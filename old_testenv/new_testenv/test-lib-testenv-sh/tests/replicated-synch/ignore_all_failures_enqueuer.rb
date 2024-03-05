require 'stateful_enqueuer'
require 'forwardable'

# This enqueuer will also start the crawler for enqueues.
class IgnoreAllFailuresEnqueuer
  extend Forwardable

  def initialize(collection, enqueue_creator)
    state = StartCrawlerState.new(collection)
    @stateful_enqueuer = StatefulEnqueuer.new(collection.name, enqueue_creator, state)
  end

  def_delegators :@stateful_enqueuer, :enqueued_documents, :begin_enqueue, :stop_enqueue
end

class IgnoreAllFailuresEnqueuer::StartCrawlerState
  def initialize(collection)
    @collection = collection
  end

  def enqueue(data, document_id)
    begin
      @collection.enqueue_xml(data)
    rescue VapiException
      # Deliberately ignore these errors
    end
  end
end
