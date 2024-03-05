#*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'query_expansion_helper'

describe "Query Expansion" do
  vlog "** Running tests for Query Expansion\n**************************************************************"
  context "Verifying that basic QE expansion works with existing Ontolections"  do

    before(:all) do
      qe_basic_test_setup()
    end

    # This corresponds to manual testsuite: Default Ontolection: English spelling variations (qa-suite-ontolection-spelling)
    ####################################################################################################
    it "'theater' should have one spelling variation expansion" do
      eq = @vapi.query_expand( :query => 'theater').root
      expansion = eq.xpath("//term[2]").attr('str').value
      expansion.should eql('theatre')
    end
    
  it "'african-american' should have two spelling variation expansions" do
     eq = @vapi.query_expand( :query => 'african-american').root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     expansion1.should eql('africanamerican') and
     expansion2.should eql('african american')
  end

  # This corresponds to manual testsuite: Multiple relation types (qa-suite-ontolection-basic-example)
  ####################################################################################################
  # will have to modify this test if final API function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'theater' should have two expansion terms in the temp query node" do
     eq = @vapi.query_expand({ :query => 'theater', :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     rel1 = eq.xpath("//term[2]").attr('relation').value
     rel2 = eq.xpath("//term[3]").attr('relation').value
     expansion1.should eql('theatre') and 
     expansion2.should eql('play') and
     rel1.should eql('spelling') and
     rel2.should eql('related')
  end

    # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'home' should have four expansion terms in the temp query node" do
     eq = @vapi.query_expand({ :query => 'home', :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     expansion3 = eq.xpath("//term[4]").attr('str').value
     expansion4 = eq.xpath("//term[5]").attr('str').value
     rel1 = eq.xpath("//term[2]").attr('relation').value
     rel2 = eq.xpath("//term[3]").attr('relation').value
     rel3 = eq.xpath("//term[4]").attr('relation').value
     rel4 = eq.xpath("//term[5]").attr('relation').value
     expansion1.should eql('house') and
     expansion2.should eql('townhouse') and
     expansion3.should eql('building') and
     expansion4.should eql('construction') and 
     rel1.should eql('synonym') and
     rel2.should eql('narrower') and
     rel3.should eql('broader') and
     rel4.should eql('broader') 
  end

  # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'work day' should have eight expansion terms in the temp query node" do
     # testing 4 of them
     eq = @vapi.query_expand({ :query => 'work day', :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     expansion3 = eq.xpath("//term[4]").attr('str').value
     expansion4 = eq.xpath("//term[5]").attr('str').value
     rel1 = eq.xpath("//term[2]").attr('relation').value
     rel2 = eq.xpath("//term[3]").attr('relation').value
     rel3 = eq.xpath("//term[4]").attr('relation').value
     rel4 = eq.xpath("//term[5]").attr('relation').value
     expansion1.should eql('weekday') and
     expansion2.should eql('week day') and
     expansion3.should eql('día laboral') and
     expansion4.should eql('Monday') and
     rel1.should eql('synonym') and
     rel2.should eql('spelling') and
     rel3.should eql('spanish') and
     rel4.should eql('narrower') 
  end

  it "'SIDS' should have one synonym expansion" do
     eq = @vapi.query_expand( :query => 'SIDS').root
     expansion = eq.xpath("//term[2]").attr('str').value
     expansion.should eql('Sudden Infant Death Syndrome')
  end

  # This corresponds to manual testsuite: Advanced relation types (qa-suite-ontolection-advanced-example)
  ########################################################################################################
  # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'Q&A' should have three expansion terms in the temp query node" do
     eq = @vapi.query_expand({ :query => "Q&A", :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     expansion3 = eq.xpath("//term[4]").attr('str').value
     rel1 = eq.xpath("//term[2]").attr('relation').value
     rel2 = eq.xpath("//term[3]").attr('relation').value
     rel3 = eq.xpath("//term[4]").attr('relation').value
     expansion1.should eql('Questions&Answers') and 
     expansion2.should eql('Questions and Answers') and
     expansion3.should eql('FAQ') and
     rel1.should eql('spelling') and
     rel2.should eql('spelling') and
     rel3.should eql('related')
  end

  # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'storage device' should have eight expansion terms in the temp query node" do
     # testing 4 of them
     eq = @vapi.query_expand({ :query => "storage device", :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     expansion3 = eq.xpath("//term[6]").attr('str').value
     expansion4 = eq.xpath("//term[7]").attr('str').value
     rel1 = eq.xpath("//term[2]").attr('relation').value
     rel2 = eq.xpath("//term[3]").attr('relation').value
     rel3 = eq.xpath("//term[6]").attr('relation').value
     rel4 = eq.xpath("//term[7]").attr('relation').value
     expansion1.should eql('flash drive') and 
     expansion2.should eql('USB drive') and
     expansion3.should eql('tank') and
     expansion4.should eql('floating storage device') and
     rel1.should eql('data-narrower') and
     rel3.should eql('energy-narrower') 
  end

  # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'CEO' should have four expansion terms in the temp query node" do
     eq = @vapi.query_expand({ :query => "CEO", :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     expansion3 = eq.xpath("//term[4]").attr('str').value
     expansion4 = eq.xpath("//term[5]").attr('str').value
     rel1 = eq.xpath("//term[2]").attr('relation').value
     expansion1.should eql('Chief executive officer') and 
     expansion2.should eql('Chief Executives Organization') and
     expansion3.should eql('Corporate Europe Observatory') and
     expansion4.should eql('Catholic Education Office') and
     rel1.should eql('acronym-synonym') # same for all expansions
  end

  # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'SIDS' should have four expansion terms in the temp query node" do
     eq = @vapi.query_expand({ :query => "SIDS", :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[3]").attr('str').value
     expansion2 = eq.xpath("//term[4]").attr('str').value
     expansion3 = eq.xpath("//term[5]").attr('str').value
     rel1 = eq.xpath("//term[3]").attr('relation').value
     rel3 = eq.xpath("//term[5]").attr('relation').value
     expansion1.should eql('Sudden Infant Death Syndrome') and 
     expansion2.should eql('Simian immunodeficiency virus') and
     expansion3.should eql('Small Island Developing States') and
     rel1.should eql('health-synonym') and
     rel3.should eql('economy-synonym')     
  end

  it "'Vivsimo' should have one expansion terms in the temp query node" do
     eq = @vapi.query_expand( :query => "Vivsimo").root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion1.should eql('Vivisimo') 
  end

  # This loosely corresponds to manual testsuite: Core query expansion functionality (qa-suite-query-expansion-core)
  # tests below don't include redundant and stress tests (which require modifying query expansion project options)
  ##################################################################################################################
  # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'townhouse' should have two expansion terms in the temp query node (inferred entry)" do
     eq = @vapi.query_expand({ :query => "townhouse", :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     rel1 = eq.xpath("//term[2]").attr('relation').value

     expansion1.should eql('house') and 
     expansion2.should eql('home') and
     rel1.should eql('broader') 
  end

  # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'día laboral': symmetric relations (spanish) should function like synonyms" do
     # testing 4 of them
     eq = @vapi.query_expand({ :query => 'día laboral', :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     expansion3 = eq.xpath("//term[4]").attr('str').value
     expansion4 = eq.xpath("//term[5]").attr('str').value
     rel1 = eq.xpath("//term[2]").attr('relation').value
     rel2 = eq.xpath("//term[3]").attr('relation').value
     rel3 = eq.xpath("//term[4]").attr('relation').value
     rel4 = eq.xpath("//term[5]").attr('relation').value

     expansion1.should eql('weekday') and
     expansion2.should eql('work day') and
     expansion3.should eql('week day') and
     expansion4.should eql('Monday') and
     rel1.should eql('synonym') and
     rel3.should eql('spelling') and
     rel4.should eql('narrower') 
  end

  # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'bebe': symmetric relations (translation) should function like synonyms" do
     # testing 4 out of 6
     eq = @vapi.query_expand({ :query => 'bebe', :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     expansion3 = eq.xpath("//term[4]").attr('str').value
     expansion4 = eq.xpath("//term[5]").attr('str').value
     rel1 = eq.xpath("//term[2]").attr('relation').value
     rel3 = eq.xpath("//term[4]").attr('relation').value
     rel4 = eq.xpath("//term[5]").attr('relation').value

     expansion1.should eql('baby') and
     expansion2.should eql('infant') and
     expansion3.should eql('person') and
     expansion4.should eql('pediatrician') and
     rel1.should eql('synonym') and
     rel3.should eql('broader') and
     rel4.should eql('related') 
  end

  # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms)
  it "'Chief executive officer' should have four expansion terms in the temp query node" do
     eq = @vapi.query_expand({ :query => "Chief executive officer", :output_node_type => 'display' }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     expansion3 = eq.xpath("//term[4]").attr('str').value
     expansion4 = eq.xpath("//term[5]").attr('str').value
     rel1 = eq.xpath("//term[2]").attr('relation').value
     rel2 = eq.xpath("//term[3]").attr('relation').value

     expansion1.should eql('CEO') and 
     expansion2.should eql('Chief Executives Organization') and
     expansion3.should eql('Corporate Europe Observatory') and
     expansion4.should eql('Catholic Education Office') and
     rel1.should eql('synonym') and
     rel2.should eql('acronym-synonym')
  end

    # need to test once I fixed the selenium-client conflict
    it "STRESS TESTING: 'storage device' should have expansions, even with spurious auto-sym relation type" do
         # just testing 1 out of 8
         eq = @vapi.query_expand({ :query => "storage device", :output_node_type => 'display', :query_expansion__automatic_symmetric => ' testing;' }).root
         expansion1 = eq.xpath("//term[2]").attr('str').value
         rel1 = eq.xpath("//term[2]").attr('relation').value
         expansion1.should eql('flash drive') and 
         rel1.should eql('data-narrower')
    end
    
    it "STRESS TESTING: 'storage device' should have expansions, even with spurious auto-asym relation type" do
         eq = @vapi.query_expand({ :query => "storage device", :output_node_type => 'display', :query_expansion__automatic_asymmetric => 'narrower:0.5|data-narrower|energy-narrower|probando' }).root
         expansion1 = eq.xpath("//term[2]").attr('str').value
         rel1 = eq.xpath("//term[2]").attr('relation').value
         expansion1.should eql('flash drive') and 
         rel1.should eql('data-narrower')
    end

    it "STRESS TESTING: 'storage device' should have expansions, even with spaces around OL" do
         eq = @vapi.query_expand({ :query => "storage device", :output_node_type => 'display', :query_expansion__ontolections => ' ontolection-english-general-advanced-example ' }).root
         expansion1 = eq.xpath("//term[2]").attr('str').value
         rel1 = eq.xpath("//term[2]").attr('relation').value
         expansion1.should eql('flash drive') and 
         rel1.should eql('data-narrower')
    end
 
    it "STRESS TESTING: 'storage device' should have expansions, even with spaces around the relevant relation types" do
         eq = @vapi.query_expand({ :query => "storage device", :output_node_type => 'display', :query_expansion__automatic_asymmetric => 'narrower:0.5| data-narrower | energy-narrower ' }).root
         expansion1 = eq.xpath("//term[2]").attr('str').value
         rel1 = eq.xpath("//term[2]").attr('relation').value
         expansion1.should eql('flash drive') and 
         rel1.should eql('data-narrower')
    end
    
    it "STRESS TESTING: 'storage device' should have expansions, even when adding an unexisting OL" do
         eq = @vapi.query_expand({ :query => "storage device", :output_node_type => 'display', :query_expansion__ontolections => ' ontolection-english-general-advanced-example fake-ol' }).root
         expansion1 = eq.xpath("//term[2]").attr('str').value
         rel1 = eq.xpath("//term[2]").attr('relation').value
         expansion1.should eql('flash drive') and 
         rel1.should eql('data-narrower')
    end    
  
    it "'storage +device' should have NO expansions due to the MUST operator" do
         eq = @vapi.query_expand({ :query => "storage +device", :output_node_type => 'display' }).root
         eq.to_s.should_not include("@relation")
    end
    		
    it "'work day' should have 8 expansions, when setting max-terms-per-type to -1" do
         eq = @vapi.query_expand({ :query => "work day", :output_node_type => 'display', :query_expansion__max_terms_per_type => '-1' }).root
         count = eq.xpath("//query[1]//term[@relation]").length
         count.should eql(8)
    end    
    
    it "'work day' should have 4 expansions, when setting max-terms-per-type to 1" do
         eq = @vapi.query_expand({ :query => "work day", :output_node_type => 'display', :query_expansion__max_terms_per_type => '1' }).root
         count = eq.xpath("//query[1]//term[@relation]").length
         count.should eql(4)
    end
    
    it "'work day' should have expansions when match-type=exact" do
         eq = @vapi.query_expand({ :query => "work day", :output_node_type => 'display', :query_expansion__query_match_type=> 'exact' }).root
         expansion1 = eq.xpath("//term[2]").attr('str').value
         rel1 = eq.xpath("//term[2]").attr('relation').value
         expansion1.should eql('weekday') and
         rel1.should eql('synonym') 
    end   
     
    it "'work day' should have NO expansions when match-type=terms" do
         eq = @vapi.query_expand({ :query => "work day", :output_node_type => 'display', :query_expansion__query_match_type=> 'terms' }).root
         eq.to_s.should_not include("@relation")
    end    

    # New tests to make sure default weights work as expected (introduced in 7.5)
    ##############################################################################
    it "'theater' should have one spelling variation expansion with weight 0.8" do
      eq = @vapi.query_expand( :query => 'theater').root
      expansion = eq.xpath("//term[2]").attr('str').value
      w = eq.xpath("//term[2]").attr('weight').value
      expansion.should eql('theatre') and
      w.should eql('0.8')
    end
    
    # will have to modify this test if final APi function doesn't have a display output-node-type (will not be as interesting, can only verify checked terms) - switch to using the query-meta class, although then we wouldn't be testing the API functions anymore
    it "'home' should have a synonym and a narrower expansion with weights 0.8 and 0.5 respectively" do
      eq = @vapi.query_expand({ :query => 'home', :output_node_type => 'both' }).root
      # in the display node
      expansion1 = eq.xpath("//op-exp//term[@relation='synonym']").attr('str').value
      expansion2 = eq.xpath("//op-exp//term[@relation='narrower']").attr('str').value
      # in the final node
      w1 = eq.xpath("//operator//term[@str='#{expansion1}']").attr('weight').value
      w2 = eq.xpath("//operator//term[@str='#{expansion2}']").attr('weight').value
      expansion1.should eql('house') and
      expansion2.should eql('townhouse') and
      w1.should eql('0.8') and
      w2.should eql('0.5') 
    end    

    it "'infant' should have at least a translation, a broader and a related expansion with weights 05, 0.3 and 0.2 respectively" do
     # can only see weights if @use=true, need to move defaults to automatic options
      eq = @vapi.query_expand({ :query => 'infant', :output_node_type => 'both', :query_expansion__automatic_symmetric => 'translation:0.5', :query_expansion__automatic_asymmetric => 'broader:0.3|related:0.2' }).root
      expansion1 = eq.xpath("//term[@relation='translation']").attr('str').value
      expansion2 = eq.xpath("//term[@relation='broader']").attr('str').value
      expansion3 = eq.xpath("//term[@relation='related']").attr('str').value
      w1 = eq.xpath("//operator//term[@str='#{expansion1}']").attr('weight').value
      w2 = eq.xpath("//operator//term[@str='#{expansion2}']").attr('weight').value
      w3 = eq.xpath("//operator//term[@str='#{expansion3}'][1]").attr('weight').value      
      expansion1.should eql('bebe') and
      expansion2.should eql('person') and
      expansion3.should eql('pediatrician') and
      w1.should eql('0.5') and
      w2.should eql('0.3') and
      w3.should eql('0.2')
    end 

    # This corresponds to manual test-suite: Weights for relation types (qa-suite-query-expansion-weights)
    # with some modifications (different weights)
    ######################################################################################################
    it "'theater' should have one spelling variation expansion with weight 0.9" do
      eq = @vapi.query_expand({ :query => 'theater', 
                                :query_expansion__automatic_symmetric => 'spelling:0.9' }).root
      expansion = eq.xpath("//term[2]").attr('str').value
      w = eq.xpath("//term[2]").attr('weight').value
      expansion.should eql('theatre') and
      w.should eql('0.9')
  end
 
  it "'home' should have two expansions with weights" do
     eq = @vapi.query_expand({ :query => 'home', 
                               :query_expansion__automatic_symmetric => 'synonym:0.5', 
                               :query_expansion__automatic_asymmetric => 'narrower:0.4'  }).root
     expansion1 = eq.xpath("//term[2]").attr('str').value
     expansion2 = eq.xpath("//term[3]").attr('str').value
     w1 = eq.xpath("//term[2]").attr('weight').value
     w2 = eq.xpath("//term[3]").attr('weight').value

     expansion1.should eql('house') and
     expansion2.should eql('townhouse') and
     w1.should eql('0.5') and
     w2.should eql('0.4') 
  end

    it "'SIDS' should have expansions with weight of 0.5 for synonym: Sudden Infant Death Syndrome and health-synonym: Sudden Infant Death Syndrome, Simian immunodeficiency virus; and of 0.01 for economy-synonym: Small Island Developing States" do
      eq = @vapi.query_expand({ :query => 'SIDS', 
                                :query_expansion__automatic_symmetric => 'synonym:0.5|health-synonym:0.5|economy-synonym:0.01' }).root
      expansion1 = eq.xpath("//term[2]").attr('str').value
      w1 = eq.xpath("//term[3]").attr('weight').value
      w2 = eq.xpath("//term[@str='Sudden Infant Death Syndrome']").attr('weight').value
      w3 = eq.xpath("//term[@str='Simian immunodeficiency virus']").attr('weight').value
      w4 = eq.xpath("//term[@str='Small Island Developing States']").attr('weight').value
      w1.should eql('0.5') and
      w2.should eql('0.5') and
      w3.should eql('0.5') and
      w4.should eql('0.01')
    end

    it "STRESS TESTING: 'storage device' should have data-narrower and energy-narrower (w=0.5) expansions, despite the missing weight and the extra space" do
      eq = @vapi.query_expand({ :query => 'storage device', 
                                :query_expansion__automatic_asymmetric => 'data-narrower:|energy-narrower: 0.5' }).root
      w0 = eq.xpath("//term[@str='flash drive']").attr('weight').value
      w1 = eq.xpath("//term[@str='tank']").attr('weight').value
      w2 = eq.xpath("//term[@str='floating storage device']").attr('weight').value
      w3 = eq.xpath("//term[@str='hydraulic accumulator']").attr('weight').value
      w0.should eql('') and
      w1.should eql('0.5') and
      w2.should eql('0.5') and
      w3.should eql('0.5') 
    end

    it "STRESS TESTING: 'vivsimo' should have a rewrite (w=3!) expansion, despite the extra | and it not being from [0-1]" do
      eq = @vapi.query_expand({ :query => 'vivsimo', 
                                :query_expansion__automatic_asymmetric => '|rewrite:3' }).root
      w1 = eq.xpath("//term[@str='Vivisimo']").attr('weight').value
      w1.should eql('3')
    end

    it "STRESS TESTING: 'car' should have a french, spanish and german expansion, despite the invalid weight format" do
      eq = @vapi.query_expand({ :query => 'car', 
                                :query_expansion__automatic_symmetric => 'french:0:9|spanish:0,9|german:0;9' }).root
      w1 = eq.xpath("//term[@str='carro']").attr('weight').value
      w2 = eq.xpath("//term[@str='Auto']").attr('weight').value
      w3 = eq.xpath("//term[@str='voiture']").attr('weight').value
      w1.should eql('0,9') and
      w2.should eql('0;9') and
      w3.should eql('0:9') 
    end

    it "STRESS TESTING: 'baby' should have a translation expansion, despite the invalid format" do
      eq = @vapi.query_expand({ :query => 'baby', 
                                :query_expansion__automatic_symmetric => 'translation;0.3' }).root
      eq.to_s.should_not include('bebe')
      eq = @vapi.query_expand({ :query => 'baby', 
                                :query_expansion__automatic_symmetric => 'translation:0.3' }).root
      w1 = eq.xpath("//term[@str='bebe']").attr('weight').value
      w1.should eql('0.3')
    end

    it "Query translation testing: 'baby' should not be in the final query (original:0) " do
      eq = @vapi.query_expand({ :query => 'baby', 
                                :query_expansion__automatic_symmetric => 'original:0|synonym:1|translation:0.7' }).root
      w2 = eq.xpath("//term[@str='bebe']").attr('weight').value
      w3 = eq.xpath("//term[@str='infant']").attr('weight').value
      eq.to_s.should_not include('baby') and
      w2.should eql('0.7') and
      w3.should eql('1')
    end

    it "'work day' should have original terms with a weight of 0.5 " do
      eq = @vapi.query_expand({ :query => 'work day', 
                                :query_expansion__automatic_symmetric => 'original:0.5|synonym:0.8|spelling:1|spanish:0.5' }).root
      w1 = eq.xpath("//term[@str='work day']").attr('weight').value
      w2 = eq.xpath("//term[@str='weekday']").attr('weight').value
      w3 = eq.xpath("//term[@str='week day']").attr('weight').value
      w4 = eq.xpath("//term[@str='día laboral']").attr('weight').value
      w1.should eql('0.5') and
      w2.should eql('0.8') and
      w3.should eql('1') and
      w4.should eql('0.5')
    end

    it "Query translation testing: 'big baby' should have big but only baby expansions in final query (original:0) " do
      pending "final API function implementation with match-type logic" do 
        eq = @vapi.query_expand({ :query => 'big baby', 
                                :query_expansion__automatic_symmetric => 'original:0|synonym:1|translation:0.7' }).root
        w2 = eq.xpath("//term[@str='bebe']").attr('weight').value
        w3 = eq.xpath("//term[@str='infant']").attr('weight').value
        eq.to_s.should include('big') and
        eq.to_s.should_not include('baby') and
        w2.should eql('0.7') and
        w3.should eql('1')
      end
    end
 end
end
