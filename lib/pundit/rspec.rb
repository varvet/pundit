if RSpec::Core::Version::STRING.starts_with?("3")
  require 'pundit/rspec3'
else
  require 'pundit/rspec2'
end
