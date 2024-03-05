#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'dictionary_collections'
require 'dictionary'

results = TestResults.new('Basic test to see if dictionary autocomplete supports non-english languages')
results.need_system_report = false

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)

input_collection = DictionaryPolyglot.new
results.associate(input_collection)
input_collection.setup

dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)

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

dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'phrase')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['école normale supérieure']
msg("Test that accented suggestions are returned when request doesn't have accent")
autocomplete.ensure_correct_counts('Ec', nil, results, [1])
autocomplete.ensure_correct_suggestions('Ec', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('ec', nil, results, [1])
autocomplete.ensure_correct_suggestions('ec', nil, results, correct_suggestions)

msg("Test that accented suggestions are returned when request has accent")
autocomplete.ensure_correct_counts('Éc', nil, results, [1])
autocomplete.ensure_correct_suggestions('Éc', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('éc', nil, results, [1])
autocomplete.ensure_correct_suggestions('éc', nil, results, correct_suggestions)

correct_suggestions = ['dansen går till hårgalåten']
msg("Test that accented suggestions are returned when request doesn't have accent")
autocomplete.ensure_correct_counts('Ha', nil, results, [1])
autocomplete.ensure_correct_suggestions('Ha', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('ha', nil, results, [1])
autocomplete.ensure_correct_suggestions('ha', nil, results, correct_suggestions)

msg("Test that accented suggestions are returned when request has accent")
autocomplete.ensure_correct_counts('Hå', nil, results, [1])
autocomplete.ensure_correct_suggestions('Hå', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('hå', nil, results, [1])
autocomplete.ensure_correct_suggestions('hå', nil, results, correct_suggestions)

correct_suggestions = ['bím i gcónai i do theannta']
msg("Test that accented suggestions are returned when request doesn't have accent")
autocomplete.ensure_correct_counts('Bi', nil, results, [1])
autocomplete.ensure_correct_suggestions('Bi', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('bi', nil, results, [1])
autocomplete.ensure_correct_suggestions('bi', nil, results, correct_suggestions)

msg("Test that accented suggestions are returned when request has accent")
autocomplete.ensure_correct_counts('Bí', nil, results, [1])
autocomplete.ensure_correct_suggestions('Bí', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('bí', nil, results, [1])
autocomplete.ensure_correct_suggestions('bí', nil, results, correct_suggestions)


dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'word')
end

msg('Test that unaccented characters match for accented requests')
correct_suggestions = ['ecole']
autocomplete.ensure_correct_counts('Éc', nil, results, [1])
autocomplete.ensure_correct_suggestions('Éc', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('éc', nil, results, [1])
autocomplete.ensure_correct_suggestions('éc', nil, results, correct_suggestions)

correct_suggestions = ['hargalaten']
autocomplete.ensure_correct_counts('Hå', nil, results, [1])
autocomplete.ensure_correct_suggestions('Hå', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('hå', nil, results, [1])
autocomplete.ensure_correct_suggestions('hå', nil, results, correct_suggestions)

dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'word')
end

msg('Test that Korean data matches as a single word')
correct_suggestions = ['국내검색엔진']
autocomplete.ensure_correct_counts('국내', nil, results, [1])
autocomplete.ensure_correct_suggestions('국내', nil, results, correct_suggestions)

msg('Test that Chinese data matches as a single word')
correct_suggestions = ['中餐小議']
autocomplete.ensure_correct_counts('中', nil, results, [1])
autocomplete.ensure_correct_suggestions('中', nil, results, correct_suggestions)

msg('Test that Thai data matches as a single word')
correct_suggestions = ['สถานีอวกาศนานาชาติ']
autocomplete.ensure_correct_counts('ส', nil, results, [1])
autocomplete.ensure_correct_suggestions('ส', nil, results, correct_suggestions)

msg('Test that Japanese data matches as a single word')
correct_suggestions = ['あなたの単語リスト']
autocomplete.ensure_correct_counts('あ', nil, results, [1])
autocomplete.ensure_correct_suggestions('あ', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('ア', nil, results, [1])
autocomplete.ensure_correct_suggestions('ア', nil, results, correct_suggestions)
correct_suggestions = []
autocomplete.ensure_correct_counts('語', nil, results, [])
autocomplete.ensure_correct_suggestions('語', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('な', nil, results, [])
autocomplete.ensure_correct_suggestions('な', nil, results, correct_suggestions)

dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'phrase')
end

msg('Test that Korean data matches as a phrase when seperated by spaces')
correct_suggestions = ['국내 검색 엔진']
autocomplete.ensure_correct_counts('검', nil, results, [1])
autocomplete.ensure_correct_suggestions('검', nil, results, correct_suggestions)

msg('Test that Chinese data matches as a phrase when seperated by spaces')
correct_suggestions = ['中餐 小議']
autocomplete.ensure_correct_counts('小', nil, results, [1])
autocomplete.ensure_correct_suggestions('小', nil, results, correct_suggestions)

msg('Test that Thai data matches as a phrase when seperated by spaces')
correct_suggestions = ['สถานี อวกาศ นานา ชาติ']
autocomplete.ensure_correct_counts('อ', nil, results, [1])
autocomplete.ensure_correct_suggestions('อ', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('นา', nil, results, [1])
autocomplete.ensure_correct_suggestions('นา', nil, results, correct_suggestions)

msg('Test that Japanese data matches as a phrase when seperated by spaces')
correct_suggestions = ['あなた の 単語 リスト']
autocomplete.ensure_correct_counts('単', nil, results, [1])
autocomplete.ensure_correct_suggestions('単', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('あ', nil, results, [1])
autocomplete.ensure_correct_suggestions('あ', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('ア', nil, results, [1])
autocomplete.ensure_correct_suggestions('ア', nil, results, correct_suggestions)
correct_suggestions = []
autocomplete.ensure_correct_counts('語', nil, results, [])
autocomplete.ensure_correct_suggestions('語', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('な', nil, results, [])
autocomplete.ensure_correct_suggestions('な', nil, results, correct_suggestions)

dict.setup_and_build(results) do |dict|
  dict.set_autocomplete_output_vis_node('<vse-index-stream segmenter="japanese"/>')
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'word')
end

msg('Test that Japanese data naturally matches as a phrase when autocomplete collection has japanese segmenter')
correct_suggestions = ['あなたの単語リスト']
autocomplete.ensure_correct_counts('単', nil, results, [1])
autocomplete.ensure_correct_suggestions('単', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('あ', nil, results, [1])
autocomplete.ensure_correct_suggestions('あ', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('ア', nil, results, [1])
autocomplete.ensure_correct_suggestions('ア', nil, results, correct_suggestions)
correct_suggestions = []
autocomplete.ensure_correct_counts('語', nil, results, [])
autocomplete.ensure_correct_suggestions('語', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('な', nil, results, [])
autocomplete.ensure_correct_suggestions('な', nil, results, correct_suggestions)

dict.setup_and_build(results) do |dict|
  dict.set_autocomplete_output_vis_node('<vse-index-stream segmenter="thai"/>')
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'word')
end

msg('Test that Thai data matches as a phrase when autocomplete collection has thai segmenter')
correct_suggestions = ['สถานีอวกาศนานาชาติ']
autocomplete.ensure_correct_counts('อ', nil, results, [1])
autocomplete.ensure_correct_suggestions('อ', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('นา', nil, results, [1])
autocomplete.ensure_correct_suggestions('นา', nil, results, correct_suggestions)
correct_suggestions = []
autocomplete.ensure_correct_suggestions('ถ', nil, results, correct_suggestions)

dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'word')
end

msg('Test that non-ASCII data matches as a word')
correct_suggestions = ['ტყაოსანი']
autocomplete.ensure_correct_counts('ტ', nil, results, [1])
autocomplete.ensure_correct_suggestions('ტ', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('ტყ', nil, results, [1])
autocomplete.ensure_correct_suggestions('ტყ', nil, results, correct_suggestions)

dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'phrase')
end

msg('Test that non-ASCII data matches as phrase')
correct_suggestions = ['ვეპხის ტყაოსანი შოთა რუსთაველი']
autocomplete.ensure_correct_counts('ტ', nil, results, [1])
autocomplete.ensure_correct_suggestions('ტ', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('ტყ', nil, results, [1])
autocomplete.ensure_correct_suggestions('ტყ', nil, results, correct_suggestions)

correct_suggestions = ['somoruː vɒʃaːrnɒp']
autocomplete.ensure_correct_counts('v', nil, results, [1])
autocomplete.ensure_correct_suggestions('v', nil, results, correct_suggestions)
autocomplete.ensure_correct_counts('vɒʃ', nil, results, [1])
autocomplete.ensure_correct_suggestions('vɒʃ', nil, results, correct_suggestions)

msg('Test that non-ASCII data matches as phrase when seperated by unicode space characters')
correct_suggestions = ['ᚦᚩᚱᚾ᛫ᛒᛦᚦ᛫ᚦᛖᚪᚱᛚᛖ᛫ᛋᚳᛖᚪᚱᛈ']
autocomplete.ensure_correct_counts('ᚦᛖ', nil, results, [1])
autocomplete.ensure_correct_suggestions('ᚦᛖ', nil, results, correct_suggestions)

results.cleanup_and_exit!(true)
