$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "/../lib"))
require 'hash_model'

hash = {
          :field1 => "f", 
          :field2 => {
            :field3 => "f3", 
            :field4 => {
              :field5 => "f5", 
              :field6 => ["f6", "f7"]
            }
          }
        }
=begin

hash2 = {
  :switch => ["-x", "--xtend"], 
  :parameter => {:type => String, :require => true}, 
  :description => "Xish stuff", 
  :field => {:field2 => {:field3 => "ff3", :field4 => "ff4"}}
}

hash2 = {
  :switch => ["-x", "--xtend"], 
  :parameter => {:type => String, :require => true}, 
  :description => "Xish stuff", 
  :field => {:field2 => [:field3 => "ff3", :field4 => "ff4", "ff5"]}
}


hm = HashModel.new
hm << hash2
hm.flatten_index = :field__field2


flat = {
        :field2__field4__field5=>"f5", 
        :field1=>"f", 
        :field3=>"f3", 
        :field2__field4__field6=>["f6", "f7"]
      }

[
  {
    :field__field2__field3=>"ff3",
    :field__field2__field4=>"ff4", 
    :switch=>["-x", "--xtend"], 
    :parameter__type=>String,
    :parameter__require=>true, 
    :description=>"Xish stuff",
  }
]

puts "\nhm: #{hm}"
#hash2 = {:field => "field", :field2__field3 => "field3", :field2__field4 => {:field5 => "field5", :field6 => ["field6", "field7"]}}}
=end



def unflatten(input)
  # Seriously in need of a refactor, just looking at this hurts my brain
  case input
    when Hash
      new_record = {}
      input.each do |key, value|
        puts "#{key} => #{value}"
        # recursively look for flattened keys
        keys = key.to_s.split("__", 2)
        if keys[1]
          key = keys[0].to_sym
          value = unflatten({keys[1].to_sym => value})
        end
      
        # Don't overwrite existing value
        if (existing = new_record[key])
          # convert to array and search for subkeys if appropriate
          if existing.class == Hash
            # Convert to an array if something other than a hash is added
            unless value.class == Hash
              new_record[key] = hash_to_array(existing)
              new_record[key] << value
            else
              # Search subkeys for duplicate values if it's a hash
              unless (found_keys = existing.keys & value.keys).empty?
                found_keys.each do |found_key|
                  if new_record[key][found_key].class == Hash
                    unless value[found_key].class == Hash
                      new_record[key] = hash_to_array(new_record[key][found_key])
                      new_record[key] << value[found_key]
                    else
                      new_record[key][found_key].merge!(value[found_key])
                    end
                  end
                end
              else
                new_record[key].merge!(value)
              end
            end
          else
            new_record[key] << value
          end
        else
          new_record.merge!(key => value)
        end
      end
      new_record
    when Array
      # recurse into array
      input.collect! {|item| unflatten(item) }
    else
      input
  end
end


def hash_to_array(hash)
  array = []
  hash.each do |key, value|
    array << {key => value}
  end
  array
end

hash = [
  {
    :field__field2__field3=>"ff3",
    :field__field2__field4=>"ff4"
  }
]

hash2 =  { 
    :switch=>["-x", "--xtend"], 
    :parameter__type=>String,
    :parameter__require=>true,
    :description=>"Xish stuff",
  }


hash3 =  { 
    :switch=>[{:deep1 => "deepOne"}, {:deep2 => "deepTwo"}, "--xtend"], 
    :parameter__type=>String,
    :parameter__require=>true,
    :description=>"Xish stuff",
  }


hash4 =  { 
    :parameter__type=>String,
    :switch__deep1__deep3 => "deepTwo",
    :parameter__type__ruby=>true,
    :parameter => "glorp",
    :parameter__require=>true,
    :switch__deep2 => "deepTwo",
    :description=>"Xish stuff",
    :switch => "--xtend",
  }


unflat = unflatten(hash4)
puts "\nUnflat: #{unflat}"

=begin
puts "to_a: #{hash2.to_a}"

x = [1,2,3]
y = [3,4,5]

puts "\nx & y = #{x & y}"
=end