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
    print time.ctime(), 'starting searches'

    step = max(100, count/100) # Run as many as one hundred parallel processes.
    pid_list = []
    for n in range(0, int(count), step):
        pid_list.append(os.spawnl(os.P_NOWAIT,
                                  './query.py',
                                  'query.py',
                                  name_format, 
                                  str(n),
                                  str(min(n+step, count))))
        time.sleep(0.1) # Don't pound my test driver machine too hard.

    for pid in pid_list:
        ret_pid, status = os.waitpid(pid, 0)
        assert status == 0, \
            'status returned for pid ' + str(ret_pid) + ' was ' + str(status>>8)

    print time.ctime(), 'searches completed'
    cb.status(vapi, 'cb_status_after_searches.xml')

    for name in cb.shuffle(collection_name_list):
        cb.cleanup(vapi, name, os.environ.has_key('REMOVECOLLECTIONS'))
    print time.ctime(), 'cleanup complete'


################################################################
# Run the test.
if __name__ == "__main__":
    count = 100    # Default to smallish run, creating 100 collections
    if len(sys.argv) > 1:        # If we're given a different count,
        count = int(sys.argv[1]) # use it.
    do_test(count)

