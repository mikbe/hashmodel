# HashModel

A simple MVC type model class for storing deeply nested hashes as records.
It's meant to be used for small, in-memory recordset that you want an easy, flexible way to query.
It is not meant as a data storage device for managing huge datasets.

Note:   
This started out as a programming exercise to learn more about Ruby but is now fairly well featured so can be quite useful.
It is not however a thoroughly tested or industrial strength model and it's not meant to be used to parse your entire user database.
If you're looking for an excellent model class take a look at ActiveModel, it's probably more of what you're looking for.

## Synopsis

The major usefulness of this class is it allows you to filter and search flattened records based on any field.
A field can contain anything, including another hash, a string, an array, or even an Object class like String or Array, not just an instance of an Object class.

Searches are very simple and logical. You can search using just using the value of the default index 

    records = [  
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"},  
      {:switch => ["-y", "--why"],  :description => "lucky what?"},  
      {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},  
    ]  
    hm = HashModel.new(:raw_data=>records)  
    found = hm.where("-x")  => Returns an array of flattened records  


Or more powerfully you can search using boolean like logic e.g.  
   
    hm = HashModel.new(:raw_data=>records)  
    found = hm.where {:switch == "-x" && :parameter__type == String}  => Returns an array of flattened records  


## Status

###**Beta: Probably good to go but needs some more real-world testing**###  

The latest version is still beta but mostly because I didn't realize little time it would take to get the changes I wanted done in version 0.3.0 and I didn't want to release 0.2.0 and 0.3.0 within a day of each other.  

I expect the design to stay pretty stable from this point forward so no more surprising changes in the design or its use.

## Usage

These are just a few of the major methods of the class, to see all the functionality take a look at the RSpec files.

### **Creating with an array of hashes**  
    records = [  
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"},  
      {:switch => ["-y", "--why"],  :description => "lucky what?"},  
      {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},  
    ]  
    hash_model = HashModel.new(:raw_data=>records)  

    puts hash_model  
    >> {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}  
    >> {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0}  
    >> {:switch=>"-y", :description=>"lucky what?", :_id=>2, :_group_id=>1}  
    >> {:switch=>"--why", :description=>"lucky what?", :_id=>3, :_group_id=>1}  
    >> {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>4, :_group_id=>2}  

### **Group ID's and Record ID's**
    # You may have noticed that there are two fields you didn't add in the flattened records. These are the :_id field and the :_group_id fields.
    # :_id is a unique ID for the flattened record while :_group_id is unique to the raw record you used to create the HashModel record.

### **Adding hashes after creation : <<, +, add, concat, push**  
    hash_model = HashModel.new  
    hash_model += records[0]
    hash_model.concat records[1]
    hash_model.push records[2]
  
  
