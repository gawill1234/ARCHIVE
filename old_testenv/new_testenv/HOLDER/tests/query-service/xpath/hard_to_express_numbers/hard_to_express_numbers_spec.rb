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
	context "Hard to Express Numbers" do
    #
    #
    #
    it "should find 5 results less than 0.1" do
       query_object = <<HERE
				<operator logic="and">
					<term field="v.condition-xpath" str="$simple-number &lt; 0.1"
						input-type="system" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(5)
    end
    #
    #
    #
    it "should find 5 results less-than-or-equal to 0.1" do
       query_object = <<HERE
				<operator logic="and">
					<term field="v.condition-xpath" str="$simple-number &lt;= 0.1"
						input-type="system" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(5)
    end
    #
    #
    #
    it "should find 5 results less than 0.0000000001" do
       query_object = <<HERE
				<operator logic="and">
					<term field="v.condition-xpath" str="$simple-number &lt; 0.0000000001"
						input-type="system" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(5)
    end
    #
    #
    #
    it "should find 5 results less-than-or-equal to 0.0000000001" do
       query_object = <<HERE
				<operator logic="and">
					<term field="v.condition-xpath" str="$simple-number &lt;= 0.0000000001"
						input-type="system" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(5)
    end
    #
    #
    #
    it "should find 3 results greater-than to 1.999999999" do
       query_object = <<HERE
				<operator logic="and">
					<term field="v.condition-xpath" str="$simple-number > 1.999999999"
						input-type="system" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end
    #
    #
    #
    it "should find 3 results greater-than-or-equal to 1.999999999" do
       query_object = <<HERE
				<operator logic="and">
					<term field="v.condition-xpath" str="$simple-number >= 1.999999999"
						input-type="system" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end
  end	# End Numeric Range Context
end
