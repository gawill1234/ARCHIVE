#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'set'
require 'testenv'
require 'vapi'

class Collection
  attr_reader :name, :vapi

  def initialize(name,
                 velocity=TESTENV.velocity,
                 user=TESTENV.user,
                 password=TESTENV.password)
    @name = name.freeze
    @vapi = Vapi.new(velocity, user, password)
  end

  def create_raw(based_on=nil, collection_meta=nil, description=nil)
    @vapi.search_collection_create(:collection => @name,
                                   :based_on => based_on,
                                   :collection_meta => collection_meta,
                                   :description => description)
  end

  def create(based_on=nil, collection_meta=nil, description=nil)
    description = "Created by a Ruby test." unless description
    description = "#{description} based-on: #{based_on}" if based_on
    create_raw(based_on, collection_meta, description)
  end

  def xml
    @vapi.search_collection_xml(:collection => @name)
  end

  def fix_path(path)
    # If it looks like we have a Windows path,
    if path[/^[A-Za-z]:\\/]
      # fixup any Unix-like slashes.
      path.split('/').join('\\').sub('\\\\','\\')
    else
      path.sub('//','/')
    end
  end

  def filebase
    fix_path(xml.xpath('/vse-collection/@filebase').first.to_s)
  end

  def crawl_path_list
    # Return an array of two: [live-crawl-dir, staging-crawl-dir]
    meta = '/vse-collection/vse-meta/vse-meta-info'
    live = xml.xpath(meta+'[@name="live-crawl-dir"]')
    if live.empty?
      live = filebase + '/crawl1'
    else
      live = live.first.content
    end
    staging = xml.xpath(meta+'[@name="staging-crawl-dir"]')
    if staging.empty?
      staging = filebase + '/crawl0'
    else
      staging = staging.first.content
    end
    [fix_path(live), fix_path(staging)]
  end

  def run_path_list(which=nil)
    # Default is all run paths.
    run_xpath = '/vse-collection/vse-run//run/@path'
    # Allow the caller to pick which one (should be "live" or "staging").
    run_xpath = '/vse-collection/vse-run[@which="#{which}"]//run/@path' if which
    xml.xpath(run_xpath).map{|path| fix_path(path.to_s)}.uniq
  end

  COLLECTION_CONFIG_INDEX = '/vse-collection/vse-config/vse-index'

  def magic_index_options(xml, opts)
    vse_index = xml.xpath(COLLECTION_CONFIG_INDEX).first
    if vse_index.nil?
      puts "#{COLLECTION_CONFIG_INDEX} not found"
      false
    else
      opts.each {|name_value|
        name, value = name_value.split('=')
        vse_index.xpath("vse-index-option[@name='#{name}']").unlink
        el = xml.document.create_element('vse-index-option')
        el['name'] = name
        el.content = value
        vse_index << el
      }
      true
    end
  end

  def set_xml(new_xml)
    magic_index_options(new_xml, ENV['INDEX_OPTIONS'].split(',')) if
      ENV['INDEX_OPTIONS']
    @vapi.search_collection_set_xml(:collection => @name, :xml => new_xml)
  end

  def enqueue_good?(resp)
    resp.name == 'crawler-service-enqueue-response' and
      resp['error'].nil? and
      resp['n-failed'].to_s == '0' and
      resp.children.to_set {|c| c['state'].to_s}.subset?(['success',
                                                          ''].to_set) and
      resp.children.to_set {|c| c['status'].to_s}.subset?(['complete',
                                                           ''].to_set)
  end

  def enqueue(crawl_urls, ensure_running=nil)
    resp = @vapi.search_collection_enqueue(:collection => @name,
                                           :crawl_urls => crawl_urls,
                                           :ensure_running => ensure_running)
    enqueue_good?(resp.root)
  end

  def enqueue_xml(crawl_nodes, ensure_running=nil)
    resp = @vapi.search_collection_enqueue_xml(:collection => @name,
                                               :crawl_nodes => crawl_nodes,
                                               :ensure_running => ensure_running)
    enqueue_good?(resp.root)
  end

  def broker_enqueue_xml(crawl_nodes)
    resp = @vapi.collection_broker_enqueue_xml(:collection => @name,
                                               :crawl_nodes => crawl_nodes)
    resp.root.name == 'collection-broker-enqueue-response' and
      enqueue_good?(resp.root.child)
  end

  def export_data(destination_collection, options={})
    resp = @vapi.collection_broker_export_data(options.merge(
                    :source_collection => @name,
                    :destination_collection => destination_collection))
    raise "Invalid node returned by collection_broker_export_data: #{xml}" if
      resp.root.name != 'collection-broker-export-data-response'
    resp.root.attributes['id'].to_s
  end

  def broker_start
    @vapi.collection_broker_start_collection(:collection => @name).root.name ==
      '__CONTAINER__'
  end

  def search(query=nil, options={})
    @vapi.query_search(options.merge(:sources => @name, :query => query))
  end

  def search_total_results(args={})
    resp = @vapi.query_search(args.merge(:sources => @name))
    raise "Invalid response to query-search: #{resp}" if
      resp.root.name != 'query-results'
    sum = 0
    resp.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}
    sum
  end

  def search_total_results(args={})
    resp = @vapi.query_search(args.merge(:sources => @name))
    raise "Invalid response to query-search: #{resp}" if
      resp.root.name != 'query-results'
    sum = 0
    resp.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}
    sum
  end

  BROKER_SEARCH_TOTAL_RESULTS = '/collection-broker-search-response/query-results/added-source/@total-results-with-duplicates'
  # This is very strict. I don't want to kill an unknown exception.
  BROKER_SEARCH_CAUSE_ID = '/exception[@name="collection-broker-search"]/xmlnode[@name="cause"]/log/error/@id'
  # These two exception ids indicate an expected resource constraint, not a failure.
  # broker_search will prevent these from being thrown as a VapiException.
  BROKER_SEARCH_NO_FAIL_IDS = Set.new(['COLLECTION_BROKER_NO_COLLECTION_TO_STOP',
                                       'COLLECTION_BROKER_SEARCH_STARTED_AND_STOPPED'])

  def broker_search(args={})
    begin
      resp = @vapi.collection_broker_search(args.merge(:collection => @name))
      raise "Invalid response to collection-broker-search: #{resp}" if
        resp.root.name != 'collection-broker-search-response' or
        resp.root['status'] != 'success'
      sum = 0
      resp.xpath(BROKER_SEARCH_TOTAL_RESULTS).each {|node| sum += node.to_s.to_i}
      sum
    rescue VapiException => ex
      cause = Nokogiri::XML(ex.message).xpath(BROKER_SEARCH_CAUSE_ID).to_s
      raise unless BROKER_SEARCH_NO_FAIL_IDS.member?(cause)
      msg "collection.broker_search not raising exception id=#{cause}"
      nil                       # Tell my caller we didn't find anything, not even zero results.
    end
  end

  def read_only(mode=:status)
    resp = @vapi.search_collection_read_only(:collection => @name,
                                            :mode => mode)
    raise "Invalid node returned by search-collection-status: #{resp}" if
      resp.root.name != 'read-only-state'
    attrs = resp.root.attributes
    raise "Unknown mode returned by search-collection-status: #{attrs['mode']}" if
      ['disabled', 'pending', 'enabled'].index(attrs['mode'].to_s).nil?
    h = {}
    attrs.each {|n,v| h[n.to_s] = v.to_s}
    h
  end

  def read_only?
    read_only['mode'] == 'enabled'
  end

  def read_only_pending?
    read_only['mode'] == 'pending'
  end

  def read_only_disabled?
    read_only['mode'] == 'disabled'
  end

  def read_only_enable
    # Just return if we're already read-only enabled
    return if read_only?
    # Ask for read-only to be enabled
    read_only('enable') if not read_only_pending?
    while not read_only? do
      sleep 1
    end
  end

  def audit_log_retrieve(limit=nil, args={})
    @vapi.search_collection_audit_log_retrieve(args.merge(:collection => @name,
                                                          :limit => limit))
  end

  def audit_log_purge(token)
    @vapi.search_collection_audit_log_purge(:collection => @name,
                                            :token => token)
  end

  def status(subcollection=nil, args={})
    @vapi.search_collection_status(args.merge(:collection => @name,
                                              :subcollection => subcollection))
  end

  def undash(s)
    s.gsub(/-/, '_').to_sym
  end

  def broker_status
    # Get the collection broker status for this collection
    mypath = "/collection-broker-status-response/collection[@name='#{@name}']"
    cb_status = @vapi.collection_broker_status.xpath(mypath)
    return {} if cb_status.empty?
    Hash[*cb_status.first.attributes.map {|n,v| [undash(n), v.to_s]}.flatten]
  end

  def crawler_status(subcollection=nil)
    cs = status(subcollection).xpath('/vse-status/crawler-status').first
    if cs.nil?
      {}
    else
      Hash[*cs.attributes.map{|k,v| [undash(k), v.to_s]}.flatten]
    end
  end

  def vse_index_status(subcollection=nil)
    vis = status(subcollection).xpath('/vse-status/vse-index-status').first
    if vis.nil?
      {}
    else
      Hash[*vis.attributes.map{|k,v| [undash(k), v.to_s]}.flatten]
    end
  end

  def broker_online?
    broker_status[:is_online] == 'true'
  end

  def cb_n_offline_queue
    vapi.collection_broker_crawler_offline_status(:collection=>@name).
      xpath('/crawler-offline-status/@n-offline-queue').first.to_s.to_i
  end

  def crawler_service_status(subcollection=nil)
    crawler_status(subcollection)[:service_status]
  end

  def crawler_n_offline_queue(subcollection=nil)
    crawler_status(subcollection)[:n_offline_queue].to_i
  end

  def crawler_this_elapsed(subcollection=nil)
    crawler_status(subcollection)[:this_elapsed].to_i
  end

  def indexer_service_status(subcollection=nil)
    vse_index_status(subcollection)[:service_status]
  end

  def crawler_idle?(subcollection=nil)
    cs = crawler_status(subcollection)
    (cs[:resume] != 'resume' and
     (cs[:idle] == 'idle' or cs[:service_status] == 'stopped'))
  end

  def crawler_stopped?(subcollection=nil)
    cs = crawler_status(subcollection)
    cs[:service_status] == 'stopped'
  end

  def indexer_idle?(subcollection=nil)
    vis = vse_index_status(subcollection)
    (vis[:idle] == 'idle' or vis[:service_status] == 'stopped')
  end

  def indexer_stopped?(subcollection=nil)
    vis = vse_index_status(subcollection)
    vis[:service_status] == 'stopped'
  end

  def wait_until_idle
    wait_until_condition { crawler_idle? and indexer_idle? }
  end

  def wait_until_crawler_stopped
    wait_until_condition { crawler_stopped? }
  end

  def wait_until_stopped
    wait_until_condition { crawler_stopped? and indexer_stopped? }
  end

  def wait_until_condition
    sleep_time = 0.1

    while not yield
      sleep(sleep_time)

      if sleep_time < 5
        sleep_time *= 2
      else
        sleep_time = 5
      end
    end
  end
  private :wait_until_condition

  def indexer_running_time(subcollection=nil)
    vse_index_status(subcollection)[:running_time].to_i
  end

  def index_n_docs(subcollection=nil)
    vse_index_status(subcollection)[:n_docs].to_i
  end

  def crawler_stop_no_wait(subcollection=nil, args={})
    begin
      @vapi.search_collection_crawler_stop(args.merge(:collection => @name,
                                                      :subcollection =>
                                                      subcollection))
    rescue
      nil
    end
  end

  def indexer_stop_no_wait(subcollection=nil, args={})
    begin
      @vapi.search_collection_indexer_stop(args.merge(:collection => @name,
                                                      :subcollection =>
                                                      subcollection))
    rescue
      nil
    end
  end

  def crawler_kill(subcollection=nil)
    crawler_stop_no_wait(subcollection, :kill => true)
  end

  def indexer_kill(subcollection=nil)
    indexer_stop_no_wait(subcollection, :kill => true)
  end

  def crawler_start(subcollection=nil, args={})
    @vapi.search_collection_crawler_start(args.merge(:collection => @name,
                                                     :subcollection =>
                                                     subcollection))
  end

  def indexer_start(subcollection=nil, args={})
    @vapi.search_collection_indexer_start(args.merge(:collection => @name,
                                                     :subcollection =>
                                                     subcollection))
  end

  def crawler_restart(subcollection=nil, args={})
    @vapi.search_collection_crawler_restart(args.merge(:collection => @name,
                                                       :subcollection =>
                                                       subcollection))
  end

  def indexer_restart(subcollection=nil, args={})
    @vapi.search_collection_indexer_restart(args.merge(:collection => @name,
                                                       :subcollection =>
                                                       subcollection))
  end

  def crawler_stop(subcollection=nil, args={})
    until crawler_service_status(subcollection) != 'running'
      crawler_stop_no_wait(subcollection, args)
      sleep 1
    end
  end

  def indexer_stop(subcollection=nil, args={})
    until indexer_service_status(subcollection) != 'running'
      indexer_stop_no_wait(subcollection, args)
      sleep 1
    end
  end

  def stop_no_wait(subcollection=nil, args={})
    crawler_stop_no_wait(subcollection, args)
    indexer_stop_no_wait(subcollection, args)
  end

  def stop(subcollection=nil, args={})
    crawler_stop(subcollection, args)
    indexer_stop(subcollection, args)
  end

  def kill(subcollection=nil)
    crawler_kill(subcollection)
    indexer_kill(subcollection)
  end

  def exists?
    not @vapi.repository_list_xml.xpath(
          "/vce/vse-collection[@name='#{@name}']").empty?
  end

  def clean(subcollection=nil, args={})
    begin
      @vapi.search_collection_clean(args.merge(:collection => @name,
                                               :subcollection => subcollection))
    rescue
      stop
      @vapi.search_collection_clean(args.merge(:collection => @name,
                                               :subcollection => subcollection))
    end
  end

  def delete_no_wait(args={})
    begin
      @vapi.search_collection_delete(args.merge(:collection => @name))
      true
    rescue
      false
    end
  end

  def delete
    begin
      # This will fail for read-only (and maybe nothing else?)
      @vapi.search_collection_delete(:collection => @name,
                                     :force => true,
                                     :kill_services => true)
    rescue
      if self.exists?
        # Try one more time, with explicit kills
        kill
        sleep 1
        kill
        read_only(:disable) if read_only?
        @vapi.search_collection_delete(:collection => @name,
                                       :force => true,
                                       :kill_services => true)
      end
    end
  end

  def set_crawl_options(crawl_options, curl_options)
    conf = xml
    crawler = conf.xpath('//vse-config/crawler').first
    options = crawler.xpath('crawl-options')

    if options.size == 0
      options = crawler.document.create_element('crawl-options')
      crawler << options
    else
      options = options.first
    end

    crawl_options.each do |k,v|
      # tweak from ruby identifier to vivisimo option style
      k = k.to_s.gsub('_', '-')

      options.xpath("crawl-option[@name='#{k}']").unlink
      new_opt = options.document.create_element('crawl-option')
      new_opt['name'] = k
      new_opt.content = v.to_s
      options << new_opt
    end

    curl_options.each do |k,v|
      # tweak from ruby identifier to vivisimo option style
      k = k.to_s.gsub('_', '-')

      options.xpath("curl-option[@name='#{k}']").unlink
      new_opt = options.document.create_element('curl-option')
      new_opt['name'] = k
      new_opt.content = v.to_s
      options << new_opt
    end

    set_xml(conf)
  end

  def add_converter(converter_string)
    conf = xml

    crawler = conf.xpath('//vse-config/crawler').first
    options = crawler.xpath('crawl-options')

    vse_config = conf.xpath('//vse-config').first
    converters = vse_config.xpath('converters')

    if converters.size == 0
      converters = vse_config.document.create_element('converters')
      vse_config << converters
    else
      converters = converters.first
    end

    # adds the converter to the end of the list
    new_converter = converters.add_child(Nokogiri::XML(converter_string).
                                         search("//converter").first)

    converters << new_converter

    set_xml(conf)
  end

  def remove_config_at(xpath)
    conf = xml
    conf.xpath(xpath).remove
    set_xml(conf)
  end

  def set_index_options(opts)
    conf = xml
    idx_conf = conf.xpath('//vse-config/vse-index').first

    opts.each do |k,v|
      # tweak from ruby identifier to vivisimo option style
      k = k.to_s.gsub('_', '-')

      idx_conf.xpath("vse-index-option[@name='#{k}']").unlink
      new_opt = idx_conf.document.create_element('vse-index-option')
      new_opt['name'] = k
      new_opt.content = v.to_s
      idx_conf << new_opt
    end

    set_xml(conf)
  end

  def add_binning_set(binning_set_xml)
    conf = xml
    if conf.xpath("/vse-collection/vse-config/vse-index/binning-sets").empty?
      binning_sets = Nokogiri::XML "<binning-sets />"
      conf.xpath("/vse-collection/vse-config/vse-index").first.add_child binning_sets.root
    end
    conf.xpath("/vse-collection/vse-config/vse-index/binning-sets").first.add_child binning_set_xml.root
    set_xml(conf)
  end

  def add_crawl_seed(kind, call_with)
    conf = xml
    crawler = conf.xpath("/vse-collection/vse-config/crawler").first
    seed = crawler.add_child(Nokogiri::XML::Node.new('call-function', conf))
    seed['name'] = kind.to_s.gsub('_', '-')
    seed['type'] = 'crawl-seed'
    call_with.each do |k,v|
      this_with = seed.add_child(Nokogiri::XML::Node.new('with', conf))
      this_with['name'] = k.to_s.gsub('_', '-')
      this_with.content = v.to_s
    end
    set_xml(conf)
  end

  def get_number_streams(subcollection=nil)
    stat = status()
    stat.xpath('/vse-status/vse-index-status/vse-index-streams/vse-index-stream').length
  end

  def get_index_size(subcollection=nil)
    stat = status()
    stat.xpath('/vse-status/vse-index-status/@indexed-bytes').to_s.to_i
  end

  def get_num_dictionaries(subcollection=nil)
    stat = status()

    num_dicts = stat.xpath('/vse-status/vse-index-status/term-expand-dicts-status/term-expand-dict-status').length

    size_list = stat.xpath('/vse-status/vse-index-status/term-expand-dicts-status/term-expand-dict-status/@n-bytes')
    total_bytes = 0
    for size in size_list
      total_bytes += size.to_s.to_i
    end

    word_list = stat.xpath('/vse-status/vse-index-status/term-expand-dicts-status/term-expand-dict-status/@n-words')
    total_words = 0
    for word in word_list
      total_words += word.to_s.to_i
    end

    [num_dicts, total_bytes, total_words]
  end

  def full_merge(subcollection=nil)
    @vapi.search_collection_indexer_full_merge(:collection => @name, :subcollection => subcollection)
  end

  #+
  # Private subroutine; Please call one of the public with_crawl_remote_... methods, below.
  #-
  def with_crawl_remote_xxx_status(kind, status_node, block)
    raise "No block" if ! block
    return if ! status_node
    conn_xpath = 
      "//crawl-remote-all-status/crawl-remote-#{kind}-status/crawl-remote-connection-status"
    status_node.xpath(conn_xpath).each do |node|
      conn_name = node.attribute('name').to_s
      conn_state = node.attribute('state').to_s
      node.children.each do |child|
        coll_name = child.attribute('name').to_s
        coll_state = child.attribute('state').to_s
        block.call(conn_name, conn_state, coll_name, coll_state)
      end
    end
  end

  #+
  # Calls this.status() to get the collection's status, and then iterates over all of the
  # <crawl-remote-collection-status .../> nodes in the resulting XML.
  #
  # Args
  #   subcollection -- passed to this.status (see above)
  #   args          -- passed to this.status   ''   ''
  #   block         -- executed once for each <crawl-remote-collection-status .../> node.
  #
  # The block is invoked with four String arguments;
  #   conn_name  -- The name attribute of the enclosing <crawl-remote-connection-status> node,
  #   conn_state --  '' state   ''     ''  ''    ''       ''     ''       ''       ''     '',
  #   coll_name  --  '' name attribute of the <crawl-remote-collection-status .../> node,
  #   coll_state --  '' state   ''     ''  ''   ''     ''      ''       ''           ''.
  #
  # The value returned by the block is ignored.
  # The value returned by this method is unspecified.
  #
  # NOTE: <crawl-remote-collection-status.../> nodes are contained within structure that
  # looks like this;
  #  ...
  #  <crawler-status>
  #    ...
  #    <crawl-remote-all-status>
  #      <crawl-remote-server-status>
  #        <crawl-remote-connection-status name="..." state="..." ms="nnn">
  #          <crawl-remote-collection-status name="..." state="..."/>
  #          <crawl-remote-collection-status name="..." state="..."/>
  #          ...
  #        </crawl-remote-connection-status>
  #      </crawl-remote-server-status>
  #      <crawl-remote-client-status>
  #          <crawl-remote-collection-status name="..." state="..."/>
  #          <crawl-remote-collection-status name="..." state="..."/>
  #          ...
  #      </crawl-remote-client-status>
  #    </crawl-remote-all-status>
  #    ...
  #  </crawler-status>
  #  ...
  #-
  def with_crawl_remote_all_status(subcollection=nil, args={}, &block)
    status_node = status(subcollection, args)
    with_crawl_remote_xxx_status('server', status_node, block)
    with_crawl_remote_xxx_status('client', status_node, block)
    nil
  end

  #+
  # Same as with_crawl_remote_all_status() (see above), but only iterates over
  # <crawl-remote-collection-status... /> nodes that are descendants of the
  # <crawl-remote-server-status> node.
  #-
  def with_crawl_remote_server_status(subcollection=nil, args={}, &block)
    status_node = status(subcollection, args)
    with_crawl_remote_xxx_status('server', status_node, block)
    nil
  end

  #+
  # Same as with_crawl_remote_all_status() (see above), but only iterates over
  # <crawl-remote-collection-status... /> nodes that are descendants of the
  # <crawl-remote-client-status> node.
  #-
  def with_crawl_remote_client_status(subcollection=nil, args={}, &block)
    status_node = status(subcollection, args)
    with_crawl_remote_xxx_status('client', status_node, block)
    nil
  end

end
