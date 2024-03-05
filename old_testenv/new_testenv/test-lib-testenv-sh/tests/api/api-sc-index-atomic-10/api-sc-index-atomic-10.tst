#!/usr/bin/python

#
#   Test of the api
#      Test of abort on error
#      Bad url for enqueue
#      Duplicate enqueue
#      Duplicate delete
#      Delete of item never enqueued
#      Empty enqueue
#
import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import random
import build_schema_node
from lxml import etree

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
   originator = "api-sc-index-atomic-10"
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
      originator = "api-sc-index-atomic-10"
   else:
      originator = None

   crawl_urls = build_schema_node.create_crawl_urls()

   idx_atomic = build_schema_node.create_index_atomic(
                    abortonerror=True,
                    addnodeto=crawl_urls,
                    originator=originator, enqueueid=enqueueid)

   idx_atomic = do_crawl_delete(idx_atomic, filelist, synchro, 
                    use_origin, use_id, use_url, use_vsekey,
                    errorit)

   incr_enqueueid(use_id)

   return crawl_urls

def do_deletes(dir, use_origin=False, use_id=False,
               use_url=False, use_vsekey=False, beginid=0,
               listcount=1, errorit=0):

   global enqueueid

   usesynchro = ['enqueued', 'enqueued', 'enqueued', 
                 'indexed-no-sync', 'enqueued',
                 'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                 'indexed-no-sync', 'enqueued']

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
      originator = "api-sc-index-atomic-10"
   else:
      originator = None

   crawl_urls = build_schema_node.create_crawl_urls()

   idx_atomic = build_schema_node.create_index_atomic(
                    abortonerror=True,
                    addnodeto=crawl_urls,
                    originator=originator, enqueueid=enqueueid)

   idx_atomic = do_crawl_url(idx_atomic, filelist, synchro,
                    use_origin, use_id, errorit)

   incr_enqueueid(use_id)

   return crawl_urls

def do_enqueues(dir, use_origin=False, use_id=False, beginid=0,
                listcount=1, errorit=0):

   global enqueueid

   usesynchro = [None, 'none', 'none', 'indexed-no-sync', 'enqueued',
                  'to-be-indexed', 'indexed-no-sync', 'enqueued',
                  'indexed-no-sync', None]

   filecount = 0

   crawl_urls = None

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

   collection_name2 = "scia-10"
   cfile = collection_name2 + '.xml'
   tname = "api-sc-index-atomic-10"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  index-atomic test 10"
   print tname, ":     Errors with abort on error set"


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

   print tname, ":  Begin index-atomic cases"
   print tname, ":  ##################"
   print tname, ":  Following cases use bad urls."
   dir = "/testenv/test_data/law/F2/210"
   urlbase = 'http://junkurl/'
   #
   #   Bad url errors with various files.
   #
   filecount1a = do_enqueues(dir, use_origin=False, use_id=True,
                             listcount=3, errorit=4, beginid=10)
   filecount1a = do_enqueues(dir, use_origin=False, use_id=True,
                             listcount=2, errorit=4, beginid=20)
   filecount1a = do_enqueues(dir, use_origin=False, use_id=True,
                             listcount=1, errorit=3, beginid=30)
   filecount1a = do_enqueues(dir, use_origin=False, use_id=True,
                             listcount=5, errorit=2, beginid=40)
   filecount1a = do_enqueues(dir, use_origin=False, use_id=True,
                             listcount=4, errorit=1, beginid=50)
   #
   #   Good enqueue (3 files)
   #
   print tname, ":  ##################"
   print tname, ":  Following cases use good urls.  Should work."
   filecount = do_enqueues(dir, use_origin=False, use_id=True,
                             listcount=3, errorit=0, beginid=60)
   #
   #   Bad enqueue (3 files, duplicates of above)
   #   Good enqueue (2 files)
   #   Abort on error should cause all to fail leaving only
   #   the 3 files above.
   #
   print tname, ":  ##################"
   print tname, ":  Following cases use good urls."
   print tname, ":     Should fail because 3 of 5 are duplicates."
   filecount1a = do_enqueues(dir, use_origin=False, use_id=True,
                             listcount=5, errorit=0, beginid=70)

   delcnt = 0

   indexedcount = do_query(collection_name2, xx, yy)

   fail4 = 1
   if ( filecount != indexedcount ):
      print tname, ":  total results and current count differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  current count     = ", filecount
   else:
      print tname, ":  total results and filecount are correct at ", filecount
      fail4 = 0
   print tname, ":  ##################"

   ##############################################################

   token = dofinalauditlog(collection=collection_name2, tname=tname,
                           filecount=filecount,
                           delcnt=delcnt,
                           successes=1,
                           transactions=7,
                           comment="ALL data")

   #
   #   Enqueue a bunch of files.
   #
   dir = "/testenv/test_data/law/F2/211"
   filecount = do_enqueues(dir, use_origin=False, use_id=True,
                             listcount=97, errorit=0, beginid=60)

   resp = yy.api_sc_audit_log_purge(collection=collection_name2, token=token)

   #
   #   Current count plus those from above.  should be 100.
   #
   filecount = filecount + 3

   indexedcount = do_query(collection_name2, xx, yy)

   fail3 = 1
   if ( filecount != indexedcount ):
      print tname, ":  total results and current count differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  current count     = ", filecount
   else:
      print tname, ":  total results and filecount are correct at ",filecount
      fail3 = 0
   print tname, ":  ##################"

   urlbase = 'http://badurl/'
   print tname, ":  ##################"
   print tname, ":  Following delete cases use bad urls."
   print tname, ":     Should fail because they don't exist.  Never have."
   filecount2a = do_deletes(dir, use_origin=False, use_id=True,
                            use_url=True, use_vsekey=False,
                            listcount=3, errorit=4, beginid=110)
   filecount2a = do_deletes(dir, use_origin=False, use_id=True,
                            use_url=True, use_vsekey=False,
                            listcount=2, errorit=4, beginid=120)
   filecount2a = do_deletes(dir, use_origin=False, use_id=True,
                            use_url=True, use_vsekey=False,
                            listcount=1, errorit=3, beginid=130)
   filecount2a = do_deletes(dir, use_origin=False, use_id=True,
                            use_url=True, use_vsekey=False,
                            listcount=5, errorit=2, beginid=140)
   filecount2a = do_deletes(dir, use_origin=False, use_id=True,
                            use_url=True, use_vsekey=False,
                            listcount=4, errorit=1, beginid=150)
   #
   #   Good enqueue (3 files)
   #
   print tname, ":  ##################"
   print tname, ":  Following delete cases use good urls."
   print tname, ":     Should succeed."
   urlbase = 'http://junkurl/'
   delcount = do_deletes(dir, use_origin=False, use_id=True,
                         use_url=True, use_vsekey=False,
                         listcount=3, errorit=0, beginid=160)
   #
   #   Bad enqueue (3 files, duplicates of above)
   #   Good enqueue (2 files)
   #   Abort on error should cause all to fail leaving only
   #   the 3 files above.
   #
   print tname, ":  ##################"
   print tname, ":  Following delete cases use good urls."
   print tname, ":     Should fail because 3 of 5 have already been deleted."
   filecount2a = do_deletes(dir, use_origin=False, use_id=True,
                            use_url=True, use_vsekey=False,
                            listcount=5, errorit=0, beginid=170)


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

   xx.kill_all_services()

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
