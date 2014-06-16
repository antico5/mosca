require 'spec_helper'

describe Mosca do
  OUT = "out_topic"
  IN = "in_topic"
  Mosca.default_timeout = 200

  before do
    @client_double = ClientDouble.new
    @mosca = Mosca.new topic_out: OUT, topic_in: IN, client: @client_double
    @test_message = "something"
  end

  it "has a default broker" do
    @mosca.broker.should eq("test.mosquitto.org")
  end

  it "uses topic_out to publish if it was specified, and publishes the desired message" do
    @client_double.should_receive(:publish).with(OUT,@test_message)
    @mosca.publish @test_message
  end
  it "can take a topic_out as argument when publishing" do
    new_out_topic = "other_out_topic"
    @client_double.should_receive(:publish).with(new_out_topic,@test_message)
    @mosca.publish @test_message, topic_out: new_out_topic
  end

  it "uses topic_in to get messages if it was specified" do
    @client_double.should_receive(:get).with(IN)
    @mosca.get
  end

  it "can take a topic_in as argument when getting" do
    new_in_topic = "other_in_topic"
    @client_double.should_receive(:get).with(new_in_topic)
    @mosca.get topic_in: new_in_topic
  end

  it "will receive the message with get" do
    @mosca.get.should eq("response")
  end

  it "gets a hash if the message was a JSON object" do
    @mosca.get(topic_in: "json_in_topic").should be_a(Hash)
  end

  it "gets an array if the message was a JSON array" do
    @mosca.get(topic_in: "json_array_in_topic").should be_a(Array)
  end

end
