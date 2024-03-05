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

# Hammer away at starting and stopping the collection service.

hits = 0

def msg(text):
    """Just formatted output to stdout."""
    human_time = time.ctime().split()[3]
    sys.stdout.write('%s %s\n' % (human_time, str(text)))
    sys.stdout.flush()

def start_stop(collection):
    vapi = velocityAPI.VelocityAPI()
    # Just flap back and forth
    while True:
        vapi.test_search_collection_service_run_node(collection=collection,
                                                     ensure_running='true')
        vapi.test_search_collection_service_stop(collection=collection)


def run_test(thread_count):
    global hits
    vapi = velocityAPI.VelocityAPI()
    # Create a public API functions for starting and stopping the collection service.
    add_test_api(vapi, 'search-collection-service-run-node')
    add_test_api(vapi, 'search-collection-service-stop')

    cs_pl = gronk.get_pid_list('collection-service')
    assert cs_pl == [],  \
        'Failed precondition: found running collection-service(s): %s' % cs_pl

    collection = 'collection-service-stop-start-race-1'
    try:
        vapi.search_collection_create(collection=collection,
                                      based_on='default-push')
    except velocityAPI.VelocityAPIexception:
        exception, text = sys.exc_info()[1]

    for i in xrange(thread_count):
        threaded_work.worker(target=start_stop, args=[collection])

    msg('Starting and stopping the collection service in %d threads.'
        % thread_count)
    new_pids = frozenset([])
    for i in xrange(600):
        old_pids = new_pids
        time.sleep(1-(time.time()%1))
        new_pids = frozenset(gronk.get_pid_list('collection-service'))
        intersection = old_pids & new_pids
        if len(intersection) > 0:
            msg('collection service pids more than one second old: %s' %
                intersection)
            hits += 1


if __name__ == "__main__":
    # Allow the user to use Control-C to stop the test.
    threaded_work.allow_control_c()
    thread_count = 4
    if len(sys.argv) > 1:
        thread_count = int(sys.argv[1])
    status = threaded_work.top(run_test, args=[thread_count]).get()
    if status == 0 and hits == 0:
        msg('Test Passed')
    else:
        msg('Test Failed (sleeping to let messages print).')
        time.sleep(2.0)
        msg('Test Failed with %d hits.' % hits)
    sys.exit(status)
