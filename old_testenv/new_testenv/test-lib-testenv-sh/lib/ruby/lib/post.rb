#!/usr/bin/env ruby

require 'cgi'
require 'fileutils'
require 'logger'
require 'net/http'
require 'singleton'
require 'uri'

# This is a really simple module that just gives us a clean way to do
# HTTP POST requests. The Ruby Net::HTTP stuff is just bizarre.

# Create a singleton logger, so multiple instances of Post will
# cleanly log to the same place.
class PostLogger
  include Singleton
  def initialize
    begin
      FileUtils.mkdir('tmp')
    rescue
      # Don't worry about failure; the directory probably already exists.
    end
    @logger = Logger.new('tmp/post.log')
    @logger.progname = $PROGRAM_NAME[/[^\/]*$/]
    @logger.level = Logger::DEBUG
    @logger.level = Logger::INFO if ENV['VIVNODETAIL'] == 'true'
  end
  def logger
    @logger
  end
end

class StartTime
  attr_reader :start_time
  include Singleton
  def initialize
    @start_time = Time.now.freeze
  end
end

# Instances of this class are *not* thread safe.
class Post
  attr_accessor :log
  # Give as much detail about ourselves as we reasonably can.
  USER_AGENT = "Ruby/#{::RUBY_VERSION}" \
    " Net::HTTP/#{Net::HTTP::HTTPVersion}-#{Net::HTTP::Revision}".freeze

  # Some defaults that the caller can override, including plain text
  # encoding, HTTP Keep-Alive and user agent.
  DEFAULT_HEADERS = {'Accept-Encoding'=>'identity',
                     'Connection'=>'Keep-Alive',
                     'Content-Type'=>'application/x-www-form-urlencoded',
                     'User-Agent'=>USER_AGENT}.freeze

  def initialize(uri, headers={})
    @log = PostLogger.instance.logger
    uri = URI.parse(uri) unless uri.is_a? URI
    @uri = uri.normalize.freeze
    @log.debug {@uri}
    @headers = DEFAULT_HEADERS.merge(headers).freeze
    @log.debug {@headers}
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.open_timeout = 60*60  # one hour
    @http.read_timeout = 24*60*60 # twenty-four hours (infinite doesn't work!)
    # Can I tie this into my existing logger?
    @http.set_debug_output($stderr) if $DEBUG
  end

  def post(data)
    elapsed = Time.now - StartTime.instance.start_time
    retries = 0
    begin
      # Do an explicit start (if needed) to support HTTP Keep-Alive.
      @http.start unless @http.started?
      simple_post(data, elapsed)
    rescue EOFError, Errno::EPIPE => e
      raise if retries > 0      # We only retry this once
      retries += 1
      # The Net::HTTP library does not notice when the server closes
      # a keep-alive socket. We work around that deficiency here.
      @log.debug {"RETRY #{elapsed} Post.post handing #{e.class}: #{e.message}\n"}
      @http.finish            # Explicitly close the old HTTP session
      retry
    end
  end

  def form_urlencode(data)
    return data if data.is_a? String
    return data.map {|key,value|
      [CGI.escape(key.to_s), CGI.escape(value.to_s)].join('=')
    }.join('&')
  end

  def simple_post(data, elapsed)
    encoded_data = form_urlencode(data)
    @log.info {"POST #{@uri}"}
    @log.debug {"POST #{elapsed} #{@uri}?#{encoded_data}"}
    response = @http.request_post(@uri.path, encoded_data, @headers)
    if response.is_a? Net::HTTPSuccess
      @log.info {"RESP #{@uri}"}
      @log.debug {"RESP #{elapsed} #{response.body}"}
      response
    else
      @log.error {response}
      response.error!
    end
  end
end

if __FILE__ == $0
  # If run as a main program,
  # use the command line arguments to create a POST request.
  if ARGV.length > 0
    p = Post.new(ARGV[0])
    resp = p.post(ARGV[1..-1].map {|x| x.split('=')})
    resp.each {|n,v| puts "#{n}:#{v}"}
    puts resp.body()
  else
    $stderr << "usage: post.rb URL [key=value ...]\n"
  end
end
