#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   Test for bug 20997.  Checks that a string after
#   a character which would have caused the string to
#   become garbled/destroyed does not by querying for that
#   string.
#
#   The data is in /testenv/samba_test_data/20997/test.xls
#

import sys, cgi_interface, vapi_interface 

def dointerimauditlog(collection=None, tname=None):

   resp = yy.api_sc_audit_log_retrieve(collection=collection)
   successcount = yy.getAuditLogSuccessCount(resptree=resp)
   entrycount = yy.getAuditLogEntryCount(resptree=resp)
   token = yy.getAuditLogToken(resptree=resp)

   print tname, ":(interim,info)   Total Audit Log Entries,   ", entrycount
   print tname, ":(interim,info)   Total Audit Log Successes, ", successcount

   if ( entrycount == 7 ):
      if ( successcount == 7 ):
         return 1

   return 0


if __name__ == "__main__":

   cs_pass = 0

   collection_name = "27596"
   tname = "27596"
   colfile = ''.join([collection_name, '.xml'])
   modfile = ''.join([collection_name, '.mod.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.version_check(minversion=8.2)

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name)

   xx.wait_for_idle(collection=collection_name)

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN:  Bug 27596"
   print tname, ":                     Indexer/Crawler crash with activity feed."

   print tname, ":  ##################"
   print tname, ":  CASE 1, initial crawl/query"

   cs_pass += dointerimauditlog(collection=collection_name, tname=tname)

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 2, delete/refresh/query"

   yy.api_repository_update(xmlfile=modfile)
   print tname, ":  Starting the first crawl in live"
   yy.api_sc_crawler_start(collection=collection_name, stype='refresh-inplace')
   xx.wait_for_idle(collection=collection_name)

   cs_pass += dointerimauditlog(collection=collection_name, tname=tname)

   print tname, ":  ##################"
   print tname, ":  ##################"

   print tname, ":  cs_pass =", cs_pass

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == 2 ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
