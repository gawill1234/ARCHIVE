#!/usr/bin/env ruby

require 'misc'
require 'collection'
require 'simple_crawling_server'

results = TestResults.new('Test that crawler ignores previous content-type encodings (bug 27285)')
results.need_system_report = false

collection = Collection.new(TESTENV.test_name)
collection.delete
collection.create('default')

server = SimpleCrawlingServer.new

collection.add_crawl_seed(:vse_crawler_seed_urls, :urls => server.local_url)
collection.crawler_start

# We need to respond to 2 requests
# robots.txt and the real page
# We can be lazy and let robots.txt be the same data
2.times do
  server.accept do |client|
    headers = ["HTTP/1.0 200 OK",
      "Server: Ruby test server",
      "Content-Type: text/html; charset=utf-8",
      "Content-Type: application/zip"]

    client.write(headers.join("\r\n"))
    client.write("\r\n\r\n")

    File.open('file.zip', 'rb') do |f|
      client.write f.read
    end
  end
end

server.shutdown

collection.wait_until_idle

# file.zip contains a single file with the content "hello world".  If
# the crawler tries to make the file conform to UTF-8 encoding, the
# file will be corrupted, the conversion will fail, and the text will
# not be searchable.
res = collection.search('hello world')
docs = res.xpath('//document')
results.add_number_equals(1, docs.size, 'document')

results.cleanup_and_exit!(true)
