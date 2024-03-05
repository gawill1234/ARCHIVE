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

    <binning-set>
      <call-function name="binning-set">
        <with name="bs-id">ship2</with>
        <with name="select">$SHIP_TYPE</with>
        <with name="label">ship2</with>
      </call-function>
    </binning-set>
  </binning-set>

  <binning-set>
    <call-function name="binning-set">
      <with name="bs-id">nation2</with>
      <with name="select">$NATION</with>
      <with name="label">nation2</with>
    </call-function>
  </binning-set>
</binning-sets>
XML

results = TestResults.new("Simple oracle crawl and search that tests multiple,",
                          "nested binnings sets")

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

collection = OracleShipCollection.new(vapi, Collection.new(TESTENV.test_name))
collection.prepare_binning_collection(BINNING_XML)
results.associate(collection)

collection.crawl

results.add_number_equals(359, collection.index_n_docs, "indexed document")

msg("Checking results of 'binning-state=ship==Battleship'")
collection.search_by_refinement("ship==Battleship")
results.add_number_equals(62, collection.document_count, "battleship")
results.add_set_equals(['Andrea Doria', 'Anson', 'Arizona', 'Arizona', 'Arizona',
                        'Arkansas', 'Barham', 'Bismarck', 'Bismarck', 'Bretagne'],
                       collection.document_names, "battleship name")

msg("Checking results of 'binning-state=ship==Coastal Patrol Craft\\nnations==UK'")
collection.search_by_refinement("ship==Coastal Patrol Craft\nnations==UK")
results.add_number_equals(5, collection.document_count, "UK Coastal Patrol Craft")
results.add_set_equals(["Abercrombie", "Erebus", "Marshall Soult", "Roberts",
                        "Terror"],
                       collection.document_names,
                       "UK Coastal Patrol Craft name")

msg("Checking results of 'binning-state=align==allied'")
collection.search_by_refinement("align==allied")
results.add_number_equals(280, collection.document_count, "allied ship")
results.add_set_equals(%w{Abdiel Acasta Active Achates Acheron Activity Afridi
                          Abercrombie Alden Alden},
                       collection.document_names, "allied ship name")

msg("Checking results of 'binning-state=align==allied\\nship2==Mine Layer'")
collection.search_by_refinement("align==allied\nship2==Mine Layer")
results.add_number_equals(6, collection.document_count, "allied mine layer")
results.add_set_equals(%w{Abdiel Ariadne Apollo Latona Manxman Welshman},
                       collection.document_names, "allied mine layer name")


msg("Checking results of 'binning-state=nation2==UK'")
collection.search_by_refinement("nation2==UK")
results.add_number_equals(172, collection.document_count, "British ship")
results.add_set_equals(%w{Abdiel Abercrombie Acasta Achates Acheron Active
                          Activity Afridi Amazon Ambuscade},
                       collection.document_names, "British ship name")


msg("Checking results of 'binning-state=nation2==UK\\nship==Destroyer'")
collection.search_by_refinement("nation2==UK\nship==Destroyer")
results.add_number_equals(45, collection.document_count, "British destroyer")
results.add_set_equals(%w{Acasta Achates Acheron Active Afridi Amazon Ambuscade
                          Antelope Anthony Ardent},
                       collection.document_names, "british destroyer name")

results.cleanup_and_exit!
