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
import velocityAPI, simpleLock
import os, getopt
import doc_updater
from lxml import etree

def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

#
#   Start the initial crawl.
#
def Start_The_Crawl_No_Wait(tname=None, xx=None, yy=None, collection=None):

   stime = etime = 0

   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      raise Exception("Collection Error")
      sys.exit(1)

   cex = xx.collection_exists(collection=collection)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection, force=1)

   colfile = ''.join([collection, '.xml'])

   yy.api_sc_create(collection=collection, based_on='default')
   yy.api_repository_update(xmlfile=colfile)
   print tname, ":  Starting the first crawl in live"
   yy.api_sc_crawler_start(collection=collection, stype='new')
   #stime = time.time()
   #xx.wait_for_idle(collection=collection)
   #etime = time.time()

   print tname, ":  Approximate crawl time (seconds) =", etime - stime

   return
#
#   Start the initial crawl.
#
def Start_The_Crawl(tname=None, xx=None, yy=None, collection=None):

   stime = etime = 0

   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      raise Exception("Collection Error")
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
def Do_Case_1(tname=None, xx=None, yy=None, collection=None, hard_result=15666):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the basic crawl data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="law/US", filename="USout",
                         num=100000, odup='true')
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

#
#   List item attachment check
#   List item thing2 has the attachment thing2_attachment
#
def Do_Case_2(tname=None, xx=None, yy=None, collection=None):

   case_result = 0
   hard_result = 7
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the List Item Attachment data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="NCC-1701",
                         filename="thing2out",
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

   if ( case_result == final_result ):
      return 1
   else:
      return 0

#
#   List item 
#   List items without attachements
#
def Do_Case_3_01(tname=None, xx=None, yy=None, collection=None):

   case_result = 0
   hard_result = 1
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the List  subitems"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="Vor\'Cha",
                         filename="vorcha_out",
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

#
#   List item 
#   List items without attachements
#
def Do_Case_3(tname=None, xx=None, yy=None, collection=None):

   case_result = 0
   hard_result = 9
   final_result = 3

   stime = etime = 0

   print tname, ":  Check the List by primary name"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="Klingons",
                         filename="klingon_out",
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

   case_result += Do_Case_3_01(tname, xx, yy, collection)

   if ( case_result == final_result ):
      return 1
   else:
      return 0

#
#   Subsite data check
#   Subsite MixedDocumentTypes should also have been crawled
#   with its varied docs.
#
def Do_Case_3_or_4(tname=None, xx=None, yy=None, collection=None):

   case_result = 0
   hard_result = 1
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the subsite data"

   xx.wait_for_idle(collection=collection)
   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="Borg",
                         filename="mdtout",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 3or4:  Totaled Results : ", urlcount
   print "CASE 3or4:  Counted Results : ", urlcount2
   print "CASE 3or4:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 3or4A:  Case Passed"
   else:
      print "CASE 3or4A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 3or4B:  Case Passed"
   else:
      print "CASE 3or4B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      return 0


def Update_For_Case_4(tname=None, xx=None, yy=None, collection=None):

   global cmd_params

   cmd_params['listitem'] = None
   cmd_params['listname'] = "/testenv/test_data/law/F3/465"

   stime = etime = 0

   print tname, ":  Do a refresh and check the data"
   print tname, ":  Add data to the crawled site for a refresh"

   doc_updater.createTree(**cmd_params)

   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

   return 0
#
#   Do a refresh and look for the new data.
#
def Do_Case_4(tname=None, xx=None, yy=None, collection=None, hard_result=55):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the data after refresh"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="F3",
                         filename="f3out",
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

   if ( case_result == final_result ):
      return 1
   else:
      return 0


def Update_For_Case_5(tname=None, xx=None, yy=None, collection=None):

   global cmd_params

   cmd_params['listname'] = "/testenv/test_data/law/F3"
   cmd_params['listitem'] = None

   stime = etime = 0

   print tname, ":  Do a refresh(delete) and check the data"
   print tname, ":  Delete data from the crawled site for a refresh"

   doc_updater.deleteTree(**cmd_params)
   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

   return 0
