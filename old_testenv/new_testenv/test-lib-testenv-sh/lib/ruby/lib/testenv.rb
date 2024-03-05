#!/usr/bin/env ruby

# Get a bunch of stuff from Vivisimo's standard testing environment.

require 'uri'

class Testenv
  # These are URI objects (normalized and frozen).
  attr_reader :base, :admin, :gronk, :query_meta, :velocity
  # These are strings.
  attr_reader :user, :password, :test_name, :query_service_port, :host
  # This is a symbol, should be one of :linux, :solaris, :windows
  attr_reader :os
  # These are booleans.
  attr_reader :delete_on_pass, :kill_all_services, :wipe_velocity, :windows

  def initialize
    @wipe_velocity = (ENV['VIVWIPE']=='True')
    @delete_on_pass = (ENV['VIVDELETE']=='all' || ENV['VIVDELETE']=='pass')
    @kill_all_services = (ENV['VIVKILLALL']=='True')
    @os = ENV['VIVTARGETOS'].to_sym
    @windows = (@os == :windows)
    exe = @windows ? '.exe' : ''
    base_string = "http://#{ENV['VIVHOST']||'localhost'}:" \
                  "#{ENV['VIVHTTPPORT']||'80'}/" \
                  "#{ENV['VIVVIRTUALDIR']||'vivisimo'}/"
    @base = URI.parse(base_string).normalize.freeze
    @admin =  @base.merge("cgi-bin/admin#{exe}").normalize.freeze
    @gronk = @base.merge("cgi-bin/gronk#{exe}").normalize.freeze
    @query_meta =  @base.merge("cgi-bin/query-meta#{exe}").normalize.freeze
    if ENV['VIVASPXDIR']
      @velocity =  @base.merge("asp/velocity.aspx").normalize.freeze
    else
      @velocity =  @base.merge("cgi-bin/velocity#{exe}").normalize.freeze
    end
    @user = (ENV['VIVUSER'] || 'test-all').freeze
    @password = (ENV['VIVPW'] || 'P@$$word#1?').freeze
    @test_name = File.basename($0).sub(/.tst$/, '')
    @query_service_port = ENV['VIVPORT'].freeze
    @host = ENV['VIVHOST'].freeze
  end
end

TESTENV = Testenv.new

if __FILE__ == $0
  p TESTENV
end
