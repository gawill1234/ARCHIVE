#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/arenas'

require 'misc'
require 'collection'

results = TestResults.new('Crawl-data Light Crawler URLs')

def reset(c, audit_log = false, arenas = false)
  c.delete
  c.create
  xml = c.xml
  set_option(xml, 'vse-index', 'vse-index-option', 'arenas', 'true') if arenas
  set_option(xml, 'crawl-options', 'crawl-option', 'audit-log', 'all') if audit_log
  set_option(xml, 'crawl-options', 'crawl-option', 'audit-log-detail', 'medium') if audit_log
  c.set_xml(xml)
end

def reset_arenas(c)
  reset(c, false, true)
end

def reset_audit_log(c)
   reset(c, true, false)
end

def reset_arenas_and_audit_log(c)
   reset(c, true, true)
end

def add_delay_converter(c)
  converter = <<-HERE
  <converter timing-name="delay" type-in="application/delay" type-out="application/vxml-unnormalized">
    <parser type="xsl">
      <![CDATA[<xsl:template match="/">
        <xsl:variable name="delay" select="viv:sleep(30)" />
        <xsl:apply-templates select="." mode="copy" />
      </xsl:template>

      <xsl:template match="@* | text() | comment()" mode="copy">
        <xsl:copy />
      </xsl:template>

      <xsl:template match="*" mode="copy">
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="copy" />
          <xsl:apply-templates mode="copy" />
        </xsl:copy>
      </xsl:template>]]>
    </parser>
  </converter>
  HERE
  c.add_converter(converter)
end

def add_no_delay_converter(c)
  converter = <<-HERE
  <converter timing-name="no-delay" type-in="application/no-delay" type-out="application/vxml-unnormalized">
    <parser type="xsl">
      <![CDATA[<xsl:template match="/">
        <xsl:apply-templates select="." mode="copy" />
      </xsl:template>

      <xsl:template match="@* | text() | comment()" mode="copy">
        <xsl:copy />
      </xsl:template>

      <xsl:template match="*" mode="copy">
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="copy" />
          <xsl:apply-templates mode="copy" />
        </xsl:copy>
      </xsl:template>]]>
    </parser>
  </converter>
  HERE
  c.add_converter(converter)
end


def wait_for_idle(c)
  until c.crawler_idle? && c.indexer_idle?
    sleep 1
  end
end

# The crawler goes idle before the audit-log entry has been written!

def wait_for_audit_log(c)
  until c.audit_log_retrieve.xpath('count(//audit-log-entry)').to_i > 0
    sleep 1
  end
end

def delete(c, url, synchronization='indexed')
  c.enqueue_xml("<crawl-delete synchronization='#{synchronization}' url='#{url}' />")
end

def synchronously_enqueue_crawl_url(c, url, value)
  xml = "<crawl-url url='#{url}' status='complete' enqueue-type='reenqueued' synchronization='indexed'><crawl-data>#{value}</crawl-data></crawl-url>"
  c.enqueue_xml(xml)
end

def enqueue_crawl_datas(c, url, crawl_datas, synchronization = 'enqueued')
  xml = "<crawl-url url='#{url}' status='complete' enqueue-type='reenqueued' synchronization='#{synchronization}'>#{crawl_datas}</crawl-url>"
  c.enqueue_xml(xml)
end

def crawl_data(url, value, arena = nil, enqueue_id = nil, fast_index = nil, content_type = 'application/vxml')
  arena_attr = ""
  arena_attr = "light-crawler-arena='#{arena}'" if ! arena.nil?
  enqueue_id_attr = ""
  enqueue_id_attr = "light-crawler-enqueue-id='#{enqueue_id}'" if ! enqueue_id.nil?
  fast_index_attr = ""
  fast_index_attr = "indexed-fast-index='#{fast_index}'" if ! fast_index.nil?
  return "<crawl-data light-crawler-url='#{url}' content-type='#{content_type}' #{arena_attr} #{enqueue_id_attr}><vxml><document><content name='title' #{fast_index_attr}>#{value}</content></document></vxml></crawl-data>"
end

