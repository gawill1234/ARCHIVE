require File.dirname(__FILE__) + '/../helpers/spec_helper'

describe "Velocity Display with express tagging" do
  before(:all) do
    start_new_browser_session
    admin_login
    etc = Collection.new(@vapi, 'exqa-express-tagging-dick-francis')
    etc.clean_crawl
    @project = 'exqa-express-tagging'
  end

  it "should add keyword tag 'alpha' to the first 10 documents on a null query" do
    page.open "#{@query_meta}?v:project=#{@project}"
    page.click "sel-all-top"
    page.click "export-menu-button"
    page.click "//ul[@id='selected-results-menu']/li/span[text() = 'Express tag']", 
      :wait_for => :element, :element => "express-tag-dialog_h" 
    page.type "vivtag-bulk-tag-field", "alpha"
    page.key_press "vivtag-bulk-tag-field", ENTER_KEY
    page.click "bulk-tag-button", :wait_for => :element, :element => "//div[@id='bt-working']/div[@class='success']"
    page.click "//div[@id='bt-working']/div[@class='success']/a[text() = 'See the updated documents']", :wait_for => :page
    page.get_xpath_count("//li[starts-with(@class, 'document')]//div[starts-with(@class, 'tag tag-keyword')]//a[starts-with(@class, 'usertag') and text() = 'alpha']").should eql("10")
  end
  
  it "should set field tag 'status' to 'review' for first 10 documents"
  it "should express all 43 documents matching a null query"
  it "should express express delete all"
  
  # context "with a collection with 'require rights'" do
  #   before(:all) do
  #     # Add 'require-rights' to the search collection configuration and restart indexer
  #     # Add the keyword tag "alpha" to all documents in collection
  #     # Add the keyword tag "beta" to all documents in collection
  #   end
  # 
  #   it "should remove keyword 'beta' from all documents"
  #   it "should remove keyword 'alpha' from all documents"
  #   it "should set field tag 'status' to '' for all documents"
  # end
end