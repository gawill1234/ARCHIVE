require "misc"
require "collection"
require "repl-synch-common"
require 'timeout'
require 'vapi'

def configure_remote_server_and_client(results)
  master_one = Collection.new("#{TESTENV.test_name}-master-one")
  master_one.delete
  master_one.create('default-push')

  master_two = Collection.new("#{TESTENV.test_name}-master-two")
  master_two.delete
  master_two.create('default-push')

  port_one = 12322
  port_two = 12322

  configure_remote_common(master_one)
  configure_remote_server(master_one, master_two.name, port_one)
  configure_remote_common(master_one)
  configure_remote_client(master_one, master_two.name, "127.0.0.1:#{port_two}")

  configure_remote_common(master_two)
  configure_remote_server(master_two, master_one.name, port_two)
  configure_remote_common(master_two)
  configure_remote_client(master_two, master_one.name, "127.0.0.1:#{port_one}")

  results.associate(master_one)
  results.associate(master_two)

  return master_one, master_two
end

def resume_and_wait_and_stop_crawlers(results, first, second)
  begin
    Timeout::timeout(30) do
      first.crawler_start
      second.crawler_start
    end
  rescue Timeout::Error
    results.add(false,"crawlers did not start in a timely manner") 
  end

  sleep(10)

  begin
    Timeout::timeout(30) do
      first.wait_until_idle
      second.wait_until_idle
    end
  rescue Timeout::Error
    results.add(false, "crawlers did not reach idle in a timely manner")
  end

  begin
    Timeout::timeout(30) do
      first.crawler_stop
      second.crawler_stop
    end
  rescue Timeout::Error
    results.add(false, "crawlers did not stop in a timely manner")    
  end
end
