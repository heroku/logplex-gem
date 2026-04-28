require 'spec_helper'
require 'logplex/publisher'
require 'logplex/message'

describe Logplex::Publisher do
  describe '#publish' do
    before do
      Logplex.configure do |config|
        config.process = "postgres"
        config.host = "host"
      end
    end

    context 'with a working logplex' do
      after do
        restore_default_config
      end

      it 'encodes a message and publishes it' do
        stub = WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /message for you/, basic_auth: ['token', 't.some-token'])
          .to_return(status: 204)
        message = 'I have a message for you'
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        publisher.publish(message)
        expect(stub).to have_been_requested
      end

      it 'sends many messages in one request when passed an array' do
        stub = WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /message for you.+here is another.+some final thoughts/, basic_auth: ['token', 't.some-token'])
          .to_return(status: 204)
        messages = ['I have a message for you', 'here is another', 'some final thoughts']
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        publisher.publish(messages)
        expect(stub).to have_been_requested
      end

      it 'uses the token if app_name is not given' do
        stub = WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /t.some-token/, basic_auth: ['token', 't.some-token'])
          .to_return(status: 204)
        message = 'I have a message for you'
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        publisher.publish(message)
        expect(stub).to have_been_requested
      end

      it 'uses the given app_name' do
        stub = WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /foo/, basic_auth: ['token', 't.some-token'])
          .to_return(status: 204)
        message = 'I have a message for you'
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        publisher.publish(message, app_name: 'foo')
        expect(stub).to have_been_requested
      end

      it 'does the thing' do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /hi\="there\"/, basic_auth: ['token', 't.some-token'])
          .to_return(status: 204)
        message = { hi: 'there' }
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        expect(publisher.publish(message)).to be_truthy
      end

      it 'does the thing with a 202' do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(body: /hi\="there\"/, basic_auth: ['token', 't.some-token'])
          .to_return(status: 202)
        message = { hi: 'there' }
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        expect(publisher.publish(message)).to be_truthy
      end

      it 'returns true' do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(basic_auth: ['token', 't.some-token'])
          .to_return(status: 204)
        message = 'I have a message for you'
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        expect(publisher.publish(message)).to be_truthy
      end

      it "returns false when there's an auth error" do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(basic_auth: ['token', 't.some-token'])
          .to_return(status: 401)
        message = 'I have a message for you'
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        expect(publisher.publish(message)).to be_falsey
      end
    end

    context 'when the logplex service is acting up' do
      it 'returns false' do
        WebMock.stub_request(:post, "https://logplex.example.com")
          .with(basic_auth: ['token', 't.some-token'])
          .to_return(status: 500)
        publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
        expect(publisher.publish('hi')).to be_falsey
      end
    end

    it "handles timeouts" do
      WebMock.stub_request(:post, "https://logplex.example.com")
        .to_timeout
      publisher = Logplex::Publisher.new('https://token:t.some-token@logplex.example.com')
      expect(publisher.publish('hi')).to be_falsey
    end

    it "includes the correct headers" do
      stub = WebMock.stub_request(:post, "https://logplex.example.com")
        .with(
          basic_auth: ['token', 't.some-token'],
          headers: {
            "Content-Type" => 'application/logplex-1',
            "Content-Length" => 79,
            "Logplex-Msg-Count" => 1
          }
        ).to_return(status: 204)
      message = 'hello-harold'
      Logplex::Publisher.new('https://token:t.some-token@logplex.example.com').publish(message)
      expect(stub).to have_been_requested
    end

    it "supports bearer authentication" do
      stub = WebMock.stub_request(:post, "https://logplex-next.example.com")
        .with(
          headers: {
            "Authorization" => 'Bearer test-bearer-token',
            "Content-Type" => 'application/logplex-1',
            "Content-Length" => 70,
            "Logplex-Msg-Count" => 1
          }
        ).to_return(status: 204)
      message = 'hello-bearer'
      Logplex::Publisher.new('https://logplex-next.example.com', bearer_token: 'test-bearer-token').publish(message)
      expect(stub).to have_been_requested
    end
  end
end
