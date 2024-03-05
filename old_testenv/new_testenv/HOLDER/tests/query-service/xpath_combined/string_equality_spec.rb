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
    it "should find 4 results for the string Sid Halley" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="Sid Halley" phrase="phrase" input-type="user" />
	</operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(4)
    end  
    #
    #
    #
    it "should find no results for the string sid halley" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="sid halley" phrase="phrase" input-type="user" />
        </operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)    
    end
    #
    #
    #
    it "should find no results for the string SID HALLEY" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="SID HALLEY" phrase="phrase" input-type="user" />
	</operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)    
    end
    #
    #
    #
    it "should find no results for the string Sid" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="Sid" phrase="phrase" input-type="user" />
	</operator>
        </operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)    
    end
    #
    #
    #
    it "should find no results for the string sid" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="sid" phrase="phrase" input-type="user" />
	</operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)    
    end
    #
    # 
    #
    it "should find 1 result for the string Rob Finn" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="Rob Finn" phrase="phrase" input-type="user" />
	</operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(1)    
    end 
    #
    #
    #
    it "should find no results for the string roB Finn" do
      query_object = <<HERE
	<operator logic="and">
	<operator logic="equal" name="equal" start-string="==" precedence="9">
	<term field="hero" str="roB Finn" phrase="phrase" input-type="user" />
	</operator>
	</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(0)    
    end        
    #
    # Regex Equality Tests
    #
    it "should find one result for the regex S?even" do
      query_object = <<HERE
	<operator logic="and">
	<term field="hero" str="s?even" phrase="phrase" input-type="user">
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
    it "should find one result for the regex s?even" do
      query_object = <<HERE
	<operator logic="and">
	<term field="hero" str="s?even" phrase="phrase" input-type="user">
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
    it "should find four results for the regex *Halley" do
      query_object = <<HERE
	<operator logic="and">
	<term field="hero" str="*Halley" input-type="user">
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
    it "should find four results for the regex *Hall?y" do
      query_object = <<HERE
	<operator logic="and">
	<term field="hero" str="*Hall?y" input-type="user">
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
