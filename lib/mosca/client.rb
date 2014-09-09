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
      connection do |c|
        topic_out = params[:topic_out] || params[:topic] || @topic_out || Exceptions.raise_missing_topic
        topic_in = params[:topic_in] || @topic_in
        c.subscribe full_topic(topic_in) if params[:response]
        c.publish full_topic(topic_out), json
        get params.merge({connection: c}) if params[:response]
      end
    end

    def get params = {}
      response = nil
      connection(params) do |c|
        topic = params[:topic_in] || params[:topic] || @topic_in || Exceptions.raise_missing_topic
        c.get(topic_base + topic) do |topic, message|
          response = parse_response message
          break
        end
      end
      response
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

      def connection params = {}
        if params[:connection]
          yield params[:connection]
        else
          timeout = params[:timeout] || self.class.default_timeout
          begin
            Timeout.timeout(timeout) do
              @client.connect(client_options) do |c|
                yield c
              end
            end
          rescue Timeout::Error
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
