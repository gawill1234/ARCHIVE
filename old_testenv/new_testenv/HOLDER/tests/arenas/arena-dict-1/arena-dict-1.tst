#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/arenas'

require 'misc'
require 'collection'
require 'arenas-helpers'

def configure_language(c)
  xml = c.xml
  set_option(xml, 'vse-index/vse-index-streams/call-function', 
             'with', 'segmenter', 'mixed')
  set_option(xml, 'vse-index/vse-index-streams/call-function',
             'with', 'delanguage', 'true')
  c.set_xml(xml)
end

def configure_dictionaries(c)
  xml = c.xml
  set_option(xml, 'vse-index', 'vse-index-option', 'term-expand-dicts', 'true')
  c.set_xml(xml)
end

def tree_enqueue(c, path, url, arena=nil)
  msg "Enqueuing directory tree #{path} to collection #{c.name} and arena #{arena}"
  if arena
    system("#{ENV['TEST_ROOT']}/lib/enqueue_tree.py",
           "#{c.name}",
           "#{path}",
           "#{url}",
           "-1",
           "#{arena}")
  else
    system("#{ENV['TEST_ROOT']}/lib/enqueue_tree.py",
           "#{c.name}",
           "#{path}",
           "#{url}")
  end
end

URL="http://arena-dict/"
PATH="/testenv/test_data/languages/doc"
results = TestResults.new('Create two search collections, one with arenas and ',
                          'one without.  Enqueue the same documents into ',
                          'each, multiple times with multiple arenas. ',
                          'Check that generating ditionaries really does ',
                          'take more resources.')

c_no_arena = Collection.new('arena-dict-1-no-arena')
results.associate(c_no_arena)
c_no_arena.delete
c_no_arena.create
configure_language(c_no_arena)
c_no_arena.crawler_start
c_no_arena.indexer_start
tree_enqueue(c_no_arena, PATH, URL)
configure_dictionaries(c_no_arena)
c_no_arena.stop
c_no_arena.crawler_start
c_no_arena.indexer_start
until c_no_arena.indexer_idle?
  sleep 1
end

num, size, n_words = c_no_arena.get_num_dictionaries
results.add(num == 1,
            "Found 1 dictionary in non-arenas enabled collection, total words = #{n_words}.",
            "Found #{num} dictionaries in non-arenas enabled collection, expect 1.")

c = Collection.new('arena-dict-1')
results.associate(c)
c.delete
c.create
configure_arenas(c, 'true')
configure_language(c)
c.crawler_start
c.indexer_start
tree_enqueue(c, PATH, URL, 'arena-1')
tree_enqueue(c, PATH, URL, 'arena-2')
configure_dictionaries(c)
c.stop
c.crawler_start
c.indexer_start

until c.indexer_idle?
  sleep 1
end

num2, size2, n_words2 = c.get_num_dictionaries
results.add(num2 == num*2 && size2 == size*2 && n_words2 == n_words*2, 
            "Found #{num2} dictionaries in arenas enabled collection with only 2 arenas, total words = #{n_words2}.",
            "Found #{num2} dictionaries in arenas enabled collection with 2 arenas, size was #{size2}, expected #{size*2}, num words = #{n_words2}, expected #{n_words*2}.")

tree_enqueue(c, PATH, URL, 'arena-3')
until c.indexer_idle?
  sleep 1
end

num3, size3, n_words3 = c.get_num_dictionaries
results.add(num3 == num*3 && size3 == size*3 && n_words3 == n_words*3,
            "Found #{num3} dictionaries in arenas enabled collection with 3 arenas.",
            "Found #{num3} dictionaries in arenas enabled collection with 3 arenas, size was #{size3}, expected #{size*3}, num words = #{n_words3}, expected #{n_words*3}.")

# Cleanup
c_no_arena.stop
c.stop

results.cleanup_and_exit!

