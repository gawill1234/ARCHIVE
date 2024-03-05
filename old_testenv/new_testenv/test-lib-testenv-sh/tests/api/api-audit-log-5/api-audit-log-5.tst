#!/usr/bin/python

#vse-key="http://junkurl:80/210.F2d.287.5992.html/

#
#   Test of the api
#   This is a basic test of audit log retrieve/purge
#
import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node
from lxml import etree

#
#   This is a vse-key delete
#
def do_crawl_deletes(crawl_urls=None, filelist=None, httpport='80'):

   global enqcount

   if ( filelist is None ):
      return []

   if ( crawl_urls is None ):
      crawl_urls = build_schema_node.create_crawl_urls()

   for item in filelist:
      #print item
      fname = os.path.basename(item)
      #print fname
      vsekey = ''.join(['http://junkurl:', httpport, '/', fname, '/'])
      delete_url = build_schema_node.create_crawl_delete(vsekey=vsekey,
                                     addnodeto=crawl_urls,
                                     synchronization='to-be-indexed')

      #
      #   Since each vse-key delete is a transaction, each one counts
      #   no matter how many are in a crawl-urls node?
      #
      enqcount += 1

   return crawl_urls

def do_crawl_urls(crawl_urls=None, filelist=None):

   global enqcount

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

   enqcount += 1

   return crawl_urls

#
#   Set up and fire off crawl-delete nodes
#
def do_deletes(dir, httpport='80'):

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
               crawl_deletes = do_crawl_deletes(crawl_deletes, filelist, httpport)
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
                    delcnt=0, transmatch=0, comment=None, filename=None):

   global fail

   print "#######################################################"
   print tname, ":  Audit numbers for collection", collection
   if ( comment is not None ):
      print tname, ":     ", comment

   time.sleep(60)

   resp = yy.api_sc_audit_log_retrieve(collection=collection, filename=filename)
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

def checkit(deletelist=None, filename=None):

   global fail

   if ( deletelist is None ):
      return None

   badcount = 0
   delcnt = 0
   for item in deletelist:
      delcnt += 1
      fname = os.path.basename(item)
      url = ''.join(['http://junkurl/', fname])
      resp = yy.api_qsearch(source=collection_name2, query=url)
      resurlcount = yy.getResultUrlCount(resptree=resp)
      if ( resurlcount != 0 ):
         badcount += 1
         fail = 1
         resurl = yy.getResultUrls(resptree=resp)
         print "----->", item, "should have been deleted and was not"
         print "----->", resurl, "is the gotten url"

   if ( badcount > 0 ):
      print "Number NOT removed which should have been: ", badcount

   token = dofinalauditlog(collection=collection_name2, tname=tname,
                           filecount=filecount, delcnt=delcnt,
                           transmatch=(filecount + delcnt),
                           comment="Enqueued, pre-purge", filename=filename)

   return token

