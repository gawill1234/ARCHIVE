#!/usr/bin/python

"""One of a series of tests which:
    1. creates many collections
    2. enqueues a a series of items into each new collection
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

import generate
import helpers as cb
import os
import random
import sys
import time
import velocityAPI

def do_test(count=100, no_progress_limit=60*60):
    vapi = velocityAPI.VelocityAPI()

    # Make sure we shuffle the deck the same ways each time.
    # We want cleanly reproducable tests.
    random.seed(count)

    # Grab a single result from each collection (this is CPU intense).
    query = {}
    expect = {}
    f = open('querywork/mixed-sequential-retry-search.items', 'r')
    for line in f:
        name, text = line.strip().split(' ',1)
        words = text.split()
        mid = len(words)/2
        # FIXME These may fail for very short docs...
        query[name] = ' '.join(words[mid-5:mid+5])
        expect[name] = [' '.join(words[mid-8:mid+8]),
                        'url="nowhere://' + str(hash(text))]

    # Make sure the basic stuff I care about is running
    vapi.search_service_start()

    collection_name_list = query.keys()

    print time.ctime(), 'starting searches'
    working_list = collection_name_list[:]
    last_found_time = time.time()
    while working_list:
        found = []
        for name in cb.shuffle(working_list):
            if cb.do_single_search(vapi, name, expect[name], query[name]):
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

