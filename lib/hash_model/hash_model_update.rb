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

    changed_records = recursive_update_root(update_hash)

    @filter_proc = old_filter
    flatten
 
    changed_records
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
    
    # filter the records by the search criteria
    old_filter = @filter_proc
    filter(index_search, &block_search)

    changed_records = recursive_update_root(update_hash, true)

    # reset the filter
    @filter_proc = old_filter
    flatten
 
    changed_records
  end

  private 
  
  # Loops through the filtered recordset and sends each record off to be recursivly changed
  def recursive_update_root(update_hash, add=false)
    changed_records = []
    each do |record|
      # puts
      # puts record
      changed = [false]
      update_hash.each do |key,value|
        unflat = unflatten(key=>value)
        recursive_update_worker(@raw_data[record[:_group_id]], unflat, key, nil,  add, changed)
      end
      # puts "Changed: #{changed}"
      changed_records << record if changed[0]
    end
    #puts "changed: #{changed_records}"
    changed_records
  end

  # also look for hashes with multiple values - no we only allow single field changes they have to give a flattened field or it wipes everything

  # {:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a =>"b2a", :b2b=>"b2b"}}}
  # {:a=>"17", :b=>"1870"}
  def recursive_update_worker(target_hash, source_hash, terminal_key, parent_key, add, changed)
    # puts
    # puts "target_hash: #{target_hash}"
    # puts "source_hash: #{source_hash}"
    source_hash.each do |source_hash_key, source_hash_value|
      current_key = "#{parent_key}#{"__" if parent_key}#{source_hash_key}".to_sym 
      # puts "source_hash_key: #{source_hash_key}"
      # puts "current_key: #{current_key}"
      if current_key == terminal_key
        # puts "You've reached your destination"
        return unless target_hash[source_hash_key] or add
        target_hash[source_hash_key] = source_hash_value
        changed[0] = true
      else
        if target_hash.is_a? Hash
          recursive_update_worker(target_hash[source_hash_key], source_hash[source_hash_key], terminal_key, current_key, add, changed)
        else
          if add
            target_hash = source_hash
            changed[0] = true
          end
        end
      end
    end
  end

end
