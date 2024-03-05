#!/usr/bin/python

"""Support functions for collection broker testing."""

from lxml import etree
import random
import sys
import time
import velocityAPI


def msg(text):
    """Just formatted output to stdout."""
    human_time = time.ctime().split()[3]
    sys.stdout.write('%s %s\n' % (human_time, str(text)))
    sys.stdout.flush()


def shuffle(stuff):
    out_list = list(stuff)
    random.shuffle(out_list)
    return out_list


def get_names(vapi):
    """Return a list of collection names known to the collection broker."""
    resp = vapi.collection_broker_status()
    assert resp.tag == 'collection-broker-status-response', \
        'get_names: collection-broker-status'
    return frozenset(resp.xpath('collection/@name'))


def wait_for_all(vapi, collection_name_set):
    """Wait for the collection broker to see all of the collections.
    ******** Should I really need to do this? Bug 18135"""
    vapi.collection_broker_start() # Need to start CB to get status
    while not collection_name_set <= frozenset(get_names(vapi)):
        time.sleep(2)


def wait_for_enqueues(vapi, collection_name_set):
    """Wait for the collection broker to handle off-line queues."""
    ticks = 0
    offline_queue_count = -1
    while offline_queue_count:
        previous_offline_queue_count = offline_queue_count
        time.sleep(60-time.time()%60) # next whole minute
        resp = vapi.collection_broker_status()
        assert resp.tag == 'collection-broker-status-response', \
            'wait_for_enqueues: collection-broker-status ' \
            + etree.tostring(resp)
        assert resp.xpath('@status') == ['running'], \
            'wait_for_enqueues: collection-broker-status ' \
            + etree.tostring(resp)
        offline_queue_count = 0
        for collection in resp.xpath('collection'):
            if collection.get('has-offline-queue') == 'true' \
                    and collection.get('is-ignored') == 'false':
                offline_queue_count += 1
        if previous_offline_queue_count == offline_queue_count \
                and ticks < 10:
            ticks += 1
        else:
            ticks = 0
            msg('offline count %d' % offline_queue_count)

def set_option(xml, parent_name, child_name, option_name, value):
    """A sort-of generic way to set an option in an XML doc."""
    if value == None:
        return
    children = xml.xpath('//%s/%s[@name="%s"]'
                         % (parent_name, child_name, option_name))
    assert len(children) <= 1, 'Multiple options found! %s, %s, %s' \
        % (parent_name, child_name, option_name)
    if len(children) == 1:
        child = children[0]
    else:
        # This specific child is not already there, create it.
        parents = xml.xpath('//' + parent_name)
        assert len(parents) == 1, 'Multiple parents found! %s, %s, %s' \
            % (parent_name, child_name, option_name)
        child = etree.SubElement(parents[0], child_name, name=option_name)
    child.text = str(value)

DEFAULT_COLLECTION_NAME = 'tuned-for-collection-broker-test'

def default_collection(vapi,
                       crawler_idle=None,  indexer_idle=None,
                       crawler_mb=None, indexer_mb=None):
    """Create a template collection
    which will be used by create_collection (below)."""
    name = DEFAULT_COLLECTION_NAME
    try:
        resp = vapi.search_collection_create(collection=name,
                                             based_on='default-broker-push')
        retry = False
    except velocityAPI.VelocityAPIexception:
        # If the tuned template already exists, delete and recreate it.
        resp = vapi.search_collection_delete(collection=name)
        resp = vapi.search_collection_create(collection=name,
                                             based_on='default-broker-push')
    # Short cut return if no tuning is asked for.
    if crawler_idle == None and indexer_idle == None \
            and crawler_mb == None and indexer_mb == None:
        return name
    xml = vapi.search_collection_xml(collection=name)
    set_option(xml, 'crawl-options', 'crawl-option',
               'idle-running-time', crawler_idle)
    # Don't tune the indexer idle-exit to reproduce bug 18967
    set_option(xml, 'vse-index', 'vse-index-option', 'idle-exit', indexer_idle)
    set_option(xml, 'crawl-options', 'crawl-option', 'cache-size', crawler_mb)
    set_option(xml, 'vse-index', 'vse-index-option', 'cache-mb', indexer_mb)
    set_option(xml, 'vse-index', 'vse-index-option',
               'cache-cleaner-mb', indexer_mb)
    resp = vapi.search_collection_set_xml(collection=name,
                                          xml=etree.tostring(xml))
    assert resp.tag == '__CONTAINER__', etree.tostring(resp)
    return name


def create_collection(vapi,
                      collection,
                      delete_first=False,
                      based_on=DEFAULT_COLLECTION_NAME):
    """Create a collection based on our tuned template."""
    try:
        resp = vapi.search_collection_create(collection=collection,
                                             based_on=based_on)
    except velocityAPI.VelocityAPIexception:
        exception = sys.exc_info()[1][0]
        if exception.get('name') != 'search-collection-already-exists':
            raise
        if not delete_first:
            return              # The caller proceeds with whatever is there.
        cleaned_up = False
        while not cleaned_up:
            msg('removing pre-existing collection "%s".' % collection)
            cleaned_up = cleanup(vapi, collection, True)
        resp = vapi.search_collection_create(collection=collection,
                                             based_on=based_on)

    assert resp.tag == '__CONTAINER__', etree.tostring(resp)


