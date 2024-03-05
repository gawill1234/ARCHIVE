#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'collection'
require 'misc'
require 'rexml/document'

# With a collection in read-only "enabled", check for exceptions from:
# - annotation-*
# - collection-broker-enqueue-xml
# - search-collection-audit-log-purge
# - search-collection-clean
# - search-collection-delete
# - search-collection-enqueue-*
# - search-collection-push-staging
# - search-collection-working-copy-*
# - collection-broker-export-data move=true

# Chris P. says OK:
# - search-collection-indexer-full-merge
# - search-collection-set-xml
# - search-collection-update-configuration

# check for OK from:
# - search-collection-start*
# - query-search
# - collection-broker-start-collection
# - collection-broker-search
# - collection-broker-export-data move=false

step = []

VAPI = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password) 
TIME_LIMIT = 20

class VapiTimeout < ThreadError
end

class Collection_Call
  def initialize(func, ro_ok, args=nil, tag=:collection)
    @func = func
    @ro_ok = ro_ok
    @args = {}
    @args = args if args
    @tag = tag
  end

  def do_call(name)
    t = Thread.new { VAPI.call(@func, {@tag=>name}.merge(@args)) }
    r = t.join(TIME_LIMIT)
    if r.nil?
      t.kill
      raise VapiTimeout, @func.to_s
    end    
    t.value
  end

  def rw_call(name)
    do_call(name)
    true
  end

  def ro_call(name)
    if @ro_ok
      begin
        do_call(name)
        msg "ro_call #{@func} no exception - pass"
        true
      rescue Exception => ex
        msg "ro_call #{@func} unexpected exception:" \
          "\n\t#{ex.class}: #{ex} - fail"
        false
      end
    else
      begin
        do_call(name)
        msg "ro_call #{@func} no exception - fail"
        false
      rescue VapiException
        # FIXME ideally, check that the exception talks about read-only
        msg "ro_call #{@func} expected exception returned - pass"
        true
      rescue Exception => ex
        msg "ro_call #{@func} unexpected exception:" \
          "\n\t#{ex.class}: #{ex} - fail"
        false
      end
    end
  end
end

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/dummy">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here.
    </crawl-data>
  </crawl-url>
</crawl-urls>'


calls = [

         Collection_Call.new(:collection_broker_start_collection, true),
         Collection_Call.new(:collection_broker_search, true),
         Collection_Call.new(:collection_broker_ignore_collection, true),
         Collection_Call.new(:search_collection_crawler_start, true),
         Collection_Call.new(:search_collection_indexer_start, true),
         Collection_Call.new(:search_collection_crawler_restart, true),
         Collection_Call.new(:search_collection_indexer_restart, true),
         Collection_Call.new(:search_collection_crawler_stop, true),
         Collection_Call.new(:search_collection_indexer_stop, true),
         
         Collection_Call.new(:search_collection_crawler_stop, true,
                             :kill => true),
         Collection_Call.new(:search_collection_indexer_stop, true,
                             :kill => true),
         Collection_Call.new(:search_collection_status, true),
         Collection_Call.new(:search_collection_xml, true),
         # Collection_Call.new(:search_collection_clean, false),

         Collection_Call.new(:query_search, true, nil, :sources),
         # Collection_Call.new(:search_collection_crawler_start, true,
         #                     :subcollection => :staging),


         # Collection_Call.new(:search_collection_audit_log_purge, true),
         Collection_Call.new(:search_collection_audit_log_retrieve, true),
         # Collection_Call.new(:search_collection_create, true),
         # Collection_Call.new(:search_collection_delete, true),
         Collection_Call.new(:search_collection_indexer_full_merge, true),
         # Collection_Call.new(:search_collection_push_staging, false),
         # Collection_Call.new(:search_collection_set_xml, true),
         Collection_Call.new(:search_collection_update_configuration, true),
         # Collection_Call.new(:search_collection_url_status_query, true),
         # Collection_Call.new(:search_collection_working_copy_accept, true),
         # Collection_Call.new(:search_collection_working_copy_create, true),
         # Collection_Call.new(:search_collection_working_copy_delete, true),

         # Collection_Call.new(:search_collection_enqueue, true),
         # Collection_Call.new(:search_collection_enqueue_deletes, true),
         # Collection_Call.new(:search_collection_enqueue_url, true),

         # The following have been seen to hang.
         # Once one call hangs, following calls are likely to hang as well.
         Collection_Call.new(:collection_broker_enqueue_xml, false,
                             :crawl_nodes => CRAWL_NODES),
         Collection_Call.new(:search_collection_enqueue_xml, false,
                             :crawl_nodes => CRAWL_NODES),
         Collection_Call.new(:search_collection_abort_transactions, false),
         Collection_Call.new(:collection_broker_abort_transactions, false)
        ]


collection = Collection.new('example-metadata')
# Turn off read-only, as needed
collection.read_only(:disable) if collection.read_only['mode'] == 'enabled'
collection.crawler_start

# Make sure we can make all our calls in normal, not-read-only mode.
calls.each {|c| c.rw_call(collection.name)}

# Check twice, since we're going to try all the same calls again in read-only
calls.each {|c| c.rw_call(collection.name)}

# There is a remote chance this will hang... Groan.
collection.read_only_enable

# Now, the real test. Try all the calls in read-only mode.
step += calls.map {|c| c.ro_call(collection.name)}

step << (collection.read_only['mode'] == 'enabled')
if step[-1]
  msg "Still in read-only mode at end of API calls - pass"
else
  msg "Not in read-only mode at end of API calls! - fail"
end

# annotation_add
# annotation_delete
# annotation_express_add_doc_list
# annotation_express_add_query
# annotation_express_delete_doc_list
# annotation_express_delete_query
# annotation_express_global_set_doc_list
# annotation_express_global_set_query
# annotation_express_update_doc_list
# annotation_express_update_query
# annotation_express_user_set_doc_list
# annotation_express_user_set_query
# annotation_global_set
# annotation_permissions
# annotation_update
# annotation_user_set

# collection_broker_export_data

# search_collection_audit_log_purge
# search_collection_audit_log_retrieve
# search_collection_clean
# search_collection_crawler_restart
# search_collection_crawler_start
# search_collection_crawler_stop
# search_collection_create
# search_collection_delete
# search_collection_enqueue
# search_collection_enqueue_deletes
# search_collection_enqueue_url
# search_collection_indexer_full_merge
# search_collection_indexer_restart
# search_collection_indexer_start
# search_collection_indexer_stop
# search_collection_list_xml
# search_collection_push_staging
# search_collection_read_only
# search_collection_read_only_all
# search_collection_set_xml
# search_collection_status
# search_collection_update_configuration
# search_collection_url_status_query
# search_collection_working_copy_accept
# search_collection_working_copy_create
# search_collection_working_copy_delete

if step.all?
  msg 'Test passed'
  exit 0
end

passed = step.select {|s| s}.length
failed = step.reject {|s| s}.length

msg "Test failed. #{passed} steps passed and #{failed} steps failed."
exit 1
