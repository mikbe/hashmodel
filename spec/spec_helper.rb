$: << '.'
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "/../lib"))
require 'hashmodel'
require 'rspec'
require 'rspec/matchers'

# Make a new class with the given name and create instance variables set using key,value pairs.
# e.g. new_class = create_class "Dummy", {:x=>"x", :y=>String, :z=>["1",2,:three]}
def create_proc_tester(property_value_hash)
  proc_test = Class.new.new

  # Add an evaluator method to make it more clear what we are doing
  proc_test.class.class_eval do
     define_method(:xql?) { |&block| instance_eval &block }
  end

  # Add the property values to this instance of the class
  property_value_hash.each do |key, value| 
    proc_test.instance_variable_set("@#{key}", value)
  end

  proc_test
end


# Debug print
module Kernel
  def dp(value)
    puts ""
    puts "*" * 40
    puts "value: #{value}"
    puts "&" * 40
    puts ""
  end
end
