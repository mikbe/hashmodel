class Foo
  
  attr_accessor :bar
  
  def initialize
    @bar = 1
  end
  
  def show
    vars = instance_variables
    instance_variables.each do |var|
      puts "var: #{var}"
    end
    print "no vars "
    puts instance_variables.class
  end
  
end

f = Foo.new

f.show

puts f.instance_variables