require "spec_helper"

describe HashModel do

  context "when updating records" do

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

      it "should only return records that are changed" do
        hm << {:a=>"17", :b=>"1870"}
        update = {:b__b2__b2b=>"potato"}
        hm.update(update).should == [
          {:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a=>"b2a", :b2b=>"potato"}}, :_id=>0, :_group_id=>0} 
        ]
      end

    end
     
  end

end