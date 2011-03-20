require 'spec_helper'
  
describe HashModel do

  context "when making comparisons" do
    
    it "should allow arrays to be compared to the HashModel" do
      @hm.should == @flat_records
    end
    
    it "should allow HashModels to be compared to the HashModel" do
      hm2 = HashModel.new(:raw_data=>@records)
      @hm.should == hm2
    end

    it "should compare using the raw data if sent an array without group_id's or id's" do
      @hm.should == @records
    end
    
    it "should return false if compared to something other than an Array or a HashModel" do
      @hm.should_not == "potato"
    end
    
    it "should allow arrays to be compared to the HashModel using eql?" do
      @hm.eql?(@hm).should == true
    end  
    
    it "should return false if compared to an array of something other than hashes" do
      @hm.should_not == ["potato"]
    end
    
    it "should use flattened records if <=>'d with an array with a group_id" do
      (@hm <=> @flat_records).should == 0
    end
    
    it "should use flattened records if <=>'d with an array without a group_id" do
      (@hm <=> @records).should == 0
    end
    
    it "should use flattened data if <=>'d with another HashModel" do
      hm2 = @hm.clone
      (@hm <=> hm2).should == 0
    end
    
    it "should return nil if <=>'d with something other than an Array or a HashModel" do
      (@hm <=> "potato").should == nil
    end
    
    it "should compare to an empty array" do
      @hm.where!("potato")
      @hm.should == []
    end
    
  end # comparisons
end