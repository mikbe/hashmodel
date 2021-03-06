require "spec_helper"

describe HashModel do

  context "when updating records" do

    let(:hm){HashModel.new(:raw_data=> {:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a =>"b2a", :b2b=>"b2b"}}} )}
    
    context "and the search key exists in the target" do
    
      it "should update the value properly" do
        update = {:b__b2__b2b=>"potato"}
        lambda{hm.update!(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"potato"}}, :_id=>0, :_group_id=>0}])
      end
    
      it "should update a mid-level hash" do
        update = {:b__b2=>"potato"}
        lambda{hm.update!(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"a", :b=>{:b1=>"b1", :b2=>"potato"}, :_id=>0, :_group_id=>0}])
      end
    
      it "should update a multiple update hashes at once" do
        update = {:b__b2=>"potato", :a=>"blorg", :b__b1=>"fish"}
        lambda{hm.update!(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"blorg", :b=>{:b1=>"fish", :b2=>"potato"}, :_id=>0, :_group_id=>0}])
      end
    
      it "should update with a hash as the value" do
        update = {:b__b2=>{:d=>"d"}}
        lambda{hm.update!(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:d=>"d"}}, :_id=>0, :_group_id=>0}])
      end
    
      it "should update with an array as the value" do
        update = {:b__b2=>[1,2,3]}
        lambda{hm.update!(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"a", :b=>{:b1=>"b1", :b2=>[1,2,3]}, :_id=>0, :_group_id=>0}])
      end
    
    
    end
    
    context "but the search key does NOT exist in the target" do
    
      it "should NOT by default add a field" do
        update = {:b__b2__b2c=>"potato"}
        lambda{hm.update!(update)}.should_not change{hm.deep_clone}
      end
    
      it "should add a field if told to do so (by using update_and_add)" do
        update = {:b__b2__b2c=>"potato"}
        lambda{hm.update_and_add!(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b", :b2c=>"potato"}}, :_id=>0, :_group_id=>0}])
      end
    
      it "should only return records that are changed" do
        hm << {:a=>"17", :b=>"1870"}
        update = {:b__b2__b2b=>"potato"}
        hm.update!(update).should == [
          {:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"potato"}}, :_id=>0, :_group_id=>0} 
        ]
      end
    
    end
 
    context "when updating a filtered HashModel" do
      
      before(:each) do
        hm << {:a=>"17", :b=>"7291", :c=>"0"}
        hm << {:a=>"17", :b=>"080", :c=>"1"}
        hm << {:a=>"17", :b=>"24134", :c=>2}
        hm.filter("17")
      end
      
      it "should return the updated records" do
        hm.update!(:b=>"23").should == [
          {:a=>"17", :b=>"23", :c=>"0", :_id=>1, :_group_id=>1}, 
          {:a=>"17", :b=>"23", :c=>"1", :_id=>2, :_group_id=>2}, 
          {:a=>"17", :b=>"23", :c=>2, :_id=>3, :_group_id=>3}
        ]
      end
      
      it "should not update records not in the current filter" do
        lambda{hm.update!(:b=>"23")}.should_not change{hm.raw_data.clone[0]}
      end
      
      it "should return the updated records even if the primary key is the one changed" do
        hm.update!(:a=>"BBBB").should == [
          {:a=>"BBBB", :b=>"7291", :c=>"0", :_id=>1, :_group_id=>1}, 
          {:a=>"BBBB", :b=>"080", :c=>"1", :_id=>2, :_group_id=>2}, 
          {:a=>"BBBB", :b=>"24134", :c=>2, :_id=>3, :_group_id=>3}
        ]
      end
      
      context "after changing the filtered field to something that doesn't match the filter" do
        it {hm.update!(:a=>"BBBB"); hm.length.should == 0}
      end
      
      context "and using variables for the update values" do
      
        it "should return the updated records" do
          update_field = :b
          update_to = "23"
          update_hash = {update_field => update_to}
          hm.update!(update_hash).should == [
            {:a=>"17", :b=>"23", :c=>"0", :_id=>1, :_group_id=>1}, 
            {:a=>"17", :b=>"23", :c=>"1", :_id=>2, :_group_id=>2}, 
            {:a=>"17", :b=>"23", :c=>2, :_id=>3, :_group_id=>3}
          ]
        end
      
        it "should not update records not in the current filter" do
          update_field = :b
          update_to = "23"
          update_hash = {update_field => update_to}
          lambda{hm.update!(update_hash)}.should_not change{hm.raw_data.clone[0]}
        end
      
        it "should return the updated records even if the primary key is the one changed" do
          update_field = :a
          update_to = "BBBB"
          update_hash = {update_field => update_to}
          hm.update!(update_hash).should == [
            {:a=>"BBBB", :b=>"7291", :c=>"0", :_id=>1, :_group_id=>1}, 
            {:a=>"BBBB", :b=>"080", :c=>"1", :_id=>2, :_group_id=>2}, 
            {:a=>"BBBB", :b=>"24134", :c=>2, :_id=>3, :_group_id=>3}
          ]
        end
      
        context "after changing the filtered field to something that doesn't match the filter in a destructive update" do
          update_field = :a
          update_to = "BBBB"
          update_hash = {update_field => update_to}
          it {hm.update!(update_hash); hm.length.should == 0}
        end
      end
       
    end
   
    context "when using non-destructive methods" do
      
      it {lambda{hm.update(:b__b2__b2b=>"potato")}.should_not change{hm.deep_clone}}
      
      it {lambda{hm.update_and_add(:b__b2__b2j=>"potato")}.should_not change{hm.deep_clone}}
      
    end
    
    context "when sending a filter with the update" do
      
      before(:each) do
        hm << {:a=>"17", :b=>"7291", :c=>"0"}
        hm << {:a=>"17", :b=>"080", :c=>"1"}
        hm << {:a=>"17", :b=>"24134", :c=>2}
      end
      
      it {hm.update("17", {:b=>3434}).should == [
        {:a=>"17", :b=>3434, :c=>"0", :_id=>1, :_group_id=>1}, 
        {:a=>"17", :b=>3434, :c=>"1", :_id=>2, :_group_id=>2}, 
        {:a=>"17", :b=>3434, :c=>2, :_id=>3, :_group_id=>3}]
      }
      
      it "should reset the original filter" do
        hm.update("17", {:b=>3434})
        hm.should == [
          {:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}, 
          {:a=>"17", :b=>"7291", :c=>"0", :_id=>1, :_group_id=>1}, 
          {:a=>"17", :b=>"080", :c=>"1", :_id=>2, :_group_id=>2}, 
          {:a=>"17", :b=>"24134", :c=>2, :_id=>3, :_group_id=>3}
        ]
        
      end
      
      
    end

    context "when the update field doesn't exist" do

      before(:each) do
        hm << {:a=>"17", :b=>"7291", :c=>"0"}
        hm << {:a=>"17", :b=>"080", :c=>"1"}
        hm << {:a=>"17", :b=>"24134", :c=>2}
      end

      it {lambda{hm.update({:parameter__type => String})}.should_not raise_error}
      it {hm.update(:parameter__type => String).should be_empty}

      context "and using a block variable search" do

        it "should not raise an error" do
          where = lambda {:a == "a"}
          param_type = String
          lambda{hm.update({:parameter__type => param_type}, &where)}.should_not raise_error
        end
      
        it "should return an empty recordset" do
          where = lambda {:a == "a"}
          param_type = String
          hm.update(:parameter__type => param_type, &where).should be_empty
        end
        
      end
      
    end
        
    context "when the search field doesn't exist" do

      before(:each) do
        hm << {:a=>"17", :b=>"7291", :c=>"0"}
        hm << {:a=>"17", :b=>"080", :c=>"1"}
        hm << {:a=>"17", :b=>"24134", :c=>2}
      end

      it {lambda{hm.update({:b=>"blorg"},lambda {:parameter__type == String})}.should_not raise_error}
      it {hm.update({:b=>"blorg"},lambda {:parameter__type == String}).should be_empty}

      context "and using a block variable search" do

        it "should not raise an error" do
          param_type = String
          where = lambda {:parameter__type == param_type}
          update_to_value = "g"
          update_to = {:a => update_to_value}
          lambda{hm.update(update_to, &where)}.should_not raise_error
        end
      
        it "should return an empty recordset" do
          param_type = String
          where = lambda {:parameter__type == param_type}
          update_to_value = "g"
          update_to = {:a => update_to_value}
          hm.update(update_to, &where).should be_empty
        end

      end

    end
        
    context "when the neither the search field nor the update field exist" do

      before(:each) do
        hm << {:a=>"17", :b=>"7291", :c=>"0"}
        hm << {:a=>"17", :b=>"080", :c=>"1"}
        hm << {:a=>"17", :b=>"24134", :c=>2}
      end

      it {lambda{hm.update({:g=>"blorg"},lambda {:parameter__type == String})}.should_not raise_error}
      it {hm.update({:g=>"blorg"},lambda {:parameter__type == String}).should be_empty}

      context "and using variables in the search and update" do

        it "should not raise an error" do
          param_type = String
          where = lambda {:flappidy == param_type}
          update_to_value = "malamute"
          update_to = {:puppies => update_to_value}
          lambda{hm.update(update_to, &where)}.should_not raise_error
        end
      
        it "should return an empty recordset" do
          param_type = String
          where = lambda {:zippidy__do__da == param_type}
          update_to_value = "delicious"
          update_to = {:goldfish => update_to_value}
          hm.update(update_to, &where).should be_empty
        end

      end

    end
    
  end

end