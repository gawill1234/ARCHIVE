#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/metasearch'

require 'misc'
require 'parse'

results = TestResults.new('Ensure we can parse a LDAP server')
results.need_system_report = false

easy_parse_ldap(results)

results.cleanup_and_exit!(true)
