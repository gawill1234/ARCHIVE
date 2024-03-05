#!/usr/bin/python

#
#   Test of autocomplete suggestion API and dictionaries.
#

import sys, time, cgi_interface, vapi_interface
import velocityAPI, build_schema_node
import urlparse
import os, subprocess
from lxml import etree

def get_rid_of_dictionary(tname, yy, xx, dictionary_name):

   try:
      yy.api_dictionary_delete(dictionary_name=dictionary_name)
      yy.api_repository_get(elemtype="dictionary",
                            elemname=dictionary_name)
   except velocityAPI.VelocityAPIexception:
      print tname, ":  Dictionary gone, whoohoo!!"
      return

   print tname, ":  Dictionary delete failed"
   print tname, ":  Test Failed"
   sys.exit(1)

def dict_create_with_collection(tname, yy, xx, dictionary_name, dictionary_file, docreate):

   if ( docreate ):
      print tname, ":  Create dictionary", dictionary_name
      yy.api_dictionary_create(dictionary_name=dictionary_name)

      print tname, ":  Update dictionary", dictionary_name
      print tname, ":     It should build using test collection"
      yy.api_repository_update(xmlfile=dictionary_file)

   print tname, ":  Build dictionary", dictionary_name
   yy.api_dictionary_build(dictionary_name=dictionary_name)

   dstat = yy.api_dictionary_status(xx=xx, dictionary_name=dictionary_name)
   while ( dstat != "aborted" ) and ( dstat != "finished" ):
      print tname, ":  Current build status,", dstat
      time.sleep(5)
      print tname, ":  Recheck the dictionary status"
      dstat = yy.api_dictionary_status(xx=xx, dictionary_name=dictionary_name)

   if ( dstat == "aborted" ):
      print tname, ":  Dictionary build failed", dictionary_name
      print tname, ":  Test Failed"
      sys.exit(99)
   else:
      print tname, ":  Dictionary build complete"
      print tname, ":  Sleep of a couple of seconds let fs data flush"
      time.sleep(2)

   return


def do_dict_file(infile, outfile, target_file, xx):

   if ( xx.TENV.targetos == "windows" ):
      flist = target_file.split('\\')

   cmdstring = "cat " + infile + " | sed -e \'s;REPLACE__WITH__TARGET;"

   if ( xx.TENV.targetos == "windows" ):
      fllen = len(flist)
      cnt = 0
      for item in flist:
         cmdstring = cmdstring + item
         cnt += 1
         if ( cnt < fllen ):
            cmdstring = cmdstring + '\\\\'
   else:
      cmdstring = cmdstring + target_file

   cmdstring = cmdstring + ";g\' > " + outfile

   #print cmdstring

   p = subprocess.Popen(cmdstring, shell=True)
   os.waitpid(p.pid, 0)

   return

def build_a_url(fullname=None):

   url = ''.join(['file://', fullname])

   return url

def do_crawl_urls(filename=None, synchro=None):

   crawl_urls = build_schema_node.create_crawl_urls()

   url = build_a_url(filename)

   crawl_url = build_schema_node.create_crawl_url(url=url,
               status='complete', enqueuetype='reenqueued',
               synchronization=synchro, addnodeto=crawl_urls)
   crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                contenttype='text/html', addnodeto=crawl_url,
                filename=filename)

   return crawl_urls

def enqueue_it(srvr, collection, crawl_urls):

   try:
      resp = srvr.api_sc_enqueue_xml(
                       collection=collection,
                       subc='live',
                       crawl_nodes=etree.tostring(crawl_urls))
      return resp
   except velocityAPI.VelocityAPIexception:
      ex_xml, ex_text = sys.exc_info()[1]
      success = ex_xml.get('name') == 'search-collection-enqueue-invalid'
      if not success:
         print "BARF, unexpected failure"
         print '%s:  %s' % (collection, ex_text)
         print "Enqueue failed"

   return None

def do_enqueues(dir, srvr, collection):


   mysynchro = 'enqueued'

   filecount = 0

   for path, dirs, files in os.walk(dir):

      for name in files:

         crawl_urls = None

         fullpath = os.path.join(path, name)
         filecount += 1

         print name
         crawl_urls = do_crawl_urls(fullpath, mysynchro)
         resp = enqueue_it(srvr, collection, crawl_urls)
         #print etree.tostring(crawl_urls)

   print tname, ":  Enqueues complete, files added =", filecount
   return filecount


