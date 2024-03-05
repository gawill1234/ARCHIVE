#!/usr/bin/env ruby

require "misc"
require "vapi"
require 'make_function_public'

results = TestResults.new('')
results.need_system_report = false

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

def it_create_container_for_ppt_slides(vapi, results)
  input = <<-IN
  <preview>
    <encoded-data><![CDATA[<html><body><div class="ISYS_SLIDE" /></body></html>]]></encoded-data>
  </preview>
  IN

  output = vapi.prepare_document_for_rich_preview(:preview_data => input)
  encoded_data = output.xpath('//encoded-data').first
  html = Nokogiri::HTML(encoded_data.text)

  results.add_equals('<div id="ppt-slider"><div class="ISYS_SLIDE"></div></div>',
                     html.xpath('//div[@id="ppt-slider"]').to_s, "ppt-slider")
end

def it_copies_content_for_other_document_types(vapi, results)
  input = <<-IN
  <preview>
    <encoded-data><![CDATA[<html><body>cats!</body></html>]]></encoded-data>
  </preview>
  IN

  output = vapi.prepare_document_for_rich_preview(:preview_data => input)
  encoded_data = output.xpath('//encoded-data').first
  html = Nokogiri::HTML(encoded_data.text)

  results.add_equals('<html><body>cats!</body></html>', html.xpath('//html').to_s, "html content")
end

publicize_function(vapi, 'prepare-document-for-rich-preview') do
  it_create_container_for_ppt_slides(vapi, results)
  it_copies_content_for_other_document_types(vapi, results)
end

results.cleanup_and_exit!(true)
