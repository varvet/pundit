source "https://rubygems.org"

gem "rspec", ENV["RSPEC_VERSION"] unless ENV["RSPEC_VERSION"].to_s.empty?

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.2.2")
  gem "rack", "< 2.0.0"
end

gemspec
