#!/usr/bin/env ruby
# Test: sc-dir-running
#
# Test that the option is not respected when the service has not been restarted.
# Test retreives the current vivisimo.conf file.  Saves it as a backup.  Modifies the file.
# Then creates a search collection, enqueues some data, and performs a search.  The collection
# should be in the default data directory.
#
# Note the update DOES succeed without restarting the services.

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'

WIN_LOCAL = "<option name=\"search-collections-dir\" value=\"c:\\temp\\\" />"
WIN_LOCAL_COMP = "c:\\temp"
LINUX_LOCAL = "<option name=\"search-collections-dir\" value=\"/tmp\" />"
LINUX_LOCAL_COMP = "/tmp"

# Variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
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
vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new("sc-dir-valid",
                               "1.  Update vivisimo.conf without restarting the service.")

# Cleanup test files written by previous test
if File.exist?("vivisimo.conf.backup")
  File.delete("vivisimo.conf.backup")
end

if File.exist?("temp.txt")
  File.delete("temp.txt")
end

# Get Install Dir
gronk = Gronk.new
install_dir = gronk.installed_dir
conf_file_path = "#{install_dir}/vivisimo.conf"

# Backup vivisimo.conf
msg "Backup vivisimo.conf"
test = gronk.get_file(conf_file_path)
test = test.strip
# Add a bunch of spaces as a hack to gronk
#test = test + "                                                                                                 "
#test = test + "                                                                                                 "
f = File.new("vivisimo.conf.backup", "w")
  f.write(test)
  f.close()

# Edit vivisimo.conf
index = test.index("<options>")
if (TESTENV.windows == true)
  test.insert(index+9, WIN_LOCAL)
else
  test.insert(index+9, LINUX_LOCAL)
end

f = File.new("temp.txt", "w")
  f.write(test)
  f.close()

begin
  msg "Adding search-collection-dir option to vivisimo.conf"
  gronk.send_file("temp.txt", conf_file_path)
  msg "copy successful"
rescue
  msg "Gronk reported an error on file copy.  Assuming good copy and continuing."
end

# Create search collection
collection = Collection.new("sc-dir-running", velocity, user, password)
collection.delete()
collection.create()

# Crawl collection
collection.enqueue_xml(CRAWL_NODES)
# Query collection
query_results = vapi.query_search(:sources => "sc-dir-running",
                            :query => "")
sum = 0
query_results.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}

test_results.add(sum == 1,
                 "Local Directory test.",
                 "Local Directory test. No Search results returned.  Expected 1, got" + sum.to_s)

# Check data dir
path = collection.crawl_path_list()
if (TESTENV.windows == true)
  test_results.add(path[0].index(WIN_LOCAL_COMP) != nil,
                   "Local Directory test. Data dir.",
                   "Local Directory test. Data not in expected dir:" + path[0])
else
  test_results.add(path[0].index(LINUX_LOCAL_COMP) != nil,
                   "Local Directory test. Data dir.",
                   "Local Directory test. Data not in expected dir:" + path[0])
end

# Cleanup.  Replace config file and delete collection.
begin
  msg "Cleanup."
  collection.delete()
  gronk.send_file("vivisimo.conf.backup", conf_file_path)
rescue
  msg "Gronk reported an error."
  vapi.search_service_stop()
  vapi.search_service_start()
end

test_results.cleanup_and_exit!
