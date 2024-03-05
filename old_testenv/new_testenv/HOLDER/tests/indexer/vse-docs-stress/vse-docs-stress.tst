#!/usr/bin/env ruby
require "misc"
require "collection"
require 'pmap'

if true
    N_BUILD_THREADS = 4
    MAX_DOCS = 50000
    MAX_PIECES = 20
    MAX_BATCH_SIZE = 200
    ENQUEUE_P = 0.75
    MAX_SEARCHES = 50
    THROTTLE_AT = 10000
    STOP_AT = 250000
    FINAL_PERIOD = 1
    THREADS_PER_QUERY = 1
else
    N_BUILD_THREADS = 4
    MAX_DOCS = 1000
    MAX_PIECES = 20
    MAX_BATCH_SIZE = 200
    ENQUEUE_P = 0.5
    MAX_SEARCHES = 5
    THROTTLE_AT = 1000
    STOP_AT = 5000
    FINAL_PERIOD = 1
    THREADS_PER_QUERY = 1
end

class State


    def initialize(results, collection)
	@results = results
	@collection = collection

	@enqueues = {}
	@deletes = {}
	@valid = {}
	@has_data = {}

	@n_enqueues = 0
	@n_deletes = 0
        @n_has_data = 0
	@n_searches = 0
	@n_pending = 0
	@total_enqueues = 0
	@total_deletes = 0

	collection.set_crawl_options({ :audit_log => 'all', :atomic_vse_key_delete_mode => 'true', :final_period => FINAL_PERIOD }, {})
	collection.set_index_options({ :n_build_threads => N_BUILD_THREADS, :threads_per_query => THREADS_PER_QUERY })
    end

    def generate_enqueue(key, xdoc, cus)
	n = rand(MAX_PIECES) + 1

	if ! @enqueues[key] then @enqueues[key] = 0 end
	if @enqueues[key] == 0
	    @n_pending += 1
	    @enqueues[key] = n
	else
	    @enqueues[key] += n
	end

	for i in (1..n)
	    if ! @valid[key]
		@valid[key] = 1
	    else
		@valid[key] += 1
	    end

	    @total_enqueues += 1

	    cu = xdoc.create_element('crawl-url')
	    cus << cu
	    cu['url'] = "#{key}_#{@total_enqueues}"
	    cu['synchronization'] = 'none'
	    cu['status'] = 'complete'

	    cd = xdoc.create_element('crawl-data')
	    cu << cd
	    cd['encoding'] = 'xml'
	    cd['content-type'] = 'application/vxml'

	    doc = xdoc.create_element('document')
	    cd << doc
	    doc['vse-key'] = String(key)
	    doc['vse-key-normalized'] = 'vse-key-normalized'
	    content = xdoc.create_element('content')
	    doc << content
	    content['name'] = 'text'
	    content['type'] = 'text'
	    content.content = "#{key} enqueue #{@valid[key]}"
	    content = xdoc.create_element('content')
	    doc << content
	    content['name'] = 'key'
	    content['type'] = 'text'
	    content['fast-index'] = 'set'
	    content.content = "#{key}"
	    content = xdoc.create_element('content')
	    doc << content
	    content['name'] = 'seq'
	    content['type'] = 'text'
	    content['indexed-fast-index'] = 'int'
	    content.content = "#{@total_enqueues}"
	    @n_enqueues += 1
	end
    end

    def generate_delete(key, xdoc, cus)
	cd = xdoc.create_element('crawl-delete')
	cus << cd
	cd['vse-key'] = String(key)
	cd['vse-key-normalized'] = 'vse-key-normalized'
	cd['synchronization'] = 'none'
	@deletes[key] = true
	@n_deletes += 1
	@total_deletes += 1
    end

    def enqueue_batch()
	xdoc = Nokogiri::XML::Document.new
	cus = xdoc.create_element('crawl-urls')
	n_enqueues = @n_enqueues
	n_deletes = @n_deletes
	for i in (1..rand(MAX_BATCH_SIZE))
	    doc = rand(MAX_DOCS)
	    if ! @deletes[doc]
		if rand < ENQUEUE_P
		    generate_enqueue(doc, xdoc, cus)
		elsif @has_data[doc] && @enqueues[doc] == 0
		    generate_delete(doc, xdoc, cus)
		end
	    end
	end
	n_enqueues = @n_enqueues - n_enqueues
	n_deletes = @n_deletes - n_deletes
	@collection.enqueue_xml(cus)
	return n_enqueues + n_deletes
    end

    def search_doc(c, doc)
	if @has_data[doc] && ! @deletes[doc] && @enqueues[doc] == 0 then
	    query = "#{doc} enqueue #{rand(@valid[doc])+1} WITHIN DOCUMENT_KEY:#{doc}"
	    key_val = rand(2) == 0 ? "'#{doc}'" : "#{doc}"
	    results = c.search(query, { :query_condition_xpath => "#{key_val} = $key and #{@total_enqueues} >= $seq" })
	    count = results.xpath("//document").size
	    if count != 1
		@results.add(false, "searched for #{query} and got #{count} results")
	    end
	    @n_searches += 1
	end
    end

    def search()
	doc = rand(MAX_DOCS)
	search_doc(@collection, doc)
    end

    def run_searches()
	n = rand(MAX_SEARCHES)+1
	for i in (1..n)
	     search
	end
    end

    def search_thread(key)
	c = Collection.new(TESTENV.test_name)
	search_doc(c, key)
    end

    def validate_counts()
	n_enqueues = 0
	@enqueues.values.each do |v|
	    if v > 0 then n_enqueues += 1 end
	end
	@results.add(n_enqueues == 0, "#{n_enqueues} enqueues not completed")

	n_deletes = 0
	@deletes.values.each do |v|
	    if v then n_deletes += 1 end
	end
	@results.add(@n_deletes == 0, "#{@n_deletes} deletes not completed")

	@results.add(@has_data.keys.entries.count == @n_has_data,
                     "internal state document counts are %d and %d" %
                     [@n_has_data, @has_data.keys.entries.count])

	status = @collection.status
	n_indexed = status.xpath('//vse-index-status/@indexed-urls').first
	@results.add(Integer(n_indexed.value) == @total_enqueues,
                     "# sent %d enqueues and %d deletes, # indexed %s" %
                     [@total_enqueues, @total_deletes, n_indexed])

	n_docs = status.xpath('//vse-index-status/@n-docs').first
	@results.add(Integer(n_docs.value) == @n_has_data,
                     "%d documents expected to have data and %s exists" %
                     [@n_has_data, n_docs])

	n_searches = status.xpath('//vse-index-status/vse-serving/@n-queries').first
	@results.add((n_searches.value.to_i % @n_searches) == 0,
                     "%s searches when we expected a multiple of %d" %
                     [n_searches, @n_searches])
    end

    def validate()
	@has_data.keys.entries.peach(20) { |key| search_thread(key) }
    end

    def update_state()
	msg "updating: #{@n_has_data} documents, #{@n_searches} searches, #{@n_enqueues} @ #{@n_pending} / #{@n_deletes} pending"
	n_enqueues = 0
	n_deletes = 0
	log = @collection.audit_log_retrieve
	log.xpath('//audit-log-entry').each do |l|
	    cu = l.xpath('crawl-url').first
	    cd = l.xpath('crawl-delete').first
	    url = cu ? cu['url'] : cd['vse-key']
	    url_part = url.split('_')[0]
	    doc = Integer(url_part)

	    if cd && @deletes[doc]
		@deletes[doc] = false
		n_deletes += 1
		@valid[doc] = 0
		@has_data.delete(doc)
		@n_has_data -= 1
	    elsif cu && @enqueues[doc] > 0
		@enqueues[doc] -= 1
		n_enqueues += 1
		if ! @has_data[doc]
		    @n_has_data += 1
		    @has_data[doc] = true
		end
		if @enqueues[doc] == 0 then @n_pending -= 1 end
	    end
	end
	@n_enqueues -= n_enqueues
	@n_deletes -= n_deletes
	msg "updated : #{@n_has_data} documents, #{@n_searches} searches, #{@n_enqueues} @ #{@n_pending} / #{@n_deletes} pending, this #{n_enqueues}/#{n_deletes}"
 	token = log.xpath('/*').first['token']
	if token && token != ''
	    # msg "purging processed audit log entries with token #{token}"
	    @collection.audit_log_purge(token)
	end

	return n_enqueues + n_deletes
    end

    def n_pending
	return @n_enqueues + @n_deletes
    end
end

results = TestResults.new('Stress test the vse_docs object')
collection = Collection.new(TESTENV.test_name)
results.associate(collection)
collection.delete
collection.create

state = State.new(results, collection)
done = 0
while done < STOP_AT
    if state.n_pending < THROTTLE_AT
	done += state.enqueue_batch
    end
    state.run_searches
    while state.update_state > 0
         state.run_searches
    end
end

msg "Waiting for all data to be processed"

collection.wait_until_idle
sleep 60                       # Bug 29071, comment 8
while state.update_state > 0
end

state.validate_counts

msg "Validating the documents"

state.validate

# Make sure everything still agrees
state.validate_counts

results.cleanup_and_exit!(true)
