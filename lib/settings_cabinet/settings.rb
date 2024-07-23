# frozen_string_literal: true

module SettingsCabinet
  class Settings
    module AccessorBuilder
      refine Settings do
        private

        def define_accessors!(values)
          values.each_key do |k|
            name = k.to_s
            next unless name.match?(/\A\w+\z/)

            singleton_class.class_eval <<~METHOD, __FILE__, __LINE__ + 1
              def #{name}            # def foo
                self[:#{name.dump}]  #   self[:foo]
              end                    # end
            METHOD
          end
        end
      end
    end
    private_constant :AccessorBuilder

    using AccessorBuilder

    def initialize(hash)
      @values = hash.transform_values { |v| v.is_a?(::Hash) ? self.class.new(v) : v }

      define_accessors!(@values)
    end

    def [](key)
      @values[key.to_sym]
    end

    def dig(*keys)
      keys[0] = keys[0].to_sym unless keys.empty?
      @values.dig(*keys)
    end

    def fetch(key, ...)
      @values.fetch(key.to_sym, ...)
    end

    def fetch_values(*keys, &block)
      @values.fetch_values(*keys.map(&:to_sym), &block)
    end

    def values_at(*keys)
      @values.values_at(*keys.map(&:to_sym))
    end

    def to_h
      @values.transform_values { |v| v.is_a?(self.class) ? v.to_h : v }
    end
  end
end
