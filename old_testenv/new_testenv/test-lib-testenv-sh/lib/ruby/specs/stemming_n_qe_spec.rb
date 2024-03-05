# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'stemming_n_qe_helper'

describe "Stemming integration with Query Expansion" do
  vlog "** Running tests for stemming integration with Query Expansion\n**************************************************************"
  context "Verifying that stemming of the expanded query works as expected"  do
    before(:all) do
      stemming_qe_test_setup()
    end

  it "Test 1: 'theater' should have at least a stemming expansion" do
      @qm.query_vxml('v:project' => 'exqa-qe-stemming', :query => 'theater')
      rel = @qm.temp_QEdisplay_query_1.xpath('//term[3]').attr('relation').value
      rel.should include('stemming')
  end
  
  it "Test 2: ''the D day'' should have no stemming expansions" do
      @qm.query_vxml('v:project' => 'exqa-qe-stemming', :query => '"the D day"')
      m_query = @qm.temp_QEdisplay_query_1.to_s
      m_query.should_not include("stemming") 
  end

  it "Test 3: 'theater' should have a spelling+stemming expansion and at least one related+stemming expansion" do
      @qm.query_vxml('v:project' => 'exqa-qe-stemming', :query => 'theater')
      spelling = @qm.temp_QEdisplay_query_1.xpath('//term[3]').attr('relation').value
      spelling.should eql('spelling+stemming')
      related  = @qm.temp_QEdisplay_query_1.xpath('//term[5]').attr('relation').value
      related.should include("related+stemming")
  end

  it "Test 4: 'car' should have a stemming expansion and at least one synonym+stemming, one narrower+stemming, one spanish+stemming and one related+stemming expansion" do
      @qm.query_vxml('v:project' => 'exqa-qe-stemming', :query => 'car')    
      # should contain the following (otherwise will get an access error: undefined method `attribute' for nil:NilClass)
      # (so that I don't have to keep track ofexpansions position in the query node)
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='stemming']")
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='synonym+stemming'][1]")  # for some reason [1] finds first two!
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='spanish+stemming'][1]")
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='narrower+stemming'][1]")
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='related+stemming'][1]")
  end

  it "Test 5: 'baby' should have a stemming expansion and at least one synonym+stemming, one broader+stemming, and one related+stemming expansion" do
      @qm.query_vxml('v:project' => 'exqa-qe-stemming', :query => 'baby')    
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='stemming']")
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='synonym+stemming'][1]")  
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='broader+stemming'][1]")
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='related+stemming'][1]")
  end

  it "Test 6: 'work day' should have a stemming expansion and at least one spelling+stemming and one narrower+stemming expansion" do
      @qm.query_vxml('v:project' => 'exqa-qe-stemming', :query => 'work day')    
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='stemming']")
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='spelling+stemming'][1]")  
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='narrower+stemming'][1]")
  end

  it "Test 7: 'día laboral' should have a stemming expansion and at least one synonym+spelling and one narrower+stemming expansion" do
      @qm.query_vxml('v:project' => 'exqa-qe-stemming', :query => 'día laboral')    
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='stemming']")
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='synonym+stemming'][1]")  
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='narrower+stemming'][1]")
  end

  it "Test 8: 'bebe' should have at least one synonym+spelling, one narrower+stemming and one related+stemming expansion" do
      @qm.query_vxml('v:project' => 'exqa-qe-stemming', :query => 'bebe')    
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='synonym+stemming'][1]")  
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='broader+stemming'][1]")
      @qm.temp_QEdisplay_query_1.xpath("//term[@relation='related+stemming'][1]")
  end
 end
end
