#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'
require "misc"
require "collection"
require 'autocomplete'
require 'dictionary_collections'
require 'dictionary'

results = TestResults.new('Autocomplete should ignore apostrophe with possessives')
results.need_system_report = false

dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
output_collection.delete

autocomplete = Autocomplete.new(TESTENV.test_name)

class AutocompleteDictionary
  def setup_and_build(results)
    delete
    create

    yield self

    build
    wait_until_finished(results)
  end
end

collection = DictionaryCollection.new(TESTENV.test_name)
results.associate(collection)
collection.delete
collection.create

PHRASES = ["women's health",  "parkinson's disease"]
collection.enqueue_phrases(PHRASES)

msg "Creating autocomplete dictionary with 'depluralize' stemming on output"
dict.setup_and_build(results) do |dict|
  dict.set_autocomplete_output_vis_node('<vse-index-stream stem="depluralize" />')
  dict.add_collection_input(collection.name, :contents => 'title')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

[false, true].each do |bag_of_words|
  msg "When 'bag_of_words' param is #{bag_of_words}"

  correct_suggestions = ["women's health"]
  ["wome","women", "women'","women's", "women's ", "women's h", "womens", "womens "].each do |query|
    msg "  #{query}"
    autocomplete.ensure_correct_suggestions(query, {:bag_of_words => bag_of_words}, results, correct_suggestions)
  end

  correct_suggestions = ["parkinson's disease"]
  ["parkinso", "parkinson", "parkinson'", "parkinson's", "parkinson's ", "parkinson's d", "parkinsons", "parkinsons "].each do |query|
    msg "  #{query}"
    autocomplete.ensure_correct_suggestions(query, {:bag_of_words => bag_of_words}, results, correct_suggestions)
  end
end

msg "Extra cases when bag_of_words is 'true'"

["womens h", "women h"].each do |query|
  correct_suggestions = ["women's health"]
  msg "  #{query}"
  autocomplete.ensure_correct_suggestions(query, {:bag_of_words => true}, results, correct_suggestions)
end

["parkinsons d"].each do |query|
  correct_suggestions = ["parkinson's disease"]
  msg "  #{query}"
  autocomplete.ensure_correct_suggestions(query, {:bag_of_words => true}, results, correct_suggestions)
end

results.cleanup_and_exit!(true)
