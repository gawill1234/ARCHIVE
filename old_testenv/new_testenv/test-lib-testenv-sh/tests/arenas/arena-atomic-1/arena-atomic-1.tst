#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/arenas'

require 'misc'
require 'collection'
require 'arenas-helpers'

CRAWL_NODES = '<crawl-urls synchronization="indexed-no-sync" >
  %s
    <crawl-url status="complete" url="%s" %s>
      <crawl-data content-type="text/plain" encoding="text">
    Nothing to see here. Move along.</crawl-data>
    </crawl-url>
  %s
</crawl-urls>'


def enqueue(collection, atomic, url, arena)
  atomic_open = ''
  atomic_close = ''
  if atomic
    atomic_open = '<index-atomic abort-batch-on-error="true">'
    atomic_close = '</index-atomic>'
  end
  arena_option = 'arena="%s"' % arena
  collection.enqueue_xml(CRAWL_NODES % [atomic_open,
                                        url,
                                        arena_option,
                                        atomic_close])
end

results = TestResults.new('Test arena behavior re-enqueueing the same URL',
                          'to two different arenas in the same collection.',
                          'Related to bug 24308.')

collection = Collection.new('arena-atomic-1')
results.associate(collection)
collection.delete
collection.create
xml = collection.xml
set_option(xml, 'crawl-options', 'crawl-option', 'audit-log', 'all')
collection.set_xml(xml)
configure_arenas(collection, true)

url1 = 'http://adams/one'
url2 = 'http://adams/two'

# Confirm the weird disappearing document behavior.
results.add(enqueue(collection, false, url1, 'arena1'),
            'Initial non-atomic enqueue')
tr = collection.search_total_results(:arena=>'arena1')
results.add(tr == 1,
            'Expected one result, found %d' % tr)
results.add((not enqueue(collection, false, url1, 'arena2')),
            'Non-atomic re-enqueue, different arena, failed as expected',
            'Non-atomic re-enqueue, different arena, unexpected success')
tr = collection.search_total_results(:arena=>'arena1')
results.add(tr == 0,
            'Expected zero results in %s, found %d' % ['arena1', tr])
tr = collection.search_total_results(:arena=>'arena2')
results.add(tr == 0,
            'Expected zero results in %s, found %d' % ['arena2', tr])

# Now, check that atomic indexing avoids deleting the document.
results.add(enqueue(collection, true, url2, 'arena1'),
            'Initial atomic enqueue')
tr = collection.search_total_results(:arena=>'arena1')
results.add(tr == 1,
            'Expected one result, found %d' % tr)
results.add((not enqueue(collection, true, url2, 'arena2')),
            'Atomic re-enqueue, different arena, failed as expected',
            'Atomic re-enqueue, different arena, unexpected success')
tr = collection.search_total_results(:arena=>'arena1')
results.add(tr == 1,
            'Expected one result in %s, found %d' % ['arena1', tr])
tr = collection.search_total_results(:arena=>'arena2')
results.add(tr == 0,
            'Expected zero results in %s, found %d' % ['arena2', tr])

results.cleanup_and_exit!
