#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'autocomplete_collections'

results = TestResults.new('Test behavior of strange inputs to the autocomplete function')
results.need_system_report = false

collection = AutocompleteInputValidationCollection.new
results.associate(collection)
collection.setup

autocomplete = Autocomplete.new(collection.autocomplete_name)

def ensure_same_results(autocomplete, results, query, correct_suggestions)
  msg "Using query: #{query}"
  autocomplete.ensure_correct_suggestions(query, nil, results, correct_suggestions)
end

def ensure_no_results(autocomplete, results, query)
  ensure_same_results(autocomplete, results, query, [])
end

def ensure_hello_results(autocomplete, results, query)
  ensure_same_results(autocomplete, results, query, ['hello world'])
end

msg("Operators should be disabled")
ensure_same_results(autocomplete, results, 'CONTENT text',
                    ['try using CONTENT text CONTAINING using'])
ensure_no_results(autocomplete, results, 'hello OR world')
ensure_same_results(autocomplete, results, 'hello OR get',
                    ['say hello OR get out of the world!'])

msg("Ignore punctuation (default search collection setup)")
ensure_same_results(autocomplete, results, 'said !@#% yourself',
                    ['she said "!@#% yourself"'])
ensure_same_results(autocomplete, results, 'said yourself',
                    ['she said "!@#% yourself"'])

msg("Variations of random cruft in the query")
ensure_hello_results(autocomplete, results, 'Hello, Wo')
ensure_hello_results(autocomplete, results, '"Hello, Wo')
ensure_hello_results(autocomplete, results, '"Hello," Wo')
ensure_hello_results(autocomplete, results, 'hello w')
ensure_hello_results(autocomplete, results, '!@hello w')
ensure_hello_results(autocomplete, results, '!hello@w')
ensure_hello_results(autocomplete, results, '"hello w')
ensure_hello_results(autocomplete, results, '"hello" w')

msg("Don't explictly remove an asterisk from the input query")
ensure_hello_results(autocomplete, results, 'hello w*')
ensure_hello_results(autocomplete, results, 'hello w**')
ensure_hello_results(autocomplete, results, '*hello w*')
ensure_hello_results(autocomplete, results, 'hel* w*')

msg("Any character (other than *) counts as end of word")
# (default search collection setup)
ensure_no_results(autocomplete, results, 'hello w"')
ensure_no_results(autocomplete, results, '"hello w"')
ensure_no_results(autocomplete, results, 'hello!w@')
ensure_no_results(autocomplete, results, 'hello w!@')
ensure_no_results(autocomplete, results, '!hello w@')

msg("Should not return suggestions if only spaces or punctuation are entered")
ensure_no_results(autocomplete, results, ' ')
ensure_no_results(autocomplete, results, '  ')
ensure_no_results(autocomplete, results, '@')
ensure_no_results(autocomplete, results, '@ ')
ensure_no_results(autocomplete, results, '#')
ensure_no_results(autocomplete, results, '^^^^')

results.cleanup_and_exit!(true)
