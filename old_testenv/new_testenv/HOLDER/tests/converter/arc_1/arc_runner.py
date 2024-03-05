#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface
import os, getopt

def do_my_query(tname=None, collection=None, xx=None,
                yy=None, myquery="", hard_result=0):

   case_result = 0
   final_result = 2

   stime = etime = 0

   if ( myquery is None ):
      myquery = ""

   print tname, ":  Check the basic crawl data"
   if ( myquery == "" ):
      print tname, ":  Query is -- <Empty Query>"
   else:
      print tname, ":  Query is --", myquery

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query=myquery, filename="USout",
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

   if ( hard_result == -1 ):
      return urlcount

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


def should_this_run():

   if ( not os.access("/testenv/CHECKFILE", os.F_OK) ):
      print tname, ":  No access to the /testenv directory"
      print tname, ":  It is required for this test to run"
      print tname, ":  To make it work do, as root:"
      print tname, ":     mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
      print tname, ":  Test Failed"
      sys.exit(1)

   return

def check_crawled_file_is_gone(xx, crawled_file):

   if (not xx.file_exists(crawled_file) ):
      print "file", crawled_file, "was correctly deleted"
      return(1)

   print "file", crawled_file, "was NOT deleted"
   return(0)

def copy_file_to_viv_tmp(xx, viv_install_location, filename):

   if ( xx.TENV.targetos == "windows" ):
      target_location = ''.join([viv_install_location, "\\tmp\\junker"])
      crawled_file = ''.join([target_location, "\\", filename])
   else:
      target_location = ''.join([viv_install_location, "/tmp/junker"])
      crawled_file = ''.join([target_location, "/", filename])

   source_file_path = ''.join(["/testenv/test_data/arc_data_files/", filename])

   xx.put_file(source_file_path, target_location)

   return(crawled_file)


if __name__ == "__main__":

   collection_name = "arc_1"
   tname = 'arc_1'

   usedoc = False

   filename = None
   qlist = []
   casecount = []
   resultcount = -1

   opts, args = getopt.getopt(sys.argv[1:], "T:f:r:q:t:d", ["testname=", "filename=", "result=", "query=", "totalresult=", "documentum"])

   for o, a in opts:
     if o in ("-f", "--filename"):
        filename = a
     if o in ("-T", "--testname"):
        tname = a
     if o in ("-r", "--result"):
        casecount.append(int(a))
     if o in ("-t", "--totalresult"):
        resultcount = int(a)
     if o in ("-q", "--query"):
        qlist.append(a)
     if o in ("-d", "--documentum"):
        usedoc = True
        collection_name = "arcwithdoc_1"

   should_this_run()

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.1)

   vivlocation = xx.vivisimo_dir()
   crawled_file = copy_file_to_viv_tmp(xx, vivlocation, filename)

   urlpath = ''.join(["archive:///", crawled_file])

   #crlurlnd = ''.join(['<crawl-url url="', urlpath, '" change-id="99" arc-display-url="', filename, '" content-type="application/tar"/>'])
   crlurlnd = ''.join(['<crawl-url url="', urlpath, '" change-id="99" arc-display-url="', filename, '" />'])

   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Content base fast index"
   print tname, ":     Simple fast index creation"
   print tname, ":     Query of non-existent fi"
   

   print tname, ":  Create and check the base collection"

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name, force=1)

   yy.api_sc_create(collection=collection_name, based_on='default-push')
   yy.api_repository_update(xmlfile=colfile)

   print tname, ":  Starting the first crawl in live"

   base_res = 0
   thebeginning = time.time()

   if ( usedoc ):
      yy.api_sc_crawler_start(collection=collection_name, stype='new')
      xx.wait_for_idle(collection=collection_name)

      base_res = do_my_query(tname, collection_name, xx, yy, "", -1)

   print tname, ":  ##################"
   print tname, ":  The actual enqueue"
   print tname, ":  enqueue url (zip file url)"
   print tname, ":     xml =", crlurlnd
   yy.api_sc_enqueue(xx=xx, collection=collection_name,
                      url=crlurlnd)
   xx.wait_for_idle(collection=collection_name)

   cnt = 0
   passcnt = 0
   for item in qlist:
      if ( item == "" ):
         casecount[cnt] = casecount[cnt] + base_res
      passcnt += do_my_query(tname, collection_name, xx, yy,
                             item, casecount[cnt])
      cnt += 1

   passcnt += check_crawled_file_is_gone(xx, crawled_file)
   cnt += 1


   if ( passcnt == cnt ):
      print tname, ":  Test Passed"
      #xx.stop_crawl(collection=collection_name, force=1)
      #xx.stop_indexing(collection=collection_name, force=1)
      #xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
