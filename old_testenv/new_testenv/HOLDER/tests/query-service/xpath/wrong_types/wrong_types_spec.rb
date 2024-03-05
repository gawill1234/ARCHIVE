$LOAD_PATH << ENV['RUBYLIB']
troot = ENV['TEST_ROOT']
usethis = troot + '/tests/query-service/xpath/helpers/xpath_helpers'
require 'loader'
require usethis


include Velocity

#
# XPath Operator Tests
#
describe "XPath Operator" do
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
	
	#---------------------------------------------------------------------------#
	#
	# Apply the not operator to string values to ensure proper behavior.
	#
	#---------------------------------------------------------------------------#
	context "Wrong Types" do
    #
    # Compare integers to strings and dates
    #  
    it "should find no results for $year < Hello there" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year &lt; Hello there" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    #
    #  
    it "should find no results for $year <= Apple" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year &lt;= Apple" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    #
    #
    it "should find no results for $year = 1990/10/28" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year = 1990/10/28" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    #
    #
     it "should find no results for $year > Elvis" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year > Elvis" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    #
    #
    it "should find no results for $year >= Banana" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year >= Banana" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    # Invalid logic
    #
    it "should find no results for logic='Nestle'" do
      query_object = <<HERE
      	<operator logic="nestle">
      		<term field="hero" str="Finn" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    #
    #
    it "should find no results for logic='Nestle'" do
      query_object = <<HERE
      	<operator logic="and">
		    	<operator logic="nestle">
		    		<term field="hero" str="Finn" />
		    	</operator>
		    	<operator logic="less-than">
		    		<term field="year" str="2000" />
		    	</operator>
		   	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    #
    #
    it "should find no results for logic='Nestle'" do
      query_object = <<HERE
      	<operator logic="and">
		    	<operator logic="fewer-than">
		    		<term field="year" str="1999" />
		    	</operator>
		    	<operator logic="more-than">
		    		<term field="year" str="2000" />
		    	</operator>
		   	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
		#
		# Dates
		#
    it "should find no results for logic='Nestle'" do
      query_object = <<HERE
      	<operator logic="and">
		    	<operator logic="less-than">
		    		<term field="year" str="1999/11/08" />
		    	</operator>
		    	<operator logic="greater-than">
		    		<term field="year" str="2000/02/28" />
		    	</operator>
		   	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    
	end	# End String Not Context
end
