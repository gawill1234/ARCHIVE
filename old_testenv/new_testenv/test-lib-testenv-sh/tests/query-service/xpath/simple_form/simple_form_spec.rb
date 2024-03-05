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
	context "Simple form" do
    #
    # Simple Form Strings
    #  
    it "should find 11 results for $year > 1990" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year > 1990" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(11)
    end
    #
    # 
    #  
    it "should find 2 results for $year >= 2000" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year >= 2000" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(2)
    end
    #
    #
    #
    it "should find 4 results for $hero = 'Sid Halley'" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$hero = 'Sid Halley'" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(4)
    end
    #
    #
    #
    it "should find 39 results for $hero != 'Sid Halley'" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$hero != 'Sid Halley'" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(39)
    end
    #
    #
    #
    it "should find 1 result for $hero = 'Rob Finn'" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$hero = 'Rob Finn'" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(1)
    end
    #
    #
    #
    it "should find 0 results for $hero = 'rob finn'" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$hero = 'rob finn'" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    #
    #
    it "should find 0 results for $hero >= 'rob fINN'" do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$hero = 'rob finn'" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)
    end
    #
    # Simple form Numbers
    #
    it "should find 1 result for $year > 2000 " do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year > 2000" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(1)
    end
    #
    #
    #
    it "should find 2 result for $year >= 2000 " do
      query_object = <<HERE
      	<operator logic="and">
      		<term field="v.condition-xpath" str="$year >= 2000" />
      	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(2)
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
    it "should find 36 results for $year <= 1995 " do
      query_object = <<HERE
				<operator logic="and">
					<term field="v.condition-xpath" str="$year &lt;= 1995" input-type="system" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(36)
    end
    #
    #
    #
    it "should find 31 results for $year < 1990 " do
      query_object = <<HERE
				<operator logic="and">
					<term field="v.condition-xpath" str="$year &lt; 1990" input-type="system" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(30)
    end
           
	end	# End String Not Context
end