if __name__ == "__main__":

   fail = 0

   global enqcount

   collection_name2 = "adlog-5b"
   collection_file2 = "adlog-5b.xml"
   tname = "api-audit-log-5"

   enqcount = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  audit logs test 1"
   print tname, ":     audit log is all"
   print tname, ":     detail is full"
   print tname, ":     purge-xml curl option does not break stuff"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   if ( xx.TENV.vivfloatversion < 7.5 ):
      print tname, ":  TEST NOT SUPPORTED IN THIS VERSION"
      print tname, ":  Test Not Run"
      sys.exit(0)

   interimauditlog = True
   doenqueuecollection = True
   waitonenqueue = True
   waitondelete = True

   dir = "/testenv/test_data/law/F2/210"

   sep = '/'
   if ( xx.TENV.targetos == 'windows' ):
      sep = "\\"

   if ( os.access(dir, os.F_OK) == 0 ):
      doenqueuecollection = False

   print tname, ":  PERFORM CRAWLS"

   if ( doenqueuecollection is False ):
      print tname, ":  WARNING, THE ENQUEUED COLLECTION WILL NOT BE RUN"

   if ( doenqueuecollection is False ):
      print tname, ":  TEST COULD NOT BE RUN AT ALL"
      print tname, ":  Test Failed"
      sys.exit(1)

   if ( doenqueuecollection is True ):
      print tname, ":     Create empty collection", collection_name2
      #
      #   Empty collection to be filled using crawl-urls
      #
      cex = xx.collection_exists(collection=collection_name2)
      if ( cex == 1 ):
         xx.delete_collection(collection=collection_name2)

      yy.api_sc_create(collection=collection_name2, based_on='default-push')
      yy.api_repository_update(xmlfile=collection_file2)

      yy.api_sc_crawler_start(collection=collection_name2, stype='new')

      #
      #   Calculate the name of the collection directory and db file.
      #   One thing gets what it thinks is the real one.  The other two
      #   are calculations of the possibilities.  If real does not match
      #   one of the possibles, quit the test.
      #
      vivdir = xx.vivisimo_dir(which='data')
      crawldir = xx.get_crawl_dir(collection=collection_name2)

      md5name = zz.getMD5Hash(textToHash=collection_name2)[0:3]

      #
      #   Possible crawl db 0
      #
      crawlsqldb0 = ''.join([vivdir, sep, 'search-collections', \
                             sep, md5name, sep, collection_name2, \
                             sep, 'crawl1', sep, 'log.sqlt'])
      #
      #   Possible crawl db 1
      #
      crawlsqldb1 = ''.join([vivdir, sep, 'search-collections', \
                             sep, md5name, sep, collection_name2, \
                             sep, 'crawl0', sep, 'log.sqlt'])
      #
      #   Anticipated real db
      #
      realcrawldb = ''.join([crawldir, sep, 'log.sqlt'])

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

      if ( waitonenqueue is True ):
         xx.wait_for_idle(collection=collection_name2)

      if ( interimauditlog is True ):
         dointerimauditlog(collection=collection_name2, tname=tname)

      print tname, ":  ##################"
      print tname, ":  Enqueueing(deleting) data using enqueue xml and crawl-delete"

      deletelist = do_deletes(dir)

      if ( interimauditlog is True ):
         dointerimauditlog(collection=collection_name2, tname=tname)

      if ( waitondelete is True ):
         xx.wait_for_idle(collection=collection_name2)

      if ( interimauditlog is True ):
         dointerimauditlog(collection=collection_name2, tname=tname)

      print tname, ":  ##################"

      if ( waitondelete is False ):
         xx.wait_for_idle(collection=collection_name2)

      time.sleep(10)
      token = checkit(deletelist=deletelist, filename='precheck1')

      #
      #   If the check failed, check it again
      #
      if ( fail == 1 ):
         time.sleep(5)
         token = checkit(deletelist=deletelist, filename='precheck2')

      print "#######################################################"
      print tname, ":Purge, using this TOKEN: ", token
      resp = yy.api_sc_audit_log_purge(collection=collection_name2, token=token)
      token = dofinalauditlog(collection=collection_name2, tname=tname,
                              filecount=0, delcnt=0, transmatch=0,
                              comment="Enqueued, post-purge, all zeroes",
                              filename='postcheck')

      print "#######################################################"

   print tname, ":  ##################"

   #print tname, ":  Getting the log.sqlt db file for collection", collection_name2
   #print tname, ":     File is, ", realcrawldb
   #time.sleep(5)
   #xx.get_file(getfile=realcrawldb, binary=1)

   print tname, ":  Total enqueues, ", enqcount

   #actenq = int(xx.run_db_query(dbfile='log.sqlt',
   #                         query='select count(*) from crawled;').strip('/n'))

   #print tname, ":  Actual enqueues, ", actenq


   ##############################################################

   #xx.kill_all_services()

   if ( fail == 0 ):
      if ( doenqueuecollection is True ):
         xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
