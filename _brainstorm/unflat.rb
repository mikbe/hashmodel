$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "/../lib"))
require 'hash_model'

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
