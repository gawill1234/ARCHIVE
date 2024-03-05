#!/usr/bin/env ruby

require 'misc'
require 'collection'

results = TestResults.new('crawl-data encoding="base64" does not accept line breaks')

collection = Collection.new('bug-24294')
#collection.delete
collection.create

results.associate(collection)

long_line = File.open('long-line.xml') {|f| f.read}
wrapped_lines = File.open('wrapped-lines.xml') {|f| f.read}

results.add(collection.enqueue_xml(long_line),
            'enqueue crawl-data encoding="base64" with no line breaks')

results.add(collection.enqueue_xml(wrapped_lines),
            'enqueue crawl-data encoding="base64" with line breaks')

results.cleanup_and_exit!
