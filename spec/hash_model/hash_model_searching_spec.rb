require 'spec_helper'
  
describe HashModel do

  context "when searching and selecting records" do
 
    context "when searhing non-destructively" do

      it "should return an empty set if the HashModel is empty" do
        empty = HashModel.new
        empty.where("fudge").should == []
      end
      
      it "should have a length of 0 if the HashModel is empty" do
        empty = HashModel.new
        empty.length.should == 0
      end
      
      it "should accept a parameter as input" do
        proc{@hm.where("-x")}.should_not raise_error
      end

      it "should raise an error if a block and a parameter are given" do
        proc{@hm.where("-x"){@switch == "-x"}}.should raise_error
      end    
    
      it "should return a HashModel when searching" do
        @hm.where("-x").class.should == HashModel
      end
  
      it "should return a different hash model when calling where" do
         @hm.where("-x").object_id.should_not == @hm.object_id
      end
      
      it "should shouldn't destroy records" do
        lambda{@hm.where("-x")}.should_not change{@hm}
      end
      
      it "should delete data from raw records if that data doesn't fit the search criteria" do
        records = {:switch=>[[1,2],[3,4]]}
        hm = HashModel.new(:raw_data=>records)
        hm.where([1,2]).raw_data[0][:switch].should_not include([3,4])
      end
      
    end
    
    context "when searhing destructively" do
  
      it "should return the same hash model when calling where!" do
         @hm.where!("-x").object_id.should == @hm.object_id
      end
      
      it "should should destroy records" do
        lambda{@hm.where!("-x")}.should change{@hm.raw_data.clone}
      end
      
    end

    context "non-string search values" do

      it "should search using the flatten_index if a symbol is used with where" do
        @records = [
          {:switch => ["-x", "--xtended", :default], :parameter => {:type => String, :require => true}, :description => "Xish stuff"},
          {:switch => ["-y", "--why"],  :description => "lucky what?"},
          {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},
        ]
        @hm = HashModel.new(:raw_data=>@records)
        @hm.where(:default).should == [{:switch=>:default, :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}]
      end

      it "should search using an array" do
        recs = [[1,2],[3,4]]
        hm = HashModel.new(:raw_data=>{:switch=>recs})
        hm.where([1,2]).should == [{:switch=>[1, 2], :_id=>0, :_group_id=>0}]
      end

    end
  
    context "filtering records" do
  
      it "should filter the recordset" do
        @hm.filter("-x")
        @hm.should == [@flat_records[0]]
      end
   
      it "should tell you if it is filtering records" do
        @hm.filter("-x")
        @hm.filtered?.should == true
      end
      
      it "should let you clear the filter" do
        @hm.filter("-x")
        proc {@hm.clear_filter}.should change(@hm, :filtered?).from(true).to(false)
      end
      
      it "should show all the records when the filter is cleared" do
        @hm.filter("-x")
        @hm.clear_filter
        @hm.should == @flat_records
      end
      
      it "should clear the filter if nothing is sent" do
        @hm.filter("-x")
        proc {@hm.where!}.should change(@hm, :filtered?).from(true).to(false)
      end
      
    end # filtering
    
    context "not in place" do

      it "should return a HashModel object" do
        @hm = HashModel.new(:raw_data=>@records)
        @hm.where("-x").class.should == HashModel
      end
  
      it "should return a new HashModel" do
         @hm.where("-x").object_id.should_not == @hm.object_id
      end

      it "should search the flatten index if given a parameter" do
        @hm = HashModel.new(:raw_data=>@records)
        @hm.where("-x").should == [@flat_records[0]]
      end
    
      it "should search the flatten index if given a block" do
        @hm.where{@parameter__type == String}.should == [
          {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0},
          {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>2, :_group_id=>1}
        ]
      end
    
    end # not in place

    context "using blocks" do
      
      it "should search using a single value boolean block" do
        @hm.where {:switch == "-x"}.should == [@flat_records[0]]
      end

      it "should search using a complex boolean block" do
        records = [
          {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
          {:switch => ["-y", "--why"],  :description => "lucky what?"},
          {:switch => "-z",  :parameter => {:type => String, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
        ]
        @hm = HashModel.new(:raw_data=>records)
        @hm.where {:something == 4 && :parameter__required == true}.should == [
          {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}, 
          {:switch=>"-z", :parameter=>{:type=>String, :required=>true}, :description=>"zee svitch zu moost calz", :something=>4, :_id=>2, :_group_id=>1}
        ]
      end
      
      it "should search a complex boolean block regardless of order" do
        records = [
          {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
          {:switch => ["-y", "--why"],  :description => "lucky what?"},
          {:switch => "-z",  :parameter => {:type => String, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
        ]
        @hm = HashModel.new(:raw_data=>records)
        @hm.where {:parameter__type == String && :parameter__required == true && :something == 4}.should == [
          {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}, 
          {:switch=>"-z", :parameter=>{:type=>String, :required=>true}, :description=>"zee svitch zu moost calz", :something=>4, :_id=>2, :_group_id=>1}
        ]
      end

      it "should search using a complex, multi-line boolean block" do
        records = [
          {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
          {:switch => ["-y", "--why"],  :description => "lucky what?", :something => 7},
          {:switch => "-z",  :parameter => {:type => Integer, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
        ]
        @hm = HashModel.new(:raw_data=>records)
        @hm.where {(:parameter__type == String && :parameter__required == true && :something == 4) || :something == 7}.should == [
          {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}, 
          {:switch=>"-y", :description=>"lucky what?", :something=>7, :_id=>2, :_group_id=>1}, 
          {:switch=>"--why", :description=>"lucky what?", :something=>7, :_id=>3, :_group_id=>1}
        ]
      end
    
      it "should search with nested hashes in a block" do
        records = [
          {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff", :something => 4},
          {:switch => ["-y", "--why"],  :description => "lucky what?", :something => 7},
          {:switch => "-z",  :parameter => {:type => Integer, :required => true}, :description => "zee svitch zu moost calz", :something => 4},
        ]
        @hm = HashModel.new(:raw_data=>records)
        @hm.where {:parameter == {:type => String, :required => true}}.should == [
          {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>0, :_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :something=>4, :_id=>1, :_group_id=>0}
        ]
      end
      
    end

    context "searching for the parent" do
      it "should return the raw record the child record is based on" do
        @hm.parents("-x").should == [@records[0]]
      end
      it "should return all the parents if there are more than one base on the search" do
        @hm.parents{:parameter__type == String}.should == [@records[0],@records[2]]
      end
    end

    it "should return false if tested for inclusion of anything other than a hash" do
      @hm.include?([:switch=>"-x"]).should == false
    end
    
    it "should match flat data if search criteria includes an _group_id field" do
      @hm.include?(@flat_records[2]).should == true
    end
    
    it "should search raw data if search criteria includes an _group_id field" do
      @hm.include?(@records[2]).should == true
    end

    it "should return the flattened record index using the index method" do
      @hm.index(@flat_records[3]).should == 3
    end
    
    context "when using take" do
      it "should return the first n flat records" do
        @hm.take(2).should == @flat_records.take(2)
      end
    
      it "should return the first n flat records while block is true" do
        @hm.take_while {|record| record[:_id] < 4}.should == @flat_records[0..3]
      end
      
    end

    it "should return values at x,y,z" do
      @hm.values_at(1,3,5).should == @flat_records.values_at(1,3,5)
    end
    
    it "should zip things" do
      hm2 = HashModel.new(:raw_data=>@records2)
      @hm.zip(hm2).should == @flat_records.zip(@flat_records2)
    end
    
  end # searching records
end