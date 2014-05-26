require 'mosca'

describe Mosca do
  before do
    @client = Mosca.new
  end

  it "has a default broker" do
    @client.broker.should eq("test.mosquitto.org")
  end

  it "uses topic_out to publish if it was specified" do

  end

  it "uses topic_in to get messages if it was specified" do

  end

  it "publishes messages" do

  end

  it "gets messages" do

  end

  it "gets a hash if the message was JSON" do

  end
end
