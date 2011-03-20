$: << '.'
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "/../lib"))
require 'rspec'
require 'rspec/matchers'
require 'hashmodel'

Dir["#{File.expand_path(File.join(File.dirname(__FILE__)))}/support/**/*.rb"].map {|f| require f}



