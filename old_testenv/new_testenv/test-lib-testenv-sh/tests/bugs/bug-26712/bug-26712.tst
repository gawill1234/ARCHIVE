#!/usr/bin/env ruby

require 'misc'
require 'collection'
require 'gronk'
require 'nokogiri'

begin
  results = TestResults.new('Test bug 26712: term-expansion dictionary',
                            'does not properly load blank lines')

  # Create search collection
  msg "Creating search collection: bug-26712"
  collection = Collection.new("bug-26712")
  results.associate(collection)
  collection.delete()
  collection.create()
  # Update to turn on term expansion dictionaries
  xml_to_update = File.open("bug-26712.xml") {|xml_file|
    Nokogiri::XML(xml_file)
  }

  collection.set_xml(xml_to_update)

  # Start crawl and let finish
  msg "Crawling Collection"
  collection.crawler_start

  collection.wait_until_idle()

  msg "Replacing wildcard dictionary"
  collection.stop

  path = collection.crawl_path_list()
  gronk = Gronk.new
  if (TESTENV.windows == true)
    gronk.rm_file(path[0]+"\\expansions\\fcda265486028e353be9954f4e6ccfc4")
    gronk.send_file("fcda265486028e353be9954f4e6ccfc4",
                    path[0]+"\\expansions\\fcda265486028e353be9954f4e6ccfc4")
  else
    gronk.rm_file(path[0]+"/expansions/fcda265486028e353be9954f4e6ccfc4")
    gronk.send_file("fcda265486028e353be9954f4e6ccfc4",
                    path[0]+"/expansions/fcda265486028e353be9954f4e6ccfc4")
  end

  msg "Checking indexer status"
  collection.indexer_start

  status_xml = collection.status
  msg status_xml
  results.add_equals("running",
                     collection.vse_index_status[:service_status],
                     "Indexer service_status=running")

  results.cleanup_and_exit!
end
