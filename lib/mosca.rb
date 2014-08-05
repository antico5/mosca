require 'mqtt'
require 'json'

class Mosca
  @@default_broker = "test.mosquitto.org"
  @@default_timeout = 5

  attr_accessor :user, :pass, :topic_in, :topic_out, :broker, :topic_base, :client

  def initialize args = {}
    options = default.merge(args)
    attributes.each do |attribute|
      send "#{attribute}=".to_sym, options[attribute]
    end
  end

  def publish json, params = {}
    connection do |c|
      topic = params[:topic_out] || @topic_out
      c.subscribe(topic_base + topic_in) if params[:response]
      c.publish(topic_base + topic,json)
      get(params.merge({connection: c})) if params[:response]
    end
  end

  def get params = {}
    response = {}
    connection(params) do |c|
      topic = params[:topic_in] || @topic_in
      timeout = params[:timeout] || @@default_timeout
      begin
        Timeout.timeout(timeout) do
          c.get(topic_base + topic) do |topic, message|
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
    def default
      { topic_base: "",
        broker: @@default_broker,
        client: MQTT::Client }
    end

  def connection params = {}
    if params[:connection]
      yield params[:connection]
    else
      @client.connect(opts) do |c|
        yield c
      end
    def attributes
      [:user, :pass, :topic_in, :topic_out, :topic_base, :broker, :client]
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


  def timestamp
    Time.new.to_f.to_s
  end
end
