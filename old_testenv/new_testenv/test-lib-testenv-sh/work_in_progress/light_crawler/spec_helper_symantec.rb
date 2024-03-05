require 'loader'

@@test_count = 0
@@feature = ""
@@db_size = ""

Spec::Runner.configure do |config|
  config.before(:all) do		
		@db_size_check = ""
		@urls = ['http://vivisimo.com' ,'http://clusty.com',
 		  'http://demos.vivisimo.com/' ,'http://en.wikiedia.org/Vivisimo',
			'http://clustermed.info'		 ,'http://www.aboutus.org/ViviSimo.com',
			'http://microsoft.com'			 ,'bing.com',
			'symantec.com'							 ,'networkworld.com']
		connect_to_velocity
  end
end

 
    #@original_data = create_original_data
    #@additional_data = create_additional_data
    #@collections = {"light" => "test-light-crawler", 
    #								"heavy" => "test-light-crawler-heavy"}
    #@collections.each_value {|value| light_crawler_test_setup(value) }
    #@light_crawler = Velocity::Collection.new(@vapi, @collections["light"])		
    #@status_query_result = ""
    #@enqueue_response = "" 
		
