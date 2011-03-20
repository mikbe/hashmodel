require 'spec_helper'
  
describe HashModel do

  context "when deleting records" do

    context "and doing it destructively" do
      it "should delete the raw record the child record is based on" do
        hm = HashModel.new << @records[1] << @records[2]
        @hm.delete!("-x")
        @hm.should == hm
      end
      it "should delete all the parents if there are more than one base on the search" do
        hm = HashModel.new(:raw_data=>@records[1])
        @hm.delete!{:parameter__type == String}
        @hm.should == hm
      end
      it "returns the parent records that are deleted" do
        @hm.delete!{:parameter__type == String}.should == [@records[0], @records[2]]
       end
    end

    context "NON-destructively" do
      # Arrays returns the records deleted, not the original array minus the deletion.
      # The class now mimics that behavior to be less surprising and more Ruby like.
      
      it "should delete the raw record the child record is based on" do
        hm = HashModel.new << @records[1] << @records[2]
        @hm.delete("-x")
        @hm.should_not == hm
      end
      it "should delete all the parents if there are more than one base on the search" do
        hm = HashModel.new(:raw_data=>@records[1])
        @hm.delete{:parameter__type == String}
        @hm.should_not == hm
      end
      it "should delete the raw record the child record is based on" do
        hm = HashModel.new << @records[0] 
        hm2 = @hm.delete("-x")
        hm2.should == hm
      end
      it "should delete all the parents if there are more than one base on the search" do
        hm = HashModel.new(:raw_data=>[@records[0], @records[2]])
        hm2 = @hm.delete{:parameter__type == String}
        hm2.should == hm
      end
    end

  end

end