# HashModel

A simple MVC type model class for storing deeply nested hashes as records.
It's meant to be used for small, in-memory recordset that you want an easy, flexible way to query.
It is not meant as a data storage device for managing huge datasets.

## Synopsis ##

The major usefulness of this class is it allows you to filter and search flattened records based on any field. You can even updated and delete data now! Exclamation!

A field can contain anything, including another hash, a string, an array, or even an Object class like String or Array, not just an instance of an Object class.

Searches are very simple and logical. You can search using just using the value of the default index 

    require 'hashmodel'
    records = [  
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff"},  
      {:switch => ["-y", "--why"],  :description => "lucky what?"},  
      {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},  
    ]  
    hash_model = HashModel.new(:raw_data=>records)  
    found = hash_model.where("-x")  => Returns an array of flattened records  


Or more powerfully you can search using boolean like logic with dynamic variables:  
   
    x = "-x"
    param_type = String
    found = hash_model.where {:switch == x && :parameter__type == param_type}  => Returns an array of flattened records  

If you want to update a record in place you can do that as well:

    x = "-x"
    param_type = String
    updated = hash_model.update!(x, :parameter__type => param_type)  => Returns an array of flattened records  

For more info checkout the rdocs and also checkout the change history below. I go in-depth on the new method calls.

## Status ##

2011.03.21 - Release Candidate: 0.4.0.rc1

Lots of changes with this one. The major changes are the ability to write to the HashModel data. See Version History for details.

I fixed a **huge** bug that caused variables not to be ignored in boolean searches. It's all fixed now and there are specs to prove make sure it doesn't happen again.

## Demo App ##

Check out Widget for a demo of just how easy it is to use HashModel. It now has a lot of complexity but it's a breeze to use:

https://github.com/mikbe/widget

## Usage ##

I've covered most of the major stuff here but to see all of the functionality take a look at the RSpec files.

### **Creating with an array of hashes**  
    require 'hashmodel'
    records = [  
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff"},  
      {:switch => ["-y", "--why"],  :description => "lucky what?"},  
      {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},  
    ]  
    hash_model = HashModel.new(:raw_data=>records)  

    puts hash_model  
    >> {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}  
    >> {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0}  
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
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff"},  
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
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff"},  
      {:switch => ["-y", "--why"],  :description => "lucky what?"},  
      {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},  
    ]  
    hash_model = HashModel.new(:raw_data=>records) 
    
    puts hash_model.raw_data
    >> {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff"}  
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
    >> {:switch => "-x", :parameter => {:type => String, :required => true}, :description => "Xish stuff"}
    
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
    >> {:parameter=>[{:type=>String}, "glorp", {:required=>true}], :switch=>[{:deep1=>{:deep3=>"deepTwo"}}, {:deep2=>"deepTwo"}, "--xtend"], :description=>"Xish stuff"}
  

## Version History ##

0.4.0.rc1 - 2011.03-21

Lots of updates and code fixes for this release. After using it for a little while I've broken down and added the write functionality I was avoiding previously. 

I fixed a **major** bug/design flaw that didn't let you use variables in a boolean block. For instance this was supposed to work but didn't:

    x = "-x"
    hm.where{:x == x}
    
It works properly now.

**Additions/Changes**

#### Methods: `update` and `update!` methods ####
These methods use a `where` like search that is slightly different. As you would expect the `update` method returns a changed copy of the HashModel while `update!` changes the data in place.

The methods look like this `update(default_index_search, field_new_value_hash, boolean_search_block)`. So if you search using a single value, a default index search, then you put the update hashes at the end. If you want to search using a boolean search then you put the update hashes at the beginning.

For instance:

    # Default index search
    my_hash_model.update("-x", :parameter__type=>Fixnum)
    
    # Boolean search 
    my_hash_model.update(:parameter__type=>Fixnum) {:switch == "-x"}


You can update more than one field at a time as well. When you do this make sure you wrap them in hash markers {}:

    my_hash_model.update("-x", {:field_1=>"new value", :field_2=>"another new value"})


It's important to note that searches in an `update` will search the entire recordset. i.e. they will ignore the current filter. They will reset that filter when they are done so if you change the value of the primary index then you'll have an empty recordset. I realize it would be better to make the filters additive, and I will, but that will have to wait for the next update. 

You don't have to put in any search criteria at all though, you can just put in the field you want updated and it will update all records that are in the current filter set.

    my_hash_model.update(:field_1=>"new value")

All of the `update` methods will return the records that were updated with the updates in place. If no records were updated then it will return an empty array. It currently returns the raw records that are or would be deleted but I will be changing it to return the flattened records. That will be in the next update.

#### Methods: `update_and_add` and `update_and_add!` methods ####
Just like `update` and `update!` but will also add a hash if it doesn't exist already. Again the ! method changes the records in place.

For instance if your HashModel has a record like `{:a=>"a"}` and you do `my_hash_model.update(:b=>"b")` it won't change that record, but it you do `my_hash_model.update_and_add(:b=>"b")` then your record will be `{:a=>'a', :b=>"b"}`.

#### Methods: `delete` and `delete!` ####
These use  the standard `where` type search used everywhere else. You guessed it, the `delete!` method deletes in place while the `delete` method returns the records that would be deleted.

This function removes data from the raw data so if you have other flattened records that are based on that raw data they will no longer exist since the data that generated them is gone.  

Just like an array these methods return the records they deleted.

#### Method: `parent` ####
Again this uses a `where` search and returns all raw parent records for flattened records matching the search criteria. (This method was there before but hadn't actually be coded, it was just a copy of some code I started but shouldn't have been in a release version).

#### Changed: `filter` ####
Filter has been changed from a property to a method. It is exactly like a `where` search but it's in-place and non-destructive. Since `where!` was changed to be truly destructive this change was needed. It also makes all the search functions identical in their usage.

#### Changed: `where!` ####
Changed to be truly destructive. If you run a where! on the class you're losing records that don't match it. The non-destructive version `where` is changed in that it does not contain the raw data of any records that don't match the `where` clause but the original HashModel remains untouched.

#### Removed: `group!` ####
Since bangs (!) are all now destructive, to bring the class inline with Ruby standards, it doesn't make logical sense to have a a group method that deletes all data except the search data then tries to find siblings; they would have been deleted with the destructive call. Instead just use `group` and it will return the sibling records without touching the data in the HashModel.

#### Other changes ####
Because of the new destructive methods all input values will be cloned. You don't have to worry about cloning input objects yourself. If it's clonable HashModel will clone it.

I've reorganized the code into multiple files based on functionality to make it easier to debug when adding new features. This is in anticipation of a major cleanup and refactoring.

Cleaned up RSpecs a little along the lines of reorganization.

#### Bugs fixed ####
* Didn't use variable in where searches.
* Threw error if you searched an empty HashModel (can't build a flatten index on nothing)
* Couldn't change the flatten index in some rare cases. 

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


## Contributing to HashModel ##

* Pull requests are handled ASAP.
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project  
* Start a feature/bugfix branch  
* Commit and push until you are happy with your contribution  
* Make sure to add RSpecs in a separate file so I can easily tell what changed (changes without specs will not be pulled).
* Changes to the configuration files, version numbers, or branches will not be pulled. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright ##

Copyrighted free software - Copyright (c) 2011 Mike Bethany. See LICENSE.txt for further details.

