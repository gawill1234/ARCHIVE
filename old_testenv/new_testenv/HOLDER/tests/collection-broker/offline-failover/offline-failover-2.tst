#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

# Need to disable collection broker reset
ENV['VIVKILLALL'] = 'False'
ENV['VIVWIPE'] = 'False'

require 'misc'
require 'collection'
require 'config'

COUNT = 1000

results = TestResults.new("Second half of an offline enqueue failover test.",
                          "Wait for offline queue to clear of %d documents." % COUNT)

bc = Broker_Config.new
bc.set

c = Collection.new('offline-failover')
# Make sure the collection broker is really running.
c.vapi.collection_broker_start

while (n_docs = c.index_n_docs) < COUNT do
  msg 'Current index size is %d' % n_docs
  sleep 10
end

results.add(c.index_n_docs == COUNT,
            'Index contains all %d documents.' % COUNT,
            'Index "n_docs" is wrong! n_docs=%d' % COUNT)

results.cleanup_and_exit!
