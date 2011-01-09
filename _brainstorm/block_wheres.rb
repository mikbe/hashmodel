$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "/../lib"))
require 'hash_model'
=begin

  # Creates an object with instance variables for each field at every level
  # This allows using a block like {:field1==true && :field2_subfield21="potato"}
  def create_object_from_flat_hash(record, hash_record=Class.new.new, parent_key=nil)
  
    # Iterate through the record creating the object recursively
    case record
      when Hash
        record.each do |key, value|
          flat_key = "#{parent_key}#{"__" if !parent_key.nil?}#{key}"
          hash_record.instance_variable_set("@#{flat_key}", value)
          hash_record = create_object_from_flat_hash(value, hash_record, flat_key)
        end
      when Array
        record.each do |value|
          hash_record = create_object_from_flat_hash(value, hash_record, parent_key)
        end
      else
        hash_record.instance_variable_set("@#{parent_key}", record)
    end # case
    
    hash_record
  end # create_object_from_flat_hash



records = [
  {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
  {:switch => ["-y", "--why"],  :description => "lucky what?"},
  {:switch => "-z",  :parameter => {:type => String, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
]
hm = HashModel.new(:raw_data=>records)
where = hm.where {:something == 4 && :parameter__type == String && :parameter__required == true}
puts "\nWhere:"
puts where


records = [
  {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
  {:switch => ["-y", "--why"],  :description => "lucky what?", :something => 7},
  {:switch => "-z",  :parameter => {:type => Integer, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
]
hm = HashModel.new(:raw_data=>records)
where = hm.where {:parameter == {:type => String, :required => true}}
puts "\nWhere:"
puts where


puts "\nflat object"
flat = create_object_from_flat_hash(hm[0]) 
puts flat.inspect
=end

puts "\nproc"
xproc = proc {:parameter == {:type => String, :required => true} && :switch == ["-x", "--xtended"]}
xproc_source = xproc.to_source
puts "xproc: #{xproc_source}"

matches = xproc_source.scan(/(\:\S+) ==/)

puts "matches: #{matches}"
puts "\nshow items"
matches.each do |item|
  puts "item: #{item}"
end
puts 'done'
#"proc { #{@filter} }.call".gsub(":", "@")

#x = "{:parameter == {:type => String, :required => true}, "
#x.match

puts "\nMatch test"
text = "The future Ruby is Ruby"
m1 = text.scan(/(Ruby)/)
puts "m1: #{m1}"

puts "\n\ndone"
