#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'logger'
require 'misc'
require 'collection'


class FastCollection
  # attr_accessor :body
  attr_reader :body, :end, :name, :prepared, :start, :vapi

  def initialize(name)
    @body = nil
    @name = name
    @prepared = nil
    @vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password) 
  end

  def prepare(function, args=nil)
    @prepared = @vapi.prepare(function, {:collection => @name}.merge(args))
  end

  def invoke
    @start = Time.now
    begin
      @body = @vapi.invoke(@prepared).body
    rescue
      @body = nil
    end
    @end = Time.now
    @body
  end

end


class Hammer
  CONTAINER = '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?><__CONTAINER__ />'
  CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/%s">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here. Collection %s says move along.
    </crawl-data>
  </crawl-url>
</crawl-urls>'

  def initialize(count)
    format = "cb-hammer-%0#{Math.log10([1,count-1].max).to_i+1}i"
    @fc = (0..count-1).map {|i| FastCollection.new(format % i)}
    create_hammer_template
  end

  def create_hammer_template
    c = Collection.new('hammer-template')
    unless c.exists?
      c.create('default-broker-push')
      xml = c.xml
      set_option(xml, 'crawl-options', 'crawl-option', 'cache-size', 1)
      set_option(xml, 'vse-index', 'vse-index-option', 'cache-mb', 1)
      set_option(xml, 'vse-index', 'vse-index-option', 'cache-cleaner-mb', 1)
      c.set_xml(xml)
    end
    c.name
  end

  def create
    @fc.each {|c| c.prepare(:search_collection_create,
                            :based_on => 'hammer-template')}
    msg "Creating #{@fc.length} collections"
    threads = @fc.map {|x| Thread.new(x) {|c| c.invoke}}
    threads.each {|t| t.join}
    pass = 0
    again = @fc.select {|c| c.body != CONTAINER}
    while again.length > 0 do
      pass += 1
      again.each {|c| c.prepare(:search_collection_create,
                                :based_on => 'hammer-template')}
      msg "Creating #{again.length} collections (retry #{pass})"
      threads = again.map {|x| Thread.new(x) {|c| c.invoke}}
      threads.each {|t| t.join}
      again = again.select {|c| c.body != CONTAINER}
    end
    true
  end

  def enqueue
    msg "Enqueuing to #{@fc.length} collections"
    @fc.each {|c| c.prepare(:collection_broker_enqueue_xml,
                            :crawl_nodes => CRAWL_NODES % ([c.name]*2))}
    threads = @fc.map {|x| Thread.new(x) {|c| c.invoke}}
    failed = threads.select {|t| not (t.value =~ / n-success="1" /)}
    msg "Enqueue failures:" if failed.length > 0
    failed.each {|r| msg r}
    failed.length == 0
  end

  def search
    msg "Searching #{@fc.length} collections"
    @fc.each {|c| c.prepare(:collection_broker_search,
                            :query => c.name)}
    threads = @fc.map {|x| Thread.new(x) {|c| c.invoke}}
    threads.each {|t| t.join}
    found = @fc.select {|c| c.body =~ / total-results-with-duplicates="1" /}
    not_found = @fc.select {|c| c.body =~ / total-results-with-duplicates="0" /}
    failed = @fc.select {|c| not (c.body =~ /total-results-with-duplicates/)}
    msg "#{found.length} found, #{not_found.length} not found and #{failed.length} failed."
  end

  def remove
  end

  def report
    elapsed = @fc.map {|x| x.end}.max - @fc.map {|x| x.start}.min
    each = @fc.map {|x| x.end-x.start}
    msg "Total elapsed #{elapsed}. Fastest #{each.min}, Slowest #{each.max}"
  end

  def go
    msg create
    report
    msg enqueue
    report
    msg search
    report
  end
end

if __FILE__ == $0
  require 'config'
  bc = Broker_Config.new
  bc.vapi.log_level(Logger::ERROR)
  bc.set
  count = (ARGV[0] || 1000).to_i
  Hammer.new(count).go
end

