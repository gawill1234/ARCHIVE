#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   This is the basic crawl test created to test SPOC
#   (the new sharepooint connector).  This test does
#   A)  A basic crawl
#   B)  A data update and refresh
#   C)  A large data update and refresh while the data is updating
#       followed by a terminating update to get final data.
#
#   This test is used for both sharepoint 2007 and 2010.  There is a
#   site for each with identical data.
#
#   If the data indicates that the queried/returned data is different
#   than expected, check that near duplicate mathing is not eliminating
#   some results of the queries.  The shingles word count has been set
#   to 20 with the default check count of 14 still in place to shrink the
#   possibility of a duplcation to near 0, however the possibility does
#   exist for an unexpected flagging of two files being duplicates.
#
#

import sys, time, cgi_interface, vapi_interface 
import velocityAPI
import os, getopt
from lxml import etree

def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

def build_command(site, user, pw, domain, dowhat,
                  thingwhat, itemname, mountpoint):
   
   validdowhat = ['create', 'delete', 'update', 'showall', 'quickcheck']
   validthingwhat = ['folder', 'tree', 'file', 'document', 'list', 'listitem']

   if (dowhat in validdowhat):
      cmd = 'run_bulk_loader'
      cmdstring = ''
   
      cmdstring = cmdstring + ' -site ' + site
      cmdstring = cmdstring + ' -user ' + user
      cmdstring = cmdstring + ' -pw ' + pw
      cmdstring = cmdstring + ' -domain ' + domain

      if (dowhat == 'showall' or dowhat == 'quickcheck'):
         if (dowhat == 'showall'):
            cmdstring = cmdstring + ' -showall'
         else:
            cmdstring = cmdstring + ' -quickcheck'
         return cmd, cmdstring
      else:
         if (thingwhat in validthingwhat):
            if (dowhat == 'update'):
               cmdstring = cmdstring + ' -update ' + thingwhat
            elif (dowhat == 'delete'):
               cmdstring = cmdstring + ' -delete ' + thingwhat
            else:
               cmdstring = cmdstring + ' -create ' + thingwhat
            if (thingwhat == 'tree'):
               cmdstring = cmdstring + ' -mountpoint ' + mountpoint
            else:
               cmdstring = cmdstring + ' -mountpoint ' + mountpoint
               cmdstring = cmdstring + ' -itemname ' + itemname
            return cmd, cmdstring

   return None, None

def deleteList(listname=None):

   global site, user, pw, domain

   cmd, cmdstring = build_command(site, user, pw, domain, "delete",
                             "list", listname, "/")

   print cmdstring

   y = xx.exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='> querywork/addit')

   return

def deleteListItem(listname=None, listitem=None):

   global site, user, pw, domain

   cmd, cmdstring = build_command(site, user, pw, domain, "delete",
                             "listitem", listitem, listname)

   print cmdstring

   y = xx.exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='> querywork/addit')

   return

def createList(listname=None):

   global site, user, pw, domain

   cmd, cmdstring = build_command(site, user, pw, domain, "create",
                             "list", listname, "/")

   print cmdstring

   y = xx.exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='> querywork/addit')

   return

def createListItem(listname=None, listitem=None):

   global site, user, pw, domain

   cmd, cmdstring = build_command(site, user, pw, domain, "create",
                             "listitem", listitem, listname)

   print cmdstring

   y = xx.exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='> querywork/addit')

   return

def flush_all_data(tname=None, xx=None, yy=None, collection=None):

   global site, user, pw, domain

   liststoplace = ['Klingons', 'Federation', 'Romulan']

   for item in liststoplace:
      deleteList(listname=item)

   listitemstoplace = ['Constitution', 'Sovereign', 'Ambassador', 'NX',
                       'Excelsior', 'Galaxy', 'Universe', 'Galaxy_Dreadnaught']

   for item in listitemstoplace:
      deleteListItem(listname="/Federation", listitem=item)

   return 0
#
#   Start the initial crawl.
#
def Start_The_Crawl(tname=None, xx=None, yy=None, collection=None):

   stime = etime = 0

   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      sys.exit(1)

   cex = xx.collection_exists(collection=collection)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection, force=1)

   colfile = ''.join([collection, '.xml'])

   yy.api_sc_create(collection=collection, based_on='default')
   yy.api_repository_update(xmlfile=colfile)
   print tname, ":  Starting the first crawl in live"
   yy.api_sc_crawler_start(collection=collection, stype='new')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate crawl time (seconds) =", etime - stime

   return

