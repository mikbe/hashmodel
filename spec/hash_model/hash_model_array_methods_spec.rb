require 'spec_helper'
  
describe HashModel do


  context "when using array methods and properties" do
    
    it "should return an array when calling to_ary" do
      @hm.to_ary.class.should == Array
    end
    
    it "should not return a HashModel when calling to_ary" do
      @hm.to_ary.class.should_not == HashModel
    end
    
    it "should return the flat records when calling to_ary" do
      @hm.to_ary.should == @flat_records
    end
    
    it "should return an array when calling to_a" do
      @hm.to_a.class.should == Array
    end
    
    it "should not return a HashModel when calling to_a" do
      @hm.to_a.class.should_not == HashModel
    end
    
    it "should return the flat records when calling to_a" do
      @hm.to_a.should == @flat_records
    end
    
    it "should report the length of the flat data" do
      @hm.length.should == @flat_records.length
    end
    
    it "should report the size of the flat data" do
      @hm.size.should == @flat_records.size
    end
    
    it "should return the correct flat record when using at" do
      @hm.at(0).should == @flat_records[0]
      @hm.at(2).should == @flat_records[2]
    end

    it "should collect across the flat data" do
      extra = -1
      @hm.collect {|record| record.merge!(:extra=>extra+=1)}.should == [
        {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0, :extra=>0}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0, :extra=>1}, 
        {:switch=>"-y", :description=>"lucky what?", :_id=>2, :_group_id=>1, :extra=>2}, 
        {:switch=>"--why", :description=>"lucky what?", :_id=>3, :_group_id=>1, :extra=>3}, 
        {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>4, :_group_id=>2, :extra=>4}
      ]
    end

    it "should map across the flat data" do
      extra = -1
      @hm.map {|record| record.merge!(:extra=>extra+=1)}.should == [
        {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0, :extra=>0}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0, :extra=>1}, 
        {:switch=>"-y", :description=>"lucky what?", :_id=>2, :_group_id=>1, :extra=>2}, 
        {:switch=>"--why", :description=>"lucky what?", :_id=>3, :_group_id=>1, :extra=>3}, 
        {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>4, :_group_id=>2, :extra=>4}
      ]
    end
    
    it "should combination'ize the flat data" do
      hm_combo = []
      flat_combo = []
      @hm.combination(2).each { |record| hm_combo << record }
      @flat_records.combination(2) { |record| flat_combo << record }
      hm_combo.should == flat_combo
    end

    it "should count the flat data" do
      @hm.count.should == @flat_records.count
    end

    it "should cycle over the flat data" do
      cycle = cycle2 = []
      @hm.cycle(2) {|record| cycle << record}
      @flat_records.cycle(2) {|record| cycle2 << record}
      cycle.should == cycle2
    end

    it "should iterate with an index" do
      collect = []
      @hm.each_index {|index| collect << @hm[index][:switch]}
      collect.should == ["-x", "--xtended", "-y", "--why", "-z"]
    end
    
    it "should say if it's empty" do
      @hm = HashModel.new
      @hm.empty?.should == true
      @hm << @records[0]
      @hm.empty?.should == false
    end

    it "should fetch records given an index" do
      @hm.fetch(2).should == @flat_records[2]
    end

    it "should return the default value if fetch index is out of bounds" do
      @hm.fetch(10, "potato").should == "potato"
    end

    it "should run a block if fetch index is out of bounds" do
      (@hm.fetch(10) {|index| index }).should == 10
    end

    it "should return the first flattened record" do
      @hm.first.should == @flat_records.first
    end

    it "should return the last flattened record" do
      @hm.last.should == @flat_records.last
    end

    it "should freeze the raw records" do
      proc{@hm.freeze}.should change(@hm.raw_data,:frozen?)
      .from(false)
      .to(true)
    end
    
    it "should permutate over the flat data" do
      @hm.permutation(2).to_a.should == @flat_records.permutation(2).to_a
      @hm.permutation.to_a.should == @flat_records.permutation.to_a
      @hm.permutation.to_a.should_not == @records.permutation.to_a
    end
    
  end
end