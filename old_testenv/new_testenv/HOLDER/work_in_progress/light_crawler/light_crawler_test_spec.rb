$LOAD_PATH << ENV['RUBYLIB']
require 'loader'
require 'spec_helper_symantec'
require 'light_crawler_helper'
require 'benchmark'

describe "Light Crawler" do
# The light crawler is basically a set of options which, when set, cause
# us to record less data about URLs (only when safe) and permit URL status
# to be deleted from the logs. Symantec didn't need all of that info about
# completed URLs, as they are handling all of the refreshing and updating,
# for which the information is normally used. Reducing the size of the
# crawler's log has two main benefits: reduced storage consumption and
# much more scalable performance.
#
# More information about the light crawler can be found at:
# https://meta.vivisimo.com/wiki/Light_Crawler_Documentation  
#
#  
#	Test Description:
# The tests included in this file were created based on the Symantec test plan
# that can be found in the product development folder of the office share. For
# general testing of the light crawler please run the light_crawler_spec.rb
# file created by Jean Lange. It should be located in the same folder as this
# file.
#
# Test Outline:
#	1. Ingest documents into a single collection to
# 	 ensure no performance degradation
# 2. Update indexed data
# 3. Delete Indexed data
# 4. Monitor the size of the SQLite database (log.sqlt) to ensure size does
#		 not continually increase
# 5. Stop crawler/indexer for collection during data ingestion (SQLite
#		 database log.sqlt should grow) and restart (all data ingested successfully)
# 6. Restart Velocity server during data ingestion and perform the following:
#    A. Toll pushing data retries each failed (data push) API call
#    B. Once ingestion complete the number of indexed documents is correct
#		 C. Searches return correct results on collection
#    D. SQLite database (log.sqlt) is expected size
#
  context "Performance Test" do
  	it "should connect to Velocity" do
  		@vapi.should_not be_nil
  	end	 
		it "should ingest documents	to ensure no performance degradation" do
			@original_data = create_original_data
			@additional_data = create_additional_data
			@collections = {"light" => "test-light-crawler-symantec",
											"heavy" => "test-light-crawler-symantec-heavy"}
			
			#----------------------------------------------------------------------#
			# Capture the amount of time it takes to create a light-crawler and
			# heavy crawler collection.
			#
			light_result = Benchmark.realtime do 
				light_crawler_test_setup("test-light-crawler-symantec")
				@light_crawler = Velocity::Collection.new(@vapi, @collections["light"])
        @light_crawler.wait_for_crawl("live", 1, true)
			end
			heavy_result = Benchmark.realtime do
				light_crawler_test_setup("test-light-crawler-symantec-heavy")
				@heavy_crawler = Velocity::Collection.new(@vapi, @collections["heavy"])
				@heavy_crawler.wait_for_crawl("live", 1, true)
			end
			#
			# This is assuming the light crawler should be faster than the "heavy"
			# crawler. Is this correct? Or should the two values just be very close
			# to one another?
			#
			light_result.should be < heavy_result
		end
  end # End Data Ingestion
  
  context "Monitor the SQL Database" do
  	it "enqueue a list of URLs" do			
			@urls.each do |url|
				@vapi.search_collection_enqueue_url({
					:collection => 'test-light-crawler-symantec',
					:url => url
				})
			end

                        live_crawl_dir = @light_crawler.crawl_path_list[0]
			@@db_size = Gronk.new.file_size(live_crawl_dir)
			
			@@db_size.should_not be_nil
  	end
  	
  	it "should delete a list of URLs" do
  		@urls.each do |url|
				@vapi.search_collection_enqueue({
					:collection => 'test-light-crawler-symantec', 
					:crawl_urls => "<crawl-delete url='" + url + "'
													syncronization='indexed-no-sync' />"})
  		end

                        live_crawl_dir = @light_crawler.crawl_path_list[0]
			@db_size_test = Gronk.new.file_size(live_crawl_dir)
			
			@db_size_test.should eql(@@db_size)
  	end

  	it "should not grow after enqueueing more URLs" do			
			@urls.each do |url|
				@vapi.search_collection_enqueue_url({
					:collection => 'test-light-crawler-symantec',
					:url => url
				})
			end
							
                        live_crawl_dir = @light_crawler.crawl_path_list[0]
			@db_size_test = Gronk.new.file_size(live_crawl_dir)
			
			@db_size_test.should eql(@@db_size)
  	end
  end
end	# End Light Crawler Tests






































