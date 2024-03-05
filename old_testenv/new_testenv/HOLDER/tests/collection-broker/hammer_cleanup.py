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

def run_cleanup(count, thread_pool_size, delete=True):
    format = 'cb-hammer-%%0%dd' % (1+math.log10(count-1))
    collection_name_set = frozenset(((format % i) for i in xrange(int(count))))
    work_q = Queue.Queue(0)

    #cb.msg('cleanup %d collections' % count) 
    thread_list = [threaded_work.worker(target=worker, args=[work_q])
                   for i in xrange(thread_pool_size)]
    for name in list(collection_name_set):
        work_q.put([cb.delete_with_retry, {'collection':name}])

    for thread in thread_list:
        work_q.put(None)
    for thread in thread_list:
        thread.join()

def main():
    count=1000
    options = {'count':count, 'thread_pool_size':250}

    cb.msg('Deleting %s collections regardless of Pass/Fail status' % count)
    cleanup_status = threaded_work.top(run_cleanup, kwargs=options).get()
    cb.msg('Finished deleting collections')

    return cleanup_status

################################################################
# Run the test.
if __name__ == "__main__":
    # Allow the user to use Control-C to stop the test.
    threaded_work.allow_control_c()
    sys.exit(main())
