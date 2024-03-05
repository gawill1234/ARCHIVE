# string_equality_spec.rb

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
    puts "Testing String Equality"
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
	
  context "String Equality" do
    #
    # 
    #  
    it "should find 4 results for the string Tommy Flat" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="Tommy Flat" phrase="phrase" input-type="user" />
	</operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(4)
    end  
    #
    #
    #
    it "should find no results when case doesn't match (all lowercase)" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="tommy flat" phrase="phrase" input-type="user" />
        </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)    
    end
    #
    #
    #
    it "should find no results when case doesn't match (all uppercase)" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="TOMMY FLAT" phrase="phrase" input-type="user" />
	</operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)    
    end
    #
    #
    #
    it "should find no results for the partial string" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="Tommy" phrase="phrase" input-type="user" />
	</operator>
        </operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)    
    end
    #
    #
    #
    it "should find no results for the partial string in wrong case" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="tommy" phrase="phrase" input-type="user" />
	</operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)    
    end
    #
    # 
    #
    it "should find 1 result for the string Chip Dawson" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="Chip Dawson" phrase="phrase" input-type="user" />
	</operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(1)    
    end 
    #
    #
    #
    it "should find no results for the string in slightly wrong case" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="chiP Dawson" phrase="phrase" input-type="user" />
	</operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)    
    end        
    #
    # Regex Equality Tests
    #
    it "should find one result for the regex H?lder" do
      query_object = <<HERE
	<operator logic="and">
	<term field="hero" str="H?lder" phrase="phrase" input-type="user">
	<operator logic="regex" />
	</term>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(1)        
    end
    #
    # 
    #
    it "should find one result for the regex h?lder" do
      query_object = <<HERE
	<operator logic="and">
	<term field="hero" str="h?lder" phrase="phrase" input-type="user">
	<operator logic="regex" />
	</term>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(1)        
    end
    #
    # Wildcard tests
    #
    it "should find four results for the regex *Flat" do
      query_object = <<HERE
	<operator logic="and">
	<term field="hero" str="*Flat" input-type="user">
	<operator char="*" logic="wildcard" />
	<operator char="?" logic="wildchar" />
	</term>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(4)        
    end
    #
    #
    #
    it "should find four results for the regex *Fl?t" do
      query_object = <<HERE
	<operator logic="and">
	<term field="hero" str="*Fl?t" input-type="user">
	<operator char="*" logic="wildcard" />
	<operator char="?" logic="wildchar" />
	</term>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(4)        
    end
    #
    #
    #  
  end	# End String Equality Context
end
