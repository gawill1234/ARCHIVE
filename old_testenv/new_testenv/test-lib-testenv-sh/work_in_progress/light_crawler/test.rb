$LOAD_PATH << ENV['RUBYLIB']
require 'loader'
require 'benchmark'
require 'light_crawler_helper'

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
  context "Crawl speed" do
  	it "should connect to velocity" do
  		@vapi.should_not be_nil
  	end
  	it "should be similar for light and heavy crawlers" do
  		@original_data = create_original_data
  		@additional_data = create_additional_data
  	end
  
  	it "" do
		 @urls = ['http://vivisimo.com'			 	 ,'http://clusty.com',
			 			  'http://demos.vivisimo.com/' ,'http://en.wikiedia.org/Vivisimo',
							'http://clustermed.info'		 ,'http://www.aboutus.org/ViviSimo.com',
							'http://microsoft.com'			 ,'bing.com',
							'symantec.com'							 ,'networkworld.com']			
			
			@urls.each do |url|
				@vapi.search_collection_enqueue_url({
					:collection => 'light-crawler-test',
					:url => url
				})
			end
  	end
  	it "should store the size of the log.sqlt database" do
  		
  	end
  	it "should delete the list of URLs" do
  	
  	end
  end
end
