require 'json'

module Mosca
  module CommandBuilder
    def method_missing(method, *args)
      json = full_hash(method, *args).to_json
      client.publish json
    end

    protected

    def default_hash
      {}
    end

    def process_command command, args
      {command: command}
    end

    private

    def specific_hash method, args
      hash = {}
      if respond_to? "#{method}_hash"
        hash.merge! send("#{method}_hash", args)
      end
      hash
    end

    def full_hash method, *args
      command_default = process_command(method, *args)
      command_specific = specific_hash(method, *args)
      default_hash.merge(command_default).merge(command_specific)
    end
  end
end
