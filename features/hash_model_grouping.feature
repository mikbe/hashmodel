Feature: Return the siblings of a flattened record
  In order to identify all the records created from a single raw record
  As a programmer
  I want to easily retrieve any records within the same group as a flattened record.	


Background:
	Given we have a test table
		 | switch                      | description                           |
		 | :switch=>["-x","--xtended"] | :description=>"This is a description" |
		 | :switch=>"-y"               | :description=>"Why not?"              |
		 | :switch=>["-z","--zee"]     | :description=>"head for zee hills"    |
  
Scenario: Get siblings for a record
Given we have a HashModel instance
 When the HashModel is populated with the test table 
  And the siblings are retrieved for a record with parameter "-y"
 Then all the siblings should have the same group id 
