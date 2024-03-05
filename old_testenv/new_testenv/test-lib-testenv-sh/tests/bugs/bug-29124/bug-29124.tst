#!/usr/bin/env ruby
#
# Test: Bug-29124
#
# Test that we throw the correct error when failing to
# purge the audit log while in read-only mode.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'nokogiri'

#Constants
velocity          = TESTENV.velocity
user              = TESTENV.user
password          = TESTENV.password
TESTNAME          = "bug-29124"
XPATH_CONFIG      = "//crawler"
XPATH_TOKEN       = "//audit-log-retrieve-response[@token]"
COLLECTION_CONFIG = <<END

<crawl-options>
  <crawl-option name="idle-running-time">-1</crawl-option>
  <crawl-option name="audit-log">all</crawl-option>
</crawl-options>
END
TEST_ENQUEUES     = <<END

<crawl-urls>
  <crawl-url url="fake://foo.bar" enqueue-type="reenqueued">
    <crawl-data encoding="xml" content-type="application/vxml-unnormalized">
      <document>
        <content name="title">Pallbearer</content>
      </document>
    </crawl-data>
  </crawl-url>
  <crawl-url url="fake://baz.bar" enqueue-type="reenqueued">
    <crawl-data encoding="xml" content-type="application/vxml-unnormalized">
      <document>
        <content name="title">Kylesa</content>
      </document>
    </crawl-data>
  </crawl-url>
  <crawl-url url="fake://mumble.bar" enqueue-type="reenqueued">
    <crawl-data encoding="xml" content-type="application/vxml-unnormalized">
      <document>
        <content name="title">Ancient VVisdom</content>
      </document>
    </crawl-data>
  </crawl-url>
</crawl-urls>
END

#Helper Functions
def waiting(collection, state="enabled")
  while (collection.read_only(:status).to_s.match(state) == nil)
    sleep(1)
  end
end


#Test
vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new(TESTNAME,
                               "Test that the correct error is thrown when we "\
                               "attempt to purge the audit-log of a read only "\
                               "collection.")
test_results.need_system_report = false

##0.Initialize collection
collection = Collection.new(TESTNAME, velocity, user, password)
test_results.associate(collection)
collection.delete
collection.create("default")

##1. Update collection configuration
xml = collection.xml
xml.xpath(XPATH_CONFIG).children.before(COLLECTION_CONFIG)
collection.set_xml(xml)

##2. Enqueue Documents, Retrieve Audit Log Token
collection.enqueue_xml(TEST_ENQUEUES)
token = collection.audit_log_retrieve.xpath(XPATH_TOKEN).attr("token")

##3. Enable Read-Only Mode
collection.read_only(:enable)
waiting(collection)

##4. Attempt to Purge Audit Log
failed = false
begin
  collection.audit_log_purge(token)
rescue Exception => e
  failed = true
  test_results.add(e.to_s.match("SEARCH_ENGINE_READ_ONLY") != nil,
                   "We correctly failed to purge the audit log because of read"\
                   "only mode.",
                   "We encountered an unexpected failure:\n#{e}")
end
test_results.add(failed,
                 "We successfully prevented the audit-log purge for occurring "\
                 "in read-only mode.",
                 "We failed to maintain read-only mode security and purged the"\
                 " audit log.")

##5. Exit read-only mode
collection.read_only(:disable)
waiting(collection, "disabled")

#Cleanup
test_results.cleanup_and_exit!
