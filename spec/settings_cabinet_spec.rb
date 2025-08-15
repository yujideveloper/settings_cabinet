# frozen_string_literal: true

require "spec_helper"

RSpec.describe SettingsCabinet do
  context "without namespace" do
    it "can access setting" do
      expect(Settings.defaults.setting1).to eq 1
    end

    it "can access setting override" do
      expect(Settings.development.setting2).to eq "override 2"
    end

    it "can access calculated setting" do
      expect(Settings.defaults.setting3).to eq 9
    end

    it "can access nested setting" do
      expect(Settings.defaults.setting4.setting_child1).to eq "child1"
    end
  end

  context "with namespace" do
    it "can access setting" do
      expect(DevelopmentSettings.setting1).to eq 1
    end

    it "can access setting override" do
      expect(DevelopmentSettings.setting2).to eq "override 2"
    end

    it "can access calculated setting" do
      expect(DevelopmentSettings.setting3).to eq 9
    end

    it "can access nested setting" do
      expect(DevelopmentSettings.setting4.setting_child1).to eq "child1"
    end
  end

  context "without permitted classes" do
    it "cannot access date and raises a DisallowedClass exception" do
      expect { UnpermitedDateAndTimeSettings.date }.to raise_error(YAML::DisallowedClass)
    end

    it "cannot access time and raises a DisallowedClass exception" do
      expect { UnpermitedDateAndTimeSettings.time }.to raise_error(YAML::DisallowedClass)
    end
  end

  context "with permitted classes" do
    it "can access date setting" do
      expect(DateAndTimeSettings.date).to eq Date.new(2022, 4, 20)
    end

    it "can access time setting" do
      expect(DateAndTimeSettings.time).to eq Time.new(2022, 4, 20, 12, 35, 45, "+09:00")
    end
  end

  describe ".[]" do
    it "can access nested setting" do
      expect(Settings[:defaults][:setting4][:setting_child1]).to eq "child1"
    end

    it "can access nested setting using string keys" do
      expect(Settings["defaults"]["setting4"]["setting_child1"]).to eq "child1"
    end

    it "returns `nil` if unknown key is specified" do
      expect(Settings[:not_exist_key1]).to be_nil
    end
  end

  describe ".dig" do
    it "can access nested setting" do
      expect(Settings.dig(:defaults, :setting4, :setting_child2, 0)).to eq 1
    end

    it "can access nested setting using string keys" do
      expect(Settings.dig("defaults", "setting4", "setting_child2", 0)).to eq 1
    end

    it "returns `nil` if unknown key is specified" do
      expect(Settings.dig(:defaults, :not_exist_key1, :not_exist_key2)).to be_nil
    end
  end

  describe ".fetch" do
    it "can access nested setting" do
      expect(Settings.fetch(:defaults).fetch(:setting4).fetch(:setting_child1)).to eq "child1"
    end

    it "can access nested setting using string keys" do
      expect(Settings.fetch("defaults").fetch("setting4").fetch("setting_child1")).to eq "child1"
    end

    it "raises KeyError if unknown key is specified" do
      expect { Settings.fetch(:not_exist_key1) }.to raise_error KeyError
    end

    it "returns default value if unknown key and default value are specified" do
      expect(Settings.fetch(:not_exist_key1, "default value")).to eq "default value"
    end
  end

  describe ".fetch_values" do
    it "can access multiple settings" do
      expect(DevelopmentSettings.fetch_values(:setting1, :setting2)).to eq [1, "override 2"]
    end

    it "raises KeyError if unknown key is contained" do
      expect { DevelopmentSettings.fetch_values(:setting1, :setting2, :not_exist_key1) }.to raise_error KeyError
    end

    it "returns containing evaluated value of specified block as the value corresponding to unknown key" do
      expect(DevelopmentSettings.fetch_values(:setting1, :not_exist_key1, :not_exist_key2) { |k| "block #{k}" })
        .to eq [1, "block not_exist_key1", "block not_exist_key2"]
    end

    it "returns empty array if keys are not specified" do
      expect(DevelopmentSettings.fetch_values).to eq []
    end
  end

  describe ".values_at" do
    it "can access multiple settings" do
      expect(DevelopmentSettings.values_at(:setting1, :setting2)).to eq [1, "override 2"]
    end

    it "returns containing `nil` as the value corresponding to uknwon key" do
      expect(DevelopmentSettings.values_at(:setting1, :setting2, :not_exist_key1)).to eq [1, "override 2", nil]
    end

    it "returns empty array if keys are not specified" do
      expect(DevelopmentSettings.values_at).to eq []
    end
  end

  describe ".to_h" do
    it "returns a hash" do
      expect(DevelopmentSettings.to_h).to eq(
        { setting1: 1, setting2: "override 2", setting3: 9,
          setting4: { setting_child1: "child1", setting_child2: [1, 2, 3] },
          settings5: { 
            target1: { key1: "value1", key2: "value2" },
            target2: { key1: "value1", key2: "value2" }
          } }
      )
    end
  end

  context "hash keys functionality" do
    it "allows access to hash keys method" do
      hash_test = Settings.defaults.settings5
      expect(hash_test.keys).to eq([:target1, :target2])
    end

    it "allows access to nested hash keys" do
      target1 = Settings.defaults.settings5.target1
      expect(target1.keys).to eq([:key1, :key2])
    end

    it "allows access to root level keys" do
      defaults_keys = Settings.defaults.keys
      expect(defaults_keys).to include(:setting1, :setting2, :setting3, :setting4, :settings5)
    end
  end

  describe ".load!" do
    let!(:settings_class_str) do
      <<~CLASS
        Class.new(described_class::Base).tap do |klass|
          klass.class_exec(described_class) do |described_class|
            using described_class::DSL
            source File.expand_path("./spec/fixtures/settings.yml", __dir__)
            namespace "test"
          end
        end
      CLASS
    end
    let!(:load_settings_str) do
      <<~LOAD
        settings_class.class_exec(described_class) do |described_class|
          using described_class::Control
          load!
        end
      LOAD
    end

    it "loads settings" do
      settings_class = instance_eval(settings_class_str)
      load_settings = -> { instance_eval(load_settings_str) }
      expect { load_settings.call }
        .to change { settings_class.instance_variable_defined?(:@instance) }.from(false).to(true)
    end

    it "does not reload settings" do
      settings_class = instance_eval(settings_class_str)
      load_settings = -> { instance_eval(load_settings_str) }
      load_settings.call
      expect { load_settings.call }
        .not_to(change { settings_class.instance_variable_get(:@instance).object_id })
    end
  end
end
