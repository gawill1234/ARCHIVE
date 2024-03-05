#!/usr/bin/env ruby
# Test: sc-dir-filenames
#
# Test that invalid filenames do not cause crashes

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'

# Test Cases
WIN_LONG = "<option name=\"search-collections-dir\" value=\"c:\\temp\\longfilenamewithmorethan260charactersblahblahblahblahblahblahblahblahblahblhablhablhablhablhablhablhablhablhablhablhablhablhablhablhablahblahbalbhalhblhbblahblahblahblahblhabhlahblhalbhlahblahhdhdhdhdhdhdhdhdhdhdhdhdhddhhlonglonglonglognlonglonglongerlongerlongerlongerlonger\\\" />"
WIN_COLON = "<option name=\"search-collections-dir\" value=\"c:\\temp\\blah:\" />"
WIN_SPACE= "<option name=\"search-collections-dir\" value=\"c:\\temp\\add space\" />"
LINUX_SPACE = "<option name=\"search-collections-dir\" value=\"/tmp/blah space\" />"
LINUX_LOCAL_COMP = "/tmp"

# Variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
test_results = TestResults.new("sc-dir-filenames")
collection = Collection.new("sc-dir-filenames", velocity, user, password)
vapi = Vapi.new(velocity, user, password)

def restore_backup(vapi, gronk, conf_file_path)
  begin
    vapi.search_service_stop()
    gronk.send_file("vivisimo.conf.backup", conf_file_path)
    vapi.search_service_start()
    msg "Backup vivisimo.conf restored."
  rescue
    msg "Gronk reported an error on file copy.  Assuming good copy and continuing."
  end
end

def run_test(update_path, update_text, conf_file_path, test_results, succeed, collection)
  velocity = TESTENV.velocity
  user = TESTENV.user
  password = TESTENV.password
  gronk = Gronk.new
  vapi = Vapi.new(velocity, user, password)

  vapi.search_service_stop()
  index = update_text.index("<options>")
  new_text = update_text
  new_text.insert(index+9, update_path)

  f = File.new("temp.txt", "w")
    f.write(new_text)
    f.close()

  begin
    msg "Adding search-collection-dir option to vivisimo.conf"
    gronk.send_file("temp.txt", conf_file_path)
    msg "copy successful"
  rescue
    msg "Gronk reported an error on file copy.  Assuming good copy and continuing."
  end

  # Restart Query Service
  vapi.search_service_start()
  begin
    # Create search collection
    collection.delete()
    collection.create()
  rescue
    test_results.add(succeed == false,
                     "Search Collection creation did not succeed.",
                     "Failure creating search collection for: " + update_path)
    return
  end
  test_results.add(succeed == true,
                   "Search Collection creation did succeed.",
                   "Search collection created for: " + update_path)
  collection.delete()
end

# Cleanup test files written by previous test
if File.exist?("vivisimo.conf.backup")
  File.delete("vivisimo.conf.backup")
end

if File.exist?("temp.txt")
  File.delete("temp.txt")
end


begin
  # Get Install Dir
  gronk = Gronk.new
  install_dir = gronk.installed_dir
  conf_file_path = "#{install_dir}/vivisimo.conf"
  msg conf_file_path

  # Backup vivisimo.conf
  msg "Backup vivisimo.conf"
  test = gronk.get_file(conf_file_path, true)
  test = test.strip
  # Add a bunch of spaces as a hack to gronk
  #test = test + "                                                                                                 "
  #test = test + "                                                                                                 "
  f = File.new("vivisimo.conf.backup", "w")
    f.write(test)
    f.close()

  if (TESTENV.windows == true)
    msg "Test: #{WIN_LONG}"
    run_test(WIN_LONG, test, conf_file_path, test_results, false, collection)
    restore_backup(vapi, gronk, conf_file_path)
    test = gronk.get_file(conf_file_path)
    msg "Test: #{WIN_COLON}"
    run_test(WIN_COLON, test, conf_file_path, test_results, false, collection)
    restore_backup(vapi, gronk, conf_file_path)
    test = gronk.get_file(conf_file_path)
    msg "Test: #{WIN_SPACE}"
    run_test(WIN_SPACE, test, conf_file_path, test_results, true, collection)
    restore_backup(vapi, gronk, conf_file_path)
  else
    msg "Test: #{LINUX_SPACE}"
    run_test(LINUX_SPACE, test, conf_file_path, test_results, true, collection)
    restore_backup(vapi, gronk, conf_file_path)
  end

  # Cleanup.  Replace config file and delete collection.
  msg "Cleanup."
  restore_backup(vapi, gronk, conf_file_path)
end

test_results.cleanup_and_exit!
