#!/usr/bin/env ruby

require 'cgi'
require 'fileutils'
require 'open-uri'

def form_urlencode(data)
  return data if data.is_a? String
  return data.map {|key,value|
    [CGI.escape(key.to_s), CGI.escape(value.to_s)].join('=')
  }.join('&')
end

def http_get(url, params)
  full_uri = '%s?%s' % [url, form_urlencode(params)]
  puts full_uri
  retval = ''
  open(full_uri, read_timeout: 300) {|f| retval = f.read}
  puts retval
  retval
end

def get_new_run_id
  target_translation = {
    'linux32'   => 'i386',
    'linux64'   => 'x86_64',
    'solaris32' => 'sparc',
    'solaris64' => 'sparc64',
    'windows32' => 'i386',
    'windows64' => 'x86_64'
  }

  launch_run = 'http://gauge.bigdatalab.ibm.com/Services/TestRun.svc/LaunchRun/'
  major, minor, build = ENV['VIVFULLBUILD'].split('-')
  if major.to_f.to_s == major
    ENV['VIVVERSION'] = major
  else                          # Not cleanly a number:
    ENV['VIVVERSION'] = '99.9'  # force numeric and crazy high.
  end
  params = {
    'Suite'              => 'Full Regression',
    'RunnerHostName'     => 'testbed14',
    'TestbedHostName'    => ENV['VIVHOST'].split('.')[0],
    'BuildVersion'       => [major, minor].join('-'),
    'BuildNumber'        => build,
    'TargetArchitecture' => target_translation[ENV['VIVTARGETARCH']]
  }

  launch_response = http_get(launch_run, params)
  puts launch_response
  /<ReturnID>([0-9]+)<\/ReturnID>/.match(launch_response)[1]
end

if __FILE__ == $0
  xml_results_file = ARGV[0]

  # Automatically flush every output
  $stdout.sync = true

  myid = get_new_run_id
  mydir = "vtd_#{myid}"

  FileUtils.mkdir(mydir)
  FileUtils.cd(mydir, :verbose => true)

  fork { exec(*[ENV['TEST_ROOT'] + '/bin/test-server2.rb',
                '--runid', myid,
                '--xmlout', xml_results_file]) }

  sleep 10                      # Gauge can be horridly slow at times.

  if system(*[ENV['TEST_ROOT'] + '/bin/test-runner.rb', myid])
    exit(0)
  else
    exit(1)
  end
end
