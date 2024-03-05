#!/usr/bin/env ruby
require "misc"
require "collection"
require 'pmap'
require "rexml/document"

module REXML
  class Attribute
    alias :old_to_s :to_s

    def to_s
      old_to_s.gsub("\n", '&#10;')
    end
  end
end

N_BATCHES = 1000
N_PER_BATCH = 1000
N_RIGHTS = 1000
N_RIGHTS_PER = 100
N_BUILD_THREADS = 4
N_THREADS = 16

include REXML

results = TestResults.new('Test a race condition between enqueues',
                          'and collection-delete (bug 26786)')
collection = Collection.new(TESTENV.test_name)

collection.delete
collection.create

collection.set_index_options(:n_build_threads => N_BUILD_THREADS,
                             :cache_mb => 1000,
                             :build_flush => 1)

msg "Starting enqueues to #{collection.name}"

def do_one(i, name)
  msg "Preparing batch #{i}"
  xdoc = Document.new
  cus = Element.new('crawl-urls')
  cu = Element.new('crawl-url')
  cus.elements << cu

  cu.attributes['url'] = "#{i}"
  cu.attributes['synchronization'] = 'none'
  cu.attributes['status'] = 'complete'

  cd = Element.new('crawl-data')
  cu.elements << cd
  cd.attributes['encoding'] = 'xml'
  cd.attributes['content-type'] = 'application/vxml'
  #cd.attributes['size'] = 100

  for j in (1..N_PER_BATCH)
    doc = Element.new('document')
    cd.elements << doc
    doc.attributes['vse-key'] = "#{i}_#{j}"
    doc.attributes['vse-key-normalized'] = 'vse-key-normalized'

    rights="everyone"
    for k in (1..N_RIGHTS_PER)
      x = Math.sqrt(rand(N_RIGHTS*N_RIGHTS)).floor
      rights="#{rights}\nright-#{x}"
    end

    content = Element.new('content')
    doc.elements << content
    content.attributes['name'] = 'text'
    content.attributes['type'] = 'text'
    content.attributes['acl'] = rights
    content.text = "this is the same text in all documents.\na#{j} b#{j % 10} c#{j % 100}"
  end
  msg "Enqueueing batch #{i}"
  begin
    Collection.new(name).enqueue_xml(cus)
  rescue
    msg "Caught exception in the enqueue, no big deal"
  end
end

enqueuers = Thread.new() {
  (1..N_BATCHES).to_a.pmap(N_THREADS) { |i| do_one(i, collection.name) }
}

while enqueuers.status
  collection.delete
  begin
    collection.create
  rescue
    msg "Caught exception in the create, no big deal"
  end
end

msg enqueuers.value.inspect

collection.delete
results.cleanup_and_exit!
