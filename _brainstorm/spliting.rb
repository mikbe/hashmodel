
def deflatten(input)
  case input
    when Hash
      new_hash = {}
      input.each do |key,value|
        split_key = key.to_s.split("__",2)
        new_hash_key = split_key[0].to_sym
        if split_key.length > 1
          child_hash = {split_key[1].to_sym => value}
          value = deflatten(child_hash)
        end
        
        #look for existing keys so we don't overwrite them
        existing_value = new_hash[new_hash_key]
        if !existing_value.nil?
          if existing_value.class == Hash && value.class == Hash
              value = existing_value.merge(value)
          elsif existing_value.class == Array
              value = existing_value << value
          else
              value = [value, existing_value]
          end
        end
        new_hash.merge!(new_hash_key => value)
      end
      new_hash
    when Array
      input.collect { |value| deflatten(value.clone)}
    else
      input
  end # case
end

hash = {:switch=>"-x", :parameter__type=>String, :parameter__required=>true, :some__value__blrop=>[1,2,3], :some__hash=>{:blah=>"bloo", :bleep=>4}, :some__value=>"something", :some__others=>"others", :some__array=> [1,2,3], :description=>"the x paramemter"}

puts ""
puts ""
puts "build_hash: #{deflatten(hash)}"

{
  :switch=>"-x", 
  :parameter=>{:required=>true, :type=>String}, 
  :some=>{:array=>[1, 2, 3], :others=>"others", :value=>[{:blrop=>[1,2,3]}, "something"], :hash=>{:blah=>"bloo", :bleep=>4}}, 
  :description=>"the x paramemter"
}