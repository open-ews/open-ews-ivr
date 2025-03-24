# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "aws-sdk-ssm"
gem "encrypted_credentials", github: "somleng/encrypted_credentials"
gem "pumi"
gem "sentry-ruby"
gem "twilio-ruby"
gem "rack"

group :development do
  gem "rake"
  gem "rubocop"
  gem "rubocop-rails-omakase"
  gem "rubocop-rspec"
  gem "rubocop-performance"
end

group :test do
  gem "activesupport"
  gem "pry"
  gem "rspec"
  gem "simplecov", require: false
  gem "simplecov-cobertura", require: false
  gem "webmock"
end
