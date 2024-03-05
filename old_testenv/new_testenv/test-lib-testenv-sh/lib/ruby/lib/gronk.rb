#!/usr/bin/env ruby

require 'testenv'
require 'cgi'
require 'net/http'
require 'rubygems'
require 'nokogiri'

class Gronk
  def initialize(url=TESTENV.gronk)
    @url = url
    @http = Net::HTTP.new(@url.host, @url.port)
    @http.open_timeout = 60*60  # one hour
    @http.read_timeout = 24*60*60 # twenty-four hours (infinite doesn't work!)
  end

  def form_urlencode(data)
    return data if data.is_a? String
    data.map {|key,value|
      [CGI.escape(key.to_s), CGI.escape(value.to_s)].join('=')
    }.join('&').split('+').join('%20') # 'gronk' doesn't handle "+" as a space.
  end

  def call(action, args=nil, post_data = nil)
    params = {'action'=>action}
    params = args.merge(params) unless args.nil?
    path_etc = "#{@url.path}?#{form_urlencode(params)}"
    if post_data
      response = @http.request_post(path_etc, post_data)
    else
      response = @http.request_get(path_etc)
    end
    if response.is_a? Net::HTTPSuccess
      response.body
    else
      response.error!
    end
  end

  def xml_call(action, args=nil, post_data = nil)
    Nokogiri::XML(call(action, args, post_data)).freeze
  end

  def installed_dir
    xml = xml_call('installed-dir')
    raise "installed-dir failure: #{xml}" if
      xml.xpath('/REMOP/OUTCOME').empty? or
      xml.xpath('/REMOP/OUTCOME').first.content != 'Success'
    xml.xpath('/REMOP/DIRECTORY').first.content
  end

  def get_pid_list(service, collection=nil)
    params = {'service' => service}
    params['collection'] = collection unless collection.nil?
    xml = xml_call('get-pid-list', params)
    raise "get-pid-list failure: #{xml}" if
      xml.xpath('/REMOP/OUTCOME').empty? or
      xml.xpath('/REMOP/OUTCOME').first.content != 'Success'
    xml.xpath('/REMOP/PIDLIST/PID').map {|e| e.content}
  end

  def kill_all_services
    # Kills most stuff. Specifically does not kill the query service.
    call('kill-all-services')
  end

  def restore_default
    # This will only work if everything on the target system is shutdown.
    xml = xml_call('restore-default')
    raise "restore-default failure #{xml}" if
      xml.xpath('/REMOP/OUTCOME').empty? or
      xml.xpath('/REMOP/OUTCOME').first.content != 'Success'
  end

  def restore_defaults
    restore_default
  end

  def file_size(path)
    xml = xml_call('file-size', :file => path)
    raise "file-size failure: #{xml}" if
      xml.xpath('/REMOP/SIZE').empty?
    xml.xpath('/REMOP/SIZE').first.content.to_i
  end

  def file_time(path, date='modified')
    xml = xml_call('file-time', :file => path, :date => date)
    raise "file-time failure: #{xml}" if
      xml.xpath('/REMOP/OUTCOME').empty? or
      xml.xpath('/REMOP/OUTCOME').first.content != 'Success' or
      xml.xpath('/REMOP/TIMESTAMP').empty?
    seconds = xml.xpath('/REMOP/TIMESTAMP').first.content.to_i
    # Only return a time if its well more than a week into the epoch.
    Time.at(seconds) if seconds > 1000000
  end

  def check_file_exists(path)
    xml = xml_call('check-file-exists', :file => path)
    raise "check-file-exists failure: #{xml}" if
      xml.xpath('/REMOP/OUTCOME').empty?
    xml.xpath('/REMOP/OUTCOME').first.content == 'Yes'
  end

  def rm_file(path)
    xml = xml_call('rm-file', :file => path)
    raise "rm-file failure: #{xml}" if
      xml.xpath('/REMOP/OUTCOME').empty?
    xml.xpath('/REMOP/OUTCOME').first.content == 'Success'
  end

  def get_file(path, binary=false)
    if binary
      call('get-file', :file => path, :type => 'binary')
    else
      xml = xml_call('get-file', :file => path)
      raise "get-file failure: #{xml}" if
        xml.xpath('/REMOP/OUTCOME').empty? or
        xml.xpath('/REMOP/OUTCOME').first.content != 'Success'
      xml.xpath('/REMOP/DATA').first.content
    end
  end

  def create_file(remotepath)
    # gronk CGI only checks the platform-specific separator
    if ENV['VIVTARGETOS'] == 'windows'
      remotepath.gsub!('/', '\\')
    end

    contents_io = StringIO.new('', 'w')
    yield(contents_io)

    #xml = xml_call('send-file', {:file => remotepath}, URI.encode(contents_io.string))
    xml = xml_call('send-file', {:file => remotepath}, contents_io.string)

    raise "send-file failure: #{xml}" if
      xml.xpath('/REMOP/OUTCOME').empty? or
      xml.xpath('/REMOP/OUTCOME').first.content != 'Success'
  end

  def send_file(localpath, remotepath)
    create_file(remotepath) { |x| x.write(IO.read(localpath)) }
  end

  def execute(command, type='binary')
    if type == 'binary'
      call('execute', :command => command, :type => type)
    else
      # May return malformed XML (which is why we default to "binary")
      xml = xml_call('execute', :command => command)
      raise "execute failure: #{xml}" if
        xml.xpath('/REMOP/OUTCOME').empty? or
        xml.xpath('/REMOP/OUTCOME').first.content != 'Success'
      xml.xpath('/REMOP/DATA').first.content
    end
  end
end

if __FILE__ == $0
  gronk = Gronk.new
  action = ARGV[0]
  if ARGV[1]
    arg_array = *ARGV[1..-1].map {|x| x.split('=', 2)}.flatten
    args = Hash[*arg_array]
  else
    args = nil
  end
  puts gronk.call(action, args)
end