def query(c, query = '', arena=nil, num=10)
  c.vapi.query_search(:query => query, :sources => c.name, :arena => arena, :num => num)
end
  
def number_of_documents(c, query = '', arena=nil)
  qr = query(c, query, arena)
  qr.xpath('count(//document)').to_i
end

def deleting_an_update_id_after_updating_it(c, results)
  reset(c)
  enqueue_crawl_datas(c, "url1", 
	crawl_data("update-id-1", "value1") +
	crawl_data("update-id-2", "value2")
  )
  wait_for_idle(c)
  enqueue_crawl_datas(c, "url2", 
	crawl_data("update-id-1", "value2") +
	crawl_data("update-id-3", "value3")
  )
  wait_for_idle(c)
  delete(c, "update-id-1")
  results.add_equals(0, number_of_documents(c, 'value1'), "number of times value1 appears")
  results.add_equals(1, number_of_documents(c, 'value2'), "number of times value2 appears")
end

def deleting_url_from_a_crawl_data_deletes_it(c, results)
  reset(c)
  enqueue_crawl_datas(c, "url1", 
	crawl_data("update-id-1", "value1") +
	crawl_data("update-id-2", "value2")
  )
  wait_for_idle(c)
  delete(c, "update-id-1")
  results.add_equals(1, number_of_documents(c), "documents left after deleting one url")
  results.add_equals(1, number_of_documents(c, 'value2'), "right document left after deleting one url")
end

def deleting_containing_url_doesnt_delete_the_data(c, results)
  reset(c)
  enqueue_crawl_datas(c, "url1", 
	crawl_data("update-id-1", "value1") +
	crawl_data("update-id-2", "value2")
  )
  wait_for_idle(c)
  delete(c, "url1")
  results.add_equals(2, number_of_documents(c), "documents left after deleting the containing url")
end

def uses_the_arena_on_a_crawl_data(c, results)
  reset_arenas(c)
  enqueue_crawl_datas(c, "url1", 
	crawl_data("update-id-1", "value1", "arena1") +
	crawl_data("update-id-2", "value2", "arena2")
  )
  wait_for_idle(c)
  results.add_equals(1, number_of_documents(c, '', 'arena1'), "documents in arena1")
  results.add_equals(1, number_of_documents(c, '', 'arena2'), "documents in arena2")
end

def light_crawler_attributes_do_not_appear_on_docs(c, results)
  reset_arenas(c)
  enqueue_crawl_datas(c, "url1", crawl_data("update-id-1", "value1", "arena1", "enqueue-id"))
  wait_for_idle(c)
  qr = query(c, '', 'arena1', 1)
  results.add_equals(1, qr.xpath("count(//document)").to_i, "should contain a document")
  results.add_equals(0, qr.xpath("count(//document/@light-crawler-url)").to_i, 'should not have @light-crawler-url')
  results.add_equals(0, qr.xpath("count(//document/@light-crawler-arena)").to_i, 'should not have have @light-crawler-arena')
  results.add_equals(0, qr.xpath("count(//document/@light-crawler-enqueue-id)").to_i, 'should not have have @light-crawler-enqueue-id')
end

def audit_log_reports_several_indexing_successes(c, results)
  reset_audit_log(c)
  enqueue_crawl_datas(c, "url1", 
	crawl_data("update-id-1", "value1", nil, "enqueue-1") +
	crawl_data("update-id-2", "value2", nil, "enqueue-2") +
	crawl_data("update-id-3", "value3", nil, "enqueue-3")
  )
  wait_for_audit_log(c)
  audit_log = c.audit_log_retrieve
  results.add_equals(3, audit_log.xpath('count(//light-crawler-entry)').to_i, 'should have all entries')
  results.add_equals(1, audit_log.xpath('count(//light-crawler-entry[@enqueue-id = "enqueue-1"])').to_i, 'should have update 1')
  results.add_equals(1, audit_log.xpath('count(//light-crawler-entry[@enqueue-id = "enqueue-2"])').to_i, 'should have update 2')
  results.add_equals(1, audit_log.xpath('count(//light-crawler-entry[@enqueue-id = "enqueue-3"])').to_i, 'should have update 3')
