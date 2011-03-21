require 'hashmodel'

RSpec.configure do |config|
  config.before(:each) do

    @records = [
      {:switch => ["-x", "--xtended"], :parameter => {:type => String, :required => true}, :description => "Xish stuff"},
      {:switch => ["-y", "--why"],  :description => "lucky what?"},
      {:switch => "-z",  :parameter => {:type => String}, :description => "zee svitch zu moost calz"},
    ]
    @hm = HashModel.new(:raw_data=>@records)

    @records2 = [
      {:switch => ["-p", "--pea"], :parameter => {:type => Hash, :required => false}, :description => "Pea soup"},
      {:switch => ["-q", "--quit"],  :description => "exit the game"},
      {:switch => "-r",  :parameter => {:type => Fixnum}, :description => "Arrrrrrrrrrgh!"},
    ]
    @hm2 = HashModel.new(:raw_data=>@records2)
    
    @flat_records = [
      {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}, 
      {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0}, 
      {:switch=>"-y", :description=>"lucky what?", :_id=>2, :_group_id=>1}, 
      {:switch=>"--why", :description=>"lucky what?", :_id=>3, :_group_id=>1}, 
      {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>4, :_group_id=>2}
    ]
    
    @flat_records2 =[
      {:switch=>"-p", :parameter=>{:type=>Hash, :required=>false}, :description=>"Pea soup", :_id=>0, :_group_id=>0},
      {:switch=>"--pea", :parameter=>{:type=>Hash, :required=>false}, :description=>"Pea soup", :_id=>1, :_group_id=>0},
      {:switch=>"-q", :description=>"exit the game", :_id=>2, :_group_id=>1},
      {:switch=>"--quit", :description=>"exit the game", :_id=>3, :_group_id=>1},
      {:switch=>"-r", :parameter=>{:type=>Fixnum}, :description=>"Arrrrrrrrrrgh!", :_id=>4, :_group_id=>2}
    ]
    
    @flat_records_all = [
      {:switch=>"-x", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>0, :_group_id=>0}, 
      {:switch=>"--xtended", :parameter=>{:type=>String, :required=>true}, :description=>"Xish stuff", :_id=>1, :_group_id=>0}, 
      {:switch=>"-y", :description=>"lucky what?", :_id=>2, :_group_id=>1}, 
      {:switch=>"--why", :description=>"lucky what?", :_id=>3, :_group_id=>1}, 
      {:switch=>"-z", :parameter=>{:type=>String}, :description=>"zee svitch zu moost calz", :_id=>4, :_group_id=>2}, 
      {:switch=>"-p", :parameter=>{:type=>Hash, :required=>false}, :description=>"Pea soup", :_id=>5, :_group_id=>3}, 
      {:switch=>"--pea", :parameter=>{:type=>Hash, :required=>false}, :description=>"Pea soup", :_id=>6, :_group_id=>3}, 
      {:switch=>"-q", :description=>"exit the game", :_id=>7, :_group_id=>4}, 
      {:switch=>"--quit", :description=>"exit the game", :_id=>8, :_group_id=>4}, 
      {:switch=>"-r", :parameter=>{:type=>Fixnum}, :description=>"Arrrrrrrrrrgh!", :_id=>9, :_group_id=>5}
    ]

  end
end