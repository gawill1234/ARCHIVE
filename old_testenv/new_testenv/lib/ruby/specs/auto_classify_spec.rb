require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'auto_classify_helper'

ac_collection = 'auto-classify'
data_collection = 'rspec-vivi-site'
project = 'rspec-vivi-site'
display = 'rspec-vivi-site-display'
annotation_name = 'tags'

# TODO: Make all the sleeps more conditional (wait_for_ajax if we start using the new selenium gem, waiting for the collection, while loops that simulate a timeout, etc

describe "Auto Classify" do

  before(:all) do
    start_new_browser_session
    auto_classify_test_setup(data_collection, project, display, "auto-classify", "tags", "other-tags", "2")
    admin_login
  end

  it "should be in the correct state when going there directly and be able to sample successfully" do
   pending "a better way to wait instead of sleep" do
    false.should be_true
=begin commenting this out so that the tests go faster
    page.open "#{@velocity}?v.app=auto-classify"
    page.wait_for_page_to_load(10000)
    page.get_select_options("//div[@id='primary-nav']/select").length.should eql(1)
    page.get_value("id=step1datacollection").should eql("")
    page.get_selected_value("id=step1vsources").length.should eql(0)
    page.get_selected_value("id=step1vproject").length.should eql(0)

    page.type("id=step1datacollection", "sampling-test")
    page.type("id=step1vsources", data_collection)
    page.type("id=step1vproject", project)
    page.click("id=accc-button")
    sleep 3

    # successful save
    page.get_text("id=success-done").should =~ /Your classification has been saved\./

    page.click("link=Return to the configuration screen")
    sleep 10
    page.click("id=acn-button")
    sleep 20

    # successful sampling start (if pre-selected-sources and success, this tests 15189
    page.get_text("id=success-done").should =~ /Auto-classification started/

    page.click("link=See the progress here")
    # results present -- bug 20588 (classes might not be there for a while)
    page.is_element_present("//div[@id='document-list']/ol/li[contains(@class, 'document')]").should be_true
    # classes present (testing bug 15189)
    sleep 30
    page.is_element_present("//div[@id='viv-sidebar']//div[@id='ac-binning']//ul[@id='collection-path-label1']/li[@id='root-label']/div[@id='root-label-children']//div[@class='label clearfix']/a[@class='folder']").should be_true
=end
   end
  end

  it "should arrive from a results page and import a taxonomy" do
    page.open "#{@query_meta}?v:project=#{project}&v:sources=#{data_collection}"
    page.is_element_present("//div[@id='header-links']/ul/li[@class='link-auto-classify']/a[text()='Auto-classify #{data_collection}']").should be_true
    
    page.click "link=Auto-classify #{data_collection}"
    page.wait_for_page_to_load(10000)

    # saved options
    page.get_value("id=step1datacollection").should eql(data_collection)
    page.get_value("//form[@id='ac-config-common-form']//input[@name='data-sources']").should eql("on")
    page.get_value("id=step1vproject").should eql(data_collection)

    # not updating waiting div
    page.get_text("id=time-elapsed").should eql("")

    page.click("id=accc-button")
    sleep 3

    # confirm save
    page.get_text("id=success-done").should =~ /Your classification has been saved\./

    page.click("link=Return to the configuration screen")
    sleep 10
    page.click("id=which-taxonomy")

    # check that taxonomy options toggle
    page.is_visible("id=taxonomy-url").should be_true
    page.is_editable("id=taxonomy-url").should be_true

    page.type("id=taxonomy-url", "http://dev.vivisimo.com/~nichols/taxonomies/sample-taxonomy.xml")
    page.type("id=taxonomy-format", "xml")
    page.click("id=act-button")
    sleep 20

    # successful taxonomy import
    page.get_text("id=success-done").should =~ /Taxonomy import started/

    page.click("link=See the progress here")
    page.wait_for_page_to_load(10000)

    # classes and results present -- bug 20588
    page.is_element_present("//div[@id='viv-sidebar']//div[@id='ac-binning']//ul[@id='collection-path-label1']/li[@id='root-label']/div[@id='root-label-children']//div[@class='label clearfix']/a[@class='folder']").should be_true
    page.is_element_present("//div[@id='document-list']/ol/li[contains(@class, 'document')]").should be_true

  end

end