#
#   Wait for the initial crawl to complete and do error checking for
#   a basic crawl.  I.e., does it crawl at all?
#   This query will return folders and documents under the
#   /testenv/test_data/law/US data folder from within sharepoint.
#
def Do_Case_1(tname=None, xx=None, yy=None, collection=None):

   case_result = 0
   #
   #   this is the base data in a newly created sharepoint teamsite for 2010.
   #
   hard_result = 15
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the basic crawl data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 1:  Totaled Results : ", urlcount
   print "CASE 1:  Counted Results : ", urlcount2
   print "CASE 1:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 1A:  Case Passed"
   else:
      print "CASE 1A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 1B:  Case Passed"
   else:
      print "CASE 1B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def Do_Case_4_01(tname=None, xx=None, yy=None, collection=None, queryword=None):

   case_result = 0
   hard_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the List -", queryword

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query=queryword,
                         filename="list_elem_out",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 4_01:  Totaled Results : ", urlcount
   print "CASE 4_01:  Counted Results : ", urlcount2
   print "CASE 4_01:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 4_01A:  Case Passed"
   else:
      print "CASE 4_01A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 4_01B:  Case Passed"
   else:
      print "CASE 4_01B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      return 0


def Do_Case_4(tname=None, xx=None, yy=None, collection=None):

   liststoplace = ['Klingons', 'Romulan']

   case_result = 0
   #
   #   this is the base data in a newly created sharepoint teamsite for 2010.
   #
   hard_result = 24
   final_result = 4

   stime = etime = 0

   print tname, ":  Check the basic crawl data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 4:  Totaled Results : ", urlcount
   print "CASE 4:  Counted Results : ", urlcount2
   print "CASE 4:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 4A:  Case Passed"
   else:
      print "CASE 4A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 4B:  Case Passed"
   else:
      print "CASE 4B:  Case Failed"

   for item in liststoplace:
      case_result += Do_Case_4_01(tname, xx, yy, collection, item)

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def Update_For_Case_4(tname=None, xx=None, yy=None, collection=None):

   global site, user, pw, domain

   liststoplace = ['Klingons', 'Romulan']

   for item in liststoplace:
      deleteList(listname=item)

   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

   return 0

def Do_Case_3_01(tname=None, xx=None, yy=None, collection=None, queryword=None):

   case_result = 0
   hard_result = 1
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the List -", queryword

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query=queryword,
                         filename="list_elem_out",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 3_01:  Totaled Results : ", urlcount
   print "CASE 3_01:  Counted Results : ", urlcount2
   print "CASE 3_01:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 3_01A:  Case Passed"
   else:
      print "CASE 3_01A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 3_01B:  Case Passed"
   else:
      print "CASE 3_01B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      return 0


def Do_Case_3(tname=None, xx=None, yy=None, collection=None):

   listitemstoplace = ['Constitution', 'Sovereign', 'Ambassador', 'NX',
                       'Excelsior', 'Galaxy', 'Universe', 'Galaxy_Dreadnaught']

   case_result = 0
   hard_result = 26
   final_result = 9

   stime = etime = 0

   print tname, ":  Check the basic crawl data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 3:  Totaled Results : ", urlcount
   print "CASE 3:  Counted Results : ", urlcount2
   print "CASE 3:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 3A:  Case Passed"
   else:
      print "CASE 3A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 3B:  Case Passed"
   else:
      print "CASE 3B:  Case Failed"

   for item in listitemstoplace:
      case_result += Do_Case_3_01(tname, xx, yy, collection, item)

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def Update_For_Case_3(tname=None, xx=None, yy=None, collection=None):

   global site, user, pw, domain

   listitemstoplace = ['Constitution', 'Sovereign', 'Ambassador', 'NX',
                       'Excelsior', 'Galaxy', 'Universe', 'Galaxy_Dreadnaught']

   for item in listitemstoplace:
      createListItem(listname="/Federation", listitem=item)

   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

   return 0

def Do_Case_2_01(tname=None, xx=None, yy=None, collection=None, queryword=None):

   case_result = 0
   hard_result = 1
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the List -", queryword

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query=queryword,
                         filename="list_elem_out",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 2_01:  Totaled Results : ", urlcount
   print "CASE 2_01:  Counted Results : ", urlcount2
   print "CASE 2_01:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 2_01A:  Case Passed"
   else:
      print "CASE 2_01A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 2_01B:  Case Passed"
   else:
      print "CASE 2_01B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      return 0


def Do_Case_2(tname=None, xx=None, yy=None, collection=None):

   liststoplace = ['Klingons', 'Federation', 'Romulan']

   case_result = 0
   #
   #   this is the base data in a newly created sharepoint teamsite for 2010.
   #
   hard_result = 18
   final_result = 5

   stime = etime = 0

   print tname, ":  Check the basic crawl data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 2:  Totaled Results : ", urlcount
   print "CASE 2:  Counted Results : ", urlcount2
   print "CASE 2:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 2A:  Case Passed"
   else:
      print "CASE 2A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 2B:  Case Passed"
   else:
      print "CASE 2B:  Case Failed"

   for item in liststoplace:
      case_result += Do_Case_2_01(tname, xx, yy, collection, item)

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def Update_For_Case_2(tname=None, xx=None, yy=None, collection=None):

   global site, user, pw, domain

   liststoplace = ['Klingons', 'Federation', 'Romulan']

   for item in liststoplace:
      createList(listname=item)

   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

   return 0
