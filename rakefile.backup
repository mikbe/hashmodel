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
require './lib/hash_model/version'
version = HashModel::VERSION::STRING

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "hashmodel"
  gem.version = version
  gem.summary = %Q{Store small amounts of dynamic data and easily search fields (even nested ones)}
  gem.description = %Q{A simple MVC type model class for storing records as an array of hashes. You can store deeply nested hashes and still easily flatten and querying the records using flattened field names.}
  gem.email = "mikbe.tk@gmail.com"
  gem.homepage = "http://github.com/mikbe/hashmodel"
  gem.authors = ["Mike Bethany"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

task :default => :rspec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hash_model #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
