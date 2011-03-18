require "spec_helper"

#  WARNING!
#  The following test is valid ONLY if it is run by itself!
#  If a HashModel object has been instantiated before this test
#  the test will not properly verify that the dynamic methods are
#  recreated.

describe HashModel do

  let(:hm_file) {File.expand_path((File.dirname(__FILE__) + '/hashmodel.dat'))}
  let(:hm) {Marshal.load(File.open(hm_file, "r"))}

  context "after deserializing an instance" do
    
    it "remaps dynamic methods if one of them is called" do
      lambda{hm.length}.should_not raise_error
    end
    
  end
  
  context "when a legitimatly non-exisitant method is called" do
    it "should raise an error" do
      lambda{hm.ice_cream}.should raise_error(NoMethodError)
    end
  end

end
