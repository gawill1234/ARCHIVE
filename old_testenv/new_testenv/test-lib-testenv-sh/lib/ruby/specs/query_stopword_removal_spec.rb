require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'query_expansion_helper'

describe "Query Stopword Removal" do
  before(:all) do
    # start_new_browser_session
    # 
    # ### ensures that ontolection-english-spelling-variations has been crawled and uses old conceptual-search
    # vlog "Pre-req 1: crawling OL"
    # ol = Velocity::Collection.new(@vapi, 'ontolection-english-spelling-variations')
    # if ol.crawler_status.include?('stopped')
    #   vlog "already crawled, status: #{ol.crawler_status}"
    # else
    #   vlog "started crawl, current status is: #{ol.crawler_status}"
    #   ol.start_crawl
    # end
    # admin_login
  end

  vlog "Running tests for query stopword removal"

  it "should transfrom 'the very large can above' to 'very large can above'" do
    @qm.query_vxml('v:project' => 'exqa-query-stopwords', :query => 'the very large can above')
    m_query = @qm.last_query
    m_query_term1 = m_query.xpath('operator/term[1]').attr('str').value
    m_query_term1.should_not eql('the')
  end

  it "should leave phrasal query 'the very large can above' the same" do
    @qm.query_vxml('v:project' => 'exqa-query-stopwords', :query => '"the very large can above"')
    m_query = @qm.last_query
    m_query_term1 = m_query.xpath('operator/term[1]').attr('str').value
    m_query_term1.should eql("the very large can above")
  end

  # it "Test 3: should transform 'all the above' -> above" do
  #   page.type "query", "all the above"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq_term1 = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]//span[@class='av'][2]")
  #   mq_term1.should eql("above")
  # end
  # 
  # it "Test 4: leave original query unchanged to avoid removing all stopwords and get an empty query" do
  #   page.type "query", "a of the"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"a\"") and mq.should include("str=\"the\"") and mq.should include("str=\"of\"")
  # end
  # 
  # it "Test 5:  should transform 'all the above' -> pit" do
  #   page.type "query", "a pit the of"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should_not include("str=\"a\"") and mq.should include("str=\"pit\"") and mq.should_not include("str=\"the\"") and mq.should_not include("str=\"of\"")
  # end
  # 
  # it "Test 6:  should transform 'the cat OR the dog' -> cat AND dog" do
  #   page.type "query", "the cat OR the dog"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should_not include("str=\"the\"") and mq.should include("cat") and mq.should include("dog") and mq.should_not include("logic=\"or\"")
  # end
  # 
  # it "Test 7:  should transform '(the cat) OR (the dog)' -> cat OR dog" do
  #   page.type "query", "(the cat) OR (the dog)"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should_not include("str=\"the\"") and mq.should include("cat") and mq.should include("dog") and mq.should include("logic=\"or\"")
  # end
  # 
  # it "Test 8:  should transform '((the cat) OR (the dog)) AND (a pig) NOT (many ducks)' -> '(cat OR dog) pig NOT (many ducks)'" do
  #   page.type "query", "((the cat) OR (the dog)) AND (a pig) NOT (many ducks)"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should_not include("str=\"the\"") and mq.should_not include("str=\"a\"") and mq.should include("cat") and mq.should include("dog") and mq.should include("pig") and mq.should include("ducks") and mq.should include("logic=\"or\"") and mq.should include("logic=\"not\"")
  # end
  # 
  # it "Test 9:  should transform 'the big fat dog' -> 'big fat dog'" do
  #   page.type "query", "the big fat dog"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should_not include("str=\"the\"") and mq.should include("str=\"big\"") and mq.should include("str=\"fat\"") and mq.should include("str=\"dog\"")
  # end
  # 
  # it "Test 10:  should transform '+the big fat dog' -> 'the big fat dog'" do
  #   page.type "query", "+the big fat dog"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"the\"") and mq.should include("str=\"big\"") and mq.should include("str=\"fat\"") and mq.should include("str=\"dog\"")
  # end
  # 
  # it "Test 11: should transform '+the a dog' -> 'the dog'" do
  #   page.type "query", "+the a dog"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"the\"") and mq.should_not include("str=\"a\"") and mq.should include("str=\"dog\"")
  # end
  # 
  # it "Test 12: should transform '+the a +of' -> 'the of'" do
  #   page.type "query", "+the a +of"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"the\"") and mq.should_not include("str=\"a\"") and mq.should include("str=\"of\"")
  # end
  # 
  # it "Test 13: should transform '+the +a dog' -> 'the a dog'" do
  #   vlog "\nTEST 13: verify that the MUST operator prevents stopwords from being removed (the a dog)\n******"
  #   page.type "query", "+the +a dog"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"the\"") and mq.should include("str=\"a\"") and mq.should include("str=\"dog\"")
  # end
  # 
  # it "Test 14: should transform 'title:the cat' -> 'the cat'" do
  #   page.type "query", "title:the cat"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"the\"") and mq.should include("str=\"cat\"")
  # end
  # 
  # it "Test 15: should transform 'title:\"the cat\"' -> 'the cat'" do
  #   page.type "query", "title:\"the cat\""
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"the cat\"")
  # end
  # 
  # it "Test 16: should transform 'CONTENT title CONTANING (the big fat dog)' -> 'the big fat dog'" do
  #   page.type "query", "CONTENT title CONTAINING (the big fat dog)"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"the\"") and mq.should include("str=\"big\"") and mq.should include("str=\"fat\"") and mq.should include("str=\"dog\"")
  # end
  # 
  # it "Test 17: should transform 'CONTENT title CONTANING \"the big fat dog\"' -> 'the big fat dog'" do
  #   page.type "query", "CONTENT title CONTAINING \"the big fat dog\""
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"the big fat dog\"")
  # end
  # 
  # it "Test 19: should transfrom 'the railroad' -> 'railroad OR railway' " do
  #   page.open "#{@query_meta}?v:project=exqa-query-stopwords-qe&query=the+railroad&v:debug=1"
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq_term1 = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]//span[@class='av'][2]")
  #   mq_term1.should_not eql("the")
  # end
  # 
  # it "Test 20: should leave \"the railroad\" unchanged' " do
  #   page.type "query", "\"the railroad\""
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq_term1 = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]//span[@class='av'][2]")
  #   mq_term1.should eql("the railroad")
  # end
  # 
  # it "Test 21: should leave 'a the of' unchanged (to avoid empty query) " do
  #   page.type "query", "a the of"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"a\"") and mq.should include("str=\"the\"") and mq.should include("str=\"of\"")
  # end
  # 
  # it "Test 22: should transfrom (the horse) OR (a race) -> horse OR race" do
  #   page.type "query", "(the horse) OR (a race)"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should_not include("str=\"the\"") and mq.should include("horse") and mq.should include("race") and mq.should include("logic=\"or\"")
  # end
  # 
  # it "Test 23: should not remove 'the' for the query '+the horse'" do
  #   page.type "query", "+the horse"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq.should include("str=\"the\"") and mq.should include("str=\"horse\"")
  # end
  # 
  # it "should suggest 'the large can' for the query 'the lrge can'" do
  #   page.open "#{@query_meta}?v:project=exqa-query-stopwords-spelling-corrections&query=the+lrge+can"
  #   correction = page.get_text("//div[@class='spelling-correction']")
  #   correction.should eql("Did you mean the large can?")
  # end
  # 
  # it "should remove the stopword 'the' from the query" do
  #   page.open "#{@query_meta}?v:project=exqa-query-stopwords-spelling-corrections&query=the+lrge+can&v:debug=1"
  #   query = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   m_query = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(query, m_query)
  #   m_query_term1 = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]//span[@class='av'][2]")
  #   m_query_term1.should_not eql("the")
  # end
  # 
  # it "Test 25: \"the lrge can\" should trigger Did you mean 'the large can'? (final query: the lrge can)" do
  #   page.type "query", "\"the lrge can\""
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   correction = page.get_text("//div[@class='spelling-correction']")
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq_term1 = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]//span[@class='av'][2]")
  #   correction.should eql("Did you mean \"the large can\"?") and mq_term1.should eql("the lrge can")
  # end
  # 
  # it "Test 26: should leave 'a the of' unchanged (to avoid empty query) and should NOT have a spelling correction " do
  #   page.type "query", "a the of"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   if page.is_element_present("//div[@class='spelling-correction']")
  #     nil
  #   else
  #     mq.should include("str=\"a\"") and mq.should include("str=\"the\"") and mq.should include("str=\"of\"")
  #   end
  # end
  # 
  # it "Test 27: 'the cat from ther friends' should trigger Did you mean 'the cat from their friends'? (final query: cat ther friends)" do
  #   page.type "query", "the cat from ther friends"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   correction = page.get_text("//div[@class='spelling-correction']")
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   mq_term1 = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]//span[@class='av'][2]")
  #   correction.should eql("Did you mean the cat from their friends?") and mq.should_not include("str=\"the\"") and mq.should_not include("str=\"from\"") and mq.should include("str=\"cat\"")  and mq.should include("str=\"ther\"") and mq.should include("str=\"friends\"")
  # end
  # 
  # it "Test 28: should not remove 'the' for the query '+the theter' and should have spelling correction" do
  #   page.type "query", "+the theter"
  #   page.click "//input[@value='Search']", :wait_for => :page
  #   correction = page.get_text("//div[@class='spelling-correction']")
  #   q = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][1]")
  #   mq = page.get_text("//div[@class='vse-debug-info']/div[@class='xml clearfix'][position() = last()]")
  #   log_query(q, mq)
  #   correction.should eql("Did you mean +the theater?") and mq.should include("str=\"the\"") and mq.should include("str=\"theter\"")
  # end

end
