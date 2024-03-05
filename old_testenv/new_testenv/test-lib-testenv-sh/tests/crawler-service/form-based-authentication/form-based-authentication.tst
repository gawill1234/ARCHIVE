#!/usr/bin/env ruby
require 'misc'
require 'collection'

FORM_HANDLER_XML = <<XML
<call-function name="vse-crawler-form-authentication">
  <with name="form-authentication-root">#{TESTENV.admin}</with>
  <with name="form-authentication-steps">
    <form xpath="//form[@name='login']">
      <parameter name="username" value="#{TESTENV.user}" />
      <parameter name="password" value="#{TESTENV.password}" />
    </form>
  </with>
</call-function>
XML
ALLOW_EXE_CRAWL_XPATH = <<XML
/vse-collection/vse-config/crawler/call-function[@name='vse-crawler-binary-file-extensions']
XML
ALLOW_EXE_CRAWL = <<XML
<with name='extensions-to-keep'>*.exe</with>
XML

test_results = TestResults.new("This test performs a crawl of the Velocity",
                               "Admin Tool to test the new form-handler logic.")
test_results.need_system_report = false

collection = Collection.new(TESTENV.test_name)
test_results.associate(collection)

collection.delete
collection.create("default")
collection.add_crawl_seed(:vse_crawler_seed_urls,
                          {:urls => TESTENV.admin,
                           :hops => 1})

xml = collection.xml
xml.xpath("/vse-collection/vse-config/crawler").children.before(FORM_HANDLER_XML)
xml.xpath(ALLOW_EXE_CRAWL_XPATH).first.add_child(ALLOW_EXE_CRAWL)
collection.set_xml(xml)

collection.crawler_start

collection.wait_until_idle

test_results.add(collection.index_n_docs > 1,
                 "Successfully handled the HTML form and crawled the admin tool.",
                 "Failed to make it past the login form of the admin tool.")

test_results.cleanup_and_exit!
