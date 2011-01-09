x = ["x", "y", "z"]

class Foo

  attr_accessor :array
  
  def initialize(input)
    @array = input
  end
  
end



f = Foo.new(x)

x[0] = "change"

puts f.array