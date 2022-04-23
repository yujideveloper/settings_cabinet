# frozen_string_literal: true

module SettingsCabinet
  module DSL
    refine Base.singleton_class do
      def namespace(value)
        @config.namespace = value
      end

      def source(value)
        @config.source = value
      end

      def permitted_classes(value)
        @config.permitted_classes = Array(value)
      end
    end
  end
end
