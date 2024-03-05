#!/usr/bin/env ruby

require 'misc'
require 'collection'

results = TestResults.new('Ensure that term-expanded searches prioritize',
                          'terms that occur more frequently')

c = Collection.new(TESTENV.test_name)
results.associate(c)
c.delete
c.create
c.set_index_options(:block_size => 512,
                    :term_expand_dicts => true,
                    :term_expand_max_expand => 1,
                    :term_expand_max_expand_error => false)

doc = <<XML
<crawl-url status="complete" synchronization="indexed">
  <crawl-data content-type="application/vxml">
    <vxml>
      <document>
        <content name="text" type="text" />
      </document>
    </vxml>
  </crawl-data>
</crawl-url>
XML

doc = Nokogiri::XML(doc).root
content = doc.xpath('//content').first

# Internally, the "count" is estimated based on how many index blocks
# a given term takes, which is why we can't just use 2 copies. 333
# came from manual testing, and depends on the block size set above
doc['url'] = "test://127.0.0.1/hello"
content.content = (['hello ']*333).join
c.enqueue_xml(doc)

doc['url'] = "test://127.0.0.1/hellhound"
content.content = 'hellhound '
c.enqueue_xml(doc)

search_results = c.search("hell*")
docs = search_results.xpath('//document')

results.add_number_equals(1, docs.length, 'document')
results.add_equals('test://127.0.0.1/hello', docs.first['url'], 'document url')

results.cleanup_and_exit!
