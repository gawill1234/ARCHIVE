#!/usr/bin/python

from lxml import etree
import Queue
import os
import sys
import time
import random
import threaded_work
import velocityAPI


def do_enqueue(vapi, collection, crawl_nodes, direct_enqueue=True):
    mycondition = True

    if ( direct_enqueue == "Random" ):
       g = random.Random(time.time())
       anum = g.randint(0, 100)
       if ( ( anum % 3 ) == 0 ):
          mycondition = False
          print "COLLECTION_BROKER:", collection
       else:
          mycondition = True
          print "DIRECT:", collection
    
    if mycondition:
        try:
           resp = vapi.search_collection_enqueue_xml(
                collection=collection,
                crawl_nodes=etree.tostring(crawl_nodes))
           assert resp.tag == 'crawler-service-enqueue-response', \
                etree.tostring(resp)
           assert resp.get('n-failed') == '0', etree.tostring(resp)
        except :
           print "EXCEPTION  BEGIN #############DIRECT################"
           print "Exception on direct enqueue", collection
           print "ERROR:", sys.exc_info()[0]
           print "ERROR TEXT:", sys.exc_info()[1]
           print "EXCEPTION  END   #############DIRECT################"
           do_enqueue(vapi, collection, crawl_nodes, direct_enqueue=True)
    else:
        try:
           resp = vapi.collection_broker_enqueue_xml(
               collection=collection,
               crawl_nodes=etree.tostring(crawl_nodes))
           assert resp.tag == 'collection-broker-enqueue-response', \
               etree.tostring(resp)
           assert resp.get('status') == 'success', etree.tostring(resp)
           assert resp[0].tag == 'crawler-service-enqueue-response', \
               etree.tostring(resp)
           assert resp[0].get('n-failed') == '0', etree.tostring(resp)
        except :
           print "EXCEPTION  BEGIN ##########COLLECTION#BROKER########"
           print "Exception on cb enqueue", collection
           print "ERROR:", sys.exc_info()[0]
           print "ERROR TEXT:", sys.exc_info()[1]
           print "EXCEPTION  END   ##########COLLECTION#BROKER########"
           do_enqueue(vapi, collection, crawl_nodes, direct_enqueue=False)

    return 0

def delete_data(url):

    print "Deleting: ", url
    crawl_urls = etree.Element('crawl-urls')
    crawl_url = etree.SubElement(crawl_urls, 'crawl-delete',
                                 **{'url':url.decode('utf-8', 'replace')})

    #print etree.tostring(crawl_urls)

    return crawl_urls

def getfiletype(path):

   if ( path.endswith('.html') ):
      return 'text/html'

   if ( path.endswith('.xml') ):
      return 'text/xml'

   if ( path.endswith('.vxml') ):
      return 'application/vxml-unnormalized'

   if ( path.endswith('.xls') ):
      return 'application/ms-ooxml-excel'

   if ( path.endswith('.doc') ):
      return 'application/ms-ooxml-word'

   if ( path.endswith('.pdf') ):
      return 'application/pdf'
  
   return 'text/plain'

def usablefiletype(name):
    
   if ( os.path.isdir(name) ):
      return False

   if ( os.access(name, os.R_OK) == 1 ):

      if ( name.endswith('.html') ):
         return True

      if ( name.endswith('.xml') ):
         return True

      if ( name.endswith('.vxml') ):
         return True

      if ( name.endswith('.txt') ):
         return True

      if ( name.endswith('.pdf') ):
         return True

      if ( name.endswith('.xls') ):
         return True

      if ( name.endswith('.doc') ):
         return True

   return False

#
#  Make it work for text/hml, text/xml and text/plain
#
def enqueue_data(path, url, synctype='indexed-no-sync', arena=None):
    crawl_urls = etree.Element('crawl-urls')
    crawl_data = None
    #sys.stdout.write(url + '\n')
    print "Enqueueing: ", path
    print "        as: ", url
    encontype = getfiletype(path)

    if (arena):
        crawl_url = etree.SubElement(crawl_urls, 'crawl-url',
                                     **{'url':url.decode('utf-8', 'replace'),
                                        'status':'complete',
                                        'synchronization':synctype,
                                        'enqueue-type':'reenqueued',
                                        'arena':arena})
    else:
        crawl_url = etree.SubElement(crawl_urls, 'crawl-url',
                                     **{'url':url.decode('utf-8', 'replace'),
                                        'status':'complete',
                                        'synchronization':synctype,
                                        'enqueue-type':'reenqueued'})

    crawl_data = etree.SubElement(crawl_url, 'crawl-data',
                                  **{'encoding':'base64',
                                     'content-type':getfiletype(path)})

    f = open(os.path.join(path))
    crawl_data.text = (f.read().encode('base64')).replace(" ", "").replace("\n", "") 
    #print etree.tostring(crawl_urls)

    return crawl_urls


