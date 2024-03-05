# date_range_spec.rb

$LOAD_PATH << ENV['RUBYLIB']
$LOAD_PATH << '.'
require 'loader'
require 'xpath_helpers'

include Velocity

#
# XPath Operator Tests
#
describe "XPath Operator" do
  before(:all) do
    puts "Testing Date Range" 
  end
  after(:all) do
    puts "\nDone\n"
  end
#---------------------------------------------------------------------------#
# Prepare the test environment. In order to run the tests, a connection
# must be made with the 'xpath-operator-testing' source, the query service
# must be started, and a clean crawl of the 'xpath-operator-testing' source
# should be run.
#---------------------------------------------------------------------------#
  context "Setup" do
    it "should connect with an instance of Velocity" do
      @vapi.should_not be_nil
    end
    
    it "should get a handle to the xpath source" do
      # Source to query for most of the tests
      $xpath_source = Source.new(@vapi, 'xpath-operator-testing')
    end

    it "should start the query service" do
      qs = QueryService.new(@vapi)
      status = qs.start
      status.should_not be_nil
    end

    it "should cleanly crawl xpath-operator-testing" do
      coll_xo = Collection.new(@vapi, 'xpath-operator-testing')
      status = coll_xo.clean_crawl
      status.should eql("stopped")		
    end
  end # End Setup Context
	
#---------------------------------------------------------------------------#
#
# Apply the range operator to date values to ensure proper behavior.
#
#---------------------------------------------------------------------------#
  context "Date Range" do
    it "should test the range operator over a leap year 
      		- 3 documents between 2/28 and 3/01" do
      query_object = <<HERE
	<operator logic="range">
	<term field="simple-date" str="2000/02/28" />
	<term field="simple-date" str="2000/03/01" />
        </operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end

    it "should test the range operator over years 
    		- 3 documents between 2003 and 2005" do
      query_object = <<HERE
	<operator logic="range">
	<term field="simple-date" str="2003-09-12 20:49:36" />
	<term field="simple-date" str="2005-11-12 20:49:38" />
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end

    it "should test the range operator over months 
      		- 3 documents between 2006-09 and 2006-11" do
      query_object = <<HERE
	<operator logic="range">
	<term field="simple-date" str="2006-09-12 20:49:36" />
	<term field="simple-date" str="2006-11-12 20:49:38" />
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end

    it "should test the range operator over months with dates that 
      		are different-looking than they are on the actual document 
      		- 3 documents between 2006-09 and 2006-11" do
      query_object = <<HERE
        <operator logic="range">
	<term field="simple-date" str="2006/04/01" />
	<term field="simple-date" str="2006/11/13" />
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end

    it "should test the range operator over days 
      		- 3 documents between 2007-10-10 and 2007-10-12" do
      query_object = <<HERE
	<operator logic="range">
	<term field="simple-date" str="2007-10-10" />
	<term field="simple-date" str="2007-10-12 20:49:38" />
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end

    it "should test the range operator over days with a wider space 
    		around them -  3 documents between 2007 and 2008" do
      query_object = <<HERE
	<operator logic="range">
	<term field="simple-date" str="2007" />
	<term field="simple-date" str="2008" />
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end

    it "should test the range operator over days while excluding one 
     		by just one second -  2 documents between 2007-10-10 and 
      		2007-10-12 20:49:37" do
      query_object = <<HERE
        <operator logic="range">
	<term field="simple-date" str="2007-10-10" />
	<term field="simple-date" str="2007-10-12 20:49:37" />
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(2)
    end

    it "should test the range operator over seconds 
      		- 3 documents between 2008-10-12 20:49:36 and2008-10-12 20:49:38" do
      query_object = <<HERE
	<operator logic="range">
	<term field="simple-date" str="2008-10-12 20:49:36" />
	<term field="simple-date" str="2008-10-12 20:49:38" />
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end
  end	# End Date Range Context
    
end
