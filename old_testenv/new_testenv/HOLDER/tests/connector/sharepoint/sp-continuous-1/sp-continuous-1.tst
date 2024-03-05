#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import simpleLock
from threading import Thread
import doc_updater, getopt, time

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
         doc_updater.createTree(**self.cmd_params)
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

   liststoplace = ['law/US/2', 'law/US/3', 
                   'law/US/4', 'law/US/541', 'law/F2/199']
   if ( collection == 'sp-continuous-1-oldconn' ):
      expectedcnt = [54, 24, 49, 2354, 636]
   else:
      expectedcnt = [55, 25, 50, 2355, 637]
   fn = ['f55-1', 'f25-2', 'f50-3', 'f2355-4', 'f637-5']

   case_result = 0
   hard_result = glob_results[0]
   final_result = 7

   stime = etime = 0

   print tname, ":  Update (delete and re-add) several documents and refresh crawl"

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

   myq = "NOT (law/US OR law/F2 OR law/F3)"
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

   global cmd_params

   cmd_params = {}
   result_cnt = 0
   expected_cnt = 0
   glob_results = []

   sitetype = '2010'
   tname = 'sp-continuous-1'
   funcfile = 'oldspfunction.xml'

   opts, args = getopt.getopt(sys.argv[1:], "v:", ["version="])

   for o, a in opts:
     if o in ("-v", "--version"):
        sitetype = a

   if ( sitetype == '2010' ):
      cmd_params['site'] = site = 'http://testbed18-1.test.vivisimo.com:47401'
      cmd_params['user'] = user = 'administrator'
      cmd_params['pw'] = pw = 'Mustang5'
      cmd_params['domain'] = domain = 'sptest'
      collection_name = "sp-continuous-1-2010"
      glob_results = [3142, 18]
      lock = simpleLock.simpleLock("tb18-1.47401")
   elif ( sitetype == '2007' ):
      cmd_params['site'] = site = 'http://testbed19-2:36436'
      cmd_params['user'] = user = 'administrator'
      cmd_params['pw'] = pw = 'VolvoV70'
      cmd_params['domain'] = domain = 'sp07test'
      collection_name = "sp-continuous-1-2007"
      glob_results = [3132, 8]
      lock = simpleLock.simpleLock("tb19-2.36436")
   else:
      cmd_params['site'] = site = 'http://testbed19-2:36436'
      cmd_params['user'] = user = 'administrator'
      cmd_params['pw'] = pw = 'VolvoV70'
      cmd_params['domain'] = domain = 'sp07test'
      collection_name = "sp-continuous-1-oldconn"
      glob_results = [3123, 6]
      lock = simpleLock.simpleLock("tb19-2.36436")

   initlist = ['/testenv/test_data/law/F2/199']
   runlist = ['/testenv/test_data/law/US/3', '/testenv/test_data/law/US/4',
             '/testenv/test_data/law/US/2', '/testenv/test_data/law/US/541']
   updatelist = ['/testenv/test_data/law/US/5', '/testenv/test_data/law/US/6']

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   lock.setLock()

   try:
   
      if ( collection_name == 'sp-continuous-1-oldconn' ):
         yy.api_repository_update(xmlfile=funcfile)
   
      doc_updater.flush_all_data(tname, xx, yy, 0, **cmd_params)
   
      print tname, ":  Initialize the crawled site"
   
      doit = doSPUpdate(site, user, pw, domain, initlist)
   
      doit.start()
      print tname, ":  Initialize sharepoint with data."
   
      print "Waiting ..."
      doit.join()
      print "Initialization complete"
   
      print tname, ":  Do a crawl and update simultaneously"
      print tname, ":  Begin update thread"
   
      doit = doSPUpdate(site, user, pw, domain, runlist)
      print tname, ":  Start the initial crawl while data is being added to target site."
      Start_The_Crawl(tname, xx, yy, collection_name, False)
   
      doit.start()
      print "crawl/update is running"
   
      xx.wait_for_idle(collection=collection_name)
      while ( doit.isAlive() ):
         print tname, ":  Restart update thread (by command, not continuous update)"
         Refresh_The_Crawl(tname, xx, yy, collection_name, True)
      
      print "Waiting ..."
      doit.join()
      print tname, ":  Final update of collection"
      Refresh_The_Crawl(tname, xx, yy, collection_name, True)
   
      current_result = 0
      expected_cnt += 1
      current_result += Do_Case_1(tname, xx, yy, collection_name, glob_results)
      if ( current_result == 1 ):
         print tname, ":  Case 1, Case Passed"
         result_cnt += current_result
      else:
         print tname, ":  Case 1, Case Failed"
   
      print tname, ":  Delete the crawl data and re-crawl.  Should get identical results."
      print tname, ":  Delete the crawl data."
      yy.api_sc_crawler_stop(collection=collection_name, killit='true', subc='live')
      yy.api_sc_indexer_stop(collection=collection_name, killit='true', subc='live')
      yy.api_sc_clean(xx=xx, collection=collection_name, subc='live')
   
      print tname, ":  Start the re-crawl."
      yy.api_sc_crawler_start(collection=collection_name, subc='live', stype='new')
      xx.wait_for_idle(collection=collection_name)
      #Start_The_Crawl(tname, xx, yy, collection_name, True)
   
      current_result = 0
      expected_cnt += 1
      current_result += Do_Case_1(tname, xx, yy, collection_name, glob_results)
      if ( current_result == 1 ):
         print tname, ":  Case 2, Case Passed"
         result_cnt += current_result
      else:
         print tname, ":  Case 2, Case Failed"
   
   finally:
      doc_updater.flush_all_data(tname, xx, yy, 0, **cmd_params)
      lock.freeLock()
   
   print "Done"

   if ( result_cnt == expected_cnt ):
      xx.delete_collection(collection=collection_name, force=1)
      print tname, ":  Test Passed"
      sys.exit(0)
   
   print tname, ":  Test Failed"
   sys.exit(1)
