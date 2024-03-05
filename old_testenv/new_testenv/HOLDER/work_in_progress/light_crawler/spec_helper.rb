require 'loader'

@@test_count = 0
@@feature = ""

Spec::Runner.configure do |config|
  config.before(:all) do
    @verbose = (ENV['VERBOSE']) ? true : false
    @quiet = !@verbose
    #create_selenium_driver
    cgi_paths
    setup_vapi
    setup_query_meta
 
    @original_data = create_original_data
    @additional_data = create_additional_data
    @collections = {"light" => "test-light-crawler", 
    								"heavy" => "test-light-crawler-heavy"}
    @collections.each_value {|value| light_crawler_test_setup(value) }
    @light_crawler = Velocity::Collection.new(@vapi, @collections["light"])		
    @status_query_result = ""
    @enqueue_response = ""    
  end
  
  #config.before(:each) do
  #  current_feature = self.class.description
  #  if @@feature != current_feature
  #    #vlog "Testing Feature: #{current_feature}", { :hide_caller => true, :prefix => '== ' }
  #  end
  #  @@test_count += 1
  #  verbose_message = "#{@@test_count}) #{self.description} [#{current_feature}]\n"
  #  #vlog verbose_message, { :hide_caller => true, :prefix => '===== ' }

  #  @@feature = current_feature
  #end

  # The system capture need to happen BEFORE the closing the Selenium session 
  #config.append_after(:all) do
  #  @selenium_driver.close_current_browser_session
  #end
end
