#!/usr/bin/env ruby
# Test: Bug-27340
#
# Test that search-collection-audit-purge no longer crashes
# w3wp.

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'collection'
require 'misc'
require 'nokogiri'

#variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password

#Constants
N_URLS = 20
DEBUG = false # set to true to turn on debug printing
BASE_URL = "fake://foo.bar"
XPATH_AUDITLOG = "//audit-log-retrieve-response"
XPATH_INDEX = "//vse-index"
INDEX_OPTION = "<vse-index-option name=\"idle-exit\">60</vse-index-option>"
ASPX_URL = URI("http://lemon.devel.vivisimo.com/vivisimo-bdewan-8.0-4/asp/velocity.aspx")

#Helpers
def gen_url
  return "" << BASE_URL << "/foo"
end

def gen_crawl_url (url)
  crawl_url = "" << "<crawl-url url=\"" << url << "\">\n"
  crawl_url << "<crawl-data content-type=\"application/vxml-unnormalized"
  crawl_url << "\">\n<vxml><document><content name=\"title\">" << url
  crawl_url << "</content></document></vxml>\n</crawl-data>\n"
  crawl_url << "</crawl-url>\n"
end

def gen_crawl_urls
  crawl_urls = ""
  N_URLS.times { |url| crawl_urls << gen_crawl_url(gen_url) }
  return crawl_urls
end

def debug(expl, separator, retval)
  if DEBUG
    puts "#{expl}#{separator}#{retval}"
  end
end

#1. Create a default-push collection
vapi = Vapi.new(ASPX_URL, user, password)
test_results = TestResults.new("bug-27340",
                               "Test that search-collection-audit-log-purge"\
                               " does not crash w3wp")
collection = Collection.new("bug-27340", velocity, user, password)
collection.delete
collection.create("default")
collection.add_crawl_seed(:vse_crawler_seed_urls, :urls => BASE_URL)
collection.set_crawl_options({:audit_log, "all"}, [])
collection.set_crawl_options({:audit_log_detail, "full"}, [])

cxml = Nokogiri::XML(collection.xml.to_s)

index_xml = cxml.xpath(XPATH_INDEX)
debug("Index Data Before:","\n", index_xml.to_s)

index_xml.children.before(INDEX_OPTION)
debug("Index Data Prior:", "\n", index_xml.to_s)

collection.set_xml(cxml)
collection.crawler_start
collection.indexer_start

#2. Push a punch of url's
debug("Enqueue Response:", " ", collection.enqueue(gen_crawl_urls))

#3. Set the collection to read-only
retval = collection.read_only(:enable)
i = 0
while (retval.to_s.match("enabled") == nil)
  sleep(1)
  debug("Attempt #{i += 1}", " ", retval)
  retval = collection.read_only(:status)
end

#4. Retrieve the audit log (parse for the token)
token = Nokogiri::XML(collection.audit_log_retrieve.to_s)
token = token.xpath(XPATH_AUDITLOG).attr("token")
debug("Audit Log Token:", " ", token)

#5. wait long enough for the collection-service to idle out
sleep(100)

#6. set the collection to read/write
debug("Set to Read/Write:", " ", collection.read_only(:disable))

#7. purge the audit log
begin
  retval = collection.audit_log_purge(token)
rescue Exception => e
  debug("Failed to Leave Read Only Mode with Error:", "\n", e.to_s)
  if (e.to_s.match("exception") != nil)
    test_results.add_failure("Threw an exception after failing to leave "\
                             "read_only mode. That said, the process did"\
                             " not crash.")
  else
    test_results.add_failure("A Fatal Error has crashed a velocity"\
                             " process. The bug hasn't been fixed");
  end
else
  debug("Purge Log:", "\n", retval)
end
test_results.add_success("Successfully exited read-only mode while"\
                         " the collection-service was not running!")

collection.delete
test_results.cleanup_and_exit!
test_results.last_step
