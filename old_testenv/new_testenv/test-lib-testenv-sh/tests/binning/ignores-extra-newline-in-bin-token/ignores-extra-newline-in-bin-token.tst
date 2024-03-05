#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'oracle-ship-collection'

BINNING_XML = <<XML
<binning-sets>
  <binning-set>
    <call-function name="binning-set">
      <with name="bs-id">ship</with>
      <with name="select">$SHIP_TYPE</with>
      <with name="label">ship</with>
    </call-function>

    <binning-set>
      <call-function name="binning-set">
        <with name="bs-id">nations</with>
        <with name="select">$NATION</with>
        <with name="label">nations</with>
      </call-function>
    </binning-set>
  </binning-set>
  <binning-set>
    <call-function name="binning-set">
      <with name="bs-id">align</with>
      <with name="select">$ALIGNED</with>
      <with name="label">align</with>
    </call-function>
  </binning-set>
</binning-sets>
XML

results = TestResults.new("The binning-state-token ignores trailing newline",
                          "characters, but not carriage returns.")

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

collection = OracleShipCollection.new(vapi, Collection.new(TESTENV.test_name))
collection.prepare_binning_collection(BINNING_XML)
results.associate(collection)

collection.crawl

results.add_number_equals(359, collection.index_n_docs, "indexed document")

collection.search_by_refinement("ship==Battleship")
results.add_number_equals(62,collection.document_count, "battleship")
results.add_set_equals(['Andrea Doria', 'Anson', 'Arizona', 'Arizona', 'Arizona',
                        'Arkansas', 'Barham', 'Bismarck', 'Bismarck', 'Bretagne'],
                       collection.document_names,
                       'battleship name')

msg("Adding a \\n to the binning-state should not change the result")
collection.search_by_refinement("ship==Battleship\n")
results.add_number_equals(62, collection.document_count, "battleship")
results.add_set_equals(['Andrea Doria', 'Anson', 'Arizona', 'Arizona', 'Arizona',
                        'Arkansas', 'Barham', 'Bismarck', 'Bismarck', 'Bretagne'],
                       collection.document_names,
                       "battleship name")

collection.search_by_refinement("ship==Battleship\r")
results.add(collection.results_empty?,
            "The binning-state 'ship==Battleship\\r' was properly treated as an invalid binning-state-token.",
            "The binning-state 'ship==Battleship\\r' returned documents.")

collection.search_by_refinement("ship==Battleship\n\r")
results.add(collection.results_empty?,
            "The binning-state 'ship==Battleship\\n\\r' was properly treated as an invalid binning-state-token.",
            "The binning-state 'ship==Battleship\\n\\r' returned documents.")

collection.search_by_refinement("ship==Battleship\r\n")
results.add(collection.results_empty?,
            "The binning-state 'ship==Battleship\\r\\n' was properly treated as invalid.",
            "The binning-state 'ship==Battleship\\r\\n' returned documents.")

results.cleanup_and_exit!
