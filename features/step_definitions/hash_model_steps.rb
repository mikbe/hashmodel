Given /^we have a test table$/ do |table|
  @test_table = table
end

Given /^we have a HashModel instance$/ do
  @hm = MikBe::HashModel.new
end

When /^the HashModel is populated with the test table$/ do
  @test_table.rows.each do |record|
    @hm.add(array_to_hash(record))
  end
end

Then /^the flatten index should be :(.*)$/ do |index|
  @hm.flatten_index.should == index.to_sym
end

When /^the flatten index is set to :(.*)$/ do |index|
  @hm.flatten_index = index.to_sym
end

Then /^the flatten index should be nil$/ do
  @hm.flatten_index.should == nil
end

Then /^the HashModel recordset should look like$/ do |example_table|
  formatted_table = table_to_array(example_table)
  @hm.should == formatted_table
end

When /^the siblings are retrieved for a record with parameter "([^"]*)"$/ do |parameter|
  @siblings = @hm.group("#{parameter}")
end

Then /^all the siblings should have the same group id$/ do
  group_ids = []
  @siblings.each {|record| group_ids << record[:hm_group_id]}
  group_ids.uniq.length.should == 1
  group_ids.uniq[0].should_not == nil
end

When /^we search with the single parameter "([^"]*)"$/ do |parameter|
  @hm_search = @hm.where(parameter)
end

When /^we search with the block \{@switch == \"-x\"\}$/ do
  # I know, this is sloppy, I'm just trying to define the basic functionality
  # Real tests are in the RSpecs
  @hm_search = @hm.where{@switch == "-x"}
end


Then /^the search recordset should look like$/ do |table|
  test_table = table_to_array(table)
  @hm_search.each_with_index do |record, index|
    record.should == test_table[index]
  end
   
end
