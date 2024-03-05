#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'

class Broker_Config_Defaults

  CB_Config_Defaults = {
    'always-allow-one-collection' => 'true',
    'check-memory-usage-time' => '3.0',
    'check-online-are-responsive-time' => '120',
    'check-online-are-responsive-timeout-time' => '120',
    'check-online-time' => '5.0',
    'crawler-minimum' => '367001600',
    'crawler-overhead' => '262144000',
    'current-status-time' => '10.0',
    'find-new-collections-time' => '30.0',
    'indexer-minimum' => '367001600',
    'indexer-overhead' => '262144000',
    'live-ping-probability' => '0.1',
    'maximum-collections' => '-1',
    'memory-granularity' => '10485760',
    'minimum-free-memory' => '262144000',
    'overcommit-factor' => '0.75',
    'persistent-save-time' => '10.0',
    'prefer-requests' => 'search',
    'start-offline-time' => '15.0',
    'time-granularity' => '30'
  }.freeze

  def initialize(velocity=TESTENV.velocity,
                 user=TESTENV.user,
                 password=TESTENV.password)
    @vapi = Vapi.new(velocity, user, password)
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

  def empty_config
    Nokogiri::XML('<collection-broker-configuration name="global" />')
  end

  def collection_broker_restart
    @vapi.collection_broker_stop
    waited = 0
    while waited < 120 and cb_status == 'running' do
      sleep 1
      waited += 1
    end
    puts "Waited #{waited} seconds for the collection broker to shutdown."
    @vapi.collection_broker_start
  end

  def sub_test
    ENV['REMOVECOLLECTIONS'] = 'true'
    system '$TEST_ROOT/tests/collection-broker/small-sequential-retry-search.py 9'
  end

  def try_one(name, value)
    config = empty_config
    config.root.add_child(Nokogiri::XML::Node.new(name, config)).content = value
    @vapi.collection_broker_set(:configuration => config)
    collection_broker_restart
    puts "Trying #{name}=#{value}"
    status = sub_test
    if status
      puts "Step passed for #{name}"
    else
      puts "Step FAILED for #{name}"
    end
    status
  end

  def try_one_default(name)
    try_one(name, CB_Config_Defaults[name])
  end

  def try_every_default
    results = {}
    CB_Config_Defaults.each do |name, value|
      results[name] = try_one_default(name)
    end
    results.each do |n,p|
      if p
        r = 'passed'
      else
        r = 'FAILED'
      end
      puts "Setting #{n} #{r}."
    end
  end
end

if __FILE__ == $0
  if ARGV.length == 0
    status = Broker_Config_Defaults.new.try_every_default
  else
    status = true
    ARGV.each {|name| status &&= try_one_default(name)}
  end
  if status
    puts 'Test Passed.'
  else
    puts 'Test FAILED.'
    # FIXME need to give a non-zero status return
  end
end
