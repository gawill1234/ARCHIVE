#!/usr/bin/env ruby

require 'misc'
require 'collection'
require 'velocity/example_metadata'
require 'velocity/repository'

NEW_SOURCE_NAME = 'vse_form-default-sort'

def results_in_order?(order = :descending)
  @vapi = Vapi.new(velocity=TESTENV.velocity,
                   user=TESTENV.user,
                   password=TESTENV.password)
  results = @vapi.query_search(:sources => NEW_SOURCE_NAME, :num => 50)

  prev_year = nil

  list = results.xpath('//list').first
  list.xpath('document').each do |doc|
    year_xml = doc.xpath('content[@name="year"]').first

    # There is a document with no year content (index.html)
    next if !year_xml

    year_text = year_xml.content

    # There used to be a document with empty year content (index.html)
    next if year_text == ""

    year = year_text.to_i

    if prev_year
      if order == :ascending
        return false if prev_year > year
      elsif order == :descending
        return false if prev_year < year
      else
        raise "Invalid sort order"
      end
    end

    prev_year = year
  end

  return true
end

def fi_sort_string_to_hash(str)
  config = Hash.new
  str.split("\n").each do |line|
    parts = line.split("|", 2)
    config[parts[0]] = parts[1]
  end
  return config
end

def hash_to_fi_sort_string(hash)
  hash.map {|k, v| "#{k}|#{v}"}.join("\n")
end

results = TestResults.new('Uses example-metadata to ensure that a',
                          'source can have a default sort order')
results.need_system_report = false

collection = ExampleMetadata.new
collection.ensure_correctness

# Duplicate the source
repository = Repository.new
repository.delete('source', NEW_SOURCE_NAME)
repository.copy_node('source', collection.name, NEW_SOURCE_NAME)

# Ensure that without default we aren't magically in order
results.add(! results_in_order?,
            "Results are not already in order",
            "Results are already in order, test not valid")

# Let's reuse the date sorts already defined as our default sorts
source = repository.get('source', NEW_SOURCE_NAME)
sort_config = source.xpath('//with[@name="fi-sort"]').first
original_sort_config = fi_sort_string_to_hash(sort_config.content)

# Add a default sort method to the new source
default_sort_config = original_sort_config.clone
default_sort_config[''] = default_sort_config['year']

sort_config.content = hash_to_fi_sort_string(default_sort_config)
repository.update(source)
results.add(results_in_order?,
            "Results are in descending order",
            "Results are not in descending order")

# And the other direction
default_sort_config = original_sort_config.clone
default_sort_config[''] = default_sort_config['year-asc']

sort_config.content = hash_to_fi_sort_string(default_sort_config)
repository.update(source)
results.add(results_in_order?(:ascending),
            "Results are in ascending order",
            "Results are not in ascending order")

results.cleanup_and_exit!
