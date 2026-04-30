# frozen_string_literal: true

require "spec_helper"
require "logplex/publisher"
require "logplex/message"

describe Logplex::Publisher do
  describe "#publish" do
    before do
      Logplex.configure do |config|
        config.process = "postgres"
        config.host = "host"
      end
    end

    context "with a working logplex" do
      after do
        restore_default_config
      end

      it "encodes a message and publishes it" do
        stub = WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /message for you/, basic_auth: ["token", "t.some-token"])
          .to_return(status: 204)
        message = "I have a message for you"
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        publisher.publish(message)
        expect(stub).to have_been_requested
      end

      it "sends many messages in one request when passed an array" do
        stub = WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /message for you.+here is another.+some final thoughts/, basic_auth: ["token", "t.some-token"])
          .to_return(status: 204)
        messages = ["I have a message for you", "here is another", "some final thoughts"]
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        publisher.publish(messages)
        expect(stub).to have_been_requested
      end

      it "uses the token if app_name is not given" do
        stub = WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /t.some-token/, basic_auth: ["token", "t.some-token"])
          .to_return(status: 204)
        message = "I have a message for you"
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        publisher.publish(message)
        expect(stub).to have_been_requested
      end

      it "uses the given app_name" do
        stub = WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /foo/, basic_auth: ["token", "t.some-token"])
          .to_return(status: 204)
        message = "I have a message for you"
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        publisher.publish(message, app_name: "foo")
        expect(stub).to have_been_requested
      end

      it "does the thing" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /hi="there"/, basic_auth: ["token", "t.some-token"])
          .to_return(status: 204)
        message = { hi: "there" }
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect(publisher.publish(message)).to be_truthy
      end

      it "does the thing with a 202" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /hi="there"/, basic_auth: ["token", "t.some-token"])
          .to_return(status: 202)
        message = { hi: "there" }
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect(publisher.publish(message)).to be_truthy
      end

      it "returns true" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(basic_auth: ["token", "t.some-token"])
          .to_return(status: 204)
        message = "I have a message for you"
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect(publisher.publish(message)).to be_truthy
      end

      it "raises ClientError when there's an auth error" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(basic_auth: ["token", "t.some-token"])
          .to_return(status: 401)
        message = "I have a message for you"
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect { publisher.publish(message) }.to raise_error(Logplex::HTTP::ClientError)
      end
    end

    context "when the logplex service is acting up" do
      it "raises ServerError on 500" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(basic_auth: ["token", "t.some-token"])
          .to_return(status: 500)
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect { publisher.publish("hi") }.to raise_error(Logplex::HTTP::ServerError)
      end

      it "raises ServiceUnavailableError on 503" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(basic_auth: ["token", "t.some-token"])
          .to_return(status: 503)
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect { publisher.publish("hi") }.to raise_error(Logplex::HTTP::ServiceUnavailableError)
      end

      it "ServiceUnavailableError is rescuable as ServerError" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(basic_auth: ["token", "t.some-token"])
          .to_return(status: 503)
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect { publisher.publish("hi") }.to raise_error(Logplex::HTTP::ServerError)
      end

      it "raises SeeOtherError on 303" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(basic_auth: ["token", "t.some-token"])
          .to_return(status: 303)
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect { publisher.publish("hi") }.to raise_error(Logplex::HTTP::SeeOtherError)
      end
    end

    context "when there are client errors" do
      it "raises ClientError on 401" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(basic_auth: ["token", "t.some-token"])
          .to_return(status: 401)
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect { publisher.publish("hi") }.to raise_error(Logplex::HTTP::ClientError)
      end
    end

    context "when there are network errors" do
      it "raises TimeoutError on timeout" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .to_timeout
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect { publisher.publish("hi") }.to raise_error(Logplex::HTTP::TimeoutError)
      end

      it "raises ConnectionResetError on ECONNRESET" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .to_raise(Errno::ECONNRESET)
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect { publisher.publish("hi") }.to raise_error(Logplex::HTTP::ConnectionResetError)
      end

      it "raises SocketError on connection refused" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .to_raise(Errno::ECONNREFUSED)
        publisher = described_class.new("https://token:t.some-token@logplex.example.com")
        expect { publisher.publish("hi") }.to raise_error(Logplex::HTTP::SocketError)
      end
    end

    it "includes the correct headers" do
      stub = WebMock.stub_request(:post, "https://logplex.example.com")
        .with(
          basic_auth: ["token", "t.some-token"],
          headers: {
            "Content-Type" => "application/logplex-1",
            "Content-Length" => 79,
            "Logplex-Msg-Count" => 1,
          },
        ).to_return(status: 204)
      message = "hello-harold"
      described_class.new("https://token:t.some-token@logplex.example.com").publish(message)
      expect(stub).to have_been_requested
    end

    it "supports bearer authentication" do
      stub = WebMock.stub_request(:post, "https://logplex-next.example.com")
        .with(
          headers: {
            "Authorization" => "Bearer test-bearer-token",
            "Content-Type" => "application/logplex-1",
            "Content-Length" => 70,
            "Logplex-Msg-Count" => 1,
          },
        ).to_return(status: 204)
      message = "hello-bearer"
      described_class.new("https://logplex-next.example.com", bearer_token: "test-bearer-token").publish(message)
      expect(stub).to have_been_requested
    end
  end
end
