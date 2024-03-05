#!/usr/bin/env ruby

require 'misc'
require 'collection'

results = TestResults.new('Bug 28936: Index builder waits on the merger')

def reset_with_slow_merge(c)
  c.delete
  c.create
  xml = c.xml
  set_option(xml, 'vse-index', 'vse-index-option', 'merger-max-rate', '1')
  c.set_xml(xml)
end

def enqueue_a_big_document(c)
  xml = "<crawl-url url='url' status='complete' enqueue-type='reenqueued' synchronization='indexed'><crawl-data content-type='text/plain'>#{(1..1000000).to_a.to_s}</crawl-data></crawl-url>"
  c.enqueue_xml(xml)
end

c = Collection.new('bug-28936')
results.associate(c)

reset_with_slow_merge(c)
enqueue_a_big_document(c)

c.stop

results.cleanup_and_exit!
