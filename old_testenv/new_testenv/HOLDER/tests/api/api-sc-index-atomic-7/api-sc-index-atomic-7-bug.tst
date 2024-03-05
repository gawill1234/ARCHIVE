#!/usr/bin/python

#
#   Test of the api
#   Test is for changes introduced by index-atomic.
#   This test makes sure that the originator and enqueue-id
#   attributes do not break the original schema model.
#
#   This test checks crawl-delete and crawl-url with and without
#   the new index-atomic attributes both as standalone nodes
#   and as one or more of X in a index-atomic node.
#
#   This tests crawl-url and crawl-delete within the scope of an
#   index-atomic node.   Multiple index-atomics are placed within a
#   crawl-urls node.  Partial attribute is specified.
#
import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import random
import build_schema_node
from lxml import etree

def dofinalauditlog(collection=None, tname=None, filecount=0,
                    delcnt=0, transmatch=0, comment=None):

   global fail5, yy

   print "#######################################################"
   print tname, ":  Audit numbers for collection", collection
   if ( comment is not None ):
      print tname, ":     ", comment

   time.sleep(30)

   resp = yy.api_sc_audit_log_retrieve(collection=collection, limit=100000)
   successcount = yy.getAuditLogSuccessCount(resptree=resp)
   cucount = yy.getAuditLogEntryCrawlUrlCount(resptree=resp)
   cuscount = yy.getAuditLogEntryCrawlUrlsCount(resptree=resp)
   cdcount = yy.getAuditLogEntryCrawlDeleteCount(resptree=resp)
   idxacount = yy.getAuditLogEntryIndexAtomicCount(resptree=resp)
   entrycount = yy.getAuditLogEntryCount(resptree=resp)
   token = yy.getAuditLogToken(resptree=resp)

   totalcount = filecount + delcnt
   tcnt2 = cucount + cdcount

   print tname, ":(final)   Total Audit Log Entries,   ", entrycount
   print tname, ":(final)   Total Audit Log Successes, ", successcount
   print tname, ":(final)   Total file transactions,   ", totalcount
   print tname, ":(final)       adds,                  ", filecount
   print tname, ":(final)       deletes,               ", delcnt
   print tname, ":(final)       crawl-url,             ", cucount
   print tname, ":(final)       crawl-urls,            ", cuscount
   print tname, ":(final)       crawl-deletes,         ", cdcount
   print tname, ":(final)       index-atomic,          ", idxacount
   if ( totalcount != tcnt2 ):
      fail5 = 1
      print tname, ":  transaction count and entrycount do not match"
   if ( transmatch != tcnt2 ):
      fail5 = 1
      print tname, ":  transaction count and successcount do not match"

   return token

def do_collection(xx, yy, collection_name2, tname):

   cfile = collection_name2 + '.xml'

   print tname, ":     Create empty collection", collection_name2
   #
   #   Empty collection to be filled using crawl-urls
   #
   cex = xx.collection_exists(collection=collection_name2)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name2)

   yy.api_sc_create(collection=collection_name2, based_on='default-push')
   yy.api_repository_update(xmlfile=cfile)

   return

def wait_and_query(xx, collection_name2):

   xx.wait_for_idle(collection=collection_name2)

   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')

   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = yy.getTotalResults(resptree=resp)

   return indexedcount

def random_init():

   global g

   g = random.Random(time.time())

   return

def incr_fileadds():

   global fileadds, currentadds

   fileadds += 1
   currentadds += 1

   return

def incr_filedels():

   global filedels, currentdels

   filedels += 1
   currentdels += 1

   return

def current_number(dir):

   global fileadds, filedels, currentadds, currentdels, tname

   filecount = fileadds - filedels
   currentcount = currentadds - currentdels

   print tname, ":     ENQUEUE DATA IS FROM"
   print tname, ":       ", dir

   print ""
   print tname, ":     CURRENT TOTALS"
   print tname, ":        FILES SHOULD BE :", filecount
   print tname, ":        FILES ADDED     :", fileadds
   print tname, ":        FILES DELETED   :", filedels
   print ""
   print tname, ":     VALUES FROM THIS PASS"
   print tname, ":        FILES SHOULD BE :", currentcount
   print tname, ":        FILES ADDED     :", currentadds
   print tname, ":        FILES DELETED   :", currentdels
   print ""

   return

