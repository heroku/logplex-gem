# frozen_string_literal: true

module Logplex
  module HTTP
    class Error < StandardError; end
    class ConnectionResetError < Error; end
    class SocketError < Error; end
    class TimeoutError < Error; end
    class ServerError < Error; end
    class ServiceUnavailableError < ServerError; end
    class ClientError < Error; end
    class SeeOtherError < Error; end
  end
end
