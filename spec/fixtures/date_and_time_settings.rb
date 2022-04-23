# frozen_string_literal: true

require "date"

class DateAndTimeSettings < SettingsCabinet::Base
  using SettingsCabinet::DSL

  source File.expand_path("./date_and_time_settings.yml", __dir__)
  permitted_classes [Date, Time]
end

class UnpermitedDateAndTimeSettings < SettingsCabinet::Base
  using SettingsCabinet::DSL

  source File.expand_path("./date_and_time_settings.yml", __dir__)
end
