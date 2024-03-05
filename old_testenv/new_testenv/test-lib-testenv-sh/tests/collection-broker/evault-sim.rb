#!/usr/bin/env ruby

require 'cgi'
require 'fileutils'
require 'rubygems'
require 'nokogiri'

class EVaultSim
  attr_accessor :cleanup
  attr_reader :settings
  DefaultXML = "#{ENV['TEST_ROOT']}/tests/collection-broker/evault-sim.xml"
  Identity_File = "#{ENV['TEST_ROOT']}/files/ssh_private_key"
  Runner_Host = ENV['EVaultSimRunner'] || 'testbed8.test.vivisimo.com'
  Win_Home = 'C:\\Documents and Settings\\Administrator\\'

  def initialize(settingsXml=File.new(DefaultXML))
    @cleanup = true
    @run_number = 0
    @my_name =  "evault-sim-#{$$}"
    evault_home = 'C:\\EVaultSim\\'
    File.chmod(0600, Identity_File)
    File.open('ssh_config', 'w') do |f|
      f.write "IdentityFile #{Identity_File}\nStrictHostKeyChecking no\n"
    end
    @run = ['ssh', '-F', 'ssh_config', "administrator@#{Runner_Host}",
            'cmd', '/c', 'cd', Win_Home, '&',
            "#{evault_home}EVaultSim.exe"].freeze
    @settings = Nokogiri::XML(settingsXml)
    settingsXml.close if settingsXml.is_a? File

    # Pluck out the VIV* environment and set the url related stuff
    empty, virtual_dir, path, script_name  = TESTENV.velocity.path.split('/')

    set('/EVaultSim/protocol', TESTENV.velocity.scheme)
    set('/EVaultSim/server-name', TESTENV.velocity.host)
    set('/EVaultSim/port', TESTENV.velocity.port)
    set('/EVaultSim/virtual-dir', virtual_dir)
    set('/EVaultSim/path', path)
    set('/EVaultSim/script-name', script_name)
    set('/EVaultSim/aspx', false)
    set('/EVaultSim/cgi-params', "v.app=api-soap" +
        "&v.username=#{CGI.escape(TESTENV.user)}" +
        "&v.password=#{CGI.escape(TESTENV.password)}")

    set('/EVaultSim/is-windows', TESTENV.windows)
    set('/EVaultSim/persistent-dictionary-file', "#{@my_name}-dict.dat")
    set('/EVaultSim/persistent-collections-file', "#{@my_name}-collections.dat")
  end

  def set(xpath, value)
    # A generic "set"
    elem = @settings.xpath(xpath)
    if elem.empty?
      raise "Element not found for XPath of: #{xpath}"
    else
      elem.first.content = value.to_s
      elem.first
    end
  end

  def do_setup
    @run_number += 1
    # Come up with a reasonably unique name
    @run_name = "#{@my_name}-#{@run_number}"
    File.open("/tmp/#{@run_name}.xml", 'w') {|f| f.write(@settings.to_s)}
    File.open("/tmp/#{@run_name}.put", 'w') {|f| f.write("put /tmp/#{@run_name}.xml")}
    File.open("/tmp/#{@run_name}.rm",  'w') {|f| f.write("rm #{@run_name}.xml")}
    system "sftp -F ssh_config -b /tmp/#{@run_name}.put administrator@#{Runner_Host}"
  end

  def just_run
    system(*(@run + ['"' + "#{@run_name}.xml" + '"']))
  end

  def do_cleanup
      system "sftp -F ssh_config -b /tmp/#{@run_name}.rm administrator@#{Runner_Host}"
      FileUtils.rm(Dir.glob("/tmp/#{@run_name}.*"), :force => true)
  end

  def run
    status = do_setup
    status = just_run if status
    # If we had a successful run, cleanup files: both remote and local.
    do_cleanup if @cleanup and status
    status
  end
end
