# frozen_string_literal: true

require "net/http"
require "uri"
require "logplex/errors"
require "logplex/message"
require "timeout"

module Logplex
  class Publisher
    def initialize(logplex_url = nil, bearer_token: nil)
      @logplex_url = logplex_url || Logplex.configuration.logplex_url
      @token = URI(@logplex_url).password || Logplex.configuration.app_name
      @auth_headers = bearer_token ? { "Authorization" => "Bearer #{bearer_token}" } : {}
    end

    def publish(messages, opts = {})
      message_list = messages.dup
      unless messages.is_a? Array
        message_list = [message_list]
      end
      message_list.map! { |m| Message.new(m, { app_name: @token }.merge(opts)) }
      message_list.each(&:validate)
      if message_list.inject(true) { |accum, m| m.valid? }
        Timeout.timeout(Logplex.configuration.publish_timeout) do
          api_post(message_list.map(&:syslog_frame).join(""), message_list.length)
          true
        end
      end
    rescue Errno::ECONNRESET => e
      raise Logplex::HTTP::ConnectionResetError, e.message
    rescue ::SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH => e
      raise Logplex::HTTP::SocketError, e.message
    rescue Timeout::Error => e
      raise Logplex::HTTP::TimeoutError, e.message
    end

    private

    def api_post(message, number_messages)
      uri = URI(@logplex_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Post.new(uri)
      request.body = message
      request["Content-Type"] = "application/logplex-1"
      request["Content-Length"] = message.length
      request["Logplex-Msg-Count"] = number_messages

      if @auth_headers.key?("Authorization")
        request["Authorization"] = @auth_headers["Authorization"]
      elsif uri.password
        request.basic_auth(uri.user, uri.password)
      end

      response = http.request(request)

      code = Integer(response.code, 10)
      return if [200, 202, 204].include?(code)

      case code
      when 303
        raise Logplex::HTTP::SeeOtherError, "Unexpected response: #{response.code}"
      when 503
        raise Logplex::HTTP::ServiceUnavailableError, "Unexpected response: #{response.code}"
      when 400..499
        raise Logplex::HTTP::ClientError, "Unexpected response: #{response.code}"
      when 500..599
        raise Logplex::HTTP::ServerError, "Unexpected response: #{response.code}"
      else
        raise Logplex::HTTP::Error, "Unexpected response: #{response.code}"
      end
    end
  end
end
