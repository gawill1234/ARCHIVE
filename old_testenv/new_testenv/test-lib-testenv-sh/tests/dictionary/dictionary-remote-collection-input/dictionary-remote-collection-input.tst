#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'optparse'
require 'misc'
require "collection"
require 'autocomplete'
require 'dictionary'
require 'dictionary_collections'
require 'autocomplete_indexer_app'
require 'host_wrappers'
require 'velocity/example_metadata'

results = TestResults.new('Test to see if dictionaries can read data from remote hosts')
results.need_system_report = false

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
output_collection.delete
input_collection = DictionarySimple.new
results.associate(input_collection)
input_collection.setup

msg "Test building locally"
dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)
dict.delete
dict.create

dict.add_collection_input(input_collection.name)
dict.set_tokenization(true)
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

autocomplete = Autocomplete.new(TESTENV.test_name)

correct_suggestions = ['alpha']
autocomplete.ensure_correct_suggestions('a', nil, results, correct_suggestions)

correct_suggestions = ['hotel']
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

msg "Test building locally with missing port config"
vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
old_qs_config = vapi.search_service_get()

results.add(!old_qs_config.xpath('//vse-qs/vse-qs-option/port').empty?, 'Option node exists', 'Port config not found')

empty_qs_node = old_qs_config.document.create_element('vse-qs')
vapi.search_service_set(:configuration => empty_qs_node)
vapi.search_service_restart()

resp = vapi.search_service_get().xpath('//vse-qs/vse-qs-option/port')
results.add(resp.empty?, 'Port config removed', 'Port config still exists')

dict = AutocompleteDictionary.new(TESTENV.test_name)
dict.delete
dict.create

dict.add_collection_input(input_collection.name)
dict.set_tokenization(true)
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

autocomplete = Autocomplete.new(TESTENV.test_name)

correct_suggestions = ['alpha']
autocomplete.ensure_correct_suggestions('a', nil, results, correct_suggestions)

correct_suggestions = ['hotel']
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

vapi.search_service_set(:configuration => old_qs_config.xpath('//vse-qs'))
vapi.search_service_restart()
resp = vapi.search_service_get().xpath('//vse-qs/vse-qs-option/port')
results.add(!resp.empty?, 'Option node restored', 'Could not restore config')

msg "Test building from local collection via host and port"
dict = AutocompleteDictionary.new(TESTENV.test_name)
dict.delete
dict.create

dict.add_collection_input(input_collection.name, {:host => 'localhost', :port => TESTENV.query_service_port, :username => TESTENV.user, :password => TESTENV.password})
dict.set_to_autocomplete_output
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

autocomplete = Autocomplete.new(TESTENV.test_name)

correct_suggestions = ['alpha charlie echo golf india kilo mike oscar quebec sierra']
autocomplete.ensure_correct_suggestions('alpha c', nil, results, correct_suggestions)

correct_suggestions = ['alpha bravo charlie delta echo foxtrot golf hotel india juliet']
autocomplete.ensure_correct_suggestions('hotel i', nil, results, correct_suggestions)

if (__FILE__ == $0)
  options = {}

  optparse = OptionParser.new do|opts|
    options[:remote] = ""
    opts.on( '-r', '--remote ENV_FILE', 'Remote environment file' ) do |r|
      options[:remote] = r || ""
    end
  end

  optparse.parse!

  if (options[:remote] != "")
    msg "Test building from a truly remote host"
    dict = AutocompleteDictionary.new(TESTENV.test_name)
    dict.delete
    dict.create

    hostenv = HostEnv.new(options[:remote])

    results.add(hostenv.parse_env, "Connected to remote host", "Could not create connection to remote host")

    if results.last_step[:pass]
      example_metadata = ExampleMetadata.new(hostenv.velocity, hostenv.user, hostenv.password)
      example_metadata.ensure_correctness

      dict.add_collection_input('example-metadata',
                                {:contents => 'hero', :host => hostenv.get_host_addr, :port => hostenv.env_from_file['VIVPORT'],
                                  :username => hostenv.user, :password => hostenv.password})
      dict.build
      dict.wait_until_finished(results)

      results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

      autocomplete = Autocomplete.new(TESTENV.test_name)

      correct_suggestions = ['kit fielding', 'rob finn']
      autocomplete.ensure_correct_suggestions('fi', nil, results, correct_suggestions)

      correct_suggestions = []
      autocomplete.ensure_correct_suggestions('hotel i', nil, results, correct_suggestions)
    end
  end
end
results.cleanup_and_exit!(true)
