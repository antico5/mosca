require 'mqtt'
require 'json'
require 'mosca/exceptions'
require 'forwardable'

module Mosca
  class Client
    extend Forwardable

    DEFAULT_KEEP_ALIVE = 10
    KEEP_ALIVE_MARGIN = 5

    class << self
      attr_accessor :default_broker, :default_timeout
    end

    self.default_broker  = ENV["MOSCA_BROKER"]  || "test.mosquitto.org"
    self.default_timeout = ENV["MOSCA_TIMEOUT"] || 5

    attr_accessor :user, :pass, :topic_in, :topic_out, :broker, :topic_base, :client
    def_delegators :connection, :subscribe

    def initialize args = {}
      @user = args[:user] || ENV["MOSCA_USER"]
      @pass = args[:user] || ENV["MOSCA_PASS"]
      @topic_in = args[:topic_in]
      @topic_out = args[:topic_out]
      @topic_base = args[:topic_base] || ""
      @broker = args[:broker] || ENV["MOSCA_BROKER"] || self.class.default_broker
      @client = args[:client] || MQTT::Client
      @keep_alive = args[:keep_alive] || DEFAULT_KEEP_ALIVE
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
        {remote_host: @broker, username: @user, password: @pass}
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

      def timeout params
        timeout = params[:timeout] || ENV["MOSCA_TIMEOUT"].to_i || self.class.default_timeout
        Timeout.timeout(timeout) do
          yield
        end
      end

      def is_alive?
        ( Time.now - @connection.last_ping_response ) < @keep_alive + KEEP_ALIVE_MARGIN
      end
  end
end
