#!/usr/bin/env ruby

require "misc"
require 'velocity/example_metadata'

results = TestResults.new('Test that results are identical when browsing through results when efficient paging is disabled and enabled')
results.need_system_report = false

collection = ExampleMetadata.new
collection.ensure_correctness

reg_res = collection.search(nil, :num => 200, :browse => true, :browse_num => 7, :efficient_paging => false)
eff_res = collection.search(nil, :num => 200, :browse => true, :browse_num => 7, :efficient_paging => true)

reg_links = reg_res.xpath('//link[not(@type)]')
eff_links = eff_res.xpath('//link[not(@type)]')

results.add_number_equals(reg_links.size, eff_links.size, 'navigation link')

reg_file = reg_res.root['file']
eff_file = eff_res.root['file']
document_num = 0

reg_links.size.times do |link_i|
  reg_link = reg_links[link_i]
  eff_link = eff_links[link_i]

  reg_page = collection.vapi.query_browse(:file => reg_file, :state => reg_link['state'])
  eff_page = collection.vapi.query_browse(:file => eff_file, :state => eff_link['state'])

  reg_docs = reg_page.xpath('//document')
  eff_docs = eff_page.xpath('//document')

  results.add_number_equals(reg_docs.size, eff_docs.size, 'document')

  reg_docs.size.times do |doc_i|
    reg_doc = reg_docs[doc_i]
    eff_doc = eff_docs[doc_i]

    reg_title = reg_doc.xpath('content[@name="title"]').first
    eff_title = eff_doc.xpath('content[@name="title"]').first
    results.add_equals(reg_title.content, eff_title.content, "title for document #{document_num}")

    reg_snippet = reg_doc.xpath('content[@name="snippet"]').first
    eff_snippet = eff_doc.xpath('content[@name="snippet"]').first
    results.add_equals(reg_snippet.content, eff_snippet.content, "snippet for document #{document_num}")

    document_num += 1
  end
end

results.cleanup_and_exit!(true)
