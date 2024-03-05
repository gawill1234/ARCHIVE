require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'query_node_to_string_helper'

@query_nodeset = ''
@result = ''

describe "function query-node-to-string" do

  before(:all) do
    query_node_to_string_test_setup
  end


  context "a OR b c" do

    setup do
      @query_nodeset = <<HERE
<query>
  <operator logic="and">
    <operator logic="or" middle-string="OR" name="OR0" precedence="0">
      <term field="query" str="a" position="0" processing="strict" input-type="user" />
      <term field="query" str="b" position="1" processing="strict" input-type="user" />
    </operator>
    <term field="query" str="c" position="2" processing="strict" input-type="user" />
  </operator>
</query>
HERE
      @result = @vapi.query_node_to_string_test(:query => @query_nodeset)
    end
    
    it "should return text of query \"a OR b c\" in order" do
      pending "a fix for bug 21645" do
        @result.xpath("//value").text.should eql("(a OR b) AND c")
      end
    end

    it "should return the node of the query \"a OR b c \" in order" do
      pending "a fix for bug 21645" do
        expected_result = <<HERE
<span class="query">
  <span class="operator">
    <span class="paren">(</span>
    <span class="operator">
      <span class="term">a</span>
      <span class="ostring"> OR </span>
      <span class="term">b</span>
    </span>
    <span class="paren">)</span>
    <span class="ostring"> AND </span>
    <span class="term">c</span>
  </span>
</span>
HERE
        @result.xpath("//copy/span").to_s.should eql(expected_result.chomp)
      end
    end

  end

  context "a OR (b AND c)" do
    setup do
      @query_nodeset = <<HERE
<query>
  <operator logic="and">
    <operator logic="or" middle-string="OR" name="OR0" precedence="0">
      <term field="query" str="a" position="0" processing="strict" input-type="user" />
      <operator logic="and">
        <term field="query" str="b" position="1" processing="strict" input-type="user" />
        <term field="query" str="c" position="2" processing="strict" input-type="user" />
      </operator>
    </operator>
  </operator>
</query>
HERE
      @result = @vapi.query_node_to_string_test(:query => @query_nodeset)
    end

    it "should return the text of query \"a OR (b AND c)\" in order" do
      @result.xpath("//value").text.should eql("a OR (b AND c)")
    end

    it "should return the node of query \"a OR (b AND c)\" in order" do
      expected_result = <<HERE
<span class="query">
  <span class="operator">
    <span class="term">a</span>
    <span class="ostring"> OR </span>
    <span class="paren">(</span>
    <span class="operator">
      <span class="term">b</span>
      <span class="ostring"> AND </span>
      <span class="term">c</span>
    </span>
    <span class="paren">)</span>
  </span>
</span>
HERE
      @result.xpath("//copy/span").to_s.should eql(expected_result.chomp)
    end
  end
end