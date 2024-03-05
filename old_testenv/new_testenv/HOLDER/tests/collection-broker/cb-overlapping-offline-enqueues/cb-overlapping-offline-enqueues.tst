#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'misc'
require 'collection'

collection = Collection.new('cb-tunable-0')
collection.delete

start_iso8601 = iso8601

bc = Broker_Config.new
bc.set('always-allow-one-collection' => 'false', 'maximum-collections' => '0')
msg bc

t1 = Thread.new {
  system '$TEST_ROOT/tests/collection-broker/tunable.py -c1'
}

sleep 2

t2 = Thread.new {
  system '$TEST_ROOT/tests/collection-broker/tunable.py -c1'
}

if collection.crawler_service_status == 'running'
  raise 'Crawler running when it should not be!'
end

sleep 60

if collection.crawler_service_status == 'running'
  raise 'Crawler running when it should not be!'
end

msg 'Revert the collection broker settings to the defaults.'
bc.set

s1 = t1.value
s2 = t2.value

end_iso8601 = iso8601

msg "System Report from #{start_iso8601} to #{end_iso8601}"
s3 = system "$TEST_ROOT/lib/system_report.py #{start_iso8601} #{end_iso8601}"
msg "End of System Report"

if s1 and s2 and s3
  msg 'Test passed'
  exit 0
end

msg "Test failed #{s1} #{s2} #{s3}"
exit 1
