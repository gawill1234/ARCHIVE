$LOAD_PATH << ENV['RUBYLIB']
require 'loader'

include Velocity

=begin
These tests are based on the specification at https://meta.vivisimo.com/wiki/XPath_operator/Test_plan, written by Jake Goulding.  The actual code for XPath operator was written by Chris Palmer.

XPath operator is a broad term that actually covers several different functionalities:
* using a fielded search with some new operators like so:
  year:> 1984
* how that is parsed into a comparison operator:
  <operator logic="greater-than">
    <term field="year" str="1984" />
  </operator>
* How that is processed in the indexer with the xpath logic operator:
  <operator logic="xpath">
    <term field="v.xpath" str="$year > 1984" />
  </operator>

These tests cover only the second two cases, as the first is not related to the API.  Please note that the xpath logic operator case can also be directly specified for more complex logic, as it can contain any xpath, including strs like: "viv:if-else($x, 2, 3)"  All comparison operator tests will be followed by a duplicate xpath operator test.

Related functionality is the indexing of content with fast-index attributes and indexed-fast-index attributes.  These tests will cover both possibilities.

Assumes the presence of an additional collection, xpath-operator-testing, which is in the qa repository namespace.  Access this namespace with user/pass qa/baseball.
=end

# functions used to detect test pass/fail.  Mostly useful shorthand.
#returns count of documents
def doc_count(xml)
  #xml.elements["count(//document)"]
  xml.xpath("//document").length
end

#returns @url of first document
def url(xml)
  #xml.elements["//document/@url"].to_s
  xml.xpath("//document/@url").to_s
end

describe "XPath operators" do
  context "Set up" do
		before(:all) do
			connect_to_velocity
		end

    it "should get a handle to the xpath source" do
      # Source to query for most of these queries
      $xpath_source = Source.new(@vapi, 'xpath-operator-testing')
    end

    it "should start the query service" do
      qs = QueryService.new(@vapi)
      status = qs.start
      #status.should eql(true)
      status.should_not be_nil
    end

    it "should cleanly crawl xpath-operator-testing" do
      coll_xo = Collection.new(@vapi, 'xpath-operator-testing')
      status = coll_xo.clean_crawl
      status.should eql("stopped")
    end
  end



  context "date comparisons - Apply the comparison operators to date values to ensure proper behavior.  Includes date range - Apply the range operator to date values to ensure proper behavior" do
    context "date range" do
      it "should test the range operator over a leap year - 3 documents between 2/28 and 3/01" do
        query_object = <<HERE
<operator logic="range">
  <term field="simple-date" str="2000/02/28" />
  <term field="simple-date" str="2000/03/01" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(3)
      end
      #it "should do the same with xpath" do
        #query_object = <<HERE
#<operator logic="xpath">
#  <term field="v.xpath" str="$simple-date > 2000/02/28 and $simple-date < 2000/03/01" />
#</operator>
#HERE
        #answer = $xpath_source.search(query_object)
        #doc_count(answer).should eql(3)
      #end

      it "should test the range operator over years -  3 documents between 2003 and 2005" do
        query_object = <<HERE
<operator logic="range">
  <term field="simple-date" str="2003-09-12 20:49:36" />
  <term field="simple-date" str="2005-11-12 20:49:38" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(3)
      end

      it "should test the range operator over months -  3 documents between 2006-09 and 2006-11" do
        query_object = <<HERE
<operator logic="range">
  <term field="simple-date" str="2006-09-12 20:49:36" />
  <term field="simple-date" str="2006-11-12 20:49:38" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(3)
      end

      it "should test the range operator over months with dates that are different-looking than they are on the actual document -  3 documents between 2006-09 and 2006-11" do
        query_object = <<HERE
<operator logic="range">
  <term field="simple-date" str="2006/04/01" />
  <term field="simple-date" str="2006/11/13" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(3)
      end

      it "should test the range operator over days -  3 documents between 2007-10-10 and 2007-10-12" do
        query_object = <<HERE