#
#   Do a refresh and look for the new data.
#
def Do_Case_5(tname=None, xx=None, yy=None, collection=None):

   case_result = 0
   hard_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the data after refresh"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="F3",
                         filename="f3delout",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 5:  Totaled Results : ", urlcount
   print "CASE 5:  Counted Results : ", urlcount2
   print "CASE 5:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 5A:  Case Passed"
   else:
      print "CASE 5A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 5B:  Case Passed"
   else:
      print "CASE 5B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      return 0

#
#   Common exit routine for every routine to bail to if needed.
#
def Do_Exit_Routine(tname="not defined", total_results=0, expected_total=-1):

   if (total_results == expected_total):
      print tname, ":  Test Passed"
      return 0
   
   print tname, ":  Test Failed"
   return 1

def Gen_Compare_Lists(qstring='law/US/539', baseString=None, baselist=None):

   if ( baselist is None ):
      dirstring = "/testenv/test_data/" + qstring
      baselist = os.listdir(dirstring)

   fulllist = []
   for item in baselist:
      thing = baseString + qstring + "/" + item
      fulllist.append(thing)

   return fulllist, baselist


def Compare_Two(myList, collection, xx, yy, tname, qstring, qfile):

   stime = time.time()
   resp = yy.api_qsearch(source=collection, num=6000,
                         query=qstring, filename=qfile)
   etime = time.time()
   print tname, ":  Approximate query time for collection", collection
   print tname, ":     ", etime - stime, "seconds"

   resList = yy.getResultUrls(resptree=resp)
   urlcount = yy.getResultUrlCount(resptree=resp)
   totalcount = yy.getTotalResults(resptree=resp)

   cc = 0
   for item in myList:
      x = isInList(item, resList)
      if ( x != 1 ):
         print tname, ":   Missing from collection:", collection
         print tname, ":      ", item
         cc += 1

   for item in resList:
      x = isInList(item, myList)
      if ( x != 1 ):
         print tname, ":   Extra in collection(directory?):", collection
         print tname, ":      ", item

   return urlcount, totalcount, cc


