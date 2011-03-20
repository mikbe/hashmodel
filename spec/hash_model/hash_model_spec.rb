require 'spec_helper'
  
describe HashModel do
 
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

    describe "flattened data" do
      
      it "reports the length of the flattened data" do
        @hm.length.should == 5
      end
      
    end

  end # "general properties"

  context "a reserved field name is used" do

    it "should raise an error if a protected field name is used" do
      proc { @hm << {:_id => 1} }.should raise_error(HashModel::ReservedNameError)
      proc { @hm << {:_group_id => 1} }.should raise_error(HashModel::ReservedNameError)
    end

    it "should raise an error if a reserved field name is used deep within the raw data" do
      proc { @hm.raw_data = [{:switch => "--potato", :should_error=>[:_group_id => 1, :another => 2] }] }
      .should raise_error(HashModel::ReservedNameError)
    end

    it "should raise an error if a reserved field name is used deep within the raw data" do
      proc { @hm = HashModel.new(:raw_data=>[{:switch => "--potato", :should_error=>[:_group_id => 1, :another => 2] }] ) }
      .should raise_error(HashModel::ReservedNameError)
    end

  end

  context "when using the [] sign" do
    
    it "should return flat records" do
      @hm.each_with_index do |record, index|
        record.should == @flat_records[index]
      end
    end
    
  end

end # describe "HashModel"