if __name__ == "__main__":

   tname = 'wc-rebuild-1'

   collection_name = "wc-rebuild-collection"
   dictionary_name = "wc-rebuild-dictionary"

   dictionary_file = "dictionary.xml"

   dres = ['dudington']

   dir = '/testenv/test_data/law/US/26'

   fail = 0

   ##############################################################
   #
   #  Test and dictionary setup stuff
   #
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Dictionary rebuild after document deletion"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(8.0)

   thebeginning = time.time()

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name)

   get_rid_of_dictionary(tname, yy, xx, dictionary_name)

   yy.api_sc_create(collection=collection_name, based_on='default-push')

   urlexp = do_enqueues(dir, yy, collection_name)

   xx.wait_for_idle(collection=collection_name)

   ####################################################################
   #
   #  Build the next dictionary and run the test.
   #

   print tname, ":  Building the dictionary based on the test collection"

   dict_create_with_collection(tname, yy, xx, dictionary_name, dictionary_file, True)

   print tname, ":  #######################################"
   print tname, ":  CASE 1"

   resp = yy.api_qsearch(source=collection_name, query="",
                            filename="munchy")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0
   filename = yy.look_for_file(filename='munchy')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print tname, ":  Primary list from Case 1", urlcount
   print urllist

   if ( urlcount != urlexp ):
      print tname, ":  Enqueued data incorrect"
      print tname, ":  Test Failed"
      sys.exit(1)

   zz = yy.api_autocomplete_suggest(dictionary_name=dictionary_name,
                                    basestr="DUDINGTO", num=30, bow=False)

   print tname, ":  --------------------------------------"
   print tname, ":  Returned phrase list"
   try:
      if ( zz is not None and zz != [] ):
         print zz
      else:
         print tname, ":  ERROR, the returned list is empty"
   except:
      print tname, ":  ERROR, the returned list is empty"
   print tname, ":  --------------------------------------"

   ret = yy.check_list(zz, dres)
   if ( ret == 0 ):
      print tname, ":  collection based dictionary"
      print tname, ":  'DUDINGTON' query case passed"
   else:
      print tname, ":  word not found in result list"
      fail += 1

   print tname, ":  #######################################"


   delpath1 = os.path.join(dir, 'index.html')
   url1 = build_a_url(delpath1)
   print tname, ":  Deleting", url1
   del_url = build_schema_node.create_crawl_delete(url=url1)
   yy.api_sc_enqueue_deletes(collection=collection_name, url=etree.tostring(del_url))

   delpath1 = os.path.join(dir, '26.US.18.html')
   url1 = build_a_url(delpath1)
   print tname, ":  Deleting", url1
   del_url = build_schema_node.create_crawl_delete(url=url1)
   yy.api_sc_enqueue_deletes(collection=collection_name, url=etree.tostring(del_url))

   xx.wait_for_idle(collection=collection_name)

   print tname, ":  Rebuilding the dictionary after the deletes"

   dict_create_with_collection(tname, yy, xx, dictionary_name, dictionary_file, False)

   print tname, ":  #######################################"
   print tname, ":  CASE 2"

   dres = []

   resp = yy.api_qsearch(source=collection_name, query="",
                            filename="crunchy")
   try:
      urlcount2 = yy.getTotalResults(resptree=resp)
   except:
      urlcount2 = 0
   filename = yy.look_for_file(filename='crunchy')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print tname, ":  Primary list from Case 2", urlcount2
   print urllist

   if ( urlcount2 != ( urlcount - 2 ) ):
      print tname, ":  Delete failed"
      print tname, ":  Test Failed"
      sys.exit(1)

   zz = yy.api_autocomplete_suggest(dictionary_name=dictionary_name,
                                    basestr="DUDINGTO", num=30, bow=False)
   print tname, ":  --------------------------------------"
   print tname, ":  Returned phrase list"
   try:
      if ( zz is not None and zz != [] ):
         print tname, ":  ERROR, the returned list is NOT empty"
      else:
         print tname, ":  GOOD, the returned list is empty"
   except:
      print tname, ":  GOOD, the returned list is empty"
   print tname, ":  --------------------------------------"

   ret = yy.check_list(zz, dres)
   if ( ret == 0 ):
      print tname, ":  collection based dictionary"
      print tname, ":  'DUDINGTON' query case passed"
   else:
      print tname, ":  word not found in result list"
      fail += 1

   print tname, ":  #######################################"

   ####################################################################

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      xx.delete_collection(collection=collection_name)
      print tname, ": deleting dictionary", dictionary_name
      yy.api_dictionary_delete(dictionary_name=dictionary_name)
      sys.exit(fail)

   xx.stop_crawl(collection=collection_name, force=1)
   xx.stop_indexing(collection=collection_name, force=1)

   print tname, ":  Test Failed"
   sys.exit(fail)
