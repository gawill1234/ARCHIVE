#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# Test: bug-29261
#
# Test that when a crawled samba directory is moved,
# the files in it are removed from the index upon refresh.
# We test for this case by making sure the document
# has no duplicates after refresh.
# The difference between this test and bug-29261-samba.tst
# is that this test has another directory above the directory
# that is moved.  In this case, the seed isn't the directory
# that was moved, but the parent directory to the directory
# that is moved.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'etc'

velocity        = TESTENV.velocity
user            = TESTENV.user
password        = TESTENV.password
BUG_NUMBER      = "bug-29261"
COLLECTION_NAME = "#{BUG_NUMBER}-samba"
CONVERTER_XPATH = "//converters"
SEED_XPATH      = "//crawler"
EXPIRE_TIME     = 0
SEARCH_TERM     = "moveme"
SEED_DIR        = "tmp/bug-29261-#{Etc.getlogin}"
ROOT_DIR        = "/testenv/#{SEED_DIR}"
BASE_OLD_DIR    = "old1"
OLD_DIR         = "old2"
BASE_NEW_DIR    = "new1"
NEW_DIR         = "new2"
FILE_NAME       = "moveme.txt"

vapi = Vapi.new(velocity, user, password)

test_results = TestResults.new(BUG_NUMBER, "Test that when a crawled samba directory is moved, "\
                               "the files in it are removed from the index upon refresh.")

#Create test file
FileUtils.rm_rf(ROOT_DIR)
FileUtils.mkdir(ROOT_DIR)
FileUtils.mkdir("#{ROOT_DIR}/#{BASE_OLD_DIR}")
FileUtils.mkdir("#{ROOT_DIR}/#{BASE_OLD_DIR}/#{OLD_DIR}")
FileUtils.touch("#{ROOT_DIR}/#{BASE_OLD_DIR}/#{OLD_DIR}/#{FILE_NAME}")

# Check that the user has an email address
begin
  vapi.repository_get(:element => "function", :name => "user-email")
rescue VapiException => e # we assume this means the node does not exist
  USER_EMAIL_FUNCTION = <<-HERE
  <function name="user-email" type="public-api">
    <prototype>
      <description>Used to return a user's email, only for testing</description>
      <declare name="user-name" type="string" required="required" />
    </prototype>
    <email process="*">
      <value-of select="viv:user-get($user-name)/user-identity/set-var[@name='user.email']" />
    </email>
  </function>		
HERE

  vapi.repository_add(:node => USER_EMAIL_FUNCTION)
end

if vapi.user_email(:user_name => user).xpath("//email").text.empty?
  test_results.add_failure("Your current user (#{user}) does not have an email address. "\
                          "This test will give a false pass if you run with this user. "\
                          "Please add an email address and run again.")
  test_results.cleanup_and_exit!
end

OLD_SEED_XML = <<-HERE
  <call-function name="vse-crawler-seed-smb">
    <with name="host">testbed5.test.vivisimo.com</with>
    <with name="username">gaw</with>
    <with name="password">[[vcrypt]]TMWiymi8UsQ9QvtqWkxuhw==</with>
    <with name="shares">/testfiles/#{SEED_DIR}/#{BASE_OLD_DIR}</with>
  </call-function>
HERE

NEW_SEED_XML = <<-HERE
  <call-function name="vse-crawler-seed-smb">
    <with name="host">testbed5.test.vivisimo.com</with>
    <with name="username">gaw</with>
    <with name="password">[[vcrypt]]TMWiymi8UsQ9QvtqWkxuhw==</with>
    <with name="shares">/testfiles/#{SEED_DIR}/#{BASE_NEW_DIR}</with>
  </call-function>
HERE

# Create a collection
collection = Collection.new(COLLECTION_NAME, velocity, user, password)
collection.delete
collection.create("default")
test_results.associate(collection)

# Add seed and expires options
xml = collection.xml
xml.xpath(SEED_XPATH).children.before(OLD_SEED_XML)
collection.set_xml(xml)
collection.set_crawl_options({}, {:error_expires     => EXPIRE_TIME,
                                  :uncrawled_expires => EXPIRE_TIME})

# Crawl
collection.crawler_start
collection.wait_until_crawler_stopped #It must be completely stopped before continuing
collection.wait_until_idle

# The document we are going to move should exist
result = collection.search(SEARCH_TERM)
total_results_with_duplicates = result.xpath("//added-source")[0].attr("total-results-with-duplicates").to_i
test_results.add(total_results_with_duplicates == 1,
                 "After crawling, we found the document we are going to move.",
                 "After crawling, expected to find 1 copy of our document - instead there are #{total_results_with_duplicates}")

# Add new seed
xml = collection.xml
xml.xpath(SEED_XPATH).children.before(NEW_SEED_XML)
collection.set_xml(xml)

FileUtils.mkdir("#{ROOT_DIR}/#{BASE_NEW_DIR}")
FileUtils.mv("#{ROOT_DIR}/#{BASE_OLD_DIR}/#{OLD_DIR}", "#{ROOT_DIR}/#{BASE_NEW_DIR}/#{NEW_DIR}")

# Let the expire time run out
sleep(EXPIRE_TIME + 1)

# Refresh
`refresh_crawl -C #{COLLECTION_NAME}`
collection.wait_until_crawler_stopped #It must be completely stopped before continuing
collection.wait_until_idle

# There should only be one copy of the moved document
result = collection.search(SEARCH_TERM)
total_results_with_duplicates = result.xpath("//added-source")[0].attr("total-results-with-duplicates").to_i
test_results.add(total_results_with_duplicates == 1,
                 "After refresh, only 1 copy of the moved document remains in the index.",
                 "After refresh, expected 1 copy of the moved document - instead there are #{total_results_with_duplicates} copies.")

# Cleanup
FileUtils.rm_rf(ROOT_DIR)
test_results.cleanup_and_exit!
