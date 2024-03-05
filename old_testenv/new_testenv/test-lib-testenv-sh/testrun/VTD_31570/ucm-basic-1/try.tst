#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, time, cgi_interface, vapi_interface 
import velocityAPI, simpleLock
import os, getopt
import doc_updater_ucm
from lxml import etree
from threading import Thread

class doSPUpdate ( Thread ):

   cmd_params = {}
   mylist = None

   def __init__(self, site, user, pw, domain, updateList):

      Thread.__init__(self)

      self.cmd_params['site'] = site
      self.cmd_params['user'] = user
      self.cmd_params['pw'] = pw
      self.cmd_params['domain'] = domain

      self.mylist = updateList

      self.xx = cgi_interface.CGIINTERFACE()
      self.yy = vapi_interface.VAPIINTERFACE()

      return


   def run(self):


      for item in self.mylist:
         print "Working with directory", item
         stime = time.time()
         self.cmd_params['listname'] = item
         self.cmd_params['listitem'] = None
         doc_updater_ucm.createTree_ucm(**self.cmd_params)
         etime = time.time()
         print "Load time (seconds) =", etime - stime

      return


def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

#
#
##############################################################
#
#
def Refresh_The_Crawl(tname=None, xx=None, yy=None, collection=None, cwait=True):

   stime = etime = 0

   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      raise Exception("Collection Error")
      sys.exit(1)

   cex = xx.collection_exists(collection=collection)
   if ( cex == 1 ):
      print tname, ":  Refreshing the crawl in live"
      yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
      if ( cwait ):
         stime = time.time()
         xx.wait_for_idle(collection=collection)
         etime = time.time()

   print tname, ":  Approximate crawl time (seconds) =", etime - stime

   return
#
#
##############################################################
#
#

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
#   /testenv/test_data/law/US data folder from within UCM.
#
def Run_The_Test_Case(tname=None, xx=None, yy=None,
                      collection=None, hard_result=15666):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the basic crawl data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="USout",
                         num=100000, odup='true')
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE RTTC:  Totaled Results : ", urlcount
   print "CASE RTTC:  Counted Results : ", urlcount2
   print "CASE RTTC:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE RTTC-A:  Case Passed"
   else:
      print "CASE RTTC-A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE RTTC-B:  Case Passed"
   else:
      print "CASE RTTC-B:  Case Failed"

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

