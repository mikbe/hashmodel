Feature: Search a HashModel using boolean logic
  In order to find records of interest
  As a programmer
  I want to specify an SQL like query string using boolean logic like:
  (something == "something" && something_else == 11) || more_stuff != String || extra_stuff.class == Potato

Background:
	Given we have a test table
		 | switch                      | description                           |
		 | :switch=>["-x","--xtended"] | :description=>"This is a description" |
		 | :switch=>"-y"               | :description=>"Why not?"              |
		 | :switch=>["-z","--zee"]     | :description=>"head for zee hills"    |

Scenario: Search using a parameter
  Given we have a HashModel instance
	  And the HashModel is populated with the test table 
   When we search with the single parameter "-x"
   Then the search recordset should look like
	 | id        | group_id         | switch        | description                           |
	 | :hm_id=>0 | :hm_group_id=> 0 | :switch=>"-x" | :description=>"This is a description" |

@active
Scenario: Search using a block of boolean logic
  Given we have a HashModel instance
	  And the HashModel is populated with the test table 
   When we search with the block {@switch == "-x"}
   Then the search recordset should look like
	 | id        | group_id         | switch        | description                           |
	 | :hm_id=>0 | :hm_group_id=> 0 | :switch=>"-x" | :description=>"This is a description" |




  
