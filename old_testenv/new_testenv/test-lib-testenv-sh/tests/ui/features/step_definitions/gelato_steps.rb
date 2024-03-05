require 'rspec'
require 'term/ansicolor'

Given /^I can access the login page$/ do
  page.open "/cxo/users/sign_in"
  page.check "//input[@id='user_username']"
  page.check "//input[@id='user_password']"
  page.check "//input[@id='user_submit']"
  page.check "//input[@id='user_remember_me']"
  page.get_body_text.should match "Copyright 2011"
end

Given "I login as $username with password $password" do |username, password|
  page.open "http://127.0.0.1:3000"
  page.type "//input[@id='username']", username
  page.type "//input[@id='password']", password
  page.click "//input[@name='commit']", :wait_for => :page
end

Then /^I validate the landing page sections$/ do
  page.get_body_text.should include("Signed in as")
  page.get_body_text.should include("My Activity Feed")
  page.get_body_text.should include("My Accounts")
  page.get_body_text.should include("SOW Hours")
  page.get_body_text.should include("Jira Tasks")
end

Then /^I validate the section "([^"]*)"$/ do |section_header|
  page.get_body_text.should include(section_header)
end


Then /^I validate the "([^"]*") accounts:/ do |table|
   table.hashes.each do |attributes|
     puts attributes
   end
end