class HashModel
  
  # Return the other records created from the same raw data record as the one(s) searched for
  def group(index_search=nil, &block_search)
    group_hm = self.clone
    # Filter the recordset if applicable
    if !index_search.nil? || !block_search.nil?
      group_hm.filter(index_search, &block_search)
    end
    # Get all the unique group id's
    group_ids = group_hm.collect {|hash| hash[:_group_id]}.uniq
    # reset the filter
    group_hm.filter
    group_hm.filter_proc = "#{group_ids.to_s}.include? :_group_id"
    group_hm.flatten
  end
  
end