# greater_than_spec.rb
# 
# The purpose of this file is to test multiple xpaths when the less
# than operator is involved.
#

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
	# Mutate the order of XPath expressions to ensure the same result is returned
	#
	#---------------------------------------------------------------------------#
  context "Greater Than - Multiple XPaths" do
		################################################################	
		#
		#	Greater Than AND Greater Than
		#
		it "should return two documents for > 1 and > 2" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="greater-than">
						<term field="simple-number" str="1" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="2" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end
		#
		# Greater Than AND Greater Than - REVERSE
		#
		it "should return two documents for > 1 and > 2 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="greater-than">
						<term field="simple-number" str="2" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="1" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end
		#
		#	Greater Than OR Greater Than
		#
		it "should return ten documents for > 5 or > -3" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="greater-than">
						<term field="simple-number" str="5" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="-3" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(10)
		end
		#
		# Greater Than OR Greater Than - REVERSE
		#
		it "should return ten documents for < 1 or < 2 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="greater-than">
						<term field="simple-number" str="-3" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="5" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(10)
		end
		
		################################################################			
		#
		# Less Than or Equal AND Greater Than
		#
		it "should return ten documents for <= 6.3 or > -2" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="less-than-or-equal">
						<term field="simple-number" str="6.3" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="-2" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(10)
		end		
		#
		# Less Than or Equal AND Greater Than - REVERSE
		#
		it "should return ten documents for <= 6.3 or > -2 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="greater-than">
						<term field="simple-number" str="-2" />
					</operator>
					<operator logic="less-than-or-equal">
						<term field="simple-number" str="6.3" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(10)
		end
		#
		# Less Than or Equal OR Greater Than
		#
		it "should return nine documents for <= 4 or > 9" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="less-than-or-equal">
						<term field="simple-number" str="4" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="9" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(9)
		end				
		#
		# Less Than or Equal OR Greater Than - REVERSE
		# 		
		it "should return nine documents for < 4 or > 10 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="greater-than">
						<term field="simple-number" str="10" />
					</operator>
					<operator logic="less-than-or-equal">
						<term field="simple-number" str="4" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(9)
		end			
		
		################################################################	
		#
		# Equal AND Greater Than
		#
		it "should return no documents for == 0 and > 5" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="equal">
						<term field="simple-number" str="0" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="5" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(0)
		end		
		#
		# Equal AND Greater Than - REVERSE
		#
		it "should return no documents for == 0 or > 5 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="greater-than">
						<term field="simple-number" str="5" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="0" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(0)
		end				
		#
		# Equal OR Greater Than
		#
		it "should return 1 document for == -1 or > 7" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="equal">
						<term field="simple-number" str="-1" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="7" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(1)
		end
		#
		# Equal OR Greater Than - REVERSE
		#
		it "should return one document for == -1 or > 7 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="greater-than">
						<term field="simple-number" str="7" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="-1" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(1)
		end
		
		################################################################			
		#
		# Less Than AND Greater Than
		#
		it "should return eight documents for < 3 or > -2" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="less-than">
						<term field="simple-number" str="3" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="-2" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(8)
		end		
		#
		# Less Than AND Greater Than - REVERSE
		#
		it "should return eight documents for < 3 or > -2 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="greater-than">
						<term field="simple-number" str="-2" />
					</operator>
					<operator logic="less-than">
						<term field="simple-number" str="3" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(8)
		end
		#
		# Less Than OR Greater Than
		#
		it "should return eight documents for < 4 or > 10" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="less-than">
						<term field="simple-number" str="4" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="10" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(8)
		end				
		#
		# Less Than OR Greater Than - REVERSE
		# 		
		it "should return eight documents for < 4 or > 10 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="greater-than">
						<term field="simple-number" str="10" />
					</operator>
					<operator logic="less-than">
						<term field="simple-number" str="4" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(8)
		end			
				
		################################################################			
		#
		# Greater Than AND Greater Than or Equal
		#		
		it "should return five documents for > 3 and >= 0" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="greater-than">
						<term field="simple-number" str="3" />
					</operator>
					<operator logic="greater-than-or-equal">
						<term field="simple-number" str="0" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end
		#
		# Greater Than AND Greater Than or Equal - REVERSE
		#
		it "should return two documents for > 3 and >= 0 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="greater-than-or-equal">
						<term field="simple-number" str="0" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="3" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end
		#
		# Greater Than OR Greater Than or Equal
		#
		it "should return two documents for > 9 or >= 4" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="greater-than">
						<term field="simple-number" str="9" />
					</operator>
					<operator logic="greater-than-or-equal">
						<term field="simple-number" str="4" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end		
		#
		# Greater Than OR Greater Than or Equal - REVERSE
		#
		it "should return two documents for > 9 or >= 4 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="greater-than-or-equal">
						<term field="simple-number" str="4" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="9" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end
				
		################################################################			
		#
		# Greater Than AND Range
		#
		it "should return one document for > 8 and 6..9" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="greater-than">
						<term field="simple-number" str="8" />
					</operator>
					<operator logic="range">
						<term field="simple-number" str="6" />
						<term field="simple-number" str="9" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(0)
		end
		#
		# Greater Than AND Range - REVERSE
		#
		it "should return one document for > 8 and 6..9 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="range">
						<term field="simple-number" str="6" />
						<term field="simple-number" str="9" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="8" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(0)
		end
		#
		# Greater Than OR Range
		#		
		it "should return four documents for > 4 or 1..3" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="greater-than">
						<term field="simple-number" str="4" />
					</operator>
					<operator logic="range">
						<term field="simple-number" str="1" />
						<term field="simple-number" str="3" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(4)
		end				
		#
		# Greater Than OR Range - REVERSE
		#
		it "should return four documents for > 4 or 1..3 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="range">
						<term field="simple-number" str="1" />
						<term field="simple-number" str="3" />
					</operator>
					<operator logic="greater-than">
						<term field="simple-number" str="4" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(4)
		end		
  end #End Multiple XPaths Context    
end
