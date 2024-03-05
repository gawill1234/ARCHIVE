#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/'

require 'misc'
require 'late-binding-http-basic'

results = TestResults.new('Ensure the indexer can use a HTTP site protected by HTTP Basic authentication for late-binding security, if the password needs to be escaped')
results.need_system_report = false

# password encrypted due to bug #26135
do_late_binding_http_basic_test(results, 'test2', '[[vcrypt]]+VqqnSvryZPnggxIA0zE1g==')

results.cleanup_and_exit!(true)
