#!/usr/bin/python

import optparse
import os
import Queue
import random
import sys
import threaded_work
import time
import velocityAPI
from lxml import etree


DEFAULT_THREADS=32
DEFAULT_PACE=0.1
DEFAULT_RUN_TIME=5
DEFAULT_COLLECTIONS='cb-tunable-0 cb-tunable-1 cb-tunable-2 cb-tunable-3 cb-tunable-4 cb-tunable-5 cb-tunable-6 cb-tunable-7 cb-tunable-8'

def msg(text):
    """Just formatted output to stdout."""
    human_time = time.ctime().split()[3]
    print human_time, text
    sys.stdout.flush()


TOTAL_RESULTS_WITH_DUPS_XPATH = 'sum(added-source/@total-results-with-duplicates)'

def search(vapi, collection, query=None):
    """Do a single query and return the count of results found."""

    try:
        resp = vapi.collection_broker_search(query=query, collection=collection)
    except velocityAPI.VelocityAPIexception:
        exception = sys.exc_info()[1][0]
        if 'COLLECTION_BROKER_NO_COLLECTION_TO_STOP' \
                in exception.xpath('xmlnode/log/error/@id') \
                or 'COLLECTION_BROKER_START_COLLECTION_MAXIMUM_COLLECTIONS' \
                in exception.xpath('xmlnode/log/msg/@id'):
            msg("couldn't start %s for search" % collection)
            return -1
        raise
    return resp.xpath(TOTAL_RESULTS_WITH_DUPS_XPATH)


def worker(queryq, replyq):
    """Issue queries against a collection and report back items found."""
    vapi = velocityAPI.VelocityAPI()
    collection, query = queryq.get()
    while collection:
        replyq.put([collection, query, search(vapi, collection, query)])
        collection, query = queryq.get()


def query_listener(queries, replyq):
    passing = True
    collection, query, count = replyq.get()
    while collection:
        expected_count = queries[collection][query]
        # FIXME Record what we actually saw
        if expected_count is not None and expected_count != count:
            # not what we expected, but do keep running
            if count >= 0:
                passing = False
            msg('expected: %s, found %d for: %s'
                % (expected_count, count, query))
        collection, query, count = replyq.get()
    assert passing, 'Unexpected results found'


def do_queries(queries, queryq, pace, end_time):
    while time.time() < end_time:
        for collection in queries.iterkeys():
            query = random.choice(queries[collection].keys())
            if pace > 0:
                time.sleep(pace - time.time()%pace)
                queryq.put([collection, query])


def query_driver(queries,
                 pace=DEFAULT_PACE,
                 run_time=DEFAULT_RUN_TIME,
                 threads=DEFAULT_THREADS):
    queryq = Queue.Queue(DEFAULT_THREADS)
    replyq = Queue.Queue()
    workers = [threaded_work.worker(target=worker, 
                                    args=(queryq, replyq))
               for j in xrange(threads)]
    ql = threaded_work.worker(target=query_listener, args=(queries, replyq))

    do_queries(queries, queryq, pace, time.time() + 60*run_time)

    for t in workers:
        queryq.put([None, None])  # Tell the workers to finish up.
    for t in workers:
        t.join()                  # Wait for them to, in fact, finish.

    replyq.put([None, None, None]) # Tell the listener to finish.
    ql.join()                     # and wait for it.


def setup_queries_from_xml(collections):
    queries = {}
    for collection in collections:
        queries[collection] = {}
        expected_results = etree.parse(collection + '-results.xml').getroot()
        for query in expected_results.xpath('query'):
            queries[collection][query] = query.get('count')
    return queries


def main():
    op = optparse.OptionParser()
    op.add_option('-p', '--pace', default=DEFAULT_PACE,
                  type='float', metavar='N',
                  help='Issue a new search request every N seconds [%default]')
    op.add_option('-r', '--run-time', default=DEFAULT_RUN_TIME,
                  type='int', metavar='N',
                  help='Run for N minutes (approximately) [%default]')
    op.add_option('-t', '--threads', default=DEFAULT_THREADS,
                  type='int', metavar='N',
                  help='Run with N threads [%default]')
    op.add_option('-c', '--collections', default=DEFAULT_COLLECTIONS,
                  metavar='LIST',
                  help='LIST of collection names to search [%default]')
    (optionsObject, args) = op.parse_args()
    if args:
        op.error('Unknown arguments on the command line: %s' % args)
    # Get a simple Python 'dict' of the options (easier to use).
    options = optionsObject.__dict__
    print 'Running with these options:'
    keys = options.keys()
    keys.sort()
    for key in keys:
        print '\t', key, '=', options[key]

    # Try splitting on space first, then comma
    collection_list = options['collections'].split(' ')
    if len(collection_list) == 1:
        collection_list = options['collections'].split(',')
    del options['collections']
    options['queries'] = setup_queries_from_xml(collection_list)
    
    status = threaded_work.top(query_driver, kwargs=options).get()
    if status == 0:
        msg('Test Passed.')
    else:
        msg('Test Failed (sleeping to let messages print).')
        time.sleep(2.0)
        msg('Test Failed.')
    return status


if __name__ == "__main__":
    # Allow the user to use Control-C to stop the test.
    threaded_work.allow_control_c()
    sys.exit(main())
