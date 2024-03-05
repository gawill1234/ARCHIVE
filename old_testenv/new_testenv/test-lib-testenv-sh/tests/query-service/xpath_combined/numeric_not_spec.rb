# numeric_not_spec.rb

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
    puts "Testing Numeric Not"
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
	
  context "Numeric Not" do
    #
    # Test the not operator alone
    # 
    it "should find 42 documents that do not have the year 1999" do
      query_object = <<HERE
	<operator logic="and">
  	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="year" str="1999" input-type="user" />
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(42)
    end
    #
    # Compare Not(<2000) and >= 2000
    #
    it "should return the same number of results for not(<2000) and >= 2000" do
      query_object_not = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="less-than" name="less-than" start-string="&lt;"
		  precedence="9">
	      <term field="year" str="2000" input-type="user" />
	    </operator>
	  </operator>
	</operator>
HERE
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="greater-than-or-equal" name="greater-than-or-equal"
	        start-string=">=" precedence="9">
	    <term field="year" str="2000" input-type="user" />
	  </operator>
	</operator>
HERE
      answerNot = $xpath_source.search(query_object_not)
      answer    = $xpath_source.search(query_object)
	# The reason for the +1 is that there is a document without a year
	# that shows up for not queries.
      doc_count(answerNot).should eql(doc_count(answer)+1)
    end 
    #
    # Compare Not(<=2000) and > 2000
    #
    it "should return the same number of results for not(<=2000) and > 2000" do
      query_object_not = <<HERE
	<operator logic="and">
   	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="less-than-or-equal" name="less-than-or-equal" 
		start-string="&lt;" precedence="9">
	      <term field="year" str="2000" input-type="user" />
	    </operator>
	  </operator>
	</operator>
HERE
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="greater-than" name="greater-than"
	      start-string=">" precedence="9">
	    <term field="year" str="2000" input-type="user" />
	  </operator>
	</operator>
HERE
      answerNot = $xpath_source.search(query_object_not)
      answer    = $xpath_source.search(query_object)
	# The reason for the +1 is that there is a document without a year
	# that shows up for not queries.
      doc_count(answerNot).should eql(doc_count(answer)+1)
    end
    #
    # Compare Not(==2000) and Greater-Than and Less-Than 2000
    #
    it "should return the same number of results for not(2000) and >2000<" do
      query_object_not = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="year" str="2000" input-type="user" />
	  </operator>
	</operator>
HERE
      query_object = <<HERE
	<operator logic="or">
	  <operator logic="less-than">
	    <term field="year" str="2000" />
	  </operator>
	  <operator logic="greater-than">
	    <term field="year" str="2000" />
	  </operator>
	</operator>
HERE
      answerNot = $xpath_source.search(query_object_not)
      answer = $xpath_source.search(query_object)
	# The reason for the +1 is that there is a document without a year
	# that shows up for not queries.
      doc_count(answerNot).should eql(doc_count(answer)+1)
    end
    #
    # Compare Not(>2000) and Less-than-or-equal 2000
    #
    it "should return the same number of results for not(>2000) and <=2000" do
      query_object_not = <<HERE
	<operator logic="and">
   	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="greater-than" name="greater-than" start-string=">"
		  precedence="9">
	      <term field="year" str="2000" input-type="user" />
	    </operator>
	  </operator>
	</operator>
HERE
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="less-than-or-equal" name="less-than-or-equal"
		start-string="&lt;=" precedence="9">
	    <term field="year" str="2000" input-type="user" />
	  </operator>
	</operator>
HERE
      answerNot = $xpath_source.search(query_object_not)
      answer = $xpath_source.search(query_object)
        # The reason for the +1 is that there is a document without a year
	# that shows up for not queries.
      doc_count(answerNot).should eql(doc_count(answer)+1)
    end    
    #
    # Test Multiple NOTS with and logic and ==
    #
    it "should return 41 results for Not(1995) and Not(1999)" do
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="year" str="1995" input-type="user" />
	  </operator>
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="year" str="1999" input-type="user" />
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(41)
    end 
    #
    # Test Multiple NOTS with or logic and ==
    #
    it "should return 43 results for Not(2000) or Not(1999)" do
      query_object = <<HERE
	<operator logic="or">
   	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="year" str="2000" input-type="user" />
	  </operator>
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="year" str="1999" input-type="user" />
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(43)
    end
    #
    # Test Multiple NOTS with and logic(<=, ==)
    # 	
    it "should return 16 results for Not(2007) and Not(<=2000)" do
      query_object = <<HERE
	<operator logic="and">
  	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="year" str="2007" input-type="user" />
	  </operator>
	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="less-than-or-equal" name="less-than-or-equal"
		  start-string="&lt;=" precedence="9">
	      <term field="year" str="2000" input-type="user" />
	    </operator>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(16)
    end
    #
    # Test Multiple NOTS with or logic(<=, ==)
    # 	
    it "should return 42 results for Not(1999) or Not(<=2000)" do
      query_object = <<HERE
	<operator logic="or">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="year" str="1999" input-type="user" />
	  </operator>
	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="less-than-or-equal" name="less-than-or-equal"
		  start-string="&lt;=" precedence="9">
	      <term field="year" str="2000" input-type="user" />
	    </operator>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(42)
    end
    #
    # Test Multiple NOTS with and logic(<=, <)
    # 	
    it "should return 26 results for Not(<=1990) and Not(<1995)" do
      query_object = <<HERE
	<operator logic="and">
  	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="less-than-or-equal" name="less-than-or-equal"
		  start-string="&lt;=" precedence="9">
	      <term field="year" str="1990" input-type="user" />
	    </operator>
	  </operator>
	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="less-than-or-equal" name="less-than-or-equal"
		  start-string="&lt;=" precedence="9">
	      <term field="year" str="1995" input-type="user" />
	    </operator>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(26)
    end
    #
    # Test Multiple NOTS with and logic(<=, <)
    # 	
    it "should return 30 results for Not(<=1990) or Not(<1995)" do
      query_object = <<HERE
	<operator logic="or">
   	  <operator logic="not" name="NOT" start-string="NOT">
            <operator logic="less-than-or-equal" name="less-than-or-equal"
	        start-string="&lt;=" precedence="9">
	      <term field="year" str="1990" input-type="user" />
	    </operator>
	  </operator>
	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="less-than-or-equal" name="less-than-or-equal"
		  start-string="&lt;=" precedence="9">
	      <term field="year" str="1995" input-type="user" />
	    </operator>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(30)
    end    	 
  end	# End Numeric Not Context
end
