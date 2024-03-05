#!/usr/bin/env ruby

require 'misc'
require 'collection'

good_tags = ["arena",
             "vertex",
             "parse-ref"]
             
must_have_tags = ["url",
                  "score",
                  "source",
                  "la-score",
                  "vse-key",
                  "rank",
                  "mwi-shingle",
                  "vse-base-score",
                  "vse",
                  "id",
                  "ct"]

bad_tags = ["redir-from",
            "redir-to",
            "status",
            "output-destination",
            "http-status",
            "input-at",
            "recorded-at",
            "at-datetime",
            "at",
            "filetime",
            "change-id",
            "input-purged",
            "size",
            "n-sub",
            "conversion-time",
            "converted-size",
            "speed",
            "hops",
            "exact",
            "exact-duplicate",
            "verbose",
            "uncrawled",
            "uncrawled-why",
            "crawled-locally",
            "priority",
            "input-priority",
            "i-ip",
            "forced-vse-key",
            "forced-vse-key-normalized",
            "synchronization",
            "enqueue-id",
            "originator",
            "remote-time",
            "remote-dependent",
            "remote-previous-collection",
            "remote-previous-counter",
            "remote-depend-collection",
            "remote-depend-counter",
            "remote-collection-id",
            "enqueued-offline",
            "enqueue-type",
            "deleted",
            "ignore-expires",
            "enqueued",
            "referrer-vertex",
            "remote-collection",
            "remote-counter",
            "remote-packet-id",
            "referree-url",
            "request-queue-redir",
            "prodder",
            "gatekeeper-action",
            "index-atomically",
            "gatekeeper-list",
            "gatekeeper-id",
            "offline-id",
            "offline-initialize",
            "input-on-resume",
            "switched-status",
            "from-input",
            "input-stub",
            "re-events",
            "remembered",
            "notify-id",
            "reply-id",
            "obey-no-follow",
            "normalized",
            "url-normalized",
            "wait-on-enqueued",
            "graph-id-high-water",
            "last-at",
            "indexed-n-docs",
            "indexed-n-contents",
            "indexed-n-bytes",
            "light-crawler",
            "remove-xml-data",
            "disguised-delete",
            "delete-enqueue-id",
            "delete-originator",
            "delete-index-atomically",
            "purge-pending",
            "only-input"]

def check_results(fn, urls)
  docs = urls.xpath('/query-results/list/document')

  for doc in docs do
    fn.call(doc)
  end
end

results = TestResults.new('Crawl example-metadata and make sure that no ',
                          'extraneous attributes made it into each document ',
                          'node.  Also make sure that a basic set of tags ',
                          'always there (i.e. score, id).')

c = Collection.new('example-metadata')
c.stop
c.clean

c.crawler_start
c.indexer_start

until c.crawler_idle? and c.indexer_idle?
  sleep 1
end
resp = c.search(nil, :debug => true)

fn = lambda {|doc|
  # Check that no bad attributes exist
  intersection = doc.keys & bad_tags
  if intersection.size > 0
    results.add(false, "Found bad tags: #{intersect} in doc #{doc['url']}.")
  end
}
check_results(fn, resp)

fn = lambda {|doc|
  # Check that the intersection is the same as the set of good tags.
  intersect = doc.keys & bad_tags

  # First remove bad tags
  no_bad_tags = doc.keys - intersect
  
  # Make sure that all the good tags are present
  must_have_inter = doc.keys & must_have_tags
  must_have_diff = must_have_inter - must_have_tags
  if must_have_diff.size > 0
    results.add(false, "Didn't find the tags #{must_have_diff} in doc #{doc['url']}.")
  end
}
check_results(fn, resp)

fn = lambda {|doc|
  # Check that there are no unknown tags.

  # First remove bad tags.
  inter_bad = doc.keys & bad_tags
  diff_bad = doc.keys - inter_bad

  # Remove must have tags
  inter_must_have = diff_bad & must_have_tags
  diff_must_have = diff_bad - inter_must_have

  # Remove good tags
  inter_good = diff_must_have & good_tags
  diff_good = diff_must_have - inter_good
  
  if diff_good.size > 0
    results.add(false,
                "Found #{diff_good} unknown tags in doc #{doc['url']}.")
  end
}
check_results(fn, resp)

results.cleanup_and_exit!
