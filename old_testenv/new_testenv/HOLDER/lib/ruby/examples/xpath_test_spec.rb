$LOAD_PATH << ENV['RUBYLIB']
require 'loader'

include Velocity

#---------------------------------------------------------------------------#
# Helpers
# The doc_count and url methods are used to detected the pass/fail status
# of each test. They should probably be moved out of this file and into
# a helper function.
#---------------------------------------------------------------------------#
def doc_count(xml)
	xml.xpath("//document").length
	# Returns count of documents
end

def url(xml)
	xml.xpath("//document/@url").to_s
	# Returns @url of the first document
end

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

end