def do_single_search(vapi,
                     collection_name,
                     expect_snippet=None,
                     expect_url=None,
                     query_string=None,
                     direct_search=False,
                     fetch_timeout=None):
    if direct_search:
        resp = vapi.query_search(sources=collection_name,
                                 query=query_string,
                                 fetch_timeout=fetch_timeout)
    else:
        try:
            resp = vapi.collection_broker_search(collection=collection_name,
                                                 query=query_string,
                                                 fetch_timeout=fetch_timeout)
        except velocityAPI.VelocityAPIexception:
            exception = sys.exc_info()[1][0]
            if exception.xpath('xmlnode/log/error/@id') \
                    == ['COLLECTION_BROKER_NO_COLLECTION_TO_STOP']:
                msg("couldn't start %s for search" % collection_name)
                return False
            raise

    assert resp.tag != 'exception', etree.tostring(resp)

    url = resp.xpath('//query-results'
                     '/list'
                     '/document/@url')
    snippet = resp.xpath('//query-results'
                         '/list'
                         '/document'
                         '/content[@name="snippet"]')
    if len(url) < 1 or len(snippet) < 1 \
            or (expect_url and expect_url not in url):
        return False

    if expect_snippet:
        for s in snippet:
            if expect_snippet in s.text:
                return True
        return False
    return True


def do_search_aggresive(vapi,
                        collection_name,
                        expect_snippet=None,
                        expect_url=None,
                        query_string=None):
    for retry in range(9):
        time.sleep(2*retry)
        found = do_single_search(vapi,
                                 collection_name,
                                 expect_snippet,
                                 expect_url,
                                 query_string)
        if found:
            if retry:
                msg('got it! for %s' % collection_name)
            return
        msg('no contents for %s waiting...' % collection_name)
    msg('Result never found for %s' % collection_name)
    msg('Test failed.')
    sys.exit(1)


def do_enqueue(vapi,
               collection_name,
               url_text_list,
               direct_enqueue=False,
               synchronization='indexed-no-sync',
               index_atomic=False):
    """Enqueue a single entry to a collection."""

    crawl_urls = etree.Element('crawl-urls',
                               **{'synchronization':synchronization})
    if index_atomic:
        wrapper = etree.SubElement(crawl_urls, 'index-atomic')
    else:
        wrapper = crawl_urls

    for url, text in url_text_list:
        crawl_url = etree.SubElement(wrapper, 'crawl-url',
                                     **{'url':url,
                                        'status':'complete',
                                        'enqueue-type':'reenqueued'})
        crawl_data = etree.SubElement(crawl_url, 'crawl-data',
                                      **{'encoding':'text',
                                         'content-type':'text/plain'})
        crawl_data.text = text
    if direct_enqueue:
        resp = vapi.search_collection_enqueue_xml(
            collection=collection_name,
            crawl_nodes=etree.tostring(crawl_urls))
            # exception_on_failure='true')
        assert resp.tag == 'crawler-service-enqueue-response', \
            etree.tostring(resp)
        assert resp.get('n-failed') == '0', etree.tostring(resp)
    else:
        for retry in xrange(32):
            resp = vapi.collection_broker_enqueue_xml(
                collection=collection_name,
                crawl_nodes=etree.tostring(crawl_urls))
                # exception_on_failure='true')

            # if resp.xpath('//@state'):
                # msg("Saw state=" + str(resp.xpath('//@state')))

            if resp.tag == '__CONTAINER__':
                msg('__CONTAINER__ returned for '+ collection_name)
            else:
                assert resp.tag == 'collection-broker-enqueue-response', \
                    etree.tostring(resp)
                assert resp.get('status') == 'success', etree.tostring(resp)
                if resp[0].tag == 'crawler-service-enqueue-response' \
                        and resp[0].get('n-failed') == '0' \
                        and resp[0].get('error') is None:
                    break
                msg('<%s %s> for %s' % (resp[0].tag,
                                        ' '.join(['%s="%s"'%(n,v) for n,v
                                                  in resp[0].attrib.items()]),
                                        collection_name))


def cleanup(vapi, collection, delete=True):
    """Stop and optionally delete a collection."""
    try:
        vapi.search_collection_crawler_stop(collection=collection, kill='true')
        vapi.search_collection_indexer_stop(collection=collection, kill='true')
        if delete:
            vapi.search_collection_delete(collection=collection)
    except velocityAPI.VelocityAPIexception:
        exception = sys.exc_info()[1][0]
        # Collection doesn't exist? Then we're good...
        if exception.get('name') != 'search-collection-invalid-name':
            msg('cleanup failed for %s: %s'
                % (collection, etree.tostring(exception)))
            return False
    return True

def delete_with_retry(vapi, collection, retry=3):
    """Stop and delete a collection, try up to given number of times"""
    retry_number=0
    while (retry_number < retry):
        try:
            vapi.search_collection_crawler_stop(collection=collection, kill='true')
            vapi.search_collection_indexer_stop(collection=collection, kill='true')
            vapi.search_collection_delete(collection=collection)
            return True
        except velocityAPI.VelocityAPIexception:
            exception = sys.exc_info()[1][0]
            if exception.get('name') == 'search-collection-invalid-name':
                return True
            else:
                msg('cleanup failed on attempt %s for %s: %s'  
                    % (retry_number, collection, etree.tostring(exception)))
                retry_number = retry_number + 1 
                msg('%s retries are still available to delete collection %s'  
                    % ((retry - retry_number), collection))
    
    return False
      
