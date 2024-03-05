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
	context "Numeric Range" do
      it "should test a simple range 1..3" do
        query_object = <<HERE
					<operator logic="range">
						<term field="simple-number" str="1" />
						<term field="simple-number" str="3" />
					</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(3)
      end
      
      it "should test a range with decimals 1.5..5.3" do
        query_object = <<HERE
					<operator logic="range">
						<term field="simple-number" str="1.5" />
						<term field="simple-number" str="5.3" />
					</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(4)
      end
 
      it "should test a range with one decimal and one integer 1.01..4" do
        query_object = <<HERE
					<operator logic="range">
						<term field="simple-number" str="1.01" />
						<term field="simple-number" str="4" />
					</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(3)
      end
 
      it "should test a range with one decimal and one integer 1.01..4" do
        query_object = <<HERE
					<operator logic="range">
						<term field="simple-number" str="1.01" />
						<term field="simple-number" str="4" />
					</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(3)
      end
      
      it "should test a range with one decimal and one integer -1...5" do
        query_object = <<HERE
					<operator logic="range">
						<term field="simple-number" str="-1" />
						<term field="simple-number" str=".5" />
					</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(4)
      end      
       
    end	# End Numeric Range Context
end
