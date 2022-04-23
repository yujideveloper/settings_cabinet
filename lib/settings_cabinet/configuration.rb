# frozen_string_literal: true

module SettingsCabinet
  class Configuration
    attr_accessor :source, :namespace, :permitted_classes

    def initialize(source: nil, namespace: nil, permitted_classes: [])
      @source = source
      @namespace = namespace
      @permitted_classes = permitted_classes
    end
  end
  private_constant :Configuration
end
