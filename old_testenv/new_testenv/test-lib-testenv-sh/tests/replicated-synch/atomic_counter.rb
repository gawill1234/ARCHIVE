require 'monitor'

# A counter that can be safely used from multiple concurrent threads
class AtomicCounter
  # Creates a new counter starting at zero
  def initialize
    @lock = Monitor.new
    @value = 0
  end

  # Returns the value of the counter
  def value
    @lock.synchronize do
      @value
    end
  end

  # Increments the counter and returns the new value
  def increment!
    @lock.synchronize do
      @value += 1
    end
  end
end

# No better place to put unit tests that I am aware of...
if __FILE__ == $0
  begin
    counter = AtomicCounter.new
    raise "starts counting at 0" unless (counter.value == 0)
  end

  begin
    counter = AtomicCounter.new
    counter.increment!
    raise "can increment the value" unless (counter.value == 1)
  end

  begin
    counter = AtomicCounter.new
    res = counter.increment!
    raise "returns the value when incremented" unless (res == 1)
  end

  # This doesn't really test the concurrent nature of the object...
end
