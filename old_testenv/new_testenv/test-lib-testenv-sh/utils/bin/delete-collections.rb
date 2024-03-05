#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'testenv'
require 'collection'
require 'pmap'

def all_collections
  vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  vapi.repository_list_xml.xpath('/vce/vse-collection').map{|e| e['name'].to_s}
end

def delete_collections_matching(wildcard)
  matching_collections = all_collections.select {|a| a =~ /#{wildcard}/}
  if matching_collections.empty?
    puts "No collections found matching #{wildcard}"
  else
    puts "Deleting #{matching_collections.length} collections matching #{wildcard} ..."
    matching_collections.peach {|name| Collection.new(name).delete}
  end
end

if __FILE__ == $0
  if ARGV.length == 0
    puts 'usage: delete-collections.rb wildcard [wildcard ...]'
  else
    ARGV.each {|wildcard| delete_collections_matching(wildcard)}
  end
end
