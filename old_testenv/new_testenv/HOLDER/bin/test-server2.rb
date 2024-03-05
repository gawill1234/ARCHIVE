#!/usr/bin/env ruby

require 'cgi'
require 'net/http'
require 'open-uri'
require 'socket'
require 'time'
require 'thread'
require 'rubygems'
require 'nokogiri'

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
  puts retval
  retval
end

$gauge_queue = Queue.new

$gauge_thread = Thread.new{
  while (req = $gauge_queue.pop)
    begin
      http_get(*req)
    rescue => ex
      puts 'Gauge GET of %s failed.' % req.inspect
      puts ex
    end
  end
}

def async_http(url, params)
  $gauge_queue << [url,params]
end

def read_request(conn)
  # This is making the bold assumption that a POST request is well
  # formed. If content length is screwed up, we may hang--not the
  # nicest failure mode.
  request = conn.gets
  data = nil
  post = request['POST']
  while header = conn.gets and header != "\r\n"
    request += header
    content_length = $1.to_i if header.match(/Content-Length: ([0-9]+)/)
  end
  if header
    request += header
    data = conn.read(content_length) if post
  end
  [request, data]
end

def write_response(conn, data)
  conn.write("HTTP/1.1 200 OK\r\nContent-Length: %d\r\n\r\n%s" %
             [data.length, data])
end

def parse_args(request)
  f = request.index('?') + 1
  l = request.index(' HTTP/1.1')
  args = request[f...l]

  hash = {}
  args.split('&').each{|a|
    b = a.split('=')
    hash[b[0]] = b[1..-1].join('=')
  }
  hash
end

def test_start(running, fields)
  raise '%s is already running!' % fields['id'] if
    running[fields['id']]
  fields['start'] = Time.now.to_i unless fields['start']
  running[fields['id']] = fields
  # Tell Gauge we started it.
  async_http(TEST_RUN_SVC + '/StartTest/',
             :DetailID  => fields['id'],
             :StartTime => Time.at(fields['start']).utc.iso8601,
             :LogFilePath => fields['logpath'])
end

XML_TEMPLATE = '<test>
<pid>%d</pid>
<stime>%d</stime>
<name>%s</name>
<parent>/UNKNOWN/UNKNOWN</parent>
<loc>%s</loc>
<path>%s</path>
<info>%s</info>
<result>Test %s</result>
<etime>%d</etime>
</test>
'

def test_finish(xmllog, running, fields)
  myrun = running[fields['id']]
  running.delete(fields['id'])
  raise 'Finish %s? It is not running!' % fields['id'] unless myrun
  fields['end'] = Time.now.to_i unless fields['end']
  # Mix in my new information
  myrun.merge!(fields)
  # Write it to my XML log file (vtd style).
  open(xmllog, 'a') {|f| f.write(XML_TEMPLATE %
                                 [myrun['id'],
                                  myrun['start'],
                                  myrun['name'],
                                  myrun['logpath'],
                                  myrun['srcpath'].split('+').join(' '),
                                  myrun['command'].split('+').join(' '),
                                  myrun['result'].capitalize,
                                  myrun['end']])}
  # Tell Gauge the result.
  async_http(TEST_RUN_SVC + '/StopTest/',
             :DetailID  => fields['id'],
             :EndTime => Time.at(fields['end']).utc.iso8601,
             :Result => myrun['result'])
end

def serve_tests(runid, test_list, xmllog)
  puts 'Starting server with %d tests.' % test_list.length
  running = {}
  server = TCPServer.open(1000+runid)
  client_running = true
  while client_running or running.length > 0
    client_running = true
    conn = server.accept
    request, data = read_request(conn)
    if request['/test/next']
      if test_list.length > 0
        write_response(conn, test_list.delete_at(0).inspect)
      else
        write_response(conn, '')
        client_running = false  # Consider being done after any client shutdown.
        # FIXME: There is a potential race issue here with multiple clients.
      end
    elsif request['/test/start']
      write_response(conn, '')
      test_start(running, parse_args(request))
    elsif request['/test/finish']
      write_response(conn, '')
      test_finish(xmllog, running, parse_args(request))
    else
      puts 'Unknown request: %s' % request
    end
    conn.close
  end
end

def get_run(runid)
  xml = Nokogiri::XML(http_get(TEST_RUN_SVC + '/GetRun/', 'RunID' => runid))
  # Grab the details for tests that haven't checked in as "started".
  xml.root.children[1].children.select{|c1|
    c1['StartTime'].to_s == 'None' }.map{|c2|
    [c2['ID'], c2['TestName'], c2['TestCommand'], c2['TimeOut']]
  }
end

def start_end_run(xmllog, start_end)
  tag = start_end.to_s[0..0]
  start_end = '<%sdate>%s</%sdate>
<%stime>%d</%stime>
'
  now = Time.now
  open(xmllog, 'a') {|f| f.write(start_end % [tag,
                                              now.strftime('%Y-%m-%d'),
                                              tag,
                                              tag,
                                              now.to_i,
                                              tag])}
end

if __FILE__ == $0
  require 'rubygems'
  require 'trollop'

  opts = Trollop::options do
    opt(:xmlout, 'XML output file', :default => 'results.xml')
    opt(:runid, 'Test run identifier', :type => :int)
  end

  Trollop::die :runid, 'required' unless opts[:runid]

  xmllog = opts[:xmlout]
  start_end_run(xmllog, :start)
  serve_tests(opts[:runid], get_run(opts[:runid]), xmllog)
  start_end_run(xmllog, :end)
  async_http(TEST_RUN_SVC + '/StopRun/',
             :RunID  => opts[:runid])
  $gauge_queue << nil           # Tell our gauge request queue to finish.
  $gauge_queue << nil
  $gauge_thread.join            # Wait for our requests to Gauge to finish up.
end
