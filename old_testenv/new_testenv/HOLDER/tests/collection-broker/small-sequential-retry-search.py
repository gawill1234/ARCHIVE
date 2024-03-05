#!/usr/bin/python

"""This test:
    1. creates many collections
    2. enqueues a single item into each new collection
    3. does a single search against each collection
    4. retries the search only against collections with no result.
    5. stops the collections created in step 1

This version does a single search against each collection and then, in
addtional passes, only re-queries collections where the expected
results have not yet been seen. The idea here is to give the
collection broker a chance to handle off-line enqueued data.

The interesting test failure mode is when there is no progress after a
long time.
"""

import math
import newhelpers as cb
import os
import random
import sys
import time
import vapi_interface
import velocityAPI

msg = cb.msg

def do_test(count=100, no_progress_limit=60*60):
    yy = vapi_interface.VAPIINTERFACE()
    vapi = velocityAPI.VelocityAPI()
    
    # Make sure we shuffle the deck the same way each time.
    # We want cleanly reproducable tests.
    random.seed(count)

    msg('starting test with count of %d' % int(count))
    # Make sure the basic stuff I care about is running
    vapi.search_service_start()

    msg('creating collections')
    default_name = cb.default_collection(vapi)
    format = 'cb-seq-retry-%%0%dd' % (1+math.log10(count))
    collection_name_set = frozenset(yy.create_multiple_collections(
            count,
            format,
            default_name,
            delete_first=False))
    msg('collections created')
    # Support a workaround for Bug 18135 (now resolved).
    if os.environ.has_key('CBWAIT'):
        cb.wait_for_all(vapi, collection_name_set)

    msg('starting enqueues')
    for name in cb.shuffle(collection_name_set):
        url = 'nowhere://' + name
        text = name + '\nThere are many twisty passages, all alike.'
        cb.do_enqueue(vapi, name, [(url, text)])

    msg('enqueues completed')
    msg('starting searches')
    working_set = set(collection_name_set)
    last_found_time = time.time()
    while working_set:
        found = []
        for name in cb.shuffle(working_set):
            if cb.do_single_search(vapi,
                                   name,
                                   'There are many twisty passages, all alike.',
                                   'nowhere://' + name):
                found.append(name)
                working_set.remove(name)
        # Talk about what was found...
        if not found:
            msg('nothing found.')
        else:
            msg('%d found, including: %s' %
                (len(found), ' & '.join(found[:2])))
            last_found_time = time.time()
        # Talk about what's left (if anything)...
        if working_set:
            msg('%d remain, including: %s & %s' %
                (len(working_set), 
                 random.choice(list(working_set)), 
                 random.choice(list(working_set))))
        # deal with loop control: either punt or sleep
        if not found:
            assert time.time() - last_found_time < no_progress_limit, \
                'Too much time has passed since new results found.'
            vapi.search_service_start() # Sometimes we kill it off...
            time.sleep(60)

    msg('searches completed')

    delete_collections=os.environ.has_key('REMOVECOLLECTIONS')

    for name in cb.shuffle(collection_name_set):
        vapi_interface.VAPIINTERFACE().cleanup_collection(
            name, 
            delete=delete_collections,
            retry=True)
    msg('cleanup complete')


################################################################
# Run the test.
if __name__ == "__main__":
    count = 100    # Default to smallish run, creating 100 collections
    if len(sys.argv) > 1:        # If we're given a different count,
        count = int(sys.argv[1]) # use it.
    do_test(count)