<operator logic="range">
  <term field="simple-date" str="2007-10-10" />
  <term field="simple-date" str="2007-10-12 20:49:38" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(3)
      end

      it "should test the range operator over days with a wider space around them -  3 documents between 2007 and 2008" do
        query_object = <<HERE
<operator logic="range">
  <term field="simple-date" str="2007" />
  <term field="simple-date" str="2008" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(3)
      end

      it "should test the range operator over days while excluding one by just one second -  2 documents between 2007-10-10 and 2007-10-12 20:49:37" do
        query_object = <<HERE
<operator logic="range">
  <term field="simple-date" str="2007-10-10" />
  <term field="simple-date" str="2007-10-12 20:49:37" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(2)
      end

      it "should test the range operator over seconds -  3 documents between 2008-10-12 20:49:36 and2008-10-12 20:49:38" do
        query_object = <<HERE
<operator logic="range">
  <term field="simple-date" str="2008-10-12 20:49:36" />
  <term field="simple-date" str="2008-10-12 20:49:38" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(3)
      end
    end


    context "smoke test for each of the comparison operators" do
      it "should do < properly - 17 docs < 2008-10-12 20:49:38" do
        query_object = <<HERE
<operator logic="less-than">
  <term field="simple-date" str="2008-10-12 20:49:38" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(17)
      end

      it "should do <= properly - 18 docs <= 2008-10-12 20:49:38" do
        query_object = <<HERE
<operator logic="less-than-or-equal">
  <term field="simple-date" str="2008-10-12 20:49:38" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(18)
      end

      it "should do > properly - 8 docs > 2006-10-12 20:49:37" do
        query_object = <<HERE
<operator logic="greater-than">
  <term field="simple-date" str="2006-10-12 20:49:37" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(8)
      end

      it "should do >= properly - 9 docs >= 2006-10-12 20:49:37" do
        query_object = <<HERE
<operator logic="greater-than-or-equal">
  <term field="simple-date" str="2006-10-12 20:49:37" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(9)
      end

      it "should do == properly - 1 doc for == 2006-10-12 20:49:37" do
        query_object = <<HERE
<operator logic="equal">
  <term field="simple-date" str="2006-10-12 20:49:37" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("simple-date-good-2006-10-1220:49:37")
      end
    end


    context "combine two operators" do
      it "should use < and > together correctly - 1 doc > 2/28 and < 3/01" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="greater-than">
    <term field="simple-date" str="2000-02-28" />
  </operator>
  <operator logic="less-than">
    <term field="simple-date" str="2000-03-01" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-date-good-2000/02/29")
      end

      it "should use < and < together correctly - 1 doc < 2/29 and < 3/01" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than">
    <term field="simple-date" str="2000-02-29" />
  </operator>
  <operator logic="less-than">
    <term field="simple-date" str="2000-03-01" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-date-good-2000/02/28")
      end

      it "should use range and <= together correctly - 1 doc in the range 2/28..3/01 and < 2/29" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than">
    <term field="simple-date" str="2000-02-29" />
  </operator>
  <operator logic="range">
    <term field="simple-date" str="2000-02-28" />
    <term field="simple-date" str="2000-03-01" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-date-good-2000/02/28")
      end

      it "should find a document containing 2 contents that wouldn't be found by a ranged search like 2008-10-12 20:49:36..2008-10-12 20:49:38, as well as the one that would" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="greater-than">
    <term field="simple-date" str="2008-10-12 20:49:36" />
  </operator>
  <operator logic="less-than">
    <term field="simple-date" str="2008-10-12 20:49:38" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(2)
      end

      it "should find a document containing 2 contents that wouldn't be found by a ranged search like 2008-10-12 20:49:36..2008-10-12 20:49:38, as well as the one that would - using >= and <=" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="greater-than-or-equal">
    <term field="simple-date" str="2008-10-12 20:49:37" />
  </operator>
  <operator logic="less-than-or-equal">
    <term field="simple-date" str="2008-10-12 20:49:37" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(2)
      end

      it "should find only one document in the range 2008-10-12 20:49:36..2008-10-12 20:49:38.  Complements the test above" do
        query_object = <<HERE
