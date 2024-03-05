#!/usr/bin/python

from add_test_api import add_test_api
from lxml import etree
import gronkClient as gronk
import Queue
import random
import sys
import threaded_work
import time
import velocityAPI

# Tickle a specific, known, race condition.
#
# 1. An enqueue request will start a crawler
# 2. the crawler will ask the collection service for an indexer
#
# There is a window where the collection service may be stopping
# (typically due to idle exit) that can trigger a deadlock.
#
# Some recovery mechanisms for the deadlock can end up with
# two crawlers running: a very bad thing.

CRAWL_NODES = '''<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="https://meta.vivisimo.com">
    <crawl-data content-type="text/plain"
                encoding="text">
      Nothing to see here. Move along.
    </crawl-data>
  </crawl-url>
</crawl-urls>
'''

DIRECT_ENQUEUE = False

SIGNATURE = 'Crawler could not connect to indexer due to a timeout.'

hits = 0
offline_enqueues = 0
multiple_services = False


def msg(text):
    """Just formatted output to stdout."""
    human_time = time.ctime().split()[3]
    sys.stdout.write('%s %s\n' % (human_time, str(text)))
    sys.stdout.flush()


def report_offline_enqueue(resp):
    global offline_enqueues
    offline_enqueues += 1
    msg('Unexpected offline enqueue #%d:\n%s'
        % (offline_enqueues, etree.tostring(resp, pretty_print=True)))
    msg('Sleeping ...')
    time.sleep(60)  # Wait a long time for cb to deal with it.


def enqueuer(collection, triggerq, replyq):
    """Do an enqueue when told."""
    global hits
    vapi = velocityAPI.VelocityAPI()

    while True:
        replyq.put(True)
        go = triggerq.get()
        if DIRECT_ENQUEUE:
            resp = vapi.search_collection_enqueue_xml(collection=collection,
                                                      crawl_nodes=CRAWL_NODES)
            e_resp = resp
        else:
            try:
                resp = vapi.collection_broker_enqueue_xml(
                    collection=collection,
                    crawl_nodes=CRAWL_NODES)
            except velocityAPI.VelocityAPIexception:
                exception, text = sys.exc_info()[1]
                next = False
                for error in exception.xpath('//string[@name="error"]'):
                    if error.text and error.text.startswith(SIGNATURE):
                        msg(error.text.replace('\n',''))
                        hits += 1
                        next = True
                if next:
                    continue
                raise
            assert resp.tag == 'collection-broker-enqueue-response', \
                etree.tostring(resp)
            assert resp.get('status') == 'success', etree.tostring(resp)
            e_resp = resp[0]
            if e_resp.get('n-offline') != '0':
                report_offline_enqueue(resp)

        assert e_resp.tag == 'crawler-service-enqueue-response', \
            etree.tostring(resp)
        assert e_resp.get('error') is None, etree.tostring(resp)
        if e_resp.get('n-success') != '1':
            msg('Unexpected response: ' + etree.tostring(e_resp))


def crawler_service_status(vapi, collection):
    status_list = vapi.search_collection_status(collection=collection).xpath(
        'crawler-status/@service-status')
    if len(status_list) > 0:
        return status_list[0]
    return None


def crawler_down(vapi, collection):
    """Make sure the crawler is down (gently)."""
    while crawler_service_status(vapi, collection) == 'running':
        try:
            vapi.search_collection_crawler_stop(collection=collection)
        except velocityAPI.VelocityAPIexception:
            pass
        time.sleep(0.5)


def run_test():
    global multiple_services
    vapi = velocityAPI.VelocityAPI()
    # Create a public API function for stopping the collection service.
    add_test_api(vapi, 'search-collection-service-stop')

    crawler_pl = gronk.get_pid_list('crawler')
    assert crawler_pl == [], \
        'Failed precondition: found running crawler(s): %s' % crawler_pl
    cs_pl = gronk.get_pid_list('collection-service')
    assert cs_pl == [],  \
        'Failed precondition: found running collection-service(s): %s' % cs_pl

    collection = 'broker-race-1'
    try:
        vapi.search_collection_create(collection=collection,
                                      based_on='default-broker-push')
    except velocityAPI.VelocityAPIexception:
        exception, text = sys.exc_info()[1]

    eq = Queue.Queue()
    waitq = Queue.Queue()
    threaded_work.worker(target=enqueuer, args=(collection, eq, waitq))
    for i in xrange(100):
        waitq.get()             # Wait for the enqueuer to say "ready".
        old_crawler_pl = gronk.get_pid_list('crawler')
        crawler_down(vapi, collection)
        j = 0
        pending_fail = False
        while j < 4:
            j += 1
            crawler_pl = gronk.get_pid_list('crawler')
            if crawler_pl != []:
                msg('Unexpected crawler running! PID before stop %s and now %s.'
                    % (old_crawler_pl, crawler_pl))
                multiple_services = True
                msg('Crawler service status for "%s" is "%s".'
                    % (collection, crawler_service_status(vapi, collection)))
            cs_pl = gronk.get_pid_list('collection-service')
            if len(cs_pl) > 1:
                msg('More than one collection service running: %s' % str(cs_pl))
                if pending_fail:
                    multiple_services = True
                pending_fail = True
            time.sleep(1-(time.time()%1))
        sleep_time = random.random()/20.0
        msg('iteration %d: sleeping: %.5fs' % (i, sleep_time))
        eq.put(True)
        time.sleep(sleep_time)
        vapi.test_search_collection_service_stop(collection=collection)


if __name__ == "__main__":
    # Allow the user to use Control-C to stop the test.
    threaded_work.allow_control_c()
    status = threaded_work.top(run_test).get()
    if status == 0:
        if multiple_services:
            msg('Test Failed: multiple services seen '
                '(also %d offline enqueues and %d hits)'
                % (offline_enqueues, hits))
            status = 2
        elif offline_enqueues > 0:
            msg('Test Failed: %d offline enqueues (also %d hits)'
                % (offline_enqueues, hits))
            status = 3
        else:
            msg('Test Passed with %d hits' % hits)
    else:
        msg('Test Failed (sleeping to let messages print).')
        time.sleep(2.0)
        msg('Test Failed (also %d hits)' % hits)
    sys.exit(status)