def Like_Collection_Data_Compare(tname="not defined", xx=None,
                                 yy=None, collection=None):

   global cmd_params

   fsCollection = 'sp-basic-fs'
   cifsCollection = 'sp-basic-cifs'
   qstring = 'law/US/539'
   expected_for_all = 1153
   case_result = 0
   subber = 1

   if ( collection == 'sp-basic-1-oldconn' ):
      subber = 0

   if ( xx.TENV.targetos == 'linux' ):
      Start_The_Crawl_No_Wait(tname, xx, yy, fsCollection)
   Start_The_Crawl_No_Wait(tname, xx, yy, cifsCollection)

   baseString = cmd_params['site'] + "testenv/test_data/"
   spList, baselist = Gen_Compare_Lists(qstring, baseString, None)
   baseString = "file:///testenv/test_data/"
   fsList, baselist = Gen_Compare_Lists(qstring, baseString, baselist)
   baseString = "smb://testbed5.test.vivisimo.com/testfiles/test_data/"
   cifsList, baselist = Gen_Compare_Lists(qstring, baseString, baselist)

   if ( xx.TENV.targetos == 'linux' ):
      xx.wait_for_idle(collection=fsCollection)
   xx.wait_for_idle(collection=cifsCollection)

   spUrl, spTot, spMis = Compare_Two(spList, collection, xx, yy, tname, qstring, 'spdump')
   cifsUrl, cifsTot, cifsMis = Compare_Two(cifsList, cifsCollection, xx, yy, tname, qstring, 'cifsdump')
   if ( xx.TENV.targetos == 'linux' ):
      fsUrl, fsTot, fsMis = Compare_Two(fsList, fsCollection, xx, yy, tname, qstring, 'fsdump')

   print tname, ":  UNIQUE DOCUMENTS FOUND,"
   if ( collection == 'sp-basic-1-oldconn' ):
      print tname, ":     SHAREPOINT (OLD CONNECTOR),", spUrl
   else:
      print tname, ":     SHAREPOINT (SPOC),", spUrl - subber, "+ 1(for directory)"
   print tname, ":     SAMBA/CIFS,       ", cifsUrl
   if ( xx.TENV.targetos == 'linux' ):
     print tname, ":     FILE SYSTEM,      ", fsUrl

   print tname, ":  TOTAL DOCUMENTS FOUND,"
   if ( collection == 'sp-basic-1-oldconn' ):
      print tname, ":     SHAREPOINT (OLD CONNECTOR),", spTot
   else:
      print tname, ":     SHAREPOINT (SPOC),", spTot - subber, "+ 1(for directory)"
   print tname, ":     SAMBA/CIFS,       ", cifsTot
   if ( xx.TENV.targetos == 'linux' ):
     print tname, ":     FILE SYSTEM,      ", fsTot

   print tname, ":  TOTAL DOCUMENTS MISSING,"
   if ( collection == 'sp-basic-1-oldconn' ):
      print tname, ":     SHAREPOINT (OLD CONNECTOR),", spMis
   else:
      print tname, ":     SHAREPOINT (SPOC),", spMis
   print tname, ":     SAMBA/CIFS,       ", cifsMis
   if ( xx.TENV.targetos == 'linux' ):
     print tname, ":     FILE SYSTEM,      ", fsMis

   if ( xx.TENV.targetos == 'linux' ):
      if ( (spUrl - subber) == fsUrl ):
         if ( (spUrl - subber) == cifsUrl ):
            case_result += 1
   else:
      if ( (spUrl - subber) == cifsUrl ):
         case_result += 1

   if ( case_result == 1 ):
      print "CASE 6A:  Case Passed"
   else:
      print "CASE 6A:  Case Failed"

   if ( xx.TENV.targetos == 'linux' ):
      if ( (spTot - subber) == fsTot ):
         if ( (spTot - subber) == cifsTot ):
            case_result += 1
   else:
      if ( (spTot - subber) == cifsTot ):
         case_result += 1

   if ( case_result == 2 ):
      print "CASE 6B:  Case Passed"
   else:
      print "CASE 6B:  Case Failed"

   if ( (spUrl - subber) == expected_for_all ):
      if ( (spTot - subber) == expected_for_all ):
         case_result += 1

   if ( case_result == 3 ):
      print "CASE 6C:  Case Passed"
   else:
      print "CASE 6C:  Case Failed"

   return case_result

