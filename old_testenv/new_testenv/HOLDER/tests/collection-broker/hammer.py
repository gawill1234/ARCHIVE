#!/usr/bin/python

import math
import newhelpers as cb
import Queue
import sys
import threaded_work
import time
import velocityAPI
from lxml import etree


def worker(work_q):
    vapi = velocityAPI.VelocityAPI()
    work_item = work_q.get()
    while work_item is not None:
        action, args = work_item
        action(vapi, **args)
        work_item = work_q.get()


def run_test(count, thread_pool_size):
    vapi = velocityAPI.VelocityAPI()
    format = 'cb-hammer-%%0%dd' % (1+math.log10(count-1))
    collection_name_set = frozenset(((format % i) for i in xrange(int(count))))
    default_name = cb.default_collection(vapi)
    work_q = Queue.Queue(0)

    cb.msg('create %d collections' % count)
    thread_list = [threaded_work.worker(target=worker, args=[work_q])
                   for i in xrange(thread_pool_size)]
    for name in cb.shuffle(collection_name_set):
        work_q.put([cb.create_collection, {'collection':name,
                                           'delete_first':True}])

    for thread in thread_list:
        work_q.put(None)
    for thread in thread_list:
        thread.join()

    cb.msg('enqueue to each collection')
    thread_list = [threaded_work.worker(target=worker, args=[work_q])
                   for i in xrange(thread_pool_size)]
    for name in cb.shuffle(collection_name_set):
        url = 'nowhere://' + name
        text = name + '\nThere are many twisty passages, all alike.'
        work_q.put([cb.do_enqueue, {'collection_name':name,
                                    'url_text_list':[(url, text)]}])

    for thread in thread_list:
        work_q.put(None)
    for thread in thread_list:
        thread.join()

    cb.msg('search each collection')
    thread_list = [threaded_work.worker(target=worker, args=[work_q])
                   for i in xrange(thread_pool_size)]
    for name in cb.shuffle(collection_name_set):
        work_q.put(
            [cb.do_single_search,
             {'collection_name':name,
              'expect_snippet':'There are many twisty passages, all alike.',
              'expect_url':'nowhere://' + name}])

    for thread in thread_list:
        work_q.put(None)
    for thread in thread_list:
        thread.join()


def main():
    options = {'count':1000, 'thread_pool_size':250}
    status = threaded_work.top(run_test, kwargs=options).get()
    if status == 0:
        cb.msg('Test Passed.')
    else:
        cb.msg('Test Failed (sleeping to let messages print).')
        time.sleep(2.0)
        cb.msg('Test Failed.')
    return status


################################################################
# Run the test.
if __name__ == "__main__":
    # Allow the user to use Control-C to stop the test.
    threaded_work.allow_control_c()
    sys.exit(main())
