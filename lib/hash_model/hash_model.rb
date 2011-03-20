require 'sourcify'
require 'hash_model/hash_model_delete'
require 'hash_model/hash_model_group'
require 'hash_model/hash_model_filter'
require 'hash_model/hash_model_update'
require 'hash_model/hash_model_where'


# A simple MVC type model class for storing hashes as flattenable, searchable records
class HashModel
  include Enumerable
   
  def initialize(parameters={})
    # Initialize variables
    clear

    # Map Array methods
    mimic_methods
    
    # Set values given as hashes
    parameters.each { |key,value| 
      instance_variable_set("@#{key}", smart_clone(value)) }

    # Allow a single hash to be added with :raw_data
    @raw_data = [@raw_data] if @raw_data.class == Hash

    check_field_names(@raw_data) unless @raw_data.empty?
    
    # Setup the flat data
    flatten
    
  end

  ## Properties

  attr_accessor :flatten_index, :raw_data, :filter_proc
  
  # Sets field name used to flatten the recordset
  def flatten_index=(value)
    old_flatten = @flatten_index
    old_filter = @filter_proc
    @flatten_index = value
    @filter_proc = nil
    flatten
    
    # Verify the flatten index is a valid index
    flatten_found = false
    @modified_data.each do |record|
      break (flatten_found = true) if record[value]
    end
  
    unless flatten_found
      @flatten_index = old_flatten
      @filter_proc = old_filter
      flatten 
      raise ArgumentError, "Flatten index could not be created: #{value}"
    end
    self
  end

  # Are the records being filtered?
  def filtered?
    !!@filter_proc
  end

  # Trap changes to raw data so we can re-flatten the data
  def raw_data=(value)
    value = [] if value.nil?
    raise SyntaxError, "Raw data may only be an array of hashes" if value.class != Array
    check_field_names(value)
    @raw_data = smart_clone(value)
    flatten
  end

  ## Public Methods 

  # Freeze all the data properties
  def freeze
    instance_variables.each do |var|
      instance_eval("#{var}.freeze")
    end
    super
  end
  
  # Remove the in-place where filter
  def clear_filter
    @filter_proc = nil
    flatten
  end
  alias :clear_where :clear_filter # in case this makes more sense to people
  
  # Reset the HashModel
  def clear
    @raw_data = []
    @modified_data = []
    @unflatten_data  = []
    @flatten_index = nil
    @filter_proc = nil
  end

  # Force internal arrays and variables to be cloned
  def clone
    return self if @raw_data.empty?
    flatten
    hm = HashModel.new(:raw_data=>@raw_data.clone)
    hm.flatten_index = @flatten_index
    hm.filter_proc = @filter_proc
    hm
  end

  ## Operators
  
  # Overload Array#<< function so we can create the flatten index as the first record is added.
  # This also allows us to send back this instance of the HashModel instead of an array.
  def <<(value)
    value = smart_clone(value)
    case value
      when HashModel
        @raw_data.concat(value.raw_data)
      when Hash
        # unflatten if needed
        value = unflatten(value) unless value.to_s.match("__").nil? 
        check_field_names(value)
        @raw_data << value
      when Array
        value.each{ |member| self << member }
      else
        raise SyntaxError, "You may only add a hash, another HashModel, or an array of either"
    end
    flatten
  end
  # I like the method name "add" for adding to recordsets seems more natural
  alias :add :<<
  alias :concat :<<
  alias :push :<<
  
  # remap... no loops... you know the deal
  alias :_equals_ :==
  
  # Compare values with the HashModel based on the type of values given
  def ==(value)
    flatten
    case value
      when HashModel
        @raw_data       == value.raw_data &&
        @flatten_index  == value.flatten_index &&
        @modified_data  == value
      when Array
        # test for something other than hashes, a flattened recordset, or raw data
        if value.empty? || (value[0].class == Hash && value[0].has_key?(:_group_id))
          @modified_data == value
        else
          @raw_data == value
        end
      else
        false
    end
  end
  alias :eql? :==

  # Remap spaceship to stop infinite loops
  alias :_spaceship_ :<=>
  private :_spaceship_
  
  # Spaceship - Don't probe me bro'!
  def <=>(value)
    case value
      when HashModel
        _spaceship_(value)
      when Array
        # test for a flattened recordset or raw data
        if !value.empty? && value[0].has_key?(:_group_id)
          @modified_data <=> value
        else
          @raw_data <=> value
        end
      else
        nil
    end
  end

  ## Searching 

  # Tests flat or raw data depending of if you use flat or raw data
  def include?(value)
    return false if value.class != Hash
    @modified_data.include?(value) || @raw_data.include?(value)
  end

  # Find the raw data record based on the search criteria
  def parents(index_search=nil, &block_search)
    flat_records = where(index_search, &block_search)
    flat_records.collect{|flat| @raw_data[flat[:_group_id]]}.uniq
  end

  # Set the array value for self to the flattened hashes based on the flatten_index
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
      proc_filter = "proc { #{proc_filter} }.call"
    end
    #dp "newfilter: #{proc_filter}"


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
        #dp "rec: #{new_record}"
        unless @filter_proc.nil?
          flat = create_object_from_flat_hash(new_record)
          @modified_data << new_record if flat.instance_eval proc_filter
        else
          @modified_data << new_record
        end
      end

    end # raw_data.each
    set_dirty_hash
    self
  end # flatten
  
  # If the hash_model has been changed but not flattened
  def dirty?
    get_current_dirty_hash != @dirty_hash
  end

  # Return a string consisting of the flattened data
  def to_s
    flatten
    @modified_data.to_s
  end

  # Return an array of the flattened data
  def to_ary
    flatten
    @modified_data.clone.to_ary
  end
  
  # Outputs the flattened data
  def to_a
    flatten
    @modified_data.clone.to_a
  end
  
  # Iterate over the flattened records
  def each
    @modified_data.each  do |record| 
       yield record
    end
  end
  
  # Convert a flat record into an unflattened record
  def unflatten(flat_record)
    HashModel.unflatten(flat_record)
  end

  # Convert a flat record into an unflattened record
  def self.unflatten(flat_record)
    # Seriously in need of a refactor, just looking at this hurts my brain
    # There's a lot of redundancy here.
    case flat_record
      when Hash
        new_record = {}
        flat_record.each do |key, value|
          # recursively look for flattened keys
          keys = key.to_s.split("__", 2)
          if keys[1]
            key = keys[0].to_sym
            value = unflatten({keys[1].to_sym => value})
          end
          # Don't overwrite existing value
          if (existing = new_record[key])
            # convert to array and search for subkeys if appropriate
            if existing.class == Hash
              # Convert to an array if something other than a hash is added
              unless value.class == Hash
                new_record[key] = hash_to_array(existing)
                new_record[key] << value
              else
                # Search subkeys for duplicate values if it's a hash
                unless (found_keys = existing.keys & value.keys).empty?
                  found_keys.each do |found_key|
                    # How can I remove this redundancy?
                    if new_record[key][found_key].class == Hash
                      unless value[found_key].class == Hash
                        new_record[key] = hash_to_array(new_record[key][found_key])
                        new_record[key] << value[found_key]
                      else
                        new_record[key][found_key].merge!(value[found_key])
                      end
                    end
                  end
                else
                  new_record[key].merge!(value)
                end
              end
            else
              new_record[key] << value
            end
          else
            new_record.merge!(key => value)
          end
        end
        new_record
      when Array
        # recurse into array
        flat_record.collect! {|item| unflatten(item) }
      else
        flat_record
    end
  end

  protected
  
  # Allows access to the internal filter, needed to make sure clones filter properly
  def filter_proc=(filter)
    @filter_proc = filter
    flatten
  end
  
  private

  # If the object is serialized it loses the dynamically mapped methods
  # This will catch that and try to remap them.
  def method_missing(symbol , *args)
    mimic_methods
    return send(symbol, *args) if respond_to?(symbol)
    super(symbol, args)
  end

  # Convert a hash of multiple key/value pairs to an array of single hashes.
  # {:field1 => "value1", :field2 => "value2"}
  # becomes
  # [{:field1 => "value1"}, {:field2 => "value2"}]
  def self.hash_to_array(hash)
    array = []
    hash.each do |key, value|
      array << {key => value}
    end
    array
  end

  # Convert a hash of multiple key/value pairs to an array of single hashes.
  # {:field1 => "value1", :field2 => "value2"}
  # becomes
  # [{:field1 => "value1"}, {:field2 => "value2"}]
  def hash_to_array(hash)
    HashModel.hash_to_array(hash)
  end

  # Checks hash keys for reserved field names
  def check_field_names(argument_list)
    case argument_list
      when Hash
        argument_list.each do |key, value|
          raise ReservedNameError, "use of reserved name :#{key} as a field name." if [:_id, :_group_id].include?(key)
          check_field_names(value)
        end  
      when Array
        argument_list.clone.each { |record| check_field_names(record) }
    end
  end

  # Save a hash for later evaluation
  def set_dirty_hash
    @dirty_hash = get_current_dirty_hash
  end
  
  # Create a hash based on internal values
  def get_current_dirty_hash
    # self.hash won't work
    [@raw_data.hash, @filter_proc.hash, @flatten_index.hash].hash
  end
  
  # Recursively convert a single record into an array of new 
  # records that are flattened based on the given flattened hash key
  # e.g. {:x=>{:x1=>1}, :y=>{:y1=>{:y2=>2,:y3=>4}, y4:=>5}, :z=>6}
  # if you wanted to flatten to :x1 you would set flatten_index to :x_x1
  # To flatten to :y2 you would set flatten_index to :y_y1_y2
  def flatten_hash(input, flatten_index, recordset=[], duplicate_data={}, parent_key=nil)
    case input
      when Hash
        # Check to see if the found key is on this level - We need to add duplicate data differently if so
        found_key = (input.select { |key, value| flatten_index == "#{parent_key}#{"__" if !parent_key.nil?}#{key}"} != {})
        
        # Add records for matching flatten fields and save duplicate record data for later addition to each record.
        input.each do |key, value|
          #puts "\nkey: #{key}; value: #{value}"
          flat_key = "#{parent_key}#{"__" if !parent_key.nil?}#{key}"

          #puts "flat_key: #{flat_key}"
          #puts "flat_index: #{flatten_index}"

          flat_key_starts_with_flatten_index = flat_key.start_with?("#{flatten_index}__") 
          flatten_index_starts_with_flat_key = flatten_index.start_with?(flat_key)
          
          #puts "flat_key_starts_with_flatten_index: #{flat_key_starts_with_flatten_index}"
          #puts "flatten_index_starts_with_flat_key: #{flatten_index_starts_with_flat_key}"
          
          # figure out what we need to do based on where we're at in the record's value tree and man does it look ugly
          if flat_key == flatten_index
            # go deeper
            recordset, duplicate_data = flatten_hash(value, flatten_index, recordset, duplicate_data, flat_key)
          elsif flat_key_starts_with_flatten_index && !flatten_index_starts_with_flat_key
            # new record
            recordset << {parent_key.to_sym=>{key=>value}}
          elsif !flat_key_starts_with_flatten_index && flatten_index_starts_with_flat_key
            # go deeper
            recordset, duplicate_data = flatten_hash(value, flatten_index, recordset, duplicate_data, flat_key)
          elsif found_key
            # add to dup data for same level as flatten index
            duplicate_data.merge!(flat_key.to_sym=>value)
          else
            # add to dupe data
            duplicate_data.merge!(key=>value)
          end            
        end # input.each
      when Array
        input.each do |value|
         case value
            when Hash
              recordset, duplicate_data = flatten_hash(value, flatten_index, recordset, duplicate_data, parent_key)
            else
              recordset << {parent_key.to_sym=>value}
          end
        end
      else
        recordset << {parent_key.to_sym=>input}
    end # case
     return recordset, duplicate_data
  end # flatten_hash

  # Creates an object with instance variables for each field at every level
  # This allows using a block like {:field1==true && :field2_subfield21="potato"}
  def create_object_from_flat_hash(record, hash_record=Class.new.new, parent_key=nil)
  
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

  # Deal with the array methods allowing multiple functions to use the same code
  # You couldn't do this with alias because you can't tell what alias is used.
  #
  # My rule for using this vs a seperate method is if I can use the
  # same code for more than one method it goes in here, if the method
  # only works for one method then it gets its own method.
  def wrapper_method(method, *args, &block)
    # grab the raw data if it's a hashmodel
    case method
      when :[], :each_index, :uniq, :last, :collect, :length, :at, :map, :combination, :count, :cycle, :empty?, :fetch, :index, :first, :permutation, :size, :values_at
        flatten
        @modified_data.send(method, *args, &block)
      when :+, :*
        case args[0]
          when HashModel
            args = [args[0].raw_data]
          when Hash
            args = [args]
        end
        clone = self.clone
        clone.raw_data = clone.raw_data.send(method, *args, &block)
        clone.flatten
      else
        raise NoMethodError, "undefined method `#{method}' for #{self}"
    end
  end

  # create methods like the given object so we can trap them
  def mimic_methods
    Array.new.public_methods(false).each do |method|
      # Don't mimic methods we specifically declare or methods that don't make sense for the class
      if !self.respond_to?(method)
        self.class.class_eval do
          define_method(method) { |*args, &block| wrapper_method(method, *args, &block) }
        end
      end
    end
  end

  # It's annoying to raise an error if an object can't
  # be cloned, like in the case of symbols, It is much
  # more friendly, and less surprising too, just to
  # return the same object so you can go about your work.
  # The only reason I clone is to protect the values, if
  # the values don't need to be protected I don't want an
  # annoying error message hosing up my whole day. </rant>
  def smart_clone(object)
    # Stupid error trapping
    begin
      object.clone
    rescue
      object
    end
  end

end # HashModel
