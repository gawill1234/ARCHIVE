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
	context "Numeric Not" do
      
    it "should find six results less than 1.0000000000" do
       query_object = <<HERE
				<operator logic="less-than">
					<term field="simple-number" str="1.0000000000" />
				</operator>
HERE
	    answer = $xpath_source.search(query_object)
	    doc_count(answer).should eql(6)
    end
    
    it "should find seven results less than 1.0000000001" do
        query_object = <<HERE
				<operator logic="less-than">
					<term field="simple-number" str="1.0000000001" />
				</operator>
HERE
	    answer = $xpath_source.search(query_object)
	    doc_count(answer).should eql(7)   
    end
   
    it "should find six results less than or equal 1.0000000000" do
       query_object = <<HERE
				<operator logic="less-than-or-equal">
					<term field="simple-number" str="1.0000000000" />
				</operator>
HERE
	    answer = $xpath_source.search(query_object)
	    doc_count(answer).should eql(7)
    end
    
    it "should find seven results less than or equal 1.0000000001" do
        query_object = <<HERE
				<operator logic="less-than-or-equal">
					<term field="simple-number" str="1.0000000001" />
				</operator>
HERE
	    answer = $xpath_source.search(query_object)
	    doc_count(answer).should eql(7)   
    end
    
    it "should find five results less than 1.000000000E-23 " do
       query_object = <<HERE
				<operator logic="greater-than">
					<term field="simple-number" str="1.000000000E-23 " />
				</operator>
HERE
	    answer = $xpath_source.search(query_object)
	    doc_count(answer).should eql(6)
    end

    it "should find 7 results less than -0.000000000E-23 " do
        query_object = <<HERE
				<operator logic="greater-than">
					<term field="simple-number" str="-0.000000001E-23"  />
				</operator>
HERE
	    answer = $xpath_source.search(query_object)
	    doc_count(answer).should eql(7)   
    end   
    
    it "should find 7 results greater than or equal  -0.000000000E-23 " do
        query_object = <<HERE
				<operator logic="greater-than-or-equal">
					<term field="simple-number" str="-0.000000001E-23"  />
				</operator>
HERE
	    answer = $xpath_source.search(query_object)
	    doc_count(answer).should eql(7)   
    end   
       
  end	# End Numeric Range Context
end
