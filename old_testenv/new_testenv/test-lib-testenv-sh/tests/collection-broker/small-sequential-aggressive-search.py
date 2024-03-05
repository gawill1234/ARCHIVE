#!/usr/bin/python

"""This test:
    1. creates many collections
    2. enqueues a single item into each new collection,
                  immediately after the create
    3. does searches against each collection until the enqueued data is found
    4. stops the collections created in step 1

This version is aggresive about the searches, demanding that the
result be found for a specific collection in just a few retries taking
less than one minute.
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

def do_test(count=100):
    vapi = velocityAPI.VelocityAPI()

    format = 'cb-seq-agg-%%0%dd' % (1+math.log10(count))
    collection_name_set = frozenset([(format % i) for i in range(int(count))])

    # Make sure we shuffle the deck the same ways each time.
    # We want cleanly reproducable tests.
    random.seed(count)

    msg('starting test with count of %d' % int(count))
    # Make sure the basic stuff I care about is running
    vapi.search_service_start()

    msg('creating each collection and enqueuing to it')
    cb.default_collection(vapi)
    for name in cb.shuffle(collection_name_set):
        cb.create_collection(vapi, collection=name)
        url = 'nowhere://' + name
        text = name + '\nThere are many twisty passages, all alike.'
        cb.do_enqueue(vapi, name, [(url, text)])
    msg('collections created')
    msg('starting searches')
    for name in cb.shuffle(collection_name_set):
        cb.do_search_aggresive(vapi, 
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

