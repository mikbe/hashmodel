# HashModel

A simple MVC type model class for storing deeply nested hashes as records.
It's meant to be used for small, in-memory recordset that you want an easy, flexible way to query.
It is not meant as a data storage device for managing huge datasets.

Note: 
This is more of a programming exercise to learn about Ruby so if you're looking for a good
model class take a look at ActiveModel, it's probably more of what you're looking for.

## Synopsis

The major usefulness of this class is it allows you to filter and search flattened records based on any field.
A field can contain anything, including another hash, a string, and array, or even an Object class like String or Array, not
just an instance of an Object class.

You can also search using boolean like logic e.g.  
   
@hm = HashModel.new(:raw\_data=>@records)  
found = @hm.where {@switch == "-x" && @parameter\_type == String}  

## Usage

Just simple examples for now, waiting till I get a little more stable to do more in depth, for now look at the spec files for usage.

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
  

### **Adding hashes after creation**  
    hash_model = HashModel.new  
    hash_model << records[0]
    hash_model << records[1]
    hash_model << records[2]
  
  
### **Adding another hash model**  
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
		

### **Iterating over the HashModel**
    # the HashModel acts a lot like an array so you can iterate over it
    hash_model = HashModel.new(:raw_data=>records)  
    hash_model.each do |record|
      # record is a hash
    end

### **Flatten Index**
    # Flatten index is automatically set to the first field ever given
    # but you can change it
    hash_model = HashModel.new(:raw_data=>records)  
		
    puts hash_model.flatten_index
    # you can use flattened field names
    hash_model.flatten_index = :parameter__type
    puts hash_model
		
    >> {:parameter__type=>String, :switch=>["-x", "--xtended"], :parameter__require=>true, :description=>"Xish stuff", :_id=>0, :_group_id=>0}
    >> {:parameter__type=>nil, :switch=>["-y", "--why"], :description=>"lucky what?", :_id=>1, :_group_id=>1}
    >> {:parameter__type=>String, :switch=>"-z", :description=>"zee svitch zu moost calz", :_id=>2, :_group_id=>2}

    # Notice that records that don't have the flatten index field have their value set to nil		
		

### **Accessing Records**
    # You can use the values of the default flatten_index to retrieve the a record
    hash_model = HashModel.new(:raw_data=>records)  
		
    puts hash_model.where("-x")

## Version History

0.3.0 
* Changed where searches to use symbols instead of @variables. e.g. {:x == "x" && :y == "y"} instead of the less natural {@x == "x" && @y == "y"}
* Converted the HashModel filter to a string so it can be viewed and allows the above behavior.
- To do: allow subtractions
* Removed Jeweler and converted to Bundler gem building.

0.2.0   
* Fixed bug if first field name is shorter version of another field name, e.g. :short then :shorter would cause an error.  
* Added unflattening records and adding unflattened records.  
* Changed field separator to double underscores (to allow unflattening)  
* Removed namespace module, it was annoying. Now just instantiate it with HashModel.new instead of MikBe::HashModel.new  
* Now allows a single hash, instead of an array of hashes, when creating with HashModel.new(:raw_data => hash)  

0.1.1 Moved to new RubyGems account  

0.1.0 Initial publish  

## Planned updates

* Allow subtraction of records (flattened, unflattened, or other HashModels)

== Contributing to hash\_model

* Please feel free to correct any mistakes I make by correcting the code and sending me a pull request. Pull requests are handled ASAP.
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project  
* Start a feature/bugfix branch  
* Commit and push until you are happy with your contribution  
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2010 Mike Bethany. See LICENSE.txt for further details.

