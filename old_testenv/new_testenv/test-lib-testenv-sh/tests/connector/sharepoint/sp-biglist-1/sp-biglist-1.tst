#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import simpleLock
from threading import Thread
import doc_updater, getopt, time

class doSPUpdate ( Thread ):

   cmd_params = {}
   fullCount = 0

   def __init__(self, site, user, pw, domain, updateList, numItems):

      Thread.__init__(self)

      self.cmd_params['site'] = site
      self.cmd_params['user'] = user
      self.cmd_params['pw'] = pw
      self.cmd_params['domain'] = domain

      self.cmd_params['listname'] = updateList
      self.fullCount = numItems

      self.xx = cgi_interface.CGIINTERFACE()
      self.yy = vapi_interface.VAPIINTERFACE()

      return


   def run(self):


      stime = time.time()
      doc_updater.createList(**self.cmd_params)

      self.cmd_params['listname'] = '/' + self.cmd_params['listname']
      self.cmd_params['listitem'] = 'NCC-1701'
      self.cmd_params['quantity'] = '%s' % self.fullCount
      doc_updater.createListItemBunch(**self.cmd_params)
      etime = time.time()

      print "LIST CREATION TIME: ", etime - stime

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
def Do_Case_1(tname=None, xx=None, yy=None, collection=None, hard_result=100):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Query list data, query = NCC-1701"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="NCC-1701", filename="MTout",
                         num=200000, odup="true")
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
   current_run = 0

   sitetype = '2010'
   tname = 'sp-biglist-1'
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
      collection_name = "sp-biglist-1-2010"
      lock = simpleLock.simpleLock("tb18-1.47401")
   elif ( sitetype == '2007' ):
      cmd_params['site'] = site = 'http://testbed19-2:36436/'
      cmd_params['user'] = user = 'administrator'
      cmd_params['pw'] = pw = 'VolvoV70'
      cmd_params['domain'] = domain = 'sp07test'
      collection_name = "sp-biglist-1-2007"
      lock = simpleLock.simpleLock("tb19-2.36436")
   else:
      cmd_params['site'] = site = 'http://testbed19-2:36436/'
      cmd_params['user'] = user = 'administrator'
      cmd_params['pw'] = pw = 'VolvoV70'
      cmd_params['domain'] = domain = 'sp07test'
      collection_name = "sp-biglist-1-oldconn"
      lock = simpleLock.simpleLock("tb19-2.36436")

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   lock.setLock()

   try:
   
      if ( collection_name == 'sp-biglist-1-oldconn' ):
         yy.api_repository_update(xmlfile=funcfile)
   
      #
      #   50000 is max supported by sharepoint 2010.
      #   2000 is max supported by sharepoint 2007(claimed).
      #        as an aside, I've seen 2007 handle 8000.
      #
      if ( collection_name == 'sp-biglist-1-2010' ):
         qlist = [10, 100, 1000, 2000, 10000, 50000]
      else:
         #
         #   should allaw up to 2000.  But an apparent web service bug
         #   will not allow it to happen.  Set to max at 1999.
         #
         #qlist = [10, 100, 1000, 1999, 2000]
         #
         qlist = [10, 100, 1000, 1999]
   
      for item in qlist:
   
         expected_cnt += 1
   
         doc_updater.flush_all_data(tname, xx, yy, 0, **cmd_params)
   
         print tname, ":  Initialize the crawled site"
   
         doit = doSPUpdate(site, user, pw, domain, 'CountedList', item)
   
         doit.start()
         print tname, ":  Initialize sharepoint with data."
   
         print "Waiting ..."
         doit.join()
         print "Initialization complete"
   
         Start_The_Crawl(tname, xx, yy, collection_name, True)
   
         current_run = 0
         current_run = Do_Case_1(tname, xx, yy, collection_name, item)
         if (current_run == 1):
            print tname, ":  Case Passed for", item, current_run
            result_cnt += 1
         else:
            print tname, ":  Case Failed for", item, current_run
            print tname, ":     If it can not handle", item, "elements, no point in going on."
            print tname, ":  Test Failed"
            doc_updater.flush_all_data(tname, xx, yy, 0, **cmd_params)
            lock.freeLock()
            sys.exit(1)
   
   finally:
      doc_updater.flush_all_data(tname, xx, yy, 0, **cmd_params)
      lock.freeLock()
   
   if ( result_cnt == expected_cnt ):
      xx.delete_collection(collection=collection_name, force=1)
      print tname, ":  Test Passed"
      sys.exit(0)
   
   print tname, ":  Test Failed"
   sys.exit(1)
