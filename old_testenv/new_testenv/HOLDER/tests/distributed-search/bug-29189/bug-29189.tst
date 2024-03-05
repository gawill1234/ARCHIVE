#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/replicated-synch/'
$LOAD_PATH << '.'
require 'misc'
require 'bug-29189-helper'

results = TestResults.new('Ensure that the crawler can be stopped when it experiences distributed indexing port conflicts')
results.need_system_report = false

foo, bar = configure_remote_server_and_client(results)
resume_and_wait_and_stop_crawlers(results, foo, bar)
results.cleanup_and_exit!(true)
