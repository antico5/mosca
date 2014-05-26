require 'spec_helper'
require 'freezer'
require 'mosca'

class MockClient
  attr_accessor :sent_msg
  def publish msg
    @sent_msg = msg
  end
end

describe Freezer do
  it "sends a start_freezer_login message" do
    client = MockClient.new
#    client = Mosca.new topic_out: "armanout"
    freezer = Freezer.new freezer_id: 123, client: client
    freezer.start_freezer_login

    expected = { "freezer_id" =>  123,
        "command" => "start_freezer_login",
        "user_id" => "",
        "body" => {},
        "admin" => false }
    sent = JSON.parse(client.sent_msg)
    sent.should eq(expected)
  end
end
