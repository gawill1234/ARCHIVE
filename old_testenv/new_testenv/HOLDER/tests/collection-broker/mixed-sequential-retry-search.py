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
import mixedSeqSearchOnly as searchOnly
import os
import random
import sys
import time
import velocityAPI

def do_test(count=100, no_progress_limit=60*60):
    vapi = velocityAPI.VelocityAPI()

    collection_name_list = ['cb-mixed-seq-%06d' % i 
                            for i in range(int(count))]

    # Make sure we shuffle the deck the same ways each time.
    # We want cleanly reproducable tests.
    random.seed(count)

    with open('/usr/share/dict/words') as f:
        nl_words = f.readlines()
    word_list = [word.strip() for word in nl_words]
    docs = {}
    for name in collection_name_list:
        doc_count = random.randint(2,1000)
        doc_size = random.randint(2,1000000)
        print name, doc_count, doc_size
        docs[name] = generate.collection(word_list,
                                         doc_count,
                                         doc_size,
                                         random_seed=name)

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
    f = open('querywork/mixed-sequential-retry-search.items', 'w')
    for name in cb.shuffle(collection_name_list):
        save_index = random.randint(0,docs[name].doc_count-1)
        print time.ctime(), name, save_index
        for text in docs[name].docs():
            save_index -= 1
            if save_index == 0:
                f.write(name + ' ' + text + '\n')
            url = 'nowhere://' + str(hash(text))
            cb.do_enqueue(vapi, name, url, text)

    f.close()

    cb.status(vapi, 'cb_status_after_enqueues.xml')

    print time.ctime(), 'enqueues completed'

    searchOnly.do_test(count, no_progress_limit)


################################################################
# Run the test.
if __name__ == "__main__":
    count = 100    # Default to smallish run, creating 100 collections
    if len(sys.argv) > 1:        # If we're given a different count,
        count = int(sys.argv[1]) # use it.
    do_test(count)

