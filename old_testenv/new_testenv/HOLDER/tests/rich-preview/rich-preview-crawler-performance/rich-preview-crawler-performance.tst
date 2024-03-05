#!/usr/bin/env ruby

require 'misc'
require 'collection'

FILE_TYPES = %w(DOC DOCX PPT PPTX XLS XLSX PDF)

RICH_PREVIEW_TYPES = %w(
  word ms-ooxml-word
  powerpoint ms-ooxml-powerpoint
  excel ms-ooxml-excel
  pdf
)

results = TestResults.new('Compare the crawling performance with and without rich preview.')
results.need_system_report = false

class CrawlerPerformance
  attr_reader :crawl_time, :converted_size
  def initialize(crawl_time, converted_size)
    @crawl_time = crawl_time.to_f
    @converted_size = converted_size.to_f
  end
end

class PerformanceDelta < Struct.new(:before, :after)
  def times_slower
    after.crawl_time / before.crawl_time
  end

  def times_bigger
    after.converted_size / before.converted_size
  end
end

def create_collection(results)
  # create a collection
  collection = Collection.new(TESTENV.test_name)
  results.associate(collection)

  collection.delete
  collection.create('default')

  # setup the seed
  seeds = FILE_TYPES.map { |type| '/testfiles/test_data/document/' + type }.join("\n")
  collection.add_crawl_seed('vse-crawler-seed-smb',
                            :host => 'testbed5.test.vivisimo.com',
                            :username => 'gaw',
                            :password => 'mustang5',
                            :shares => seeds)

  collection
end

def measure_crawl_time(results)
  collection = create_collection(results)

  yield(collection) if block_given?

  collection.crawler_start
  collection.wait_until_idle

  status = collection.crawler_status
  CrawlerPerformance.new(status[:elapsed], status[:converted_size])
end

msg "Crawling without rich preview..."
without_rich_preview = measure_crawl_time(results)

msg "Crawling with rich preview..."
with_rich_preview = measure_crawl_time(results) do |collection|
  types = RICH_PREVIEW_TYPES.map { |type| 'application/' + type }.join(' ')
  collection.set_crawl_options({:rich_cache_types => types}, {})
end

msg "Crawl time without rich preview:     #{without_rich_preview.crawl_time}"
msg "Crawl time with rich preview:        #{with_rich_preview.crawl_time}"

msg "Converted size without rich preview: #{without_rich_preview.converted_size}"
msg "Converted size with rich preview:    #{with_rich_preview.converted_size}"

delta = PerformanceDelta.new(without_rich_preview, with_rich_preview)

results.add_includes(7..11, delta.times_slower, :what => 'slowdown factor')
results.add_includes(10.0..10.1, delta.times_bigger, :what => 'storage space factor')

results.cleanup_and_exit!(true)
