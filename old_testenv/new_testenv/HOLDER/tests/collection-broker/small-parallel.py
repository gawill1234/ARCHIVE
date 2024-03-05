#!/usr/bin/python

"""One of a series of tests which:
    1. creates many collections
    2. enqueues a single item into each new collection
    3. does search against each collection
    4. stops the collections created in step 1

This version does a single search against each collection and then, in
addtional passes, only re-queries collections where the expected
results have not yet been seen. The idea here is to give the
collection broker a chance to handle off-line enqueued data.

The interesting test failure mode is when there is no progress after a
long time.

This specific version does *not* explictly start the collections
(between steps 1 and 2 above). This will test for fixes of Bugs 18060
and 18134.
"""

import helpers as cb
import os
import random
import smallParallelQueryOnly
import sys
import time
import velocityAPI

def do_test(count=100, no_progress_limit=60*60):
    vapi = velocityAPI.VelocityAPI()

    name_format = 'cb-sm-parallel-%06d'
    collection_name_list = [name_format % i for i in range(int(count))]

    # Make sure we shuffle the deck the same ways each time.
    # We want cleanly reproducable tests.
    random.seed(count)

    print time.ctime(), 'starting test with count of', int(count)
    # Make sure the basic stuff I care about is running
    vapi.search_service_start()

    print time.ctime(), 'creating collections'
    for name in cb.shuffle(collection_name_list):
        vapi.search_collection_create(collection=name)
    cb.status(vapi, 'cb_status_initial.xml')

    print time.ctime(), 'collections created'
    # Don't break while waiting for Bug 18135 to be resolved.
    if not os.environ.has_key('CBNOWAIT'):
        cb.wait_for_all(vapi, collection_name_list)
        cb.status(vapi, 'cb_status_after_wait.xml')

    print time.ctime(), 'starting enqueues'
    step = max(100, count/100) # Run as many as one hundred parallel processes.
    pid_list = []
    for n in range(0, int(count), step):
        pid_list.append(os.spawnl(os.P_NOWAIT,
                                  './enqueue.py',
                                  'enqueue.py',
                                  name_format, 
                                  str(n),
                                  str(min(n+step, count))))
        time.sleep(0.1) # Don't pound my test driver machine too hard.

    for pid in pid_list:
        ret_pid, status = os.waitpid(pid, 0)
        assert status == 0, \
            'status returned for pid ' + str(ret_pid) + ' was ' + str(status>>8)

    cb.status(vapi, 'cb_status_after_enqueues.xml')

    print time.ctime(), 'enqueues completed'

    smallParallelQueryOnly.do_test(count, no_progress_limit)


################################################################
# Run the test.
if __name__ == "__main__":
    count = 100    # Default to smallish run, creating 100 collections
    if len(sys.argv) > 1:        # If we're given a different count,
        count = int(sys.argv[1]) # use it.
    do_test(count)

