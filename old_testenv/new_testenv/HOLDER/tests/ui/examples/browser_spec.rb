require File.dirname(__FILE__) + '/../helpers/spec_helper'

describe "Google Search" do
  before(:all) do
    start_new_browser_session
  end

  ENTER_KEY = "\\13"
  it "can find Selenium" do
    page.open "http://www.google.com"
    page.title.should eql("Google")
    page.type "q", "Selenium seleniumhq #{ENTER_KEY}"
    page.value("q").should eql("Selenium seleniumhq #{ENTER_KEY}")
    sleep 1
    page.text?("seleniumhq.org").should be_true
    page.title.should match(/Google/)
    page.text?("Selenium Documentation").should be_true
    page.element?("link=Cached").should be_true
  end
end
