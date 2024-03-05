#!/usr/bin/python

#
#   Test of the api
#   This is a basic test of audit log retrieve/purge
#
import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node
from lxml import etree

def dofinalauditlog(collection=None, tname=None, filecount=0,
                    delcnt=0, comment=None):

   global fail

   print "#######################################################"
   print tname, ":  Audit numbers for collection", collection
   if ( comment is not None ):
      print tname, ":     ", comment

   time.sleep(60)

   resp = yy.api_sc_audit_log_retrieve(collection=collection)
   successcount = yy.getAuditLogSuccessCount(resptree=resp)
   entrycount = yy.getAuditLogEntryCount(resptree=resp)
   detailcount = yy.getResultGenericTagCount(resptree=resp,
                    tagname='crawl-url', attrname='status')
   token = yy.getAuditLogToken(resptree=resp)

   totalcount = filecount + delcnt

   print tname, ":(final)   Total Audit Log Entries,   ", entrycount
   print tname, ":(final)   Total Audit Log Successes, ", successcount
   print tname, ":(final)   Total Audit Log Detailed,  ", detailcount
   print tname, ":(final)   Total file transactions,   ", totalcount
   print tname, ":(final)              adds,           ", filecount
   print tname, ":(final)              deletes,        ", delcnt
   if ( totalcount != entrycount ):
      fail = 1
      print tname, ":  transaction count and entrycount do not match"
   if ( delcnt != detailcount ):
      fail = 1
      print tname, ":  transaction fails and details do not match"

   if ( fail == 1 ):
      print tname, ":  Test Failed"
      sys.exit(1)

   return token

if __name__ == "__main__":

   fail = 0

   collection_name1 = "adlog-3"
   tname = "api-audit-log-3"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  audit logs test 3"
   print tname, ":     audit log is all"
   print tname, ":     detail is unsuccessful"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   if ( xx.TENV.vivfloatversion < 7.5 ):
      print tname, ":  TEST NOT SUPPORTED IN THIS VERSION"
      print tname, ":  Test Not Run"
      sys.exit(0)

   docrawlcollection = True

   print tname, ":  PERFORM CRAWLS"

   if ( docrawlcollection is False ):
      print tname, ":  WARNING, THE CRAWLED COLLECTION WILL NOT BE RUN"
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

   thebeginning = time.time()

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   if ( docrawlcollection is True ):
      token = dofinalauditlog(collection=collection_name1, tname=tname,
                              filecount=50, delcnt=10,
                              comment="Crawled, pre-purge")

      print "#######################################################"
      print tname, ":Purge, using this TOKEN: ", token
      resp = yy.api_sc_audit_log_purge(collection=collection_name1, token=token)
      token = dofinalauditlog(collection=collection_name1, tname=tname,
                              filecount=0, delcnt=0,
                              comment="Crawled, post-purge, all zeroes")

      print "#######################################################"


   print tname, ":  ##################"

   ##############################################################

   #xx.kill_all_services()

   if ( fail == 0 ):
      if ( docrawlcollection is True ):
         xx.delete_collection(collection=collection_name1)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
