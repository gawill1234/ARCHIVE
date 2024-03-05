#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'misc'
require 'collection'
require 'gronk'
require 'config'

def many_killed_cleanup(total, chunk)
  gronk = Gronk.new
  (chunk..total).step(chunk) do |so_far|
    threads = (0..chunk-1).map do |i|
      Thread.new(i) do |j|
        cur = Collection.new("many-killed-#{so_far+j}")
        cur.delete
      end
    end
    threads.each {|t| t.join}
  end
end


if __FILE__ == $0
  if ARGV.length == 0
    puts "usage: many-killed-cleanup.rb total chunk"
    puts
    puts "This script will delete collections in the same manner they were created in many-killed.rb."
    puts
    puts "Two command line arguments are required:"
    puts "\ttotal:\tThe total number of collections to create and kill."
    puts "\tchunk:\tThe number of collections to run simultaneously."
  else
    total = ARGV[0].to_i
    chunk = ARGV[1].to_i
    msg "Delete #{total} collections created in many-killed.rb in batches of #{chunk}"
    many_killed_cleanup(total, chunk)
  end
end
