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
	
	#---------------------------------------------------------------------------#
	#
	# Apply the range operator to date values to ensure proper behavior.
	#
	#---------------------------------------------------------------------------#
  context "smoke test for each of the comparison operators" do
    it "should do < properly - 17 docs < 2008-10-12 20:49:38" do
      query_object = <<HERE
				<operator logic="less-than">
					<term field="simple-date" str="2008-10-12 20:49:38" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(17)
    end

    it "should do <= properly - 18 docs <= 2008-10-12 20:49:38" do
      query_object = <<HERE
				<operator logic="less-than-or-equal">
					<term field="simple-date" str="2008-10-12 20:49:38" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(18)
    end

    it "should do > properly - 8 docs > 2006-10-12 20:49:37" do
      query_object = <<HERE
				<operator logic="greater-than">
					<term field="simple-date" str="2006-10-12 20:49:37" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(8)
    end

    it "should do >= properly - 9 docs >= 2006-10-12 20:49:37" do
      query_object = <<HERE
				<operator logic="greater-than-or-equal">
					<term field="simple-date" str="2006-10-12 20:49:37" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(9)
    end

    it "should do == properly - 1 doc for == 2006-10-12 20:49:37" do
      query_object = <<HERE
				<operator logic="equal">
					<term field="simple-date" str="2006-10-12 20:49:37" />
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(1) and url(answer).should eql("simple-date-good-2006-10-1220:49:37")
    end
  end #End Numeric Comparisons Context    
end
