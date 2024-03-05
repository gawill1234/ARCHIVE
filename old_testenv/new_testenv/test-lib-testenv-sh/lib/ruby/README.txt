= Ruby Velocity API
= Extracted from the UX-QA git repository
===============================================================================

== Overview ==
This provides access to Velocity from the Ruby Programming language and is
combined with RSpecto create Unit and Functional Tests using the Velocity API. 

== Misc ==

== To Do ==

* Make a wiki page explaining how to use this library
* Describe in detail the required gems and dependencies
* Modify the env.setup to include a RUBYLIB environment variable
* Lots more...

== Setup ==
Before you can use the API with the Regression test suite you must 
configure and run the appropriate setup file from the env.setup folder 
in the library.

  1. Go to testenv/lib/env.setup/
  2. Open "common" and make any necessary changes
  3. From the testenv folder run . env.setup/{desired work environment}
  	 Ex. . env.setup/7.5testbed10
  
  4. Type 'make'
  5. Type 'testtest' to ensure that your environment is correctly working
  
If you just want to use the Ruby library without the rest of the 
regression test suite, edit the setup file in this directory to fit
your desired environment and run the setup file.

	Ex: . setup
	
== Usage ==
When creating a new test follow the current Regression test rules that can be
found at: https://meta.vivisimo.com/wiki/Automatic_Tests_for_QA

To run a test:

		$ spec -c filename


== File Structure ==
ruby
|--examples         # Example spec files to demonstrate different testing methods
|--helpers          # General test_helper.rb along with specific helpers for each spec
|--lib              # Velocity API and other helper classes
`--test_plans       # Text files for manual tests or plans prior to writing automated tests 

== Testing methodology ==

See "The Way of Testivus": http://www.artima.com/weblogs/viewpost.jsp?thread=203994
