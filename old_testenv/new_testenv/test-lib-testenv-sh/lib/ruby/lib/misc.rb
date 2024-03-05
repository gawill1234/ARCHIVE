#!/usr/bin/env ruby

# Random junk that hasn't found another home.

# Ideally, this remains short. Stuff that starts to get big here
# should be refactored out to a separate module.

# FIXME - This is a legacy thing, to get older Ruby libraries that
# conflict with newer ones!
$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'testenv'
require 'gronk'
require 'vapi'
require 'test_results'

def msg(s, out=$stdout)
  out.puts "#{Time.now.strftime('%H:%M:%S')} #{s}"
  out.flush
end

def windows_path(path)
  not path[/^[A-Za-z]:\\/].nil?
end

def fix_path(path)
  # If it looks like we have a Windows path,
  if windows_path(path)
    # fixup any Unix-like slashes.
    path.split('/').join('\\')
  else
    path
  end
end

def is_testenv_mounted
  unless File.exists?("/testenv/CHECKFILE")
    puts "/testenv is not mounted"
    puts "Create a local directory name /testenv.  Then, as root, do:"
    puts "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
    puts "Then rerun the test"
    puts "TEST FAILED"
    exit 1
  end
end

def prep_target_system
  vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  vapi.search_service_start

  begin
    vapi.repository_get_md5(:element => 'function',
                            :name => 'velocity-date-time')
  rescue
    velocity_date_time='<function name="velocity-date-time" type="public-api">
  <prototype>
    <description name="description">Returns the current date/time.</description>
  </prototype>
  <value-of select="date:date-time()"/>
</function>'
    vapi.repository_add(:node => velocity_date_time)
  end
end

begin
  prep_target_system
rescue => exception
  puts 'prep_target_system failed:'
  puts exception
  puts 'Continuing ...'
end

def iso8601
  # Get the current date time from the target server.
  # This avoids most issues with time skew.
  vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  vapi.velocity_date_time.root.text
end

def set_option(xml, parent_name, child_name, option_name, value)
  unless value.nil?
    child = xml.xpath("//#{parent_name}/#{child_name}[@name='#{option_name}']")
    if child.empty?
      parent = xml.xpath("//#{parent_name}").first
      child = parent.add_child(Nokogiri::XML::Node.new(child_name, xml))
      child['name'] = option_name
    else
      child = child.first
    end
    child.content = value.to_s
  end
end

# Older Ruby (such as installed on testbed10) don't have Array.count.
# Monkey patch it in, if it's not already there.
if not Array.method_defined?(:count)
  class Array
    def count
      if block_given?
        c = 0
        self.each {|i| c += 1 if yield i}
        c
      else
        self.length
      end
    end
  end
end

