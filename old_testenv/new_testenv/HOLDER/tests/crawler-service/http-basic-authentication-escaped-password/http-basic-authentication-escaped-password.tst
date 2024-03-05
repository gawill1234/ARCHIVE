#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/crawler-service/'

require 'misc'
require 'http-basic-authentication'

results = TestResults.new('Ensure the crawler can access a HTTP site protected by HTTP Basic authentication when the password needs to be escaped')
results.need_system_report = false

do_http_basic_auth_test(results, 'test2', '[[vcrypt]]+VqqnSvryZPnggxIA0zE1g==')

results.cleanup_and_exit!(true)
