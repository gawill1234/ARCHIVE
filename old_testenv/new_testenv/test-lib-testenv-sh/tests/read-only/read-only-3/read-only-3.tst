#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/read-only'

require 'time'
require 'misc'
require 'collection'
require 'read-only-files'

results = TestResults.new('Have a collection running, enter read-only mode,',
                          'change the configuration to update the fast-index',
                          'contents and then restart the indexer.',
                          "Verify that it doesn't change any data.",
                          'Finally: disable read-only and check the fast-index.')

# It would be good to also verify that it is using the new config,
# but that's trickier and I'm not sure how to verify it off hand...

def wrap(stuff)
  '<crawl-urls synchronization="indexed-no-sync" >%s</crawl-urls>' % stuff
end

def bin_check(collection, expect)
  qr = collection.vapi.query_search(:sources => collection.name)
  bin_count = qr.xpath('/query-results/binning/binning-set/bin').length
  [bin_count == expect,
   "#{bin_count} search results were binned.",
   "#{bin_count} search results were binned (expected #{expect})."]
end

CRAWL_URL = '<crawl-url status="complete" url="http://adams/doc-%d" >
<crawl-data content-type="application/vxml-unnormalized"><vxml>
  <document >
    <content name="my.index" >%d</content>
    <content name="my.date" >%s</content>
    <content name="my.content" >Nothing to see here. Move along. My index is &quot;%d&quot;.</content>
</document></vxml></crawl-data></crawl-url>'

COUNT = 10000

c = Collection.new('read-only-3')
results.associate(c)
c.delete
c.create('default-broker-push')

# Setup binning. NOTE: These fields are not yet fast-indexed.
xml = c.xml
vse_index =  xml.xpath("/vse-collection/vse-config/vse-index").first
vse_index.add_child(Nokogiri::XML('
    <binning-sets>
      <binning-set>
        <call-function name="binning-set">
          <with name="select">$my.date</with>
          <with name="label">Date</with>
        </call-function>
      </binning-set>
      <binning-set>
        <call-function name="binning-set">
          <with name="select">$my.index</with>
          <with name="label">Index</with>
        </call-function>
      </binning-set>
    </binning-sets>').root)
c.set_xml(xml)

msg "Collection #{c.name} setup with binning, but no fast-index."

crawl_nodes = wrap((0...COUNT).map {|i| CRAWL_URL %
                     [i, i, (Time.now-i*86400).iso8601, i]}.join("\n"))

results.add(c.enqueue_xml(crawl_nodes), "#{COUNT} documents indexed.")

results.add(*bin_check(c, 0))

c.read_only_enable
msg "read-only: #{c.read_only.inspect}"

# Setup two my fast index fields.
xml = c.xml
set_option(xml, 'vse-index', 'vse-index-option', 'fast-index',
           "my.index|int\nmy.date|date")
c.set_xml(xml)
msg "Added two fields to the fast-index configuration."
c.stop
c.indexer_start
msg "Restarted the indexer."
sleep 20
results.add(*bin_check(c, 0))

results.add(*fail_files_newer(c))

ro_disable = Time.now
c.read_only(:disable)
msg "read-only: #{c.read_only.inspect}"

msg "Wait for the indexer to go idle."
until c.indexer_idle? or Time.now-ro_disable >= 600
  sleep 1
end

results.add(c.indexer_idle?,
            "Indexer is idle.",
            "Indexer remains active.")

results.add(*bin_check(c, 200))

results.cleanup_and_exit!
