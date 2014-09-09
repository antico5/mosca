module Mosca
  module Exceptions
    class MissingTopic < StandardError
    end

    def self.raise_missing_topic
      raise MissingTopic.new, "Publish or get was called without specifying topic."
    end
  end
end
