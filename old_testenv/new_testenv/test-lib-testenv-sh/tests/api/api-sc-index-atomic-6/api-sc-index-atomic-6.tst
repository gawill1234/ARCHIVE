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
#   crawl-urls node.
#
import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import random
import build_schema_node
import velocityAPI
from lxml import etree

def enqueue_it(crawl_urls=None):

   global dumpofd, dumpresp, collection_name2, yy

   dumpofd.write( etree.tostring(crawl_urls) )
   try:
      resp = yy.api_sc_enqueue_xml(
                       collection=collection_name2,
                       subc='live',
                       crawl_nodes=etree.tostring(crawl_urls))
   except velocityAPI.VelocityAPIexception:
      resp = None
      ex_xml, ex_text = sys.exc_info()[1]
      success = ex_xml.get('name') == 'search-collection-enqueue-invalid'
      if not success:
         print "BARF, unexpected failure"
         print '%s:  %s' % (collection_name2, ex_text)
         print "Enqueue failed"

   if ( resp is not None ):
      dumpresp.write( etree.tostring(resp) )

   return resp

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

def current_number():

   global fileadds, filedels, currentadds, currentdels, tname

   filecount = fileadds - filedels
   currentcount = currentadds - currentdels

   print tname, ":  TOTAL CURRENT FILES SHOULD BE    :", filecount
   print tname, ":  TOTAL CURRENT FILES ADDED        :", fileadds
   print tname, ":  TOTAL CURRENT FILES DELETED      :", filedels

   print tname, ":  THIS PASS CURRENT FILES SHOULD BE:", currentcount
   print tname, ":  THIS PASS CURRENT FILES ADDED    :", currentadds
   print tname, ":  THIS PASS CURRENT FILES DELETED  :", currentdels

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
   thingbomb = 0
   x = 0

   if ( use_origin ):
      originator = "api-sc-index-atomic-6"
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

   crawl_delete = build_schema_node.create_crawl_delete(url=url,
                  synchronization=thissynchro, addnodeto=crawl_urls,
                  vsekey=vsekey, enqueueid=enqueueid)

   incr_filedels()

   return crawl_urls

def do_crawl_url(crawl_urls=None, filename=None,
                 use_origin=False, use_id=False):

   global enqueueid

   thingbomb = 0
   x = 0

   if ( use_origin ):
      originator = "api-sc-index-atomic-6"
   else:
      originator = None

   thissynchro = 'enqueued'

   fname = os.path.basename(filename)
   fdir = os.path.basename(os.path.dirname(filename))

   url = ''.join(['http://junkurl/', fdir, '.', fname])

   crawl_url = build_schema_node.create_crawl_url(url=url,
               status='complete', enqueuetype='reenqueued',
               synchronization=thissynchro, addnodeto=crawl_urls,
               enqueueid=enqueueid)

   crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                contenttype='text/html', addnodeto=crawl_url,
                filename=filename)

   incr_fileadds()

   return crawl_urls


def do_crawl_urls(crawl_urls=None, idx_atomic=None, 
                  filename=None,
                  use_origin=False, use_id=False, 
                  use_url=False, use_vsekey=False, delete=False):

   global enqueueid
   global enqisout

   if ( use_origin ):
      originator = "api-sc-index-atomic-6"
   else:
      originator = None

   if ( crawl_urls is None ):
      crawl_urls = build_schema_node.create_crawl_urls()
   else:
      if ( get_max(100) > 90 ):
         enqueue_it(crawl_urls)
         idx_atomic = None
         enqisout = False
         crawl_urls = build_schema_node.create_crawl_urls()

   if ( get_max(100) > 90 ):
      if ( delete ):
         enqisout = False
         do_crawl_delete(crawl_urls, filename,
                         use_origin, use_id,
                         use_url, use_vsekey)

         incr_enqueueid(use_id)
      else:
         enqisout = True
         do_crawl_url(crawl_urls, filename,
                      use_origin, use_id)
         incr_enqueueid(use_id)
   else:
      if ( get_max(100) > 75 or enqisout or
           idx_atomic is None ):
         enqisout = False
         idx_atomic = build_schema_node.create_index_atomic(
                          addnodeto=crawl_urls,
                          originator=originator, enqueueid=enqueueid)
         incr_enqueueid(use_id)

      if ( delete ):
         do_crawl_delete(idx_atomic, filename,
                         use_origin, use_id,
                         use_url, use_vsekey)
         incr_enqueueid(use_id)
      else:
         do_crawl_url(idx_atomic, filename,
                          use_origin, use_id)
         incr_enqueueid(use_id)

   return crawl_urls, idx_atomic


