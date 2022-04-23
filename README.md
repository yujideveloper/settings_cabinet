# SettingsCabinet

[![Gem Version](https://badge.fury.io/rb/settings_cabinet.svg)](https://badge.fury.io/rb/settings_cabinet)
[![Build](https://github.com/yujideveloper/settings_cabinet/actions/workflows/main.yml/badge.svg)](https://github.com/yujideveloper/settings_cabinet/actions/workflows/main.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/9b3e8a9816ade4c40398/maintainability)](https://codeclimate.com/github/yujideveloper/settings_cabinet/maintainability)

SettingsCabinet is a simple settings solution with ERB-enabled YAML file like [settingslogic](https://github.com/settingslogic/settingslogic).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "settings_cabinet"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install settings_cabinet

## Usage

DSL is very similar to settingslogic.

```ruby
class Settings < SettingsCabinet
  using SettingsCabinet::DSL

  source Rails.root.join("config", "settings.yml")
  namespace Rails.env
end
```

| Name | Type | Description | Default | Optional |
|--|--|--|--|--|
| `source` | String | Path of settings file. | - | No |
| `namespace` | String | Using a namespace allows you to change your configuration depending on your environment. e.g. `Rails.env` | `nil` | Yes |
| `permitted_classes` | Array of Class | Arbitrary classes can be allowed by adding those classes to the allowlist. e.g. `[Date, Time]` | `[]` | Yes |


```yaml
# config/settings.yml
defaults: &defaults
  foo:
    bar: nested setting
  baz: <%= 3 * 3 %>
  quz: 24

development:
  <<: *defaults
  quz: 48

test:
  <<: *defaults

production:
  <<: *defaults
```

Accessors are defined in the same way as settingslogic, but writers do not.
```ruby
Settings.foo.bar #=> "nested setting"
Settings[:baz]   #=> 9
```

You can explicitly load all your settings, if needed.
```ruby
# e.g. config/initializers/settings.rb
using SettingsCabinet::Control
Settings.load!
```
or
```ruby
class Settings < SettingsCabinet
  using SettingsCabinet::DSL
  using SettingsCabinet::Control

  source Rails.root.join("config", "settings.yml")
  namespace Rails.env

  load!
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yujideveloper/settings_cabinet. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/yujideveloper/settings_cabinet/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SettingsCabinet project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yujideveloper/settings_cabinet/blob/main/CODE_OF_CONDUCT.md).
