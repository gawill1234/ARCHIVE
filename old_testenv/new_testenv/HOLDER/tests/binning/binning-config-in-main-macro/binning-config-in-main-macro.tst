#!/usr/bin/env ruby

require 'misc'
require 'velocity/repository'
require 'velocity/query-meta'
require 'velocity/example_metadata'

results = TestResults.new('Binning configuration in the core macro should ',
                          'not cause a crash on the second page (bug 26498)')
results.need_system_report = false

collection = ExampleMetadata.new
collection.ensure_correctness

def next_page_parameters(query_response)
  resp_noko = Nokogiri::HTML(query_response.body)

  list = resp_noko.xpath('.//div[contains(@class, "list-more")]').first
  next_page_link = list.xpath('.//a').first
  next_url = next_page_link['href']

  uri = URI.parse(next_url)
  params = CGI.parse(uri.query)

  vf = params['v:file'].first
  vs = params['v:state'].first

  {:v__file => vf, :v__state => vs}
end

def find_warnings(query_response)
  resp_noko = Nokogiri::HTML(query_response.body)
  resp_noko.xpath('//*[contains(@class, "vse-warning")]/*[contains(@class, "warning")]')
end

project_name = TESTENV.test_name
main_macro_name = "#{project_name}-main"

BINNING_SET_XML = Nokogiri::XML(<<EOF
<binning-sets>
  <binning-set>
    <call-function name="binning-set">
      <with name="select">$year</with>
    </call-function>
  </binning-set>
</binning-sets>
EOF
).root.freeze

PROJECT_XML = Nokogiri::XML(<<EOF
<options name="#{project_name}" load-options="core">
  <load-options name="core" />
  <set-var name="main">#{main_macro_name}</set-var>
</options>
EOF
).root.freeze

r = Repository.new

# Duplicate main macro, adding binning config
r.delete('macro', main_macro_name)
r.copy_node('macro', 'core-main', main_macro_name) do |node|
  node.first_element_child.add_previous_sibling(BINNING_SET_XML)
  node
end

# Create new project with main macro set to above
r.delete('options', project_name)
r.add(PROJECT_XML)

qm = Velocity::QueryMeta.new(TESTENV.query_meta, TESTENV.user, TESTENV.password)

query_response = qm.query(:v__project => project_name)
second_response = qm.query(next_page_parameters(query_response).merge(:v__debug => 1))
warning = find_warnings(second_response).first.text

results.add_matches('Unable to merge the binning node', warning,
                    :what => 'warning message')

results.cleanup_and_exit!(true)
