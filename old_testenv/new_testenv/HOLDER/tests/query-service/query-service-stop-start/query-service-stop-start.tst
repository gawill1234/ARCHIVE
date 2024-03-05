#!/usr/bin/env ruby

require 'thread'
require 'misc'
require 'velocity/example_metadata'

results = TestResults.new("Test bug 24081: query-service hang during test runs",
                          "While running continuous queries,",
                          "stop and start the query-service.",
                          "The failure mode is a query-service hang.",
                          "NOTE: The query-service will remain hung!")

example_metadata = ExampleMetadata.new
example_metadata.ensure_correctness

# I see higher query success rates with this relatively low thread count.
THREAD_COUNT = 100
threads = (0...THREAD_COUNT).map {
  Thread.new {
    api = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
    args = api.prepare(:query_search, :sources => example_metadata.name)
    while true
      # We use "invoke" to avoid the XML parse and Velocity exception handling.
      api.invoke(args)
    end
  }
}

# We use this queue to send a heart beat after each successful start
# of the query service.
ping_q = Queue.new
ping_q.push(-1)                 # Prefill, so I can do an immediate check below.

stop_start_thread = Thread.new {
  qs_vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  50.times {|j|
    sleep 2
    qs_vapi.search_service_stop
    begin
      qs_vapi.search_service_start
      results.add(true, "Query service restarted")
    rescue => ex
      msg "Query service start failed:\n#{ex}"
      sleep 1
      retry
    end
    # We're good (for now). Tell our monitor...
    ping_q.push(j)
  }
}

# Poll to see if we've heard from the stop/start thread.
PING_TIMEOUT = 300

while stop_start_thread.alive?
  if ping_q.empty?
    results.add(false,
                "Abort: no successful query service start in %d seconds" %
                PING_TIMEOUT)
    stop_start_thread.kill
  end
  ping_q.clear
  # Sleep, unless the stop/start thread is done.
  stop_start_thread.join(PING_TIMEOUT)
end

# Give the target system a chance to do work (like the system report below).
threads.each {|t| t.kill}

results.cleanup_and_exit!
