require 'spec_helper'
  
describe HashModel do

  context "when adding records" do

    it "should allow a hash of values to be added" do
      proc { @hm << {:switch => ["-x", "--xtended"], :description => "Xish stuff"} }.should_not raise_error
    end

    it "should allow a single hash to be added with :raw_data" do
      hash = {:switch => ["-x", "--xtended"], :description => "Xish stuff"}
      @hm = HashModel.new(:raw_data => hash)
      @hm.raw_data.should == [{:switch=>["-x", "--xtended"], :description=>"Xish stuff"}]
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
    
    it "should add a hash with a symbol as a value" do
      @hm = HashModel.new
      @hm << {:switch => :default}
      @hm.should == [{:switch=>:default, :_id=>0, :_group_id=>0}]
    end
     
    it "should add an array with mixed value types" do
      @records = [
        {:switch => ["-x", "--xtended", :default], :parameter => {:type => String, :required => true}, :description => "Xish stuff"},
        {:switch => ["-y", "--why"],  :description => "lucky what?"},
        {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},
      ]
      @hm = HashModel.new(:raw_data=>@records)
      @hm.should == [
        {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0}, 
        {:switch=>:default, :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>2, :_group_id=>0},
        {:switch=>"-y", :description=>"lucky what?", :_id=>3, :_group_id=>1}, 
        {:switch=>"--why", :description=>"lucky what?", :_id=>4, :_group_id=>1}, 
        {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>5, :_group_id=>2}
      ]
    end
    
    it "should add an array of arrays as values and not recurse into them" do
        @records = [
          { :switch => [ [5, 6], [1, 2] ] }
        ]
        @hm = HashModel.new(:raw_data=>@records)
        @hm.should == [{:switch=>[5, 6], :_id=>0, :_group_id=>0}, {:switch=>[1, 2], :_id=>1, :_group_id=>0}]
    end
    
    it "shouldn't recurse into arrays with hash values" do
        @records = [
          { :switch => [ [5, 6], [1, :blah=>2] ] }
        ]
        @hm = HashModel.new(:raw_data=>@records)
        @hm.should == [{:switch=>[5, 6], :_id=>0, :_group_id=>0}, {:switch=>[1, :blah=>2], :_id=>1, :_group_id=>0}]
    end
    
    it "should allow an array of HashModels to be added" do
      @hm.add([@hm, @hm2])
      @hm.should == [
        {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0}, 
        {:switch=>"-y", :description=>"lucky what?", :_id=>2, :_group_id=>1}, 
        {:switch=>"--why", :description=>"lucky what?", :_id=>3, :_group_id=>1}, 
        {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>4, :_group_id=>2}, 
        {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>5, :_group_id=>3}, 
        {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>6, :_group_id=>3}, 
        {:switch=>"-y", :description=>"lucky what?", :_id=>7, :_group_id=>4}, 
        {:switch=>"--why", :description=>"lucky what?", :_id=>8, :_group_id=>4}, 
        {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>9, :_group_id=>5}, 
        {:switch=>"-p", :parameter=>{:type=>Hash, :required=>false}, :description=>"Pea soup", :_id=>10, :_group_id=>6}, 
        {:switch=>"--pea", :parameter=>{:type=>Hash, :required=>false}, :description=>"Pea soup", :_id=>11, :_group_id=>6}, 
        {:switch=>"-q", :description=>"exit the game", :_id=>12, :_group_id=>7}, 
        {:switch=>"--quit", :description=>"exit the game", :_id=>13, :_group_id=>7}, 
        {:switch=>"-r", :parameter=>{:type=>Fixnum}, :description=>"Arrrrrrrrrrgh!", :_id=>14, :_group_id=>8}
      ]
    end
    
    it "should allow field names that are longer versions of other names" do
      @hm = HashModel.new
      @hm << {:long => "short", :longer => "long"}
      @hm.should == [{:long => "short", :longer => "long"}]
    end
    
    it "should raise an error if something other than a hash, an array of hashes, or another HashModel (or an array of them) is added" do
      proc { @hm << ["-x", "--xtended", "Xish stuff"] }.should raise_error
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
      @hm = HashModel.new
      @hm << @records[0] << @records[1] <<@records[2]
      @hm.raw_data.should == @records
    end

    context "flattened records" do
    
      it "should allow a flattened record to be added" do
        @hm = HashModel.new
        @hm << {:switch=>"-x", :parameter__type=>String, :parameter__required=>true, :description=>"Xish stuff"}
        @hm.raw_data.should == [{:switch => "-x", :parameter => {:type => String, :required => true}, :description => "Xish stuff"}]
      end

      it "should allow a flattened record to be added even with arrays in it" do
        @hm = HashModel.new
        @hm << {:switch=>["-x", "--xtend"], 
                  :parameter__type=>String, 
                  :parameter__required=>true, 
                  :description=>"Xish stuff", 
                  :field__field2 => {:field3 => "ff3", :field4 => "ff4"}
               }
        @hm.raw_data.should == [ 
                                {
                                    :switch => ["-x", "--xtend"], 
                                    :parameter => {:type => String, :required => true}, 
                                    :description => "Xish stuff", 
                                    :field => {:field2 => {:field3 => "ff3", :field4 => "ff4"}}
                                 }
                               ]
      end
      
      it "should allow deeply flattened record to be added" do
        deep_hash =  { 
          :parameter__type=>String,
          :switch__deep1__deep3 => "deepTwo",
          :parameter__type__ruby=>true,
          :parameter => "glorp",
          :parameter__required=>true,
          :switch__deep2 => "deepTwo",
          :description=>"Xish stuff",
          :switch => "--xtend",
        }
        @hm = HashModel.new
        @hm << deep_hash
        @hm.raw_data.should == [
          {
            :parameter => [
              {:type=>String}, 
              "glorp", 
              {:required=>true}
            ], 
            :switch => [
              {:deep1 => {:deep3=>"deepTwo"}},
              {:deep2=>"deepTwo"}, 
              "--xtend"
            ], 
            :description=>"Xish stuff"
          }
        ] 
      end
      
      
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
          {:switch=>["-x", "--xtended"], :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff"}, 
          {:switch=>["-y", "--why"], :description=>"lucky what?"}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz"},
          {:switch=>["-x", "--xtended"], :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff"}, 
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
          {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0}, 
          {:switch=>"-y", :description=>"lucky what?", :_id=>2, :_group_id=>1}, 
          {:switch=>"--why", :description=>"lucky what?", :_id=>3, :_group_id=>1},
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>4, :_group_id=>2}, 
          {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>5, :_group_id=>3}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>6, :_group_id=>3}, 
          {:switch=>"-y", :description=>"lucky what?", :_id=>7, :_group_id=>4}, 
          {:switch=>"--why", :description=>"lucky what?", :_id=>8, :_group_id=>4}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>9, :_group_id=>5}
        ]
      end
      
    end

    context "using concat" do
      
      it "should concatinate using a single Hash" do
        @hm.concat(@records2[0]).should == [
          {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0}, 
          {:switch=>"-y", :description=>"lucky what?", :_id=>2, :_group_id=>1}, 
          {:switch=>"--why", :description=>"lucky what?", :_id=>3, :_group_id=>1}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>4, :_group_id=>2}, 
          {:switch=>"-p", :parameter=>{:type=>Hash, :required=>false}, :description=>"Pea soup", :_id=>5, :_group_id=>3}, 
          {:switch=>"--pea", :parameter=>{:type=>Hash, :required=>false}, :description=>"Pea soup", :_id=>6, :_group_id=>3}
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
          {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}, 
          {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0}, 
          {:switch=>"-y", :description=>"lucky what?", :_id=>2, :_group_id=>1}, 
          {:switch=>"--why", :description=>"lucky what?", :_id=>3, :_group_id=>1}, 
          {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>4, :_group_id=>2}, 
          {:switch=>"-p", :parameter=>{:type=>Hash, :required=>false}, :description=>"Pea soup", :_id=>5, :_group_id=>3}, 
          {:switch=>"--pea", :parameter=>{:type=>Hash, :required=>false}, :description=>"Pea soup", :_id=>6, :_group_id=>3}
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

end