#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'pmap'
require 'misc'
require 'config'
require 'collection'

results = TestResults.new("Test for bug 22346: Transient missing doc during re-enqueue",
                          "Load a smallish collection with collection-broker-enqueue-xml.",
                          "Do many simple queries against the collection, keep result counts.",
                          "Force the collection offline.",
                          "Push five copies of the the same enqueues into the offline queue.",
                          "Allow the collection back online.",
                          "Rerun the same queries repeatedly.",
                          "Demand the same result counts.")

class Search_Results
  WORD_FILE = ENV['TEST_ROOT']+ '/files/top_5k_words'
  WORDS = File.open(WORD_FILE) {|f| f.map {|l| l.strip}}
  SEARCH_THREAD_POOL_SIZE = 50

  def initialize(name)
    @name = name
  end

  def search_results
    WORDS.pmap(SEARCH_THREAD_POOL_SIZE) do |word|
      Collection.new(@name).broker_search(:query => word)
    end
  end

  def initial_search_results
    @counts = search_results
  end

  def check_search_results
    good = true
    WORDS.zip(@counts).peach(SEARCH_THREAD_POOL_SIZE) do |word,count|
      new_count = Collection.new(@name).broker_search(:query => word)
      if count != new_count
        good = false
        msg "Mismatch: original:#{count}, now:#{new_count} '#{word}'"
      end
    end
    good
  end
end

collection = Collection.new('bug-22346-0')
sr = Search_Results.new(collection.name)

bc = Broker_Config.new
msg "Reset collection broker config to the defaults (to allow enqueues)."
bc.set

enqueue_command = "$TEST_ROOT/tests/collection-broker/tunable.py" +
  " -q1 -c1 -z12345 -n50 -e50 -N#{collection.name[0..-2]}"

msg "Initial population of the collection '#{collection.name}' ..."
collection.delete
status = system(enqueue_command)
raise "Populating collection failed!" if not status

msg "Gather initial search result counts ..."
sr.initial_search_results

msg "Tell the collection broker there is no available memory."
bc.set('always-allow-one-collection' => false,
       'check-memory-usage-time' => 0.1,
       'minimum-free-memory' => (256*1024*1024*1024),
       'overcommit-factor' => 0.0001)
msg bc

msg "Re-enqueue everything five times (collection should stay offline)."
5.times do |j|
  pass = "re-enqueue pass #{j+1}"
  results.add(system(enqueue_command), "Offline #{pass}")
  crawler_service_status = collection.crawler_service_status
  results.add(crawler_service_status == 'stopped',
              "Crawler is '#{crawler_service_status}' after #{pass}.")
end

msg "Reset collection broker config to the defaults" +
  "\n\t (to allow offline queue processing and searching in parallel)."
bc.set

collection.broker_start
sleep 10

msg "Rerun queries checking that the result counts stay the same ..."
# Redo the searches several times and demand identical result counts.
j = 0
n_offline_queue = 9999
while n_offline_queue > 100
  j += 1
  n_offline_queue = collection.crawler_n_offline_queue
  pass = "search pass #{j} with n-offline-queue=#{n_offline_queue}"
  results.add(sr.check_search_results,
              "Search results match in #{pass}",
              "Mismatched search results in #{pass}!")
end

msg "Wait for the crawler to idle exit ..."
while collection.crawler_service_status == 'running' do
  sleep 1
end

msg "Recheck search result counts, now that enqueueing is finished."
results.add(sr.check_search_results,
            "Search results match after clearing offline queue",
            "Mismatched search results after clearing offline queue!" +
            "\n\t Is this test broken?")

results.cleanup_and_exit!
