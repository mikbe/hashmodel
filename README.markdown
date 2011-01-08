# HashModel

A simple MVC type model class for storing deeply nested hashes as records.
It's meant to be used for small, in-memory recordset that you want an easy, flexible way to query.
It is not meant as a data storage device for managing huge datasets.

Note: 
This is more of a programming exercise to learn about Ruby so if you're looking for a good
model class take a look at ActiveModel, it's probably more of what you're looking for.

## Synopsis

The major usefulness of this class is it allows you to filter and search flattened records based on any field.
A field can contain anything, including another hash, a string, and array, or even an Object class like String or Array, not
just an instance of an Object class.

You can also search using boolean like logic e.g.  
   
@hm = HashModel.new(:raw\_data=>@records)  
found = @hm.where {@switch == "-x" && @parameter\_type == String}  

## Usage



## Version History

0.2.0 
* Fixed bug if first field name is shorter version of another field name, e.g. :short then :shorter would cause an error.
* Added unflattening records and adding unflattened records.
* Changed field separator to double underscores (to allow unflattening)
* Removed namespace module, it was annoying. Now just instantiate it with HashModel.new instead of MikBe::HashModel.new
* Now allows a single hash, instead of an array of hashes, when creating with HashModel.new(:raw_data => hash)

0.1.1 Moved to new RubyGems account

0.1.0 Initial publish

== Contributing to hash\_model

* Please feel free to correct any mistakes I make by correcting the code and sending me a pull request. Pull requests are handled ASAP.
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project  
* Start a feature/bugfix branch  
* Commit and push until you are happy with your contribution  
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2010 Mike Bethany. See LICENSE.txt for further details.

