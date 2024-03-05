# string_not_spec.rb

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
    puts "Testing String Not"
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
	
  #---------------------------------------------------------------------------#
  #
  # Apply the not operator to string values to ensure proper behavior.
  #
  #---------------------------------------------------------------------------#
  context "String Not" do
    #
    # 
    #  
    it "should find 39 results for the query NOT(hero:tommy)" do
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="hero" str="tommy" input-type="user" />
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(39)
    end
    #
    #
    #
    it "should find 39 results for the query NOT(hero:=='Tommy Flat')" do
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="equal" name="equal" start-string="==" precedence="9">
	      <term field="hero" str="Tommy Flat" phrase="phrase" input-type="user" />
	    </operator>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(39)
    end
    #
    #
    #
    it "should find 43 results for the query NOT(hero:=='tommy Flat')" do
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="equal" name="equal" start-string="==" precedence="9">
	      <term field="hero" str="tommy Flat" phrase="phrase" input-type="user" />
	    </operator>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(43)
    end
    #
    #
    #
    it "should find 39 results for NOT(hero:'Tommy Fl?t')" do
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <operator logic="and">
	      <term field="hero" str="'Tommy" input-type="user" />
	      <term field="query" str="Fl?t'" processing="strict" input-type="user">
	        <operator char="?" logic="wildchar" />
	      </term>
	    </operator>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(39)
    end
    #
    #
    #
    it "should find 39 results for NOT(hero:'*l?t')" do
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="hero" str="'*l?t'" input-type="user">
	      <operator char="*" logic="wildcard" />
	      <operator char="?" logic="wildchar" />
	    </term>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(39)
    end
    #
    #
    #
    it "should find 42 results for NOT(hero:'*ice')" do
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="hero" str="'*ice'" input-type="user">
	      <operator char="*" logic="wildcard" />
	    </term>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(42)
    end
    #
    #
    #
    it "should find 42 results for NOT(hero:*ice)" do
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="hero" str="*ice" input-type="user">
	      <operator char="*" logic="wildcard" />
	    </term>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(42)    
    end
    #
    #
    #
    it "should find 37 results for NOT(m/Plan?/) and NOT(hero:m/Nic?/)" do
      query_object = <<HERE
	<operator logic="and">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="hero" str="Plan?" phrase="phrase" input-type="user">
	      <operator logic="regex" />
	    </term>
	  </operator>
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="hero" str="Nic?" phrase="phrase" input-type="user">
	      <operator logic="regex" />
	    </term>
	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(37)    
    end
    #
    #
    #
    it "should find 43 results for NOT(m/Plan?/) or NOT(hero:m/Nic?/)" do
      query_object = <<HERE
	<operator logic="or">
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="hero" str="Plan?" phrase="phrase" input-type="user">
	      <operator logic="regex" />
	    </term>
	  </operator>
	  <operator logic="not" name="NOT" start-string="NOT">
	    <term field="hero" str="Nic?" phrase="phrase" input-type="user">
	      <operator logic="regex" />
	    </term>
  	  </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(43)    
    end
    #
    #
    #
    it "should find the same number of documents for NOT() and !=" do
    	query_object_not = <<HERE
	  <operator logic="and">
	    <term field="v.condition-xpath" str="$hero != 'Tommy Flat'"
						input-type="system"/>
	  </operator>
HERE
	query_object = <<HERE
	  <operator logic="and">
	    <operator logic="not" name="NOT" start-string="NOT">
	      <operator logic="and">
	        <term field="hero" str="'Tommy" input-type="user" />
		<term field="query" str="Flat'" processing="strict" 
		    input-type="user" />
	      </operator>
	    </operator>
	  </operator>	
HERE
	answerNot = $xpath_source.search(query_object_not)
	answer    = $xpath_source.search(query_object)
	# Difference of one caused by index file without 'hero' content
        doc_count(answerNot).should eql(doc_count(answer)-1)
    end   
  end	# End String Not Context
end
