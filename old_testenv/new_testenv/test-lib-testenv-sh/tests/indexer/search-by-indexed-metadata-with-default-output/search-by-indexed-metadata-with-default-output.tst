#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'oracle-ship-collection'

SYNTAX_NODE = <<XML
<syntax name="#{TESTENV.test_name}" load-syntax="core">
  <load-syntax name="core" />
  <field record="record" name="SHIP_TYPE" processing="strict" />
  <field record="record" name="NATION" processing="strict" />
</syntax>
XML

test_results = TestResults.new("Simple crawl of an oracle db that performs some",
                               "metadata queries without specifying output fields.")

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
collection = OracleShipCollection.new(vapi, Collection.new(TESTENV.test_name))
test_results.associate(collection)

collection.set_index_options({:duplicate_elimination => "false"})
collection.add_syntax(TESTENV.test_name, SYNTAX_NODE)

collection.crawl

collection.search_by_metadata_field("SHIP_TYPE:Mine Layer")
test_results.add_set_equals(%w{Abdiel Apollo Ariadne Latona Manxman Welshman},
                            collection.document_names, "mine laying ship")

collection.search_by_metadata_field("NATION:Poland")
test_results.add_set_equals(%w{B¿¿yskawica Burza Grom Orkan Piorun Wicher},
                            collection.document_names, "Polish ship")

test_results.cleanup_and_exit!
