#!/usr/bin/env ruby

require "misc"
require "vapi"
require 'make_function_public'

results = TestResults.new('Tests the rich-preview-data-for-url function.')
results.need_system_report = false

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

publicize_function(vapi, 'rich-preview-data-for-url') do
  result = vapi.rich_preview_data_for_url(:url => "#{TESTENV.base}/images/zimo-logo.gif")
  results.add_number_equals(1, result.xpath('/preview/encoded-data').count, 'content data node')

  content_type = result.xpath('/preview/content-type').first.text
  results.add_equals('image/gif', content_type, 'content type')

  result = vapi.rich_preview_data_for_url(:url => "#{TESTENV.base}/images/this_image_doesnt_exist.gif")
  results.add_number_equals(0, result.xpath('/preview/encoded-data').count, 'content data node')
end

results.cleanup_and_exit!(true)
