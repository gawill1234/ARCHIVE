# simple_form_spec.rb

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
    puts "Testing Simple form"
  end
  after(:all) do
    puts "\nDone\n"
  end
	#---------------------------------------------------------------------------#
	# Prepare the test environment. In order to run the tests, a connection
	# must be made with the 'test-xpath-operator2' source, the query service
	# must be started, and a clean crawl of the 'test-xpath-operator2' source
	# should be run.
	#---------------------------------------------------------------------------#
	context "Setup" do
		it "should connect with an instance of Velocity" do
			@vapi.should_not be_nil
		end

		it "should get a handle to the xpath source" do
			# Source to query for most of the tests
			$xpath_source = Source.new(@vapi, 'test-xpath-operator2')
		end

		it "should start the query service" do
			qs = QueryService.new(@vapi)
			status = qs.start
			status.should_not be_nil
		end

		it "should cleanly crawl xpath-operator-testing" do
			coll_xo = Collection.new(@vapi, 'test-xpath-operator2')
			status = coll_xo.clean_crawl
			status.should eql("stopped")		
		end
	end # End Setup Context
	
  context "Simple form" do
    #
    # Simple Form Strings
    #  
    it "should find 29 results for $year > 1990" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year > 1990" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(29)
    end
    #
    # 
    #  
    it "should find 19 results for $year >= 2000" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year >= 2000" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(19)
    end
    #
    #
    #
    it "should find 4 results for $hero = 'Tommy Flat'" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$hero = 'Tommy Flat'" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(4)
    end
    #
    #
    #
    it "should find 38 results for $hero != 'Tommy Flat'" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$hero != 'Tommy Flat'" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(38)
    end
    #
    #
    #
    it "should find 1 result for $hero = 'John Pyle'" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$hero = 'John Pyle'" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(1)
    end
    #
    #
    #
    it "should find 0 results for $hero = 'john pyle'" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$hero = 'john pyle'" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    #
    #
    it "should find 0 results for $hero >= 'john pYLE'" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$hero = 'john pYLE'" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    # Simple form Numbers
    #
    it "should find 1 result for $year > 2005 " do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year > 2005" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(1)
    end
    #
    #
    #
    it "should find 3 result for $year >= 2005 " do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year >= 2005" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end
    #
    #
    #
    it "should find 1 result for $year == 1999 " do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year = 1999" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(1)
    end    
    #
    #
    #
    it "should find 17 results for $year <= 1995 " do
      query_object = <<HERE
	<operator logic="and">
	  <term field="v.condition-xpath" str="$year &lt;= 1995" input-type="system" />
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(17)
    end
    #
    #
    #
    it "should find 11 results for $year < 1990 " do
      query_object = <<HERE
	<operator logic="and">
	  <term field="v.condition-xpath" str="$year &lt; 1990" input-type="system" />
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(11)
    end
           
  end	# End Simple Form Context
end
