#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/read-only'

require 'misc'
require 'config'
require 'read-only-push'

msg "Starting #{File.basename($0)}"
collection_name = File.basename($0)[0..-5]

# Reset the collection broker to it's default config
Broker_Config.new.set

# read_only_push is most of a test.
# It returns test results, which we add to below.
results = read_only_push(collection_name, true)

# Tolerate errors-high
results.fail_severity = 'error-unknown'

results.cleanup_and_exit!
