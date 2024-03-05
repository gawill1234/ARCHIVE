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
    vapi = velocityAPI.VelocityAPI()

    format = 'cb-seq-wait-%%0%dd' % (1+math.log10(count))
    collection_name_set = frozenset([(format % i) for i in range(int(count))])

    # Make sure we shuffle the deck the same ways each time.
    # We want cleanly reproducable tests.
    random.seed(count)

    msg('starting test with count of %d' % int(count))
    # Make sure the basic stuff I care about is running
    vapi.search_service_start()

    msg('creating collections')
    cb.default_collection(vapi, crawler_mb=1, indexer_mb=1)
    for name in cb.shuffle(collection_name_set):
        cb.create_collection(vapi, name)

    msg('collections created, starting enqueues')
    for name in cb.shuffle(collection_name_set):
        url = 'nowhere://' + name
        text = name + '\nThere are many twisty passages, all alike.'
        cb.do_enqueue(vapi, name, [(url, text)])

    msg('enqueues completed')
    cb.wait_for_enqueues(vapi, collection_name_set)
    msg('starting searches')
    for name in cb.shuffle(collection_name_set):
        assert cb.do_single_search(
            vapi,
            name,
            'There are many twisty passages, all alike.',
            'nowhere://' + name)

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

