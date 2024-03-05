#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'pmap'
require "misc"
require "collection"
require 'autocomplete'
require 'velocity/collection/restore'

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

results = TestResults.new('Basic test to profile autocomplete performance')
results.need_system_report = false

collection = Collection.restore_saved_collection('large-data-collection-autocomplete', '/testenv/saved-collections/autocomplete/large-data-collection-autocomplete')
results.associate(collection)

num = 10
max = {}
min = {}
total = {}

autocomplete = Autocomplete.new('large-data-collection')

options = {}
options[:dictionary] = 'large-data-collection'
options[:str] = '*'

vapi.autocomplete_suggest(options)

msg "Test single letter calls"
total_time = 0
num.times do |n|
  ('a'..'z').each do |l|
    options[:str] = l
    t1 = Time.now
    vapi.autocomplete_suggest(options)
    t2 = Time.now
    time = (t2 - t1).to_f

    total_time += time
    if max[l].nil? or time > max[l]
      max[l] = time
    end
    if min[l].nil? or time < min[l]
      min[l] = time
    end
    if total[l].nil?
      total[l] = time
    else
      total[l] += time
    end
  end
  msg "Average after #{n + 1}: #{total_time / ((n + 1) * 26 )}"
end
('a'..'z').each do |l|
  msg "#{l}: max:#{max[l]} min:#{min[l]} avg:#{total[l] / num}"
end

msg "Test two-letter combinations"
total_time = 0
num.times do |n|
  ('aa'..'zz').each do |l|
    options[:str] = l
    t1 = Time.now
    vapi.autocomplete_suggest(options)
    t2 = Time.now
    time = (t2 - t1).to_f

    total_time += time
    if max[l].nil? or time > max[l]
      max[l] = time
    end
    if min[l].nil? or time < min[l]
      min[l] = time
    end
    if total[l].nil?
      total[l] = time
    else
      total[l] += time
    end
  end
  msg "Average after #{n + 1}: #{total_time / ((n + 1) * 26 * 26 )}"
end
('aa'..'zz').each do |l|
  msg "#{l}: max:#{max[l]} min:#{min[l]} avg:#{total[l] / num}"
end

msg "Test single letter requests (10 threads in parallel)"
total_time = 0
max = {}
min = {}
total = {}

mutex = Mutex.new
num.times do
  ('a'..'z').to_a.peach(10) do |l|
    local_options = {}
    local_options[:dictionary] = 'large-data-collection'
    local_options[:str] = l
    threadvapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
    t1 = Time.now
    threadvapi.autocomplete_suggest(local_options)
    t2 = Time.now
    time = (t2 - t1).to_f

    mutex.synchronize do
      total_time += time
      if max[l].nil? or time > max[l]
        max[l] = time
      end
      if min[l].nil? or time < min[l]
        min[l] = time
      end
      if total[l].nil?
        total[l] = time
      else
        total[l] += time
      end
    end

  end
end

msg "Average: #{total_time / (num * 26)}"
('a'..'z').each do |l|
  msg "#{l}: #{max[l]} #{min[l]} #{total[l] / num}"
end

msg "Test single- and double-letter combinations (100 threads in parallel"
total_time = 0
max = {}
min = {}
total = {}
arr = ('a'..'z').to_a + ('aa'..'zz').to_a

arr.peach(100) do |l|
  local_options = {}
  local_options[:dictionary] = 'large-data-collection'
  local_options[:str] = l
  threadvapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  t1 = Time.now
  threadvapi.autocomplete_suggest(local_options)
  t2 = Time.now
  time = (t2 - t1).to_f

  mutex.synchronize do
    total_time += time
    if max[l].nil? or time > max[l]
      max[l] = time
    end
    if min[l].nil? or time < min[l]
      min[l] = time
    end
    if total[l].nil?
      total[l] = time
    else
      total[l] += time
    end
  end
end

msg "Average: #{total_time / (26 * 26)}"

msg "Test performance with filters"
[1,10,100,1000,2000,5000,10000].each do |filtersize|
  begin
    vapi.repository_delete(:element => 'filter', :name => 'ac-filter')
  rescue
  end

  doc = Nokogiri::XML(File.open("filter#{filtersize}.xml"))
  vapi.repository_add(:node => doc.root)
  options[:filter] = 'ac-filter'
  total_time = 0
  ('a'..'z').each do |l|
    options[:str] = l
    t1 = Time.now
    vapi.autocomplete_suggest(options)
    t2 = Time.now
    time = (t2 - t1).to_f

    total_time += time
  end
  ('aa'..'zz').each do |l|
    options[:str] = l
    t1 = Time.now
    vapi.autocomplete_suggest(options)
    t2 = Time.now
    time = (t2 - t1).to_f

    total_time += time
  end
  msg "#{filtersize} filter-terms: #{total_time / (26 + 26 * 26)} sec/request"
end
results.cleanup_and_exit!
