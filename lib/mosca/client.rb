require 'mqtt'
require 'json'
require 'mosca/exceptions'

module Mosca

  class Client

    class << self
      attr_accessor :default_broker, :default_timeout
    end

    self.default_broker = ENV["MOSCA_BROKER"] || "test.mosquitto.org"
    self.default_timeout = 5

    attr_accessor :user, :pass, :topic_in, :topic_out, :broker, :topic_base, :client

    def initialize args = {}
      options = default.merge(args)
      attributes.each do |attribute|
        send "#{attribute}=".to_sym, options[attribute]
      end
    end

    def publish json, params = {}
      topic_out = params[:topic_out] || params[:topic] || @topic_out || Exceptions.raise_missing_topic
      topic_in = params[:topic_in] || @topic_in
      connection.subscribe full_topic(topic_in) if params[:response]
      connection.publish full_topic(topic_out), json
      get(params) if params[:response]
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

    private

      def default
        { topic_base: "",
          broker: self.class.default_broker,
          client: MQTT::Client }
      end

      def attributes
        [:user, :pass, :topic_in, :topic_out, :topic_base, :broker, :client]
      end

      def client_options
        {remote_host: @broker, username: @user, password: @pass}
      end

      def connection
        if @connection and @connection.connected?
          @connection
        else
          @connection ||= @client.connect(client_options)
        end
      end

      def parse_response response
        JSON.parse response
        rescue JSON::ParserError
          response
      end

      def timeout params
        timeout = params[:timeout] || self.class.default_timeout
        Timeout.timeout(timeout) do
          yield
        end
      end
  end
end
