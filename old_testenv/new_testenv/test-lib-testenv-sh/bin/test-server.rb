#!/usr/bin/env ruby

require 'net/http'
require 'socket'

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
  raise '%s is already running!' % fields['command'] if
    running[fields['command']]
  fields['start'] = Time.now.to_i unless fields['start']
  running[fields['command']] = fields
end

XML_TEMPLATE = '<test>
<pid>1</pid>
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
  myrun = running[fields['command']]
  running.delete(fields['command'])
  raise 'Finish %s? It is not running!' % fields['command'] unless myrun
  fields['end'] = Time.now.to_i unless fields['end']
  # Mix in my new information
  myrun.merge!(fields)
  cap_result =  myrun['result'][0..0].upcase + myrun['result'][1..-1]
  # Write it to my XML log file (vtd style).
  open(xmllog, 'a') {|f| f.write(XML_TEMPLATE %
                                 [myrun['start'],
                                  myrun['name'],
                                  myrun['logpath'],
                                  myrun['srcpath'].split('+').join(' '),
                                  myrun['command'].split('+').join(' '),
                                  cap_result,
                                  myrun['end']])}
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
        write_response(conn, ([0] + test_list.delete_at(0)).inspect)
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

def start_end_run(xmllog, tag)
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
  require ENV['TEST_ROOT']+'/bin/parse-vtd'


  opts = Trollop::options do
    opt(:input, 'Input test list', :type => String)
    opt(:xmlout, 'XML output file', :default => 'results.xml')
    opt(:timeout, 'Default test timeout, in seconds (not implemented!)',
        :short => 'T', :default => 60*60*3)
    opt(:runid, 'Test run identifier', :type => :int)
  end

  Trollop::die :runid, 'required' unless opts[:runid]
  Trollop::die :input, 'must exist' unless
    opts[:input] and File.exist?(opts[:input])

  xmllog = opts[:xmlout]
  start_end_run(xmllog, :s)
  serve_tests(opts[:runid], vtd_contents(opts[:input]), xmllog)
  start_end_run(xmllog, :e)
end