def do_filelist(crawl_urls, idx_atomic, filelist=None,
                  use_origin=False, use_id=False, use_url=False,
                  use_vsekey=False):

   global enqisout

   enqisout = False

   for item in filelist:
      crawl_urls, idx_atomic = do_crawl_urls(crawl_urls, idx_atomic, 
                                             item,
                                             use_origin, use_id,
                                             use_url, use_vsekey)
      if ( get_max(100) > 75 ):
         crawl_urls, idx_atomic = do_crawl_urls(crawl_urls, idx_atomic,
                                  item,
                                  use_origin, use_id,
                                  use_url, use_vsekey, delete=True)

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

   enqueue_it(crawl_urls)

   current_number()

   return

if __name__ == "__main__":

   global enqueueid, fileadds, filedels
   global tname, dumpofd, dumpresp, collection_name2, yy

   enqueueid = 0
   fileadds = 0
   filedels = 0

   maxcount = 10
   i = 0
   num = 500
   clustercount = 10
   cluster = 'True'
   perpage = 10
   fail = 1
   fail5 = 0

   random_init()

   collection_name2 = "scia-6"
   cfile = collection_name2 + '.xml'
   tname = "api-sc-index-atomic-6"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  index-atomic test 6"
   print tname, ":     index-atomic within crawl-urls node, with and"
   print tname, ":     without standalone crawl-url or crawl-delete"
   print tname, ":     nodes"


   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Create empty collection", collection_name2
   #
   #   Empty collection to be filled using crawl-urls
   #
   cex = xx.collection_exists(collection=collection_name2)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name2)

   yy.api_sc_create(collection=collection_name2, based_on='default-push')
   yy.api_repository_update(xmlfile=cfile)

   thebeginning = time.time()

   dumpofd = open("querywork/what_i_did", "w+")
   dumpofd.write("<output>")
   dumpresp = open('querywork/responses', 'w+')
   dumpresp.write("<output>")

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   print tname, ":  Begin crawl-url cases"
   print tname, ":  ##################"
   print tname, ":  CASE ia-crawlurl-1"
   print tname, ":       ia-nestednode-1"
   print tname, ":     Multiple index-atomic in a crawl-urls node"
   dir = "/testenv/test_data/law/F2/210"
   do_enqueues(dir, use_origin=False, use_id=True,
               use_url=True, use_vsekey=False, beginid=2100000)
   dir = "/testenv/test_data/law/F2/211"
   do_enqueues(dir, use_origin=False, use_id=True,
               use_url=True, use_vsekey=False, beginid=2110000)
   dir = "/testenv/test_data/law/F2/212"
   do_enqueues(dir, use_origin=False, use_id=True,
               use_url=True, use_vsekey=False, beginid=2120000)
   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  CASE ia-crawlurl-2, origin only"
   print tname, ":       ia-nestednode-1"
   dir = "/testenv/test_data/law/F2/190"
   do_enqueues(dir, use_origin=True, use_id=True,
               use_url=True, use_vsekey=False, beginid=1900000)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawlurl-2, enqueue-id only"
   print tname, ":       ia-nestednode-1"
   dir = "/testenv/test_data/law/F2/191"
   do_enqueues(dir, use_origin=False, use_id=True,
               use_url=True, use_vsekey=False, beginid=1910000)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawlurl-2, origin and enqueue-id"
   print tname, ":       ia-nestednode-1"
   dir = "/testenv/test_data/law/F2/192"
   do_enqueues(dir, use_origin=True, use_id=True,
               use_url=True, use_vsekey=False, beginid=1920000)
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

   xx.wait_for_idle(collection=collection_name2)

   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')

   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = yy.getTotalResults(resptree=resp)

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

   token = dofinalauditlog(collection=collection_name2, tname=tname,
                           filecount=thghtadded,
                           delcnt=thghtdel,
                           transmatch=(thghtadded + thghtdel),
                           comment="ALL data")

   print tname, ":  ##################"

   fail = fail + fail5

   ##############################################################

   #xx.kill_all_services()

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
