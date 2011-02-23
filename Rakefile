require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name        = "s3-static-site"
  gem.homepage    = "http://github.com/voxxit/s3-static-site"
  gem.license     = "MIT"
  gem.summary     = %Q{Using Ruby and Capistrano, build and deploy a static website to Amazon S3}
  gem.description = %Q{Using Ruby and Capistrano, build and deploy a static website to Amazon S3}
  gem.email       = "jdelsman@voxxit.com"
  gem.authors     = ["Josh Delsman"]
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test