class HashModel

  # Returns a copy of the HashModel that matches the search criteria
  # updated using the update_hash. This affects the raw_data.
  def update(index_search=nil, update_hash, &block_search)
    self.clone.update!(index_search, update_hash, &block_search)
  end
  
  # Destructively updates the raw data for the records that match the
  # search criteria. This affects the raw_data so if more than one record
  # is based on the raw_data that's changed that record will be changed too.
  # Returns the records that were updated.
  def update!(index_search=nil, update_hash, &block_search)
    
    old_filter = @filter_proc
    filter(index_search, &block_search)

    recursive_update_root(update_hash)

    @filter_proc = old_filter
    flatten
  end


  # Updates existing hashes with a given value and also
  # adds the full root to the key if it doesn't already exist.
  # Returns a new instance of the original HashModel
  def update_and_add(index_search=nil, update_hash, &block_search)
    self.clone.update_and_add!(index_search, update_hash, &block_search)
  end
  
  # Updates existing hashes with a given value and also
  # adds the full root to the key if it doesn't already exist.
  # Destructively updated the existing HashModel
  def update_and_add!(index_search=nil, update_hash, &block_search)
    
    old_filter = @filter_proc
    filter(index_search, &block_search)

    recursive_update_root(update_hash, true)

    @filter_proc = old_filter
    flatten 
    
  end

  private 
  
  # Loops through the filtered recordset and sends each record off to be recursivly changed
  def recursive_update_root(update_hash, add=false)
    each do |record|
      update_hash.each do |key,value|
        unflat = unflatten(key=>value)
        recursive_update_worker(@raw_data[record[:_group_id]], unflat, key, nil,  add)
      end
    end
  end

  def recursive_update_worker(target_hash, new_value_hash, terminal_key, parent_key, add)
    new_value_hash.each { |key,value|
      current_key = "#{parent_key}#{"__" if parent_key}#{key}".to_sym 
      if value.is_a? Hash and target_hash[key].is_a? Hash and current_key != terminal_key
        target_hash.merge(key=>{}) if add and !target_hash[key] # allows deep recursion of fields that don't yet exist
        recursive_update_worker(target_hash[key], value, terminal_key, current_key, add) if target_hash[key]
      else
        target_hash[key] = value if target_hash[key] || add
      end
    }
  end


end
