#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/arenas'

require 'thread'
require 'time'
require 'misc'
require 'collection'
require 'arenas-helpers'
require 'pmap'

ARENA_COUNT=4
QUERY_COUNT=100
DOCUMENT_COUNT=75
URL = "http://lince/"
TREE_PATH = "/testenv/test_data/languages/doc"

def configure_language(c)
  xml = c.xml
  set_option(xml, 'vse-index/vse-index-streams/call-function', 
             'with', 'segmenter', 'mixed')
  set_option(xml, 'vse-index/vse-index-streams/call-function',
             'with', 'delanguage', 'true')
  c.set_xml(xml)
end

def check_results(collection, expect, arena, hash)
  duplicate = false
  wrong_arena = false
  msg "Checking collection #{collection.name} and arena #{arena}"
  qr = collection.vapi.query_search(:sources => collection.name,
                                    :arena => arena,
                                    :num => 1000)
  doc_list = qr.xpath('/query-results/list/document/@url')
  for url in doc_list
    if ! hash.insert(url.to_s, true) 
      duplicate = true
      msg "Duplicate found at %s"%url.to_s
    end
    if ! url.to_s.slice(arena)
      # Arena name not found in URL.  This is unexpected.
      wrong_arena = true
      msg "URL %s without arena (or from different arena) found!"%url.to_s
    end
  end
  doc_count = qr.xpath('/query-results/list/document').length
  [! duplicate && ! wrong_arena && doc_count == expect,
   "#{doc_count} documents found.",
   "#{doc_count} documents found (expected #{expect}), duplicates found = #{duplicate}, wrong arena = #{wrong_arena}"]
end

class SafeHash
  attr_reader :_mutex, :_hash

  def initialize
    @_hash = Hash.new
    @_mutex = Mutex.new
  end

  def insert(key, value)
    @_mutex.synchronize { 
      if (@_hash.key?(key))
        return false
      end
      
      @_hash.store(key,value)
    }
    true
  end

  def clear
    @_mutex.synchronize {
      @_hash.clear
    }
  end
end

Class.instance_eval { @_mutex = Mutex.new }

class TreeEnqueueAndQuery
  attr_reader :collection, :results, :name, :url, :arena, :path, :query, 
  :expect, :hash

  def initialize(results, path, url, arena, expect, hash)
    @collection = Collection.new('arena-race-1')
    @results = results
    @name = collection.name
    @path = path
    @url = url
    @arena = "arena-%d" % arena
    @expect = expect
    @hash = hash
    @query = DoQuery.new(results, @collection, @expect, arena, hash)
    if (arena == 0)
      # Hack to create collection only if it is the first one
      @collection.delete
      @collection.create
      configure_arenas(@collection, 'true')
      configure_language(@collection)
      @collection.crawler_start
      @collection.indexer_start
    end
  end

  def queue(max_docs)
    msg "Starting #{ARENA_COUNT} arena tree enqueues to #{collection.name}"
    system("#{ENV['TEST_ROOT']}/lib/enqueue_tree.py",
           "#{name}",
           "#{path}",
           "#{url}", "#{max_docs}", "#{arena}")
  end

  def query
    @query.invoke
  end

  def get_arenas
    @collection.get_number_streams
  end
end

class DoQuery
  attr_reader :results, :collection, :expect, :arena, :hash

  def initialize(results, collection, expect, arena, hash)
    @results = results
    @collection = collection
    @expect = expect
    @arena = "arena-%d" % arena
    @hash = hash
  end

  def invoke
    results.add(*check_results(collection, expect, arena, hash))
  end
end

results = TestResults.new('Create a collection with arenas enabled, ',
                          'crawl a complex set of documents into four arenas, ',
                          'then do a series of identical searches in parallel. ')

c = Collection.new('arena-race-1')
results.associate(c)
hash = SafeHash.new
stage = (0...ARENA_COUNT).map {|i| TreeEnqueueAndQuery.new(results, TREE_PATH, URL, i, DOCUMENT_COUNT, hash)}

# Enqueue full directory
stage.peach {|e| e.queue(-1)}
until c.indexer_idle?
  sleep 1
end

# Run queries against each arena in parallel
(0...QUERY_COUNT).each {
  stage.peach {|e| e.query}
  hash.clear
}

# Check that the collection reports at least four streams
stage.each { |e|
  streams = e.get_arenas
  results.add(streams >= ARENA_COUNT,
              "Found #{streams} arenas.",
              "Found #{streams} arenas, expected #{ARENA_COUNT}.")
}

# Enqueue only half of the tree now
stage.peach {|e| e.queue(DOCUMENT_COUNT/2) }

# Run queries against each arena in parallel
(0...QUERY_COUNT).each {
  stage.peach {|e| e.query}
  hash.clear
}

results.cleanup_and_exit!
