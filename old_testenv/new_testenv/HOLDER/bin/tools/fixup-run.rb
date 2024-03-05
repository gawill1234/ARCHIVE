#!/usr/bin/env ruby

require 'cgi'
require 'time'
require 'open-uri'
require 'nokogiri'
require './results'

# TEST_RUN_SVC = 'http://10.17.10.99:390/Services/TestRun.svc'
TEST_RUN_SVC = 'http://gauge.vivisimo.com/Services/TestRun.svc'

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
  open(full_uri) {|f| retval = f.read}
  puts retval if retval.length < 1024
  retval
end

# filename is something like "/testenv/NEW_RESULTS/linux_64/7.5-7-rc1"
def list_of_results(filename, xml)
  puts "I see filename '#{filename}'"
  # target is something like "linux_64"
  # run is something like "7.5-7-rc1"
  target, run = filename.split('/')[-2..-1]
  xml.root.children.xpath('//test').map {|node|
    TestResult.new(target, run, node)
  }
end

# <TestRunDetail ID="133468" TestType="Functional" TestName="refresh-stress" TestCommand="./refresh-stress.tst" TimeOut="480" StartTime="None" EndTime="10/18/2010 1:41:45 PM"><LogFilePath>Unknown</LogFilePath><Notes>None</Notes><Metrics/></TestRunDetail>

def gauge_remainder(runid)
  xml = Nokogiri::XML(http_get(TEST_RUN_SVC + '/GetRun/', 'RunID' => runid))
  # Grab the details for tests that haven't checked in as finished.
  xml.xpath('//xmlns:TestRunDetail').
    select{|c1| c1['StartTime'] == 'None' or c1['EndTime'] == 'None' }.
    map{|c2| Hash[c2.keys.map{|k| [k.to_sym, c2[k].to_s]}]}
end

def fixup_tests(xmlfile, xml, runid)
  rdict = Hash[list_of_results(xmlfile, xml).map{|r| [r.info, r]}]
  gauge_results = gauge_remainder(runid)
  puts 'Gauge shows %d unfinished tests' % gauge_results.length
  gauge_results.each {|g|
    r = rdict[g[:TestCommand]]
    if r.nil?
      puts 'No XML result found for Gauge %s' % g[:TestCommand]
    else
      if g[:StartTime] == 'None'
        args = {
          :DetailID  => g[:ID],
          :StartTime => r.start.utc.iso8601,
          :LogFilePath => r.loc }
        http_get(TEST_RUN_SVC + '/StartTest/', args)
      end
      if g[:EndTime] == 'None'
        args = {
          :DetailID  => g[:ID],
          :EndTime => r.finish.utc.iso8601,
          :Result => r.result }
        http_get(TEST_RUN_SVC + '/StopTest/', args)
      end
    end
  }
end

if __FILE__ == $0
  require 'trollop'
  opts = Trollop::options do
    opt(:xmlfile, 'XML results file', :type => :string, :required => true)
    opt(:runid, 'Test run identifier', :type => :int, :required => true)
  end

  contents = File.open(opts[:xmlfile]) {|f| f.read}
  xml = Nokogiri::XML('<wrapper>%s</wrapper>'%contents)

  fixup_tests(opts[:xmlfile], xml, opts[:runid])

  # If my XML file contains an end time, push that to Gauge.
  etime = xml.xpath('/wrapper/etime')
  if etime.length > 0
    http_get(TEST_RUN_SVC + '/StopRun/',
             :RunID => opts[:runid],
             :EndTime => Time.at(etime.last.text.to_i).utc.iso8601)
  end
end
