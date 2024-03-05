require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'query_expansion_helper'
require 'csol_suggestions_helper'

# This test makes sure that:
## dictionary exists or creates it and builds it
## the relevant collections exist or creates them for example-metadata, and
## the relevant special (ccs and csol) collections are created and crawled
## deletes special (ccs and csol) collections at the end

=begin
 TODO:
     - move ccs-specific methods to helper (as a subclass of collection)
     - move tmp_QE_display_query methods to a subclass of query_meta in query_expansion_helper?
=end

describe "CSOL suggestions" do
  vlog "** Running tests for Conceptual Search Ontolection expansions\n**************************************************************"
  context "Verifying that terms in the CSOL have suggestions at query time"  do

    before(:all) do
      start_new_browser_session()
      csol_test_setup() 
    end

    after(:all) do
      clean_up()
    end

    it "'race' should have a suggested concepts" do
      @qm.query_vxml('v:project' => 'exqa-query-expansion-csol', :query => 'race')
      rel = @qm.temp_QEdisplay_query_1.xpath('//term[2]').attr('relation').value
      rel.should include('suggested')
    end

    it "'horse' should have a suggested concept" do
      @qm.query_vxml('v:project' => 'exqa-query-expansion-csol', :query => 'horse')
      rel = @qm.temp_QEdisplay_query_1.xpath('//term[2]').attr('relation').value
      rel.should include('suggested')
    end

    it "'attempt' should have a suggested concept" do
      @qm.query_vxml('v:project' => 'exqa-query-expansion-csol', :query => 'attempt')
      rel = @qm.temp_QEdisplay_query_1.xpath('//term[2]').attr('relation').value
      rel.should include('suggested')
    end

    it "'learn' should have no suggested concepts" do
      @qm.query_vxml('v:project' => 'exqa-query-expansion-csol', :query => 'learn')
      m_query = @qm.temp_QEdisplay_query_1.to_s
      m_query.should_not include('suggested')
    end
    
  end
  
end
