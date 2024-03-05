#!/usr/bin/python

#
#   Test of the api
#      Test that the partial attribute works in various corner cases.
#      Partial is large with data.
#      Partial takes many seconds to be completed
#      Partial is never completed.
#
import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import random
import build_schema_node
from lxml import etree

def flush_partial(use_origin):
   
   global enqueueid 
   
   if ( use_origin ):
      originator = "api-sc-index-atomic-9" 
   else: 
      originator = None

   idx_atomic = build_schema_node.create_index_atomic( 
                    originator=originator, enqueueid=enqueueid,
                    partial=None)

   return idx_atomic

def do_query(collection_name2, xx, yy):

   xx.wait_for_idle(collection=collection_name2)

   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')

   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = yy.getTotalResults(resptree=resp)

   return indexedcount

def do_collection(collection_name2, cfile, xx, yy):

   #
   #   Empty collection to be filled using crawl-urls
   #
   cex = xx.collection_exists(collection=collection_name2)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name2)

   yy.api_sc_create(collection=collection_name2, based_on='default-push')
   yy.api_repository_update(xmlfile=cfile)

   return

def enqueue_it(crawl_urls=None):

   global dumpofd, collection_name2, yy, dumpresp

   resp = None

   dumpofd.write( etree.tostring(crawl_urls) )
   resp = yy.api_sc_enqueue_xml(
                    collection=collection_name2,
                    subc='live',
                    crawl_nodes=etree.tostring(crawl_urls))
   dumpresp.write( etree.tostring(resp) )
   return resp

def dofinalauditlog(collection=None, tname=None, filecount=0,
                    delcnt=0, successes=0, transactions=0, comment=None):

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

   totalcount = transactions

   print tname, ":(final)   Total Audit Log Entries,   ", entrycount
   print tname, ":(final)   Total Audit Log Successes, ", successcount
   print tname, ":(final)   Total file transactions,   ", totalcount
   print tname, ":(final)       adds,                  ", filecount
   print tname, ":(final)       deletes,               ", delcnt
   print tname, ":(final)       crawl-url,             ", cucount
   print tname, ":(final)       crawl-urls,            ", cuscount
   print tname, ":(final)       crawl-deletes,         ", cdcount
   print tname, ":(final)       index-atomic,          ", idxacount
   if ( totalcount != idxacount ):
      fail5 = 1
      print tname, ":  transaction count and entrycount do not match"
   if ( transactions != idxacount ):
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


def set_curl_attribs(item, i=1, errorit=0, use_vsekey=False):

   global enqueueid, status, enqtype, thissynchro, url, originator, vsekey
   global urlbase

   synchrolst = [['enqueued', 'enqueued', 'enqueued',
                  'enqueued', 'enqueued'],
                 ['indexed-no-sync', 'indexed-no-sync', 'indexed-no-sync',
                  'indexed-no-sync', 'indexed-no-sync'],
                 ['indexed-no-sync', 'enqueued', 'none',
                  None, 'indexed'],
                 ['indexed-no-sync', 'enqueued', 'none',
                  'indexed-no-sync', 'enqueued'],
                 ['indexed-no-sync', 'enqueued', 'none',
                  'indexed-no-sync', 'enqueued']]

   enqlst = [['reenqueued', 'reenqueued', 'reenqueued',
              'reenqueued', 'reenqueued'],
             ['reenqueued', 'reenqueued', 'forced',
              'reenqueued', 'reenqueued'],
             ['reenqueued', 'reenqueued', 'reenqueued',
              'reenqueued', 'forced'],
             ['forced', 'reenqueued', 'reenqueued',
              'reenqueued', 'reenqueued'],
             ['forced', 'forced', 'forced',
              'forced', 'forced']]

   statuslst = [['complete', 'complete', 'complete', 'complete', 'complete'],
                ['complete', 'complete', None, 'complete', 'complete'],
                ['complete', 'complete', 'complete', 'complete', None],
                [None, 'complete', 'complete', 'complete', 'complete'],
                [None, None, None, None, None]]

   httpport = '80'
   originator = "api-sc-index-atomic-9"
   status = statuslst[errorit][i % 5]
   enqtype = enqlst[errorit][i % 5]
   thissynchro = synchrolst[errorit][i % 5]

   fname = os.path.basename(item)
   fdir = os.path.basename(os.path.dirname(item))

   #url = ''.join(['http://junkurl/', fdir, '.', fname])
   url = ''.join([urlbase, fdir, '.', fname])

   if ( use_vsekey ):
      vsekey = ''.join(['http://junkurl:',httpport,'/',fdir,'.',fname,'/'])
   else:
      vsekey = None

   return