def incr_enqueueid(use_id=False):

   global enqueueid

   if ( use_id ):
      if ( enqueueid is not None ):
         enqueueid += 1
   else:
      enqueueid = None

   return

def get_max(allowedmax=100):

   global g

   return g.randint(1, allowedmax)

def get_nested(nestmax=1):

   global g

   return g.randint(1, nestmax)

def series_depth(usezero=0):

   global g

   if ( usezero == 1 ):
      return g.randint(0, 2)
   else:
      return g.randint(1, 2)

def do_crawl_delete(crawl_urls=None, filename=None,
                 use_origin=False, use_id=False, use_url=False,
                 use_vsekey=False):

   global enqueueid

   httpport = '80'
   x = 0

   if ( use_origin ):
      originator = "api-sc-index-atomic-7"
   else:
      originator = None

   thissynchro = 'enqueued'

   fname = os.path.basename(filename)
   fdir = os.path.basename(os.path.dirname(filename))

   if ( use_url ):
      url = ''.join(['http://junkurl/', fdir, '.', fname])
   else:
      url = None

   if ( use_vsekey ):
      vsekey = ''.join(['http://junkurl:', httpport, '/', fdir, '.', fname, '/'])
   else:
      vsekey = None

   if ( use_id ):
      crawl_delete = build_schema_node.create_crawl_delete(url=url,
                     synchronization=thissynchro, addnodeto=crawl_urls,
                     vsekey=vsekey, enqueueid=enqueueid)
   else:
      crawl_delete = build_schema_node.create_crawl_delete(url=url,
                     synchronization=thissynchro, addnodeto=crawl_urls,
                     vsekey=vsekey)

   incr_filedels()

   return crawl_urls

def do_crawl_url(crawl_urls=None, filename=None,
                 use_origin=False, use_id=False):

   global enqueueid

   thingbomb = 0
   x = 0

   if ( use_origin ):
      originator = "api-sc-index-atomic-7"
   else:
      originator = None

   thissynchro = 'enqueued'

   fname = os.path.basename(filename)
   fdir = os.path.basename(os.path.dirname(filename))

   url = ''.join(['http://junkurl/', fdir, '.', fname])

   if ( use_id ):
      crawl_url = build_schema_node.create_crawl_url(url=url,
                  status='complete', enqueuetype='reenqueued',
                  synchronization=thissynchro, addnodeto=crawl_urls,
                  enqueueid=enqueueid)
   else:
      crawl_url = build_schema_node.create_crawl_url(url=url,
                  status='complete', enqueuetype='reenqueued',
                  synchronization=thissynchro, addnodeto=crawl_urls)

   crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                contenttype='text/html', addnodeto=crawl_url,
                filename=filename)

   incr_fileadds()

   return crawl_urls

def flush_partial(crawl_urls, use_origin):

   global enqueueid

   if ( use_origin ):
      originator = "api-sc-index-atomic-7"
   else:
      originator = None

   idx_atomic = build_schema_node.create_index_atomic(
                    addnodeto=crawl_urls,
                    originator=originator, enqueueid=enqueueid,
                    partial=None, synchronization='enqueued')

   thissynchro = 'enqueued'
   url = 'http://www.bogusurl.org/' + '%s' % enqueueid
   crawl_url = build_schema_node.create_crawl_url(url=url,
               status='complete', enqueuetype='reenqueued',
               synchronization=thissynchro, addnodeto=idx_atomic)

   return crawl_urls

def enqueue_it(crawl_urls=None, kludge=None):

   global dumpofd, dumpresp, yy, collection_name2, did_enqueue

   print "ENQUEUE FROM: ", kludge
   print etree.tostring(crawl_urls)

   dumpofd.write( etree.tostring(crawl_urls) )
   resp = yy.api_sc_enqueue_xml(
                    collection=collection_name2,
                    subc='live',
                    crawl_nodes=etree.tostring(crawl_urls))

   print "DONE ENQUEUE FROM: ", kludge

   dumpresp.write( etree.tostring(resp) )

   did_enqueue = 1

   return

