#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'
require 'gronk'

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued" status="complete" synchronization="indexed-no-sync" url="http://vivisimo.com">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here. Move along.
    </crawl-data>
  </crawl-url>
</crawl-urls>'


def create_tiny_template
  c = Collection.new("tiny-template")
  unless c.exists?
    c.create('default-push')
    xml = c.xml
    set_option(xml, 'crawl-options', 'crawl-option', 'cache-size', 1)
    set_option(xml, 'vse-index', 'vse-index-option', 'cache-mb', 1)
    set_option(xml, 'vse-index', 'vse-index-option', 'cache-cleaner-mb', 1)
    c.set_xml(xml)
  end
  c.name
end

def delete(list)
  # Returns a list of collections for which the delete failed.
  threads = list.map do |x|
    Thread.new(x) do |c|
      begin
        c.delete
        nil
      rescue
        c
      end
    end
  end
  (threads.map {|x| x.value}).select {|r| r.is_a? Collection}
end

def kill(list)
  # Issue stop/kill for each collection's crawler and indexer.
  threads = list.map {|x| Thread.new(x) {|c| c.kill}}
  threads.each {|t| t.join}
end

def delete_many_collections(list)
  # Clean up after myself (in parallel: fast!)
  list = delete(list)           # Trying deleting each collection
  retries = 0
  while list.length > 0 and retries < 20
    retries += 1
    msg "Delete failed for #{list.length} collections. Retry #{retries} ..."
    sleep retries
    kill(list)
    list = delete(list)
  end
  raise "Delete failed for #{list.length} collections." \
    if list.length > 0 and list.any? {|c| c.exists?}
end


def create_maximum_online_plus(op, name_base='max-online-')
  tiny_template = create_tiny_template
  i = 0
  no_increase = 0
  max_online = Gronk.new.get_pid_list('indexer').length
  collection = []
  while no_increase < [10, i/5].max do
    collection << Collection.new("#{name_base}#{i}")
    collection[-1].create(tiny_template)
    i += 1
    if op == :search
      collection[-1].broker_search
    else
      collection[-1].broker_enqueue_xml(CRAWL_NODES)
    end
    new_online = Gronk.new.get_pid_list('indexer').length
    if max_online < new_online
      max_online = new_online
      no_increase = 0
    else
      no_increase += 1          # Note the lack of more online collections.
    end
  end
  [max_online, collection]
end

def determine_maximum_online(op, name_base='max-online-')
  max_online, collection = create_maximum_online_plus(op, name_base)
  delete_many_collections(collection)
  max_online
end

def determine_maximum_online_via_enqueue(name_base='max-online-enqueue-')
  determine_maximum_online(:enqueue_xml, name_base)
end

def determine_maximum_online_via_search(name_base='max-online-search-')
  determine_maximum_online(:search, name_base)
end

if __FILE__ == $0
  msg "Max online via enqueue: #{determine_maximum_online_via_enqueue}"
  msg "Max online via search: #{determine_maximum_online_via_search}"
end
