source "http://rubygems.org"

gem "cocoapods"
gem "rake"
gem 'onesky-ruby'


gem "fastlane"#, "2.131.0"
#gem "faraday", "0.15.4"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
