#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/read-only'

require 'misc'
require 'read-only-files'
require 'collection'
require 'time'

results = TestResults.new("Repeatedly do concurrent stop & read-only enable",
                          "for a collection while it is crawling data.")

# start a big crawl
collection = Collection.new(TESTENV.test_name)
results.associate(collection)
collection.delete
collection.create('default')
collection.add_crawl_seed(:vse_crawler_seed_smb,
                          :host => 'testbed5.test.vivisimo.com',
                          :username => 'gaw',
                          :password => '{vcrypt}TMWiymi8UsQ9QvtqWkxuhw==',
                          :shares => '/testfiles/samba_test_data/samba-stress')
collection.set_index_options(:max_indices => 10)
collection.crawler_start
msg "Started initial crawl."

# Issue a crawler stop and an read-only enable request at about the same time.
def stop_read(name, delay)
  c1 = Collection.new(name)
  c2 = Collection.new(name)
  stop_sleep = 1
  ro_sleep = 1+delay
  stop_thread = Thread.new {sleep stop_sleep; c1.crawler_stop_no_wait}
  ro_thread   = Thread.new {sleep ro_sleep;   c2.read_only(:enable)}
  msg ro_thread.value.inspect
end

# Do lots of stops and read-only-enable, with fuzzed timing.
100.times do |i|
  sleep 30                      # Give the crawler a while to do some work
  stop_read(collection.name, rand-0.5)
  # Wait for read-only to really get here
  waited = 0
  while collection.read_only_pending? and waited < 600 do
    waited += 1
    sleep 1
  end
  msg "Waited #{waited} seconds for read-only mode"
  results.add(*fail_files_newer(collection))
  css = collection.crawler_service_status
  results.add(css != "running", "Crawler service-status is '#{css}'")
  collection.read_only(:disable) if collection.read_only?
  collection.crawler_start
end

results.cleanup_and_exit!
