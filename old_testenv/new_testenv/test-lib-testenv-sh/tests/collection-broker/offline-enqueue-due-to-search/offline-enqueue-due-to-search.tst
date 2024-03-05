#!/usr/bin/env ruby

# A variant of broker-2 enqueuing test, adding competing searches to
# force the loading collections to stay offline during the
# enqueues. Once the searches end, check that all of the enqueued
# documents appear in each index.

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'collection'
require 'config'
require 'max-online'
require 'misc'
require 'testenv'
require 'time'

start_iso8601 = iso8601

# Make sure the collection broker has it's default settings.
Broker_Config.new.set

step = []

msg "Creating collections for searches"

# Get a bit more than the maximum online collections for search.
# Getting collections for competing searches
test_name = File.basename($0)[/[^.]*/]
max_online, searchers = create_maximum_online_plus(:search, test_name+'-s-')

msg "Frequent searches across #{searchers.length} collections."

end_time = Time.now + 60

search_threads = searchers.map do |x|
  Thread.new(x) do |c|
    while true do
      begin
        c.broker_search
        sleep 1
      rescue
        msg 'Just keep searching...'
      end
    end
  end
end

enqueuer = Collection.new(test_name+'-e-0')
enqueuer.delete

sleep 10                        # Let the searches get to a steady state.

t2 = Thread.new {
  system "$TEST_ROOT/tests/collection-broker/tunable.py -c1 -N#{test_name+'-e-'}"
}

sleep 60

n_docs = enqueuer.index_n_docs
msg "#{n_docs} in enqueuer's index. Stopping searches..."
step << (n_docs == 0)

search_threads.each {|t| t.kill}

# Stop the searching collections (fast)
threads = searchers.map {|x| Thread.new(x) {|c| c.vapi.search_collection_indexer_stop(:collection => c.name)}}

step << t2.value

threads.all? {|t| t.value}
delete_many_collections(searchers)

end_iso8601 = iso8601

msg "System Report from #{start_iso8601} to #{end_iso8601}"
step << system("$TEST_ROOT/lib/system_report.py #{start_iso8601} #{end_iso8601}")
msg "End of System Report"

if step.all?
  msg 'Test passed'
  exit 0
end

msg "Test failed. Steps: #{step.map {|s| s ? 'pass' : 'fail' }.join(', ')}"
exit 1
