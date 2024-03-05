#!/usr/bin/env ruby

require 'cgi'
require 'mysql'
require 'nokogiri'
require 'open-uri'
require 'time'

TEST_RUN_SVC = 'http://gauge.vivisimo.com/Services/TestRun.svc'
DB = Mysql::new('eng-db.vivisimo.com',
                'gaugereader',
                'NqqtS4vGveDGjDsa',
                'gauge')

RUNID_FOR_MACHINE = DB.prepare('select s.id
  from tblTestRunSummary s, tblTestBeds t, tblMachines m
  where m.MachineName=?
    and s.TargetTestbedID = t.id
    and t.MachineID = m.id
    and s.EndTime is null')

def active_runid(target)
  runid = nil
  RUNID_FOR_MACHINE.execute(target).each{|row|
    raise 'Multiple active runs found for %s!' % target if runid
    runid = row.first
  }
  runid
end

def get_pids(re)
  %x{grep -l '#{re}' /proc/*/cmdline 2> /dev/null}.
    split("\n").
    map{|line| line.split('/')[2]}
end

def do_cmd(cmd)
  puts cmd.join(' ')
  system(*cmd)
end

# Kill off the test-runners and their children, then kill off the test-server.
def kill_previous_run(runid)
  while true
    pids = get_pids('test-runner\\.rb.%d' % runid)
    break if pids.length == 0
    pgids = pids.map{|pid|
      begin
        open('/proc/%d/stat' % pid) {|f| f.read.split[4]}
      rescue
        nil
      end
    }.select{|pgid| pgid}
    do_cmd(['/bin/kill', '-9'] + pgids.map{|z| '-%s'%z}) if pgids.length > 0
    sleep 1
  end

  # Because of the test-runner process group kills above,
  # there is a fair chance the test-server is already dead.
  pids = get_pids('test-server2\\.rb --runid %d ' % runid)
  do_cmd(['/bin/kill', '-9'] + pids) if pids.length > 0
end

FILE_TYPE = { linux: 'tar.gz', solaris: 'tar.gz', windows: 'exe' }

def installer_path(build, os, hw)
  '/candidates/velocity/%s/vivisimo-velocity-%s-%s-%s.%s' %
    [build, build, os, hw, FILE_TYPE[os.to_sym]]
end

TARGET_MAP = { 'testbed1'    => ['linux',   'x86_64'],
               'testbed2'    => ['windows', 'x86_64'],
               'testbed4'    => ['linux',   'x86_64'],
               'testbed6'    => ['linux',   'x86_64'],
               'testbed7'    => ['solaris', 'sparc64'],
               'testbed8'    => ['windows', 'i386'],
               'testbed9'    => ['windows', 'x86_64'],
               'testbed10'   => ['linux',   'i386'],
               'testbed11'   => ['windows', 'i386'],
               'testbed12'   => ['solaris', 'sparc64'],
               'testbed14'   => ['linux',   'x86_64'],
               'testbed15'   => ['windows', 'x86_64'],
               'testbed16-1' => ['linux',   'x86_64'],
               'testbed16-2' => ['linux',   'x86_64'],
               'testbed16-3' => ['windows', 'x86_64'],
               'testbed16-4' => ['windows', 'x86_64'],
               'testbed16-5' => ['windows', 'x86_64'],
               'testbed17'   => ['windows', 'x86_64'],
               'symc-beast'  => ['windows', 'x86_64'],
               'symc-beast2' => ['windows', 'x86_64'],
               'symc-slim'   => ['windows', 'x86_64'],
               'symc-slim2'  => ['windows', 'x86_64'] }

def wait_for_build(target, build)
  os, hw = TARGET_MAP[target]
  path = installer_path(build, os, hw)
  puts 'Waiting for %s to appear...' % path unless File.exists?(path)
  while not File.exists?(path)
    sleep 1
  end
end

# Do a standard run_regression.py launch.
def launch_new_run(target, build)
  do_cmd(['./run_regression.py', build, target])
end

def form_urlencode(data)
  return data if data.is_a? String
  return data.map {|key,value|
    [CGI.escape(key.to_s), CGI.escape(value.to_s)].join('=')
  }.join('&')
end

def http_get(url, params)
  full_uri = '%s?%s' % [url, form_urlencode(params)]
  # puts full_uri
  retval = ''
  open(full_uri) {|f| retval = f.read}
  # puts retval if retval.length < 1024
  retval
end

# Grab the details for tests that haven't checked in as finished.
def gauge_remainder(runid)
  xml = Nokogiri::XML(http_get(TEST_RUN_SVC + '/GetRun/', 'RunID' => runid))
  xml.xpath('//xmlns:TestRunDetail').
    select{|c1| c1['StartTime'] == 'None' or c1['EndTime'] == 'None' }.
    map{|c2| Hash[c2.keys.map{|k| [k.to_sym, c2[k].to_s]}]}
end

# Abort all tests that have not yet completed.
def abort_tests(runid)
  gauge_results = gauge_remainder(runid)
  puts 'Gauge shows %d unfinished tests' % gauge_results.length
  gauge_results.each {|g|
    if g[:StartTime] == 'None'
      args = {:DetailID  => g[:ID], :LogFilePath => '/' }
      http_get(TEST_RUN_SVC + '/StartTest/', args)
    end
    if g[:EndTime] == 'None'
      args = {:DetailID  => g[:ID], :Result => 'Aborted'}
      http_get(TEST_RUN_SVC + '/StopTest/', args)
    end
  }
end

# Get the test run end time from Gauge.
def gauge_run_end(runid)
  xml = Nokogiri::XML(http_get(TEST_RUN_SVC + '/GetRun/', 'RunID' => runid))
  xml.xpath('//xmlns:TestRunReport/@EndTime').first.value
end

# Abort a regression run in Gauge.
def abort_previous_run(runid)
  abort_tests(runid)

  # Does Gauge think this run is complete?
  if gauge_run_end(runid) == 'None'
    # Need to finish out the run.
    http_get(TEST_RUN_SVC + '/StopRun/', :RunID => runid)
  end
end

if __FILE__ == $0
  require 'trollop'
  opts = Trollop::options do
    banner('Kills a running regression and optionally launches a new one.

If a build is given, we wait for that build to
become available before killing off the old run.
 ')
    opt(:build, 'Velocity build', type: :string)
    opt(:target, 'Target host', type: :string, required: true)
  end

  runid = active_runid(opts[:target])
  puts 'Found active run id=%d for %s.' % [runid, opts[:target]]
  wait_for_build(opts[:target], opts[:build]) if opts[:build]
  killer = Thread.new {
    puts 'Killing run id=%d.' % runid
    kill_previous_run(runid)
    puts 'Aborting run id=%d.' % runid
    abort_previous_run(runid)
  }
  launch_new_run(opts[:target], opts[:build]) if opts[:build]
  killer.join
end
