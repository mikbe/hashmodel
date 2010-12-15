# Pickle Pumpers namespace
module MikBe
  
  # A simple MVC type model class for storing hashes as flattenable, searchable records
  class HashModel
    include Enumerable
     
    def initialize(parameters={})
      # Initialize variables
      clear

      # Map Array methods
      mimic_methods
      
      # Set values given as hashes
      parameters.each { |key,value| instance_variable_set("@#{key}", value) }

      check_field_names(@raw_data) if !@raw_data.empty?
      
      # Setup the flat data
      flatten
      
    end
 
    ## Properties

    attr_accessor :flatten_index, :raw_data

    # Sets field name used to flatten the recordset
    def flatten_index=(value)
      @flatten_index = value
      flatten
    end
  
    # Are the records being filtered?
    def filtered?
      !!@filter
    end

    # Trap changes to raw data so we can re-flatten the data
    def raw_data=(value)
      value = [] if value.nil?
      raise SyntaxError, "Raw data may only be an array of hashes" if value.class != Array
      check_field_names(value)
      @raw_data = value.clone
    end


    ## Public Methods 

    # Freeze the raw data
    def freeze
      @raw_data.freeze
      @modified_data.freeze
      @flatten_index.freeze
      @filter.freeze
      super
    end
    
    # Remove the where filter
    def clear_filter
      @filter = nil
      flatten
    end
    alias :clear_where :clear_filter # in case this makes more sense to people
    
    # Reset the HashModel
    def clear
      @raw_data = []
      @modified_data = []
      @flatten_index = nil
      @filter = nil
    end
 

    ## Operators
    
    # Overload Array#<< function so we can create the flatten index as the first record is added
    # and allows us to send back this instance of the HashModel instead of an array.
    def <<(value)
      case value
        when HashModel
          @raw_data.concat(value.raw_data)
        when Hash
          check_field_names(value)
          @raw_data << value
        when Array
          # It goes crazy if you don't clone the array before recursing
          value.clone.each{ |member| self << member }
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
          if !value.empty? && value[0].class == Hash && value[0].has_key?(:hm_group_id)
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
          if !value.empty? && value[0].has_key?(:hm_group_id)
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

    # Search creating a new instance of HashModel based on this one
    def where(value=nil, &search)
      self.clone.where!(value, &search)
    end

    # Search the flattened records using a 
    def where!(value=nil, &search)
      # Parameter checks
      raise SyntaxError, "You may only provide a parameter or a block but not both" if value && !search.nil?
      
      # Allow clearing the filter and returning the entire recordset if nothing is given
      if !value && search.nil?
        @filter = nil
        return flatten
      end

      # If given a parameter make our own search based on the flatten index
      if !value.nil?
        # Make sure the field name is available to the proc
        flatten_index = @flatten_index 
        search = proc do
          instance_variable_get("@#{flatten_index}") == value
        end # search
      end # !value.nil?
      
      # Set and process the filter
      @filter = search
      flatten
    end

    # Return the other records created from the same raw data record as the one(s) searched for
    def group(value=nil, &search)
      if !value.nil? || !search.nil?
        sibling = where(value, &search)
      else
        sibling = where &@filter
      end
      
      # Get all the unique group id's
      group_ids = sibling.collect {|hash| hash[:hm_group_id]}.uniq
      
      # Find any records with matching group ids
      where {group_ids.include? @hm_group_id}
    end
    
    # Group the records in place based on the existing filter
    # This is basically a short hand for filtering based on
    # group ids of filtered records
    def group!(value=nil, &search)
      
      if !value.nil? || !search.nil?
        where!(value, &search)
      end
      
      # Get all the unique group id's
      group_ids = @modified_data.collect {|hash| hash[:hm_group_id]}.uniq

      # Find any records with matching group ids
      where! {group_ids.include? @hm_group_id}
    end

    # Find the raw data record for a given flat record
    def parent(flat_record)
      flatten
      @raw_data[flat_record[:hm_group_id]]
    end

    # Set the array value for self to the flattened hashes based on the flatten_index
    def flatten
      # Don't flatten the data if we don't need to
      return self if !dirty?
      
      id = -1
      group_id = -1
      @modified_data.clear
      # set the flatten index if this is the first time the function is called
      @flatten_index = @raw_data[0].keys[0] if @raw_data != [] && @flatten_index.nil?
      flatten_index = @flatten_index.to_s

      # Flatten and filter the raw data
      @raw_data.each do |record|
        new_records, duplicate_data = flatten_hash(record, flatten_index)
        # catch raw data records that don't have the flatten index
        new_records << {@flatten_index.to_sym=>nil} if new_records.empty?
        group_id += 1
        new_records.collect! do |new_record|
          # Double bangs aren't needed but are they more efficient?
          new_record.merge!( duplicate_data.merge!( { :hm_id=>(id+=1), :hm_group_id=>group_id } ) )
        end 
        
        # Add the records to modified data if they pass the filter
        new_records.each do |new_record| 
          @modified_data << new_record if @filter.nil? ? true : (create_object_from_flat_hash(new_record).instance_eval &@filter)
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
      @modified_data.to_s
    end

    # Return an array of the flattened data
    def to_ary
      @modified_data.to_ary
    end
    
    # Iterate over the flattened records
    def each
      @modified_data.each  do |record| 
        # change or manipulate the values in your value array inside this block
        yield record
      end
    end
    
    private

    # Checks hash keys for reserved field names
    def check_field_names(input)
      case input
        when Hash
          input.each do |key, value|
            raise ReservedNameError, "use of reserved name :#{key} as a field name." if [:hm_id, :hm_group_id].include?(key)
            check_field_names(value)
          end  
        when Array
          input.clone.each { |record| check_field_names(record) }
      end
    end

    # Save a hash for later evaluation
    def set_dirty_hash
      @dirty_hash = get_current_dirty_hash
    end
    
    # Create a hash based on internal values
    def get_current_dirty_hash
      # self.hash won't work
      [@raw_data.hash, @filter.hash, @flatten_index.hash].hash
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
          found_key = (input.select { |key, value| flatten_index == "#{parent_key}#{"_" if !parent_key.nil?}#{key}"} != {})
          
          # Add records for matching flatten fields and save duplicate record data for later addition to each record.
          input.each do |key, value|
            flat_key = "#{parent_key}#{"_" if !parent_key.nil?}#{key}"
            flat_key_starts_with_flatten_index = flat_key.start_with?(flatten_index) 
            flatten_index_starts_with_flat_key = flatten_index.start_with?(flat_key)
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
            recordset, duplicate_data = flatten_hash(value, flatten_index, recordset, duplicate_data, parent_key)
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
            flat_key = "#{parent_key}#{"_" if !parent_key.nil?}#{key}"
            hash_record.instance_variable_set("@#{flat_key}", value)
            hash_record = create_object_from_flat_hash(value, hash_record, flat_key)
          end
        when Array
          record.each do |value|
            hash_record = create_object_from_flat_hash(value, hash_record, parent_key)
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

  end # HashModel
  
end # MikBe
