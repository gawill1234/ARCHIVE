#!/usr/bin/env ruby

require 'cgi'
require 'fileutils'
require 'open-uri'
require 'rubygems'
require 'nokogiri'

def form_urlencode(data)
  return data if data.is_a? String
  return data.map {|key,value|
    [CGI.escape(key.to_s), CGI.escape(value.to_s)].join('=')
  }.join('&')
end

def http_get(url, params)
  full_uri = '%s?%s' % [url, form_urlencode(params)]
  retval = ''
  #### puts full_uri
  open(full_uri) {|f| retval = f.read}
  #### puts retval
  retval
end

def get_run(host, version='8.0-0')
  target_translation = {
    'testbed1'    => 'x86_64',
    'testbed2'    => 'x86_64',
    'testbed4'    => 'x86_64',
    'testbed6'    => 'x86_64',
    'testbed7'    => 'sparc64',
    'testbed8'    => 'i386',
    'testbed9'    => 'x86_64',
    'testbed10'   => 'i386',
    'testbed11'   => 'i386',
    'testbed12'   => 'sparc64',
    'testbed14'   => 'x86_64',
    'testbed15'   => 'x86_64',
    'testbed16-1' => 'x86_64',
    'testbed16-2' => 'x86_64',
    'testbed16-3' => 'x86_64',
    'testbed16-4' => 'x86_64',
    'testbed17'   => 'x86_64'
  }

  launch_run = 'http://gauge.bigdatalab.ibm.com/Services/TestRun.svc/PreviewRun/'
  params = {
    'Suite'              => 'Full Regression',
    'RunnerHostName'     => 'testbed14',
    'TestbedHostName'    => host,
    'BuildVersion'       => version,
    'BuildNumber'        => '',
    'TargetArchitecture' => target_translation[host]
  }

  ret = http_get(launch_run, params)
  xml = Nokogiri::XML(ret)
  xml.xpath('//xmlns:TestRunDetail').map{|node|
    [node['TestName'], node['TestCommand'], node['TimeOut'].to_i]
  }
end

if __FILE__ == $0
  get_run(*ARGV).each{|name,cmd,time| puts '(run=%d)%s' % [60*time, cmd]}
end
