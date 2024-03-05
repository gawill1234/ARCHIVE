#!/usr/bin/python

import generate
import math
import newhelpers as cb
import os
import optparse
import Queue
import sys
import threaded_work
import time
import velocityAPI
from lxml import etree

# Tuning points (see the arguments to the "main" method below):
# total collection count
# number of collections to enqueue to in parallel
# number of enqueues to run in parallel to each collection
# average document size
# number of documents per enqueue request
# total number of documents to each collection

# I'd like the code itself to make the thread hierarchy more clear.
# Something should be abstracted out...
#
# To leverage 'threaded_work's help with fast exits,
# a single thread is created: 'run_test'
# 'run_test' creates four threads:
#               'create_collections'
#               'collection_driver' (that does enqueuing)
#               'check_collections' (check index size)
# 'collection_driver' creates a thread pool of 'collection_work' threads.
# Each 'collection_work' thread creates a thread pool of 'enqueuer' threads.


SEARCH_START=['all', 'each', 'never']
WORD_LIST = []
avoid_bug_19332 = False         # May be set True via command line option.
avoid_bug_18135 = False         # May be set True via command line option.

msg = cb.msg

def enqueuer(collection_name,
             direct_enqueue,
             synchronization,
             index_atomic,
             doc_q):
    """This is the 'run' method for enqueueing docs."""
    vapi = velocityAPI.VelocityAPI()

    doc_list = doc_q.get()
    while doc_list:
        url_text_list = [('nowhere://' + str(hash(text)), text)
                         for text in doc_list]
        retrying = True
        retries = 0
        while retrying:
            try:
                cb.do_enqueue(vapi,
                              collection_name,
                              url_text_list,
                              direct_enqueue,
                              synchronization,
                              index_atomic)
                retrying = False
            except velocityAPI.VelocityAPIexception:
                ex_xml, ex_text = sys.exc_info()[1]
                if retries > 9:
                    raise
                retries += 1
                msg('retry %d after exception %s' % (retries, collection_name))

        doc_list = doc_q.get()


def collection_work(collection_q,
                    check_q,
                    doc_count,
                    direct_enqueue,
                    synchronization,
                    index_atomic,
                    average_doc_size,
                    enqueue_size,
                    num_worker_threads):
    """This is the 'run' method for handling each collection."""
    global avoid_bug_19332
    while True:
        collection_name = collection_q.get()
        msg('starting enqueues to ' + collection_name)
        c = generate.Collection(WORD_LIST,
                                doc_count,
                                average_doc_size,
                                stddev=average_doc_size/100.0,
                                random_seed=collection_name)
        # Try to stay a little ahead...
        doc_q = Queue.Queue(num_worker_threads+2)
        my_children = [threaded_work.worker(target=enqueuer,
                                            args=(collection_name,
                                                  direct_enqueue,
                                                  synchronization,
                                                  index_atomic,
                                                  doc_q))
                       for i in range(num_worker_threads)]

        doc_list = []
        first_put = True
        for doc in c.docs():
            doc_list += [doc]
            if len(doc_list) >= enqueue_size:
                if avoid_bug_19332 and first_put:
                    # Hack around bug 19332 by spoon feeding the first enqueue.
                    first_put = False
                    url_text_list = [('nowhere://' + str(hash(text)), text)
                                     for text in doc_list]
                    cb.do_enqueue(velocityAPI.VelocityAPI(),
                                  collection_name,
                                  url_text_list,
                                  direct_enqueue,
                                  synchronization,
                                  index_atomic)
                    msg('dodging bug 19332 for ' + collection_name)
                    time.sleep(2)
                else:
                    doc_q.put(doc_list)
                doc_list = []

        if doc_list:
            doc_q.put(doc_list)

        # Tell my children to finish up.
        for t in my_children:
            doc_q.put(None)

        for t in my_children:
            t.join()

        msg('finished enqueues to ' + collection_name)

        # Tell the checker to take a look
        check_q.put(collection_name)


def collection_driver(collection_name_set,
                      collection_queue,
                      check_q,
                      enqueue_collections,
                      enqueues,
                      direct_enqueue,
                      synchronization,
                      index_atomic,
                      doc_size,
                      enqueue_size,
                      collection_size):
    """Launch a pool of threads for handling collections.

    Feed collection names into those threads either at create time
    (from my parent) or, avoiding bug 18135, as the collection broker
    becomes aware of the collections."""
    vapi = velocityAPI.VelocityAPI()
    if avoid_bug_18135:
        collection_q = Queue.Queue(2*enqueue_collections)
    else:
        collection_q = collection_queue

    my_children = [threaded_work.worker(target=collection_work,
                                        args=(collection_q,
                                              check_q,
                                              collection_size,
                                              direct_enqueue,
                                              synchronization,
                                              index_atomic,
                                              doc_size,
                                              enqueue_size,
                                              enqueues))
                   for i in range(enqueue_collections)]

    if avoid_bug_18135:
        msg('avoiding Bug 18135 ...')
        remaining_collections = set(collection_name_set)
        while remaining_collections:
            cb_known_names = cb.get_names(vapi)
            none_found = True
            for name in cb_known_names:
                if name in remaining_collections:
                    none_found = False
                    remaining_collections.remove(name)
                    collection_q.put(name)  # This will block when the queue is full.

            if none_found:
                time.sleep(10.0)


