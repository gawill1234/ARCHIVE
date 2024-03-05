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
    it "should find 39 results for the query NOT(hero:sid)" do
      query_object = <<HERE
				<operator logic="and">
					<operator logic="not" name="NOT" start-string="NOT">
						<term field="hero" str="sid" input-type="user" />
					</operator>
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(39)
    end
    #
    #
    #
    it "should find 39 results for the query NOT(hero:=='Sid Halley')" do
      query_object = <<HERE
				<operator logic="and">
					<operator logic="not" name="NOT" start-string="NOT">
						<operator logic="equal" name="equal" start-string="==" precedence="9">
						  <term field="hero" str="Sid Halley" phrase="phrase" input-type="user" />
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
    it "should find 43 results for the query NOT(hero:=='sid Halley')" do
      query_object = <<HERE
				<operator logic="and">
					<operator logic="not" name="NOT" start-string="NOT">
						<operator logic="equal" name="equal" start-string="==" precedence="9">
						  <term field="hero" str="sid Halley" phrase="phrase" input-type="user" />
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
    it "should find 39 results for NOT(hero:'Sid Hall?y')" do
      query_object = <<HERE
				<operator logic="and">
					<operator logic="not" name="NOT" start-string="NOT">
						<operator logic="and">
						  <term field="hero" str="'Sid" input-type="user" />
						  <term field="query" str="Hall?y'" processing="strict" input-type="user">
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
    it "should find 39 results for NOT(hero:'*all?y')" do
      query_object = <<HERE
				<operator logic="and">
					<operator logic="not" name="NOT" start-string="NOT">
						<term field="hero" str="'*all?y'" input-type="user">
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
    it "should find 42 results for NOT(hero:'*inn')" do
      query_object = <<HERE
				<operator logic="and">
					<operator logic="not" name="NOT" start-string="NOT">
						<term field="hero" str="'*inn'" input-type="user">
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
    it "should find 42 results for NOT(hero:*inn)" do
      query_object = <<HERE
				<operator logic="and">
					<operator logic="not" name="NOT" start-string="NOT">
						<term field="hero" str="*inn" input-type="user">
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
    it "should find 36 results for NOT(m/Halle?/) and NOT(hero:m/Fin?/)" do
      query_object = <<HERE
				<operator logic="and">
					<operator logic="not" name="NOT" start-string="NOT">
						<term field="hero" str="Halle?" phrase="phrase" input-type="user">
						  <operator logic="regex" />
						</term>
					</operator>
					<operator logic="not" name="NOT" start-string="NOT">
						<term field="hero" str="Fin?" phrase="phrase" input-type="user">
						  <operator logic="regex" />
						</term>
					</operator>
				</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(36)    
    end
		#
		#
		#
    it "should find 43 results for NOT(m/Halle?/) and NOT(hero:m/Fin?/)" do
      query_object = <<HERE
				<operator logic="or">
					<operator logic="not" name="NOT" start-string="NOT">
						<term field="hero" str="Halle?" phrase="phrase" input-type="user">
						  <operator logic="regex" />
						</term>
					</operator>
					<operator logic="not" name="NOT" start-string="NOT">
						<term field="hero" str="Fin?" phrase="phrase" input-type="user">
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
					<term field="v.condition-xpath" str="$hero != 'Sid Halley'"
						input-type="system"/>
				</operator>
HERE
			query_object = <<HERE
				<operator logic="and">
					<operator logic="not" name="NOT" start-string="NOT">
						<operator logic="and">
						  <term field="hero" str="'Sid" input-type="user" />
						  <term field="query" str="Halley'" processing="strict" 
						  			input-type="user" />
						</operator>
					</operator>
				</operator>	
HERE
			answerNot = $xpath_source.search(query_object_not)
			answer    = $xpath_source.search(query_object)
			doc_count(answerNot).should eql(doc_count(answer))
    end 
      
	end	# End String Not Context
end