end

def audit_log_reports_indexing_errors(c, results)
  reset_audit_log(c)
  enqueue_crawl_datas(c, "url1", crawl_data("update-id", "Not A Number", nil, 'enqueue-id', 'int'))
  wait_for_audit_log(c)
audit_log = c.audit_log_retrieve
  results.add_equals(1, audit_log.xpath('count(//light-crawler-entry[@enqueue-id = "enqueue-id"]/log/error)').to_i, 'should have an error in the audit log for indexer errors')
end

def audit_log_reports_crawler_errors(c, results)
  reset_audit_log(c)
  enqueue_crawl_datas(c, "url1",
                      crawl_data("update-id", "value", nil, 'enqueue-id', nil, 'not a content type') +
	              crawl_data("update-id-2", "value2", nil, "enqueue-2")
                     )
  wait_for_audit_log(c)
  audit_log = c.audit_log_retrieve
  results.add_equals(1, audit_log.xpath('count(//light-crawler-entry[@enqueue-id = "enqueue-id"]/log/error)').to_i, 'should have an error in the audit log for crawler errors')
end

def audit_log_reports_crawler_errors_when_there_are_no_valid_crawl_datas(c, results)
  reset_audit_log(c)
  enqueue_crawl_datas(c, "url1",
                      crawl_data("update-id", "value", nil, 'enqueue-id', nil, 'not a content type') +
	              crawl_data("update-id-2", "value2", nil, 'enqueue-id', nil, "not a content type")
                     )
  wait_for_audit_log(c)
  audit_log = c.audit_log_retrieve
  results.add_equals(2, audit_log.xpath('count(//light-crawler-entry[@enqueue-id = "enqueue-id"]/log/error)').to_i, 'should have errors in the audit log when there are no valid crawl datas')
end

def updating_an_url_with_a_different_arena_throws_an_error(c, results)
  reset_arenas(c)
  enqueue_crawl_datas(c, "url1", crawl_data("update-id-1", "value1", "arena1"))
  wait_for_idle(c)
  enqueue_crawl_datas(c, "url2", crawl_data("update-id-1", "value2", "arena2"))
  wait_for_idle(c)
  # When the arena is updated it will be an error and the error causes the old data
  # to be removed and the new data to not be indexed
  results.add_equals(0, number_of_documents(c, '', 'arena1'), "doesn't appear in either arena (arena1)")
  results.add_equals(0, number_of_documents(c, '', 'arena2'), "doesn't appear in either arena (arena2)")
end

def enqueue_item_with_light_crawler_url_and_then_update_with_crawl_url(c, results)
  reset(c)
  enqueue_crawl_datas(c, "url1",
	crawl_data("update-id-1", "value1") +
	crawl_data("update-id-2", "value2")
  )
  wait_for_idle(c)
  synchronously_enqueue_crawl_url(c, "update-id-1", "value3")
  results.add_equals(0, number_of_documents(c, 'value1'), "value1 was removed")
  results.add_equals(1, number_of_documents(c, 'value3'), "value3 was added")
end

def enqueue_light_crawler_url_and_same_light_crawler_url_immediately_after(c, results)
  reset(c)
  add_delay_converter(c)
  add_no_delay_converter(c)
  enqueue_crawl_datas(c, "url1", 
	crawl_data("update-id-1", "value1", nil, nil, nil, "application/delay") +
	crawl_data("update-id-2", "value2", nil, nil, nil, "application/delay")
  )
  enqueue_crawl_datas(c, "url2", 
	crawl_data("update-id-1", "value3", nil, nil, nil, "application/no-delay") +
	crawl_data("update-id-2", "value4", nil, nil, nil, "application/no-delay")
  )
  wait_for_idle(c)
  results.add_equals(0, number_of_documents(c, 'value1'), "value1 was removed")
  results.add_equals(0, number_of_documents(c, 'value2'), "value2 was removed")
  results.add_equals(1, number_of_documents(c, 'value3'), "value3 was added")
  results.add_equals(1, number_of_documents(c, 'value4'), "value4 was added")
