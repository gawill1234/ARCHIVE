#!/usr/bin/env ruby
#
# Test: Bug-15336
#
# Test that we properly throw an exception when we try to
# restart an indexer or crawler that isn't actually running.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'nokogiri'

#Constants
velocity        = TESTENV.velocity
user            = TESTENV.user
password        = TESTENV.password
testname        = TESTENV.test_name
XPATH_CRAWLER   = "/vse-collection/vse-config/crawler"
CRAWL_OPTIONS   = <<END
<crawl-options>
  <crawl-option name="idle-running-time">120</crawl-option>
</crawl-options>
END

#Helper Functions
def stop_crawler_timeout(time = 20)
  i = 0
  time.times do
    if @collection.crawler_stopped?
      break
    end
    @collection.crawler_stop
    i += 1
    sleep(1)
  end
  @test_results.add(i < time,
                    "The crawler stopped in less than #{time} seconds.",
                    "The crawler failed to stop within #{time} seconds.")
end

def stop_indexer_timeout(time = 20)
  i = 0
  time.times do
    if @collection.indexer_stopped?
      break
    end
    @collection.indexer_stop
    i += 1
    sleep(1)
  end
  @test_results.add(i < time,
                    "The indexer stopped in less than #{time} seconds.",
                    "The indexer failed to stop within #{time} seconds.")
end

def stop_collection_timeout(time = 20)
  stop_crawler_timeout(time)
  stop_indexer_timeout(time)
end

def assert_crawler_restart_success
  begin
    @collection.crawler_restart
  rescue => e
    @test_results.add_failure("Caught an exception trying to restart a running"\
                              " crawler.\n#{e.to_s}")
  else
    @test_results.add_success("Correctly restarted a running crawler.")
  end
end

def assert_crawler_restart_failure
  begin
    @collection.crawler_restart
  rescue => e
    @test_results.add_success("Caught an expected exception when restarting a "\
                              "stopped crawler.")
  else
    @test_results.add_failure("Restarted a non-running crawler.")
  end
end

def assert_indexer_restart_success
  begin
    @collection.indexer_restart
  rescue => e
    @test_results.add_failure("Caught an exception trying to restart a running"\
                              " indexer.\n#{e.to_s}")
  else
    @test_results.add_success("Correctly restarted a running indexer.")
  end
end

def assert_indexer_restart_failure

  begin
    @collection.indexer_restart
  rescue => e
    @test_results.add_success("Caught an expected exception when restarting a "\
                              "stopped indexer.")
  else
    @test_results.add_failure("Restarted a non-running indexer.")
  end
end

def assert_restart_success
  assert_crawler_restart_success
  assert_indexer_restart_success
end
def assert_restart_failure
  assert_crawler_restart_failure
  assert_indexer_restart_failure
end

#Test
##0. Initialize Test & Collection
@vapi = Vapi.new(velocity, user, password)
@test_results = TestResults.new(testname,
                               "Test that we properly throw an exception when "\
                               "we try to restart a crawler or indexer that is"\
                               "n't actually running.")
@test_results.need_system_report = false

@collection = Collection.new(testname, velocity, user, password)
@test_results.associate(@collection)
@collection.delete
@collection.create("default")

xml = @collection.xml
xml.xpath(XPATH_CRAWLER).children.before(CRAWL_OPTIONS)
@collection.set_xml(xml)

##1. Trying to restart the [crawler|indexer] right now should fail
assert_restart_failure

##2. Trying to restart running [crawler|indexer] should succeed
@collection.crawler_start
@collection.wait_until_idle
assert_restart_success

##3. If we stop a process, restart should fail
@collection.wait_until_idle

stop_crawler_timeout

assert_crawler_restart_failure
assert_indexer_restart_success

stop_collection_timeout
assert_indexer_restart_failure

# Cleanup
@test_results.cleanup_and_exit!
