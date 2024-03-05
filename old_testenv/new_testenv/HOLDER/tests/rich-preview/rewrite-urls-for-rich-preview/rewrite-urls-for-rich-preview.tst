#!/usr/bin/env ruby

require "misc"
require "vapi"
require 'make_function_public'

results = TestResults.new('Tests the rewrite-urls-for-rich-preview function.')
results.need_system_report = false

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

def it_rewrites_urls_in_image_src_attributes(vapi, results)
  input = <<-IN
  <preview>
    <encoded-data><![CDATA[<html><body><p>Simple image</p><img src="1.jpg" /></body></html>]]></encoded-data>
  </preview>
  IN

  output = vapi.rewrite_urls_for_rich_preview(:preview_data => input, :file => 'viv_1234', :key => 'thekey')
  encoded_data = output.xpath('//encoded-data').first
  html = Nokogiri::HTML(encoded_data.text)

  results.add_equals('?v.app=rich-preview&v.file=viv_1234&key=thekey&filename=1.jpg&', html.xpath('//img').first['src'], "image source")
end

def it_rewrites_urls_in_style_attributes(vapi, results)
  input = <<-IN
  <preview>
    <encoded-data><![CDATA[<html><body><div style="zoom:1; background-image:url(drawing_0.png); margin: 0; " /></body></html>]]></encoded-data>
  </preview>
  IN

  output = vapi.rewrite_urls_for_rich_preview(:preview_data => input, :file => 'viv_1234', :key => 'thekey')
  encoded_data = output.xpath('//encoded-data').first
  html = Nokogiri::HTML(encoded_data.text)

  results.add_equals('zoom:1; background-image:url(?v.app=rich-preview&v.file=viv_1234&key=thekey&filename=drawing_0.png&); margin: 0', html.xpath('//div').first['style'], "CSS background image")
end

def it_preserves_the_content_type(vapi, results)
  input = <<-IN
  <preview>
    <content-type>text/html</content-type>
  </preview>
  IN

  output = vapi.rewrite_urls_for_rich_preview(:preview_data => input, :file => '', :key => '')
  content_type = output.xpath('//content-type').first.text

  results.add_equals('text/html', content_type, 'content type')
end

publicize_function(vapi, 'rewrite-urls-for-rich-preview') do
  it_rewrites_urls_in_image_src_attributes(vapi, results)
  it_rewrites_urls_in_style_attributes(vapi, results)
  it_preserves_the_content_type(vapi, results)
end

results.cleanup_and_exit!(true)
