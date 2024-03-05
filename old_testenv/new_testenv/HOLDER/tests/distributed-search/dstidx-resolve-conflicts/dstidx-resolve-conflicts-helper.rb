require "misc"
require "collection"
require "repl-synch-common"
require 'timeout'

def configure_remote_server_and_client(results)
  master_one = Collection.new("#{TESTENV.test_name}-master-one")
  master_one.delete
  master_one.create('default-push')

  master_two = Collection.new("#{TESTENV.test_name}-master-two")
  master_two.delete
  master_two.create('default-push')

  port_one = 12322
  port_two = 12321

  configure_remote_common(master_one)
  configure_remote_server(master_one, master_two.name, port_one)
  configure_remote_common(master_one)
  configure_remote_client(master_one, master_two.name, "127.0.0.1:#{port_two}")

  configure_remote_common(master_two)
  configure_remote_server(master_two, master_one.name, port_two)
  configure_remote_common(master_two)
  configure_remote_client(master_two, master_one.name, "127.0.0.1:#{port_one}")

  results.associate(master_one)
  results.associate(master_two)

  return master_one, master_two
end

def crawl_xml_and_stop_crawler(collection, packet)
  Timeout::timeout(120) do
    collection.crawler_start
    collection.enqueue(packet)
    collection.wait_until_idle
    collection.crawler_stop
  end
end

def resume_crawler_and_wait_for_idle(collection)
  Timeout::timeout(120) do
    collection.crawler_start
    sleep(30)
    collection.wait_until_idle
  end
end

def query(c, query = '', arena=nil, num=10)
  c.vapi.query_search(:query => query, :sources => c.name, :arena => arena, :num => num)
end

def number_of_documents(c, query = '', arena=nil)
  qr = query(c, query, arena)
  qr.xpath('count(//document)').to_i
end

# test data
CRAWL_URL_START = <<-HERE
<crawl-url enqueue-type="reenqueued"
           status="complete"
           synchronization="indexed"
           url="foo"
           forced-vse-key="foobar"
           >
  <crawl-data>
HERE

CRAWL_URL_END = <<-HERE
  </crawl-data>
</crawl-url>
HERE

OLD_DATA = <<-HERE
overwrite this
HERE

NEW_DATA = <<-HERE
new data
HERE

CRAWL_DELETE = <<-HERE
<crawl-delete url="foo" enqueue-type="reenqueued" synchronization="indexed"/>
HERE
