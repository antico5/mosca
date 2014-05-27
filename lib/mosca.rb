require 'mqtt'
require 'json'

class Mosca
  @@default_broker = "test.mosquitto.org"
  @@default_timeout = 5

  attr_accessor :user, :pass, :topic_in, :topic_out, :broker

  def initialize params = {}
    @user = params[:user]
    @pass = params[:pass]
    @topic_in = params[:topic_in]
    @topic_out = params[:topic_out]
    @broker = params[:broker] ||  @@default_broker
    @client = params[:client] || MQTT::Client
  end

  def publish json, params = {}
    connection do |c|
      topic = params[:topic] || @topic_out
      c.publish(topic,json)
      if params[:response]
        return get(params)
      end
    end
  end

  def get params = {}
    response = {}
    connection do |c|
      topic = params[:topic] || @topic_in
      timeout = params[:timeout] || @@default_timeout
      begin
        Timeout.timeout(timeout) do
          c.get(topic) do |topic, message|
            response = parse_response message
            break
          end
        end
      rescue
      end
    end
    response
  end

  def self.default_broker= param
    @@default_broker = param
  end

  def self.default_timeout= param
    @@default_timeout = param
  end

  private

  def opts
    {remote_host: @broker, username: @user, password: @pass}
  end

  def connection
    @client.connect(opts) do |c|
      yield c
    end
  end

  def parse_response response
    if valid_json? response
      response = JSON.parse response
    end
    response
  end

  def valid_json? json_
    begin
      JSON.parse(json_)
      return true
    rescue
      return false
    end
  end
end
