#!/usr/bin/env ruby
require "misc"
require "collection"

num_slow = 500
num_fast = 100000

results = TestResults.new('Basic test vse-docs hash table')
collection = Collection.new(TESTENV.test_name)
results.associate(collection)
collection.delete
collection.create

def enqueue_key_full(collection, key_low, key_high, synch)
    xdoc = Nokogiri::XML::Document.new
    cus = xdoc.create_element('crawl-urls')
    for key in (key_low..key_high)
        cu = xdoc.create_element('crawl-url')
        cus << cu
        cu['url'] = String(key)
        cu['synchronization'] = synch
        cu['status'] = 'complete'
        cd = xdoc.create_element('crawl-data')
        cu << cd
        cd['content-type'] = 'text/plain'
        cd.content = String(key)
    end
    collection.enqueue_xml(cus)
end

def enqueue_key_indexed(collection, key)
    enqueue_key_full(collection, key, key, 'indexed')
end

def enqueue_key_none(collection, key)
    enqueue_key_full(collection, key, key, 'none')
end

def delete_key(collection, key)
    xdoc = Nokogiri::XML::Document.new
    cus = xdoc.create_element('crawl-urls')
    cd = xdoc.create_element('crawl-delete')
    cus << cd
    cd['url'] = String(key)
    cd['synchronization'] = 'indexed'
    cd['status'] = 'complete'
    collection.enqueue_xml(cus)
end

def check_key_count(results, collection, key, count)
    res = collection.search("DOCUMENT_KEY:#{key}")
    found = res.xpath('//document').size
    if count != found then
	results.add(false, "expected #{count} documents for #{key}, but got #{found} instead.")
    end
end

def check_key(results, collection, key)
    check_key_count(results, collection, key, 1)
end

def check_not_key(results, collection, key)
    check_key_count(results, collection, key, 0)
end

msg "enqueuing #{num_slow} keys with verification"

for key in (0..num_slow)
    check_not_key(results, collection, key)
    enqueue_key_indexed(collection, key)
    check_key(results, collection, key)
    if key == 401
        delete_key(collection, key)
	check_not_key(results, collection, key)
    end
end

enqueue_key_indexed(collection, 401)

msg "deleting half the keys"

(0..num_slow).step(2) do |key|
    check_key(results, collection, key)
    delete_key(collection, key)
    check_not_key(results, collection, key)
end

msg "adding another #{num_fast} keys without verification"

(num_slow+1..num_fast).step(500) do |key|
    enqueue_key_full(collection, key, key+500-1, "none")
end

msg "waiting for the collection to go idle"

collection.wait_until_idle

msg "spot checking all the keys"

(num_slow+1..num_fast).step(1234) do |key|
    check_key(results, collection, key)
end

results.cleanup_and_exit!(true)
