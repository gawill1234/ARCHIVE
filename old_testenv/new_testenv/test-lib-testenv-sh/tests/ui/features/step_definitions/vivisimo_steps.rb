Given /^I am logged in to velocity admin$/ do
  admin_login
end

When /^I go to the Management section of admin$/ do
  page.click "//span[@id='masthead-menu-management-button']//a", :wait_for => :page
end

When /^I click on the IO Pro tab$/ do
  page.click "//a[text() = 'IO Pro']", :wait_for => :page
end

When /^I click on the Administration button$/ do
  page.click "//td[@id='work-panel']//a[text() = 'Administration']", :wait_for => :popup
end

When /^I switch to the IO Pro tab$/ do
  page.all_window_titles.should include("IO Pro")
  page.select_pop_up("null")
end

Then /^I should see "([^"]*)"$/ do |arg1|
  page.get_body_text.should match /#{arg1}/
end

When /^I click on the Users button$/ do
   page.click "//a[text() = 'Users']", :wait_for => :page
end

When /^I click on the Create Users button$/ do
  page.click "//a[@class='link_button']", :wait_for => :page
end

When /^I enter new user information$/ do
  page.type "user[login]", "admin_user"
  page.type "user[password]", "admin_pw"
  page.type "user[password_confirmation]", "admin_pw"
  page.type "user[first_name]", "admin"
  page.click "//input[@value='Add User']", :wait_for => :page
end

When /^I add all roles to a user account$/ do
  page.click "//tr[child::td='admin_user']//td[child::a='edit roles']//a[text()='edit roles']", :wait_for => :page
  page.check "//input[@id='user_spotlight_permissions_attributes_ids_2']"
  page.check "//input[@id='user_term_permissions_attributes_ids_5']"
  page.check "//input[@id='user_admin_permissions_attributes_0_role_id']"
  page.check "//input[@id='user_admin_permissions_attributes_1_role_id']"
  page.click "//input[@value='Update']", :wait_for => :page
  page.click "//tr[child::td='admin_user']//td[child::a='edit roles']/a/@onclick", :wait_for => :page
  page.check "//input[@id='user_spotlight_promoter']"
  page.check "//input[@id='user_spotlight_collection_manager']"
  page.check "//input[@id='user_term_promoter']"
  page.check "//input[@id='user_term_collection_manager']"
  page.click "//input[@value='Update']", :wait_for => :page
end

When /^I add spotlight manager roles to the account$/ do
  page.click "//div[@id='main']/div/table/tbody/tr[2]/td[3]//a[text()='edit roles']", :wait_for => :page
  page.check "//input[@id='user_spotlight_permissions_attributes_ids_2']"
  page.check "//input[@id='user_spotlight_promoter']"
  page.check "//input[@id='user_spotlight_collection_manager']"
  page.click "//input[@value='Update']", :wait_for => :page

end

When /^I add terminology manager roles to the account$/ do
  page.click "//a//tr[child::td='admin_user']//td[child::a='edit roles']", :wait_for => :page
  page.check "//input[@id='user_term_permissions_attributes_ids_5']"
  page.check "//input[@id='user_term_promoter']"
  page.check "//input[@id='user_term_collection_manager']"
  page.click "//input[@value='Update']", :wait_for => :page
end

Given /^I log in to IO Pro$/ do
    iopro_login
end

When /^I create a spotlight manager user$/ do |arg1|
  page.click "//div[@id='main']/div/table/tbody/tr[2]/td[3]//a[text()='edit roles']", :wait_for => :page
  page.check "//input[@id='user_spotlight_permissions_attributes_ids_2']"
  page.check "//input[@id='user_spotlight_promoter']"
  page.check "//input[@id='user_spotlight_collection_manager']"
  page.click "//input[@value='Update']", :wait_for => :page
end

When /^I create a New Spotlight$/ do
  page.click "//a[text() = 'Enter Spotlight Manager']", :wait_for => :page
  page.click "//a[content() = 'Create a New Spotlight']", :wait_for => :page
end