<operator logic="range">
  <term field="simple-date" str="2008-10-12 20:49:37" />
  <term field="simple-date" str="2008-10-12 20:49:37" />
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("simple-date-good-2008-10-1220:49:37")
      end
    end
  end





  context "multiple XPaths - Mutate the order of XPath expressions to ensure the same result is returned, using the simple-number data set" do
    context "< tests" do
      context "with <" do
        it "should return one document for < -1.5 and > -3.5" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than">
    <term field="simple-number" str="-1.5" />
  </operator>
  <operator logic="greater-than">
    <term field="simple-number" str="-3.5" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-2")
      end
        it "should return the same one document for those reversed" do
          query_object = <<HERE
<operator logic="and">
  <operator logic="greater-than">
    <term field="simple-number" str="-3.5" />
  </operator>
  <operator logic="less-than">
    <term field="simple-number" str="-1.5" />
  </operator>
</operator>
HERE
          answer = $xpath_source.search(query_object)
          doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-2")
        end
      end

      context "with <=" do
        it "should return two documents for < 0 and <= -1.2" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than">
    <term field="simple-number" str="0" />
  </operator>
  <operator logic="less-than-or-equal">
    <term field="simple-number" str="-1.2" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(2)
      end
        it "should return two documents for those reversed" do
          query_object = <<HERE
<operator logic="and">
  <operator logic="less-than-or-equal">
    <term field="simple-number" str="-1.2" />
  </operator>
  <operator logic="less-than">
    <term field="simple-number" str="0" />
  </operator>
</operator>
HERE
          answer = $xpath_source.search(query_object)
          doc_count(answer).should eql(2)
        end
      end

      context "with >" do
        it "should return no documents for < .5 and > 0" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than">
    <term field="simple-number" str=".5" />
  </operator>
  <operator logic="greater-than">
    <term field="simple-number" str="0" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(0)
      end
        it "should return the same one document for those reversed" do
          query_object = <<HERE
<operator logic="and">
  <operator logic="greater-than">
    <term field="simple-number" str="0" />
  </operator>
  <operator logic="less-than">
    <term field="simple-number" str=".5" />
  </operator>
</operator>
HERE
          answer = $xpath_source.search(query_object)
          doc_count(answer).should eql(0)
        end
      end

      context "with >=" do
        it "should return one document for < .5 and >= 0" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than">
    <term field="simple-number" str=".5" />
  </operator>
  <operator logic="greater-than-or-equal">
    <term field="simple-number" str="0" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-0")
      end
        it "should return the same one document for those reversed" do
          query_object = <<HERE
<operator logic="and">
  <operator logic="greater-than-or-equal">
    <term field="simple-number" str="0" />
  </operator>
  <operator logic="less-than">
    <term field="simple-number" str=".5" />
  </operator>
</operator>
HERE
          answer = $xpath_source.search(query_object)
          doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-0")
        end
      end

      context "with ==" do
        it "should return one document for < .5 and == 0" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than">
    <term field="simple-number" str=".5" />
  </operator>
  <operator logic="equal">
    <term field="simple-number" str="0" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-0")
      end
        it "should return the same one document for those reversed" do
          query_object = <<HERE
<operator logic="and">
  <operator logic="equal">
    <term field="simple-number" str="0" />
  </operator>
  <operator logic="less-than">
    <term field="simple-number" str=".5" />
  </operator>
</operator>
HERE
          answer = $xpath_source.search(query_object)
          doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-0")
        end
      end

      context "with .." do
        it "should return one document for < 1.5 and [1,2]" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than">
    <term field="simple-number" str="1.5" />
  </operator>
  <operator logic="range">
    <term field="simple-number" str="1" />
    <term field="simple-number" str="2" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-+1")
      end
        it "should return the same one document for those reversed" do
          query_object = <<HERE
<operator logic="and">
  <operator logic="range">
    <term field="simple-number" str="1" />
    <term field="simple-number" str="2" />
  </operator>
  <operator logic="less-than">
    <term field="simple-number" str="1.5" />
  </operator>