def do_crawl_urls(crawl_urls=None, idx_atomic=None, 
                  filename=None,
                  use_origin=False, use_id=False, 
                  use_url=False, use_vsekey=False, 
                  use_partial=None, delete=False):

   global enqueueid, dopartial

   if ( use_origin ):
      originator = "api-sc-index-atomic-7"
   else:
      originator = None

   if ( crawl_urls is None ):
      crawl_urls = build_schema_node.create_crawl_urls(
                   synchronization='enqueued')
   else:
      if ( get_max(100) > 90 ):
         #if ( dopartial > 0 ):
         #   crawl_urls = flush_partial(crawl_urls, use_origin)
         #   incr_enqueueid(use_id)
         enqueue_it(crawl_urls, "do_crawl_urls-1")
         idx_atomic = None
         crawl_urls = build_schema_node.create_crawl_urls(
                      synchronization='enqueued')

   if ( get_max(100) > 75 or
        idx_atomic is None ):

      dopartial -= 1

      if ( dopartial <= 0 ):
         thingy = None
      else:
         thingy = use_partial

      idx_atomic = build_schema_node.create_index_atomic(
                       addnodeto=crawl_urls,
                       originator=originator, enqueueid=enqueueid,
                       partial=thingy, synchronization='enqueued')

      if ( dopartial <= 0 ):
         incr_enqueueid(use_id)

   if ( delete ):
      do_crawl_delete(idx_atomic, filename,
                      use_origin, False,
                      use_url, use_vsekey)
   else:
      do_crawl_url(idx_atomic, filename,
                       use_origin, False)

   return crawl_urls, idx_atomic


def do_filelist(crawl_urls, idx_atomic, filelist=None,
                  use_origin=False, use_id=False, use_url=False,
                  use_vsekey=False):

   global dopartial, enqueueid, did_enqueue, xx, collection_name2

   dopartial = 0

   for item in filelist:

      if ( dopartial <= 0 ):
         dopartial = get_max(13)

      did_enqueue = 0
      crawl_urls, idx_atomic = do_crawl_urls(crawl_urls, idx_atomic, 
                                             item,
                                             use_origin, use_id,
                                             use_url, use_vsekey,
                                             use_partial="yes")

   #
   #   Should create a blank idx_atomic with no partial flag
   #   and the current enqueue id.  This should terminate the 
   #   current partial set up.
   #
   if ( did_enqueue == 0 ):
      enqueue_it(crawl_urls, "do_filelist-1")
   crawl_urls = flush_partial(crawl_urls, use_origin)
   enqueue_it(crawl_urls, "do_filelist-2")

   #
   #   Wait for all the enqueues to complete so deletes will work
   #
   xx.wait_for_idle(collection=collection_name2)

   incr_enqueueid(use_id)

   for item in filelist:
      if ( dopartial <= 0 ):
         dopartial = get_max(13)

      did_enqueue = 0
      if ( get_max(100) > 75 ):
         crawl_urls, idx_atomic = do_crawl_urls(crawl_urls, idx_atomic,
                                  item,
                                  use_origin, use_id,
                                  use_url, use_vsekey,
                                  use_partial="yes", delete=True)

   #
   #   Should create a blank idx_atomic with no partial flag
   #   and the current enqueue id.  This should terminate the 
   #   current partial set up.
   #
   if ( did_enqueue == 0 ):
      enqueue_it(crawl_urls, "do_filelist-3")
   crawl_urls = flush_partial(crawl_urls, use_origin)
   enqueue_it(crawl_urls, "do_filelist-4")
   incr_enqueueid(use_id)

   return crawl_urls, idx_atomic


def do_enqueues(dir, use_origin=False, use_id=False, 
                use_url=False, use_vsekey=False, beginid=0):

   global enqueueid, currentadds, currentdels

   currentadds = 0
   currentdels = 0

   if ( use_id is False ):
      enqueueid = None
   else:
      enqueueid = beginid

   crawl_urls = None
   idx_atomic = None

   for path, dirs, files in os.walk(dir):

      filelist = []

      for name in files:

         fullpath = os.path.join(path, name)
         filelist.append(fullpath)

      crawl_urls, idx_atomic = do_filelist(crawl_urls, idx_atomic,
                                           filelist,
                                           use_origin, use_id,
                                           use_url, use_vsekey)

   current_number(dir)

   return

