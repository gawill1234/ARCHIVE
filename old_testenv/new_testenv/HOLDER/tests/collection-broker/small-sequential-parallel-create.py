#!/usr/bin/python

"""One of a series of tests which:
    1. creates many collections
    2. enqueues a single item into each new collection
    3. does search against each collection
    4. stops and deletes the collections created in step 1

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

    name_format = 'cb-sm-seq-parallel-create-%06d'
    collection_name_list = [name_format % i for i in range(int(count))]

    # Make sure we shuffle the deck the same ways each time.
    # We want cleanly reproducable tests.
    random.seed(count)

    print time.ctime(), 'starting test with count of', int(count)
    # Make sure the basic stuff I care about is running
    vapi.search_service_start()

    print time.ctime(), 'creating collections'
    step = max(100, count/100) # Run as many as one hundred parallel processes.
    pid_list = []
    for n in range(0, int(count), step):
        pid_list.append(os.spawnl(os.P_NOWAIT,
                                  './create-collections.py',
                                  'create-collections.py',
                                  name_format, 
                                  str(n),
                                  str(min(n+step, count))))
        time.sleep(0.1) # Don't pound my test driver machine too hard.

    for pid in pid_list:
        ret_pid, status = os.waitpid(pid, 0)
        assert status == 0, \
            'status returned for pid ' + str(ret_pid) + ' was ' + str(status>>8)

    cb.status(vapi, 'cb_status_initial.xml')

    print time.ctime(), 'collections created'
    # Don't break while waiting for Bug 18135 to be resolved.
    if not os.environ.has_key('CBNOWAIT'):
        cb.wait_for_all(vapi, collection_name_list)
        cb.status(vapi, 'cb_status_after_wait.xml')

    print time.ctime(), 'starting enqueues'
    for name in cb.shuffle(collection_name_list):
        url = 'nowhere://' + name
        text = name + '\nThere are many twisty passages, all alike.'
        cb.do_enqueue(vapi, name, url, text)
    cb.status(vapi, 'cb_status_after_enqueues.xml')

    print time.ctime(), 'enqueues completed'
    print time.ctime(), 'starting searches'
    working_list = collection_name_list[:]
    last_found_time = time.time()
    while working_list:
        found = []
        for name in cb.shuffle(working_list):
            if cb.do_single_search(vapi,
                                   name,
                                   ['There are many twisty passages,'
                                    ' all alike.',
                                    'url="nowhere://' + name]):
                found.append(name)
                working_list.remove(name)
        if found:
            print time.ctime(), 'found\t' + '\n\t\t\t\t'.join(found)
            last_found_time = time.time()
        else:
            if len(working_list) < 10:
                print time.ctime(), 'nothing found, need:', working_list
            else:
                print time.ctime(), 'nothing found,', \
                    len(working_list), 'remaining.'
            assert time.time() - last_found_time < no_progress_limit, \
                'Too much time has passed since new results found.'
            vapi.search_service_start() # Sometimes we kill it off...

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

