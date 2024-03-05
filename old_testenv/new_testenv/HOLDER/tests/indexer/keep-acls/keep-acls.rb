#!/usr/bin/env ruby

require 'rexml/document'
require 'misc'
require 'gronk'

def canonical_dump(raw_dump)
  myre = /<.*>\)$/
  raw_dump.split('\n').map{|line|
    chunk = line[myre]
    if chunk
      # REXML will sort the attributes into alphabetical order :-)
      line.sub(myre, REXML::Document.new(chunk[0...-1]).to_s + ')')
    else
      line
    end
  }.join('\n')
end

def dump_index_file(collection)
  gronk = Gronk.new

  xml = collection.xml

  index_file_names = xml.xpath('//vse-index-file/@name')
  raise "Can not dump multiple index files, try a full merge" if index_file_names.size > 1
  raise "No index file exists" if index_file_names.size == 0

  live_dir, staging_dir = collection.crawl_path_list
  install_path = gronk.installed_dir

  if ENV['VIVTARGETOS'] == 'windows'
    # this makes me die inside
    install_path.gsub!('Program Files', 'progra~1')
  end

  exe = "#{install_path}/bin/dump"
  output_file = "#{install_path}/tmp/#{collection.name}-index-dump"

  if ENV['VIVTARGETOS'] == 'windows'
    exe += '.exe'
    null_device = 'nul:'
  else
    null_device = '/dev/null'
  end

  parts = [exe, null_device, "#{live_dir}/#{index_file_names}", '>', output_file]
  cmd = parts.join(' ')

  gronk.execute(cmd)
  result = gronk.get_file(output_file)
  canonical_dump(result)
end

def crawler_options
  options_str = <<EOF
<crawl-options>
  <curl-option name="default-allow">allow</curl-option>
</crawl-options>
EOF
  return Nokogiri::XML(options_str).root
end

def setup_collection(name, url_xml, index_options={})
  def_indexer_options = {:output_acls => true}
  index_options = def_indexer_options.merge(index_options)

  collection = Collection.new(name)
  collection.delete()
  collection.create('default')

  config_xml = collection.xml
  crawler_xml = config_xml.xpath('//crawler').first
  crawler_xml.add_child(url_xml)
  crawler_xml.add_child(crawler_options)
  collection.set_xml(config_xml)

  collection.set_index_options(index_options)

  collection.crawler_start()
  collection.wait_until_idle()
  collection.stop()

  return collection
end

def ensure_index_files_are_equal(collection, results)
  index_dump = dump_index_file(collection)

  file = File.open('test_dump', 'w')
  file.write(index_dump)
  file.close()

  files_are_same = FileUtils.compare_file('correct_dump', 'test_dump')
  results.add(files_are_same, "Index dump files are identical", "Index dump files are not identical")
end

def ensure_acl_attributes_are_equal(collection, expected_acls, results)
  res = collection.search(nil, :output_summary => false)

  contents = res.xpath('//content')
  results.add_number_equals(expected_acls.size, contents.size, 'content node')

  expected_acls.each_with_index do |expected_acl, i|
    actual_acl = contents[i]['acl']
    results.add_equals(expected_acl, actual_acl, 'acl attribute')
  end
end

def ensure_acl_entries_are_saved_and_searchable(collection, url_xml, results)
  expected_acls = url_xml.xpath('//content').map {|x| x['acl']}

  ensure_index_files_are_equal(collection, results)
  ensure_acl_attributes_are_equal(collection, expected_acls, results)
end


if __FILE__ == $0
  ARGV.each{|filename|
    raw = open(filename) {|f| f.read}
    clean = canonical_dump(raw)
    open(filename, 'w') {|f| f.write(clean)}
  }
end
