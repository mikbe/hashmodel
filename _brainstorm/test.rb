class Fruit
  
  def set_defaults
    @color ||= 'green'
    @type  ||= 'pear'
  end    

  def initialize(params = {})
    params.each { |key,value| instance_variable_set("@#{key}", value) }
    set_defaults
    instance_variables.each {|var| self.class.send(:attr_accessor, var)}
  end

  def to_s
    instance_variables.inject("") {|vars, var| vars += "#{var}: #{instance_variable_get(var)}; "}
  end
  
end

puts Fruit.new
puts Fruit.new :color => 'red', :type => 'grape'  
puts Fruit.new :type => 'pomegranate'
puts Fruit.new :cost => 20.21
puts Fruit.new :foo => "bar"

f = Fruit.new :potato => "salad"
puts "f.cost.nil? #{f.cost.nil?}"
