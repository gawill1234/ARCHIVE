#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker'

require 'misc'
require 'collection'
require 'config'

results = TestResults.new('Reproduce a crawler hang with many index-atomic',
                          'in an offline queue.')

msg 'Tell the collection broker to not bring collections on-line.'
bc = Broker_Config.new
bc.set('always-allow-one-collection' => 'false', 'maximum-collections' => '0')
msg bc

collection = Collection.new('bug-24495-0')
collection.delete
results.associate(collection)

enqueue_command = ['$TEST_ROOT/tests/collection-broker/tunable.py',
                   '--collection-size=25000',
                   '--collections=1',
                   '--delete-first',
                   '--doc-size=400',
                   '--enqueues=50',
                   '--index-atomic',
                   '--name-base=bug-24495-',
                   '--synchronization=enqueued']


enq_thread = Thread.new {system enqueue_command.join(' ')}

n_offline_queue = 0
while n_offline_queue < 2500 and not enq_thread.join(60-Time.now.to_i%60)
  n_offline_queue = collection.cb_n_offline_queue
  msg "Offline queue size is %d" % n_offline_queue
end

msg 'Allow the collection broker to bring collections on-line.'
bc.set

msg "Waiting for enqueues to complete..."
complete = enq_thread.join(3600)
results.add((complete and enq_thread.value),
            "Ingested documents in index.",
            "Timed out waiting for crawling/indexing. Probably hit the crawler hang: bug 24495.")

results.cleanup_and_exit!
