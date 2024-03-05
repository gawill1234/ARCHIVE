#!/usr/bin/env ruby
#
#

require 'misc'
require 'collection'
require 'testenv'
require 'gronk'
require 'vapi'
require 'nokogiri'

# Variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
vapi = Vapi.new(velocity, user, password)

begin
  results = TestResults.new('Test bug 26726: The term expansion dictionary should not return a status node if no words have been added yet.')

  # Create search collection
  msg "Creating search collection: bug-26726"
  collection = Collection.new("bug-26726", velocity, user, password)
  results.associate(collection)
  collection.delete()
  collection.create()
  # Update to turn on term expansion dictionaries
  xml_file = File.open("bug-26726.xml")
  xml_to_update = Nokogiri::XML(xml_file)
  xml_file.close()

  vapi.repository_update(:node=> xml_to_update)

  # Start crawl with no seed specified
  vapi.search_collection_crawler_start(:collection=>"bug-26726")

  # Make sure dictionary build status is not null
  msg "Checking status of dictionary build"
  dictionary_status_xml = vapi.search_collection_status(:collection => "bug-26726")
  status = dictionary_status_xml.xpath('/vse-index-status/term-expand-dicts-status/@status')

  results.add(status.empty?() == true, "Status was not returned")

  results.cleanup_and_exit!

end

