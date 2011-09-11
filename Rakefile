require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'

task :default => [:test, :build]

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
end