def enqueuer(collection_name, work_q, synctype, direct_enqueue=True, arena=None):
    vapi = velocityAPI.VelocityAPI()
    path, url = work_q.get()
    beginning = time.time()
    while path and url:
        do_enqueue(vapi,
                   collection_name,
                   enqueue_data(path, url, synctype, arena), direct_enqueue)
        path, url = work_q.get()

    endoftime = time.time()
    elapsed = endoftime - beginning

    print "Exiting enqueuer:", collection_name, "after", elapsed, "seconds"

    return 0

def enqueuer_with_delete(collection_name, work_q, synctype,
                         direct_enqueue=True, arena=None):
    vapi = velocityAPI.VelocityAPI()
    path, url, deleteflag = work_q.get()

    g = random.Random(time.time())
    while path and url:

        fizzbin = g.randint(0, 1000)

        if ( fizzbin > 900 ):
            print "Fake Delete: ", url
            do_enqueue(vapi,
                   collection_name,
                   delete_data(url))
            time.sleep(1)

        do_enqueue(vapi,
                   collection_name,
                   enqueue_data(path, url, synctype, arena), direct_enqueue)
        if ( deleteflag == 'yes' ):
            #
            #   This sleep assures that the data enqueue is
            #   in place before the delete.  As long as that
            #   happens, the crawler gatekeeper should assure
            #   order.
            #
            time.sleep(1)
            do_enqueue(vapi,
                   collection_name,
                   delete_data(url))
        path, url, deleteflag = work_q.get()

        if ( not path ):
           #time.sleep(1)
           path, url, deleteflag = work_q.get()

    print "Exiting enqueuer_with_delete:", collection_name

    return 0

def enqueue_tree(collection_name, root, base_url,
                 thread_count=10, delete_which=0,
                 synctype='indexed-no-sync', direct_enqueue=True, arena=None,
                 max_files=-1
                 ):
    num_files = 0
    if ( delete_which > 0 ):
        dodelete = True
    else:
        dodelete = False

    vapi = velocityAPI.VelocityAPI()

    work_q = Queue.Queue()

    if ( dodelete ):
        threads = [threaded_work.worker(target=enqueuer_with_delete,
                                 args=(collection_name, work_q,
                                       synctype, direct_enqueue, arena))
                   for i in xrange(thread_count)]
    else:
        threads = [threaded_work.worker(target=enqueuer,
                                 args=(collection_name, work_q,
                                       synctype, direct_enqueue, arena))
                   for i in xrange(thread_count)]

    for path, dirs, files in os.walk(root):
        relative_path = path.replace(root, '', 1)
        if ( max_files != -1 and num_files >= max_files):
            break
        if ( dodelete ):
            zz = 0
            for name in files:
                if ( max_files != -1 and num_files >= max_files ):
                    break
                num_files += 1
                zz = zz + 1
                deleteit = 'no'
                if ( ( zz % delete_which ) == 0 ):
                    deleteit = 'yes'
                fullpath = os.path.join(path, name)
                if usablefiletype( fullpath ):
                    if (arena):
                        work_q.put(tuple([fullpath,
                                          '%s/%s/%s/%s'%(base_url, arena,
                                                         relative_path, name),
                                          deleteit]))
                    else:
                        work_q.put(tuple([fullpath,
                                          '%s/%s/%s'%(base_url,
                                                      relative_path, name),
                                          deleteit]))
        else:
            for name in files:
                if ( max_files != -1 and num_files >= max_files ):
                    break
                num_files += 1
                fullpath = os.path.join(path, name)
                if usablefiletype( fullpath ):
                    if (arena):
                        work_q.put(tuple([fullpath,
                                          '%s/%s/%s/%s'%(base_url, arena,
                                                         relative_path,
                                                         name)]))
                    else:
                        work_q.put(tuple([fullpath,
                                          '%s/%s/%s'%(base_url,
                                                      relative_path,
                                                      name)]))

    # Tell my workers we're done.
    print "Tell enqueuers we are done"
    if ( dodelete ):
        for thread in threads:
            work_q.put(tuple([None, None, None]))
    else:
        for thread in threads:
            work_q.put(tuple([None, None]))

    # Wait for the workers to finish up.
    for thread in threads:
        thread.join()

    print "Exiting enqueue_tree, walked %d files, max %d"%(num_files, max_files)

    return
                
if __name__ == "__main__":
    if len(sys.argv) < 4:
        print 'usage: %s collection_name local_directory base_url [max_docs] [arena]' % sys.argv[0]
        sys.exit(1)
    threaded_work.allow_control_c()
    if len(sys.argv) == 4:
        control_q = threaded_work.top(target=enqueue_tree, 
                                  args=(sys.argv[1], sys.argv[2], sys.argv[3]))

    elif len(sys.argv) == 5:
        control_q = threaded_work.top(target=enqueue_tree,
                                      args=(sys.argv[1], sys.argv[2], sys.argv[3], 10, 0, 'indexed-no-sync', True, None, int(sys.argv[4])))

    else:
        control_q = threaded_work.top(target=enqueue_tree,
                                      args=(sys.argv[1], sys.argv[2], sys.argv[3], 10, 0, 'indexed-no-sync', True, sys.argv[5], int(sys.argv[4])))
        
    status = control_q.get()
    print 'Final status is', status
    time.sleep(2)
