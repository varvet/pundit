require 'rubygems'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'

Rake::TestTask.new(:spec) do |test|
  test.libs << 'spec'
  test.test_files = Dir['spec/**/*_spec.rb']
  test.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  #t.options = ['--any', '--extra', '--opts'] # optional
end

task :default => [:spec]
