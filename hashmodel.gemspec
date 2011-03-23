# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hash_model/version"

Gem::Specification.new do |s|
  s.name                    = "hashmodel"
  s.version                 = HashModel::VERSION::STRING
  s.platform                = Gem::Platform::RUBY
  s.required_ruby_version   = '>= 1.9.2'
  s.authors                 = ["Mike Bethany"]
  s.email                   = ["mikbe.tk@gmail.com"]
  s.homepage                = "http://mikbe.tk"
  s.summary                 = %q{A hash based MVC model class that makes searching and updating deeply nested hashes a breeze.}
  s.description             = 
"""
A hash based MVC model class that makes searching and updating deeply nested hashes a breeze.
You can store deeply nested hashes and still easily flatten, query, and update the records using flattened field names.
It's meant to be used for small, in-memory recordset that you want an easy, flexible way to query.
It is not meant as a data storage device for managing huge datasets.
"""

  s.license                 = 'MIT'
  
  s.add_dependency "sourcify", "~>0.4"
  s.add_dependency "file-tail", "~>1.0"

  s.add_development_dependency "rspec", "~>2.5"
  s.add_development_dependency "cucumber", "~>0.3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/**/*`.split("\n")
  s.require_paths = ["lib"]
end
