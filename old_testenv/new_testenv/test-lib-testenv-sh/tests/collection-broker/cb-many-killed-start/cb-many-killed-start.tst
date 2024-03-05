#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'misc'
require 'collection'

# Make sure the collection broker is using default setups.
Broker_Config.new.set

collection_count = '1000'
collection_count = ARGV[0] unless ARGV[0].nil?
kill_chunks = '10'
kill_chunks = ARGV[1] unless ARGV[1].nil?

cbhome = ENV['TEST_ROOT']+'/tests/collection-broker'

# Need to make sure the Ruby scripts that we invoke as subprocesses
# don't reset the target system!
ENV['VIVWIPE'] = 'False'

step = []
cmd = ["#{cbhome}/many-killed.rb", collection_count, kill_chunks]
puts cmd.join(' ')
step << system(*cmd)

# Set environment variable for small-sequential-retry-search.py to 
# delete collections at the end of the test
ENV['REMOVECOLLECTIONS'] = "True"

cmd = ["#{cbhome}/small-sequential-retry-search.py"]
puts cmd.join(' ')
step << system(*cmd)

cmd = ["#{cbhome}/many-killed-cleanup.rb", collection_count, kill_chunks]
puts cmd.join(' ')
if system(*cmd)
  msg 'Collections deleted'
else
  msg 'May have failed to delete some of the collections'
end
# Cleanup is not a part of pass/fail criteria for this test.

if step.all?
  msg 'Test passed'
  exit 0
end

msg "Test failed. Steps: #{step.map {|s| s ? 'pass' : 'fail' }.join(', ')}"
exit 1
