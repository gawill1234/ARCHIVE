#!/usr/bin/python

"""Support functions for collection broker testing."""

import random
import time

def shuffle(in_list):
    out_list = in_list[:]
    random.shuffle(out_list)
    return out_list

def status(vapi, filename):
    """Save a snapshot of the raw collection-broker-status XML."""
    f = open(filename, 'w')
    f.write(vapi.collection_broker_status())
    f.close()

def wait_for_all(vapi, collection_name_list):
    """Wait for the collection broker to see all of the collections.
    ******** Should I really need to do this? Bug 18135"""
    vapi.collection_broker_start() # Need to start CB to get status
    seen_all = 0
    while not seen_all:
        time.sleep(1)
        resp = vapi.collection_broker_status()
        seen_all = True
        for name in collection_name_list:
            if '"' + name + '"' not in resp:
                seen_all = False

def wait_for_enqueues(vapi, collection_name_list):
    """Wait for the collection broker to handle off-line queues."""
    ticks = 0
    offline_queue_count = -1
    while offline_queue_count:
        previous_offline_queue_count = offline_queue_count
        time.sleep(10)
        resp = vapi.collection_broker_status()
        no_offline_queue_count = resp.count('has-offline-queue="false"')
        offline_queue_count = resp.count('has-offline-queue="true"')
        if previous_offline_queue_count == offline_queue_count \
                and ticks < 50:
            ticks += 1
        else:
            ticks = 0
            print time.ctime(), 'offline count', offline_queue_count

def tune_short_idle(xml):
    xml = xml.replace(
        '<crawl-option name="idle-running-time">-1</crawl-option>',
        '<crawl-option name="idle-running-time">10</crawl-option>')
    
    # Only fiddle with indexer idle if it's not already tuned.
    if '"idle-exit"' not in xml:
        xml = xml.replace(
            '<vse-index-option',
            '<vse-index-option name="idle-exit">300</vse-index-option>'
            '<vse-index-option',
            1)
    return xml

def create_tiny(vapi, name):
    vapi.search_collection_create(collection=name)
    xml = vapi.search_collection_xml(collection=name)
    assert '"cache-size"' not in xml and '"cache-mb"' not in xml, \
        'Unexpected cache tuning in place.'
    xml = xml.replace(
        '<crawl-option',
        '<crawl-option name="cache-size">1</crawl-option>'
        '<crawl-option',
        1)
    xml = xml.replace(
        '<vse-index-option',
        '<vse-index-option name="cache-mb">1</vse-index-option>'
        '<vse-index-option name="cache-cleaner-mb">1</vse-index-option>'
        '<vse-index-option',
        1)
    xml = tune_short_idle(xml)
    vapi.search_collection_set_xml(collection=name, xml=xml)

def rolling_start_stop(start, stop, collection_name_list, max_running):
    """Start collections and then stop them.
    Overlap the starts and stops by as much as max_running."""
    q = []
    for name in collection_name_list:
        q[0:0] = [name]
        start(collection=name)
        while len(q) > max_running:
            stop(collection=q.pop())
    while len(q):
        stop(collection=q.pop())

def start_stop_crawlers(vapi, collection_name_list, max_running=16):
    return rolling_start_stop(vapi.search_collection_crawler_start,
                              vapi.search_collection_crawler_stop,
                              collection_name_list,
                              max_running)

def start_stop_indexers(vapi, collection_name_list, max_running=16):
    return rolling_start_stop(vapi.search_collection_indexer_start,
                              vapi.search_collection_indexer_stop,
                              collection_name_list,
                              max_running)

def do_enqueue(vapi, collection_name, url, text):
    """Enqueue a single entry to a collection."""

    crawl_url = '<crawl-url url="%s"' \
        ' status="complete"' \
        ' enqueue-type="reenqueued">' \
        '<crawl-data encoding="text" content-type="text/plain">%s' \
        '</crawl-data></crawl-url>' \
        % (url, text)

    resp = vapi.collection_broker_enqueue_xml(
        collection_broker_collection=collection_name,
        collection=collection_name,
        crawl_nodes=crawl_url)
    assert '<exception' not in resp, resp
    assert '<crawler-service-enqueue-failed ' not in resp, resp
    assert '<crawler-service-enqueue-success' in resp, resp
    assert 'status="success"' in resp, resp

def do_single_search(vapi, 
                     collection_name,
                     expect_list=None,
                     query_string=None):
    resp = vapi.collection_broker_search(
        collection_broker_collection=collection_name,
        sources=collection_name,
        query=query_string)
    assert '<exception' not in resp, resp

    found = True            # Just guessing, for the moment.
    for item in expect_list:
        if item not in resp:
            found = False
    return found

def do_search_aggresive(vapi,
                        collection_name, 
                        expect_list=None,
                        query_string=None):
    for retry in range(9):
        found = do_single_search(vapi,
                                 collection_name,
                                 expect_list,
                                 query_string)

        if found:
            if retry:
                print time.ctime(), 'got it!', collection_name
            return
        
        if retry == 1:          # Start the crawler ??
            vapi.search_service_start()
            vapi.search_collection_crawler_start(
                collection=collection_name,
                type='resume')
        if retry == 2:          # Try to get CB's attention by stopping stuff.
            vapi.search_collection_crawler_stop(collection=collection_name)
            vapi.search_collection_indexer_stop(collection=collection_name)
        if retry == 3:          # Try restarting the crawler again...
            vapi.search_service_start()
            vapi.search_collection_crawler_start(
                collection=collection_name,
                type='resume')
        if retry > 5:
            print time.ctime(), '* giving up on *', collection_name
            return
        print time.ctime(), 'no contents for', collection_name, 'waiting...'
        time.sleep(16)


def cleanup(vapi, collection_name, delete=True):
    """Stop and delete a collections."""
    resp = vapi.search_collection_crawler_stop(collection=collection_name,
                                               kill='true')
    #### assert '<exception' not in resp, resp
    resp = vapi.search_collection_indexer_stop(collection=collection_name,
                                               kill='true')
    #### assert '<exception' not in resp, resp
    if delete:
        resp = vapi.search_collection_delete(collection=collection_name)
        assert '<exception' not in resp, resp
