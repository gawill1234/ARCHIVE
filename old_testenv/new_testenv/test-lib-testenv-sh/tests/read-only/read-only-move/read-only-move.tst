#!/usr/bin/env ruby

# Jake has another suggestion from reviewing some of this code...  Put
# a collection in read-only mode, stop the indexer, change the meta
# directories for the collection, resume the indexer and verify that
# after resume there is a file called indexer-read-only in the new
# directory that you specified.

# Basically, ensure that you can change the location of a collection
# and it will stay in read-only mode and it also tests that if someone
# goes and deletes our magic file that it will be fixed on startup.


$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'
require 'gronk'

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here. Move along.
    </crawl-data>
  </crawl-url>
</crawl-urls>'

results = TestResults.new('Put a collection in read-only mode, stop the',
                          'indexer, stop the indexer, change the meta',
                          'directories for the collection, resume the',
                          'indexer and verify that after resume there',
                          'is a file called indexer-read-only in the',
                          'new directory that you specified.',
                          "Or: the indexer won't start due to read-only.")
results.fail_severity = 'error-unknown'
gronk = Gronk.new

msg 'Starting test'

collection = Collection.new('read-only-move')
results.associate(collection)
collection.delete
collection.create
collection.enqueue_xml(CRAWL_NODES)
msg "Collection #{collection.name} created and started."
collection.read_only_enable
results.add(true,
            "Collection #{collection.name} is now read-only #{collection.read_only['mode']}.")
collection.stop

path = "/tmp/#{collection.name}/"
xml = collection.xml
set_option(xml, 'vse-meta', 'vse-meta-info', 'live-crawl-dir', "#{path}live")
set_option(xml, 'vse-meta', 'vse-meta-info', 'staging-crawl-dir', "#{path}stage")
set_option(xml, 'vse-meta', 'vse-meta-info', 'cache-dir', "#{path}cache")
collection.set_xml(xml)
results.add(true,
            "Collection #{collection.name} stopped and meta updated.")

started = true
begin
  collection.indexer_start
  results.add(true,
              "Collection #{collection.name} indexer started.")
rescue => ex
  results.add((ex.message =~
               /<exception .* id="COLLECTION_SERVICE_READ_ONLY_MODE"/m or
               ex.message =~
               /<exception .* id="SEARCH_ENGINE_READ_ONLY_DATABASE"/m or
               ex.message =~
               /<exception .* id="COLLECTION_SERVICE_SERVICE_START"/m),
              "Couldn't start collection due to read-only",
              "Couldn't start collection: #{ex}")
  started = false
end

if started
  sleep 10
  results.add((gronk.file_size("#{path}live/indexer-read-only") >= 0),
              "#{path}live/indexer-read-only found, first time - success",
              "#{path}live/indexer-read-only was not found, first try - fail")

  # Do a second stop/start of the indexer
  collection.indexer_stop
  collection.indexer_start
  msg "Collection #{collection.name} indexer restarted."
  sleep 2
  results.add((gronk.file_size("#{path}live/indexer-read-only") >= 0),
              "#{path}live/indexer-read-only found, second pass - success",
              "#{path}live/indexer-read-only was not found, second try - fail")
end

results.cleanup_and_exit!
