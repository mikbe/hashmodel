require 'spec_helper'
  
describe HashModel do
  
  context "when flattening" do
    
    it "should set the first field given as the default flatten index" do
      @hm << {:switch => ["-x", "--xtended"], :description => "Xish stuff"}
      @hm.add(:description => "blah,blah,blah")
      @hm.flatten_index.should == :switch
    end
    
    it "should set the flatten index properly if specified using parameter :flatten_index" do
      @hm = HashModel.new(:raw_data=>@records, :flatten_index=>:parameter)
      @hm.should == [
        {:parameter=>{:type=>String}, :switch=>["-x", "--xtended"], :description=>"Xish stuff", :_id=>0, :_group_id=>0}, 
        {:parameter=>{:required=>true}, :switch=>["-x", "--xtended"], :description=>"Xish stuff", :_id=>1, :_group_id=>0}, 
        {:parameter=>nil, :switch=>["-y", "--why"], :description=>"lucky what?", :_id=>2, :_group_id=>1}, 
        {:parameter=>{:type=>String}, :switch=>"-z", :description=>"zee svitch zu moost calz", :_id=>3, :_group_id=>2}
      ]
  
    end
  
    it "should allow you to change the flatten index" do
      @hm << {:switch => ["-x", "--xtended"], :description => "Xish stuff"}
      proc do
        @hm.flatten_index = :description
      end.should change(@hm, :flatten_index).from(:switch).to(:description)
    end
    
    it "should throw an error if an invalid flatten index is given" do
        @records = [
          { :switch => [ [5, 6], [1, :blah=>2] ] }
        ]
        @hm = HashModel.new(:raw_data=>@records)
        proc {@hm.flatten_index = :switch__blah}.should raise_error(ArgumentError)
    end
    
    it "shouldn't throw an error if a valid flatten index is given" do
      proc {@hm.flatten_index = :parameter__type}.should_not raise_error
    end

    it "should reset the flatten index if an invalid flatten index is given" do
        @records = [
          { :switch => [ [5, 6], [1, :blah=>2] ] }
        ]
        @hm = HashModel.new(:raw_data=>@records)
        proc {@hm.flatten_index = :switch__blah}.should raise_error(ArgumentError)
        @hm.flatten_index.should == :switch
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
      @hm.last.should == {:switch=>nil, :foo=>"bar", :_id=>2, :_group_id=>1}
    end

    it "should change the flattened data when changing the flatten index" do
      @hm = HashModel.new(:raw_data=>@records)
      @hm.flatten_index = :parameter__type
      @hm.should == [
        {:parameter__type=>String, :switch=>["-x", "--xtended"], :parameter__required=>true, :description=>"Xish stuff", :_id=>0, :_group_id=>0}, 
        {:parameter__type=>nil, :switch=>["-y", "--why"], :description=>"lucky what?", :_id=>1, :_group_id=>1}, 
        {:parameter__type=>String, :switch=>"-z", :description=>"zee svitch zu moost calz", :_id=>2, :_group_id=>2}
      ]
    end

    it "should update the flattened data if the raw data is changed" do
      @hm.raw_data = @records2.clone
      @hm.should == @flat_records2
    end

  end # flattening behvior

end