#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'testenv'
require 'vapi'
require 'collection'

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
collections = vapi.repository_list_xml.xpath('//vse-collection/@name').map{|a|
  Collection.new(a.value)}
collections.each{|collection|
  puts 'Messing with %s' % collection.name
  # We do this for the side effects. Ugh.
  collection.set_xml(collection.xml)
}
