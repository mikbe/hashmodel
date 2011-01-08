$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "/../lib"))
require 'hash_model'
require 'sourcify'

records = [
  {:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"},
  {:switch => ["-y", "--why"],  :description => "lucky what?"},
  {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},
]

=begin
hash_model = HashModel.new(:raw_data=>records)

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


		# Flatten index is automatically set to the first field ever given
		# but you can change it
    records = [  
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"},  
      {:switch => ["-y", "--why"],  :description => "lucky what?"},  
      {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},  
    ]  
    hash_model = HashModel.new(:raw_data=>records)  
		
		puts hash_model.flatten_index
		# you can use flattened field names
		hash_model.flatten_index = :parameter__type
		puts hash_model
		
		>> {:parameter__type=>String, :switch=>["-x", "--xtended"], :parameter__require=>true, :description=>"Xish stuff", :_id=>0, :_group_id=>0}
    >> {:parameter__type=>nil, :switch=>["-y", "--why"], :description=>"lucky what?", :_id=>1, :_group_id=>1}
    >> {:parameter__type=>String, :switch=>"-z", :description=>"zee svitch zu moost calz", :_id=>2, :_group_id=>2}

    # Notice that records that don't have the flatten index have their value set to nil
=end    
    # The real strength of the class is its ability to search flattened fields
    hash_model = HashModel.new(:raw_data=>records)  

    # default is to use the flatten index
    puts hash_model.where("-z")
    
    # but you can also use a block with boolean search parameters
    # You must write the field names as @variables instead of symbols
    puts hash_model.where {@parameter_type}
