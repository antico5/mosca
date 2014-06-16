require 'mqtt'
require 'json'

class Mosca
  @@default_broker = "test.mosquitto.org"
  @@default_timeout = 5
  @@debug = false

  attr_accessor :user, :pass, :topic_in, :topic_out, :broker, :topic_base, :client

  def initialize params = {}
    @user = params[:user]
    @pass = params[:pass]
    @topic_in = params[:topic_in]
    @topic_out = params[:topic_out]
    @topic_base = params[:topic_base] || ""
    @broker = params[:broker] ||  @@default_broker
    @client = params[:client] || MQTT::Client
  end

  def publish json, params = {}
    connection do |c|
      topic = params[:topic_out] || @topic_out
      debug "[start publish] " + timestamp
      c.subscribe(topic_base + topic_in) if params[:response]
      c.publish(topic_base + topic,json)
      debug "[end publish] " + timestamp
      if params[:response]
        return get(params.merge({connection: c}))
      end
    end
  end

  def get params = {}
    response = {}
    connection(params) do |c|
      topic = params[:topic_in] || @topic_in
      timeout = params[:timeout] || @@default_timeout
      begin
        Timeout.timeout(timeout) do
          debug "[start get] " + timestamp
          c.get(topic_base + topic) do |topic, message|
            response = parse_response message
            break
          end
          debug "[end get] " + timestamp
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

  def self.debug= param
    @@debug = param
  end

  private

  def opts
    {remote_host: @broker, username: @user, password: @pass}
  end

  def connection params = {}
    if params[:connection]
      yield params[:connection]
    else
      @client.connect(opts) do |c|
        yield c
      end
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

  def debug message
    puts message if @@debug
  end

  def timestamp
    Time.new.to_f.to_s
  end
end
