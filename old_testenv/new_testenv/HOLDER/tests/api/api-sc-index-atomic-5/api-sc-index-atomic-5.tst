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

   global dumpofd, collection_name2, yy

   dumpofd.write( etree.tostring(crawl_urls) )
   try:
      resp = yy.api_sc_enqueue_xml(
                       collection=collection_name2,
                       subc='live',
                       crawl_nodes=etree.tostring(crawl_urls))
      return resp
   except velocityAPI.VelocityAPIexception:
      ex_xml, ex_text = sys.exc_info()[1]
      success = ex_xml.get('name') == 'search-collection-enqueue-invalid'
      if not success:
         print "BARF, unexpected failure"
         print '%s:  %s' % (collection_name2, ex_text)
         print "Enqueue failed"

   return None

def dofinalauditlog(collection=None, tname=None, filecount=0,
                    delcnt=0, transmatch=0, comment=None):

   global fail5

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

def incr_enqueueid(use_id=False):

   global enqueueid

   if ( use_id ):
      if ( enqueueid is not None ):
         enqueueid += 1
   else:
      enqueueid = None

   return

def get_max(allowedmax=100):

   g = random.Random(time.time())

   return g.randint(1, allowedmax)

def get_nested(nestmax=1):

   g = random.Random(time.time())

   return g.randint(1, nestmax)

def series_depth(usezero=0):

   g = random.Random(time.time())

   if ( usezero == 1 ):
      return g.randint(0, 2)
   else:
      return g.randint(1, 2)

def do_crawl_delete(crawl_urls=None, filelist=None, synchro=None,
                 use_origin=False, use_id=False, use_url=False,
                 use_vsekey=False, num_at_depth=1, current=0):

   global enqueueid

   usesynchro = ['none', 'indexed', 'none', 'enqueued', 'indexed-no-sync',
                  'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                  'indexed-no-sync', 'enqueued']

   httpport = '80'
   thingbomb = 0
   x = 0

   if ( use_origin ):
      originator = "api-sc-index-atomic-5"
   else:
      originator = None

   if ( filelist is None ):
      return []

   while ( x < num_at_depth ):

      item = filelist[current]

      if ( synchro == None ):
         whichone = thingbomb % 10
         thissynchro = usesynchro[whichone]
         thingbomb += 1
      else:
         thissynchro = synchro

      fname = os.path.basename(item)
      fdir = os.path.basename(os.path.dirname(item))

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
                  vsekey=vsekey )

      x += 1
      current += 1
      incr_enqueueid(use_id)

   return crawl_urls

def do_crawl_deletes(crawl_urls=None, filelist=None, synchro=None,
                  use_origin=False, use_id=False, use_url=False,
                  use_vsekey=False):

   global enqueueid

   max_here = len(filelist)
   current = 0

   if ( use_origin ):
      originator = "api-sc-index-atomic-5"
   else:
      originator = None

   crawl_urls = build_schema_node.create_crawl_urls()

   while ( max_here > 0 ):

      depth = series_depth(0)
      num_at_depth = get_nested(max_here)
      max_here = max_here - num_at_depth
      if ( max_here < 0 ):
         num_at_depth = num_at_depth - max_here
         max_here = 0
      if ( depth > 0 ):
         if ( depth == 1 ):
            crawl_urls = do_crawl_delete(crawl_urls, filelist, synchro,
                             use_origin, use_id, use_url, use_vsekey,
                             num_at_depth, current)
         else:
            if ( use_id ):
               idx_atomic = build_schema_node.create_index_atomic(
                                addnodeto=crawl_urls,
                                originator=originator, enqueueid=enqueueid)
            else:
               idx_atomic = build_schema_node.create_index_atomic(
                                addnodeto=crawl_urls, originator=originator)

            incr_enqueueid(use_id)

            idx_atomic = do_crawl_delete(idx_atomic, filelist, synchro,
                             use_origin, use_id, use_url, use_vsekey,
                             num_at_depth, current)

      current = current + num_at_depth
       

   return crawl_urls

