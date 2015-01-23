require 'mqtt'
require 'json'
require 'mosca/exceptions'
require 'forwardable'

module Mosca
  class Client
    extend Forwardable

    KEEP_ALIVE_MARGIN = 5

    # class attributes
    class << self
      attr_accessor :default_broker, :default_timeout
    end

    attr_accessor :user, :pass, :topic_in, :topic_out, :broker, :topic_base,
      :client, :keep_alive, :port, :time_out

    def_delegators :connection, :subscribe

    def initialize args = {}
      default_attributes.merge(args).each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def default_attributes
      { user: ENV["MOSCA_USER"],
        pass: ENV["MOSCA_PASS"],
        topic_base: "",
        broker: ENV["MOSCA_BROKER"] || self.class.default_broker || "test.mosquitto.org",
        client: MQTT::Client,
        keep_alive: 10,
        time_out: (ENV["MOSCA_TIMEOUT"] || self.class.default_timeout || 5).to_i
      }
    end

    def publish! message, params = {}
      timeout(params) do
        topic_out = params[:topic_out] || params[:topic] || @topic_out || Exceptions.raise_missing_topic
        topic_in = params[:topic_in] || @topic_in
        connection.subscribe full_topic(topic_in) if params[:response]
        connection.publish full_topic(topic_out), message
        params[:response] ? get(params) : message
      end
    end

    def publish message, params = {}
      publish! message, params
    rescue Timeout::Error
      nil
    end

    def get! params = {}
      timeout(params) do
        topic = params[:topic_in] || params[:topic] || @topic_in || Exceptions.raise_missing_topic
        connection.get(full_topic topic) do |topic, message|
          return parse_response message
        end
      end
    end

    def get params = {}
      get! params
    rescue Timeout::Error
      nil
    end

    def full_topic topic_name
      topic_base + topic_name
    end

    def refresh_connection
      connection
    end

    def connected?
      @connection and @connection.connected? and is_alive?
    end

    private

      def client_options
        {remote_host: @broker, remote_port: @port, username: @user, password: @pass}
      end

      def connection
        if connected?
          @connection
        else
          @connection = @client.connect(client_options)
          @connection.keep_alive = @keep_alive
          @connection
        end
      end

      def parse_response response
        JSON.parse response
        rescue JSON::ParserError
          response
      end

      def timeout params, &b
        seconds = params[:timeout] || time_out
        Timeout.timeout(seconds) do
          yield
        end
      end

      def is_alive?
        ( Time.now - @connection.last_ping_response ) < @keep_alive + KEEP_ALIVE_MARGIN
      end
  end
end
