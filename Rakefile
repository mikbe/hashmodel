require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
  t.verbose = true
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = %w{--tags ~@jruby} unless defined?(JRUBY_VERSION)
end

task :default => [:test, :build]
task :test =>[:cucumber, :spec]

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
  rm_rf 'rdoc'
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "HashModel #{HashModel::VERSION}"
  rdoc.rdoc_files.exclude('autotest/*')
  rdoc.rdoc_files.exclude('features/*')
  rdoc.rdoc_files.exclude('pkg/*')
  rdoc.rdoc_files.exclude('spec/**/*')
  rdoc.rdoc_files.exclude('vendor/*')
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end