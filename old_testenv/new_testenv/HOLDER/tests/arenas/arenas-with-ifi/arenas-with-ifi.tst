#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/arenas'

require 'misc'
require 'collection'
require 'arenas-helpers'

results = TestResults.new('Arena and indexed-fast-index interactions')

def get_vse_hash(c, url = "foo", arena = "LOG_ENTRY")
  qr = c.vapi.query_search(
	 :query => "DOCUMENT:#{url}",
         :sources => c.name,
         :arena => arena,
         :output_axl => '<document key="{vse:doc-hash()}" />', :debug => '1'
       )
  qr.xpath('//document/@key')[0].to_s
end

def reset(c)
  c.delete
  c.create
  configure_arenas(c, 'true')
end

def wait_for_idle(c)
  until c.indexer_idle?
    sleep 1
  end
end

def enqueue_document(c, arena, name, value, type = nil, synchronization='indexed-no-sync')
  ifi = ""
  ifi = "indexed-fast-index='#{type}'" if ! type.nil?
  c.enqueue_xml("<crawl-url url='#{arena + ',' + name + ',' + value}' status='complete' enqueue-type='reenqueued' synchronization='#{synchronization}' arena='#{arena}'><crawl-data content-type='application/vxml'><vxml><document><content name='#{name}' #{ifi}>#{value}</content></document></vxml></crawl-data></crawl-url>")
end

def num_fields(status)
  status.xpath('//reconstructor-statuses[1]/value-set-field').count
end

def num_streams_for_fields(status)
  status.xpath('//vse-index-status/vse-index-streams/vse-index-stream[@fast-index-field]').count
end

def two_arenas_use_the_same_name_they_generate_two_fields_and_streams(c, results)
  reset(c)
  enqueue_document(c, '1', 'name', 'value', 'set')
  enqueue_document(c, '2', 'name', 'value', 'set')
  wait_for_idle(c)
  status = c.status
  results.add_equals(2, num_fields(status), 'fast-index fields when using same name')
  results.add_equals(2, num_streams_for_fields(status), 'streams for fast-index fields when using same name')
end

def two_arenas_using_the_same_name_dont_break_the_set_ifi_optimization(c, results)
  reset(c)
  enqueue_document(c, '1', 'title', 'value', 'set')
  enqueue_document(c, '2', 'title', '12', 'int')
  wait_for_idle(c)
  # TODO how the hell can I get profiling information?
  qr = c.vapi.query_search(
	 :query => 'title :== value',
	 :sources => 'arenas-with-ifi',
	 :profile => 1,
	 :arena => 1
       )
end

def changing_ifi_config_rebuilds_the_streams_correctly(c, results)
  reset(c)
  enqueue_document(c, '1', 'title', 'value1')
  enqueue_document(c, '2', 'author', 'chris', 'set')
  enqueue_document(c, '1', 'author', 'chris', 'set')
  enqueue_document(c, '1', 'title', 'value2')
  wait_for_idle(c)
  c.crawler_stop
  c.indexer_stop
  c.set_index_options(:fast_index => 'title', :indexed_fast_index => 'true')
  c.indexer_start
  wait_for_idle(c)
  status = c.status
  results.add_equals(3, num_fields(status), 'fast-index fields after ifi config changed')
  results.add_equals(3, num_streams_for_fields(status), 'streams for fast-index fields after ifi config changed')
end

def verify_author_fast_indexed_in_arena(results, c, author, arena)
  quote='"'
  qr = c.vapi.query_search(
	 :query_object => "<term field='v.xpath' str='viv:str-to-lower($author) = #{quote}#{author}#{quote}' />",
	 :sources => 'arenas-with-ifi',
	 :arena => arena
       )
  results.add_equals(1, qr.xpath('count(//document)'), "number of documents for author [#{author}] in arena [#{arena}]")
end

def reconstruction_with_multiple_arenas_builds_fast_index_data(c, results)
  reset(c)
  enqueue_document(c, '1', 'author', 'chris', 'set', 'none')
  enqueue_document(c, '2', 'author', 'chris', 'set', 'none')
  enqueue_document(c, '1', 'author', 'palmer', 'set', 'none')
  enqueue_document(c, '2', 'author', 'palmer', 'set', 'none')
  wait_for_idle(c)
  verify_author_fast_indexed_in_arena(results, c, 'chris', '1')
  verify_author_fast_indexed_in_arena(results, c, 'chris', '2')
  verify_author_fast_indexed_in_arena(results, c, 'palmer', '1')
  verify_author_fast_indexed_in_arena(results, c, 'palmer', '2')
end

c = Collection.new('arenas-with-ifi')
results.associate(c)

two_arenas_use_the_same_name_they_generate_two_fields_and_streams(c, results)
#two_arenas_using_the_same_name_dont_break_the_set_ifi_optimization(c, results)
changing_ifi_config_rebuilds_the_streams_correctly(c, results)
reconstruction_with_multiple_arenas_builds_fast_index_data(c, results)

# Cleanup
c.stop

results.cleanup_and_exit!
