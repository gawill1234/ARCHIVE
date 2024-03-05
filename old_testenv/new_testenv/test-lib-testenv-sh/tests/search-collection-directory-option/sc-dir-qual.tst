#!/usr/bin/env ruby
# Test: sc-dir-qual
#
#  Test that only fully qualifed directories are valid configuration options.
#  Configurations being tested:
#  Relative file path that does exist.
#  Relative file path that does not exist.
#  File path containing a read-only location.
#  File path that does not give permissions to the vivisimo user to write.

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'

# Test cases
WIN_RELATIVE = "<option name=\"search-collections-dir\" value=\"\\temp\" />"
WIN_RELATIVE_NOTEXIST = "<option name=\"search-collections-dir\" value=\"c:\\blah\" />"
LINUX_RELATIVE = "./"
LINUX_RELATIVE_NOTEXIST = "<option name=\"search-collections-dir\" value=\"./blah\" />"

# Variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
test_results = TestResults.new("sc-dir-qualified",
                               "1.  Valid Relative directory.",
                               "2.  Invalid Relative directory.")
collection = Collection.new("sc-dir-qual", velocity, user, password)
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
    msg "Test: #{WIN_RELATIVE}"
    run_test(WIN_RELATIVE, test, conf_file_path, test_results, false, collection)
    restore_backup(vapi, gronk, conf_file_path)
    test = gronk.get_file(conf_file_path)
    msg "Test: #{WIN_RELATIVE_NOTEXIST}"
    run_test(WIN_RELATIVE_NOTEXIST, test, conf_file_path, test_results, false, collection)
    restore_backup(vapi, gronk, conf_file_path)
  else
    msg "Test: #{LINUX_RELATIVE}"
    run_test(LINUX_RELATIVE, test, conf_file_path, test_results, false, collection)
    restore_backup(vapi, gronk, conf_file_path)
    msg "Test: #{LINUX_RELATIVE_NOTEXIST}"
    test = gronk.get_file(conf_file_path)
    run_test(LINUX_RELATIVE_NOTEXIST, test, conf_file_path, test_results, false, collection)
    restore_backup(vapi, gronk, conf_file_path)
  end

  # Cleanup.  Replace config file and delete collection.
  msg "Cleanup."
  restore_backup(vapi, gronk, conf_file_path)
end

test_results.cleanup_and_exit!
