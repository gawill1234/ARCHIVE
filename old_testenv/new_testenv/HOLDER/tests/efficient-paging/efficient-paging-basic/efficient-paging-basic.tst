#!/usr/bin/env ruby

require 'misc'
require 'velocity/example_metadata'

results = TestResults.new('Test that results are identical when efficient paging is disabled and enabled')
results.need_system_report = false

collection = ExampleMetadata.new
collection.ensure_correctness

reg_res = collection.search(nil, :num => 200, :efficient_paging => false)
eff_res = collection.search(nil, :num => 200, :efficient_paging => true)

reg_docs = reg_res.xpath('//document')
eff_docs = eff_res.xpath('//document')

results.add_number_equals(reg_docs.size, eff_docs.size, 'document')

reg_docs.size.times do |i|
  reg_doc = reg_docs[i]
  eff_doc = eff_docs[i]

  reg_title = reg_doc.xpath('content[@name="title"]').first
  eff_title = eff_doc.xpath('content[@name="title"]').first
  results.add_equals(reg_title.content, eff_title.content, "title for document #{i}")

  reg_snippet = reg_doc.xpath('content[@name="snippet"]').first
  eff_snippet = eff_doc.xpath('content[@name="snippet"]').first
  results.add_equals(reg_snippet.content, eff_snippet.content, "snippet for document #{i}")
end

results.cleanup_and_exit!(true)