def create_idle_collections(idle_collections):
    if not idle_collections:
        return

    format = 'idle-%02d'
    idle_collection_names = [format % i for i in xrange(int(idle_collections))]
    msg('create and start idle collections')

    # FIXME This will fail if the idle collections already exist.
    for collection_name in idle_collection_names:
        vapi.search_collection_create(collection=collection_name)
        vapi.search_collection_crawler_start(collection=collection_name)

    msg('idle collections started, sleeping 1 minute...')
    time.sleep(60)          # let the target system settle down.


def stop_idle_collections(idle_collections):
    if not idle_collections:
        return

    format = 'idle-%02d'
    idle_collection_names = [format % i for i in xrange(int(idle_collections))]

    # Shutdown my idle collections.
    # This may release off-line queues for processing.
    for collection_name in idle_collection_names:
        vapi.search_collection_crawler_stop(collection=collection_name)

    for collection_name in idle_collection_names:
        vapi.search_collection_indexer_stop(collection=collection_name)



def create_collections(collection_name_set,
                       q,
                       based_on='default-broker-push',
                       start_crawler=False,
                       delete_first=False):
    vapi = velocityAPI.VelocityAPI()
    msg('create collections')

    # Create my collections
    for name in cb.shuffle(collection_name_set):
        cb.create_collection(vapi,
                             name,
                             based_on=based_on,
                             delete_first=delete_first)
        if start_crawler:
            resp = vapi.search_collection_crawler_start(collection=name)
        q.put(name)

    msg('collections created')


def index_n_docs(vapi, collection_name):
    scs = vapi.search_collection_status(collection=collection_name)
    return sum([int(n) for n in scs.xpath('vse-index-status/@n-docs')])


def check_collections(collection_count, collection_size, check_q):
    vapi = velocityAPI.VelocityAPI()
    no_progress = 0
    pending = {}
    remaining = collection_count
    while remaining > 0:
        no_progress += 1
        # We should see something happen in well less than half-an-hour.
        assert not pending or no_progress < 180, \
            'Not enough progress while checking collections.'
        try:
            name = check_q.get(timeout=10) # This is the sleep...
            pending[name] = -1
            msg('begin checking %s' % name)
        except Queue.Empty:
            pass
        for name in pending.keys():
            n = index_n_docs(vapi, name)
            if collection_size == n:
                no_progress = 0
                del pending[name]
                remaining -= 1
                msg('%s is good, %d remaining' % (name, remaining))
            elif pending[name] != n:
                no_progress = 0
                pending[name] = n


def run_test(based_on,
             collection_size,
             collections,
             delete_first,
             direct_enqueue,
             doc_size,
             enqueue_collections,
             enqueue_size,
             enqueues,
             index_atomic,
             idle_collections,
             name_base,
             start_crawler,
             synchronization,
             wait_for_creates):
    format = '%s%%0%dd' % (name_base, 1+math.log10(max(1,int(collections)-1)))
    collection_name_set = frozenset([format % i
                                     for i in xrange(int(collections))])

    try:
        # Only available in Python 2.6
        # We like this, because it's much more agressive about using newly
        # created collections soon after they are created.
        collection_queue = Queue.LifoQueue(0)
    except AttributeError:
        collection_queue = Queue.Queue(0)

    create_idle_collections(idle_collections)

    # Startup a collection creator.
    t_creator = threaded_work.worker(target=create_collections,
                                     args=(collection_name_set,
                                           collection_queue,
                                           based_on,
                                           start_crawler,
                                           delete_first))
    if wait_for_creates:
        t_creator.join()

    check_q = Queue.Queue(0)
    # Startup a handler for enqueueing to collections.
    t_enqueuer = threaded_work.worker(target=collection_driver,
                                      args=(collection_name_set,
                                            collection_queue,
                                            check_q,
                                            enqueue_collections,
                                            enqueues,
                                            direct_enqueue,
                                            synchronization,
                                            index_atomic,
                                            doc_size,
                                            enqueue_size,
                                            collection_size))
    # Startup a collection checker.
    t_checker = threaded_work.worker(target=check_collections,
                                     args=(len(collection_name_set),
                                           collection_size,
                                           check_q))

    t_enqueuer.join()

    # Once the enqueues are done (or mostly done), shutdown idle
    # collections to give the collection broker more machine to work with.
    stop_idle_collections(idle_collections)

    # Once everything is checked, we're done.
    t_checker.join()


