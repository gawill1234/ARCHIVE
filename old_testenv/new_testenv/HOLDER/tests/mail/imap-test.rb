#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'
require 'misc'
require 'collection'
require 'nokogiri'

class ImapTest

  def initialize(test_desc)
    @testname = TESTENV.test_name.freeze
    @test_results = TestResults.new(@testname, test_desc)
    @collection = Collection.new(@testname)
    @test_results.associate(@collection)
  end

  def initialize_collection(crawler_config="", indexer_config="")
    @collection.delete
    @collection.create("default")
    xml = @collection.xml
    xml.xpath("/vse-collection/vse-config/crawler").children.before(crawler_config)
    xml.xpath("/vse-collection/vse-config/vse-index").children.before(indexer_config)
    @collection.set_xml(xml)
  end

  def run(n_docs, query_and_n_res=nil)
    source_xpath   = "//added-source[@name=\"#{@testname}\"]"
    n_docs_attr    = "total-results-with-duplicates"

    @collection.crawler_start
    @collection.wait_until_idle

    @test_results.add(@collection.index_n_docs == n_docs,
                      "The #{@testname} contains #{n_docs} documents as expected.",
                      "Expected the #{@testname} index to have #{n_docs}, "\
                      "but it instead has #{@collection.index_n_docs}.")
    if query_and_n_res
      query_and_n_res.each do |query, n_expected|
        n_docs = @collection.search(query).xpath(source_xpath).attr(n_docs_attr)

        @test_results.add(n_docs.value.to_i.eql?(n_expected.to_i),
                          "The query, \"#{query}\" returned #{n_docs} many hits.",
                          "Expected #{n_expected} many documents for the query"\
                          ", \"#{query}\", but #{n_docs} were returned.")
      end
    else
      msg = @collection.search("kenneth").xpath("#{source_xpath}/log/msg").attr('id').to_s
      @test_results.add(msg.eql?("SEARCH_ENGINE_EMPTY_INDEX"),
                        "The index is empty, as it should be.",
                        "Received an unexpected message from the indexer: #{msg}")
    end

    @test_results.cleanup_and_exit!
  end
end
