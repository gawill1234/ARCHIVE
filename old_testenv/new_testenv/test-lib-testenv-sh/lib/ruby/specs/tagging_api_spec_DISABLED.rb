require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'velocity/collection'
require 'velocity/document'
require 'tagging_api_helper'

include Velocity

=begin
These tests make sure that tagging API users can:
* add, delete, and update basic tags
* add, delete, and update user tags
* add, delete, and update global tags
* perform these same functions with express tagging.

These tests do not cover varying any optional parameters

Assumes the presence of example-metadata (crawled or uncrawled), and a running query-service

If you'd like to see the effects of the tests, you can look at the project 'collaboration' in the qa namespace - qa/baseball
=end

describe "Tagging API" do
  context "Has variables from spec_helper.rb available" do
    before(:all) do
      @d = Document.new(@vapi, :vse_key => "#{@application_example_path}wild_horses.html/")
      vlog @d.vse_key

      ############################################
      # two documents used for tagging functionality in many of the tests below.  A key characteristic is that they are both returned for the query 'horses'
      $d = Document.new(@vapi, :vse_key => "#{@application_example_path}wild_horses.html/")
      $d2 = Document.new(@vapi, :vse_key => "#{@application_example_path}knockdown.html/")

      # a third document that is not returned for the query 'horses'
      $d3 = Document.new(@vapi, :vse_key => "#{@application_example_path}dead_cert.html/")

      # a fourth document that is returned for the query 'dead' and for the query 'horses'
      $d4 = Document.new(@vapi, :vse_key => "#{@application_example_path}under_orders.html/")

      # this is my list of documents I'll be adding to/deleting from:
      $document_nodeset = "<document vse-key=\"#{@application_example_path}wild_horses.html/\" /><document vse-key=\"#{@application_example_path}knockdown.html/\" />"

      # unless I need a smaller list:
      $small_document_nodeset = "<document vse-key=\"#{@application_example_path}wild_horses.html/\" />"

      Collection.new(@vapi, 'example-metadata').clean_crawl
    end
    
    # this is my query I'll be adding to/deleting from:
    query_nodeset = <<-HERE
    <query>
      <operator logic="and">
        <term field="query" str="horses"/>
      </operator>
    </query>
    HERE

    # unless I need a different one that overlaps slightly and has d3
    query_nodeset_dead = <<-HERE
    <query>
      <operator logic="and">
        <term field="query" str="dead"/>
      </operator>
    </query>
    HERE

    #This was long enough for me.  2 was too short sometimes.  You may need to adjust
    wait_for_express_tagging = 3

    context "Basic tagging" do
      it "should add a tag (hello world) to one document in example-metadata collection" do
        vlog "\nadd tag (hello world!)\n******"
        content_nodeset = "<content name=\"tags\">hello world!</content>"
        @d.add_annotation(content_nodeset)
        tag(@d).should eql("hello world!")
      end
     
      it "should update a tag (hello world! -> hello test-all!) on one document in example-metadata collection" do
        vlog "\nupdate tag (hello world! -> hello test-all!)\n******"
        content_nodeset = "<content name=\"tags\">hello test-all!</content>"
        id = content_id($d, "//content[@name='tags'][text() = 'hello world!']")
        $d.update_annotation(content_nodeset, id)
        tag($d).should eql("hello test-all!")
        count($d).should eql(1)
      end
      
      it "should attempt to delete a tag as a different user" do
        vlog "\ndelete tag (but fail)\n******"
        id = content_id($d, "//content[@name='tags' and text() = 'hello test-all!']")
        $d.delete_annotation('tags', id, "test1")
        count($d).should eql(1)
      end

      it "should delete a tag (hello test-all!) from one document in example-metadata collection" do
        vlog "\ndelete tag (hello test-all!)\n******"
        id = content_id($d, "//content[@name='tags' and text() = 'hello test-all!']")
        $d.delete_annotation('tags', id)
        count($d).should eql(0)
      end
    end



    context "User tagging" do
      it "should add a user tag (value1) to one document with user test-all" do
        vlog "\nadd user tag (value1)\n******"
        content_nodeset = "<content name=\"tags\">value1</content>"
        $d.add_one_annotation_per_user(content_nodeset)
        count($d).should eql(1)
        tag($d).should eql("value1")
        user($d).should eql('test-all')
      end

      it "should add a user tag (value2) to the same document with same user test-all.  Value2 should overwrite value1" do
        vlog "\nadd user tag (value2)\n******"
        content_nodeset = "<content name=\"tags\">value2</content>"
        $d.add_one_annotation_per_user(content_nodeset)
        count($d).should eql(1)
        tag($d).should eql("value2")
        user($d).should eql("test-all")
      end

      # test adding two tags with different values and different users
      it "should add a user tag (value3) to the same document with user test2.  Both value2 and value3 should still be there." do
        vlog "\nadd other user tag (value3)\n******"
        content_nodeset = "<content name=\"tags\">value3</content>"
        $d.add_one_annotation_per_user(content_nodeset, 'test2')
        xml = $d.get_xml
        #tag_test_all = xml.elements["//content[@name='tags' and @modified-by='test-all']"].text
        tag_test_all = xml.xpath("//content[@name='tags' and @modified-by='test-all']").text
        #tag_test2 = xml.elements["//content[@name='tags' and @modified-by='test2']"].text
        tag_test2 = xml.xpath("//content[@name='tags' and @modified-by='test2']").text
        count($d).should eql(2)
        tag_test_all.should eql("value2")
        tag_test2.should eql("value3")
      end

      #note that in order to delete user/global tags, you have to call the same function you used to add them, but with an empty content.  The delete function will not work.
      # test deleting tag with different value, different user
      it "should clean up test-all's user tags properly" do
        vlog "\nClean up user tags\n*****"
        content_nodeset = "<content name=\"tags\"></content>"
        $d.add_one_annotation_per_user(content_nodeset)
        count($d).should eql(1)
      end
      
      # test adding two tags with same values but different users
      it "should add a user tag (value3) to the same document with user test-all.  Two copies of value3 should still be there - one for test-all and one for test2." do
        vlog "\nadd other user tag (value3)\n******"
        content_nodeset = "<content name=\"tags\">value3</content>"
        $d.add_one_annotation_per_user(content_nodeset)
        xml = $d.get_xml
        #tag_test_all = xml.elements["//content[@name='tags' and @modified-by='test-all']"].text
        tag_test_all = xml.xpath("//content[@name='tags' and @modified-by='test-all']").text
        #tag_test2 = xml.elements["//content[@name='tags' and @modified-by='test2']"].text
        tag_test2 = xml.xpath("//content[@name='tags' and @modified-by='test2']").text
        count($d).should eql(2)
        tag_test_all.should eql("value3")
        tag_test2.should eql("value3")
      end

      # test deleting same tag values per user.
      it "should clean up all user tags properly, first test-all's, then test2's." do
        vlog "\nClean up user tags\n*****"
        content_nodeset = "<content name=\"tags\"></content>"
        $d.add_one_annotation_per_user(content_nodeset)
        test2_count = count($d)
        $d.add_one_annotation_per_user(content_nodeset, "test2")
        count($d).should eql(0)
        test2_count.should eql(1)
      end
    end



    context "Global tagging" do
      it "should add a global tag (gvalue1) to a document with user test-all" do
        vlog "\nadd global tag (gvalue1)\n******"
        content_nodeset = "<content name=\"tags\">gvalue1</content>"
        $d.add_one_annotation_per_doc(content_nodeset)
        count($d).should eql(1)
        tag($d).should eql("gvalue1")
        user($d).should eql("test-all")
      end

      it "should add a global tag (gvalue2) to the same document with user test2.  gvalue2 should overwrite gvalue1." do
        vlog "\nadd global tag (gvalue2)\n******"
        content_nodeset = "<content name=\"tags\">gvalue2</content>"
        $d.add_one_annotation_per_doc(content_nodeset, "test2")
        count($d).should eql(1)
        tag($d).should eql("gvalue2")
        user($d).should eql("test2")
      end

      #note that in order to delete user/global tags, you have to call the same function you used to add them, but with an empty content.  The delete function will not work.  Also note that user does not matter.
      it "should clean up global tags on one document properly, regardless of user.  Test deleting with user test3." do
        vlog "\nClean up global tag\n*****"
        content_nodeset = "<content name=\"tags\"></content>"
        $d.add_one_annotation_per_doc(content_nodeset, "test3")
        count($d).should eql(0)
      end
    end


    
    context "Basic express tagging" do
      context "With document lists" do
        it "should add a single tag (evalue1) to several documents" do
          vlog "\nexpress tag (evalue1)\n******"
          content_nodeset = "<content name=\"tags\">evalue1</content>"
          $d.add_annotation_to_multiple_docs(content_nodeset, $document_nodeset)
          count($d).should eql(1)
          count($d2).should eql(1)
          tag($d).should eql("evalue1")
          tag($d2).should eql("evalue1")
        end

        it "should try to delete a non-existent tag from several documents.  Nothing should actually be deleted." do
          vlog "\nexpress tag-delete (evalue2)\n******"
          content_nodeset = "<content name=\"tags\">evalue2</content>"
          $d.delete_annotation_from_multiple_docs(content_nodeset, $document_nodeset)
          count($d).should eql(1)
          count($d2).should eql(1)
          tag($d).should eql("evalue1")
          tag($d2).should eql("evalue1")
        end
        
        it "should update a tag on several documents using generic old content.  evalue1 -> evalue1b" do
          vlog "\nexpress tag-update (evalue1 -> evalue1b)\n******"
          content_nodeset = "<content name=\"tags\">evalue1b</content>"
          old_content = "<content name=\"tags\" />"
          $d.annotation_express_update_doc_list(content_nodeset, old_content, $document_nodeset)
          count($d).should eql(1)
          count($d2).should eql(1)
          tag($d).should eql("evalue1b")
          tag($d2).should eql("evalue1b")
        end
        
        it "should update a tag on several documents using specifically valued old content.  evalue1b -> evalue1c" do
          vlog "\nexpress tag-update (evalue1b -> evalue1c)\n******"
          content_nodeset = "<content name=\"tags\">evalue1c</content>"
          old_content = "<content name=\"tags\">evalue1b</content>"
          $d.annotation_express_update_doc_list(content_nodeset, old_content, $document_nodeset)
          count($d).should eql(1)
          count($d2).should eql(1)
          tag($d).should eql("evalue1c")
          tag($d2).should eql("evalue1c")
        end
        
        it "should try to update a tag on several documents using specifically valued old content.  However, that old content does not have that value.  Document should not be re-tagged." do
          vlog "\nexpress tag-update (evalue1c -> evalue1d)\n******"
          content_nodeset = "<content name=\"tags\">evalue1d</content>"
          old_content = "<content name=\"tags\">not this value</content>"
          $d.annotation_express_update_doc_list(content_nodeset, old_content, $small_document_nodeset)
          count($d).should eql(1)
          tag($d).should eql("evalue1c")
        end

        it "should actually delete a tag from several documents" do
          vlog "\nexpress tag-delete (evalue1)\n******"
          content_nodeset = "<content name=\"tags\">evalue1c</content>"
          $d.delete_annotation_from_multiple_docs(content_nodeset, $document_nodeset)
          count($d).should eql(0)
          count($d2).should eql(0)
        end
      end


      context "With queries" do
        it "should add a single tag (evalue2) to all documents returned for the query horses.  Check $d and $d2.  Documents not returned for that query should not be tagged - check $d3" do
          vlog "\nexpress tag (evalue2)\n******"
          content_nodeset = "<content name=\"tags\">evalue2</content>"
          $d.add_annotation_for_query(content_nodeset, query_nodeset)
          #have to wait for express tagging to finish.
          sleep wait_for_express_tagging
          count($d).should eql(1)
          count($d2).should eql(1)
          count($d3).should eql(0)
          tag($d).should eql("evalue2")
          tag($d2).should eql("evalue2")
        end

        it "Setup - Should add another tag (evalue3) to $d.  $d has evalue2 and evalue3" do
          content_nodeset = "<content name=\"tags\">evalue3</content>"
          $d.add_annotation(content_nodeset)
          count($d).should eql(2)
        end
        
        it "should add another tag (evalue2) to $d3.  $d3 has evalue2" do
          content_nodeset = "<content name=\"tags\">evalue2</content>"
          $d3.add_annotation(content_nodeset)
          count($d3).should eql(1)
        end

        # delete by tag value
        it "should delete a single tag (evalue2) from all documents returned for the query 'horses'.  Check $d and $d2 for deletion and $d3 for non-deletion.  $d has evalue3, $d3 has evalue2" do
          vlog "\nexpress tag-delete (evalue2)\n******"
          content_nodeset = "<content name=\"tags\">evalue2</content>"
          $d.delete_annotation_for_query(content_nodeset, query_nodeset)
          sleep wait_for_express_tagging
          count($d).should eql(1)
          count($d2).should eql(0)
          tag($d).should eql("evalue3")
          count($d3).should eql(1)
        end
        
        # delete by tag without value
        it "should clean up further by deleting all possible values for that query - but not for things outside of that query.  $d and $d2 have no tags, $d3 has evalue2" do
          vlog "\nexpress tag-delete (all for query)\n******"
          content_nodeset = "<content name=\"tags\" />"
          $d.delete_annotation_for_query(content_nodeset, query_nodeset)
          sleep wait_for_express_tagging
          count($d).should eql(0)
          count($d2).should eql(0)
          count($d3).should eql(1)
        end
        
        # delete by tag without value and with blank query
        it "should finish cleaning up by deleting all possible values for a null query" do
          vlog "\nexpress tag-delete (all)\n******"
          null_query_nodeset = "<query><operator logic=\"and\" /></query>"
          content_nodeset = "<content name=\"tags\" />"
          $d.delete_annotation_for_query(content_nodeset, null_query_nodeset)
          sleep wait_for_express_tagging
          count($d).should eql(0)
          count($d2).should eql(0)
          count($d3).should eql(0)
        end
        
        context "Updating with queries" do
          it "should add two different tags to a query, then run an update with a third.  Each document for the query should have the tag 'updated'" do
            content_nodeset = "<content name=\"tags\">update me!</content>"
            $d.add_annotation_for_query(content_nodeset, query_nodeset)
            content_nodeset = "<content name=\"tags\">update me, too!</content>"
            $d.add_annotation_for_query(content_nodeset, query_nodeset)
            #have to wait for express tagging to finish.
            sleep wait_for_express_tagging
            content_nodeset = "<content name=\"tags\">updated</content>"
            old_content = "<content name=\"tags\" />"
            $d.annotation_express_update_query(content_nodeset, old_content, query_nodeset)
            #have to wait for express tagging to finish.
            sleep wait_for_express_tagging
            count($d).should eql(1)
            count($d2).should eql(1)
            tag($d).should eql("updated")
            tag($d2).should eql("updated")
          end
          
          it "should add a different tag to a different, but slightly overlapping query.  d1 and $d2 should be 'updated', $d3 and $d4 should be 'overlap'" do
            $d4_tag_before_new_tag = tag($d4)
            content_nodeset = "<content name=\"tags\">overlap</content>"
            old_content = "<content name=\"tags\" />"
            $d.annotation_express_update_query(content_nodeset, old_content, query_nodeset_dead)
            #have to wait for express tagging to finish.
            sleep wait_for_express_tagging
            count($d).should eql(1)
            count($d2).should eql(1)
            count($d3).should eql(1)
            count($d4).should eql(1)
            $d4_tag_before_new_tag.should eql("updated")
            tag($d).should eql("updated")
            tag($d2).should eql("updated")
            tag($d3).should eql("overlap")
            tag($d4).should eql("overlap")
          end
          
          it "should clean up from updating" do
            vlog "\nexpress tag-delete (all)\n******"
            null_query_nodeset = "<query><operator logic=\"and\" /></query>"
            content_nodeset = "<content name=\"tags\" />"
            $d.delete_annotation_for_query(content_nodeset, null_query_nodeset)
            sleep wait_for_express_tagging
            count($d).should eql(0)
            count($d2).should eql(0)
            count($d3).should eql(0)
            count($d4).should eql(0)
          end
        end
      end
    end
    
    
    
    context "Deletion by user who did not set tag in first place" do
      #tests for user adding a tag and then another user trying to delete it - normal tagging (covered by other tests)
      # For normal tags, 'normal' deleting should not work unless you are the original user (see "should attempt to delete a tag as a different user").
      # For user tags, 'normal' deleting is just resetting to blank.  Other users should not be able to delete your user tags. (see "should clean up all user tags properly, first test-all's, then test2's.")
      # For global tags, 'normal' deleting is also resetting to blank.  Anyone should be able to reset a tag (see "should clean up global tags on one document properly, regardless of user.  Test deleting with user test3.")
      
      #tests for user adding a tag and then another user trying to delete it - express tagging
      # For normal tags, express deleting should only work on your personal tags.  See below.
      # For user tags, express deleting is just resetting to blank.  Other users should not be able to delete your user tags.  (see "should express delete the user tags from the same listed documents, first test-all's, then test2's.")
      # For global tags, express deleting is also resetting to blank.  Anyone should be able to reset a tag (see "should delete all tags with document list (also tests other user express deleting global tag)")
      
      # normal tags, express deleting
      it "should add a tag as user test-all and attempt to express delete it by doc list as user test2.  The tag should still be there.  Clean up." do
        content_nodeset = "<content name=\"tags\">normal-tag-to-be-deleted</content>"
        $d.add_annotation(content_nodeset)
        tag_before_deletion = tag($d)
        content_nodeset = "<content name=\"tags\" />"
        $d.delete_annotation_from_multiple_docs(content_nodeset, $small_document_nodeset, "test2")
        count_after_failed_delete = count($d)
        user_after_failed_delete = user($d)
        $d.delete_annotation_from_multiple_docs(content_nodeset, $small_document_nodeset)
        tag_before_deletion.should eql("normal-tag-to-be-deleted")
        count_after_failed_delete.should eql(1)
        user_after_failed_delete.should eql("test-all")
        count($d).should eql(0)
      end
    end



    context "Global express tagging" do
      context "With document list" do
        it "should add a single global tag (evalue3) to several listed documents.  Check $d and $d2." do
          vlog "\nexpress tag per doc (evalue3)\n******"
          content_nodeset = "<content name=\"tags\">evalue3</content>"
          $d.add_one_annotation_per_doc_to_multiple_docs(content_nodeset, $document_nodeset)
          count($d).should eql(1)
          count($d2).should eql(1)
          tag($d).should eql("evalue3")
          tag($d2).should eql("evalue3")
        end

        it "should add another single global tag (evalue4) to the same listed documents as user test2.  evalue4 should overwrite evalue3.  The user should change." do
          vlog "\nexpress tag per doc (evalue4)\n******"
          content_nodeset = "<content name=\"tags\">evalue4</content>"
          $d.add_one_annotation_per_doc_to_multiple_docs(content_nodeset, $document_nodeset, "test2")
          count($d).should eql(1)
          count($d2).should eql(1)
          tag($d).should eql("evalue4")
          tag($d2).should eql("evalue4")
          user($d).should eql("test2")
          user($d2).should eql("test2")
        end

        it "should delete all tags with document list (also tests other user express deleting global tag)" do
          content_nodeset = "<content name=\"tags\" />"
          $d.add_one_annotation_per_doc_to_multiple_docs(content_nodeset, $document_nodeset, "test3")
          count($d).should eql(0)
        end
      end
      
      
      context "With queries" do
        it "should express add a global tag (express global query) to some documents returned for a query as user test-all.  Check $d and $d2 for tag, check $d3 for lack of tag" do
          content_nodeset = "<content name=\"tags\">express global query</content>"
          $d.add_one_annotation_per_doc_to_query(content_nodeset, query_nodeset)
          sleep wait_for_express_tagging
          count($d).should eql(1)
          count($d2).should eql(1)
          count($d3).should eql(0)
          tag($d).should eql("express global query")
          user($d).should eql("test-all")
        end
        
          it "should express add a different global tag (express global query 2) to some documents returned for a query as user test2.  express global query 2 should overwrite express global query.  User should change.  $d3 should remain untagged." do
          content_nodeset = "<content name=\"tags\">express global query 2</content>"
          $d.add_one_annotation_per_doc_to_query(content_nodeset, query_nodeset, "test2")
          sleep wait_for_express_tagging
          count($d).should eql(1)
          count($d2).should eql(1)
          count($d3).should eql(0)
          tag($d).should eql("express global query 2")
          user($d).should eql("test2")
        end
        
        it "should express clean up global tags by query as user 3." do
          content_nodeset = "<content name=\"tags\" />"
          $d.add_one_annotation_per_doc_to_query(content_nodeset, query_nodeset, "test3")
          sleep wait_for_express_tagging
          count($d).should eql(0)
          count($d2).should eql(0)
          count($d3).should eql(0)
        end
      end
    end


    
    context "User express tagging" do
      context "With document lists" do
        it "should express add a user tag (express user list) to some listed documents as user test-all.  Check $d and $d2 for tags, check $d3 for lack of tag." do
          content_nodeset = "<content name=\"tags\">express user list</content>"
          $d.add_one_annotation_per_user_to_multiple_docs(content_nodeset, $document_nodeset)
          count($d).should eql(1)
          count($d2).should eql(1)
          count($d3).should eql(0)
          tag($d).should eql("express user list")
          user($d).should eql("test-all")
        end
        
        it "should express add the same user tag (express user list) to the same listed documents as user test2.  Both values should be present on $d and $d2, not on $d3." do
          content_nodeset = "<content name=\"tags\">express user list</content>"
          $d.add_one_annotation_per_user_to_multiple_docs(content_nodeset, $document_nodeset, "test2")
          count($d).should eql(2)
          count($d2).should eql(2)
          count($d3).should eql(0)
        end
        
        it "should express delete the user tags from the same listed documents, first test-all's, then test2's." do
          content_nodeset = "<content name=\"tags\" />"
          $d.add_one_annotation_per_user_to_multiple_docs(content_nodeset, $document_nodeset)
          countd = count($d)
          countd2 = count($d2)
          $d.add_one_annotation_per_user_to_multiple_docs(content_nodeset, $document_nodeset, "test2")
          countd.should eql(1)
          countd2.should eql(1)
          count($d).should eql(0)
          count($d2).should eql(0)
          count($d3).should eql(0)
        end
      end
    
      
      context "With queries" do
        it "should express add a user tag (express user query) to documents returned for a query" do
          content_nodeset = "<content name=\"tags\">express user query</content>"
          $d.add_one_annotation_per_user_to_query(content_nodeset, query_nodeset)
          sleep wait_for_express_tagging
          count($d).should eql(1)
          count($d2).should eql(1)
          count($d3).should eql(0)
          tag($d).should eql("express user query")
          user($d).should eql("test-all")
        end
      end
    end
  end
end
