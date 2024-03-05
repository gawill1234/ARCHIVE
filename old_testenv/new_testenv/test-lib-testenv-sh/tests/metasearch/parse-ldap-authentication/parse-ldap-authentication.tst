#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/metasearch'

require 'misc'
require 'parse'

results = TestResults.new('Ensure we can parse a LDAP server requiring authentication')
results.need_system_report = false

easy_parse_ldap(results, 'cn=test1,dc=test,dc=vivisimo,dc=com', 'test1')

results.cleanup_and_exit!(true)
