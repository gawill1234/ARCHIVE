#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/viv-functions'

require "viv-function-wrapper"

def public_viv_parse_date(vapi)
  params = [
    {:name => 'date', :required => true},
    {:name => 'format'},
  ]

  vapi.create_public_api_wrapper('viv:parse-date', params)
end

def public_viv_parse_date_range(vapi)
  params = [
    {:name => 'date', :required => true},
    {:name => 'format'},
    {:name => 'timezone', :value => "'UTC'"},
    {:name => 'check-32bit', :value => 1},
  ]

  vapi.create_public_api_wrapper('viv:parse-date', params, :name => 'viv-parse-date-range')
end

def simple_time(t)
  begin
    Time.at(t).utc.strftime('%Y-%m-%d %H:%M:%S UTC')
  rescue
    "%d is out of Ruby Time range" % t
  end
end

def format_elapsed_time(t)
  sign = ''
  sign = '-' if t < 0
  ti = t.to_i.abs
  s = ti%60
  m = ti/60%60
  h = ti/3600%24
  d = ti/86400
  if d == 0
    '%s%i:%02i:%02i' % [sign, h, m, s]
  else
    '%s%id %i:%02i:%02i' % [sign, d, h, m, s]
  end
end

if __FILE__ == $0
  $LOAD_PATH << ENV['TEST_ROOT']+'/lib'
  require 'vapi'
  require 'testenv'
  vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  public_viv_parse_date(vapi)
  f = '%Y-%m-%d %H:%M:%S %z'
  ARGV.each {|arg|
    text = vapi.viv_parse_date(:date => arg).root.text
    t = text.to_f.to_i
    puts "#{arg} gives #{text} which is #{Time.at(t).strftime(f)}"
  }
end
