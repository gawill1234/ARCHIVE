#!/usr/bin/python

import math
import newhelpers as cb
import Queue
import sys
import threaded_work
import time
import velocityAPI
from lxml import etree

def report(vapi, collection_name):
    cbs = vapi.collection_broker_status()
    scs = vapi.search_collection_status(collection=collection_name)
    cb.msg('collection broker status says:')
    for n,v in cbs.xpath('collection[@name="%s"]'%collection_name)[0].attrib.items():
        cb.msg('\t%s="%s"'%(n,v))
    cb.msg('search collection status says:')
    for xpath in ['crawler-status/@service-status',
                  'crawler-status/@n-offline-queue',
                  'vse-index-status/@service-status',
                  'vse-index-status/@idle',
                  'vse-index-status/@n-docs']:
        cb.msg('\t%s = %s' %(xpath, scs.xpath(xpath)))
    return scs.xpath('sum(vse-index-status/@n-docs)')


def worker(work_q):
    vapi = velocityAPI.VelocityAPI()
    work_item = work_q.get()
    while work_item is not None:
        action, args = work_item
        action(vapi, **args)
        work_item = work_q.get()


def run_test(thread_pool_size, doc_count):
    vapi = velocityAPI.VelocityAPI()
    collection_name = 'cb-thunder'
    default_name = cb.default_collection(vapi)
    work_q = Queue.Queue(0)

    thread_list = [threaded_work.worker(target=worker, args=[work_q])
                   for i in xrange(int(thread_pool_size))]

    enqueue_list = [{'collection_name':collection_name,
                     'url_text_list':[('%s://%4d'%(collection_name,i),
                                       '\nThere are %d twisty passages, all alike.'%i)],
                     'direct_enqueue':False}
                    for i in xrange(int(doc_count))]

    cb.create_collection(vapi, collection_name, delete_first=True)
    cb.msg('many enqueues')
    for enqueue_item in enqueue_list:
        work_q.put([cb.do_enqueue, enqueue_item])

    for thread in thread_list:
        work_q.put(None)
    for thread in thread_list:
        thread.join()
    cb.msg('enqueue calls complete')

    n_docs = report(vapi, collection_name)
    assert n_docs == doc_count, 'Unexpected value %d for "n-docs"' % n_docs



def main():
    options = {'thread_pool_size':500, 'doc_count':2000}
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