</operator>
HERE
          answer = $xpath_source.search(query_object)
          doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-+1")
        end

        it "should return no documents for < 1.5 and [1.5,2]" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than">
    <term field="simple-number" str="1.5" />
  </operator>
  <operator logic="range">
    <term field="simple-number" str="1.5" />
    <term field="simple-number" str="2" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(0)
      end
        it "should also return no documents for those reversed" do
          query_object = <<HERE
<operator logic="and">
  <operator logic="range">
    <term field="simple-number" str="1.5" />
    <term field="simple-number" str="2" />
  </operator>
  <operator logic="less-than">
    <term field="simple-number" str="1.5" />
  </operator>
</operator>
HERE
          answer = $xpath_source.search(query_object)
          doc_count(answer).should eql(0)
      end
      end
    end


    context "<= tests" do
      context "with <=" do
        it "should return one document for <= -2 and <= -2" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than-or-equal">
    <term field="simple-number" str="-2" />
  </operator>
  <operator logic="less-than-or-equal">
    <term field="simple-number" str="-2" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-2")
      end
      end
      context "with >" do
        it "should return one document for <= .5 and > 0" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than-or-equal">
    <term field="simple-number" str=".5" />
  </operator>
  <operator logic="greater-than">
    <term field="simple-number" str="0" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-+.5")
      end
        it "should return the same one document for those reversed" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="greater-than">
    <term field="simple-number" str="0" />
  </operator>
  <operator logic="less-than-or-equal">
    <term field="simple-number" str=".5" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-+.5")
        end
      end
      context "with >=" do
        it "should return one document for <= 0 and >= 0" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than-or-equal">
    <term field="simple-number" str="0" />
  </operator>
  <operator logic="greater-than-or-equal">
    <term field="simple-number" str="0" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-0")
      end
        it "should return the same one document for those reversed" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="greater-than-or-equal">
    <term field="simple-number" str="0" />
  </operator>
  <operator logic="less-than-or-equal">
    <term field="simple-number" str="0" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-0")
        end
      end
      context "with ==" do
        it "should return no documents for <= 0 and == 3" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="less-than-or-equal">
    <term field="simple-number" str="0" />
  </operator>
  <operator logic="equal">
    <term field="simple-number" str="3" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(0)
      end
        it "should return the same no documents for those reversed" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="equal">
    <term field="simple-number" str="3" />
  </operator>
  <operator logic="less-than-or-equal">
    <term field="simple-number" str="0" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(0)
        end
      end
      context "with .." do
      end
    end


    context "> tests" do
      context "with >" do
      end
      context "with >=" do
      end
      context "with ==" do
        it "should return one document for > 0 and == .5" do
        query_object = <<HERE
<operator logic="and">
  <operator logic="greater-than">
    <term field="simple-number" str="0" />
  </operator>
  <operator logic="equal">
    <term field="simple-number" str=".5" />
  </operator>
</operator>
HERE
        answer = $xpath_source.search(query_object)
        doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-+.5")
      end
        it "should return the same one document for == .5 and > 0" do
          query_object = <<HERE
<operator logic="and">
  <operator logic="equal">
    <term field="simple-number" str=".5" />
  </operator>
  <operator logic="greater-than">
    <term field="simple-number" str="0" />
  </operator>
</operator>
HERE
          answer = $xpath_source.search(query_object)
          doc_count(answer).should eql(1) and url(answer).should eql("http://vivisimo.com/simple-number-+.5")
        end
      end
      context "with .." do
      end
    end


    context ">= tests" do
      context "with >=" do
      end
      context "with ==" do
      end
      context "with .." do
      end
    end


    context "== tests" do
      context "with ==" do
      end
      context "with .." do
      end
    end


    context ".. tests" do
      context "with .." do
      end
    end
  end

  context "Range operator for simple numbers" do
    it "should test range operator on simple numbers - 2 documents between 1 and 2" do
      query_object = <<HERE
<operator logic="range">
  <term field="simple-number" str="1" />
  <term field="simple-number" str="2" />
</operator>
HERE
      answer = $xpath_source.search(query_object)
      doc_count(answer).should eql(3)
    end
  end
end
