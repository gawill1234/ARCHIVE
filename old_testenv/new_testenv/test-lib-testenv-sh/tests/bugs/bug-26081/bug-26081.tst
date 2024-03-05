#!/usr/bin/env ruby
#
# This test verifies bug 26081.  The goal of the test is to ensure that dictionaries
# are not rebuilt when a collection is refreshed in staging.
#
# The test creates a search collection and enqueues data to the collection.  A dictionary is
# then built based on that collection.  The count of the dictionary is checked to ensure it
# is correct.  A crawl-delete is then enqueued to the search collection and the crawl refreshed.
# The count of the dictionary is then checked again to ensure it did not change.

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'
require 'misc'
require 'collection'
require 'testenv'
require 'gronk'
require 'vapi'
require 'dictionary'

# Variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
CRAWL_NODES = '      <crawl-urls>
        <crawl-url url="a" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="phrase" type="text">hello world</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="b" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="phrase" type="text">foo</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="c" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="phrase" type="text">try using CONTENT text CONTAINING</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="d" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="phrase" type="text">bar test add more words</content>
            </document>
          </crawl-data>
        </crawl-url>
      </crawl-urls>'
CRAWL_DELETE = '<crawl-delete url="c"/>'
vapi = Vapi.new(velocity, user, password)
compare_file = "correct_file"

begin
  results = TestResults.new('Test bug 26081. Verifies that dictionary is not rebuilt when collection is refreshed in staging.')
  # Create search collection
  msg "Creating search collection: bug-26081"
  collection = Collection.new("bug-26081", velocity, user, password)
  results.associate(collection)
  collection.delete()
  collection.create()

  # Repository update
  msg "Update search collection configuration"
  f = File.open("bug-26081.xml")
  repository_xml = Nokogiri::XML(f)
  f.close
  vapi.repository_update(:node => repository_xml)

  collection.enqueue_xml(CRAWL_NODES)

  msg "Enqueueing data to collection: bug-26081"
  vapi.search_collection_enqueue_xml(:collection => "bug-26081",
                                     :subcollection => "staging",
                                     :crawl_nodes => CRAWL_NODES)

  # Stop query service to prevent automatic push
  vapi.search_service_stop()

  # Crawl collection
  msg "Enqueueing data to collection in staging: bug-26081"
  vapi.search_collection_enqueue_xml(:collection => "bug-26081",
                                     :subcollection => "staging",
                                     :crawl_nodes => CRAWL_NODES)
  # Enqueue crawl deletes
  msg "Enqueue crawl delete"
  vapi.search_collection_enqueue_deletes(:collection => "bug-26081",
                              :subcollection => "staging",
                             :crawl_deletes => CRAWL_DELETE,
                             :crawl_type => "resume_and_idle")

  vapi.search_collection_crawler_start(:collection => "bug-26081",
                                       :subcollection => "staging",
                                       :type => "refresh")

  vapi.search_service_start()
  sleep(5)
  
  # Check wildcard dictionary
  msg "Find dictionary and compare it with expected."
  gronk = Gronk.new()
  install_dir = gronk.installed_dir
  if (TESTENV.windows == true)
    dictionary_dir_path = install_dir + "\\data\\search-collections\\4b8\\bug-26081\\crawl0\\expansions\\"
  else
    dictionary_dir_path = install_dir + "/data//search-collections/4b8/bug-26081/crawl0/expansions/"
  end

  # Searching file by typical name (the name has changed between releases).
  # Chose to continue using hard-coded names, because there could be 
  # other files in expansions directory.
  if gronk.check_file_exists(dictionary_dir_path + "fcda265486028e353be9954f4e6ccfc4")
    dictionary_path = dictionary_dir_path + "fcda265486028e353be9954f4e6ccfc4"
  elsif gronk.check_file_exists(dictionary_dir_path + "20d34bab21bddaf8e66318b24afb95fa")
    dictionary_path = dictionary_dir_path + "20d34bab21bddaf8e66318b24afb95fa"
  else 
    dictionary_path = ""
    msg "Dictionary file doesn't exist or has new unexpected name"
  end
  results.add(dictionary_path != "", "Dictionary file found", "Dictionary file not found")

  msg "dictionary_path=" + dictionary_path
  if dictionary_path != ""
    File.open("test_file", 'w') do |f|
      test_dict = gronk.get_file(dictionary_path).split("\n")
      test_dict.sort.each do |l|
        f.puts(l)
      end
    end
    files_equal = FileUtils.compare_file('test_file', 'correct_file')
    results.add(files_equal, "Dictionary does match after refresh.")
  end
  results.cleanup_and_exit!
end


