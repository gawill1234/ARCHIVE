#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/binning'
require 'misc'
require 'binning'
require 'metadata_collection'
require 'ics_collection'
require 'velocity/repository'
require 'velocity/query-meta'
require 'velocity/source'

BINNING_XML = <<XML
<binning-set bs-id='location' select='$location' label='Location'/>
<binning-set bs-id='price' select='$price' label='Price'/>
XML

common_refinement = "common_refinement"

def setup_collection_helper(collection, index_docs, results)
    results.associate(collection)
    index_docs.each do |doc|
        collection.add_document(doc)
    end

    collection.save!
    collection.add_binning_set(BINNING_XML)
    collection.indexer_restart
    collection.wait_until_idle
end

results = TestResults.new("Binning state tokens will be merged",
"when there are multiple sources in a project")
results.need_system_report = false

first_collection_name = "#{TESTENV.test_name}-first-collection"
first_collection = MetadataCollection.new(Collection.new(first_collection_name))
docs_in_first_collection = [
    {:location => "PITTSBURGH", :price=> 200000},
    {:location => "PHILADELPHIA", :price => 190000},
    {:location => common_refinement, :price => 90000},
    {:location => "SAN FRANCISCO", :price => 1200}
    ]

second_collection_name = "#{TESTENV.test_name}-second-collection"
second_collection = MetadataCollection.new(Collection.new(second_collection_name))
docs_in_second_collection = [
    {:location => common_refinement,:price => 12000000},
    {:location => "SOUTHSIDE",:price => 140000},
    {:location => "SQHILL",:price => 150000},
    {:location => "BEVERLY HILLS",:price => 2500000},
    {:location => "LOS ANGELES",:price => 1200000},
    {:location => "ANAHEIM",:price => 2100001},
    {:location => "TORONTO",:price => 100000},
    {:location => "CHICAGO",:price => 380000}
    ]

setup_collection_helper(first_collection, docs_in_first_collection, results)
setup_collection_helper(second_collection, docs_in_second_collection, results)

# Use a hard-coded source to mock up a ics collection here.
# It is difficult to create a real ics collection and have it return
# before normal collections.
# Tried to add <option name="meta.delay">1000</option> in the project
# settings. But that is not working, since the request sent to the ics
# collection is always after than the request to a normal collection.
# So this setting actually makes the ics collection returns later.
ics_collection_name = "#{TESTENV.test_name}-ics"
ICS_SOURCE_XML = <<EOF
<source name="#{ics_collection_name}" test-strictly="test-strictly" type="ref">
<binning id="#{ics_collection_name}" ndocs="0" skipped-docs="0" mode="normal">
    <binning-state />
</binning>
</source>
EOF

ics_source = Velocity::Source.new(first_collection.vapi, ics_collection_name)
ics_source.create(ICS_SOURCE_XML)

# Create new project
project_name = TESTENV.test_name

PROJECT_XML = Nokogiri::XML(<<EOF
<options name="#{project_name}" load-options="core">
  <load-options name="core" />
  <set-var name="ics-collection">#{ics_collection_name}</set-var>
  <set-var name="query.sources">#{first_collection_name} #{second_collection_name}</set-var>
</options>
EOF
).root.freeze

r = Repository.new
r.delete('options', project_name)
r.add(PROJECT_XML)

qm = Velocity::QueryMeta.new(TESTENV.query_meta, TESTENV.user, TESTENV.password)

def test_helper(project_name,
                expected_binning_id = nil,
                query_meta,
                binning_state,
                expected_tokens,
                results)
    expected_count = expected_tokens.count
    response = query_meta.query(:v__project => project_name,
                                :binning_state => binning_state,
                                'v:xml' => 1)
    xml = Nokogiri::XML(response.body)

    if !expected_binning_id.nil? and !expected_binning_id.empty? then
        binning_id = xml.xpath('//binning/@id').to_s
        results.add(binning_id.eql?(expected_binning_id),
        "Found expected binning id: #{expected_binning_id}",
        "Found binning id: #{binning_id}, expected #{expected_binning_id}")
    end

    token_num = xml.xpath('count(//binning/binning-state/binning-state-token)')
    results.add(token_num == expected_count,
    "Found expected number of binning state tokens",
    "Returns #{token_num} token(s), expected #{expected_count}")

    tokens = xml.xpath('//binning/binning-state/binning-state-token/@token')
    tokens.each do |token|
        results.add(expected_tokens.include?(token.to_s),
        "Found expected binning state token",
        "Token:#{token} is not expected")
    end
end

def there_is_expected_binning_state_token_when_ics_collection_returns_first(
    project_name,
    expected_binning_id,
    query_meta,
    results)
    expected_count = 1
    binning_state = "price==140000"
    test_helper(project_name, expected_binning_id, query_meta, binning_state, [binning_state], results)
end

def only_one_token_returns_when_a_refinement_configured_in_multi_collections_is_selected(
    project_name,
    query_meta,
    common_refinement,
    results)
    expected_count = 1
    binning_state = "location==#{common_refinement}"
    test_helper(project_name, nil, query_meta, binning_state, [binning_state], results)
end

def multi_tokens_return_when_multi_refinements_are_selected(
    project_name,
    query_meta,
    common_refinement,
    results)
    expected_count = 2
    binning_state1 = "location==#{common_refinement}"
    binning_state2 = "price==12000000"
    binning_state = "#{binning_state1}\n#{binning_state2}"
    test_helper(project_name, nil, query_meta, binning_state, [binning_state1,binning_state2], results)
end

there_is_expected_binning_state_token_when_ics_collection_returns_first(
    project_name,
    ics_collection_name,
    qm,
    results)

only_one_token_returns_when_a_refinement_configured_in_multi_collections_is_selected(
    project_name,
    qm,
    common_refinement,
    results)

multi_tokens_return_when_multi_refinements_are_selected(
    project_name,
    qm,
    common_refinement,
    results)

ics_source.delete
r.delete('options', project_name)
results.cleanup_and_exit!(true)
