# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hash_model/version"

Gem::Specification.new do |s|
  s.name                    = "hashmodel"
  s.version                 = Hashmodel.VERSION
  s.platform                = Gem::Platform::RUBY
  s.required_ruby_version   = '>= 1.9.2'
  s.authors                 = ["Mike Bethany"]
  s.email                   = ["mikbe.tk@gmail.com"]
  s.homepage                = "http://mikbe.tk"
  s.summary                 = %q{A hash based data model that makes creating, searching, and updating small datasets a breeze.}
  s.description             = 
"""
A hash based data model that makes creating, searching, and updating small datasets a breeze.  
It's perfect for dealing with small, in-memory recordset like parsing command line options or storing user preferences for your application.  
Hashmodel's real power lies in how it allows you to treat deeply nested fields as if they were a top-level field with little to no effort on your part.
"""

  s.license                 = 'MIT'

  s.add_development_dependency "minitest", "~>2.5"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/**/*`.split("\n")
  s.require_paths = ["lib"]
end
