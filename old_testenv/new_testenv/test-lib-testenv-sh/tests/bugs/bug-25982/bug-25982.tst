#!/usr/bin/env ruby

require 'misc'
require 'pmap'
require 'velocity/query-meta'
require 'velocity/example_metadata'

results = TestResults.new('Try to corrupt users.xml',
                          'by pounding parallel queries against query-meta',
                          'with query history recording enabled.')
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
    qm = Velocity::QueryMeta.new(TESTENV.query_meta,
                                 TESTENV.user,
                                 TESTENV.password)
    html = qm.query(:v__sources => c.name, :query => query).body
    [pass, query, html[/<strong>[0-9]*<\/strong> result/]]
  }
  query_results.each {|pass, query, snip|
    results.add(false, "No results found for #{query} in pass #{pass}") if snip == ''
  }
}

results.cleanup_and_exit!
