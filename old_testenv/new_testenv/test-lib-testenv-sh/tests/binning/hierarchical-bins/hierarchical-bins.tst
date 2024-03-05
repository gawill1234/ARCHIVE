#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/binning'
require 'misc'
require 'binning'
require 'metadata_collection'

results = TestResults.new("Tree bins can be created and queried successfully.")
results.need_system_report = false

BINNING_XML = <<XML
<binning-set bs-id='location'
             select='$location'>
  <binning-tree />
</binning-set>
<binning-set bs-id='price' select='$price'/>
XML

collection = MetadataCollection.new(Collection.new(TESTENV.test_name))
results.associate(collection)

collection.add_document(:location => "US > PA > PITTSBURGH > OAKLAND",
                        :price    => 120000)
collection.add_document(:location => "US > PA > PITTSBURGH > SOUTHSIDE",
                        :price    => 140000)
collection.add_document(:location => "US > PA > PITTSBURGH > SOUTHSIDE",
                        :price    => 140000)
collection.add_document(:location => "US > PA > PITTSBURGH > SQHILL",
                        :price    => 150000)
collection.add_document(:location => "US > PA > PITTSBURGH > SQHILL",
                        :price    => 200000)
collection.add_document(:location => "US > PA > PITTSBURGH > OAKLAND",
                        :price    => 80000)
collection.add_document(:location => "US > PA > PHILADELPHIA",
                        :price    => 190000)
collection.add_document(:location => "US > PA > HARRISBURG",
                        :price    => 90000)
collection.add_document(:location => "US > PA > PITTSBURGH",
                        :price    => 120000)
collection.add_document(:location => "US > CA > SAN FRANCISCO",
                        :price    => 1200000)
collection.add_document(:location => "US > CA > LOS ANGELES",
                        :price    => 2500000)
collection.add_document(:location => "US > CA > LOS ANGELES",
                        :price    => 1200000)
collection.add_document(:location => "US > CA > LOS ANGELES > ANAHEIM",
                        :price    => 2100001)
collection.add_document(:location => "CA > ONT > TORONTO",
                        :price    => 100000)
collection.add_document(:location => "US > IL > CHICAGO",
                        :price    => 380000)
collection.save!

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

search = Binning::Search.new(vapi, collection.name, BINNING_XML)
binning_result = search.activate_facet_and_save("location", "CA")
results.add_set_equals(%w{100000}, binning_result.content_values("price"),
                       "Canadian house price")

binning_result.within("location") do |facet_values|
  results.add_set_equals(%w{CA}, facet_values.labels, "top level bin")

  facet_values.within("CA") do |facet_values|
    results.add_set_equals(%w{ONT}, facet_values.labels, "middle bin")

    facet_values.within("ONT") do |facet_values|
      results.add_set_equals(%w{TORONTO}, facet_values.labels, "child bin")
    end
  end
end

search = Binning::Search.new(vapi, collection.name, BINNING_XML)
search.activate_facet("location", "US")
binning_result = search.activate_facet_and_save("location", "PA")
results.add_set_equals(%w{120000 140000 140000 150000 200000 80000 190000 90000 120000},
                       binning_result.content_values("price"),
                       "US>PA house price")
binning_result.within("location") do |facet_values|
  results.add_set_equals(%w{US}, facet_values.labels, "top level bin")

  facet_values.within("US") do |facet_values|
    results.add_set_equals(%w{PA}, facet_values.labels, "middle bin")

    facet_values.within("PA") do |facet_values|
      results.add_set_equals(%w{PITTSBURGH PHILADELPHIA HARRISBURG},
                             facet_values.labels, "child bin")
    end
  end
end

search = Binning::Search.new(vapi, collection.name, BINNING_XML)
binning_result = search.activate_facet_and_save("price", "120000")
results.add_set_equals(["US > PA > PITTSBURGH > OAKLAND", "US > PA > PITTSBURGH"],
                       binning_result.content_values("location"),
                       "$120,000 house location")
binning_result.within("location") do |facet_values|
  results.add_set_equals(%w{US}, facet_values.labels, "top level bin")

  facet_values.within("US") do |facet_values|
    results.add_set_equals(%w{PA}, facet_values.labels, "second level bin")

    facet_values.within("PA") do |facet_values|
      results.add_set_equals(%w{PITTSBURGH}, facet_values.labels, "third level bin")

      facet_values.within("PITTSBURGH") do |facet_values|
        results.add_set_equals(%w{OAKLAND}, facet_values.labels, "childmost bin")
      end
    end
  end
end



search = Binning::Search.new(vapi, collection.name, BINNING_XML)
binning_result = search.activate_facet_and_save("price", "1200000")
results.add_set_equals(["US > CA > SAN FRANCISCO", "US > CA > LOS ANGELES"],
                       binning_result.content_values("location"),
                       "$1,200,000 house location")
binning_result.within("location") do |facet_values|
  results.add_set_equals(%w{US}, facet_values.labels, "top level bin")

  facet_values.within("US") do |facet_values|
    results.add_set_equals(%w{CA}, facet_values.labels, "second level bin")

    facet_values.within("CA") do |facet_values|
      results.add_set_equals(['SAN FRANCISCO', 'LOS ANGELES'],
                             facet_values.labels, "third level bin")
    end
  end
end

results.cleanup_and_exit!
