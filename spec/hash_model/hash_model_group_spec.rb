require 'spec_helper'

describe HashModel do
  
  context "when grouping" do
       
    it "should return a HashModel object" do
      @hm.group("-x").class.should == HashModel
    end
  
    it "should return a different HashModel object" do
      @hm.group("-x").object_id.should_not == @hm.object_id
    end
  
    it "should return the records in the same raw data record when using a parameter" do
      @hm.group("-x").should == [@flat_records[0], @flat_records[1]]
    end
  
    it "should be chainable on a filtered HashModel" do
      # Doesn't make logical sense anymore to do it this way since 
      # when you #where the HashModel you've deleted all the other data
      # Just use group like a #group like a where like above
      # @hm.where("-x").group.should == [@flat_records[0],@flat_records[1]]
    end 
  
    it "should return the records in the same raw data record when using a block" do
      @hm.group{:switch == "-y"}.should == [@flat_records[2], @flat_records[3]]
    end
  
    it "should group across group_id's if searching for something that returns records from multiple groups" do
      @hm.group{:parameter__type == String}.should == [
        {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0},
        {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz", :_id=>4, :_group_id=>2}
      ]
    end
  
    it "should group with a complex block" do
      records = [
        {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
        {:switch => ["-y", "--why"],  :description => "lucky what?", :something => 7},
        {:switch => "-z",  :parameter => {:type => Integer, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
      ]
      @hm = HashModel.new(:raw_data=>records)
      @hm.group {(:parameter__type == String && :parameter__required == true && :something == 4) || :something == 7}.should == [
        {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}, 
        {:switch=>"-y", :description=>"lucky what?", :something=>7, :_id=>2, :_group_id=>1}, 
        {:switch=>"--why", :description=>"lucky what?", :something=>7, :_id=>3, :_group_id=>1}
      ]
    end
  
    it "should group with nested hashes block" do
      records = [
        {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
        {:switch => ["-y", "--why"],  :description => "lucky what?", :something => 7},
        {:switch => "-z",  :parameter => {:type => Integer, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
      ]
      @hm = HashModel.new(:raw_data=>records)
      @hm.group {:parameter == {:type => String, :required => true}}.should == [
        {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}
      ]
    end
    
  end # grouping
end