require File.dirname(__FILE__) + '/../helpers/spec_helper'

describe "An example Velocity API feature" do
  it "should pass" do
    10.should eql(10)
  end
  
  it "should check for one of two values" do
    actual = 'success'
    actual.should match(/^(success|complete)$/)
  end

  it "should check for the other of two values" do
    actual = 'complete'
  
    # You can't with test an || inside an eql call, so this will not be equal:
    actual.should_not eql('success' || 'complete')

    # You can, however, use a regular expression match if there are multiple possible values:
    actual.should match(/^(success|complete)$/)
  end

  it "should add an option to a crawler configuration" do
    # Just trying to capture the method for adding nodes using nokogiri:
    # crawl_url_status.xpath('/*/crawl-url-status-filter-operation').after('<foo />')
  end
end