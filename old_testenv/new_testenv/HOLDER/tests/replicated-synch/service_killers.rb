require 'thread'

# Kills the specified service every so often
class CollectionServiceKiller
  MAXIMUM_TIME_BETWEEN_KILLS_S = 20

  def initialize(collection)
    @collection = collection
  end

  def start(&block)
    @indexer_kill_thread = Thread.new do
      while true
        sleep(rand(MAXIMUM_TIME_BETWEEN_KILLS_S))
        yield
      end
    end
  end

  def stop
    @indexer_kill_thread.exit
    @indexer_kill_thread.join
  end
end

# Kills the collection's indexer
class IndexerKiller < CollectionServiceKiller
  def start
    msg "Starting indexer kill thread."
    super do
      @collection.indexer_kill
    end
  end
end

# Kills the collection's crawler
class CrawlerKiller < CollectionServiceKiller
  def start
    msg "Starting crawler kill thread."
    super do
      @collection.crawler_kill
    end
  end
end
