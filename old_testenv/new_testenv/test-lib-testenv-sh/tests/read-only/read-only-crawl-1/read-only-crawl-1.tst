#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/read-only'

require 'misc'
require 'collection'
require 'read-only-files'
require 'time'

results = TestResults.new('During a Samba crawl, repeatedly switch read-only',
                          'between "enabled" and "disabled".')

# start a big crawl
collection = Collection.new("samba-stress")
results.associate(collection)
collection.delete
collection.create("default")

crawler_config = <<XML
  <call-function name="vse-crawler-seed-smb">
    <with name="host"><![CDATA[#{ENV['VIV_SAMBA_LINUX_SERVER']}]]></with>
    <with name="shares"><![CDATA[/#{ENV['VIV_SAMBA_LINUX_SHARE']}/samba_test_data/samba-stress]]></with>
    <with name="username"><![CDATA[#{ENV['VIV_SAMBA_LINUX_USER']}]]></with>
    <with name="password"><![CDATA[#{ENV['VIV_SAMBA_LINUX_PASSWORD']}]]></with>
  </call-function>
XML

xml = collection.xml
xml.xpath("/vse-collection/vse-config/crawler").children.before(crawler_config)
collection.set_xml(xml)

collection.crawler_start
msg "Started initial crawl."

20.times do
  wait_for_n_docs = collection.index_n_docs + 25
  # Wait for a few more docs to appear in the index.
  slept = 0
  while collection.index_n_docs < wait_for_n_docs do
    sleep 1
    slept += 1
    if slept % 100 == 0
      msg "Still waiting: no new docs indexed (read-only mode=#{collection.read_only['mode']})"
    end
    # After more than an hour of waiting, punt
    raise "No indexer progress!" if slept > 60*60
  end
  ro_request = collection.read_only(:enable)
  msg ro_request.inspect
  slept = 0
  while (acquired = collection.read_only['acquired']).nil? do
    sleep 1
    slept += 1
    if slept % 100 == 0
      msg "Still waiting for read_only 'acquired' (read-only mode=#{collection.read_only['mode']})"
      msg "indexer-read-only at #{indexer_read_only(collection)}"
      msg "crawler-read-only at #{crawler_read_only(collection)}"
    end
    # After an hour of waiting, punt
    raise "Pending read-only hang!" if
      Time.now-Time.iso8601(ro_request['requested']) > 60*60
  end
  ro1 = Time.iso8601(acquired)
  msg collection.read_only.inspect
  sleep 10
  ro2 = Time.iso8601(collection.read_only['acquired'])
  results.add(ro1 == ro2,
              "read-only 'acquired' didn't change.",
              "read-only 'acquired' time changed from #{ro1.iso8601} to #{ro2.iso8601}")

  results.add(*fail_files_newer(collection))

  msg "Crawler service-status is '#{collection.crawler_service_status}'"
  while collection.crawler_service_status == 'running' and Time.now-ro1 < 600
    msg "Waiting for crawler to stop ..."
    sleep 1
  end

  results.add(collection.crawler_service_status != 'running',
              "Crawler stopped when read-only enabled.",
              "Crawler still running with read-only enabled.")

  collection.read_only(:disable)
  collection.crawler_start
end

results.cleanup_and_exit!
