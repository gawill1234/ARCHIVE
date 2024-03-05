#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import simpleLock
from threading import Thread
import run_bulk_loader, getopt, time, shutil

class doSPUpdate ( Thread ):

   mylist = None
   runUpdateLoads = None

   def __init__(self, updateList, **myparams):

      Thread.__init__(self)

      self.runUpdateLoads = run_bulk_loader.RUN_BULK_LOADER(**myparams)

      self.mylist = updateList

      self.xx = cgi_interface.CGIINTERFACE()
      self.yy = vapi_interface.VAPIINTERFACE()

      return


   def run(self):


      for item in self.mylist:
         print "Working with directory", item
         stime = time.time()
         self.runUpdateLoads.add_cmd_parameter('mountpoint', item)
         self.runUpdateLoads.add_cmd_parameter('create', 'tree')
         self.runUpdateLoads.run_doc_update()
         etime = time.time()
         print "Load time (seconds) =", etime - stime

      return

#
#
##############################################################
#
#
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
def Start_The_Crawl(tname=None, xx=None, yy=None, collection=None, cwait=True):

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
   if ( cwait ):
      stime = time.time()
      xx.wait_for_idle(collection=collection)
      etime = time.time()

   print tname, ":  Approximate crawl time (seconds) =", etime - stime

   return

def Refresh_The_Crawl(tname=None, xx=None, yy=None, collection=None, cwait=True):

   stime = etime = 0

   if ( collection is None ):
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

def Resume_The_Crawl(tname=None, xx=None, yy=None, collection=None, cwait=True):

   stime = etime = 0

   if ( collection is None ):
      print tname, ":  Test Failed, no collection"
      raise Exception("Collection Error")
      sys.exit(1)

   cex = xx.collection_exists(collection=collection)
   if ( cex == 1 ):
      print tname, ":  Resuming the crawl in live"
      yy.api_sc_crawler_start(collection=collection, stype='resume')
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
def Do_Case_1_01(tname=None, xx=None, yy=None, collection=None,
                 queryword=None, hard_result=0, filename=None):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the List -", queryword

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query=queryword,
                         filename=filename,
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
      urllist = yy.getResultUrls(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 1_01:  Totaled Results : ", urlcount
   print "CASE 1_01:  Counted Results : ", urlcount2
   print "CASE 1_01:  Expected Results: ", hard_result

   #for item in urllist:
   #   print item

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 1_01A:  Case Passed"
   else:
      print "CASE 1_01A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 1_01B:  Case Passed"
   else:
      print "CASE 1_01B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      resp = yy.api_qsearch(source=collection, query=queryword,
                            filename="Case_1_out",
                            num=100000, odup="true")
      urlcount_err = yy.getTotalResults(resptree=resp)
      urlcount2_err = yy.getResultUrlCount(resptree=resp)
      urllist_err = yy.getResultUrls(resptree=resp)

      print "CASE 1_01_try2:  Totaled Results : ", urlcount_err
      print "CASE 1_01_try2:  Counted Results : ", urlcount2_err
      print "CASE 1_01_try2:  Expected Results: ", hard_result

      #for item in urllist:
      #   print item

      if (urlcount_err == hard_result):
         case_result += 1
         print "CASE 1_01A_try2:  Case Passed"
      else:
         print "CASE 1_01A_try2:  Case Failed"

      if (urlcount_err == urlcount2_err):
         case_result += 1
         print "CASE 1_01B_try2:  Case Passed"
      else:
         print "CASE 1_01B_try2:  Case Failed"

      zz = 0
      for item in urllist_err:
         if ( isInList(item, urllist) == 0 ):
            zz += 1
            print "MISSING:", item
      print "Missing count =", zz
      return 0


def Do_Case_1(tname=None, xx=None, yy=None, collection=None, glob_results=[]):

   #liststoplace = ['law/US/2', 'law/US/3', 
   #                'law/US/4', 'law/US/541', 'law/F2/199']
   liststoplace = ['2.US', '3.US', 
                   '4.US', '1.US', '178.F3d']
   expectedcnt = [53, 23, 48, 49, 395]
   fn = ['f53-1', 'f23-2', 'f48-3', 'f49-4', 'f395-5']

   case_result = 0
   hard_result = glob_results[0]
   final_result = 7

   stime = etime = 0

   print tname, ":  Query for documents from specific folders"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
                         num=100000, odup="true")
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

   mcnt = len(liststoplace)
   i = 0
   while ( i < mcnt ):
      case_result += Do_Case_1_01(tname, xx, yy, collection,
                                  liststoplace[i], expectedcnt[i], fn[i])
      i += 1

   #myq = "NOT (law/US OR law/F2 OR law/F3)"
   myq = "NOT (US OR Fd2 OR F3d)"
   case_result += Do_Case_1_01(tname, xx, yy, collection, myq, glob_results[1], 'not_q')

   print tname, ":  1 CRES =", case_result

   if ( case_result == final_result ):
      return 1
   else:
      return 0
