Feature: Flatten the HashModel
  In order to customize looping over the HashModel records
  As a programmer
  I want to be able to flatten the HashModel to one field
  Or flatten all fields

Background:
	Given we have a test table
		 | switch                      | description                           |
		 | :switch=>["-x","--xtended"] | :description=>"This is a description" |
		 | :switch=>"-y"               | :description=>"Why not?"              |
		 | :switch=>["-z","--zee"]     | :description=>"head for zee hills"    |

Scenario: Create a HashModel
	Given we have a HashModel instance
	 When the HashModel is populated with the test table 
   Then the flatten index should be :switch

Scenario: Change the flatten index
  Given we have a HashModel instance
	 When the HashModel is populated with the test table 
	  And the flatten index is set to :description
	 Then the flatten index should be :description

Scenario: Flatten input hashes to the default flatten index
  Given we have a HashModel instance
   When the HashModel is populated with the test table 
   Then the HashModel recordset should look like
	 | id        | group_id         | switch               | description                           |
	 | :_id=>0 | :_group_id=> 0 | :switch=>"-x"        | :description=>"This is a description" |
	 | :_id=>1 | :_group_id=> 0 | :switch=>"--xtended" | :description=>"This is a description" |
	 | :_id=>2 | :_group_id=> 1 | :switch=>"-y"        | :description=>"Why not?"              |
	 | :_id=>3 | :_group_id=> 2 | :switch=>"-z"        | :description=>"head for zee hills"    |
	 | :_id=>4 | :_group_id=> 2 | :switch=>"--zee"     | :description=>"head for zee hills"    |
