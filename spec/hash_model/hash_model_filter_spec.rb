require "spec_helper"

describe HashModel do

  let(:hm){
    HashModel.new(:raw_data=> [
        {:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a =>"b2a", :b2b=>"b2b"}}},
        {:a=>"17", :b=>"7291", :c=>"0"},
        {:a=>"17", :b=>"080", :c=>"1"},
        {:a=>"17", :b=>"24134", :c=>2}
      ]
    )
  }

  context "when using a block" do

    it "should accept a block variable" do
      where = lambda {:a == "a"}
      lambda{hm.filter &where}.should change{hm.clone}
      .from( [
          {:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a =>"b2a", :b2b=>"b2b"}}},
          {:a=>"17", :b=>"7291", :c=>"0"},
          {:a=>"17", :b=>"080", :c=>"1"},
          {:a=>"17", :b=>"24134", :c=>2}
        ]
      )
      .to( [
          {:a=>"a", :b=>{:b1=>"b1", :b2=>{:b2a =>"b2a", :b2b=>"b2b"}}, :_id=>0, :_group_id=>0}
        ]
      )
    end
  
  end

end