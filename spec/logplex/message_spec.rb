# frozen_string_literal: true

require "spec_helper"
require "logplex/message"

describe Logplex::Message do
  before { Logplex.configure {} }
  after { restore_default_config }

  it "fills out fields of a syslog message" do
    message = described_class.new(
      "my message here",
      app_name: "t.some-token",
      time: DateTime.parse("1980-08-23 05:31 00:00"),
      process: "heroku-postgres",
      host: "some-host",
      message_id: "1",
    )

    expect(message.syslog_frame).to eq(
      "91 <134>1 1980-08-23T05:31:00+00:00 some-host t.some-token heroku-postgres 1 - my message here",
    )
  end

  it "is invalid for messages longer than 10240 bytes" do
    short = described_class.new("a" * 10240, app_name:   "foo",
      process: "proc",
      host:    "host",)
    long = described_class.new("a" * 10241, app_name: "foo",
      process: "proc",
      host:    "host",)
    short.validate
    long.validate

    expect(short).to be_valid
    expect(long).not_to be_valid
  end

  it "is invalid with no process or host" do
    Logplex.configure do |conf|
      conf.host = nil
      conf.process = nil
    end

    message = described_class.new("a message", app_name: "t.some-token")
    message.validate

    expect(message).not_to be_valid
    expect(message.errors[:process]).to eq ["can't be nil"]
    expect(message.errors[:host]).to eq ["can't be nil"]
  end

  it "formats logs as key/values when given a hash" do
    message = described_class.new(
      { vocals: "Robert Plant", guitar: "Jimmy Page" },
      app_name: "t.some-token",
      process: "proc",
      host: "host",
      time: DateTime.parse("1980-08-23 05:31 00:00"),
    )

    expect(message.syslog_frame).to eq(
      %(101 <134>1 1980-08-23T05:31:00+00:00 host t.some-token proc - - vocals="Robert Plant" guitar="Jimmy Page"),
    )
  end
end