if __name__ == "__main__":

   global enqueueid, fileadds, filedels, fail5
   global tname, dumpofd, dumpresp, yy, collection_name2

   enqueueid = 0
   fileadds = 0
   filedels = 0

   fail = 1
   fail5 = 0

   random_init()

   collection_name2 = "scia-7"
   cfile = collection_name2 + '.xml'
   tname = "api-sc-index-atomic-7"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  index-atomic test 7"
   print tname, ":     index atomic with partial option"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Create empty collection", collection_name2
   #
   #   Empty collection to be filled using crawl-urls
   #

   do_collection(xx, yy, collection_name2, tname)

   thebeginning = time.time()

   dumpofd = open("querywork/what_i_did", "w+")
   dumpofd.write("<output>")
   dumpresp = open('querywork/responses', 'w+')
   dumpresp.write("<output>")

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   print tname, ":  Begin index-atomic cases"
   print tname, ":  ##################"
   print tname, ":     Use of partial with index-atomic"
   print tname, ":     All index-atomic nodes are in crawl-urls node"
   print tname, ":     enqueue-id is used for index-atomic only"
   print tname, ":     All deletes are by url"

   dir = "/testenv/test_data/law/F2/210"
   do_enqueues(dir, use_origin=False, use_id=True,
               use_url=True, use_vsekey=False, beginid=210000)
   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = wait_and_query(xx, collection_name2)
   print tname, ":     total results and filecount data"
   print tname, ":  ======================================"
   print tname, ":  actual results    = ", indexedcount

   print tname, ":  ##################"

   dir = "/testenv/test_data/law/F2/211"
   do_enqueues(dir, use_origin=False, use_id=True,
               use_url=True, use_vsekey=False, beginid=211000)
   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = wait_and_query(xx, collection_name2)
   print tname, ":     total results and filecount data"
   print tname, ":  ======================================"
   print tname, ":  actual results    = ", indexedcount

   print tname, ":  ##################"

   dir = "/testenv/test_data/law/F2/212"
   do_enqueues(dir, use_origin=False, use_id=True,
               use_url=True, use_vsekey=False, beginid=212000)
   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = wait_and_query(xx, collection_name2)
   print tname, ":     total results and filecount data"
   print tname, ":  ======================================"
   print tname, ":  actual results    = ", indexedcount

   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  CASE ia-crawlurl-2, use origin"
   print tname, ":       ia-nestednode-1"

   dir = "/testenv/test_data/law/F2/190"
   do_enqueues(dir, use_origin=True, use_id=True,
               use_url=True, use_vsekey=False, beginid=190000)
   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = wait_and_query(xx, collection_name2)
   print tname, ":     total results and filecount data"
   print tname, ":  ======================================"
   print tname, ":  actual results    = ", indexedcount

   print tname, ":  ##################"

   dir = "/testenv/test_data/law/F2/191"
   do_enqueues(dir, use_origin=False, use_id=True,
               use_url=True, use_vsekey=False, beginid=191000)
   print tname, ":  ##################"

   dir = "/testenv/test_data/law/F2/192"
   do_enqueues(dir, use_origin=True, use_id=True,
               use_url=True, use_vsekey=False, beginid=192000)
   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = wait_and_query(xx, collection_name2)
   print tname, ":     total results and filecount data"
   print tname, ":  ======================================"
   print tname, ":  actual results    = ", indexedcount

   print tname, ":  ##################"


   dumpofd.write("</output>")
   dumpofd.close()

   dumpresp.write( "</output>" )
   dumpresp.close()

   notdeleted = yy.getResultGenericTagCount(filename='querywork/responses',
                                            tagname='crawl-delete',
                                            attrname='state',
                                            attrvalue='error')

   thghtadded = yy.getAuditLogEntryCrawlUrlCount(filename='querywork/what_i_did')
   thghtdel = yy.getAuditLogEntryCrawlDeleteCount(filename='querywork/what_i_did')

   filedels = filedels - notdeleted

   filecount = fileadds - filedels

   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = wait_and_query(xx, collection_name2)

   print tname, ":     total results and filecount data"
   print tname, ":  ======================================"
   print tname, ":  actual results    = ", indexedcount
   print tname, ":  filecount         = ", filecount
   print tname, ":  delete errors     = ", notdeleted
   print tname, ":  assumed added     = ", thghtadded
   print tname, ":  assumed deleted   = ", thghtdel

   if ( filecount == indexedcount ):
      print tname, ":  total results and filecount are correct at ", filecount
      fail = 0

   dofinalauditlog(collection=collection_name2, tname=tname,
                   filecount=thghtadded,
                   delcnt=thghtdel,
                   transmatch=(thghtadded + thghtdel),
                   comment="ALL data")

   print tname, ":  ##################"

   fail = fail + fail5

   ##############################################################


   xx.kill_all_services()

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
