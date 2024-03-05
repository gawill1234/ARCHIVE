#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'misc'
require 'collection'
require 'gronk'
require 'config'

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="https://meta.vivisimo.com">
    <crawl-data content-type="text/plain"
                encoding="text">
      Nothing to see here. Move along.
    </crawl-data>
  </crawl-url>
</crawl-urls>'


def many_killed(total, chunk)
  Broker_Config.new.collection_broker_down
  gronk = Gronk.new
  gronk.kill_all_services
  (chunk..total).step(chunk) do |so_far|
    threads = (0..chunk-1).map do |i|
      Thread.new(i) do |j|
        cur = Collection.new("many-killed-#{so_far+j}")
        begin
          cur.create
        rescue
          # Assume the collection exists
        end
        cur.enqueue_xml(CRAWL_NODES)
      end
    end
    threads.each {|t| t.join}
    sleep 1
    gronk.kill_all_services
    msg "Now have #{so_far} killed collections ..."
  end
end


if __FILE__ == $0
  if ARGV.length == 0
    puts "usage: many-killed.rb total chunk"
    puts
    puts "This script will create, start (via an enqueue), then kill many collections."
    puts
    puts "Two command line arguments are required:"
    puts "\ttotal:\tThe total number of collections to create and kill."
    puts "\tchunk:\tThe number of collections to run simultaneously."
  else
    total = ARGV[0].to_i
    chunk = ARGV[1].to_i
    msg "Create, start and kill #{total} collections in batches of #{chunk}"
    many_killed(total, chunk)
  end
end
