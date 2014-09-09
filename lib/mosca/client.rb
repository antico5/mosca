require 'mqtt'
require 'json'
require 'mosca/exceptions'

module Mosca

  class Client

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
        topic_out = params[:topic_out] || params[:topic] || @topic_out || Exceptions.raise_missing_topic
        topic_in = params[:topic_in] || @topic_in
        c.subscribe full_topic(topic_in) if params[:response]
        c.publish full_topic(topic_out), json
        get params.merge({connection: c}) if params[:response]
      end
    end

    def get params = {}
      response = {}
      connection(params) do |c|
        topic = params[:topic_in] || params[:topic] || @topic_in || Exceptions.raise_missing_topic
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

    def full_topic topic_name
      topic_base + topic_name
    end

    private

      def default
        { topic_base: "",
          broker: @@default_broker,
          client: MQTT::Client }
      end

      def attributes
        [:user, :pass, :topic_in, :topic_out, :topic_base, :broker, :client]
      end

      def client_options
        {remote_host: @broker, username: @user, password: @pass}
      end

      def connection params = {}
        if params[:connection]
          yield params[:connection]
        else
          @client.connect(client_options) do |c|
            yield c
          end
        end
      end

      def parse_response response
        JSON.parse response
        rescue JSON::ParserError
          response
      end

  end
end
