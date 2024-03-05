#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/arenas'

require 'misc'
require 'collection'
require 'arenas-helpers'

results = TestResults.new('Arena sub-document update was broken and fixed in bug 28879')

def get_vse_hash(c, url = "foo", arena = "LOG_ENTRY")
  qr = c.vapi.query_search(
	 :query => "DOCUMENT:#{url}",
         :sources => c.name,
         :arena => arena,
         :output_axl => '<document key="{vse:doc-hash()}" />', :debug => '1'
       )
  qr.xpath('//document/@key')[0].to_s
end

def wait_for_idle(c)
  until c.indexer_idle?
    sleep 1
  end
end

def enqueue_main_document(c, url = "foo", arena = "LOG_ENTRY")
  c.enqueue_xml("<crawl-url url='#{url}' status='complete' enqueue-type='reenqueued' synchronization='indexed-no-sync' arena='#{arena}'><crawl-data content-type='application/vxml'><vxml><document vse-key='#{url}'><content name='etype'>etype</content></document></vxml></crawl-data></crawl-url>")
end

def enqueue_additional_contents(c, url = "foo", arena = "LOG_ENTRY")
  c.enqueue_xml("<crawl-url url='#{url}.0' status='complete' enqueue-type='reenqueued' synchronization='indexed-no-sync' arena='#{arena}'><crawl-data content-type='application/vxml'><vxml><content name='first' add-to='#{url}'>first</content></vxml></crawl-data></crawl-url>")
end

def delete_additional_contents(c, url = "foo2")
  c.enqueue_xml("<crawl-delete url='#{url}.0' synchronization='indexed-no-sync' />")
end

def single_document_example_from_bug_report(results, c)
  enqueue_main_document(c)
  enqueue_additional_contents(c)
  delete_additional_contents(c)
  wait_for_idle(c)
  results.add_equals('acbd18db4cc2f85cedef654fccc4a4d8', get_vse_hash(c), 'single doc example: key hash should match after deleting additional contents')
end

def multiple_deletes_with_multiple_arenas(results, c)
  # Create documents so that we have interleaved arenas
  # a1, a2, a2, a1
  enqueue_main_document(c, "a1.1", "a1")
  enqueue_main_document(c, "a2.1", "a2")
  enqueue_additional_contents(c, "a1.1", "a1")
  enqueue_main_document(c, "a2.2", "a2")
  enqueue_main_document(c, "a1.2", "a1")
  enqueue_additional_contents(c, "a1.2", "a1")
  enqueue_additional_contents(c, "a2.1", "a2")
  enqueue_additional_contents(c, "a2.2", "a2")
  wait_for_idle(c)

  # Todo, this should be passing a set to delete_additional_contents

  # I need the index-atomic because sometimes there are multiple indexer threads
  # and I want ensure that this is processed as a single merge operation

  c.enqueue_xml("<index-atomic> <crawl-delete url='a1.1.0' synchronization='indexed-no-sync' /> <crawl-delete url='a1.2.0' synchronization='indexed-no-sync' /> <crawl-delete url='a2.1.0' synchronization='indexed-no-sync' /> <crawl-delete url='a2.2.0' synchronization='indexed-no-sync' /> </index-atomic>")
  wait_for_idle(c)

  results.add('' != get_vse_hash(c, "a1.1", "a1"), 'a1.1 should have a key')
  results.add('' != get_vse_hash(c, "a1.2", "a1"), 'a1.2 should have a key')
  results.add('' != get_vse_hash(c, "a2.1", "a2"), 'a2.1 should have a key')
  results.add('' != get_vse_hash(c, "a2.2", "a2"), 'a2.2 should have a key')
end

c = Collection.new('bug-28879')
results.associate(c)
c.delete
c.create
configure_arenas(c, 'true')

single_document_example_from_bug_report(results, c)
multiple_deletes_with_multiple_arenas(results, c)

# Cleanup
c.stop

results.cleanup_and_exit!
