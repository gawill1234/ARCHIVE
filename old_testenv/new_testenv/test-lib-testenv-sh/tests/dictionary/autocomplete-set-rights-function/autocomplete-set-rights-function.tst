#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require "vapi"
require 'make_function_public'

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

make_function_public(vapi, 'dictionary-set-autocomplete-rights-function')

results = TestResults.new('Test whether the rights-function attribute is correctly added/removed')
results.need_system_report = false

collection = Collection.new('ac-set-rights-function-autocomplete')

results.associate(collection)

# Make sure to start with no collection
if collection.exists?
  collection.delete
  results.add(!collection.exists?, 'Successfully deleted collection', 'Could not delete collection')
end

# Create collection
collection.create('default-autocomplete')

my_xml = vapi.repository_get(:element => 'source', :name => 'ac-set-rights-function-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(! t_e, 'Expected config present in collection', 'Unexpected configuration!')

msg('Function should have no affect if rights-function argument not set')
vapi.dictionary_set_autocomplete_rights_function(:dictionary => 'ac-set-rights-function')

my_xml = vapi.repository_get(:element => 'source', :name => 'ac-set-rights-function-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(! t_e, 'Expected config present in collection', 'Unexpected configuration!')

msg('Function should set attribute if rights-function argument not set')
vapi.dictionary_set_autocomplete_rights_function(:dictionary => 'ac-set-rights-function', :rights_function => 'foo')

my_xml = vapi.repository_get(:element => 'source', :name => 'ac-set-rights-function-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(t_e.value == 'foo', 'Expected config present in collection', 'Unexpected configuration!')

msg('Function should change attribute if rights-function is already set')
vapi.dictionary_set_autocomplete_rights_function(:dictionary => 'ac-set-rights-function', :rights_function => 'bar')

my_xml = vapi.repository_get(:element => 'source', :name => 'ac-set-rights-function-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(t_e.value == 'bar', 'Expected config present in collection', 'Unexpected configuration!')

msg('Function should unset attribute if rights-function is already set but is called with no rights-function')
vapi.dictionary_set_autocomplete_rights_function(:dictionary => 'ac-set-rights-function')

my_xml = vapi.repository_get(:element => 'source', :name => 'ac-set-rights-function-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(! t_e, 'Expected config present in collection', 'Unexpected configuration!')

restore_internal_function(vapi, 'dictionary-set-autocomplete-rights-function')

results.cleanup_and_exit!(true)
