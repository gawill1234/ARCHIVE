require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'auto_classify_helper'

ac_collection = 'auto-classify'
data_collection = 'rspec-vivi-site'
seed_collection = 'auto-classify-refresh'
project = 'rspec-vivi-site'
display = 'rspec-vivi-site-display'
classification_set_name = 'tag-refresh-test'
annotation_name = 'tags'
other_annotation_name = 'other-tags'

describe "Auto Classify" do

  before(:all) do
    start_new_browser_session
    auto_classify_test_setup(data_collection, project, display, ac_collection, annotation_name, other_annotation_name, "1")
    create_classification_set(classification_set_name, data_collection, project)
    import_taxonomy(classification_set_name, data_collection, project, "http://dev.vivisimo.com/~nichols/taxonomies/search.xml")
    express_tag(classification_set_name, data_collection, project, annotation_name)
  end

  context "Tests" do

    it "should be able to initiate tag refresh through the api" do
     pending "commit for bug 20553" do
      dc = Velocity::Collection.new(@vapi, data_collection)

      # add the new data seed
      additional_seed = Nokogiri::XML "<call-function name=\"vse-crawler-seed-urls\" type=\"crawl-seed\"><with name=\"urls\">http://searchdoneright.com</with><with name=\"hops\">1</with></call-function>"
      dc.add_seed(additional_seed)

      # refresh, this shouldn't be able to tag all the docs
      dc.start_crawl("live", "refresh-inplace")
      dc.wait_for_crawl
      sleep 2
      dc.wait_for_crawl
      sleep 2
      dc.wait_for_crawl

      ((dc.search("NOT CONTENT #{annotation_name}").xpath("/query-results/added-source/@total-results").to_s).to_i > 0).should be_true

      # call the tag refresh api fn
      @vapi.auto_classify_refresh_tags({:collection => data_collection, :classification_set_name => classification_set_name, :annotation_name => annotation_name, :username => @application_user, :project => project})

      sleep 5
      dc.wait_for_crawl

      (dc.search("NOT CONTENT #{annotation_name}").xpath("/query-results/added-source/@total-results").to_s).to_i.should eql(0)
     end
    end

    it "should be able to initiate tag refresh by refreshing another collection with the application as the seed" do
     pending "commit for bug 20553" do
      dc = Velocity::Collection.new(@vapi, data_collection)
      sc = Velocity::Collection.new(@vapi, seed_collection)

      reset_data_collection(data_collection, project, annotation_name)

      dc.wait_for_crawl

      #set up the seed collection
      begin
        sc.delete
      rescue
      end

      sc.create
      refresh_seed = Nokogiri::XML "<call-function name=\"vse-crawler-seed-urls\" type=\"crawl-seed\">
        <with name=\"urls\"><![CDATA[#{@application_url + @velocity}?v.app=auto-classify-refresh-tags&username=#{@application_user}&password=#{@application_password}&v.function=auto-classify-refresh-tags&collection=#{data_collection}&classification-set-name=#{classification_set_name}&annotation-name=#{annotation_name}&project=#{project}]]></with>
        <with name=\"hops\">1</with>
      </call-function>" 
      sc.add_seed(refresh_seed)
      force_recrawl = Nokogiri::XML "<curl-option name=\"force-recrawl\">force-recrawl</curl-option>"
      sc.add_curl_option(force_recrawl)

      sc.start_crawl("live", "refresh-inplace")

      dc.wait_for_crawl

      (dc.search("NOT CONTENT #{annotation_name}").xpath("/query-results/added-source/@total-results").to_s).to_i.should eql(0)

      # add the new data seed
      additional_seed = Nokogiri::XML "<call-function name=\"vse-crawler-seed-urls\" type=\"crawl-seed\"><with name=\"urls\">http://searchdoneright.com</with><with name=\"hops\">1</with></call-function>"
      dc.add_seed(additional_seed)

      # refresh, this shouldn't be able to tag all the docs
      dc.start_crawl("live", "refresh-inplace")
      dc.wait_for_crawl
      sleep 2
      dc.wait_for_crawl
      sleep 2
      dc.wait_for_crawl

      ((dc.search("NOT CONTENT #{annotation_name}").xpath("/query-results/added-source/@total-results").to_s).to_i > 0).should be_true


      # refresh the seed collection
      sc.start_crawl("live", "refresh-inplace")

      sleep 5
      dc.wait_for_crawl

      (dc.search("NOT CONTENT #{annotation_name}").xpath("/query-results/added-source/@total-results").to_s).to_i.should eql(0)
     end

    end

    it "should get an exception when trying to refresh with a nonexistent classification set" do
     pending "commit for bug 20553" do
      lambda {
        @vapi.auto_classify_refresh_tags({:collection => data_collection, :classification_set_name => "aoeuthnsaouethnsaouehtns", :annotation_name => annotation_name, :username => @application_user, :project => project})
      }.should raise_error(Velocity::APIException, /auto-classify-set-not-found/)
     end
    end

    it "should not clear the users' other express tagging operations when clearing the ac annotations" do
     pending "commit for bug 20553" do
      admin_login
      page.open "#{@query_meta}?v:sources=#{data_collection}&v:project=#{project}&query=security"
      page.wait_for_page_to_load(10000)
      page.click "id=sel-all-top"
      page.click "id=select-all-link"
      page.click "id=export-menu-button"
      page.click "//ul[@id='selected-results-menu']//span[contains(text(), 'Express tag')]"
      sleep 2
      page.type("id=vivtag-bulk-#{annotation_name}-field", "aaaa")
      page.type("id=vivtag-bulk-#{other_annotation_name}-field", "bbbb")
      page.click "id=bulk-tag-button"
      sleep 2
      page.click "link=View all of your pending operations"
      page.wait_for_page_to_load(10000)
      page.is_element_present("//table[@class='express-list']//td[@class='query']/ul/li[label[contains(text(), '#{annotation_name}:')] and text()='aaaa']").should be_true
      page.is_element_present("//table[@class='express-list']//td[@class='query']/ul/li[label[contains(text(), '#{other_annotation_name}:')] and text()='bbbb']").should be_true
      @vapi.auto_classify_refresh_tags({:collection => data_collection, :classification_set_name => classification_set_name, :annotation_name => annotation_name, :username => @application_user, :project => project})
      page.open "#{@query_meta}?v:sources=#{data_collection}&v:project=#{project}&query=security"
      page.wait_for_page_to_load(10000)
      page.click "id=sel-all-top"
      page.click "id=export-menu-button"
      page.click "//ul[@id='selected-results-menu']/li/ul/li/span[text()='Express tagging']"
      page.wait_for_page_to_load(10000)
      page.is_element_present("//table[@class='express-list']//td[@class='query']/ul/li[label[contains(text(), '#{annotation_name}:')] and text()='aaaa']").should be_false
      page.is_element_present("//table[@class='express-list']//td[@class='query']/ul/li[label[contains(text(), '#{other_annotation_name}:')] and text()='bbbb']").should be_true
     end
    end
  end

end