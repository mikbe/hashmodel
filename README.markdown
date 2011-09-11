#Hashmodel
A hash based data model that makes creating, searching, and updating small datasets a breeze.

##What does it do?
Hashmodel is perfect for dealing with small, in-memory recordset like parsing command line options or storing user preferences for your application.  

But its real power lies in how it allows you to treat deeply nested fields as if they were a top-level field with little to no effort on your part.  

##Versioning
Hashmodel uses [semantic versioning](http://semver.org/) with all that implies. Most importantly it should be noted that this is currently a pre-1.0.0 release so the interface can and will change dramatically between beta versions.  

##Important update notes
With semantic versioning in mind this is a complete rewrite from HashModel 4.0 and is aiming to be a true beta for the Hashmodel 1.0.0 release. I will strive to keep interface changes between 0.9.0 and 1.0.0 to a bare minimum.  

##Why the big re-write?
Quite frankly HashModel 0.4.0 is terrible code and a horrible design. I want to take what I've learned over the last year and see if I can implement some better design decisions.  

##HashModel vs. Hashmodel
That isn't a typo, I'm changing the name of the class for a few reasons:  

* I kept mistyping it as Hashmodel so why not use what seems more natural?
* I want to highlight the change from HashModel 0.4.0 to Hashmodel 0.9.0 and beyond.
* I'm doing a total interface redesign. If you try to use Hashmodel 0.9.0 with code that requires HashModel 0.4.0 I want it to fail so you can't accidentally use the wrong one.