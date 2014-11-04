require 'spec_helper'

describe Mosca::Client do
  OUT = "out_topic"
  IN = "in_topic"
  MESSAGE = "test_message"

  let (:client) {
    ClientDouble.new
  }

  let (:mosca) {
    mosca = Mosca::Client.new topic_out: OUT, topic_in: IN, client: client
    allow(mosca).to receive(:is_alive?).and_return true
    mosca
  }

  it "has a default broker" do
    expect(mosca.broker).to eq("test.mosquitto.org")
  end

  it "has attribute accessors" do
    %w{user pass broker topic_in topic_out topic_base}.each do |attr|
      expect(mosca).to respond_to(attr.to_sym)
      expect(mosca).to respond_to("#{attr}=".to_sym)
    end
  end

  describe "publishing" do
    it "uses topic_out to publish if it was specified, publishes the desired message and returns the message when successfully published" do
      expect(client).to receive(:publish).with(OUT,MESSAGE)
      expect(mosca.publish MESSAGE).to eq MESSAGE
    end

    it "can take a topic_out as argument when publishing" do
      new_out_topic = "other_out_topic"
      expect(client).to receive(:publish).with(new_out_topic,MESSAGE)
      mosca.publish MESSAGE, topic_out: new_out_topic
    end

    it "should wait for a response on topic_in if it's specified" do
      expect(client).to receive(:connect).once.and_call_original
      expect(mosca.publish(MESSAGE, response: true)).to eq("response")
    end
  end

  describe "subscribing" do
    it "uses topic_in to get messages if it was specified" do
      expect(client).to receive(:get).with(IN)
      mosca.get
    end

    it "can take a topic_in as argument when getting" do
      new_in_topic = "other_in_topic"
      expect(client).to receive(:get).with(new_in_topic)
      mosca.get topic_in: new_in_topic
    end

    it "will receive the message with get" do
      expect(mosca.get).to eq("response")
    end

    it "will delegate subscribe to the mqtt client" do
      allow(mosca).to receive(:connection).and_return(client)
      expect(client).to receive(:subscribe).with("queue")
      mosca.subscribe "queue"
    end
  end

  describe "parsing the incoming messages" do
    it "gets a hash if the message was a JSON object" do
      expect(mosca.get topic_in: "json_in_topic").to be_a Hash
    end

    it "gets an array if the message was a JSON array" do
      expect(mosca.get topic_in: "json_array_in_topic").to be_a Array
    end

    it "gets plain text if the message aint JSON" do
      expect(mosca.get topic_in: "plain_in_topic").to be_a String
    end
  end

  describe "formatting the topic names" do
    before do
      mosca.topic_base = "/base/"
    end

    it "uses topic_base to form the full topic for publishing and receiving" do
      expect(client).to receive(:get).with("/base/#{IN}")
      expect(client).to receive(:publish).with("/base/#{OUT}", MESSAGE)
      mosca.get
      mosca.publish MESSAGE
    end
  end

  describe "Exceptions raising" do
    describe "raises MissingTopic" do
      it "when publishing without topic" do
        mosca.topic_out = nil
        expect { mosca.publish "hi" }.to raise_error Mosca::Exceptions::MissingTopic
      end

      it "when getting without topic" do
        mosca.topic_in = nil
        expect { mosca.get }.to raise_error Mosca::Exceptions::MissingTopic
      end
    end
  end

  describe "Timeout" do
    it "has a default timeout of 5 seconds" do
      expect(Mosca::Client.default_timeout).to eq(5)
    end

    it "can set a default timeout" do
      described_class.default_timeout = 1
      expect(described_class.default_timeout).to eq 1
    end

    it "calls timeout when getting a message" do
      expect(Timeout).to receive(:timeout)
      mosca.get
    end

    context "time runs out" do
      before do
        expect(Timeout).to receive(:timeout).and_raise Timeout::Error
      end

      it "get returns nil" do
        expect(mosca.get).to be nil
      end

      it "publish returns nil" do
        expect(mosca.publish 123).to be nil
      end

      it "get! raises the timed out exception" do
        expect{ mosca.get! }.to raise_error Timeout::Error
      end

      it "publish! raises the timed out exception" do
        expect{ mosca.publish! 123 }.to raise_error Timeout::Error
      end
    end
  end

  describe "Environment variables" do
    it "can set MOSCA_BROKER" do
      ENV["MOSCA_BROKER"] = "broker"
      expect(described_class.new.broker).to eq "broker"
    end

    it "can set MOSCA_USER" do
      ENV["MOSCA_USER"] = "USER"
      expect(described_class.new.user).to eq "USER"
    end

    it "can set MOSCA_PASS" do
      ENV["MOSCA_PASS"] = "PASS"
      expect(described_class.new.pass).to eq "PASS"
    end

    it "can set MOSCA_TIMEOUT" do
      ENV["MOSCA_TIMEOUT"] = "3"
      expect(Timeout).to receive(:timeout).with 3
      mosca.get
    end
  end
end
