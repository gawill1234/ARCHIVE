#!/usr/bin/env ruby

require "misc"
require "collection"

results = TestResults.new('Test that the exec: protocol can list the current directory')
results.need_system_report = false

collection = Collection.new(TESTENV.test_name)
results.associate(collection)
collection.delete
collection.create

exec_url = <<EOF
<crawl-url synchronization="indexed" />
EOF
exec_url = Nokogiri::XML(exec_url).root

if TESTENV.os == :windows
  exec_url['url'] = 'exec:cmd /c "dir"'
else
  exec_url['url'] = 'exec:ls'
end

collection.enqueue_xml(exec_url)

search_results = collection.search('log.sqlt')
results.add_number_equals(1, search_results.xpath('//document').size, "document")

results.cleanup_and_exit!(true)