#
#   Common exit routine for every routine to bail to if needed.
#
def Do_Exit_Routine(tname="not defined", total_results=0, expected_total=-1):

   if (total_results == expected_total):
      print tname, ":  Test Passed"
      return 0
      #sys.exit(0)
   
   print tname, ":  Test Failed"
   return 1
   #sys.exit(1)

if __name__ == "__main__":

   global site, user, pw, domain

   fail = 1

   sitetype = '2010'

   opts, args = getopt.getopt(sys.argv[1:], "v:", ["version="])

   for o, a in opts:
     if o in ("-v", "--version"):
        sitetype = a
        sitetype = '2010'

   if ( sitetype == '2010' ):
      site = 'http://testbed18-1.test.vivisimo.com:47401/'
      user = 'administrator'
      pw = 'Mustang5'
      domain = 'sptest'
      collection_name = "sp-updates-1-2010"
   else:
      #site = 'http://testbed19-2.test.vivisimo.com:36436/'
      site = 'http://testbed19-2:36436/'
      user = 'administrator'
      pw = 'VolvoV70'
      domain = 'sp07test'
      collection_name = "sp-updates-1-2007"

   dowhat = 'quickcheck'
   thingwhat = 'document'
   itemname = None
   mountpoint = None

   case_res = [0,0,0,0,0,0]
   case_rt = [0,0,0,0,0,0]
   case_desc = ['crawl and query', 'attachemnt query',
                'list item query', 'update (add) and query',
                'update (delete) and query', 'comparitive crawl/query']
 
   stime = etime = 0
   cstime = cetime = 0

   tname = "sp-updates-1"
   colfile = collection_name + '.xml'

   cmd, cmdstring = build_command(site, user, pw, domain, dowhat,
                             thingwhat, itemname, mountpoint)

   print cmdstring


   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Set up for SPOC basic crawl"
   print tname, ":     Basic crawl using the new sharepoint connector"
   total_results = 0
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   flush_all_data(tname, xx, yy, collection_name)

   stime = time.time()

   cstime = time.time()
   Start_The_Crawl(tname, xx, yy, collection_name)

   print "#################################################"

   current_results = Do_Case_1(tname, xx, yy, collection_name)
   cetime = time.time()
   case_rt[0] = cetime - cstime
   if (current_results != 1):
      Do_Exit_Routine(tname, total_results, 1)
   else:
      case_res[0] = 1
   total_results += current_results

   print "#################################################"

   cstime = time.time()
   Update_For_Case_2(tname, xx, yy, collection_name)
   current_results = Do_Case_2(tname, xx, yy, collection_name)
   cetime = time.time()
   case_rt[1] = cetime - cstime
   if (current_results != 1):
      Do_Exit_Routine(tname, total_results, 2)
   else:
      case_res[1] = 1
   total_results += current_results

   print "#################################################"

   cstime = time.time()
   Update_For_Case_3(tname, xx, yy, collection_name)
   current_results = Do_Case_3(tname, xx, yy, collection_name)
   cetime = time.time()
   case_rt[2] = cetime - cstime
   if (current_results != 1):
      Do_Exit_Routine(tname, total_results, 4)
   else:
      case_res[2] = 1
   total_results += current_results

   print "#################################################"

   cstime = time.time()
   Update_For_Case_4(tname, xx, yy, collection_name)
   current_results = Do_Case_4(tname, xx, yy, collection_name)
   cetime = time.time()
   case_rt[3] = cetime - cstime
   if (current_results != 1):
      Do_Exit_Routine(tname, total_results, 4)
   else:
      case_res[3] = 1
   total_results += current_results

   sys.exit(0)

   print "#################################################"

   print tname, ":  Actual   Total Results =", total_results
   print tname, ":  Expected Total Results = 8"
   print tname, ":  Approximate test run time (seconds) =", etime - stime

   print tname, ":  CASE RESULTS SUMMARY"
   i = 1
   for item in case_res:
      if ( item == 1 ):
         print tname, ":     CASE", i, "PASSED,", case_desc[i - 1]
      else:
         print tname, ":     CASE", i, "FAILED,", case_desc[i - 1]
      print tname, ":        CASE", i, "Approximate run time (seconds) =", case_rt[i - 1]
      i += 1

   sys.exit(Do_Exit_Routine(tname, total_results, 8))