#
#
##############################################################
#
#
if __name__ == "__main__":

   result_cnt = 0
   expected_cnt = 0
   glob_results = []

   sitetype = 'WCC'
   tname = 'wcc-continuous-2'

   opts, args = getopt.getopt(sys.argv[1:], "v:", ["version="])

   for o, a in opts:
     if o in ("-v", "--version"):
        sitetype = a

   runLoads = run_bulk_loader.RUN_BULK_LOADER()
   runLoads.add_cmd_parameter('connector', 'UCM')

   if ( sitetype == 'WCC' ):
      runLoads.add_cmd_parameter('site', 'wcc-qa.bigdatalab.ibm.com')
      runLoads.add_cmd_parameter('user', 'gaw')
      runLoads.add_cmd_parameter('pw', 'mustang5')
      runLoads.add_cmd_parameter('port', '4444')
      collection_name = "wcc-continuous-2"
      glob_results = [1406, 460]
      lock = simpleLock.simpleLock("wcc-qa.WCC")
   else:
      #runLoads.add_cmd_parameter('site', 'testbed6-6.bigdatalab.ibm.com')
      runLoads.add_cmd_parameter('site', 'ucm.bigdatalab.ibm.com')
      runLoads.add_cmd_parameter('user', 'sysadmin')
      runLoads.add_cmd_parameter('pw', 'idc')
      #runLoads.add_cmd_parameter('port', '4444')
      runLoads.add_cmd_parameter('port', '5444')
      collection_name = "ucm-continuous-2"
      glob_results = [1406, 460]
      lock = simpleLock.simpleLock("tb6-6.UCM")

   origname = collection_name + '.orig' + '.xml'
   contname = collection_name + '.cont' + '.xml'
   workname = collection_name + '.xml'

   initlist = ['/testenv/test_data/law/F2/199']
   runlist = ['/testenv/test_data/law/US/3', '/testenv/test_data/law/US/4',
             '/testenv/test_data/law/US/2', '/testenv/test_data/law/US/1',
             '/testenv/test_data/law/F3/178', '/testenv/test_data/law/F3/220']
   updatelist = ['/testenv/test_data/law/US/5', '/testenv/test_data/law/US/6']

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   lock.setLock()

   ##############################################################################
   ##############################################################################

   try:
   
      runLoads.add_cmd_parameter('delete', 'tree')
      runLoads.add_cmd_parameter('mountpoint', '/testenv')
      runLoads.run_doc_update()
      runLoads.add_cmd_parameter('mountpoint', '/home')
      runLoads.run_doc_update()
   
      print tname, ":  Initialize the crawled site"
      shutil.copy(origname, workname)
      Start_The_Crawl(tname, xx, yy, collection_name, True)
      shutil.copy(contname, workname)
   
      yy.api_sc_indexer_stop(collection=collection_name, killit='true', subc='live')
      yy.api_repository_update(xx, xmlfile=workname)
      yy.api_sc_update_config(collection=collection_name)
   
      runLoads.reset_non_connection_params()
      doit = doSPUpdate(initlist, **(runLoads.get_cmd_params_list()))
   
      doit.start()
      print tname, ":  Initialize wcc with data."
   
      print "Waiting ..."
      doit.join()
      print "Initialization complete"
   
      print tname, ":  Do a crawl and update simultaneously"
      print tname, ":  Begin update thread"
   
      runLoads.reset_non_connection_params()
      doit = doSPUpdate(runlist, **(runLoads.get_cmd_params_list()))

      print tname, ":  Resume the crawl while data is being added to target site."
      Resume_The_Crawl(tname, xx, yy, collection_name, False)
   
      doit.start()
      print "crawl/update is running"
      print "LOOK NOW -------------------------------------"
      print "LOOK NOW -------------------------------------"
      print "LOOK NOW -------------------------------------"
   
      #
      #   The section to change for true continuous update.
      #   No restarts, just look for idle?
      #
      while ( doit.isAlive() ):
         time.sleep(120)
         xx.wait_for_idle(collection=collection_name)
      
      print "Waiting ..."
      doit.join()
      print tname, ":  Final update wait of collection"
   
      time.sleep(900)
      xx.wait_for_idle(collection=collection_name)
   
      current_result = 0
      expected_cnt += 1
      current_result += Do_Case_1(tname, xx, yy, collection_name, glob_results)
      if ( current_result == 1 ):
         print tname, ":  Case 1, Case Passed"
         result_cnt += current_result
      else:
         print tname, ":  Case 1, Case Failed"

      #sys.exit(1)
   
      #######################################################################
   
      print tname, ":  Delete the crawl data and re-crawl.  Should get identical results."
      print tname, ":  Delete the crawl data.  Stop crawler and indexer.  Perform delete."
      yy.api_sc_crawler_stop(collection=collection_name, killit='true', subc='live')
      yy.api_sc_indexer_stop(collection=collection_name, killit='true', subc='live')
      yy.api_sc_clean(xx=xx, collection=collection_name, subc='live')
   
      #shutil.copy(origname, workname)
      #yy.api_repository_update(xx, xmlfile=workname)
      #yy.api_sc_update_config(collection=collection_name)
   
      print tname, ":  Start the re-crawl."
      yy.api_sc_crawler_start(collection=collection_name, subc='live', stype='new')
      xx.wait_for_idle(collection=collection_name)
   
      current_result = 0
      expected_cnt += 1
      current_result += Do_Case_1(tname, xx, yy, collection_name, glob_results)
      if ( current_result == 1 ):
         print tname, ":  Case 2, Case Passed"
         result_cnt += current_result
      else:
         print tname, ":  Case 2, Case Failed"
   
      ######################################################################
      ######################################################################
   finally:
      lock.freeLock()
   
   print "Done"
   if ( result_cnt == expected_cnt ):
      xx.delete_collection(collection=collection_name, force=1)
      runLoads.add_cmd_parameter('delete', 'tree')
      runLoads.add_cmd_parameter('mountpoint', '/testenv')
      runLoads.run_doc_update()
      runLoads.add_cmd_parameter('mountpoint', '/home')
      runLoads.run_doc_update()
      print tname, ":  Test Passed"
      sys.exit(0)
   
   print tname, ":  Test Failed"
   sys.exit(1)
