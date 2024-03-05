# This ensures that multiple threads can update test results
# concurrently without worrying that the results will be corrupted
class ThreadSafeTestResults
  def initialize(results)
    @delegate = results
    @lock = Monitor.new
  end

  # This is a very heavy-handed locking policy, but the test result
  # object isn't expected to have a high-level of contention.
  def method_missing(sym, *args, &block)
    @lock.synchronize do
      @delegate.send(sym, *args, &block)
    end
  end

  def responds_to?(sym)
    @lock.synchronize do
      @delegate.responds_to?(sym)
    end
  end
end