if __name__ == "__main__":

   global cmd_params

   cmd_params = {}

   fail = 1
   nokill = True

   sitetype = '2010'

   opts, args = getopt.getopt(sys.argv[1:], "v:k", ["version=", "kill"])

   for o, a in opts:
     if o in ("-v", "--version"):
        sitetype = a
     if o in ("-k", "--kill"):
        nokill = False

   if ( sitetype == '2010' ):
      hard_result = [15666, 55]
      cmd_params['site'] = 'http://testbed19-1.test.vivisimo.com:34687/'
      #cmd_params['site'] = 'http://testbed18-1.test.vivisimo.com:34687/'
      cmd_params['user'] = 'administrator'
      cmd_params['pw'] = 'Mustang5'
      cmd_params['domain'] = 'sptest'
      collection_name = "sp-basic-1-2010"
      lock = simpleLock.simpleLock("tb19-1.34687")
   elif ( sitetype == '2007' ):
      #site = 'http://testbed19-2.test.vivisimo.com:36371/'
      #cmd_params['site'] = 'http://testbed19-2.test.vivisimo.com:36371/'
      hard_result = [15666, 55]
      cmd_params['site'] = 'http://testbed19-2:36371/'
      cmd_params['user'] = 'administrator'
      cmd_params['pw'] = 'VolvoV70'
      cmd_params['domain'] = 'sp07test'
      collection_name = "sp-basic-1-2007"
      lock = simpleLock.simpleLock("tb19-2.36371")
   else:
      hard_result = [15658, 53]
      cmd_params['site'] = 'http://testbed19-2:36371/'
      cmd_params['user'] = 'administrator'
      cmd_params['pw'] = 'VolvoV70'
      cmd_params['domain'] = 'sp07test'
      collection_name = "sp-basic-1-oldconn"
      lock = simpleLock.simpleLock("tb19-2.36371")

   case_res = [0, 0, 0, 0, 0, 0, 0]
   case_rt = [0, 0, 0, 0, 0, 0, 0]
   case_desc = ['crawl and query', 'attachemnt query',
                'list item query', 'blog query', 'update (add) and query',
                'update (delete) and query', 'comparitive crawl/query']
 
   stime = etime = 0
   cstime = cetime = 0

   tname = "sp-basic-1"
   colfile = collection_name + '.xml'
   funcfile = 'oldspfunction.xml'

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Set up for SPOC basic crawl"
   print tname, ":     Basic crawl using the new sharepoint connector"

   total_results = 0
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   lock.setLock()

   try:
   
      if ( collection_name == 'sp-basic-1-oldconn' ):
         yy.api_repository_update(xmlfile=funcfile)
   
      cmd_params['listname'] = "/testenv/test_data/law/F3/465"
      cmd_params['listitem'] = None
      doc_updater.deleteTree(**cmd_params)
   
   
      stime = time.time()
   
      cstime = time.time()
      if ( nokill ):
         Start_The_Crawl(tname, xx, yy, collection_name)
      else:
         Start_The_Crawl_No_Wait(tname, xx, yy, collection_name)
         i = 0
         while ( i < 5 ):
            time.sleep(45)
            yy.api_sc_crawler_stop(collection=collection_name, killit='true',
                                   subc='live')
            time.sleep(5)
            yy.api_sc_crawler_start(collection=collection_name, stype='resume')
            i += 1
         xx.wait_for_idle(collection=collection_name)
   
      print "#################################################"
   
      current_results = Do_Case_1(tname, xx, yy, collection_name, hard_result[0])
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[0] = 1
      total_results += current_results
   
      print "#################################################"
   
      cstime = time.time()
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
      current_results = Do_Case_3_or_4(tname, xx, yy, collection_name)
      cetime = time.time()
      case_rt[3] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 4)
      else:
         case_res[3] = 1
      total_results += current_results
   
      print "#################################################"
   
      cstime = time.time()
      Update_For_Case_4(tname, xx, yy, collection_name)
      current_results = Do_Case_4(tname, xx, yy, collection_name, hard_result[1])
      cetime = time.time()
      case_rt[4] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 5)
      else:
         case_res[4] = 1
      total_results += current_results
   
      print "#################################################"
   
      cstime = time.time()
      Update_For_Case_5(tname, xx, yy, collection_name)
      current_results = Do_Case_5(tname, xx, yy, collection_name)
      cetime = time.time()
      case_rt[5] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 5)
      else:
         case_res[5] = 1
      total_results += current_results
   
      etime = time.time()
   
      print "#################################################"
   
      cstime = time.time()
      current_results = Like_Collection_Data_Compare(tname, xx, yy, collection_name)
      cetime = time.time()
      case_rt[6] = cetime - cstime
      if (current_results != 3):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[6] = 1
      total_results += current_results
   
      print "#################################################"
   
   
      print tname, ":  Actual   Total Results =", total_results
      print tname, ":  Expected Total Results = 9"
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
   
   finally:
      cmd_params['listname'] = "/testenv/test_data/law/F3/465"
      cmd_params['listitem'] = None
      doc_updater.deleteTree(**cmd_params)
      lock.freeLock()
   
   if (Do_Exit_Routine(tname, total_results, 9) == 0):
      xx.delete_collection(collection=collection_name, force=1)
      sys.exit(0)
   
   sys.exit(1)
      