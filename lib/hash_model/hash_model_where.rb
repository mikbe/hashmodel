class HashModel

  # Search creating a new instance of HashModel based on this one
  def where(index_search=nil, &block_search)
    self.clone.where!(index_search, &block_search)
  end

  # Search the flattened records using the default flatten index or a boolean block
  def where!(index_search=nil, &block_search)
    filter(index_search, &block_search)
    
    # Delete the raw records that don't have matches
    good_group_ids = unflatten(@modified_data).collect{|record| record[:_group_id]}.uniq
    index = -1;
    @raw_data.delete_if {|record| !good_group_ids.include?(index+=1)}
    
    # Remove the non-matching values from raw data for the filter_index
    good_values = self.collect{|record| record[@flatten_index]}
    @raw_data.each do |record|
      if record[@flatten_index].is_a? Array
        record[@flatten_index].delete_if{|value| !good_values.include?(value) }
      end
    end
    self
  end

end