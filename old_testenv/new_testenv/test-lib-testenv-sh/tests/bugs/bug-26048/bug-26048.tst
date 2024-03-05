#!/usr/bin/env ruby
#
#

require 'misc'
require 'collection'
require 'testenv'
require 'gronk'
require 'vapi'


# Variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
vapi = Vapi.new(velocity, user, password)

results = TestResults.new('Test bug 26048: Verified that editing query-service configuration does not stop the query-service')

# Start search service
msg "Start search service"
vapi.search_service_start()

# Get existing search service config
msg "Get search service config"
search_service_config = vapi.search_service_get()

# Update config with no changes
msg "Update search service config with no changes"
vapi.search_service_set(:configuration => search_service_config)

# Check status (should be running)
msg "Check service config"
search_status_xml = vapi.search_service_status_xml()
status = 0
search_status_xml.xpath('/vse-qs-status/service-status/@started').each {|node| status += node.to_s.to_i}

results.add(status != 0, "Service started")
results.cleanup_and_exit!