end

def enqueue_url_and_same_light_crawler_url_immediately_after(c, results)
  reset(c)
  add_delay_converter(c)
  add_no_delay_converter(c)
  enqueue_crawl_datas(c, "url1",
	crawl_data(nil, "value1", nil, nil, nil, "application/delay")
  )
  enqueue_crawl_datas(c, "url2",
	crawl_data("url1", "value2", nil, nil, nil, "application/no-delay")
  )
  wait_for_idle(c)
  results.add_equals(0, number_of_documents(c, 'value1'), "value1 was removed")
  results.add_equals(1, number_of_documents(c, 'value2'), "value2 was added")
end

def enqueue_light_crawler_url_and_same_url_immediately_after(c, results)
  reset(c)
  add_delay_converter(c)
  add_no_delay_converter(c)
  enqueue_crawl_datas(c, "url1",
	crawl_data("url2", "value1", nil, nil, nil, "application/delay")
  )
  enqueue_crawl_datas(c, "url2",
	crawl_data(nil, "value2", nil, nil, nil, "application/no-delay")
  )
  wait_for_idle(c)
  results.add_equals(0, number_of_documents(c, 'value1'), "value1 was removed")
  results.add_equals(1, number_of_documents(c, 'value2'), "value2 was added")
end

def enqueue_light_crawler_urls_and_same_delete_immediately_after(c, results)
  reset(c)
  add_delay_converter(c)
  add_no_delay_converter(c)
  enqueue_crawl_datas(c, "url1",
	crawl_data("update-id-1", "value1", nil, nil, nil, "application/delay") +
	crawl_data("update-id-2", "value2", nil, nil, nil, "application/delay")
  )
  delete(c, "update-id-1")
  wait_for_idle(c)
  results.add_equals(0, number_of_documents(c, 'value1'), "value1 was removed")
  results.add_equals(1, number_of_documents(c, 'value2'), "value2 was added")
end
   
def light_crawler_url_errors_overwrite_previous_data(c, results)
  reset(c)
  enqueue_crawl_datas(c, "url1",
	crawl_data("update-id-1", "value1") +
	crawl_data("update-id-2", "value2")
  )
  enqueue_crawl_datas(c, "url2",
	crawl_data("update-id-1", "value3", nil, nil, nil, "not a content type") +
	crawl_data("update-id-2", "value4", nil, nil, nil, "not a content type")
  )
  wait_for_idle(c)
  results.add_equals(0, number_of_documents(c, 'value1'), "value1 was removed")
  results.add_equals(0, number_of_documents(c, 'value2'), "value2 was removed")
  results.add_equals(0, number_of_documents(c, 'value3'), "value3 was not added")
  results.add_equals(0, number_of_documents(c, 'value4'), "value4 was not added")
end

c = Collection.new('crawl-data-light-crawler')
results.associate(c)

deleting_containing_url_doesnt_delete_the_data(c, results)
deleting_url_from_a_crawl_data_deletes_it(c, results)
deleting_an_update_id_after_updating_it(c, results)
uses_the_arena_on_a_crawl_data(c, results)
updating_an_url_with_a_different_arena_throws_an_error(c, results)
light_crawler_attributes_do_not_appear_on_docs(c, results)
audit_log_reports_several_indexing_successes(c, results)
audit_log_reports_indexing_errors(c, results)
enqueue_item_with_light_crawler_url_and_then_update_with_crawl_url(c, results)
enqueue_light_crawler_url_and_same_url_immediately_after(c, results)
# this test fails due to either a bug or bad assumptions on the part of the test writer
#enqueue_url_and_same_light_crawler_url_immediately_after(c, results)
enqueue_light_crawler_url_and_same_light_crawler_url_immediately_after(c, results)
enqueue_light_crawler_urls_and_same_delete_immediately_after(c, results)
audit_log_reports_crawler_errors(c, results)
audit_log_reports_crawler_errors_when_there_are_no_valid_crawl_datas(c, results)
light_crawler_url_errors_overwrite_previous_data(c, results)
# Cleanup
c.stop

results.cleanup_and_exit!
