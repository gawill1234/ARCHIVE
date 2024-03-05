#!/usr/bin/env ruby

require 'misc'
require 'velocity/example_metadata'

results = TestResults.new("an invalid xpath expression can cause the indexer-service to crash.",
                          'Try the specific xpath query "$foo[".',
                          "Failure is indicated by error messages in query-results.")

example_metadata = ExampleMetadata.new
example_metadata.ensure_correctness

bad_query = '<operator logic="and">
  <term field="v.condition-xpath" str="$foo[" />
</operator>'

resp = example_metadata.vapi.query_search(:sources => example_metadata.name,
                                          :query_object => bad_query)
messages = resp.xpath('//message').map {|m| m.text}
results.add(messages.empty?,
            "No messages",
            messages.join("\n             "))

results.cleanup_and_exit!
