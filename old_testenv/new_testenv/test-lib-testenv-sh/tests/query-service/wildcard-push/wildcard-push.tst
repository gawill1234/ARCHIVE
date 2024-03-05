#!/usr/bin/env ruby

require 'misc'
require 'collection'
require 'timeout'
require 'gronk'

gronk = Gronk.new

SERVER_COLLECTION_NAME = "#{TESTENV.test_name}-server"
CLIENT_COLLECTION_NAME = "#{TESTENV.test_name}-client"

REL_DIR = "/tmp/#{TESTENV.test_name}"
ABS_DIR = "#{gronk.installed_dir}#{REL_DIR}"

FILENAME_1 = 'zombie.txt'
FILENAME_2 = 'fish.txt'

TEST_WORD_1 = 'horde'
TEST_WORD_2 = 'school'

def create_collection(results, name, based_on='default')
  collection = Collection.new(name)
  results.associate(collection)
  collection.create(based_on)
  collection
end

def config_xml(xml, xpath, xml_value_string)
  xml_value = Nokogiri::XML(xml_value_string).root
  xml_foo = xml.xpath(xpath).first
  xml_foo << xml_value
end

def create_server_collection(results)
  collection = create_collection(results, SERVER_COLLECTION_NAME)
  collection.add_crawl_seed('vse-crawler-seed-files', :files => ABS_DIR)
  collection.set_index_options(:term_expand_dicts => true)

  xml = collection.xml

  meta_info = '<vse-meta-info name="enable-remote">enable-remote</vse-meta-info>'
  config_xml(xml, '/vse-collection/vse-meta', meta_info)

  remote = <<"END"
<vse-remote>
  <vse-remote-option name="auto-push">auto-push</vse-remote-option>
  <vse-remote-mirror>
    <vse-remote-server>
      <vse-remote-server-option name="collection">#{CLIENT_COLLECTION_NAME}</vse-remote-server-option>
    </vse-remote-server>
  </vse-remote-mirror>
</vse-remote>
END
  config_xml(xml, '/vse-collection/vse-config', remote)

  collection.set_xml(xml)
  collection
end

def create_client_collection(results)
  collection = create_collection(results, CLIENT_COLLECTION_NAME)
  collection.set_index_options(:term_expand_dicts => true)
  collection
end

def setup(gronk)
  Collection.new(SERVER_COLLECTION_NAME).delete
  Collection.new(CLIENT_COLLECTION_NAME).delete
  gronk.rm_file("#{ABS_DIR}/#{FILENAME_1}")
  gronk.rm_file("#{ABS_DIR}/#{FILENAME_2}")
end

def wait_for_query(collection, word, timeout_seconds=60)
  Timeout::timeout(timeout_seconds) do
    loop do
      xml = collection.search(word)
      return if xml.xpath('//document').first
      sleep 1
    end
  end
end

results = TestResults.new('Test for bug 26019: wildcard expansions not generated on mirror after refresh on master')
results.need_system_report = false

# Create two collections configured for "old-style" remote push.
setup(gronk)
server_collection = create_server_collection(results)
client_collection = create_client_collection(results)

# Crawl a document.
gronk.create_file("#{ABS_DIR}/#{FILENAME_1}") { |x| x.write(TEST_WORD_1) }
server_collection.crawler_start
server_collection.wait_until_idle

# Verify that a wildcard query finds the document on the server and client.
wait_for_query(server_collection, "m/#{TEST_WORD_1}/")
wait_for_query(client_collection, "m/#{TEST_WORD_1}/")

# Crawl another document.
gronk.create_file("#{ABS_DIR}/#{FILENAME_2}") { |x| x.write(TEST_WORD_2) }
server_collection.crawler_start(nil, :type => 'refresh-inplace')
server_collection.wait_until_idle

# Verify that a wildcard query finds the document on the server and client.
wait_for_query(server_collection, "m/#{TEST_WORD_2}/")
wait_for_query(client_collection, "m/#{TEST_WORD_2}/")

# Cleanup
results.cleanup_and_exit!(true)
