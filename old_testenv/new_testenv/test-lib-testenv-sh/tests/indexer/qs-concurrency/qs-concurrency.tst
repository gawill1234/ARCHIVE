#!/usr/bin/env ruby

require 'thread'
require 'time'
require 'misc'
require 'collection'

def wrap(stuff)
  '<crawl-urls synchronization="indexed-no-sync" >%s</crawl-urls>' % stuff
end

def run_query_until_finished(c, results, thread, cond, msg)
  last_count = 0
  last_time = nil

  while thread.alive?
    msg "Running query..."
    start = Time.now
    begin
      count = c.search_total_results
    rescue
      results.add(false,
                  "Error while querying for results.")
    end
    time = Time.now - start
    if not last_time
      # Make the first query always pass
      last_count = count
      last_time = time
    end

    msg "Found #{count} results, query took #{time} seconds."
    if ! cond.call(count - last_count, time.to_f / last_time.to_f)
      results.add(false, msg % [count, last_count, time, last_time*10])
    end

    last_count = count
    last_time = time
    sleep 10
  end
end

results = TestResults.new('Enqueue data to collection and continuously ',
                          'perform searches.  Time to search should not ',
                          'increase significantly during enqueues. ',
                          'Afterwards, delete all content and check ',
                          'the same criteria.')


COUNT = 500
CRAWL_URL = '<crawl-url status="complete" url="http://lince/doc-%d">
<crawl-data content-type="application/vxml-unnormalized"><vxml>
   <document >
     <content name="doc-id" >%d</content>
     <content name="date" >%s</content>
     <content name="text" >Nothing to see here.  My doc id is &quot;%d&quot;.</content>
</document></vxml></crawl-data></crawl-url>'

CRAWL_DELETE = '<crawl-delete url="http://lince/doc-%d" />'

c = Collection.new('qs-concurrency')
c2 = Collection.new('qs-concurrency')
c.delete
c.create
results.associate(c)

msg "Beginning crawl-url enqueue."
thread = Thread.new {
  (0...COUNT).map {|i| 
    ok = c2.enqueue_xml(wrap(CRAWL_URL % 
                             [i, i, (Time.now-i*86400).iso8601, i])) 
    if not ok
      results.add(false,
                  'Failed to enqueue doc %d' % i)
    end
  }
  Thread.exit
}

# Configure multiple ranking threads
c.set_index_options(:threads_per_query => 8,
                    :min_docs_per_thread => 50)

msg = "Query failed.  Found %d queries, expected at least %d.  Query took %f seconds, expected at most %f seconds."
cond = lambda {|count, time|
  # If we got less results than last time, fail
  if count < 0
    return false
  end

  # If query took longer than 10 times from last time, fail
  if time > 10
    return false
  end

  true
}
run_query_until_finished(c, results, thread, cond, msg)

# Wait until indexer is idling, i.e. no more docs coming in
until c.indexer_idle? and c.crawler_idle?
  sleep 1
end

count = c.search_total_results
results.add(count == COUNT,
            "Found #{count} entries in indexer.",
            "Found #{count} entries in indexer, expected #{COUNT}.")


msg "Enqueuing crawl deletes for all URLs."
thread = Thread.new {
  (0...COUNT).map {|i| 
    ok = c2.enqueue_xml(wrap(CRAWL_DELETE % i))
    if not ok
      results.add(false,
                  'Failed to delete doc %d' % i)
    end
  }
  Thread.exit
}

msg = "Query failed.  Found %d queries, expected at most %d.  Query took %f seconds, expected at most %f seconds."
cond = lambda {|count, time|
  # If we got less results than last time, fail
  if count > 0
    return false
  end

  # If query took longer than 10 times from last time, fail
  if time > 10
    return false
  end

  true
}
run_query_until_finished(c, results, thread, cond, msg)

# Wait until indexer is idling, i.e. no more docs coming in
until c.indexer_idle? and c.crawler_idle?
  sleep 1
end

count = c.search_total_results
results.add(count == 0,
            "Found #{count} entries in indexer.",
            "Found #{count} entries in indexer, expected 0.")

results.cleanup_and_exit!
