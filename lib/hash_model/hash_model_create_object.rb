class HashModel
  
  # Creates an object with instance variables for each field at every level
  # This allows using a block like {:field1==true && :field2_subfield21="potato"}
  def create_object_from_flat_hash_old(record, hash_record=Class.new.new, parent_key=nil)
  
    # Iterate through the record creating the object recursively
    case record
      when Hash
        record.each do |key, value|
          flat_key = "#{parent_key}#{"__" if !parent_key.nil?}#{key}"
          hash_record.instance_variable_set("@#{flat_key}", value)
          hash_record = create_object_from_flat_hash(value, hash_record, flat_key)
        end
      when Array
        hash_record.instance_variable_set("@#{parent_key}", record)
        record.each do |value|
          hash_record = create_object_from_flat_hash(value, hash_record, parent_key) if value.class == Hash
        end
      else
        hash_record.instance_variable_set("@#{parent_key}", record)
    end # case
    hash_record
  end # create_object_from_flat_hash
  
  def create_value_string(record)
    variables_string = ""
    remove_string = ""
    variables_array, remove_array = create_wide_values(record)
    variables_array.each{|record|variables_string+="@#{record};"}
    remove_array.each{|record|remove_string+="remove_instance_variable(:@#{record});"}
    [variables_string,remove_string]
  end
  
  # Creates an object with instance variables for each field at every level
  # This allows using a block like {:field1==true && :field2_subfield21="potato"}
  def create_wide_values(record, variable_array=[], remove_array=[], parent_key=nil)
    # Iterate through the record creating the object recursively
    case record
      when Hash
        record.each do |key, value|
          flat_key = "#{parent_key}#{"__" if !parent_key.nil?}#{key}"
          if value
            variable_array << "#{flat_key}=#{value.inspect}"
            remove_array << "#{flat_key}"
          end
          variable_array, remove_array = create_wide_values(value, variable_array, remove_array, flat_key)
        end
      when Array
        variable_array << "#{parent_key}=#{record.inspect}"
        remove_array << "#{parent_key}"
        record.each do |value|
          variable_array, remove_array = create_wide_values(value, variable_array, remove_array, parent_key) if value.class == Hash
        end
      else
        variable_array << "#{parent_key}=#{record.inspect}"
        remove_array << "#{parent_key}"
    end # case
    [variable_array.uniq, remove_array.uniq]
  end 

end