class HashModel

  # Processes the raw_data and flattens the records based on the filter (set by filter or a where search)
  def flatten
    # Don't flatten the data if we don't need to
    return self unless dirty?

    id = -1
    group_id = -1
    @modified_data.clear
    # set the flatten index if this is the first time the function is called
    @flatten_index = @raw_data[0].keys[0] if @raw_data != [] && @flatten_index.nil?
    flatten_index = @flatten_index.to_s
    # Change the filter so it looks for variables instead of symbols
    unless @filter_proc.nil?
      proc_filter = @filter_proc.clone
      proc_filter.scan(/(:\S+) ==/).each {|match| proc_filter.sub!(match[0], match[0].sub(":","@"))}
      proc_filter.sub!(":_group_id", "@_group_id")
    end

    # Flatten and filter the raw data
    @raw_data.each do |record|
      new_records, duplicate_data = flatten_hash(record, flatten_index)
      # catch raw data records that don't have the flatten index
      new_records << {@flatten_index.to_sym=>nil} if new_records.empty?
      group_id += 1
      new_records.collect! do |new_record|
        # Double bangs aren't needed but are they more efficient?
        new_record.merge!( duplicate_data.merge!( { :_id=>(id+=1), :_group_id=>group_id } ) )
      end 

      # Add the records to modified data if they pass the filter
      new_records.each do |new_record|
        unless @filter_proc.nil?
          variables_string, remove_string = create_value_string(new_record)
          @modified_data << new_record if eval("#{variables_string}return_value=#{proc_filter};#{remove_string}return_value", @filter_binding)
        else
          @modified_data << new_record
        end
      end

    end # raw_data.each
    set_dirty_hash
    self
  end # flatten

end