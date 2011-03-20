class HashModel

  # Filter the flattened records based on the value of the
  # default index or by using a boolean logic block:
  # filter("x")
  # filter{:x==4 and :y!="potato"}
  def filter(index_search=nil, &block_search)
    # Parameter checks
    raise SyntaxError, "You may only provide a parameter or a block but not both" if index_search && !block_search.nil?
    return self if @raw_data.empty?

    # Allow clearing the filter and returning the entire recordset if nothing is given
    if !index_search && block_search.nil?
      @filter_proc = nil
      return flatten
    end

    # If given a parameter make our own search based on the flatten index
    unless index_search.nil?
      # Make sure the field name is available to the proc
      case index_search
        when String
          string_search = ":#{@flatten_index} == \"#{index_search}\"".to_s
        when Symbol
          string_search = ":#{@flatten_index} == :#{index_search}".to_s
        else
          string_search = ":#{@flatten_index} == #{index_search}".to_s
      end
    else
      # Convert the proc to a string so it can have :'s turned into @'s
      
      # Sourcify can create single or multi-line procs so we have to make sure we deal with them accordingly
      source = block_search.to_source
      unless (match = source.match(/^proc do\n(.*)\nend$/))
        match = source.match(/^proc { (.*) }$/)
      end
      string_search = match[1]
    end # !index_search.nil?
    
    # Set and process the filter
    @filter_proc = string_search
    flatten
  end

end