### **Adding another hash model**  
    # You can also add another HashModel object to the existing one
    # and it will add the raw records and reflatten.
    records = [  
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"},  
      {:switch => ["-y", "--why"],  :description => "lucky what?"}
    ]

    records2 = {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"}

    hash_model = HashModel.new(:raw_data => records)
    hash_model2 = HashModel.new(:raw_data => records2)

    hash_model << hash_model2
    # or
    hash_model += hash_model2
  
    
### **Accessing the raw data : raw\_data**  
    # You can always edit and access the raw data via the raw_data property accessor
    # When you make changes to the raw_data the HashModel will automatically be updated.
    records = [  
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"},  
      {:switch => ["-y", "--why"],  :description => "lucky what?"},  
      {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},  
    ]  
    hm = HashModel.new(:raw_data=>records) 
    
    puts hm.raw_data
    >> {:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"}  
    >> {:switch => ["-y", "--why"],  :description => "lucky what?"}  
    >> {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"}  
  	
  
### **Iterating over the HashModel : each**
    # the HashModel acts a lot like an array so you can iterate over it
    hash_model = HashModel.new(:raw_data=>records)  
    hash_model.each do |record|
      # record is a hash
    end
  
  
### **Flattening records : flatten_index**
    # Flatten index is automatically set to the first field ever given
    # but you can change it
    hash_model = HashModel.new(:raw_data=>records)  
		
    puts hash_model.flatten_index
    >> :switch
    
    # you can use flattened field names
    hash_model.flatten_index = :parameter__type

    puts hash_model.flatten_index
    >> :parameter__type

    puts hash_model
    >> {:parameter__type=>String, :switch=>["-x", "--xtended"], :parameter__require=>true, :description=>"Xish stuff", :_id=>0, :_group_id=>0}
    >> {:parameter__type=>nil, :switch=>["-y", "--why"], :description=>"lucky what?", :_id=>1, :_group_id=>1}
    >> {:parameter__type=>String, :switch=>"-z", :description=>"zee svitch zu moost calz", :_id=>2, :_group_id=>2}

    # Notice that records that don't have the flatten index field have that field added and the value is set to nil		
		

### **Searching Records : where**
    # This is where the real power of the library is. You can do complex boolean searches using flattened field names.
    
    # You can search using just a value and it will search based on the flatten_index
    records = [
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
      {:switch => ["-y", "--why"],  :description => "lucky what?", :something => 7},
      {:switch => "-z",  :parameter => {:type => String, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
    ]
    hm = HashModel.new(:raw_data=>records)
    where = hm.where("-x")

    puts where
    >> {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}
    
    # Best of all you can use complex boolean searches using normal and flattend field names.
    # Note that flattened field names are seperated with double under lines __
    hm = HashModel.new(:raw_data=>records)
    where = hm.where {:something == 7 || (:parameter__type == String && :parameter__required == true)}

    puts where
    >> {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}
    >> {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}
    >> {:switch=>"-z", :parameter=>{:type=>String, :required=>true}, :description=>"zee svitch zu moost calz", :something=>4, :_id=>4, :_group_id=>2}

    # You can even search using hash values
    hm = HashModel.new(:raw_data=>records)
    where = hm.where {:parameter == {:type => String, :required => true}}
    
    puts where
    
    >> {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}, 
    >> {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}


### **Finding Sibling Records : group**
    # Since the HashModel class flattens records it is sometimes useful to know what records were created from the same raw data record.
    # This works exactly like a where search so you can send just a value or send a block and get all of the sibling records for your search criteria.
    records = [
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
      {:switch => ["-y", "--why"],  :description => "lucky what?", :something => 7},
      {:switch => "-z",  :parameter => {:type => Integer, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
    ]
    hm = HashModel.new(:raw_data=>records)
    group = hm.group {(:parameter__type == String && :parameter__required == true && :something == 4) || :something == 7}
    
    puts group
    >> {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}
    >> {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}
    >> {:switch=>"-y", :description=>"lucky what?", :something=>7, :_id=>2, :_group_id=>1}
    >> {:switch=>"--why", :description=>"lucky what?", :something=>7, :_id=>3, :_group_id=>1}


### **Unflattening records : unflatten**
    # Anywhere you can add a raw record you can add a flat record
    hm = HashModel.new
    hm << {:switch=>"-x", :parameter__type=>String, :parameter__require=>true, :description=>"Xish stuff"}
    
    puts hm.raw_data
    >> {:switch => "-x", :parameter => {:type => String, :require => true}, :description => "Xish stuff"}
    
    # You can also call the unflatten method yourself on an instance or the class itself and send it a record. (It won't mess with the existing data.)
    deep_hash =  { 
      :parameter__type=>String,
      :switch__deep1__deep3 => "deepTwo",
      :parameter__type__ruby=>true,
      :parameter => "glorp",
      :parameter__require=>true,
      :switch__deep2 => "deepTwo",
      :description=>"Xish stuff",
      :switch => "--xtend",
    }
    unflat = HashModel.unflatten(deep_hash) 
  
    puts unflat
    >> {:parameter=>[{:type=>String}, "glorp", {:require=>true}], :switch=>[{:deep1=>{:deep3=>"deepTwo"}}, {:deep2=>"deepTwo"}, "--xtend"], :description=>"Xish stuff"}
  

## Version History

0.3.0.beta1 - 2011.01.09  

* Changed HashModel\#where searches to use symbols instead of @variables.  
e.g. hm.where{:x == "x" && :y == "y"} instead of the less natural hm.where{@x == "x" && @y == "y"}  
* Converted the HashModel filter from a proc to a string so it can be viewed and allows the above behavior.  
* Removed Jeweler and converted to Bundler gem building.
* Added usage instructions.  
* To do: Refactor some ugly code, more usage examples?

0.2.0 - 2011.01.08  

* Fixed bug if first field name is shorter version of another field name, e.g. :short then :shorter would cause an error.  
* Added unflattening records and adding unflattened records.  
* Changed field separator to double underscores (to allow unflattening)  
* Removed namespace module, it was annoying. Now just instantiate it with HashModel.new instead of MikBe::HashModel.new  
* Now allows a single hash, instead of an array of hashes, when creating with HashModel.new(:raw_data => hash)  

0.1.1 - 2010.12.15   

* Moved to proper RubyGems account  

0.1.0 - 2010.12.15  

* Initial publish  
* Released on wrong RubyGems account (yanked)


##Contributing to HashModel

* Pull requests are handled ASAP.
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project  
* Start a feature/bugfix branch  
* Commit and push until you are happy with your contribution  
* Make sure to add RSpecs in a separate file so I can easily tell what changed (changes without specs will not be pulled) for it.
* Changes to the configuration files, version numbers, or branches will not be pulled. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

##Copyright

Copyright (c) 2010 Mike Bethany. See LICENSE.txt for further details.

