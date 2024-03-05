#!/usr/bin/ruby

require 'cgi'
require 'net/http'
require 'uri'

# This is a really simple module that just gives us a clean way to do
# HTTP POST requests. The Ruby Net::HTTP stuff is just bizarre.

class SimpleHTTP
  # Give as much detail about ourselves as we reasonably can.
  USER_AGENT = "Ruby/#{::RUBY_VERSION}" \
    " Net::HTTP/#{Net::HTTP::HTTPVersion}-#{Net::HTTP::Revision}".freeze

  # Some defaults that the caller can override, including plain text
  # encoding, HTTP Keep-Alive and user agent.
  DEFAULT_HEADERS = {'Accept-Encoding'=>'identity',
                     'Connection'=>'Keep-Alive',
                     'Content-Type'=>'application/x-www-form-urlencoded',
                     'User-Agent'=>USER_AGENT}.freeze

  def initialize(url, headers={})
    url = URI.parse(url) unless url.is_a? URI
    @uri = url.normalize.freeze
    @headers = DEFAULT_HEADERS.merge(headers).freeze
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.read_timeout = 24*60*60 # twenty-four hours (infinite doesn't work!)
    @http.set_debug_output($stderr) if $DEBUG
  end

  def post(data)
    retries = 0
    begin
      # Do an explicit start (if needed) to support HTTP Keep-Alive.
      @http.start unless @http.started?
      simple_post(data)
    rescue EOFError, Errno::EPIPE => e
      raise if retries > 0      # We only retry this once
      retries += 1
      # The Net::HTTP library does not notice when the server closes
      # a keep-alive socket. We work around that deficiency here.
      $stderr << "Post.post handing #{e.class}: #{e.message}\n" if $DEBUG
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

  def simple_post(data)
    # Log the raw request and raw response.
    encoded_data = form_urlencode(data)
    # log(:post, @uri.to_s + '?' + encoded_data)
    response = @http.request_post(@uri.path, encoded_data, @headers)
    if response.is_a? Net::HTTPSuccess
      # log(:data, response.body)
      response
    else
      # log(:error, response.headers)
      response.error!
    end
  end
end

if __FILE__ == $0
  # If run as a main program,
  # use the command line arguments to create a POST request.
  if ARGV.length > 0
    p = Post.new(ARGV[0])
    puts p.post(ARGV[1..-1].map {|x| x.split('=')}).body()
  else
    $stderr << 'usage: post.rb URL [key=value ...]\n'
  end
end
