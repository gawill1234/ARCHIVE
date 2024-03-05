#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/metasearch'

require 'misc'
require 'parse'

results = TestResults.new('Ensure we can parse a HTTP site protected by HTTP Basic authentication when the password needs to be escaped')
results.need_system_report = false

options = {
  :username => 'test2',
  :password => '!@#$%^&*()_+'
}
processed = easy_parse('http://testbed14.test.vivisimo.com/secure/', options)

parses = processed.xpath('//parse')
results.add_number_equals(1, parses.length, 'parse node')

parse = parses.first
results.add_equals("200 OK", parse['http-status'], 'HTTP status')
results.add_parse_status(parse)

results.cleanup_and_exit!(true)
