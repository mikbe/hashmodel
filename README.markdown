# HashModel

A simple MVC type model class for storing deeply nested hashes as records.
It's meant to be used for small, in-memory recordset that you want an easy, flexible way to query.
It is not meant as a data storage device for managing huge datasets.

## Synopsis

The major usefulness of this class is it allows you to filter and search flattened records based on any field.
A field can contain anything, including another hash, a string, an array, or even an Object class like String or Array, not just an instance of an Object class.

Searches are very simple and logical. You can search using just using the value of the default index 

    require 'hashmodel'
    records = [  
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"},  
      {:switch => ["-y", "--why"],  :description => "lucky what?"},  
      {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},  
    ]  
    hash_model = HashModel.new(:raw_data=>records)  
    found = hash_model.where("-x")  => Returns an array of flattened records  


Or more powerfully you can search using boolean like logic e.g.  
   
    hash_model = HashModel.new(:raw_data=>records)  
    found = hash_model.where {:switch == "-x" && :parameter__type == String}  => Returns an array of flattened records  


## Status

2011.03.18 - Production: 0.3.2

## Developer Notes

If you have problems running Autotest on your RSpecs try including the gem file-tail in your app. You **shouldn't** have to since I include it here but I had problems with Autotest and Sourcify and adding that fixed it.

## Usage

I've covered most of the major stuff here but to see all of the functionality take a look at the RSpec files.

### **Creating with an array of hashes**  
    require 'hashmodel'
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
    # You may have noticed that there are two fields you didn't add in the 
    # flattened records. These are the :_id field and the :_group_id fields.
    # :_id is a unique ID for the flattened record while :_group_id is 
    # unique to the raw record you used to create the HashModel record.


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
    hash_model = HashModel.new(:raw_data=>records) 
    
    puts hash_model.raw_data
    >> {:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"}  
    >> {:switch => ["-y", "--why"],  :description => "lucky what?"}  
    >> {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"}  
  	
  
### **Iterating over the HashModel : each**
    # the HashModel acts a lot like an array so you can iterate over it
    hash_model = HashModel.new(:raw_data=>records)  
    hash_model.each do |record|
      # record is a hash
    end

### **Direct access to flattened records : []**
    # the HashModel acts a lot like an array so you can iterate over it
    hash_model = HashModel.new(:raw_data=>records)  

    puts hash_model[0]
    >> {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}

  
### **Flattening records : flatten_index**
    # Flatten index is automatically set to the first field ever given
    # but you can change it to any field you want.
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
    # You can search using just a value and it will search based on the flatten_index
    records = [
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
      {:switch => ["-y", "--why"],  :description => "lucky what?", :something => 7},
      {:switch => "-z",  :parameter => {:type => String, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
    ]
    hash_model = HashModel.new(:raw_data=>records)
    where = hash_model.where("-x")

    puts where
    >> {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}
    
    # But the real power is the ability to search with complex boolean logic using normal and flattend field names.
    # Note that flattened field names are seperated with double under lines __
    hash_model = HashModel.new(:raw_data=>records)
    where = hash_model.where {:something == 7 || (:parameter__type == String && :parameter__required == true)}

    puts where
    >> {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}
    >> {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}
    >> {:switch=>"-z", :parameter=>{:type=>String, :required=>true}, :description=>"zee svitch zu moost calz", :something=>4, :_id=>4, :_group_id=>2}

    # You can even search using hash values
    hash_model = HashModel.new(:raw_data=>records)
    where = hash_model.where {:parameter == {:type => String, :required => true}}
    
    puts where
    >> {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}, 
    >> {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}


### **Finding Sibling Records : group**
    # Since the HashModel class flattens records it is sometimes useful to know what records were created from the same raw data record.
    # This works exactly like a #where search so you can send just a value or send a block and get all of the sibling records for your search criteria.
    records = [
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
      {:switch => ["-y", "--why"],  :description => "lucky what?", :something => 7},
      {:switch => "-z",  :parameter => {:type => Integer, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
    ]
    hash_model = HashModel.new(:raw_data=>records)
    group = hash_model.group {(:parameter__type == String && :parameter__required == true && :something == 4) || :something == 7}
    
    puts group
    >> {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}
    >> {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}
    >> {:switch=>"-y", :description=>"lucky what?", :something=>7, :_id=>2, :_group_id=>1}
    >> {:switch=>"--why", :description=>"lucky what?", :something=>7, :_id=>3, :_group_id=>1}


### **Unflattening records : unflatten**
    # You can also add flat records in the same way you add raw records. 
    hash_model = HashModel.new
    hash_model << {:switch=>"-x", :parameter__type=>String, :parameter__require=>true, :description=>"Xish stuff"}
    
    puts hash_model.raw_data
    >> {:switch => "-x", :parameter => {:type => String, :require => true}, :description => "Xish stuff"}
    
    # You can also call the unflatten method on an instance or the class itself and send it a record. (It won't mess with the existing data.)
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

0.3.2 - 2011.03

* Fixed bug if you searched an empty HashModel (can't build a flatten index on nothing)
* Changed HashModel#parent method to search like a `where` search and return all raw parent records.
* Added delete method to delete raw data for flattened records. Note that since this is deleting the raw data if you have other flatten records that are based on that raw data they will no longer exist because the data that generated them is gone.

0.3.1 - 2011.03.18

* Fixed design flaw that caused HashModel not to respond to Array methods if a deserialized copy (e.g. Marshal.load) was used before a new instance of the class had been created.

0.3.0 - 2011.01.13

* HashModel\#where searches can now use symbols instead of @variables (you can still use @ if you want).  
e.g. hash_model.where{:x == "x" && :y == "y"} instead of the less natural hash_model.where{@x == "x" && @y == "y"}  
* Converted the HashModel filter from a proc to a string so it can be viewed and allows the above behavior (still no built-in proc.to_source so thanks to sourcify).  
* Changed name for require to mirror name of app (require 'hashmodel' instead of confusing require 'hash_model')  
* Added flatten to multiple methods (clone, to\_s, to\_a, to\_ary) so they'll return flattened data if called without anything else happening first.  
* Fixed == comparison bug
* Fixed design flaw that didn't allow arrays of arrays to be used as values or allow arrays as search criteria.  
* Removed Jeweler and converted to Bundler gem building.  
* Added usage instructions.  
* To do: Refactor some ugly code  

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

