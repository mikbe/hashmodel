class HashModel

  # Returns a copy of the HashModel that matches the search criteria
  # updated using the update_hash. This affects the raw_data.
  def update(index_search=:DontSearchForThis_195151c48a254db2949ed102c81ec579, update_hash, &block_search)
    self.clone.update!(index_search, update_hash, &block_search)
  end
  
  # Destructively updates the raw data for the records that match the
  # search criteria. Since this affects the raw_data so if more than one record
  # is based on the raw_data that's changed that record will be changed too.
  # Returns the records that were updated.
  def update!(index_search=:DontSearchForThis_195151c48a254db2949ed102c81ec579, update_hash, &block_search)
    
    # only filter if they sent something to be filter otherwise leave the filter alone
    unless index_search == :DontSearchForThis_195151c48a254db2949ed102c81ec579 && block_search.nil?
      old_filter = @filter_proc
      old_binding = @filter_binding
      filter(index_search, &block_search)
    end

    changed = recursive_update_root(update_hash)

    if old_filter
      @filter_proc = old_filter
      @filter_binding = old_binding
      flatten
    end
    
    changed
  end

  # Updates existing hashes with a given value and also
  # adds the full root to the key if it doesn't already exist.
  # Returns a new instance of the original HashModel
  def update_and_add(index_search=:DontSearchForThis_195151c48a254db2949ed102c81ec579, update_hash, &block_search)
    self.clone.update_and_add!(index_search, update_hash, &block_search)
  end
  
  # Updates existing hashes with a given value and also
  # adds the full root to the key if it doesn't already exist.
  # Destructively updated the existing HashModel
  def update_and_add!(index_search=:DontSearchForThis_195151c48a254db2949ed102c81ec579, update_hash, &block_search)
    
    # only filter if they sent something to be filter otherwise leave the filter alone
    unless index_search == :DontSearchForThis_195151c48a254db2949ed102c81ec579 && block_search.nil?
      old_filter = @filter_proc
      old_binding = @filter_binding
      filter(index_search, &block_search)
    end

    changed = recursive_update_root(update_hash, true)

    if old_filter
      @filter_proc = old_filter
      @filter_binding = old_binding
      flatten
    end
    
    changed
  end

  protected 
  
  # Loops through the filtered recordset and sends each record off to be recursivly changed
  def recursive_update_root(update_hash, add=false)
    changed_record_ids = []
    each do |record|
      save_change = []
      update_hash.each do |key,value|
        unflat = unflatten(key=>value)
        recursive_update_worker(@raw_data[record[:_group_id]], unflat, key, nil,  add, record[:_id], save_change)
      end
      changed_record_ids << save_change.uniq[0] unless save_change.empty?
    end
    # clear the filter so we can get changed records if the filter is 
    # the field that changed (also causes records to update)
    # This looks ripe for a refactor
    if @filter_proc
      old_filter = @filter_proc
      old_binding = @filter_binding
      @filter_proc = nil
      @filter_binding = nil
    end
    # now that we've changed the raw data update the values in the flattened records
    filter
    # Grab the changed records
    changed = @modified_data.select{|record| changed_record_ids.include?(record[:_id])}
    if old_filter
      @filter_proc = old_filter
      @filter_binding = old_binding
      flatten
    end
    changed
  end

  # Loops through the hash that represents the changes to make and recurses into as needed
  def recursive_update_worker(target_hash, source_hash, terminal_key, parent_key, add, record_id, save_change)
    source_hash.each do |source_hash_key, source_hash_value|
      current_key = "#{parent_key}#{"__" if parent_key}#{source_hash_key}".to_sym 
      if current_key == terminal_key
        return unless target_hash[source_hash_key] or add
        target_hash[source_hash_key] = source_hash_value
        save_change << record_id
      else
        if target_hash.is_a? Hash
          recursive_update_worker(target_hash[source_hash_key], source_hash[source_hash_key], terminal_key, current_key, add, record_id, save_change)
        else
          if add
            target_hash = source_hash
            save_change << record_id
          end
        end
      end
    end
  end

end
