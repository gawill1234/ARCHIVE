#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/metasearch'

require 'misc'
require 'parse'

results = TestResults.new('Ensure we can parse a LDAP server requiring authentication when the password needs to be escaped')
results.need_system_report = false

easy_parse_ldap(results, 'cn=test2,dc=test,dc=vivisimo,dc=com', '!@#$%^&*()_+')

results.cleanup_and_exit!(true)
