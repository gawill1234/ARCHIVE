#!/usr/bin/env ruby
# Test: bug-20648
#
# Test that the crawler rejects URLs of size >= 500 bytes
# in light-crawler-mode

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'collection'
require 'misc'

#Constants
velocity       = TESTENV.velocity
user           = TESTENV.user
password       = TESTENV.password
N_GOOD_URLS    = 50
N_BAD_URLS     = 10
TESTNAME       = "bug-20648"
XPATH_CRAWLER  = "/vse-collection/vse-config/crawler"
DEFAULT_CONFIG = <<END
<crawl-options>
  <crawl-option name="default-allow">allow</crawl-option>
  <crawl-option name="idle-running-time">-1</crawl-option>
</crawl-options>
END
CRAWL_URL = <<END
<crawl-url url="%s" enqueue-type="reenqueued" status="complete">
  <crawl-data encoding="xml" content-type="application/vxml-unnormalized">
    <document>
      <content name="title">%d Bytes</content>
    </document>
  </crawl-data>
</crawl-url>
END

=begin
Setting DEBUG to 'true' will cause the test to fail, but it will also print a
lot more information to help determine the cause of a problem in the test.
=end
DEBUG = false


#Helper Functions

def gen_url(length)
  "fake://".ljust(length,'riitiir')
end

def gen_good_crawl_urls
  urls = {}
  N_GOOD_URLS.times do |i|
    url = gen_url(i*10)
    urls[url.length] = CRAWL_URL % [url, url.length]
  end
  urls
end

def gen_bad_crawl_urls
  urls = {}
  N_BAD_URLS.times do |i|
    url = gen_url((i+50)*10)
    urls[url.length] = CRAWL_URL % [url, url.length]
  end
  urls
end

#Class Extension
class LightCollection < Collection
  def enqueue_good?(resp)
    if DEBUG
      puts resp
    end
    resp.name == 'crawler-service-enqueue-response' and
      resp['error'].nil? and
      resp['n-failed'].to_s === "0" and
      resp['n-success'].to_s === "1"
  end
end

#Test
##0. Intialize Test
test_results = TestResults.new(TESTNAME,
                               "Test that in light crawler mode we reject urls"\
                               " with URL lengths longer than 500.")

if not DEBUG
  test_results.need_system_report = false
end

collection = LightCollection.new(TESTNAME, velocity, user, password)
light_collection = LightCollection.new(TESTNAME + "-light", velocity, user,
                                       password)
test_results.associate(collection)
test_results.associate(light_collection)

##1. Initialize Collections
collection.delete
collection.create("default")
xml = collection.xml
xml.xpath(XPATH_CRAWLER).children.before(DEFAULT_CONFIG)
collection.set_xml(xml)

light_collection.delete
light_collection.create("default-push")

##2. Perform Enqueue of URLs that should always succeed
good_crawl_urls = gen_good_crawl_urls

reg_failures = 0
light_failures = 0

good_crawl_urls.each do |length, good_url|
  if not collection.enqueue_xml(good_url)
    test_results.add_failure("Failed to enqueue a url of length #{length} to a"\
                             " regular crawler.")
    reg_failures += 1
  end
  if not light_collection.enqueue_xml(good_url)
    test_results.add_failure("Failed to enqueue a url of length #{length} to a"\
                             " light crawler.")
    light_failures +=1
  end
end
test_results.add(reg_failures == 0,
                 "Successfully enqueued all URLs of length < 500 to regular cr"\
                 "awler",
                 "Failed to enqueue #{reg_failures} URLs of length < 500 to th"\
                 "e regular crawler.")

test_results.add(light_failures == 0,
                 "Successfully enqueued all URLs of length < 500 to light craw"\
                 "ler",
                 "Failed to enqueue #{light_failures} URLs of length < 500 to "\
                 "the light crawler.")

##3. Perform Enqueue of URLS that should fail in light crawler mode
reg_failures = 0
light_successes = 0

bad_crawl_urls = gen_bad_crawl_urls
bad_crawl_urls.each do |length, bad_url|
  if not collection.enqueue_xml(bad_url)
    test_results.add_failure("Failed to enqueue a url of length #{length} to a"\
                             " regular crawler.")
    reg_failures += 1
  end
  if light_collection.enqueue_xml(bad_url)
    test_results.add_failure("We should not be able to enqueue a url of length"\
                             " #{length} to a light crawler, but it succeeded.")
    light_successes +=1
  end
end

test_results.add(reg_failures == 0,
                 "Successfully enqueued all URLs of length >= 500 to regular c"\
                 "rawler",
                 "Failed to enqueue #{reg_failures} URLs of length >= 500 to t"\
                 "he regular crawler.")

test_results.add(light_successes == 0,
                 "Successfully failed to enqueue any URLs of length >= 500 to "\
                 "the light crawler",
                 "Failed to throw an exception for #{light_successes} URLs"\
                 " of length >= 500 enqueued to the light crawler.")

#Cleanup
test_results.cleanup_and_exit!
