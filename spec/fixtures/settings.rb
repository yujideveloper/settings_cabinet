# frozen_string_literal: true

class Settings < SettingsCabinet::Base
  using SettingsCabinet::DSL

  source File.expand_path("./settings.yml", __dir__)
end

class DevelopmentSettings < SettingsCabinet::Base
  using SettingsCabinet::DSL

  source File.expand_path("./settings.yml", __dir__)
  namespace "development"
end
