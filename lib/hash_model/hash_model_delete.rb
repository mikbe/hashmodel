class HashModel
  
  # Returns a copy of the HashModel with raw data deleted based on the search criteria
  def delete(index_search=nil, &block_search)
    self.clone.delete!(index_search, &block_search)
  end
  
  # Deletes the raw data records based on the search criteria
  def delete!(index_search=nil, &block_search)
    parents(index_search, &block_search).each{|parent| @raw_data.delete(parent)}
  end

end