# frozen_string_literal: true

module SettingsCabinet
  module Control
    require_relative "instance"
    using Instance

    refine Base.singleton_class do
      def load!
        instance
        true
      end
    end
  end
end
