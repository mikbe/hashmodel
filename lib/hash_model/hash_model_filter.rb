class HashModel


  # Filter the flattened records based on the value of the
  # default index or by using a boolean logic block:
  # filter("x")
  # filter{:x==4 and :y!="potato"}
  def filter(index_search=:DontSearchForThis_195151c48a254db2949ed102c81ec579, &block_search)
    # Parameter checks
    raise SyntaxError, "You may only provide a parameter or a block but not both" unless index_search==:DontSearchForThis_195151c48a254db2949ed102c81ec579 or block_search.nil?
    return self if @raw_data.empty?

    # Allow clearing the filter and returning the entire recordset if nothing is given
    if index_search == :DontSearchForThis_195151c48a254db2949ed102c81ec579 && block_search.nil?
      @filter_proc = nil
      @filter_binding = nil
      return flatten
    end

    # If given a parameter make our own search based on the flatten index
    unless index_search == :DontSearchForThis_195151c48a254db2949ed102c81ec579
      string_search = "(:#{@flatten_index} == #{index_search.inspect})".to_s # << the to_s makes sure it's evaluated now
      @filter_binding = nil
    else
      # Convert the proc to a string so it can have :'s turned into @'s
      # We only want the internals so we can write the proc the way we want
      string_search = block_search.to_source(:strip_enclosure => true)
      @filter_binding = block_search.binding
    end
    
    # Set and process the filter
    @filter_proc = string_search
    flatten
  end


end