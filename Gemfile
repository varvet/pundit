# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Rails-related - for testing purposes
gem "actionpack", ">= 3.0.0" # Used to test strong parameters
gem "activemodel", ">= 3.0.0" # Used to test ActiveModel::Naming
gem "railties", ">= 3.0.0" # Used to test generators

# Testing
gem "rspec", ">= 3.0.0"
gem "simplecov", ">= 0.17.0"

# Development tools
gem "bundler"
gem "rake"
gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rspec"
gem "yard"
gem "zeitwerk"

# Affects us on JRuby 9.3.15.
#
# @see https://github.com/rails/rails/issues/54260
gem "logger"
