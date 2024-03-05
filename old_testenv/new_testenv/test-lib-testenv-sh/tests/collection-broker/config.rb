#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'testenv'
require 'vapi'

# The collection broker can take nearly forever to shutdown.
COLLECTION_BROKER_SHUTDOWN_WAIT_MINUTES = 15

class Broker_Config
  attr_reader :vapi

  def initialize(velocity=TESTENV.velocity,
                 user=TESTENV.user,
                 password=TESTENV.password)
    @vapi = Vapi.new(velocity, user, password)
    @log_dir = nil
  end

  def default_log_dir
    # If we don't have it, figure it out.
    if @log_dir.nil?
      require 'misc'
      @log_dir = fix_path(Gronk.new.installed_dir +
                          '/data/collection-broker-log')
    end
    @log_dir
  end

  def empty_config
    Nokogiri::XML('<collection-broker-configuration name="global" />')
  end

  def cb_status
    begin
      @vapi.collection_broker_status.root['status'].to_s
    rescue VapiException => ex
      exception = Nokogiri::XML(ex.message)
      raise unless exception.root['name'] == 'collection-broker-terminating'
      'terminating'
    end
  end

  def collection_broker_down
    stop_request = Time.now
    @vapi.collection_broker_stop
    while cb_status != 'stopped' and
        Time.now-stop_request < 60*COLLECTION_BROKER_SHUTDOWN_WAIT_MINUTES
      sleep 1
    end
    puts "Waited %.0f seconds for the collection broker to shutdown." %
      (Time.now-stop_request)
  end

  def collection_broker_restart
    collection_broker_down
    @vapi.collection_broker_start
  end

  def get
    # Return a hash of collection broker parameters :name => :value
    d = {}
    @vapi.collection_broker_get.root.children.each do |item|
      d[item.name] = item.text if item.element?
    end
    d
  end

  def to_s
    get.map {|name,value| "#{name}=#{value}"}.join(', ')
  end

  def set(args=nil)
    if args
      new = Hash[*args.map {|key,value| [key, value.to_s]}.flatten]
      # This is evil.
      # We magically make sure log-directory is set if log-level is set.
      new['log-directory'] = default_log_dir if
        new['log-level'] and new['log-directory'].nil?
    else
      new = {}
    end
    if new == get
      puts 'No configuration change (not restarting the collection broker).'
    else
      xml = empty_config
      new.each do |name, value|
        xml.root.add_child(Nokogiri::XML::Node.new(name, xml)).content = value
      end
      @vapi.collection_broker_set(:configuration => xml)
      puts 'Configuration changed. Restarting the collection broker ...'
      collection_broker_restart
    end
    self
  end
end

if __FILE__ == $0
  if ARGV.length == 0
    puts "usage: config.rb [--reset] [config-name-1[=value]] [config-name-n[=value] ...]"
    puts "\t If no value is given (with =value), the config item is removed."
    puts "\t --reset means clear all settings and only set what's specified."
  else
    bc = Broker_Config.new
    puts "Before: #{bc}"
    # Treat the command line as name=value: put it into a hash
    want = Hash[*ARGV.map do |x|
                  if x.index('=')
                    x.split('=', 2)
                  else
                    [x, nil]
                  end
                end.flatten]
    # No "--reset" on the command line?
    if not ARGV.include? '--reset'
      want = bc.get.merge(want) # Merge the new settings into existing.
    end
    # Remove any entries with an empty values (e.g. "--reset")
    want.delete_if {|name, value| not value}
    # Do the collection-broker-set
    bc.set want
    puts "After: #{bc}"
  end
end
