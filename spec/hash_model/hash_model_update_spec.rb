require "spec_helper"

describe HashModel do

  context "when updating records" do
  
    context "and doing it destructively" do
      it "should update the raw records" do
        lambda{@hm.update!("-x", :parameter__type => Fixnum)}.should change{@hm.deep_clone}
      end
    end

    let(:hm){HashModel.new(:raw_data=> {:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a =>"b2a", :b2b=>"b2b"}}} )}

    context "and the search key exists in the target" do

      it "should update the value properly" do
        update = {:b__b2__b2b=>"potato"}
        lambda{hm.update(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"potato"}}, :_id=>0, :_group_id=>0}])
      end

      it "should update a mid-level hash" do
        update = {:b__b2=>"potato"}
        lambda{hm.update(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"a", :b=>{:b1=>"b1", :b2=>"potato"}, :_id=>0, :_group_id=>0}])
      end

      it "should update a multiple update hashes at once" do
        update = {:b__b2=>"potato", :a=>"blorg", :b__b1=>"fish"}
        lambda{hm.update(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"blorg", :b=>{:b1=>"fish", :b2=>"potato"}, :_id=>0, :_group_id=>0}])
      end

      it "should update with a hash as the value" do
        update = {:b__b2=>{:d=>"d"}}
        lambda{hm.update(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:d=>"d"}}, :_id=>0, :_group_id=>0}])
      end

      it "should update with an array as the value" do
        update = {:b__b2=>[1,2,3]}
        lambda{hm.update(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"a", :b=>{:b1=>"b1", :b2=>[1,2,3]}, :_id=>0, :_group_id=>0}])
      end

    end

    context "but the search key does NOT exist in the target" do

      it "should NOT by default add a field" do
        update = {:b__b2__b2c=>"potato"}
        lambda{hm.update(update)}.should_not change{hm.deep_clone}
      end

      it "should add a field if told to do so (by using update_and_add)" do
        update = {:b__b2__b2c=>"potato"}
        lambda{hm.update_and_add(update)}.should change{hm.deep_clone}
          .from([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}])
          .to([{:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"b2b", :b2c=>"potato"}}, :_id=>0, :_group_id=>0}])
      end

    end
  
    context "when there is something other than a hash in the value of a target hash" do
      
      it "should stop for that record but not raise an error" do
        hm << {:a=>"17", :b=>"1870"}
        update = {:b__b2__b2b=>"potato"}
        lambda{hm.update(update)}.should_not raise_error
      end
      
    end

    context "when successful" do
      
      it "should return the changed recordset" do
        hm << {:a=>"17", :b=>"1870"}
        update = {:b__b2__b2b=>"potato"}
        hm.update(update).should == [
          {:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"potato"}}, :_id=>0, :_group_id=>0}, 
          {:a=>"17", :b=>{:b2=>{:b2b=>"potato"}}, :_id=>1, :_group_id=>1}
        ]
      end
      
    end
  
  end
end