class TestSelf
  include Enumerable
  
  attr_accessor :data
  
  def initialize(data=[])
    @data = data
  end
  
  def each
    @data.each do |record| 
      yield record
    end
  end
  
  def to_s
    @data.to_s
  end
  
end


array = [1,2,3,4,5]
ts = TestSelf.new(array)

puts ts[2]