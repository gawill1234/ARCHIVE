#!/usr/bin/env ruby

require 'gronk'
require 'misc'
require 'collection'
require 'velocity/collection/restore'
require 'time'

def get_startup_time(c, g)
  c.stop

  # Clear disk cache
  clear_cache = 'sync; echo 3 > /proc/sys/vm/drop_caches'
  g.execute("#{clear_cache}", 'xml')

  start_time = Time.now
  c.search
  end_time = Time.now

  return end_time - start_time
end

results = TestResults.new('Test startup times of indexer with various ',
                          'different options set on a large collection.')
gronk = Gronk.new

msg 'Restoring danone-1 collection from disk.'
collection = Collection.new('danone-1')
if not collection.exists?
  collection = Collection.restore_saved_collection(
                            'danone-1',
                            '/testenv/saved-collections/danone/danone-1-tmp'
                          )
end
msg 'Done.'
results.associate(collection)

# XXX: need a way to clear the disk cache.

msg 'Test startup time with no options set.'
collection.set_index_options(:preload_database => false,
                             :fast_reconstructor_startup => false,
                             :fast_docs_load => false)
time_no_options = get_startup_time(collection, gronk)
results.add(time_no_options > 0,
            "Indexer started in #{time_no_options} seconds.")

msg 'Test startup time with db preload option set.'
collection.set_index_options(:preload_database => true,
                             :fast_reconstructor_startup => false,
                             :fast_docs_load => false)
time_preload_db = get_startup_time(collection, gronk)
results.add(time_preload_db > 0,
            "Indexer started in #{time_preload_db} seconds.")

msg 'Test startup time with fast reconstructor startup set.'
collection.set_index_options(:fast_reconstructor_startup => true,
                             :preload_database => false,
                             :fast_docs_load => false)
time_fast_reconstructor = get_startup_time(collection, gronk)
results.add(time_fast_reconstructor > 0,
            "Indexer started in #{time_fast_reconstructor} seconds.")

msg 'Test startup time with fast docs load set.'
collection.set_index_options(:fast_reconstructor_startup => false,
                             :preload_database => false,
                             :fast_docs_load => true)
time_fast_docs = get_startup_time(collection, gronk)
results.add(time_fast_docs > 0,
            "Indexer started in #{time_fast_docs} seconds.")

msg 'Test startup time with fast docs load and fast reconstructor startup set.'
collection.set_index_options(:fast_reconstructor_startup => true,
                             :preload_database => false,
                             :fast_docs_load => true)
time_fast_docs_and_recons = get_startup_time(collection, gronk)
results.add(time_fast_docs_and_recons > 0,
            "Indexer started in #{time_fast_docs_and_recons} seconds.")

msg 'Test startup time with all options on.'
collection.set_index_options(:fast_reconstructor_startup => true,
                             :preload_database => true,
                             :fast_docs_load => true)
time_fast_all = get_startup_time(collection, gronk)
results.add(time_fast_all > 0,
            "Indexer started in #{time_fast_all} seconds.")

exit
 
