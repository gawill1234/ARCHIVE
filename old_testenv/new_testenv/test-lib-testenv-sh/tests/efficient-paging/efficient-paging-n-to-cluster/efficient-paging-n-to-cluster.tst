#!/usr/bin/env ruby

require 'misc'
require 'velocity/example_metadata'

results = TestResults.new('Test that clustering is affected by the num-to-cluster option')
results.need_system_report = false

collection = ExampleMetadata.new
collection.ensure_correctness

msg "Baseline case, no efficient paging"
res = collection.search(nil, :num => 200, :cluster => true)
results.add_number_equals(1, res.xpath('//tree').size, 'tree node')
reg_cluster_names = res.xpath('//descriptor/@string')

msg "Enable efficient paging"
res = collection.search(nil, :num => 200, :cluster => true, :efficient_paging => true)
results.add_number_equals(1, res.xpath('//tree').size, 'tree node')
eff_cluster_names = res.xpath('//descriptor/@string')

results.add_number_equals(reg_cluster_names.size, eff_cluster_names.size, 'cluster')
reg_cluster_names.size.times do |i|
  reg_name = reg_cluster_names[i].content
  eff_name = eff_cluster_names[i].content

  results.add_equals(reg_name, eff_name, "cluster #{i} name")
end

msg "Set num-to-cluster to 0"
res = collection.search(nil, :num => 200, :cluster => true, :efficient_paging => true, :efficient_paging_n_top_docs_to_cluster => 0)
results.add_number_equals(0, res.xpath('//tree').size, 'tree node')

msg "Set num-to-cluster to 10"
res = collection.search(nil, :num => 200, :cluster => true, :efficient_paging => true, :efficient_paging_n_top_docs_to_cluster => 5)
subset_cluster_names = res.xpath('//descriptor/@string')
results.add(subset_cluster_names.size < reg_cluster_names.size, 'have fewer cluster names', 'should have fewer cluster names')

results.cleanup_and_exit!(true)