def directoryExists(myDirectory=None):

   if ( myDirectory is not None ):
      if ( os.path.exists(myDirectory) ):
         return 1

   return 0

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

   hard_result = [170, 308, 170, 10302, 10259, 10094, 170]
   cmd_params['site'] = 'http://testbed6-6.test.vivisimo.com/idc/idcplg'
   cmd_params['user'] = 'sysadmin'
   cmd_params['pw'] = 'idc'
   cmd_params['domain'] = ''
   collection_name = "ucm-basic-1"
   #lock = simpleLock.simpleLock("tb6-6.UCM")

   case_res = [0, 0, 0, 0, 0, 0, 0]
   case_rt = [0, 0, 0, 0, 0, 0, 0]
   case_desc = ['new crawl: base crawl and query',
                'update: add many document types, refresh, and query',
                'update: delete many document types, refresh, and query',
                'update: add a huge number of files, refresh, and query',
                'update: delete 2 directories(86 files), refresh, and query',
                'update: delete 203 files, refresh, and query',
                'update: delete all added files, refresh, and query']
 
   stime = etime = 0
   cstime = cetime = 0

   tname = "ucm-basic-1"
   colfile = collection_name + '.xml'

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Set up for UCM basic crawl"
   print tname, ":     Basic crawl using the new Oracle UCM connector"

   print "#################################################"

   initlist = ['/testenv/test_data/document/PPT',
               '/testenv/test_data/document/PDF',
               '/testenv/test_data/document/XLS',
               '/testenv/test_data/document/XLSX',
               '/testenv/test_data/document/DOC',
               '/testenv/test_data/document/DOCX',
               '/testenv/test_data/document/PPTX']

   doit = doSPUpdate('http://testbed6-6.test.vivisimo.com/cs/idcplg',
                        'weblogic', 'mustang5', '', initlist)

   doit.start()
   print tname, ":  Initialize sharepoint with data."

   print "Waiting ..."
   doit.join()

   sys.exit()

   total_results = 0
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   #lock.setLock()

   print "Initialize main load list"
   loadlist = []
   x = 1
   while ( x < 200 ):
      swiffer = '/testenv/test_data/law/US/' + '%s' % x
      x += 1
      if ( directoryExists(swiffer) ):
         print "Loadable directory:", swiffer
         loadlist.append(swiffer)

   try:
   
      cmd_params['listname'] = "/testenv"
      cmd_params['listitem'] = None
      doc_updater_ucm.deleteTree_ucm(**cmd_params)

      cmd_params['listname'] = "/home"
      cmd_params['listitem'] = None
      doc_updater_ucm.deleteTree_ucm(**cmd_params)

      stime = time.time()
   
      cstime = time.time()
   
      print "#################################################"

      if ( nokill ):
         Start_The_Crawl(tname, xx, yy, collection_name)
      else:
         Start_The_Crawl_No_Wait(tname, xx, yy, collection_name)
         i = 0
         while ( i < 5 ):
            time.sleep(45)
            yy.api_sc_crawler_stop(collection=collection_name, killit='true',
                                   subc='live')
            time.sleep(10)
            yy.api_sc_crawler_start(collection=collection_name, stype='resume')
            i += 1
         xx.wait_for_idle(collection=collection_name)
   
      using = 0
      current_results = Run_The_Test_Case(tname, xx, yy,
                                          collection_name, hard_result[using])
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[using] = 1
      total_results += current_results
   
      print "#################################################"
      print "#################################################"

      initlist = ['/testenv/test_data/document/PPT',
                  '/testenv/test_data/document/PDF',
                  '/testenv/test_data/document/XLS',
                  '/testenv/test_data/document/XLSX',
                  '/testenv/test_data/document/DOC',
                  '/testenv/test_data/document/DOCX',
                  '/testenv/test_data/document/PPTX']

      doit = doSPUpdate('http://testbed6-6.test.vivisimo.com/idc/idcplg',
                        'sysadmin', 'idc', '', initlist)

      doit.start()
      print tname, ":  Initialize sharepoint with data."

      print "Waiting ..."
      doit.join()

      Refresh_The_Crawl(tname, xx, yy, collection_name)

      using += 1
      current_results = Run_The_Test_Case(tname, xx, yy,
                                          collection_name, hard_result[using])
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[using] = 1
      total_results += current_results

      print "#################################################"
      print "#################################################"

      cmd_params['listname'] = "/testenv"
      cmd_params['listitem'] = None
      doc_updater_ucm.deleteTree_ucm(**cmd_params)
      time.sleep(10)

      Refresh_The_Crawl(tname, xx, yy, collection_name)

      using += 1
      current_results = Run_The_Test_Case(tname, xx, yy,
                                          collection_name, hard_result[using])
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[using] = 1
      total_results += current_results

      print "#################################################"
      print "#################################################"


      zz = len(loadlist)

      start = 0
      stop = 5
      while ( start < zz ):
         doit = doSPUpdate('http://testbed6-6.test.vivisimo.com/idc/idcplg',
                           'sysadmin', 'idc', '', loadlist[start:stop])
         start = stop + 1
         stop = start + 5
         if ( stop > zz ):
            stop = zz - 1

         doit.start()
         print tname, ":  Initialize UCM with data."

         print "Waiting ..."
         doit.join()

         time.sleep(8)

      Refresh_The_Crawl(tname, xx, yy, collection_name)

      using += 1
      current_results = Run_The_Test_Case(tname, xx, yy,
                                          collection_name, hard_result[using])
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[using] = 1
      total_results += current_results
   
      print "#################################################"
      print "#################################################"

      cmd_params['listname'] = "/testenv/test_data/law/US/9"
      cmd_params['listitem'] = None
      doc_updater_ucm.deleteTree_ucm(**cmd_params)

      cmd_params['listname'] = "/testenv/test_data/law/US/90"
      doc_updater_ucm.deleteTree_ucm(**cmd_params)
      time.sleep(10)

      Refresh_The_Crawl(tname, xx, yy, collection_name)

      using += 1
      current_results = Run_The_Test_Case(tname, xx, yy,
                                          collection_name, hard_result[using])
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[using] = 1
      total_results += current_results

      print "#################################################"
      print "#################################################"

      cmd_params['listname'] = None
      #
      #   Delete at least one file from each of 4 directories.
      #
      #   index.html
      #   199 directories should contain this file, all of which
      #   should be deleted.  So, each of 199 directorys will have
      #   at least one file deleted and 4 of the directories will have
      #   2 files deleted.
      #
      cmd_params['listitem'] = "index.html"
      doc_updater_ucm.deleteDocumentByName_ucm(**cmd_params)
      cmd_params['listitem'] = "10.US.221.html"
      doc_updater_ucm.deleteDocumentByName_ucm(**cmd_params)
      cmd_params['listitem'] = "36.US.1.html"
      doc_updater_ucm.deleteDocumentByName_ucm(**cmd_params)
      cmd_params['listitem'] = "126.US.1.html"
      doc_updater_ucm.deleteDocumentByName_ucm(**cmd_params)
      cmd_params['listitem'] = "199.US.89.193.html"
      doc_updater_ucm.deleteDocumentByName_ucm(**cmd_params)
      time.sleep(10)

      Refresh_The_Crawl(tname, xx, yy, collection_name)

      using += 1
      current_results = Run_The_Test_Case(tname, xx, yy,
                                          collection_name, hard_result[using])
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[using] = 1
      total_results += current_results

      etime = time.time()

      print "#################################################"
      print "#################################################"

      for item in loadlist:
         cmd_params['listname'] = item
         cmd_params['listitem'] = None
         doc_updater_ucm.deleteTree_ucm(**cmd_params)
         time.sleep(5)

      time.sleep(15)

      Refresh_The_Crawl(tname, xx, yy, collection_name)

      using += 1
      current_results = Run_The_Test_Case(tname, xx, yy,
                                          collection_name, hard_result[using])
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[using] = 1
      total_results += current_results

      print "#################################################"
      print "#################################################"
   
      print tname, ":  Actual   Total Results =", total_results
      print tname, ":  Expected Total Results = 7"
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
      #for item in loadlist:
      #   cmd_params['listname'] = item
      #   cmd_params['listitem'] = None
      #   doc_updater_ucm.deleteTree_ucm(**cmd_params)

      cmd_params['listname'] = "/testenv"
      cmd_params['listitem'] = None
      doc_updater_ucm.deleteTree_ucm(**cmd_params)

      cmd_params['listname'] = "/home"
      cmd_params['listitem'] = None
      doc_updater_ucm.deleteTree_ucm(**cmd_params)
      #lock.freeLock()
   
   if (Do_Exit_Routine(tname, total_results, 9) == 0):
      xx.delete_collection(collection=collection_name, force=1)
      sys.exit(0)
   
   sys.exit(1)
      
