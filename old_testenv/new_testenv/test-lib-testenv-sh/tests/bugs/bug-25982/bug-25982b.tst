#!/usr/bin/env ruby

require 'misc'
require 'pmap'
require 'velocity/query-meta'
require 'velocity/example_metadata'

results = TestResults.new('Just a sanity check for the real test.',
                          'This variant uses query-search, not query-meta.')
c = ExampleMetadata.new
results.associate(c)
c.ensure_correctness

words = []
open(ENV['TEST_ROOT'] + '/files/example-metadata-words.txt') {|f|
  words = f.readlines
}

5.times {|pass|
  msg "Starting query pass #{pass}"
  query_results = words.pmap {|query|
    myc = Collection.new(c.name)
    count = myc.search_total_results(:query => query)
    [pass, query, count]
  }
  query_results.each {|pass, query, count|
    results.add(false, "No results found for #{query} in pass #{pass}") if count == 0
  }
}

results.cleanup_and_exit!
