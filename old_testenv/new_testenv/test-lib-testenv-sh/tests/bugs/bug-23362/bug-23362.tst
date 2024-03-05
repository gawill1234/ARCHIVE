#!/usr/bin/env ruby

require 'misc'
require 'collection'

results = TestResults.new('Reproduce indexer crash with output-axl set.')

collection = Collection.new('example-metadata')

collection.crawler_start
collection.indexer_start

axl_node = '<document>
<attribute name="vse-key">
<value-of select="vse:document()/@vse-key" />
</attribute>
</document>'

res = collection.search_total_results(:output_axl => axl_node)

results.add(res > 0,
        "Found #{res} results.")

results.cleanup_and_exit!
