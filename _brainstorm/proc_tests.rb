require 'sourcify'
@x = "x"
@y = "y"

search = proc{:x == "x" && :y == "y"}

@filter = search.to_source.match(/^proc { \((.*)\) }$/)[1]
puts "new_search: \"#{@filter}\""
puts "\nRun Eval"
puts instance_eval("proc { (#{@filter}) }.call".gsub(":", "@"))




