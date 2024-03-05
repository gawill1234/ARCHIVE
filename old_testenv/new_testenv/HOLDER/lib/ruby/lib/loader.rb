# I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = true

# Add the 'lib' and 'helpers' directories to the LOAD_PATH
lib_dir = File.expand_path(File.dirname(__FILE__) + "/../lib")
helper_dir = File.expand_path(File.dirname(__FILE__) + "/../helpers")
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
$LOAD_PATH.unshift(helper_dir) unless $LOAD_PATH.include?(helper_dir)

require "rubygems"

require "velocity/api"
require "velocity/query_service"
require "velocity/collection"
require "velocity/source"
require "velocity/query_meta"

require "simple_http"
gem "nokogiri", "~> 1.4"
require "nokogiri"

if defined? RSpec
  require 'spec_helper'
end

include Velocity

def cgi_paths
  virtual_dir = ENV['VIVVIRTUALDIR'] || 'vivisimo'
  exe = ENV['VIVTARGETOS'] == 'windows' ? '.exe' : ''
  @admin      = "/#{virtual_dir}/cgi-bin/admin#{exe}".freeze
  @admin_axl  = "/#{virtual_dir}/cgi-bin/admin-axl#{exe}".freeze
  @query_meta = "/#{virtual_dir}/cgi-bin/query-meta#{exe}".freeze
  @velocity   = "/#{virtual_dir}/cgi-bin/velocity#{exe}".freeze
end

# Get an instance of a convenience class for API calls.
def setup_vapi
  url = ENV['VIVURL'] || "http://" \
                         "#{ENV['VIVHOST'] || 'localhost'}:" \
                         "#{ENV['VIVHTTPPORT'] || '80'}/" \
                         "#{ENV['VIVVIRTUALDIR'] || 'vivisimo'}/" \
                         "cgi-bin/velocity" \
                         + ( ENV['VIVTARGETOS'] == 'windows' ? '.exe' : '' )
  user = ENV['VIVUSER'] || 'test-all'
  pswd = ENV['VIVPW'] || 'P@$$word#1?'

  @vapi = API.new(url, user, pswd)
  @application_url = url
  #xml = @vapi.call(ARGV[0], ARGV[1..-1].map {|x| x.split('=', 2)})
  #puts xml
end

def setup_query_meta
  @qm = Velocity::QueryMeta.new(URI.join(@application_url, @query_meta))
end

# Load up objects for use in irb
def connect_to_velocity
  cgi_paths
  setup_vapi
  setup_query_meta
end

# TODO: only call irb_setup when within irb
# connect_to_velocity
