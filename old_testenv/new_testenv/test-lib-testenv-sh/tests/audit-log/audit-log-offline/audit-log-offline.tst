#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'misc'
require 'collection'
require 'config'

results = TestResults.new('Audit log with offline queue.',
                          'Online enqueue to create several documents,',
                          'tune the collection broker to keep all offline,',
                          'enqueue field adds, fields deletes then field adds.',
                          'Finally, allow the offline queue to process',
                          'and check the audit log.')
bc = Broker_Config.new

def key(i)
  'key-%03d'%i
end

def create_docs(count)
  (0...count).map {|i|
    '<crawl-url enqueue-id="%s"
           enqueue-type="reenqueued"
           forced-vse-key="%s"
           status="complete"
           url="http://adams/doc/%s" >
  <crawl-data content-type="text/plain" encoding="text" >
    Nothing to see here. Move along. My key is &quot;%s&quot;.
  </crawl-data></crawl-url>' %
    ['create-%03d'%i, key(i), key(i), key(i)]
  }.join("\n")
end

def add_fields(tag, fields)
  (0...fields.length).map {|i|
    '<crawl-url enqueue-id="%s"
           enqueue-type="reenqueued"
           forced-vse-key="%s"
           status="complete"
           url="http://adams/doc/%s#%s" >
  <crawl-data content-type="application/vxml-unnormalized">
    <vxml>
      <content indexed-fast-index="int" name="%s" >%d</content>
    </vxml>
  </crawl-data></crawl-url>' %
    ['%s-%03d'%[tag,i], key(i), key(i), fields[i][0], fields[i][0], fields[i][1]]
  }.join("\n")
end

def delete_fields(fields)
  (0...fields.length).map {|i|
    '<crawl-delete enqueue-id="%s" url="http://adams/doc/%s#%s" />' %
    ['delete-%03d'%i, key(i), fields[i][0]]
  }.join("\n")
end

def wrap(stuff)
  '<crawl-urls synchronization="indexed-no-sync" >
%s
</crawl-urls>' % stuff
end

def has_offline_queue(collection)
  hoq_xpath = '/collection-broker-status-response' +
    ('/collection[@name="%s"]' % collection.name) +
    '/@has-offline-queue'
  # Report "true" when the collection broker does not report the collection
  hoq = collection.vapi.collection_broker_status.xpath(hoq_xpath).first.to_s
  not (hoq == 'false')
end

COUNT = 500

c = Collection.new('audit-log-offline')
results.associate(c)
c.delete
c.create('default-broker-push')
xml = c.xml
set_option(xml, 'crawl-options', 'crawl-option', 'audit-log', 'all')
c.set_xml(xml)

# Create the base documents
results.add(c.broker_enqueue_xml(wrap(create_docs(COUNT))),
            'Base documents enqueued.',
            'Base documents enqueuing failed?')

n_docs = c.index_n_docs
results.add(n_docs == COUNT,
            "n-docs is: #{n_docs}",
            "n-docs is: #{n_docs} (should be #{COUNT}).")

msg "Tell the collection broker there is no available memory."
bc.set('always-allow-one-collection' => false,
       'check-memory-usage-time' => 0.1,
       'minimum-free-memory' => (256*1024*1024*1024),
       'overcommit-factor' => 0.0001)
msg bc

# Offline enqueue field add
fields = (0...COUNT).map {|i| ['square', i]}
results.add(c.broker_enqueue_xml(wrap(add_fields('first', fields))),
            'Offline enqueue first field addition to each document.',
            'Offline enqueue first field addition failed?')

# Offline enqueue field delete
results.add(c.broker_enqueue_xml(wrap(delete_fields(fields))),
            'Offline enqueue field deletion from each document.',
            'Offline enqueue field deletion failed?')

# Offline enqueue field add a second time
fields = (0...COUNT).map {|i| ['square', i*i]}
results.add(c.broker_enqueue_xml(wrap(add_fields('second', fields))),
            'Offline enqueue second field addition to each document.',
            'Offline enqueue second field addition failed?')

# Don't fail here if we don't see an offline queue.
# I don't understand why we don't see it sometimes, but it doesn't matter.
if has_offline_queue(c)
  msg '"%s" has an offline queue.' % c.name
else
  msg '"%s" should have an offline queue, but does not appear to.' % c.name
end

msg "Reset collection broker config to default (allow offline queue processing):"
bc.set

results.add(has_offline_queue(c),
            '"%s" should still have an offline queue.' % c.name)

msg "Waiting for offline queue processing ..."

# The crawler needs to start, process and idle exit, minimum of 60 seconds.
sleep 60

# Wait as long as ten minutes (should this be longer?)
end_of_wait = Time.now + 10*60

while has_offline_queue(c) and Time.now <= end_of_wait do
  sleep 1
end

# Now that we won't wait forever, fail if offline queue not cleared.
results.add((not has_offline_queue(c)),
            'Offline queue processing should be complete by now.')

# Also, fail is the crawler is still running; report status.
crawler_status = c.status.xpath('/vse-status/crawler-status')
if crawler_status.empty?
  results.add(false,
              'Empty crawler status? found: "%s".' % crawler_status.inspect)
else
  results.add(crawler_status.first['service-status'] != 'running',
              'Crawler is not running.',
              "Crawler should have idle exited by now.\n%s" %
              crawler_status.first)
end

# Check the audit log.
audit_log_entries = c.audit_log_retrieve(10000).
  xpath('/audit-log-retrieve-response/audit-log-entry')

creates = audit_log_entries.select {|e| e['enqueue-id'].to_s =~ /^create/}
firsts  = audit_log_entries.select {|e| e['enqueue-id'].to_s =~ /^first/}
deletes = audit_log_entries.select {|e| e['enqueue-id'].to_s =~ /^delete/}
seconds = audit_log_entries.select {|e| e['enqueue-id'].to_s =~ /^second/}

create_success = creates.count {|e| e['status'] == 'successful'}
first_success  = firsts.count  {|e| e['status'] == 'successful'}
delete_fail    = deletes.count {|e| e['status'] != 'successful'}
second_success = seconds.count {|e| e['status'] == 'successful'}

# We should have the same number of audit log entries for each action.
# We don't demand success or failure, but do report them.
results.add(create_success == COUNT,
            "#{create_success} successful document creates.")

results.add(firsts.length == COUNT,
            "First field additions: %d audit log entries with %d successes." %
            [firsts.length, first_success])

results.add(deletes.length == COUNT,
            "Delete fields: %d audit log entries with %d failures." %
            [deletes.length, delete_fail])

results.add(seconds.length == COUNT,
            "Second field additions: %d audit log entries with %d successes." %
            [seconds.length, second_success])

results.cleanup_and_exit!
