#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'

results = TestResults.new("Test for bug 23148: velocity-shutdown taking a",
                          "really long time, spawning multiple admin-axl",
                          "processes that are taking up multiple GB of ram.")
# Don't get the system report automatically at the end.
# (It won't work after if the velocity shutdown is successful.)
results.need_system_report = false

vapi2 = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
existing_collection_count = vapi2.repository_list_xml.
  xpath('/vce/vse-collection').length
msg "There are #{existing_collection_count} existing collections"

if existing_collection_count < 3000
  msg "Creating 5000 additional collections"
  template = 'bug-23148-%04d'
  thread_number = -1
  threads = (0..200).map do
    thread_number += 1
    Thread.new(25*thread_number) do |j|
      vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
      25.times do |i|
        begin
          vapi.search_collection_create(:collection => template%(j+i))
        rescue
          msg "Couldn't create collection '#{template%(j+i)}', proceeding..."
        end
      end
    end
  end

  threads.each {|t| t.join}
  msg "Collections created."

  # Do grab a system report, in case anything went weird with the creates.
  results.system_report
end

gronk = Gronk.new
vshut = fix_path(gronk.installed_dir + '/bin/velocity-shutdown') +
  ' --force --yes'
msg "Attempting velocity shutdown:"
msg "#{vshut}"
msg gronk.execute(vshut)
msg "Completed velocity shutdown attempt."

results.cleanup_and_exit!
