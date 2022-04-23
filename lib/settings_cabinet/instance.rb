# frozen_string_literal: true

module SettingsCabinet
  class SettingsSourcePathNotSpecified < ::StandardError; end

  module Instance
    MUTEX = ::Mutex.new
    private_constant :MUTEX

    refine Base.singleton_class do
      def instance
        if instance_variable_defined?(:@instance) && (instance_ = @instance)
          return instance_
        end

        @instance_lock.synchronize do
          break @instance if instance_variable_defined?(:@instance)

          raise SettingsSourcePathNotSpecified unless @config.source

          @instance = new(@config)
        end
      end
    end
  end
  private_constant :Instance
end
