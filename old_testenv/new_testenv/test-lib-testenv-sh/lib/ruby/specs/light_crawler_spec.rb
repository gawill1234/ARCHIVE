require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'light_crawler_helper'

describe "Light Crawler" do
  before(:all) do
    @original_data = create_original_data
    @additional_data = create_additional_data
    @collections = {"light" => "test-light-crawler", "heavy" => "test-light-crawler-heavy"}
    @collections.each_value {|value| light_crawler_test_setup(value) }
    @light_crawler = Velocity::Collection.new(@vapi, @collections["light"])
    @status_query_result = ""
    @enqueue_response = ""
  end

  context "[status-all]" do

    it "should get the status for all URLs from the light collection" do

      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "*"}])
      @status_query_result = status_query(@collections["light"], input)

      crawl_url_count.should eql(2)

      status_of("url_error_nonexistent").should eql("error")
      error_id("url_error_nonexistent").should eql("CRAWLER_FS_OPERATION")
      status_of("url_error_no_permissions").should eql("error")
      error_id("url_error_no_permissions").should eql("CRAWLER_CONNECTOR_CRAWL")
      get_status_node("url_crawled").should be_empty
      get_status_node("url_manual").should be_empty
      get_status_node("url_to_be_deleted").should be_empty

    end

    it "should get the status for all URLs from the heavy collection" do

      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "*"}])
      @status_query_result = status_query(@collections["heavy"], input)

      crawl_url_count.should eql(5)
      crawl_url_count(".//error").should eql(2)

      get_status_node("url_crawled").should_not be_empty

    end

  end

  context "[status-bad-url]" do

    it "should get the status for a URL with an error" do

      input = create_crawl_url_status([{:name => "url", :comparison => "eq", :value => get_url("url_error_nonexistent")}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(1)
        get_status_node("url_error_nonexistent").should_not be_empty
      }

    end

  end

  context "[status-non-url]" do

    it "should not be able to get the status of a URL that was not enqueued" do

      input = create_crawl_url_status([{:name => "url", :comparison => "eq", :value => "file:///no-such-url-enqueued"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*").should be_empty
      }

    end

  end

  # TODO: Mark this test as one that takes a long time; conditionally run?
  context "[status-pending]" do

    it "should get a crawl_url from the light crawler while pending and not get one when the enqueue is finished" do

      input = create_crawl_url_status([{:name => "url", :comparison => "eq", :value => get_url("url_takes_time_to_crawl")}])
  
      @collections.each_value {|value|
        light_crawler_enqueue_url(value, "url_takes_time_to_crawl")
        @status_query_result = status_query(value, input)

        crawl_url_count.should eql(1)
        status_of("url_takes_time_to_crawl").should be_empty
        error_count.should eql(0)

        vc = Velocity::Collection.new(@vapi, value)
        vc.wait_for_crawl("live", 1, true)

        @status_query_result = status_query(value, input)

        if (!value.match(/-heavy$/))
          crawl_url_count.should eql(0)
          @status_query_result.xpath("//crawl-url-status-response/*").should be_empty
        else
          crawl_url_count.should eql(1)
          status_of("url_takes_time_to_crawl").should eql("complete")
          error_count.should eql(0)
        end
        light_crawler_delete_url(value, "url_takes_time_to_crawl")
      }
    end

  end

  context "[status-error]" do

    it "should get the status for all URLs that have an error" do

      input = create_crawl_url_status([{:name => "error", :comparison => "wc", :value => "*"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(2)
        crawl_url_count(".//error").should eql(2)
        error_count.should eql(4)
        error_count("@id='CRAWLER_FS_OPERATION'").should eql(1)
        error_count("@id='CONVERTER_NO_RULE'").should eql(2)
        error_count("@id='CRAWLER_CONNECTOR_CRAWL'").should eql(1)
      }

    end

  end

  context "[status-specific-error]" do

    it "should get the status for all URLs that have a specific error (using eq)" do

      input = create_crawl_url_status([{:name => "error", :comparison => "eq", :value => "CRAWLER_FS_OPERATION"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(1)
        error_id("url_error_nonexistent").should eql("CRAWLER_FS_OPERATION")
      }

    end

  end

  context "[status-not-specific-error]" do

    it "should get the status for all URLs that do not have a specific error from the light collection" do

      input = create_crawl_url_status([{:name => "error", :comparison => "neq", :value => "CRAWLER_FS_OPERATION"}, 
                                       {:name => "error", :comparison => "neq", :value => "CONVERTER_NO_RULE"}])

      
      @status_query_result = status_query(@collections["light"], input)
      crawl_url_count.should eql(1)
      error_id("url_error_no_permissions").should_not eql("CRAWLER_FS_OPERATION")

    end

    it "should get the status for all URLs that do not have a specific error from the heavy collection" do

     pending "bug 18491" do

      input = create_crawl_url_status([{:name => "error", :comparison => "neq", :value => "CRAWLER_FS_OPERATION"}, 
                                       {:name => "error", :comparison => "neq", :value => "CONVERTER_NO_RULE"}])

      
      @status_query_result = status_query(@collections["heavy"], input)
      crawl_url_count.should eql(5)
      get_status_node("url_error_nonexistent").should be_empty

     end

    end

  end

  context "[status-deleted]" do 

    it "should get the status for a URL that has been deleted that was complete" do

      input = create_crawl_url_status([{:name => "url", :comparison => "eq", :value => get_url("url_to_be_deleted")}])
  
      @collections.each_value {|value|
        light_crawler_delete_url(value, "url_to_be_deleted")
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*").should be_empty
        light_crawler_enqueue_url(value, "url_to_be_deleted")
      }

    end

  end

  context "[status-purged]" do

    it "should not get the status for a URL that has been purged from the light collection" do

      input = create_crawl_url_status([{:name => "url", :comparison => "eq", :value => get_url("url_manual")}])

      @status_query_result = status_query(@collections["light"], input)
      crawl_url_count.should eql(0)
      @status_query_result.xpath("//crawl-url-status-response/*").should be_empty

    end

    it "should get the status for a URL that has been purged from the heavy collection" do

      input = create_crawl_url_status([{:name => "url", :comparison => "eq", :value => get_url("url_manual")}])

      @status_query_result = status_query(@collections["heavy"], input)
      crawl_url_count.should eql(1)
      status_of("url_manual").should eql("complete")

    end

  end

  context "[status-all-times]" do

    it "should not be able to get url status using time and wc" do

      input = create_crawl_url_status([{:name => "time", :comparison => "wc", :value => "*"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*").should be_empty
      }

    end

  end

  context "[status-newer-than]" do

    it "should get the status for all URLs newer than a date" do
     pending "datetime" do
      false.should be_true
     end
    end

  end

  context "[status-older-than-or-equal]" do

    it "should get the status for all URLs older than a date" do
     pending "datetime" do
      false.should be_true
     end
    end

  end
  context "[status-time-comparison-no-result-bad-range]" do

    it "should not return statuses when given a range that contains no time" do

      input = create_crawl_url_status([{:name => "time", :comparison => "gt", :value => "2009-07-31T15:47:35-04:00"},
                                       {:name => "time", :comparison => "lt", :value => "2009-07-31T15:47:35-04:00"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*").should be_empty
      }

    end

  end

  context "[status-time-comparison-no-result]" do

    it "should not return statuses when given a range during which no URLs were enqueued" do

      input = create_crawl_url_status([{:name => "time", :comparison => "lt", :value => "2002-07-31T15:47:35-04:00"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*").should be_empty
      }


    end

  end

  context "[urls-matching]" do

    it "should get the status for all URLs matching a wildcard from the light collection" do

      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "smb://*doc*"}])
      @status_query_result = status_query(@collections["light"], input)
      crawl_url_count.should eql(1)
      @status_query_result.xpath("//crawl-url/@url").to_s.should match(/smb:\/\/.*doc.*/)

    end

    it "should get the status for all URLs matching a wildcard from the heavy collection" do

      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "smb://*doc*"}])
      @status_query_result = status_query(@collections["heavy"], input)
      crawl_url_count.should eql(3)
      @status_query_result.xpath("//crawl-url/@url").each {|n|
        n.to_s.should match(/smb:\/\/.*doc.*/)
      }

    end

  end

  context "[urls-matching-false-%]" do

    it "should fail to fool wildcard matching by using %" do

      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "%"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*").should be_empty
      }

    end

  end

  context "[urls-matching-false-_]" do

    it "should fail to fool wildcard matching by using _" do
      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "_*"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*").should be_empty
      }

    end

  end

  context "[urls-matching-no-result]" do

    it "should not get any statuses when using a wildcard that has no matches" do
    
      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "*jean*"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*").should be_empty
      }


    end

  end
  context "[status-first] and [status-second]" do

    it "should get different URLs using the limit and offset attributes" do
    
      input_first = create_crawl_url_status([{:name => "error", :comparison => "wc", :value => "*"}], "and", 1, 0)
      input_second = create_crawl_url_status([{:name => "error", :comparison => "wc", :value => "*"}], "and", 1, 1)

      @collections.each_value {|value|
        result_first = status_query(value, input_first)
        result_second = status_query(value, input_second)
       
        (result_first.xpath("//crawl-url/@url").to_s.eql?(get_url("url_error_nonexistent")) || result_first.xpath("//crawl-url/@url").to_s.eql?(get_url("url_error_no_permissions"))).should be_true

        if result_first.xpath("//crawl-url/@url").to_s.eql?(get_url("url_error_nonexistent"))
          result_second.xpath("//crawl-url/@url").to_s.should eql(get_url("url_error_no_permissions"))
        elsif result_first.xpath("//crawl-url/@url").to_s.eql?(get_url("url_error_no_permissions"))
          result_second.xpath("//crawl-url/@url").to_s.should eql(get_url("url_error_nonexistent"))
        end
      }
    end

  end

  context "[or-operator]" do

    it "should get the status for some URLs using the 'or' operator" do

      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "#{get_url("url_manual")}/"},
                                       {:name => "url", :comparison => "eq", :value => get_url("url_error_nonexistent")}], "or")

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(1)
        get_status_node("url_error_nonexistent").should_not be_empty

      }
    end

  end

  context "[not-operator]" do

    it "should get the status for some URLs using the 'not' operator" do
     pending "bug 18898, implementation of the 'not' operator" do
      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "*"}], "not")

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*|//crawl-url-status-response/@error").should be_empty
      }
     end
    end

  end

  context "[status-all-error-states]" do

    it "should try to get the status for all URLs using error-state and wc" do
      input = create_crawl_url_status([{:name => "error-state", :comparison => "wc", :value => "*"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*|//crawl-url-status-response/@error").should be_empty
      }

    end

  end

  context "[error-state-filter-regular]" do

    it "should get the status for a URL with a regular error" do
      input = create_crawl_url_status([{:name => "error-state", :comparison => "eq", :value => "0"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(2)
      }
    end

  end

  context "[error-state-filter-warning]" do

    it "should get the status for a URL with a warning" do
     pending "a way to generate a URL with a warning (bug 19855 comments #9 and #29)" do
      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "*/failure"}])
      @collections.each_value {|value|

        # remove the fallback converter to create something in a warning state
        light_crawler_remove_fallback_converter(value)

        # url_warning has two <crawl-data> nodes beneath it, which should cause a warning
        # but it doesn't because of the issue detailed in bug 19855 comments #9 and #29.
        light_crawler_enqueue_url(value, "url_warning")

        @status_query_result = status_query(value, input)

        crawl_url_count.should eql(1)
        
        # this test will fail until the issue in bug bug 19855 comments #9 and #29 is fixed
        @status_query_result.xpath("//crawl-url[@warning='warning']").should_not be_empty

        # this is actually testing the querying for urls with warnings,
        # but until we get a way to generate a warning consistently, we can't really test this.
        input = create_crawl_url_status([{:name => "error-state", :comparison => "eq", :value => "2"}])
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(1)

        # get rid of the url
        light_crawler_delete_url(value, "url_warning")

        # put back the fallback converter
        light_crawler_replace_fallback_converter(value)
      }
     end
    end

  end

  context "[status-deleted-error]" do

    it "should get the status a URL that has been deleted that *was* an error" do
      input = create_crawl_url_status([{:name => "url", :comparison => "eq", :value => get_url("url_error_nonexistent")}])
  
      @collections.each_value {|value|
        light_crawler_delete_url(value, "url_error_nonexistent")
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*|//crawl-url-status-response/@error").should be_empty
        light_crawler_enqueue_url(value, "url_error_nonexistent")
      }

    end

  end

  context "[invalid-query]" do

    it "should not get the status for any URLs when the query is improperly formed" do
      input = create_crawl_url_status([{:name => "url", :comparison => "seq", :value => get_url("url_error_nonexistent")}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/@error").to_s.should eql("invalid")
      }

    end

  end

  context "[inaccessible-database]" do

    it "should fail to get the status for any URLs because the database is inaccessible" do
      pending "learning how to do file permission manipulation in ruby" do
        false.should be_true
      end
    end

  end

  context "[sql-injection]" do

    it "should attempt to use SQL delete with URL condition of \";DELETE FROM crawled;\"" do
      input = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => ";DELETE FROM crawled;"}])

      @collections.each_value {|value|
        @status_query_result = status_query(value, input)
        crawl_url_count.should eql(0)
        @status_query_result.xpath("//crawl-url-status-response/*|//crawl-url-status-response/@error").should be_empty

        # make sure everything is still there
        input_check = create_crawl_url_status([{:name => "url", :comparison => "wc", :value => "*"}])
        @status_query_result = status_query(value, input_check)
        if (!value.match(/-heavy$/))
          crawl_url_count.should eql(2)
        else
          crawl_url_count.should eql(5)
        end
      }

    end

  end

  context "[option-enqueue-input-threshold]" do

    it "should set different values for enqueue-input-threshold and test correctness" do

      # -1 under
      @light_crawler.add_curl_option(Nokogiri::XML("<curl-option name=\"enqueue-input-threshold\">-1</curl-option>"))
      @enqueue_response = light_crawler_enqueue_xml(@light_crawler.name, "url_1")
      num_success.should eql(1)
      num_failed.should eql(0)
      light_crawler_delete_url(@light_crawler.name, "url_1")

      # 0 under
      @enqueue_response = @vapi.search_collection_enqueue_xml({:collection => @light_crawler.name, :crawl_nodes => "<crawl-urls />"})
      num_success.should eql(0)
      num_failed.should eql(0)

      # 0 over
      @light_crawler.add_curl_option(Nokogiri::XML("<curl-option name=\"enqueue-input-threshold\">0</curl-option>"))
      @enqueue_response = light_crawler_enqueue_xml(@light_crawler.name, "url_1")
      num_success.should eql(1)
      num_failed.should eql(0)
      light_crawler_delete_url(@light_crawler.name, "url_1")


    end

  end

=begin
  context "[]" do

    it "should " do

    end

  end
=end
end