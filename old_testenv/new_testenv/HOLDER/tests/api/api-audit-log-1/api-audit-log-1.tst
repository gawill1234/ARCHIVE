#!/usr/bin/python

#
#   Test of the api
#   This is a basic test of audit log retrieve/purge
#
import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node
from lxml import etree

def do_crawl_deletes(crawl_urls=None, filelist=None):

   if ( filelist is None ):
      return []

   if ( crawl_urls is None ):
      crawl_urls = build_schema_node.create_crawl_urls()

   for item in filelist:
      #print item
      fname = os.path.basename(item)
      #print fname
      url = ''.join(['http://junkurl/', fname])
      delete_url = build_schema_node.create_crawl_delete(url=url,
                                     addnodeto=crawl_urls)

   return crawl_urls

def do_crawl_urls(crawl_urls=None, filelist=None):

   if ( filelist is None ):
      return []

   if ( crawl_urls is None ):
      crawl_urls = build_schema_node.create_crawl_urls()

   for item in filelist:
      #print item
      fname = os.path.basename(item)
      #print fname
      url = ''.join(['http://junkurl/', fname])
      crawl_url = build_schema_node.create_crawl_url(url=url,
                  status='complete', enqueuetype='reenqueued',
                  synchronization='enqueued', addnodeto=crawl_urls)
      crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                   contenttype='text/html', addnodeto=crawl_url,
                   filename=item)

   return crawl_urls

#
#   Set up and fire off crawl-delete nodes
#
def do_deletes(dir):

   for path, dirs, files in os.walk(dir):

      filelist = []
      deletelist = []
      crawl_deletes = None

      quitcounter = 0
      quitnum = len(files)

      lcnt = 20
      curcnt = 0
      whichone = 5

      for name in files:

         quitcounter += 1
         if ( quitcounter == quitnum ):
            zz = 0
         else:
            zz = quitcounter % whichone

         if ( zz == 0 ):
            if ( quitcounter == quitnum ):
               curcnt = lcnt
            else:
               curcnt += 1
            fullpath = os.path.join(path, name)
            filelist.append(fullpath)
            deletelist.append(fullpath)

            if ( curcnt == lcnt ):
               #print "++++++++++++++++++++++++++++++++"
               crawl_deletes = do_crawl_deletes(crawl_deletes, filelist)
               #print "++++++++++++++++++++++++++++++++"
               curcnt = 0
               lcnt -= 1
               resp = yy.api_sc_enqueue_xml(
                             collection=collection_name2,
                             subc='live',
                             crawl_nodes=etree.tostring(crawl_deletes))
               #print etree.tostring(crawl_urls)
               filelist = []
               crawl_deletes = None
               if ( lcnt == 0 ):
                  lcnt = 20

   return deletelist

#
#   Set up and fire off crawl-url nodes
#
def do_enqueues(dir):

   filecount = 0

   for path, dirs, files in os.walk(dir):

      filelist = []
      crawl_urls = None

      quitcounter = 0
      quitnum = len(files)

      lcnt = 5
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

         if ( curcnt == lcnt ):
            #print "============================="
            crawl_urls = do_crawl_urls(crawl_urls, filelist)
            #print "============================="
            curcnt = 0
            lcnt -= 1
            resp = yy.api_sc_enqueue_xml(
                             collection=collection_name2,
                             subc='live',
                             crawl_nodes=etree.tostring(crawl_urls))
            #print etree.tostring(crawl_urls)
            filelist = []
            crawl_urls = None
            if ( lcnt == 0 ):
               lcnt = 5

   return filecount

def dointerimauditlog(collection=None, tname=None):

   resp = yy.api_sc_audit_log_retrieve(collection=collection)
   successcount = yy.getAuditLogSuccessCount(resptree=resp)
   entrycount = yy.getAuditLogEntryCount(resptree=resp)
   token = yy.getAuditLogToken(resptree=resp)

   print tname, ":(interim,info)   Total Audit Log Entries,   ", entrycount
   print tname, ":(interim,info)   Total Audit Log Successes, ", successcount

   return

def dofinalauditlog(collection=None, tname=None, filecount=0,
                    delcnt=0, transmatch=0, comment=None):

   global fail

   print "#######################################################"
   print tname, ":  Audit numbers for collection", collection
   if ( comment is not None ):
      print tname, ":     ", comment

   time.sleep(60)

   resp = yy.api_sc_audit_log_retrieve(collection=collection)
   successcount = yy.getAuditLogSuccessCount(resptree=resp)
   entrycount = yy.getAuditLogEntryCount(resptree=resp)
   token = yy.getAuditLogToken(resptree=resp)

   totalcount = filecount + delcnt

   print tname, ":(final)   Total Audit Log Entries,   ", entrycount
   print tname, ":(final)   Total Audit Log Successes, ", successcount
   print tname, ":(final)   Total file transactions,   ", totalcount
   print tname, ":(final)              adds,           ", filecount
   print tname, ":(final)              deletes,        ", delcnt
   if ( totalcount != entrycount ):
      fail = 1
      print tname, ":  transaction count and entrycount do not match"
   if ( transmatch != successcount ):
      fail = 1
      print tname, ":  transaction count and successcount do not match"

   return token

