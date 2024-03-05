#!/usr/bin/env ruby

require 'misc'
require 'collection'

class Collection
  def prepend_converter(converter)
    conf = xml
    first_converter = conf.xpath('//converters/*').first
    first_converter.before(converter)
    set_xml(conf)
  end
end

results = TestResults.new('Creates a copy of example-metadata and adds ',
                          'an external converter process to ensure ',
                          'that values of the converter memory limit ',
                          'above 2GB do not wrap around')
results.need_system_report = false

c = Collection.new(TESTENV.test_name)
results.associate(c)

c.delete
c.create('example-metadata')
converter = <<EOF
<converter timing-name="Simple external command" type-in="text/html" type-out="text/html">
  <converter-execute>cat</converter-execute>
</converter>
EOF
c.prepend_converter(converter)

def test_amount(collection, results, mem)
  collection.clean
  collection.set_crawl_options({}, {:converter_max_memory => mem})
  collection.crawler_start
  collection.wait_until_idle
  results.add_equals(43, collection.index_n_docs, "Document count")
end

# While we really want to test for the 2GB boundary, the value is
# negative when the setting is between 2-4 GB, which is treated as no
# limit. So we test around 4GB as it shows the bad behavior clearly.
test_amount(c, results, 4096-1)
test_amount(c, results, 4096)
test_amount(c, results, 4096+1)

results.cleanup_and_exit!
