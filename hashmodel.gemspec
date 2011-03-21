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
  s.description = %q{A hash based MVC model class that makes searching and updating deeply nested hashes a breeze. You can store deeply nested hashes and still easily flatten, query, and update the records using flattened field names.}

  s.add_dependency "sourcify"
  s.add_dependency "file-tail"
  
  # After hassling with version dependency it makes more sense NOT to
  # declare version numbers and let it break if it is actually going
  # to break instead of having it break every single time even if it
  # wouldn't have broken with the new versions. Or maybe people need
  # to be looser with their versioning requiremetns. My 2 cents.
  #
  s.add_development_dependency "rspec"
  s.add_development_dependency "cucumber"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
