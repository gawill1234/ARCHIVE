#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker'

require 'many-enqueues-to-one'

results = TestResults.new('Pound collection-broker-enqueue-xml calls',
                          'against a non-existent collection.')

# Be careful to use a unique name each time.
# One relevant collection broker bug doesn't occur for a collection
# that has ever existed (even if the collection has been deleted).
collection = Collection.new("cb-nonexistant-#{Time.now.to_f}")

count = 1000
responses = many_enqueues_to_one(collection, count)

msg "Enqueues completed"
success = responses.count {|r| r  =~ / n-success="1" /}
results.add_number_equals(0, success, 'successes')

except  = responses.count {|r| r  =~ /<exception /}
results.add(except > 0.7*count,
            "exceptions: #{except} (should be close to #{count})")

msg "Attempting to create #{collection.name} ..."
begin
  collection.create
  results.add(true, 'create success')
rescue => ex
  results.add(false, 'create failed')
  puts ex
end

msg "Attempting to delete  #{collection.name} ..."
results.add(collection.delete_no_wait,
            "delete success",
            "delete failed")

results.cleanup_and_exit!
