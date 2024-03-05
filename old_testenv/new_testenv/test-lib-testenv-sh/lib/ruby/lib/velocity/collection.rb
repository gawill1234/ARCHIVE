module Velocity
  class Collection
    attr_reader :name

    def initialize(vapi, collection_name)
      @vapi = vapi
      @name = collection_name
    end

    def create(based_on = 'default')
      @vapi.search_collection_create({ :collection => @name,
                                       :based_on => based_on })
    end

    def get_config
      @vapi.search_collection_xml({:collection => @name})
    end

    def fix_path(path)
      # If it looks like we have a Windows path,
      if path[/^[A-Za-z]:\\/]
        # fixup any Unix-like slashes.
        path.split('/').join('\\')
      else
        path
      end
    end

    def filebase
      fix_path(get_config.xpath('/vse-collection/@filebase').to_s)
    end

    def crawl_path_list
      # Return an array of two: [live-crawl-dir, staging-crawl-dir]
      meta = '/vse-collection/vse-meta/vse-meta-info'
      xml = get_config
      live = xml.xpath(meta+'[@name="live-crawl-dir"]')
      if live
        live = live.text
      else
        live = filebase + '/crawl1'
      end
      staging = xml.xpath(meta+'[@name="staging-crawl-dir"]')
      if staging
        staging = staging.text
      else
        staging = filebase + '/crawl0'
      end
      [fix_path(live), fix_path(staging)]
    end

    def set_config(new_xml)
      @vapi.search_collection_set_xml({:collection => @name, :xml => new_xml})
      @vapi.search_collection_update_configuration({:collection => @name})
    end

    # Add configuration child nodes
    def add_seed(seed_xml)
      curr_xml = get_config
      curr_xml.xpath("/vse-collection/vse-config/crawler").first.add_child seed_xml.root
      set_config(curr_xml)
    end

    def add_curl_option(curl_option_xml)
      curr_xml = get_config
      if curr_xml.xpath("/vse-collection/vse-config/crawler/crawl-options").empty?
        crawl_options = Nokogiri::XML "<crawl-options />"
        curr_xml.xpath("/vse-collection/vse-config/crawler").first.add_child crawl_options.root
      end
      curr_xml.xpath("/vse-collection/vse-config/crawler/crawl-options").first.add_child curl_option_xml.root
      set_config(curr_xml)
    end

    def add_ccs_collection_seeds(domain_collection, dictionary_path)
      xml = get_config
      xml.xpath("//call-function[@name='vse-crawler-seed-ccs-collection']").remove
      seeds =  Nokogiri::XML "<call-function name=\"vse-crawler-seed-ccs-collection\" type=\"crawl-seed\"><with name=\"domain-collection\">#{domain_collection}</with><with name=\"dictionary\"><value-of-var name=\"install-dir\" realm=\"option\" />/data/dictionaries/#{dictionary_path}/wildcard.dict</with></call-function>"
      xml.xpath("/vse-collection/vse-config/crawler").first.add_child seeds.root
      set_config(xml)
    end

    def add_csol_collection_seed(ccs_collection)
      xml = get_config
      xml.xpath("//call-function[@name='vse-crawler-seed-cs-ontolection']").remove
      seed =  Nokogiri::XML "<call-function name=\"vse-crawler-seed-cs-ontolection\" type=\"crawl-seed\"><with name=\"ccs-collection\">#{ccs_collection}</with></call-function>"
      xml.xpath("/vse-collection/vse-config/crawler").first.add_child seed.root
      set_config(xml)
    end

    def add_converter(converter_xml)
      curr_xml = get_config
      curr_xml.xpath("/vse-collection/vse-config/converters").first.add_child converter_xml.root
      set_config(curr_xml)
    end

    def add_binning_set(binning_set_xml)
      curr_xml = get_config
      if curr_xml.xpath("/vse-collection/vse-config/vse-index/binning-sets").empty?
        binning_sets = Nokogiri::XML "<binning-sets />"
        curr_xml.xpath("/vse-collection/vse-config/vse-index").first.add_child binning_sets.root
      end
      curr_xml.xpath("/vse-collection/vse-config/vse-index/binning-sets").first.add_child binning_set_xml.root
      set_config(curr_xml)
    end

    def search(query, subcollection = 'live')
       @vapi.query_search({ :query => query,
                            :sources => (@name + (subcollection.eql?("staging") ? "#staging" : "")) })
    end

    # crawler service functions

    # should distinguish between crawl (wait for crawl to finish) and start_crawl, for when we need to test large collections and don't need to wait for it to be finish to start running tests
    def start_crawl(subcollection = 'live', type = 'new', delay_seconds = 1)
      @vapi.search_collection_crawler_start({ :collection => @name,
                                              :subcollection => subcollection,
                                              :type => type })
      wait_for_crawl(subcollection, delay_seconds)
    end

    def stop_crawl(subcollection = 'live', delay_seconds = 1)
      begin
        @vapi.search_collection_crawler_stop({ :collection => @name,
                                             :subcollection => subcollection,
                                             :kill => 'true' })
      rescue
        # process to stop doesn't exist?
      end
      # The "stop" API calls don't wait for the stop to complete, so we do.
      wait_for_crawl(subcollection, delay_seconds)
    end

    def wait_for_crawl(subcollection = 'live', delay_seconds = 1, idle_ok = false)
      cs, idle = crawler_status(subcollection)
      if idle_ok
        while !cs.eql?("stopped") && !cs.eql?("none") && !idle.eql?("idle")
          sleep delay_seconds
          cs, idle = crawler_status(subcollection)
        end
      else
        while !cs.eql?("stopped") && !cs.eql?("none")
          sleep delay_seconds
          cs, idle = crawler_status(subcollection)
        end
      end
      cs
    end

    def crawler_status(subcollection = 'live')
      status = @vapi.search_collection_status({ :collection => @name,
                                                :subcollection => subcollection })
      service_status_and_idle = []
      if status.xpath("//crawler-status/@service-status").empty?
        service_status_and_idle[0] = "none"
      else
        service_status_and_idle[0] = status.xpath("//crawler-status/@service-status").to_s
      end

      if status.xpath("//crawler-status/@idle").empty?
        service_status_and_idle[1] = "active"
      else
        service_status_and_idle[1] = "idle"
      end
      service_status_and_idle
    end

    # indexer service functions
    def start_index(subcollection = 'live')
      @vapi.search_collection_indexer_start({ :collection => @name,
                                              :subcollection => subcollection })
    end

    def stop_index(subcollection = 'live', delay_seconds = 1)
      begin
        @vapi.search_collection_indexer_stop({ :collection => @name,
                                               :subcollection => subcollection })
      rescue
        # process to stop doesn't exist?
      end
      wait_for_index(subcollection, delay_seconds)
    end

    def wait_for_index(subcollection = 'live', delay_seconds = 1)
      i_s = indexer_status(subcollection)
      while !i_s.eql?("stopped") && !i_s.eql?("none")
        sleep delay_seconds
        i_s = indexer_status(subcollection)
      end
      indexer_status(subcollection)
    end

    def indexer_status(subcollection = 'live')
      status = @vapi.search_collection_status({ :collection => @name,
                                                :subcollection => subcollection })
      if status.xpath("//vse-index-status/@service-status").empty?
        "none"
      else
        status.xpath("//vse-index-status/@service-status").to_s
      end
    end

    # remove data
    def clean(subcollection = 'live')
      status = @vapi.search_collection_status({:collection => @name, :subcollection => subcollection})
      if !status.root.name.eql?("__CONTAINER__")
        stop_crawl(subcollection)
        stop_index(subcollection)
        @vapi.search_collection_clean({ :collection => @name,
                                        :subcollection => subcollection })
      end
    end

    # remove data and configuration
    def delete
      clean
      begin
        @vapi.search_collection_delete({:collection => @name})
      rescue
        # If the above throw exceptions, it's almost certainly because the collection doesn't exist.  Since the purpose of this function is to make sure the collection doesn't exist, I'm ok with that exception.
        # Future improvement: check exception to be sure of what it's doing.
      end
    end


    # deletes data in 'subcollection', then starts a crawl there and
    # checks every delay_seconds to see if it's completed.  Returns
    # crawler status for collection.  Designed to be used with
    # example-metadata, so delay_seconds is small.

    def clean_crawl(subcollection = 'live', delay_seconds = 1)
      clean(subcollection)
      start_crawl(subcollection)
    end
  end
end
