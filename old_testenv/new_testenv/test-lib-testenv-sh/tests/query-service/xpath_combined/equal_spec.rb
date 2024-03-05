# equal_spec.rb
# 
# The purpose of this file is to test multiple xpaths when the 
# equal operator is involved.
#

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
    puts "Testing Multiple XPaths including =="
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
	# Mutate the order of XPath expressions to ensure the same result is returned
	#
	#---------------------------------------------------------------------------#
  context "Equal - Multiple XPaths" do
		################################################################	
		#
		#	Equal AND Equal
		#
		it "should return no documents for == 1 and == 2" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="equal">
						<term field="simple-number" str="1" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="2" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(0)
		end
		#
		# Equal AND Equal - REVERSE
		#
		it "should return no documents for == 1 and == 2 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="equal">
						<term field="simple-number" str="2" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="1" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(0)
		end
		#
		#	Equal OR Equal Than
		#
		it "should return eight documents for == 2 or == 5" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="equal">
						<term field="simple-number" str="2" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="5" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end
		#
		# Equal OR Equal - REVERSE
		#
		it "should return eight documents for == 2 or == 5 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="equal">
						<term field="simple-number" str="5" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="2" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
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
		# Less Than AND Equal
		#
		it "should return one document for < -1 or == -2" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="less-than">
						<term field="simple-number" str="-1" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="-2" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(1)
		end		
		#
		# Less Than AND Equal - REVERSE
		#
		it "should return one document for < -1 and == -2 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="equal">
						<term field="simple-number" str="-2" />
					</operator>
					<operator logic="less-than">
						<term field="simple-number" str="-1" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(1)
		end
		#
		# Less Than OR Equal
		#
		it "should return two documents for < -1 or == -2" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="less-than">
						<term field="simple-number" str="-1" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="-2" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end		
		#
		# Less Than OR Equal - REVERSE
		#
		it "should return two documents for < -1 or == -2 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="equal">
						<term field="simple-number" str="-2" />
					</operator>
					<operator logic="less-than">
						<term field="simple-number" str="-1" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end
		
		################################################################	
		#
		# Less Than or Equal AND Equal
		#
		it "should return one document for <= 10.5 and == 5" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="less-than-or-equal">
						<term field="simple-number" str="10.5" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="5" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(1)
		end		
		#
		# Less Than or Equal AND Equal - REVERSE
		#
		it "should return one document for <= 10.5 and == 5 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="equal">
						<term field="simple-number" str="5" />
					</operator>
					<operator logic="less-than">
						<term field="simple-number" str="10.5" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(1)
		end
		#
		# Less Than or Equal OR Equal
		#
		it "should return ten documents for <= 10.5 or == 5" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="less-than-or-equal">
						<term field="simple-number" str="10.5" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="5" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(10)
		end		
		#
		# Less Than or Equal OR Equal - REVERSE
		#
		it "should return ten documents for <= 10.5 or == 5 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="equal">
						<term field="simple-number" str="5" />
					</operator>
					<operator logic="less-than-or-equal">
						<term field="simple-number" str="10.5" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(10)
		end			
				
		################################################################			
		#
		# Equal AND Greater Than or Equal
		#		
		it "should return seven documents for == 9 and >= 0" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="less-than">
						<term field="simple-number" str="9" />
					</operator>
					<operator logic="greater-than-or-equal">
						<term field="simple-number" str="0" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(7)
		end
		#
		# Equal AND Greater Than or Equal - REVERSE
		#
		it "should return seven documents for == 9 and >= 0 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="greater-than-or-equal">
						<term field="simple-number" str="0" />
					</operator>
					<operator logic="less-than">
						<term field="simple-number" str="9" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(7)
		end
		#
		# Equal OR Greater Than or Equal
		#
		it "should return one document for == 3 or >= 5" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="equal">
						<term field="simple-number" str="3" />
					</operator>
					<operator logic="greater-than-or-equal">
						<term field="simple-number" str="5" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(1)
		end		
		#
		# Equal OR Greater Than or Equal - REVERSE
		#
		it "should return one document for == 3 or >= 5 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="greater-than-or-equal">
						<term field="simple-number" str="5" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="3" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(1)
		end
				
		################################################################			
		#
		# Equal AND Range
		#
		it "should return one document for == -2 and -5..0" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="equal">
						<term field="simple-number" str="-2" />
					</operator>
					<operator logic="range">
						<term field="simple-number" str="-5" />
						<term field="simple-number" str="0" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(1)
		end
		#
		# Equal AND Range - REVERSE
		#
		it "should return one document for == -2 and -5..0 - REVERSE" do
			query_object = <<HERE
				<operator logic="and">
					<operator logic="range">
						<term field="simple-number" str="-5" />
						<term field="simple-number" str="0" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="-2" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(1)
		end
		#
		# Equal OR Range
		#		
		it "should return two documents for == -2 or 7..10" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="equal">
						<term field="simple-number" str="-2" />
					</operator>
					<operator logic="range">
						<term field="simple-number" str="7" />
						<term field="simple-number" str="10" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end				
		#
		# Equal OR Range - REVERSE
		#
		it "should return two documents for == -2 or 7..10 - REVERSE" do
			query_object = <<HERE
				<operator logic="or">
					<operator logic="range">
						<term field="simple-number" str="7" />
						<term field="simple-number" str="10" />
					</operator>
					<operator logic="equal">
						<term field="simple-number" str="-2" />
					</operator>
				</operator>
HERE
			answer = $xpath_source.search(query_object)
			doc_count(answer).should eql(2)
		end		
  end #End Multiple XPaths Context    
end
