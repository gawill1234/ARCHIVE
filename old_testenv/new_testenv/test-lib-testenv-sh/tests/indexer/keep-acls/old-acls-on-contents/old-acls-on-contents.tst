#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/keep-acls'

require 'misc'
require 'collection'
require 'velocity/collection/restore'

class Collection
  def first_acl
    res = search()
    doc = res.xpath('//document').first
    con = doc.xpath("content[@name='main']").first
    return con['acl']
  end
end

results = TestResults.new("Ensure that old indexes with acls saved on the contents still work")
results.need_system_report = false

collection = Collection.restore_saved_collection('revive', '/testenv/saved-collections/indexer/keep-acls/old-acls-on-contents')
results.associate(collection)

# default should be to not output
results.add_equals(nil, collection.first_acl, 'acl attribute')

collection.set_index_options(:output_acls => true)
collection.indexer_stop

results.add_equals('acl1', collection.first_acl, 'acl attribute')

collection.set_index_options(:output_acls => false)
collection.indexer_stop

results.add_equals(nil, collection.first_acl, 'acl attribute')

results.cleanup_and_exit!(true)
