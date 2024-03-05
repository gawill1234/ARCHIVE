#!/usr/bin/env ruby
# Test: bug-27160
#
# Test that search-collection-list-status-xml
# does what it's supposed to.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'nokogiri'

#variables
velocity            = TESTENV.velocity
user                = TESTENV.user
password            = TESTENV.password
N_COLLECTIONS       = 4
MAX_RETRIES         = 5
BASE_NAME           = "bug27160"
NAME_ATTR           = "name"
COLLECTION_TYPE     = "default-push"
LIVE_CRAWLER_STATUS = "//collection-crawler-service"
LIVE_INDEXER_STATUS = "//collection-indexer-service"

DEBUG  = false
RIGGED = false

#0. Init Velocity API Connection
vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new("bug-27160",
                               "Test that the new axl function search-collecti"\
                               "on-list-status behaves properly and retur"\
                               "ns correctly.")

#helper function
def count_valid_children(parent_node)
  count = 0
  parent_node.children.each do |node|
    if ((node.attr(NAME_ATTR) =~ /#{BASE_NAME}/) != nil)
      count += 1
    end
  end
  count
end

def expected_returns(vapi, test_results, live_c = 0, live_i = 0)
  i = 0
  while (i < MAX_RETRIES)
    status_xml = Nokogiri::XML(vapi.search_collection_list_status_xml.to_s)

    crawl_count = count_valid_children(status_xml.xpath(LIVE_CRAWLER_STATUS))
    index_count = count_valid_children(status_xml.xpath(LIVE_INDEXER_STATUS))

    correct_cnum = (crawl_count == live_c)
    correct_inum = (index_count == live_i)

    if not (correct_cnum and correct_inum)
      i += 1
      sleep(5)
    else
      break
    end
  end

  test_results.add(correct_cnum, "Encountered the correct number of running cr"\
                   "awler processes: #{live_c}", "After #{MAX_RETRIES} there a"\
                   "re still #{crawl_count} many crawler processes running, no"\
                   "t #{live_c}.")
  if (DEBUG)
    puts status_xml.xpath(LIVE_CRAWLER_STATUS).children.to_s
  end

  test_results.add(correct_inum, "Encountered the correct number of running in"\
                   "dexer processes: #{live_i}", "After #{MAX_RETRIES} there a"\
                   "re still #{index_count} many indexer processes running, no"\
                   "t #{index_count}.")
  if (DEBUG)
    puts status_xml.xpath(LIVE_INDEXER_STATUS).children.to_s
  end

  correct_cnum and correct_inum
end

#1. Create a slew of collections
collection = Array.new(N_COLLECTIONS)
(0..(N_COLLECTIONS-1)).each { |i|
  collection[i] = Collection.new("#{BASE_NAME}-#{i}", velocity, user, password)
  collection[i].delete
  collection[i].create(COLLECTION_TYPE)
}

#2. The status nodes should be empty right now
if (expected_returns(vapi, test_results))

  #3. Start the crawler/indexer on the n-many collections

  if (DEBUG)
    puts "N_COLLECTIONS: #{N_COLLECTIONS}"
  end

  (0..(N_COLLECTIONS-1)).each{|i|
    collection[i].crawler_start
    collection[i].indexer_start
  }

  num_c = N_COLLECTIONS
  num_i = N_COLLECTIONS
  if(expected_returns(vapi, test_results, num_c, num_i))
    #4. For 0 <= j < n, start the staging crawler/indexer on those collections
    if (RIGGED)
      staging_seed = 2
    else
      staging_seed = Random.rand(N_COLLECTIONS)
    end

    if (DEBUG)
      puts "staging_seed: #{staging_seed}"
    end

    if (staging_seed > 0)
      (0..(staging_seed-1)).each{|i|
        collection[i].crawler_start("staging")
      }
    end
    num_c += staging_seed
    num_i += staging_seed

    #5. Check that the status nodes have the correct values (n+j children)
    if (expected_returns(vapi, test_results, num_c, num_i))
      #6. shutdown 0 <= k <= i+j many processes (if k >j, kill live process
      #   k-n). For added variability, if k is even don't kill the indexer
      if (RIGGED)
        kill_seed = 3
      else
        kill_seed = Random.rand(N_COLLECTIONS+staging_seed)
      end

      if (DEBUG)
        puts "kill_seed: #{kill_seed}"
      end

      if (kill_seed > 0)
        (0..(kill_seed-1)).each{|i|
          idx = i
          subcollection="staging"
          if (i >= staging_seed)
            idx = i - staging_seed
            subcollection = nil
          end
          collection[idx].crawler_stop(subcollection)
          if ((kill_seed % 2) == 1)
            collection[idx].indexer_stop(subcollection)
          end
        }
      end

      num_c -= kill_seed
      if ((kill_seed % 2) == 1)
        num_i -= kill_seed
      end

      #7. Check for expected values in each status node
      if (expected_returns(vapi, test_results, num_c, num_i))
        #8. Shut down the remaining running processes
        (0..(N_COLLECTIONS-1)).each{|i|
          if (i <= staging_seed)
            collection[i].crawler_stop("staging")
            collection[i].indexer_stop("staging")
          end
          collection[i].crawler_stop
          collection[i].indexer_stop
        }
      end
    end
  end

  expected_returns(vapi, test_results)
end

#10. cleanup
(0..(N_COLLECTIONS-1)).each{ |i|
  collection[i].delete
}

test_results.cleanup_and_exit!
