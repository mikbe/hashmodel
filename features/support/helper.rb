module HashModelHelpers
  # converts ugly arrays from Cucumber::AST::Tables into nice neat hashes
  def array_to_hash(array)
    hash = {}
    array.each { |field| eval("hash.merge!({#{field}})") }
    hash
  end
  
  # wrapper for converting Cucumber::AST::Tables into an array of nice neat hashes 
  def table_to_array(input_table)
    table_of_hashes = []
    input_table.rows.each do |record|
      table_of_hashes << array_to_hash(record)
    end
    table_of_hashes
  end
end
World(HashModelHelpers)