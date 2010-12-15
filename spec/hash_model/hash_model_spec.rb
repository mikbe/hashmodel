require_relative '../spec_helper'

module MikBe

# RSpec's change just does not work with arrays in tests because of how Ruby changes the data arrays point to
# So we have to manually check before and after
  
describe "HashModel" do

  before(:each) do
    @records = [
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"},
      {:switch => ["-y", "--why"],  :description => "lucky what?"},
      {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},
    ]
    @hm = HashModel.new(:raw_data=>@records)

    @records2 = [
      {:switch => ["-p", "--pea"], :parameter => {:type => Hash, :require => false}, :description => "Pea soup"},
      {:switch => ["-q", "--quit"],  :description => "exit the game"},
      {:switch => "-r",  :parameter => {:type => Fixnum}, :description => "Arrrrrrrrrrgh!"},
    ]
    @hm2 = HashModel.new(:raw_data=>@records2)
    
    @flat_records = [
      {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
      {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0}, 
      {:switch=>"-y", :description=>"lucky what?", :hm_id=>2, :hm_group_id=>1}, {:switch=>"--why", :description=>"lucky what?", :hm_id=>3, :hm_group_id=>1}, 
      {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2}
    ]
    
    @flat_records2 =[
      {:switch=>"-p", :parameter=>{:type=>Hash, :require=>false}, :description=>"Pea soup", :hm_id=>0, :hm_group_id=>0},
      {:switch=>"--pea", :parameter=>{:type=>Hash, :require=>false}, :description=>"Pea soup", :hm_id=>1, :hm_group_id=>0},
      {:switch=>"-q", :description=>"exit the game", :hm_id=>2, :hm_group_id=>1},
      {:switch=>"--quit", :description=>"exit the game", :hm_id=>3, :hm_group_id=>1},
      {:switch=>"-r", :parameter=>{:type=>Fixnum}, :description=>"Arrrrrrrrrrgh!", :hm_id=>4, :hm_group_id=>2}
    ]
    
    @flat_records_all = [
      {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
      {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0}, 
      {:switch=>"-y", :description=>"lucky what?", :hm_id=>2, :hm_group_id=>1}, 
      {:switch=>"--why", :description=>"lucky what?", :hm_id=>3, :hm_group_id=>1}, 
      {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2}, 
      {:switch=>"-p", :parameter=>{:type=>Hash, :require=>false}, :description=>"Pea soup", :hm_id=>5, :hm_group_id=>3}, 
      {:switch=>"--pea", :parameter=>{:type=>Hash, :require=>false}, :description=>"Pea soup", :hm_id=>6, :hm_group_id=>3}, 
      {:switch=>"-q", :description=>"exit the game", :hm_id=>7, :hm_group_id=>4}, 
      {:switch=>"--quit", :description=>"exit the game", :hm_id=>8, :hm_group_id=>4}, 
      {:switch=>"-r", :parameter=>{:type=>Fixnum}, :description=>"Arrrrrrrrrrgh!", :hm_id=>9, :hm_group_id=>5}
    ]

  end
 
  describe "general properties" do
    
    describe "raw data" do

      it "should always allow access to the raw, unflattened records" do
        @hm.should respond_to(:raw_data)
      end

      it "should have raw data equal to the data that is input" do
        @hm.raw_data.should == @records
      end
      
      it "should clear the raw data when clear is called" do
        @hm = HashModel.new
        @hm << @records[0]
        proc{@hm.clear}.should change(@hm, :raw_data)
          .from([{:switch => ["-x", "--xtended"], :parameter => {:type => String, :require => true}, :description => "Xish stuff"}])
          .to([])
      end
      
      it "should only allow arrays to be set as the raw data" do
        proc {@hm.raw_data = "string"}.should raise_error
      end
      
      it "should allow arrays to be set as the raw data" do
        proc {@hm.raw_data = [ { :switch => ["-x", "--xtended"] } ] }.should_not raise_error
      end
      
      it "should allow nil to be set as the raw data" do
        proc {@hm.raw_data = nil }.should_not raise_error
      end
      
    end # "raw data"

  end # "general properties"

  describe "adding records" do

    it "should allow a hash of values to be added" do
      proc { @hm << {:switch => ["-x", "--xtended"], :description => "Xish stuff"} }.should_not raise_error
    end

    it "should allow a hash of values to be added using the keyword 'add'" do
      proc { @hm.add(:switch => ["-x", "--xtended"], :description => "Xish stuff") }.should_not raise_error
    end
    
    it "should allow an array of hashes to be added as if they were multiple records" do
      proc { @hm << @records }.should_not raise_error
    end
    
    it "should allow another HashModel to be added" do
      @hm.add(@hm2).should == @flat_records_all
    end
    
    it "should allow an array of HashModels to be added" do
      @hm.add([@hm, @hm2])
      @hm.should == [
        {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0}, 
        {:switch=>"-y", :description=>"lucky what?", :hm_id=>2, :hm_group_id=>1}, 
        {:switch=>"--why", :description=>"lucky what?", :hm_id=>3, :hm_group_id=>1}, 
        {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2}, 
        {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>5, :hm_group_id=>3}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>6, :hm_group_id=>3}, 
        {:switch=>"-y", :description=>"lucky what?", :hm_id=>7, :hm_group_id=>4}, 
        {:switch=>"--why", :description=>"lucky what?", :hm_id=>8, :hm_group_id=>4}, 
        {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>9, :hm_group_id=>5}, 
        {:switch=>"-p", :parameter=>{:type=>Hash, :require=>false}, :description=>"Pea soup", :hm_id=>10, :hm_group_id=>6}, 
        {:switch=>"--pea", :parameter=>{:type=>Hash, :require=>false}, :description=>"Pea soup", :hm_id=>11, :hm_group_id=>6}, 
        {:switch=>"-q", :description=>"exit the game", :hm_id=>12, :hm_group_id=>7}, 
        {:switch=>"--quit", :description=>"exit the game", :hm_id=>13, :hm_group_id=>7}, 
        {:switch=>"-r", :parameter=>{:type=>Fixnum}, :description=>"Arrrrrrrrrrgh!", :hm_id=>14, :hm_group_id=>8}
      ]
    end
    
    it "should raise an error if something other than a hash, an array of hashes, or another HashModel (or an array of them) is added" do
      proc { @hm << ["-x", "--xtended", "Xish stuff"] }.should raise_error
    end

    context "reserved field names" do
  
      it "should raise an error if a protected field name is used" do
        proc { @hm << {:hm_id => 1} }.should raise_error(MikBe::ReservedNameError)
        proc { @hm << {:hm_group_id => 1} }.should raise_error(MikBe::ReservedNameError)
      end
  
      it "should raise an error if a reserved field name is used deep within the raw data" do
        proc { @hm.raw_data = [{:switch => "--potato", :should_error=>[:hm_group_id => 1, :another => 2] }] }
        .should raise_error(MikBe::ReservedNameError)
      end

      it "should raise an error if a reserved field name is used deep within the raw data" do
        proc { @hm = HashModel.new(:raw_data=>[{:switch => "--potato", :should_error=>[:hm_group_id => 1, :another => 2] }] ) }
        .should raise_error(MikBe::ReservedNameError)
      end
  
    end
  
    it "should allow an array of hashes to be specified when creating the HashModel" do
      proc { HashModel.new(:raw_data=>@records) }.should_not raise_error
    end
  
    it "should retain the raw data used when creating the HashModel" do
      @hm.raw_data.should == @records
    end

    it "should return a HashModel object when adding records using <<" do
      (@hm << @records[0]).class.should == HashModel
    end

    it "should return the same HashModel instance when adding records using <<" do
      (@hm << @records[0]).object_id.should == @hm.object_id
    end
    
    it "should allow chaining of record adds using <<" do
      proc {@hm << @records[0] << @records[1] << @records[2]}.should_not raise_error
    end

    it "should contain all of the records when chaining record adds" do
      @hm << @records[0] << @records[1] << @records[2]
      @hm.raw_data.should == @records
    end

    context "using the + sign" do

      it "should return a HashModel class when adding an Array" do
        (@hm + @records2).class.should == HashModel
      end

      it "should return a HashModel class when adding a HashModel" do
        (@hm + @hm2).class.should == HashModel
      end

      it "should return a different HashModel instance" do
        (@hm + @records2).object_id.should_not == @hm.object_id
      end

      it "should contain the records of both recordsets when adding an Array" do
        (@hm + @records2).raw_data.should == (@records + @records2)
      end

      it "should contain the records of both recordsets when adding a HashModel" do
        (@hm + @hm2).raw_data.should == (@records + @records2)
      end
      
      it "should use the flatten index of the receiver HashModel" do
        hm2 = HashModel.new
        hm2 << {:potato=>7}
        (@hm + hm2).flatten_index.should == :switch
        (hm2 + @hm).flatten_index.should == :potato
      end
      
    end # "when using the plus sign"

    context "using the += sign" do

      it "should return a HashModel class" do
        (@hm += @records2).class.should == HashModel
      end

      it "should return the same HashModel instance when using += to add an array" do
        (@hm += @records2).object_id.should == @hm.object_id
      end

      it "should contain the records of both recordsets when adding an Array" do
        @hm += @records2
        @hm.raw_data.should == (@records + @records2)
      end

      it "should contain the records of both recordsets when adding a HashModel" do
        @hm += @hm2
        @hm.raw_data.should == (@records + @records2)
      end
      
      it "should not alter the added HashModel" do
        proc{@hm += @hm2}.should_not change(@hm2, :raw_data)
      end
      
    end # "when using the += sign"

    context "using the * sign" do
      
      it "should return a HashRecord" do
        (@hm * 2).class.should == HashModel
      end
      
      it "should return a different HashRecord" do
        (@hm * 2).object_id.should_not == @hm.object_id
      end
      
      it "should return a HashModel with twice the amount of raw data if * 2'd" do
        (@hm * 2).raw_data.should == [
          {:switch=>["-x", "--xtended"], :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff"}, 
          {:switch=>["-y", "--why"], :description=>"lucky what?"}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz"},
          {:switch=>["-x", "--xtended"], :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff"}, 
          {:switch=>["-y", "--why"], :description=>"lucky what?"}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz"}
        ]
      end
      
    end

    context "using the *= sign" do
    
      it "should return the same HashModel" do
       (@hm *= 2).object_id.should == @hm.object_id
      end
      
      it "should change current raw to twice its old raw data if *= 2'd" do
        @hm *= 2
        @hm.should == [
          {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0}, 
          {:switch=>"-y", :description=>"lucky what?", :hm_id=>2, :hm_group_id=>1}, 
          {:switch=>"--why", :description=>"lucky what?", :hm_id=>3, :hm_group_id=>1},
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2}, 
          {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>5, :hm_group_id=>3}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>6, :hm_group_id=>3}, 
          {:switch=>"-y", :description=>"lucky what?", :hm_id=>7, :hm_group_id=>4}, 
          {:switch=>"--why", :description=>"lucky what?", :hm_id=>8, :hm_group_id=>4}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>9, :hm_group_id=>5}
        ]
      end
      
    end

    context "using concat" do
      
      it "should concatinate using a single Hash" do
        @hm.concat(@records2[0]).should == [
          {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0}, 
          {:switch=>"-y", :description=>"lucky what?", :hm_id=>2, :hm_group_id=>1}, 
          {:switch=>"--why", :description=>"lucky what?", :hm_id=>3, :hm_group_id=>1}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2}, 
          {:switch=>"-p", :parameter=>{:type=>Hash, :require=>false}, :description=>"Pea soup", :hm_id=>5, :hm_group_id=>3}, 
          {:switch=>"--pea", :parameter=>{:type=>Hash, :require=>false}, :description=>"Pea soup", :hm_id=>6, :hm_group_id=>3}
        ]
      end
      
      it "should concatinate using an array" do
        @hm.concat(@records2).should == @flat_records_all
      end
      
      it "should concatinate using a HashModel" do
        @hm.concat(@hm2).should == @flat_records_all
      end
      
    end

    context "using push" do
      
      it "should add a single Hash" do
        @hm.push(@records2[0]).should == [
          {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0}, 
          {:switch=>"-y", :description=>"lucky what?", :hm_id=>2, :hm_group_id=>1}, 
          {:switch=>"--why", :description=>"lucky what?", :hm_id=>3, :hm_group_id=>1}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2}, 
          {:switch=>"-p", :parameter=>{:type=>Hash, :require=>false}, :description=>"Pea soup", :hm_id=>5, :hm_group_id=>3}, 
          {:switch=>"--pea", :parameter=>{:type=>Hash, :require=>false}, :description=>"Pea soup", :hm_id=>6, :hm_group_id=>3}
        ]
      end
      
      it "should add an array" do
        @hm.push(@records2).should == @flat_records_all
      end
      
      it "should add a HashModel" do
        @hm.push(@hm2).should == @flat_records_all
      end
      
    end

  end # adding records
   
  describe "using the [] sign" do
    
    it "should return flat records" do
      @hm.each_with_index do |record, index|
        record.should == @flat_records[index]
      end
    end
    
  end
  
  describe "flattening behavior" do
    
    it "should set the first field given as the default flatten index" do
      @hm << {:switch => ["-x", "--xtended"], :description => "Xish stuff"}
      @hm.add(:description => "blah,blah,blah")
      @hm.flatten_index.should == :switch
    end
    
    it "should set the flatten index properly if specified using parameter :flatten_index" do
      @hm = HashModel.new(:raw_data=>@records, :flatten_index=>:parameter)
      @hm.should == [
        {:parameter=>{:type=>String}, :switch=>["-x", "--xtended"], :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
        {:parameter=>{:require=>true}, :switch=>["-x", "--xtended"], :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0}, 
        {:parameter=>nil, :switch=>["-y", "--why"], :description=>"lucky what?", :hm_id=>2, :hm_group_id=>1}, 
        {:parameter=>{:type=>String}, :switch=>"-z", :description=>"zee svitch zu moost calz", :hm_id=>3, :hm_group_id=>2}
      ]
      
    end
  
    it "should allow you to change the flatten index" do
      @hm << {:switch => ["-x", "--xtended"], :description => "Xish stuff"}
      proc do
        @hm.flatten_index = :description
      end.should change(@hm, :flatten_index).from(:switch).to(:description)
    end

    it "should set the flatten index when adding to an empty HashModel" do
      @hm.flatten_index.should == :switch
    end

    it "should assign the flattened data to self correctly when adding records using <<" do
      @hm = HashModel.new
      @hm << @records[0]
      @hm << @records[1]
      @hm << @records[2]
      @hm.should == @flat_records
    end

    it "should assign the flattened data to self correctly when adding with :raw_data=>records" do
      @hm.should == @flat_records
    end
    
    it "should add a nil value for the field index for records that don't have a field with the field index" do
      @hm = HashModel.new
      @hm << @records[0]
      @hm << {:foo=>"bar"}
      @hm.last.should == {:switch=>nil, :foo=>"bar", :hm_id=>2, :hm_group_id=>1}
    end

    it "should change the flattened data when changing the flatten index" do
      @hm = HashModel.new(:raw_data=>@records)
      @hm.flatten_index = :parameter_type
      @hm.should == [
        {:parameter_type=>String, :switch=>["-x", "--xtended"], :parameter_require=>true, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
        {:parameter_type=>nil, :switch=>["-y", "--why"], :description=>"lucky what?", :hm_id=>1, :hm_group_id=>1}, 
        {:parameter_type=>String, :switch=>"-z", :description=>"zee svitch zu moost calz", :hm_id=>2, :hm_group_id=>2}
      ]
    end

    it "should update the flattened data if the raw data is changed" do
      @hm.raw_data = @records2.clone
      @hm.should == @flat_records2
    end

  end # flattening behvior

  describe "comparisons" do
    
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
    
  end # comparisons

  describe "searching and selecting records" do
 
    context "in place" do

      it "should accept a parameter as input" do
        proc{@hm.where!("-x")}.should_not raise_error
      end

      it "should raise an error if a block and a parameter are given" do
        proc{@hm.where!("-x"){@switch == "-x"}}.should raise_error
      end    
    
      it "should return a HashModel when searching" do
        @hm.where!("-x").class.should == HashModel
      end
  
      it "should return the same hash model when calling where" do
         @hm.where!("-x").object_id.should == @hm.object_id
      end
     
      it "should filter the recordset" do
        @hm.where!("-x")
        @hm.should == [@flat_records[0]]
      end
   
      it "should tell you if it is filtering records" do
        @hm.where!("-x")
        @hm.filtered?.should == true
      end
      
      it "should let you clear the filter" do
        @hm.where!("-x")
        proc {@hm.clear_filter}.should change(@hm, :filtered?).from(true).to(false)
      end
      
      it "should show all the records when the filter is cleared" do
        @hm.where!("-x")
        @hm.clear_filter
        @hm.should == @flat_records
      end
      
      it "should clear the filter if nothing is sent" do
        @hm.where!("-x")
        proc {@hm.where!}.should change(@hm, :filtered?).from(true).to(false)
      end
      
      it "should return the entire flattened recordset if nothing is sent" do
        @hm.where!("-x")
        @hm.should == [@flat_records[0]]
        @hm.where!
        @hm.should == @flat_records
      end
      
    end # in place
    
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
        @hm = HashModel.new(:raw_data=>@records)
        @hm.where{@parameter_type == String}.should == [
          {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2}
        ]
      end
    
    end # not in place

    it "should return false if tested for inclusion of anything other than a hash" do
      @hm.include?([:switch=>"-x"]).should == false
    end
    
    it "should match flat data if search criteria includes an hm_group_id field" do
      @hm.include?(@flat_records[2]).should == true
    end
    
    it "should search raw data if search criteria includes an hm_group_id field" do
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
        @hm.take_while {|record| record[:hm_id] < 4}.should == @flat_records[0..3]
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

  describe "grouping" do
    
    context "not in place" do
      
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
        @hm.where("-x").group.should == [@flat_records[0],@flat_records[1]]
      end 
    
      it "should return the records in the same raw data record when using a block" do
        @hm.group{@switch == "-y"}.should == [@flat_records[2], @flat_records[3]]
      end
    
      it "should work across group_id's if searching for something that returns records from multiple groups" do
        @hm.group{@parameter_type == String}.should == [
          {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0},
          {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2}
        ]
      end
    
    end # not in place
    
    context "in place" do
      
      it "should return the same HashModel object" do
        @hm.group!("-x").object_id.should == @hm.object_id
      end
  
      it "should return the records in the same raw data record when using a parameter" do
        @hm.group!("-x").should == [@flat_records[0],@flat_records[1]]
      end

      it "should be chainable on a filtered HashModel" do
        @hm.where("-x").group!.should == [@flat_records[0],@flat_records[1]]
      end 

      it "should be chainable on an in-place filtered HashModel" do
        @hm.where!("-x").group!.should == [@flat_records[0],@flat_records[1]]
      end 
  
      it "should return the records in the same raw data record when using a block" do
        @hm.group!{@switch == "-y"}.should == [
          {:switch=>"-y", :description=>"lucky what?", :hm_id=>2, :hm_group_id=>1}, 
          {:switch=>"--why", :description=>"lucky what?", :hm_id=>3, :hm_group_id=>1}
        ]
      end
  
      it "should work across group_id's if searching for something that returns records from multiple groups" do
        @hm.group!{@parameter_type == String}.should == [
          {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0},
          {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2}
        ]
      end
      
    end
    
  end # grouping

  describe "miscellaneous array methods and properties" do
    
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
        {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0, :extra=>0}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0, :extra=>1}, 
        {:switch=>"-y", :description=>"lucky what?", :hm_id=>2, :hm_group_id=>1, :extra=>2}, 
        {:switch=>"--why", :description=>"lucky what?", :hm_id=>3, :hm_group_id=>1, :extra=>3}, 
        {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2, :extra=>4}
      ]
    end

    it "should map across the flat data" do
      extra = -1
      @hm.map {|record| record.merge!(:extra=>extra+=1)}.should == [
        {:switch=>"-x", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>0, :hm_group_id=>0, :extra=>0}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :require=>true}, :description=>"Xish stuff", :hm_id=>1, :hm_group_id=>0, :extra=>1}, 
        {:switch=>"-y", :description=>"lucky what?", :hm_id=>2, :hm_group_id=>1, :extra=>2}, 
        {:switch=>"--why", :description=>"lucky what?", :hm_id=>3, :hm_group_id=>1, :extra=>3}, 
        {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :hm_id=>4, :hm_group_id=>2, :extra=>4}
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
 
end # describe "HashModel"

end # MikBe