def main():
    global WORD_LIST
    global avoid_bug_18135
    global avoid_bug_19332
    op = optparse.OptionParser()
    op.add_option('-c', '--collections', default=20,
                  type='int', metavar='N',
                  help='create and work with N collections [%default]')
    op.add_option('-z', '--collection-size', default=2000,
                  type='int', metavar='N',
                  help='enqueue a total of N documents'
                  ' to each collection [%default]')
    op.add_option('-d', '--doc-size', default=10000,
                  type='int', metavar='BYTES',
                  help='Average document size [%default]')
    op.add_option('-n', '--enqueue-size', default=10,
                  type='int', metavar='N',
                  help='N documents per enqueue request [%default]')
    op.add_option('-e', '--enqueues', default=10,
                  type='int', metavar='N',
                  help='N parallel enqueues to each collection [%default]')
    op.add_option('-q', '--enqueue-collections', default=10,
                  type='int', metavar='N',
                  help='Enqueue to N collections in parallel [%default]')
    op.add_option('-i', '--idle-collections', default=0,
                  type='int', metavar='N',
                  help='Number of idle, running collections to create'
                  ' and start (to limit on-line enqueuing) [%default]')
    op.add_option('-s', '--synchronization', default='indexed-no-sync',
                  metavar='OPTION',
                  help='crawl-url synchronization=OPTION [%default]')
    op.add_option('-A', '--index-atomic', default=False,
                  action='store_true',
                  help='Wrap enqueue batches in index-atomic.')
    op.add_option('--dictionary',
                  default=os.environ['TEST_ROOT'] + '/files/words',
                  metavar='PATH',
                  help='PATH to a dictionary [%default]')
    op.add_option('-B', '--based-on', default='default-broker-push',
                  metavar='NAME',
                  help='"based-on" collection NAME for creates [%default]')
    op.add_option('-N', '--name-base', default='cb-tunable-',
                  metavar='NAME',
                  help='NAME for new collections. Will have digits appended'
                  ' to the end to make each name unique. [%default]')
    op.add_option('-D', '--direct-enqueue', default=False,
                  action='store_true',
                  help='Enqueue directly (not through collection-broker)')
    op.add_option('-C', '--start-crawler', default=False,
                  action='store_true',
                  help='Start the crawler for each collection'
                  ' before enqueuing to the collection.')
    op.add_option('-X', '--delete-first', default=False,
                  action='store_true',
                  help='Delete existing collections and recreate.')
    op.add_option('-W', '--wait-for-creates', default=False,
                  action='store_true',
                  help='Wait for all of the creates to complete'
                  ' before starting enqueues.')
    op.add_option('--bug-18135', default=False,
                  action='store_true',
                  help='Use a workaround for Bug 18135. Wait for a'
                  ' collection to appear in collection-broker-status'
                  ' before starting enqueues.')
    op.add_option('--bug-19332', default=False,
                  action='store_true',
                  help='Use a workaround for Bug 19332. Do a single'
                  ' enqueue before starting concurrent enqueues.')
    (optionsObject, args) = op.parse_args()
    if args:
        op.error('Unknown arguments on the command line: ' + args)
    # Get a simple Python 'dict' of the options (easier to use).
    options = optionsObject.__dict__
    print 'Running with these options:'
    keys = options.keys()
    keys.sort()
    for key in keys:
        print '\t', key, '=', options[key]

    dictionary_path = options['dictionary']
    f = open(dictionary_path)
    WORD_LIST = [word.strip() for word in f.readlines() if word.strip() != '']
    f.close()
    if len(WORD_LIST) < 1000:
        op.error('Too few words in ' + dictionary_path)
    del options['dictionary']
    avoid_bug_18135 = options['bug_18135']
    del options['bug_18135']
    avoid_bug_19332 = options['bug_19332']
    del options['bug_19332']
    status = threaded_work.top(run_test, kwargs=options).get()
    if status == 0:
        msg('Test Passed.')
    else:
        msg('Test Failed (sleeping to let messages print).')
        time.sleep(2.0)
        msg('Test Failed.')
    return status


################################################################
# Run the test.
if __name__ == "__main__":
    # Allow the user to use Control-C to stop the test.
    threaded_work.allow_control_c()
    sys.exit(main())
