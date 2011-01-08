
def test_it(y)
  y.concat("_mod")
end

x = "test"
test_it x
puts "x id: #{x.object_id}"
puts "x: #{x}"

z = "z"
puts "z id: #{z.object_id}"
puts "z: #{z}"
z += "_mod"
puts "z id: #{z.object_id}"
puts "z: #{z}"
