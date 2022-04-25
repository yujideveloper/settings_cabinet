# frozen_string_literal: true

require "yaml"
require "erb"

require_relative "settings"
require_relative "configuration"

module SettingsCabinet
  class Base
    module AccessorBuilder
      RESERVED_METHODS = %i[instance define_accessors! define_class_accessors!].freeze
      private_constant :RESERVED_METHODS

      refine Base do
        private

        def define_accessors!(values)
          values.each_key do |key|
            name = key.to_s
            next unless name.match?(/\A\w+\z/)

            self.class.class_eval <<~METHOD, __FILE__, __LINE__ + 1
              def #{name}            # def foo
                self[:#{name.dump}]  #   self[:foo]
              end                    # end
            METHOD
          end
        end

        def define_class_accessors!
          names = public_methods(false)
            .difference(::Object.public_methods, self.class.public_methods(false), RESERVED_METHODS)
          names.each do |name|
            self.class.class_eval <<~METHOD, __FILE__, __LINE__ + 1
              def self.#{name}(...)     # def self.foo(...)
                @instance.#{name}(...)  #   @instance.foo(...)
              end                       # end
            METHOD
          end
        end
      end
    end
    private_constant :AccessorBuilder

    module SettingsLoader
      refine Base do
        def load_settings_hash(config)
          YAMLSettingsLoader.new(config).call
        end
      end

      class YAMLSettingsLoader
        def initialize(config)
          @source = config.source
          @namespace = config.namespace
          @permitted_classes = config.permitted_classes
        end

        def call
          erb_str = ::File.read(source)
          yaml_str = ::ERB.new(erb_str).result
          ::YAML
            .safe_load(yaml_str,
                       permitted_classes: permitted_classes,
                       aliases: true,
                       filename: source,
                       fallback: {},
                       symbolize_names: true)
            .then { |h| namespace ? h.fetch(namespace.to_sym) : h }
        end

        private

        attr_reader :source, :namespace, :permitted_classes
      end
      private_constant :YAMLSettingsLoader
    end

    require_relative "instance"
    using Instance

    using SettingsLoader
    using AccessorBuilder

    def initialize(config)
      settings_hash = load_settings_hash(config)

      @settings = Settings.new(settings_hash)

      define_accessors!(settings_hash)
      define_class_accessors!
    end

    def [](...)
      @settings.[](...)
    end

    def dig(...)
      @settings.dig(...)
    end

    def fetch(...)
      @settings.fetch(...)
    end

    def fetch_values(...)
      @settings.fetch_values(...)
    end

    def values_at(...)
      @settings.values_at(...)
    end

    def to_h(...)
      @settings.to_h(...)
    end

    def self.[](...)
      instance.[](...)
    end

    def self.dig(...)
      instance.dig(...)
    end

    def self.fetch(...)
      instance.fetch(...)
    end

    def self.fetch_values(...)
      instance.fetch_values(...)
    end

    def self.values_at(...)
      instance.values_at(...)
    end

    def self.to_h(...)
      instance.to_h(...)
    end

    def self.method_missing(...)
      instance.public_send(...)
    end
    private_class_method :method_missing

    def self.respond_to_missing?(symbol, _include_private)
      instance.respond_to?(symbol, false)
    end
    private_class_method :respond_to_missing?

    def self.new(*)
      raise ::NotImplementedError, "#{self} is an abstract class and cannot be instantiated." if self == Base

      super
    end
    private_class_method :new

    def self.inherited(subclass)
      super
      config = Configuration.new(source: nil, namespace: nil, permitted_classes: [])
      subclass.instance_variable_set(:@config, config)
      subclass.instance_variable_set(:@instance_lock, ::Mutex.new)
    end
    private_class_method :inherited
  end
end
