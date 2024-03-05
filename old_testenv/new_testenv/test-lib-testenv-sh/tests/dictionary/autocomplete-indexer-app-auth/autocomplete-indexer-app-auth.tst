#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require 'dictionary_collections'
require 'autocomplete_indexer_app'

results = TestResults.new('Basic test to see if the autocomplete indexer app authentication works')
results.need_system_report = false

collection = DictionarySimple.new
results.associate(collection)
collection.setup

app = AutocompleteIndexerApp.new(collection.name)

def expect_single_exception(app, results, exception_name)
  index_data = app.get_data(['title'])
  exceptions = index_data.xpath('//exception')
  results.add_number_equals(1, exceptions.size, 'exception')

  exceptions.each do |e|
    results.add_equals(exception_name, e['name'], 'exception name')  
  end
end

def expect_no_exception(app, results)
  index_data = app.get_data(['title'])
  exceptions = index_data.xpath('//exception')
  results.add_number_equals(0, exceptions.size, 'exception')

  exceptions.each do |e|
    puts e
  end
end

app.authentication_type = :none
expect_single_exception(app, results, 'rights-execute')

app.authentication_type = :username
expect_no_exception(app, results)

app.authentication_type = :username
app.username = TESTENV.user
app.password = TESTENV.password + '-wrong-password'
expect_single_exception(app, results, 'core-authenticate-error')

app.authentication_type = :username
app.username = TESTENV.user + '-wrong-username'
app.password = TESTENV.password
expect_single_exception(app, results, 'core-authenticate-error')

app.authentication_type = :su_token
expect_no_exception(app, results)

results.cleanup_and_exit!(true)
