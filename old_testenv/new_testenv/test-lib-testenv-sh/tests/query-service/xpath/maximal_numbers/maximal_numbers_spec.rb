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

    it "should find 10 results less than 4E50" do
      query_object = <<HERE
<operator logic="less-than">
  <term field="simple-number" str="4E50" />
</operator>
HERE
      answer = $xpath_source.search(query_object)
      total_results_with_duplicates(answer).should eql(12)
    end

    it "should find no results greater than 4E50" do
      query_object = <<HERE
<operator logic="greater-than">
  <term field="simple-number" str="4E50" />
</operator>
HERE
      answer = $xpath_source.search(query_object)
      total_results_with_duplicates(answer).should eql(0)
    end

    it "should find 10 results greater than -4E50" do
      query_object = <<HERE
<operator logic="greater-than">
  <term field="simple-number" str="-4E50" />
</operator>
HERE
      answer = $xpath_source.search(query_object)
      total_results_with_duplicates(answer).should eql(12)
    end

    it "should find no results less than -4E50" do
      query_object = <<HERE
<operator logic="less-than">
  <term field="simple-number" str="-4E50" />
</operator>
HERE
      answer = $xpath_source.search(query_object)
      total_results_with_duplicates(answer).should eql(0)
    end
  end	# End Numeric Range Context
end
