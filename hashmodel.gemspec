# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hash_model/version"

Gem::Specification.new do |s|
  s.name        = "hashmodel"
  s.version     = HashModel::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mike Bethany"]
  s.email       = ["mikbe.tk@gmail.com"]
  s.homepage    = "http://github.com/mikbe/hashmodel"
  s.summary     = %q{Store nested hashes as records and easily search them (even nested ones)}
  s.description = %q{A simple MVC type model class for storing records based on nested hashes as an array of hashes. You can store deeply nested hashes and still easily flatten and query the records using flattened field names.}

  s.add_dependency "sourcify"
  s.add_dependency "file-tail"
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "cucumber"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
