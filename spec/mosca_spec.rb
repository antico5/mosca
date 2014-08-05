require 'spec_helper'

describe Mosca do
  OUT = "out_topic"
  IN = "in_topic"

  before do
    @client_double = ClientDouble.new
    @mosca = Mosca.new topic_out: OUT, topic_in: IN, client: @client_double
    @test_message = "something"
  end

  it "has a default broker" do
    expect(@mosca.broker).to eq("test.mosquitto.org")
  end

  it "has attribute accessors" do
    %w{user pass broker topic_in topic_out topic_base}.each do |attr|
      expect(@mosca).to respond_to(attr.to_sym)
      expect(@mosca).to respond_to("#{attr}=".to_sym)
    end
  end

  describe "publishing" do

    it "uses topic_out to publish if it was specified, and publishes the desired message" do
      expect(@client_double).to receive(:publish).with(OUT,@test_message)
      @mosca.publish @test_message
    end

    it "can take a topic_out as argument when publishing" do
      new_out_topic = "other_out_topic"
      expect(@client_double).to receive(:publish).with(new_out_topic,@test_message)
      @mosca.publish @test_message, topic_out: new_out_topic
    end

    it "should wait for a response on topic_in if it's specified" do
      expect(@client_double).to receive(:connect).once.and_yield(@client_double)
      expect(@mosca.publish(@test_message, response: true)).to eq("response")
    end

  end

  describe "subscribing" do

    it "uses topic_in to get messages if it was specified" do
      expect(@client_double).to receive(:get).with(IN)
      @mosca.get
    end

    it "can take a topic_in as argument when getting" do
      new_in_topic = "other_in_topic"
      expect(@client_double).to receive(:get).with(new_in_topic)
      @mosca.get topic_in: new_in_topic
    end

    it "will receive the message with get" do
      expect(@mosca.get).to eq("response")
    end

  end

  describe "parsing the incoming messages" do

    it "gets a hash if the message was a JSON object" do
      expect(@mosca.get topic_in: "json_in_topic").to be_a(Hash)
    end

    it "gets an array if the message was a JSON array" do
      expect(@mosca.get topic_in: "json_array_in_topic").to be_a(Array)
    end

  end

  describe "formatting the topic names" do

    before do
      @mosca.topic_base = "/base/"
    end

    it "uses topic_base to form the full topic for publishing and receiving" do
      expect(@client_double).to receive(:get).with("/base/#{IN}")
      expect(@client_double).to receive(:publish).with("/base/#{OUT}", @test_message)
      @mosca.get
      @mosca.publish @test_message
    end

  end
end
