require 'stateful_enqueuer'
require 'forwardable'

# This enqueuer can change modes - one mode allows failures and the
# other does not. This enqueuer will not start the crawler for
# enqueues.
class AllowsFailuresEnqueuer
  extend Forwardable

  def initialize(c, enqueue_creator, results)
    @expect_success = ExpectSuccessState.new(c, results)
    @allow_failure = AllowFailureState.new(c, results)

    @stateful_enqueuer = StatefulEnqueuer.new(c.name, enqueue_creator, @expect_success)
  end

  def_delegators :@stateful_enqueuer, :enqueued_documents, :begin_enqueue, :stop_enqueue

  def allow_failed_enqueues
    @stateful_enqueuer.change_state(@allow_failure)
  end

  def disallow_failed_enqueues
    @stateful_enqueuer.change_state(@expect_success)
  end
end

class AllowsFailuresEnqueuer::AllowFailureState
  def initialize(collection, results)
    @collection = collection
  end

  def enqueue(data, document_id)
    begin
      @collection.enqueue_xml(data, false)
    rescue VapiException
      # We expect this failure
    end
  end
end

class AllowsFailuresEnqueuer::ExpectSuccessState
  def initialize(collection, results)
    @collection = collection
    @results = results
  end

  def enqueue(data, document_id)
    begin
      @collection.enqueue_xml(data, false)
    rescue VapiException => e
      @results.add_failure("Unable to add document #{@document_id}: #{e}")
    end
  end
end
