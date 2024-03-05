require 'thread'
require 'atomic_counter'
require 'monitor'

# This class is intended to be used concurrently from multiple threads
class StatefulEnqueuer
  def initialize(collection_name, enqueue_creator, initial_state)
    @collection_name = collection_name
    @enqueue_creator = enqueue_creator
    @enqueued_documents = AtomicCounter.new

    # protected by @lock
    @enqueue_state = initial_state

    @lock = Monitor.new
  end

  def enqueued_documents
    @enqueued_documents.value
  end

  # Change the enqueuing state. The state change will take effect on
  # the next enqueue.
  def change_state(new_state)
    @lock.synchronize do
      @enqueue_state = new_state
    end
  end

  def begin_enqueue(total=50000)
    msg "Starting enqueue to #{@collection_name}."

    @thread = Thread.new do
      while @enqueued_documents.value < total
        value = @enqueued_documents.increment!
        enqueued_data = @enqueue_creator.create_enqueue_data(@collection_name, value)
        @lock.synchronize do
          @enqueue_state.enqueue(enqueued_data, value)
        end
      end
    end
  end

  def stop_enqueue
    msg "Stopping enqueue to #{@collection_name}."
    @thread.exit
    @thread.join
  end
end

