#!/usr/bin/env ruby

require "misc"
require "velocity/api"

results = TestResults.new('Clustering API function')
results.need_system_report = false

QueryClusterTest = Struct.new(:vapi, :results) do
  def it_creates_two_clusters_when_there_are_disjoint_repeated_words
    snippets = [
      "Hello Sol", "Hello Mercury", "Hello Venus",
      "Goodbye Neptune", "Goodbye Pluto"
    ]
    docs = snippets.map {|s| create_document(s)}.join

    api_response = vapi.query_cluster(:documents => docs)

    cluster_nodes = api_response.xpath('/tree/node/node')
    cluster_names = cluster_nodes.xpath('descriptor/@string').map(&:value)

    results.add_equals(['Hello', 'Goodbye'], cluster_names, "cluster names")
  end

  def it_allows_passing_complete_knowledge_bases_to_modify_the_clusters
    snippets = [
      "Hello Sol", "Hello Mercury", "Hello Venus",
      "Goodbye Neptune", "Goodbye Pluto",
      "Amazing Earth", "Amazing Moon",
    ]
    docs = snippets.map {|s| create_document(s)}.join

    kb = <<XML
<kb name="some-name">
  <rephrase this="goodbye" as="|" />
</kb>
XML

    api_response = vapi.query_cluster(:documents => docs, :inline_kbs => kb)

    cluster_nodes = api_response.xpath('/tree/node/node')
    cluster_names = cluster_nodes.xpath('descriptor/@string').map(&:value)

    results.add_equals(['Hello', 'Amazing'], cluster_names, "cluster names")
  end

  def it_prefers_rules_from_later_knowledge_bases
    snippets = [
      "Hello Sol", "Hello Mercury",
      "Goodbye Neptune", "Goodbye Pluto",
      "Amazing Earth",
    ]
    docs = snippets.map {|s| create_document(s)}.join

    kb = <<XML
<kb name="first">
  <rephrase this="amazing" as="hello" />
</kb>
<kb name="second">
  <rephrase this="amazing" as="goodbye" />
</kb>
XML

    api_response = vapi.query_cluster(:documents => docs, :inline_kbs => kb)

    cluster_nodes = api_response.xpath('/tree/node')

    hello_cluster = cluster_nodes.xpath("node[descriptor[@string='Hello']]").first
    goodbye_cluster = cluster_nodes.xpath("node[descriptor[@string='Goodbye']]").first

    hello_doc_count = hello_cluster['ndocs'].to_i
    goodbye_doc_count = goodbye_cluster['ndocs'].to_i

    results.add_number_equals(2, hello_doc_count, "hello cluster document")
    results.add_number_equals(3, goodbye_doc_count, "goodbye cluster document")
  end

  private

  def create_document(snippet)
  <<XML
<document>
  <content name="snippet">#{snippet}</content>
</document>
XML
  end
end

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
test = QueryClusterTest.new(vapi, results)

test.it_creates_two_clusters_when_there_are_disjoint_repeated_words
test.it_allows_passing_complete_knowledge_bases_to_modify_the_clusters
test.it_prefers_rules_from_later_knowledge_bases

results.cleanup_and_exit!(true)