def do_deletes(dir, use_origin=False, use_id=False, 
               use_url=False, use_vsekey=False, beginid=0):

   global enqueueid

   usesynchro = [None, 'none', 'none', 'indexed-no-sync', 'enqueued',
                  'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                  'indexed-no-sync', None]

   filecount = 0

   enqueueid = beginid

   for path, dirs, files in os.walk(dir):

      filelist = []
      crawl_urls = None

      quitcounter = 0
      quitnum = len(files)

      lcnt = get_max()
      curcnt = 0

      for name in files:

         quitcounter += 1
         if ( quitcounter == quitnum ):
            curcnt = lcnt
         else:
            curcnt += 1

         fullpath = os.path.join(path, name)
         filelist.append(fullpath)
         filecount += 1

         if ( curcnt >= lcnt ):
            which = filecount % 10
            synchro = usesynchro[which]
            #print "=============================, ", synchro
            crawl_urls = do_crawl_deletes(crawl_urls, filelist, synchro,
                                       use_origin, use_id,
                                       use_url, use_vsekey)
            #print "============================="
            curcnt = 0
            resp = enqueue_it(crawl_urls)
            #print etree.tostring(crawl_urls)

            #
            #   Reset
            #
            filelist = []
            crawl_urls = None
            lcnt = get_max()

      print "FILES DELETED (interim):  ", filecount

   print "FILES DELETED (final):  ", filecount

   return filecount


def do_crawl_url(crawl_urls=None, filelist=None, synchro=None,
                 use_origin=False, use_id=False,
                 num_at_depth=1, current=0):

   global enqueueid

   usesynchro = ['none', 'indexed', 'none', 'enqueued', 'indexed-no-sync',
                  'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                  'indexed-no-sync', 'enqueued']

   thingbomb = 0
   x = 0

   if ( use_origin ):
      originator = "api-sc-index-atomic-5"
   else:
      originator = None

   if ( filelist is None ):
      return []

   while ( x < num_at_depth ):

      item = filelist[current]

      if ( synchro == None ):
         whichone = thingbomb % 10
         thissynchro = usesynchro[whichone]
         thingbomb += 1
      else:
         thissynchro = synchro

      fname = os.path.basename(item)
      fdir = os.path.basename(os.path.dirname(item))

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
                   filename=item)
      x += 1
      current += 1
      incr_enqueueid(use_id)

   return crawl_urls

def do_crawl_urls(crawl_urls=None, filelist=None, synchro=None,
                  use_origin=False, use_id=False):

   global enqueueid

   max_here = len(filelist)
   current = 0

   if ( use_origin ):
      originator = "api-sc-index-atomic-5"
   else:
      originator = None

   crawl_urls = build_schema_node.create_crawl_urls()

   while ( max_here > 0 ):

      depth = series_depth(0)
      num_at_depth = get_nested(max_here)
      max_here = max_here - num_at_depth
      if ( max_here < 0 ):
         num_at_depth = num_at_depth - max_here
         max_here = 0
      if ( depth > 0 ):
         if ( depth == 1 ):
            crawl_urls = do_crawl_url(crawl_urls, filelist, synchro,
                             use_origin, use_id,
                             num_at_depth, current)
         else:
            if ( use_id ):
               idx_atomic = build_schema_node.create_index_atomic(
                                addnodeto=crawl_urls,
                                originator=originator, enqueueid=enqueueid)
            else:
               idx_atomic = build_schema_node.create_index_atomic(
                                addnodeto=crawl_urls, originator=originator)

            incr_enqueueid(use_id)

            idx_atomic = do_crawl_url(idx_atomic, filelist, synchro,
                             use_origin, use_id,
                             num_at_depth, current)

      current = current + num_at_depth
       

   return crawl_urls

def do_enqueues(dir, use_origin=False, use_id=False, beginid=0):

   global enqueueid

   usesynchro = [None, 'none', 'none', 'indexed-no-sync', 'enqueued',
                  'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                  'indexed-no-sync', None]

   filecount = 0

   enqueueid = beginid

   for path, dirs, files in os.walk(dir):

      filelist = []
      crawl_urls = None

      quitcounter = 0
      quitnum = len(files)

      lcnt = get_max()
      curcnt = 0

      for name in files:

         quitcounter += 1
         if ( quitcounter == quitnum ):
            curcnt = lcnt
         else:
            curcnt += 1

         fullpath = os.path.join(path, name)
         filelist.append(fullpath)
         filecount += 1

         if ( curcnt >= lcnt ):
            which = filecount % 10
            synchro = usesynchro[which]
            #print "=============================, ", synchro
            crawl_urls = do_crawl_urls(crawl_urls, filelist, synchro,
                                       use_origin, use_id)
            #print "============================="
            curcnt = 0
            resp = enqueue_it(crawl_urls)
            #print etree.tostring(crawl_urls)

            #
            #   Reset
            #
            filelist = []
            crawl_urls = None
            lcnt = get_max()

      print "FILES ENQUEUED (interim):  ", filecount

   print "FILES ENQUEUED (final):  ", filecount

   return filecount


if __name__ == "__main__":

   global enqueueid
   global dumpofd, collection_name2

   enqueueid = 0

   maxcount = 10
   i = 0
   num = 500
   clustercount = 10
   cluster = 'True'
   perpage = 10
   fail = 1
   fail5 = 0

   collection_name2 = "scia-5"
   cfile = collection_name2 + '.xml'
   tname = "api-sc-index-atomic-5"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  index-atomic test 5"
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

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   print tname, ":  Begin crawl-url cases"
   print tname, ":  ##################"
   print tname, ":  CASE ia-crawlurl-1"
   print tname, ":       ia-nestednode-1"
   print tname, ":     Multiple index-atomic in a crawl-urls node"
   dir = "/testenv/test_data/law/F2/210"
   filecount1a = do_enqueues(dir, use_origin=False, use_id=False)
   dir = "/testenv/test_data/law/F2/211"
   filecount1b = do_enqueues(dir, use_origin=False, use_id=False)
   dir = "/testenv/test_data/law/F2/212"
   filecount1c = do_enqueues(dir, use_origin=False, use_id=False)
   filecount1 = filecount1a + filecount1b + filecount1c

   xx.wait_for_idle(collection=collection_name2)
   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')

   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = yy.getTotalResults(resptree=resp)

   fail0 = 1
   if ( filecount1 != indexedcount ):
      print tname, ":  total results and filecount differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  filecount     = ", filecount1
      dumpofd.write("</output>")
      dumpofd.close()
      actnum = yy.getAuditLogEntryCrawlUrlCount(filename='querywork/what_i_did')
      print tname, ":  actual number enqueued (crawl-url) = ", actnum
      sys.exit(1)
   else:
      print tname, ":  total results and filecount are correct at ", filecount1
      fail0 = 0
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawlurl-2, origin only"
   print tname, ":       ia-nestednode-1"
   dir = "/testenv/test_data/law/F2/190"
   filecount2 = do_enqueues(dir, use_origin=True, use_id=False)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawlurl-2, enqueue-id only"
   print tname, ":       ia-nestednode-1"
   dir = "/testenv/test_data/law/F2/191"
   filecount3 = do_enqueues(dir, use_origin=False, use_id=True,
                            beginid=191000)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawlurl-2, origin and enqueue-id"
   print tname, ":       ia-nestednode-1"
   dir = "/testenv/test_data/law/F2/192"
   filecount4 = do_enqueues(dir, use_origin=True, use_id=True,
                            beginid=192000)
   print tname, ":  ##################"

   filecount = filecount1 + filecount2 + filecount3 + filecount4

   xx.wait_for_idle(collection=collection_name2)

   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')

   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = yy.getTotalResults(resptree=resp)

   fail1 = 1
   if ( filecount != indexedcount ):
      print tname, ":  total results and filecount differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  filecount     = ", filecount
      dumpofd.write("</output>")
      dumpofd.close()
      sys.exit(1)
   else:
      print tname, ":  total results and filecount are correct at ", filecount
      fail1 = 0

   print tname, ":  ##################"
   print tname, ":  Begin crawl-delete cases"

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawldelete-1, old functionality"
   print tname, ":       ia-nestednode-1"
   dir = "/testenv/test_data/law/F2/210"
   deletecount1a = do_deletes(dir, use_origin=False, use_id=False,
                            use_url=True, use_vsekey=False)
   dir = "/testenv/test_data/law/F2/211"
   deletecount1b = do_deletes(dir, use_origin=False, use_id=False,
                            use_url=True, use_vsekey=False)
   dir = "/testenv/test_data/law/F2/212"

   print tname, ":     Use both url and vse-key.  Delete should fail"
   deletecount1c = do_deletes(dir, use_origin=False, use_id=False,
                            use_url=True, use_vsekey=True)

   deletecount1 = deletecount1a + deletecount1b

   xx.wait_for_idle(collection=collection_name2)

   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')
   indexedcount = yy.getTotalResults(resptree=resp)

   currentcount = filecount - deletecount1

   fail2 = 1
   if ( currentcount != indexedcount ):
      print tname, ":  total results and current count differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  current count     = ", currentcount
   else:
      print tname, ":  total results and filecount are correct at ",currentcount
      fail2 = 0

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawldelete-2, Attempt to delete by originator"
   print tname, ":       ia-nestednode-1"
   print tname, ":     Every delete here should fail"
   dir = "/testenv/test_data/law/F2/190"
   deletecount2 = do_deletes(dir, use_origin=True, use_id=False,
                            use_url=False, use_vsekey=False)

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawldelete-2, Attempt to delete by enqueue-id"
   print tname, ":       ia-nestednode-1"
   print tname, ":     Every delete here should fail"
   dir = "/testenv/test_data/law/F2/191"
   deletecount3 = do_deletes(dir, use_origin=False, use_id=True,
                             use_url=False, use_vsekey=False,
                             beginid=191000)

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawldelete-2, Attempt to delete by origin and id"
   print tname, ":       ia-nestednode-1"
   print tname, ":     Every delete here should fail"
   dir = "/testenv/test_data/law/F2/192"
   deletecount4 = do_deletes(dir, use_origin=True, use_id=True,
                             use_url=False, use_vsekey=False,
                             beginid=192000)

   xx.wait_for_idle(collection=collection_name2)

   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')
   indexedcount = yy.getTotalResults(resptree=resp)

   currentcount = filecount - deletecount1

   fail3 = 1
   if ( currentcount != indexedcount ):
      print tname, ":  total results and current count differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  current count     = ", currentcount
   else:
      print tname, ":  total results and filecount are correct at ",currentcount
      fail3 = 0

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawldelete-2, Attempt to delete by originator"
   print tname, ":       ia-nestednode-1"
   print tname, ":     with vse-key"
   dir = "/testenv/test_data/law/F2/190"
   deletecount2 = do_deletes(dir, use_origin=True, use_id=False,
                            use_url=True, use_vsekey=False)

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawldelete-2, Attempt to delete by enqueue-id"
   print tname, ":       ia-nestednode-1"
   print tname, ":     with vse-key"
   dir = "/testenv/test_data/law/F2/191"
   deletecount3 = do_deletes(dir, use_origin=False, use_id=True,
                             use_url=True, use_vsekey=False,
                             beginid=191000)

   print tname, ":  ##################"
   print tname, ":  CASE ia-crawldelete-2, Attempt to delete by origin and id"
   print tname, ":       ia-nestednode-1"
   print tname, ":     with vse-key"
   dir = "/testenv/test_data/law/F2/192"
   deletecount4 = do_deletes(dir, use_origin=True, use_id=True,
                            use_url=True, use_vsekey=False,
                            beginid=192000)

   xx.wait_for_idle(collection=collection_name2)

   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')
   indexedcount = yy.getTotalResults(resptree=resp)

   currentcount = filecount - ( deletecount1 + deletecount2 + deletecount3 + deletecount4 )

   delcnt = deletecount1 + deletecount2 + deletecount3 + deletecount4

   fail4 = 1
   if ( currentcount != indexedcount ):
      print tname, ":  total results and current count differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  current count     = ", currentcount
   else:
      print tname, ":  total results and filecount are correct at ",currentcount
      fail4 = 0
   print tname, ":  ##################"

   ##############################################################

   token = dofinalauditlog(collection=collection_name2, tname=tname,
                           filecount=filecount,
                           delcnt=delcnt,
                           transmatch=(filecount + delcnt),
                           comment="ALL data")

   dumpofd.write("</output>")
   dumpofd.close()

   xx.kill_all_services()

   fail = fail0 + fail1 + fail2 + fail3 + fail4 + fail5

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
