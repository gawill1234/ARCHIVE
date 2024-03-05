# numeric_comparisons_spec.rb

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
    puts "Testing Numeric Comparisons"
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
  # Apply the comparison operators to numeric values to ensure proper behavior.
  #
  #---------------------------------------------------------------------------#
  context "smoke test for each of the comparison operators" do
    it "should do < properly - 17 docs < 5" do
      query_object = <<HERE
<operator logic="less-than">
  <term field="simple-number" str="5" />
</operator>
HERE
      answer = $xpath_source.search(query_object)
      total_results_with_duplicates(answer).should eql(11)
    end

    it "should do <= properly - 18 docs <= 3" do
      query_object = <<HERE
<operator logic="less-than-or-equal">
  <term field="simple-number" str="3" />
</operator>
HERE
      answer = $xpath_source.search(query_object)
      total_results_with_duplicates(answer).should eql(10)
    end

    it "should do > properly - 8 docs > -1" do
      query_object = <<HERE
<operator logic="greater-than">
  <term field="simple-number" str="-1" />
</operator>
HERE
      answer = $xpath_source.search(query_object)
      total_results_with_duplicates(answer).should eql(9)
    end

    it "should do >= properly - 9 docs >= 10" do
      query_object = <<HERE
<operator logic="greater-than-or-equal">
  <term field="simple-number" str="10" />
</operator>
HERE
      answer = $xpath_source.search(query_object)
      total_results_with_duplicates(answer).should eql(0)
    end

    it "should do == properly - 1 doc for == 7" do
      query_object = <<HERE
<operator logic="equal">
  <term field="simple-number" str="7" />
</operator>
HERE
      answer = $xpath_source.search(query_object)
      total_results_with_duplicates(answer).should eql(1) and
        url(answer).should eql('http://testbed14.test.vivisimo.com/simple-number-rights')
    end
  end #End Numeric Comparisons Context
end