if __name__ == "__main__":

   fail = 0

   collection_name1 = "adlog-1"
   collection_name2 = "adlog-1b"
   tname = "api-audit-log-1"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  audit logs test 1"
   print tname, ":     audit log is all"
   print tname, ":     detail is full"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   if ( xx.TENV.vivfloatversion < 7.5 ):
      print tname, ":  TEST NOT SUPPORTED IN THIS VERSION"
      print tname, ":  Test Not Run"
      sys.exit(0)

   docrawlcollection = True
   interimauditlog = True
   doenqueuecollection = True

   dir = "/testenv/test_data/law/F2/210"

   if ( os.access(dir, os.F_OK) == 0 ):
      doenqueuecollection = False

   print tname, ":  PERFORM CRAWLS"

   if ( docrawlcollection is False ):
      print tname, ":  WARNING, THE CRAWLED COLLECTION WILL NOT BE RUN"
   if ( doenqueuecollection is False ):
      print tname, ":  WARNING, THE ENQUEUED COLLECTION WILL NOT BE RUN"

   if ( doenqueuecollection is False and docrawlcollection is False ):
      print tname, ":  TEST COULD NOT BE RUN AT ALL"
      print tname, ":  Test Failed"
      sys.exit(1)

   if ( docrawlcollection is True ):
      print tname, ":     Crawl collection", collection_name1
      #
      #   Samba collection
      #
      xx.create_collection(collection=collection_name1, usedefcon=0)
      xx.start_crawl(collection=collection_name1)
      xx.wait_for_idle(collection=collection_name1)

   if ( doenqueuecollection is True ):
      print tname, ":     Create empty collection", collection_name2
      #
      #   Empty collection to be filled using crawl-urls
      #
      cex = xx.collection_exists(collection=collection_name2)
      if ( cex == 1 ):
         xx.delete_collection(collection=collection_name2)

      yy.api_sc_create(collection=collection_name2, based_on='default-push')
      yy.api_repository_update(xmlfile='adlog-1b.xml')

   thebeginning = time.time()

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   if ( doenqueuecollection is True ):
      print tname, ":  ##################"
      print tname, ":  Enqueueing data using enqueue xml and crawl-url"
      filecount = do_enqueues(dir)

      if ( interimauditlog is True ):
         dointerimauditlog(collection=collection_name2, tname=tname)

      xx.wait_for_idle(collection=collection_name2)

      if ( interimauditlog is True ):
         dointerimauditlog(collection=collection_name2, tname=tname)

      print tname, ":  ##################"
      print tname, ":  Enqueueing(deleting) data using enqueue xml and crawl-delete"

      deletelist = do_deletes(dir)

      if ( interimauditlog is True ):
         dointerimauditlog(collection=collection_name2, tname=tname)

      xx.wait_for_idle(collection=collection_name2)

      if ( interimauditlog is True ):
         dointerimauditlog(collection=collection_name2, tname=tname)

      print tname, ":  ##################"

      delcnt = 0
      for item in deletelist:
         delcnt += 1
         fname = os.path.basename(item)
         url = ''.join(['http://junkurl/', fname])
         resp = yy.api_qsearch(source=collection_name2, query=url)
         resurlcount = yy.getResultUrlCount(resptree=resp)
         if ( resurlcount != 0 ):
            fail = 1
            resurl = yy.getResultUrls(resptree=resp)
            print "----->", item, "should have been deleted and was not"
            print "----->", resurl, "is the gotten url"

      token = dofinalauditlog(collection=collection_name2, tname=tname,
                              filecount=filecount, delcnt=delcnt,
                              transmatch=(filecount + delcnt),
                              comment="Enqueued, pre-purge")

      print "#######################################################"
      print tname, ":Purge, using this TOKEN: ", token
      resp = yy.api_sc_audit_log_purge(collection=collection_name2, token=token)
      token = dofinalauditlog(collection=collection_name2, tname=tname,
                              filecount=0, delcnt=0, transmatch=0,
                              comment="Enqueued, post-purge, all zeroes")

      print "#######################################################"

   if ( docrawlcollection is True ):
      token = dofinalauditlog(collection=collection_name1, tname=tname,
                              filecount=50, delcnt=10, transmatch=50,
                              comment="Crawled, pre-purge")

      print "#######################################################"
      print tname, ":Purge, using this TOKEN: ", token
      resp = yy.api_sc_audit_log_purge(collection=collection_name1, token=token)
      token = dofinalauditlog(collection=collection_name1, tname=tname,
                              filecount=0, delcnt=0, transmatch=0,
                              comment="Crawled, post-purge, all zeroes")

      print "#######################################################"


   print tname, ":  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( fail == 0 ):
      if ( docrawlcollection is True ):
         xx.delete_collection(collection=collection_name1)
      if ( doenqueuecollection is True ):
         xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
