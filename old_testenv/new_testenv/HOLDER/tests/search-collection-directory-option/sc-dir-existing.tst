#!/usr/bin/env ruby
# Test: sc-dir-existing
# This test tests that existing search collection data is not moved when the search-collection-dir option is
# set.
#
# Create collection 1
# Enqueue data
# Query and check path
# Update vivisimo.conf
# Create collection 2
# Enqueue data
# Query and check path
# Delete both collections
# Reset vivisimo.conf

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'

# Test Cases
WIN_LOCAL = "\n  <option name=\"search-collections-dir\" value=\"c:\\temp\\\" />"
WIN_LOCAL_COMP = "c:\\temp"
LINUX_LOCAL = "\n  <option name=\"search-collections-dir\" value=\"/tmp\" />"
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
test_results = TestResults.new("sc-dir-existing",
                               "1.  Ensure existing data not moved.")

# Cleanup test files written by previous test
if File.exist?("vivisimo.conf.backup")
  File.delete("vivisimo.conf.backup")
end

if File.exist?("temp.txt")
  File.delete("temp.txt")
end

msg "Setup"
collection = Collection.new("sc-dir-exist", velocity, user, password)
collection.delete()
collection.create()

collection.enqueue_xml(CRAWL_NODES)
# Query collection
query_results = vapi.query_search(:sources => "sc-dir-exist",
                            :query => "")
sum = 0
query_results.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}

test_results.add(sum == 1,
                 "Data not returned for collection 1.  Expected 1, got" + sum.to_s)

# Get Install Dir
gronk = Gronk.new
install_dir = gronk.installed_dir
conf_file_path = "#{install_dir}/vivisimo.conf"

# Backup vivisimo.conf
msg "Backup vivisimo.conf"
test = gronk.get_file(conf_file_path, true)
test = test.strip
#csring = "cmd.exe /C /Q /A \"del /Q /F " + conf_file_path + "\""
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
  #msg csring
  #gronk.execute(csring, 'binary') 
  msg conf_file_path
  gronk.send_file("temp.txt", conf_file_path)
  msg "copy successful"
rescue
  msg "Gronk reported an error on file copy.  Assuming good copy and continuing."
end

# Restart Query Service
vapi.search_service_start()

# Create search collection
collection2 = Collection.new("sc-dir-existing2", velocity, user, password)
collection2.delete()
collection2.create()

# Crawl collection
collection2.enqueue_xml(CRAWL_NODES)
# Query collection
query_results = vapi.query_search(:sources => "sc-dir-existing2",
                            :query => "")
sum = 0
query_results.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}

test_results.add(sum == 1,
                 "Updated config collection query",
                 "Updated config collection query. No Search results returned.  Expected 1, got" + sum.to_s)

# Check data dir
path = collection2.crawl_path_list()
if (TESTENV.windows == true)
  test_results.add(path[0].index(WIN_LOCAL_COMP) != nil,
                   "Updated config collection query. New collection data dir.",
                   "Updated config collection query. New collection data not in expected dir:" + path[0])
else
  test_results.add(path[0].index(LINUX_LOCAL_COMP) != nil,
                   "Updated config collection query. New collection data dir.",
                   "Updated config collection query. New collection data not in expected dir:" + path[0])
end

# Check existing collection location
# Query collection
query_results = vapi.query_search(:sources => "sc-dir-exist",
                            :query => "")
sum = 0
query_results.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}

test_results.add(sum == 1,
                 "Data not returned for collection 1 after update.  Expected 1, got" + sum.to_s)

path = collection.crawl_path_list()
if (TESTENV.windows == true)
  test_results.add(path[0].index(WIN_LOCAL_COMP) != nil,
                   "Existing collection query after update. New collection data dir.",
                   "Existing collection query after update. New collection data not in expected dir:" + path[0])
else
  test_results.add(path[0].index(LINUX_LOCAL_COMP) != nil,
                   "Existing collection query after update. New collection data dir.",
                   "Existing collection query after update. New collection data not in expected dir:" + path[0])
end

# Cleanup.  Replace config file and delete collection.
begin
  msg "Cleanup."
  collection2.delete()
  #msg csring
  #gronk.execute(csring, 'binary') 
  gronk.send_file("vivisimo.conf.backup", conf_file_path)
  vapi.search_service_stop()
  vapi.search_service_start()
  collection.delete()
rescue
  msg "Gronk reported an error."
  vapi.search_service_stop()
  vapi.search_service_start()
end

test_results.cleanup_and_exit!
