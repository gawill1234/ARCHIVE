#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'misc'
require 'collection'
require 'config'

COUNT = 1000

results = TestResults.new("First half of an offline enqueue failover test.",
                          "Offline enqueue %d documents." % COUNT)

bc = Broker_Config.new

def create_docs(count)
  '<crawl-urls synchronization="indexed-no-sync" >
' +
    (0...count).map {|i|
    '<crawl-url enqueue-type="reenqueued"
           status="complete"
           url="http://adams/doc-%d" >
  <crawl-data content-type="text/plain" encoding="text" >
    Nothing to see here. Move along. My index is &quot;%d&quot;.
  </crawl-data></crawl-url>' % [i, i]}.join("\n") + '
</crawl-urls>'
end

bc.set('always-allow-one-collection' => 'false', 'maximum-collections' => '0')
msg bc

c = Collection.new('offline-failover')
c.delete
c.create('default-broker-push')

results.add(c.broker_enqueue_xml(create_docs(COUNT)),
            '%d documents enqueued.' % COUNT,
            'Enqueuing %d documents failed?' % COUNT)

results.cleanup_and_exit!
