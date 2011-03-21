require 'spec_helper'
  
describe HashModel do

  context "when unflattening behavior" do
    
    it "should allow access to the unflatten without an instance of HashModel" do
        deep_hash =  { 
          :parameter__type=>String,
          :switch__deep1__deep3 => "deepTwo",
          :parameter__type__ruby=>true,
          :parameter => "glorp",
          :parameter__required=>true,
          :switch__deep2 => "deepTwo",
          :description=>"Xish stuff",
          :switch => "--xtend",
        }
        HashModel.unflatten(deep_hash).should == {
            :parameter => [
              {:type=>String}, 
              "glorp", 
              {:required=>true}
            ], 
            :switch => [
              {:deep1 => {:deep3=>"deepTwo"}},
              {:deep2=>"deepTwo"}, 
              "--xtend"
            ], 
            :description=>"Xish stuff"
          }
    end
    
  end
end