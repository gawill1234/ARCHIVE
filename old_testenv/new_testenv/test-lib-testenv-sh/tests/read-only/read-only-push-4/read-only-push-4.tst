#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/read-only'

require 'misc'
require 'config'
require 'collection'
require 'read-only-push'

results = TestResults.new

# Reset the collection broker to it's default config
bc = Broker_Config.new
bc.set('always-allow-one-collection' => 'false', 'maximum-collections' => '0')
msg bc

collection = Collection.new('read-only-push-0')
c2 = Collection.new('read-only-push-0')
results.associate(collection)
collection.delete

msg "Begin enqueues to offline queue ..."
enq_thread = Thread.new {system '$TEST_ROOT/tests/collection-broker/tunable.py -Nread-only-push- -c1 -z 10000'}

# Let the enqueues calls complete. (5 minutes is way long for most targets.)
sleep 300

n_docs_1 = collection.index_n_docs
results.add(n_docs_1 == 0, "index/n-docs is #{n_docs_1} (should be zero).")

msg "Reseting the collection broker to its default config ..."
Thread.new {bc.set}

iterations = 6
iterations.times do |i|
  iteration = i+1
  sleep 2
  msg "Waiting for #{10*iteration}% of the enqueued documents to appear in the index"
  # Detect and fail on no progress here...
  giveup = Time.new + 1200
  while (index_n_docs = collection.index_n_docs) < 1000*iteration and Time.new < giveup do
    sleep 2
  end

  results.add(index_n_docs >= 1000*iteration,
              "index/n-docs is now #{index_n_docs}")

  ro = {}
  ro_thread = Thread.new do
    msg "Asking for read-only mode=enable"
    ro = timed_ro(c2, :enable)
    while ro['acquired'].nil?
      sleep 1
      ro = timed_ro(c2)
    end
    true
  end

  if iteration < iterations
    sleep 30 + 2*iteration
  else
    sleep 2
    msg "Sleeping five minutes, expecting services to idle exit."
    sleep 300
  end

  results.add(ro_thread.join(1), "read only should be acquired by now.")
  sleep 2                       # Allow any exception from ro_thread to print

  crawler_n_offline_queue = collection.crawler_n_offline_queue
  index_n_docs = collection.index_n_docs
  msg "crawler/n_offline_queue=#{crawler_n_offline_queue}, index/n-docs=#{index_n_docs}, leaving #{10000-crawler_n_offline_queue-index_n_docs} unknown"

  crawler_service_status = collection.crawler_service_status
  msg "crawler/service-status is #{crawler_service_status}"
  if iteration < iterations
    results.add(crawler_service_status == 'running',
                "crawler should be running.")
  else
    results.add((crawler_service_status != 'running' or
                 collection.crawler_this_elapsed < 300),
                "crawler should have idle exited.")
  end
  indexer_service_status = collection.indexer_service_status
  msg "indexer/service-status is #{indexer_service_status}"
  if iteration < iterations
    results.add(indexer_service_status == 'running',
                "indexer should be running.")
  else
    results.add((indexer_service_status != 'running' or
                 collection.indexer_running_time < 300),
                "indexer should've idle exited.")
  end

  # For a few iterations, kill off the services.
  if iteration >= iterations-2
    msg "Killing crawler and indexer"
    collection.crawler_kill
    collection.indexer_kill
  end

  # Note that this search will start the collection
  found = collection.broker_search
  msg "Found #{found} documents via search."

  # It'd be nice if these numbers line up, but there are no promises
  msg "Warning: index/n-docs not equal to search result count" if
    index_n_docs != found

  # The (optional) kill and search above might let read-only enable happen;
  # wait a bit.
  sleep 10

  results.add(*fail_files_newer(collection))

  msg "Asking for read-only mode=disable"
  ro = timed_ro(collection, :disable)
  results.add(ro['mode'] == 'disabled', "read-only should be disabled")
end

msg "Waiting for enqueues to complete..."
results.add(enq_thread.join, "Ingested documents in index.")

results.cleanup_and_exit!