def do_crawl_delete(idx_atomic=None, filelist=None, synchro=None,
                 use_origin=False, use_id=False, use_url=False,
                 use_vsekey=False, errorit=0):

   global enqueueid, status, enqtype, thissynchro, url, originator, vsekey

   usesynchro = ['none', 'indexed', 'none', 'enqueued', 'indexed-no-sync',
                  'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                  'indexed-no-sync', 'enqueued']

   if ( filelist is None ):
      return []

   i = 0

   for item in filelist:

      set_curl_attribs(item, i, errorit, use_vsekey)


      crawl_delete = build_schema_node.create_crawl_delete(url=url,
               synchronization=thissynchro, addnodeto=idx_atomic,
               vsekey=vsekey, enqueueid=enqueueid)

   return idx_atomic

def do_crawl_deletes(crawl_urls=None, filelist=None, synchro=None,
                  use_origin=False, use_id=False, use_url=False,
                  use_vsekey=False, errorit=0):

   global enqueueid

   max_here = len(filelist)
   current = 0

   if ( use_origin ):
      originator = "api-sc-index-atomic-9"
   else:
      originator = None

   crawl_urls = build_schema_node.create_crawl_urls()

   idx_atomic = build_schema_node.create_index_atomic(
                    abortonerror=True, partial=None,
                    addnodeto=crawl_urls,
                    originator=originator, enqueueid=enqueueid)

   idx_atomic = do_crawl_delete(idx_atomic, filelist, synchro, 
                    use_origin, use_id, use_url, use_vsekey,
                    errorit)

   return crawl_urls

def do_deletes(dir, use_origin=False, use_id=False,
               use_url=False, use_vsekey=False, beginid=0,
               listcount=1, errorit=0):

   global enqueueid

   usesynchro = [None, 'none', 'none', 'indexed-no-sync', 'enqueued',
                  'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                  'indexed-no-sync', None]

   filecount = 0

   if ( use_id ) :
      enqueueid = beginid
   else:
      enqueueid = None

   for path, dirs, files in os.walk(dir):

      filelist = []
      crawl_urls = None

      quitnum = len(files)

      if ( quitnum > listcount ):
         for name in files:

            fullpath = os.path.join(path, name)
            filelist.append(fullpath)
            filecount += 1

            if ( filecount >= listcount ):
               break

   synchro = None
   crawl_urls = do_crawl_deletes(crawl_urls, filelist, synchro, 
                              use_origin, use_id,
                              use_url, use_vsekey, errorit)
   resp = enqueue_it(crawl_urls)
   #print etree.tostring(crawl_urls)

   incr_enqueueid(use_id)
   
   print "FILES DELETED (final):  ", filecount
   
   return filecount

def do_crawl_url(idx_atomic=None, filelist=None, synchro=None,
                 use_origin=False, use_id=False, errorit=0):
                 

   global enqueueid, status, enqtype, thissynchro, url, originator

   if ( filelist is None ):
      return []

   i = 0

   for item in filelist:

      set_curl_attribs(item, i, errorit)
      i += 1

      crawl_url = build_schema_node.create_crawl_url(url=url,
                  status=status, enqueuetype=enqtype,
                  synchronization=thissynchro, addnodeto=idx_atomic,
                  enqueueid=enqueueid)

      crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                   contenttype='text/html', addnodeto=crawl_url,
                   filename=item)

   return idx_atomic

def do_crawl_urls(crawl_urls=None, filelist=None, synchro=None,
                  use_origin=False, use_id=False, errorit=0):

   global enqueueid

   max_here = len(filelist)
   current = 0

   if ( use_origin ):
      originator = "api-sc-index-atomic-9"
   else:
      originator = None

   crawl_urls = build_schema_node.create_crawl_urls()

   idx_atomic = build_schema_node.create_index_atomic(
                    abortonerror=True, partial=True,
                    addnodeto=crawl_urls,
                    originator=originator, enqueueid=enqueueid)

   idx_atomic = do_crawl_url(idx_atomic, filelist, synchro,
                    use_origin, use_id, errorit)


   return crawl_urls

def do_enqueues(dir, use_origin=False, use_id=False, beginid=0,
                listcount=1, errorit=0, flushpartial=True,
                partialsleep=0):

   global enqueueid

   usesynchro = [None, 'none', 'none', 'indexed-no-sync', 'enqueued',
                  'to-be-indexed', 'indexed-no-sync', 'enqueued',
                  'indexed-no-sync', None]

   filecount = 0

   if ( use_id ) :
      enqueueid = beginid
   else:
      enqueueid = None

   for path, dirs, files in os.walk(dir):

      filelist = []
      crawl_urls = None

      quitnum = len(files)

      if ( quitnum > listcount ):
         for name in files:

            fullpath = os.path.join(path, name)
            filelist.append(fullpath)
            filecount += 1

            if ( filecount >= listcount ):
               break

   synchro = None
   crawl_urls = do_crawl_urls(crawl_urls, filelist, synchro,
                              use_origin, use_id, errorit)
   resp = enqueue_it(crawl_urls)
   #print etree.tostring(crawl_urls)

   if ( flushpartial ):
      if ( partialsleep > 0 ):
         time.sleep(partialsleep)
      idx_atomic = flush_partial(use_origin)
      resp = enqueue_it(idx_atomic)
      #print etree.tostring(idx_atomic)

   incr_enqueueid(use_id)

   print "FILES ENQUEUED (final):  ", filecount

   return filecount


if __name__ == "__main__":

   global enqueueid, urlbase
   global dumpofd, collection_name2, dumpresp, yy, xx

   enqueueid = None

   maxcount = 10
   i = 0
   num = 500
   clustercount = 10
   cluster = 'True'
   perpage = 10
   fail = 1
   fail5 = 0

   collection_name2 = "scia-9"
   cfile = collection_name2 + '.xml'
   tname = "api-sc-index-atomic-9"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  index-atomic test 9"
   print tname, ":     Partial attribute"
   print tname, ":     Partial is large"
   print tname, ":     Partial hangs around before completing"
   print tname, ":     Partial is never completed"


   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Create empty collection", collection_name2

   do_collection(collection_name2, cfile, xx, yy)

   thebeginning = time.time()

   dumpofd = open("querywork/what_i_did", "w+")
   dumpofd.write("<output>")

   dumpresp = open("querywork/responses", "w+")
   dumpresp.write("<output>")

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   print tname, ":  Begin index-atomic partial cases"
   print tname, ":  ##################"
   print tname, ":  Large partial, starting at 1 and growing to 500"
   print tname, ":     No sleep.  Do partial and complete"
   dir = "/testenv/test_data/law/F2/210"
   urlbase = 'http://junkurl/'

   fail4 = 0
   i = 1
   while ( i < 100 ):
      filecount = do_enqueues(dir, use_origin=False, use_id=True,
                                listcount=i, errorit=0, beginid=i)
      delcnt = 0

      indexedcount = do_query(collection_name2, xx, yy)

      if ( i != int(indexedcount) ):
         print tname, ":  total results and current count differ"
         print tname, ":  total results   = ", indexedcount
         print tname, ":  current count   = ", filecount
         print tname, ":  current payload = ", i
         fail4 += 1
      else:
         print tname, ":  total results and filecount are correct at ", filecount
      print tname, ":  ##################"

      ##############################################################

      token = dofinalauditlog(collection=collection_name2, tname=tname,
                              filecount=filecount,
                              delcnt=delcnt,
                              successes=1,
                              transactions=1,
                              comment="ALL data")

      delid = i + 500
      filecount2a = do_deletes(dir, use_origin=False, use_id=True,
                               use_url=True, use_vsekey=False,
                               listcount=i, errorit=0, beginid=delid)

      resp = yy.api_sc_audit_log_purge(collection=collection_name2, token=token)
 
      i += 1

   print tname, ":  ##################"
   print tname, ":  Large partial, starting at 1 and growing to 500"
   print tname, ":     Growing sleep.  Do partial and complete"
   dir = "/testenv/test_data/law/F2/211"
   fail5 = 0
   i = 1
   while ( i < 100 ):
      sleepy = i * 2
      beginid = i + 2000
      filecount = do_enqueues(dir, use_origin=False, use_id=True,
                                listcount=i, errorit=0, beginid=beginid,
                                partialsleep=sleepy)
      delcnt = 0

      indexedcount = do_query(collection_name2, xx, yy)

      if ( i != int(indexedcount) ):
         print tname, ":  total results and current count differ"
         print tname, ":  total results = ", indexedcount
         print tname, ":  current count     = ", filecount
         fail5 += 1
      else:
         print tname, ":  total results and filecount are correct at ", filecount
      print tname, ":  ##################"

      ##############################################################

      token = dofinalauditlog(collection=collection_name2, tname=tname,
                              filecount=filecount,
                              delcnt=delcnt,
                              successes=1,
                              transactions=1,
                              comment="ALL data")

      delid = beginid + 500
      filecount2a = do_deletes(dir, use_origin=False, use_id=True,
                               use_url=True, use_vsekey=False,
                               listcount=i, errorit=0, beginid=delid)

      resp = yy.api_sc_audit_log_purge(collection=collection_name2, token=token)
 
      i += 1

   print tname, ":  ##################"
   print tname, ":  Large partial, 200 items with data"
   print tname, ":     Long sleep.  Do partial and never complete"
   dir = "/testenv/test_data/law/F2/212"
   fail2 = 0
   i = 100
   sleepy = 300
   beginid = 212000
   filecount = do_enqueues(dir, use_origin=False, use_id=True,
                             listcount=100, errorit=0, beginid=beginid,
                             partialsleep=sleepy, flushpartial=False)
   delcnt = 0

   indexedcount = do_query(collection_name2, xx, yy)

   if ( i != int(indexedcount) ):
      print tname, ":  total results and current count differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  current count     = ", filecount
      fail2 += 1
   else:
      print tname, ":  total results and filecount are correct at ", filecount
      print tname, ":  ##################"

   ##############################################################

   token = dofinalauditlog(collection=collection_name2, tname=tname,
                           filecount=filecount,
                           delcnt=delcnt,
                           successes=1,
                           transactions=1,
                           comment="ALL data")

   delid = 212001
   filecount2a = do_deletes(dir, use_origin=False, use_id=True,
                            use_url=True, use_vsekey=False,
                            listcount=100, errorit=0, beginid=delid)

   resp = yy.api_sc_audit_log_purge(collection=collection_name2, token=token)

   print tname, ":  ##################"

   print tname, ":  Growing partials, 1 to 500 with data."
   print tname, ":     Long sleep.  Do partial and never complete"
   print tname, ":     Attempt to delete incomplete item."
   dir = "/testenv/test_data/law/F2/213"
   fail1 = 0
   i = 1
   while ( i < 10 ):
      sleepy = i * 2
      beginid = i + 4000
      filecount = do_enqueues(dir, use_origin=False, use_id=True,
                                listcount=i, errorit=0, beginid=beginid,
                                partialsleep=sleepy, flushpartial=False)
      delcnt = 0

      indexedcount = do_query(collection_name2, xx, yy)

      if ( i != int(indexedcount) ):
         print tname, ":  total results and current count differ"
         print tname, ":  total results   = ", indexedcount
         print tname, ":  current count   = ", filecount
         fail1 += 1
      else:
         print tname, ":  total results and filecount are correct at ", filecount
      print tname, ":  ##################"

      ##############################################################

      token = dofinalauditlog(collection=collection_name2, tname=tname,
                              filecount=filecount,
                              delcnt=delcnt,
                              successes=1,
                              transactions=1,
                              comment="ALL data")

      delid = beginid + 500
      filecount2a = do_deletes(dir, use_origin=False, use_id=True,
                               use_url=True, use_vsekey=False,
                               listcount=i, errorit=0, beginid=delid)

      resp = yy.api_sc_audit_log_purge(collection=collection_name2, token=token)
 
      i += 1


   dumpofd.write("</output>")
   dumpofd.close()

   dumpresp.write("</output>")
   dumpresp.close()

   #
   #   Current count plus those from above.  should be 100.
   #
   filecount = filecount - 3

   indexedcount = do_query(collection_name2, xx, yy)

   fail2 = 1
   if ( filecount != indexedcount ):
      print tname, ":  total results and current count differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  current count     = ", filecount
   else:
      print tname, ":  total results and filecount are correct at ",filecount
      fail2 = 0

   token = dofinalauditlog(collection=collection_name2, tname=tname,
                           filecount=filecount,
                           delcnt=delcnt,
                           successes=1,
                           transactions=8,
                           comment="ALL data")

   print tname, ":  ##################"
   fail = fail2 + fail3 + fail4 + fail5

   if ( fail == 0 ):
      #xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
