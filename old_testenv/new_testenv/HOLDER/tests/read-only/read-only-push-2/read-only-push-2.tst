#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/read-only'

require 'misc'
require 'config'
require 'collection'
require 'read-only-push'

# Reset the collection broker to never start anything.
bc = Broker_Config.new
bc.set('always-allow-one-collection' => 'false', 'maximum-collections' => '0')
msg bc

collection = Collection.new(File.basename($0)[0..-5])

# read_only_push is most of a test.
# It returns test results, which we add to below.
results = read_only_push(collection.name, false)

# Get the system report before doing cleanup.
exit_status = results.report
if exit_status == 0
  # Cleanup after a successful run
  collection.delete
  bc.set
end

exit exit_status
# Note that, after a failed run our collection is sitting around with
# an offline queue size of 1000.
