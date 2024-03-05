#!/usr/bin/python

#
#   CNN CNN CNN CNN CNN CNN ... Hi Bruce ;b
#
#   This is a test of the parent-url attribute of crawl-url and
#   the recursive attribute of crawl-delete (both related).  Any
#   crawl-delete will, if recursive is specified, do a recursive
#   delete of anything that specifies the crawl-delete url as its
#   parent-url.
#
#   Example:
#      <crawl-url url="abc">
#         <crawl-data>smurf smurf smurf</crawl-data>
#      </crawl-url>

#      <crawl-url url="xyz" parent-url="abc">
#         <crawl-data>blah blah blah</crawl-data>
#      </crawl-url>
#
#      <crawl-delete url="abc" recursive="recursive"/>
#
#      This will cause both of the <crawl-url> items to be deleted
#      because abc is the parent of xyz.
#

#
#
import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node, random
import getopt, subprocess, host_environ
import velocityAPI
from threading import Thread
from lxml import etree

def parents_enqueue(collection, srvr, url):

   crawl_url = build_schema_node.create_crawl_url(url=url,
               status='complete', enqueuetype='reenqueued',
               synchronization='indexed-no-sync')
   crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                contenttype='text/html', addnodeto=crawl_url,
                text=url)

   #print etree.tostring(crawl_url)

   resp = srvr.vapi.api_sc_enqueue_xml(
                    collection=collection,
                    subc='live',
                    crawl_nodes=etree.tostring(crawl_url))

   return

#
#   Cheesy, but it works here.
#
def isfqdn(name=None):

   domain_tail = ['com', 'net', 'org', 'xxx']

   justthename = name.split(':')
   tail = justthename[0].split('.')

   z = len(tail)
   z = z - 1

   for item in domain_tail:
      if ( tail[z] == item ):
         return True

   return False

def fullsysname(name=None):

   if ( isfqdn(name) ):
      return name
   else:
      name = name + '.test.vivisimo.com'

   return name

###############################################################
#
#
#   Data enqueue thread class
#
#
class doTheEnqueue ( Thread ):

   def __init__(self, directory, srvr, collection, parenturl, truefollow):

      Thread.__init__(self)

      self.filecount = 0

      self.dir = directory
      self.parenturl = parenturl
      self.collection = collection
      self.srvr = srvr
      self.truefollow = truefollow

      return

   def get_filecount(self):

      return self.filecount

   def enqueue_it(self, srvr, collection, crawl_urls):

      global dumpofd

      dumpofd.write( etree.tostring(crawl_urls) )
      try:
         resp = srvr.vapi.api_sc_enqueue_xml(
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

   def do_crawl_urls(self, crawl_urls=None, filelist=None,
                     synchro=None, parenturl=None, truefollow=False):
     
      if ( synchro is None ):
         thissynchro = 'indexed-no-sync'
      else:
         thissynchro = synchro

      if ( filelist is None ):
         return []

      if ( crawl_urls is None ):
         crawl_urls = build_schema_node.create_crawl_urls()

      usethisparent = parenturl

      for item in filelist:

         #print item, thissynchro
         fname = os.path.basename(item)

         #print fname

         url = build_a_url(item)
  
         crawl_url = build_schema_node.create_crawl_url(url=url,
                     status='complete', enqueuetype='reenqueued',
                     synchronization=thissynchro, addnodeto=crawl_urls,
                     parenturl=usethisparent)
         crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                      contenttype='text/html', addnodeto=crawl_url,
                      filename=item)

         if ( truefollow ):
            usethisparent = url
         else:
            usethisparent = parenturl

      return crawl_urls

   def do_enqueues(self, dir, srvr, collection, parenturl, truefollow):

      filecount = 0
      synchro = None

      for path, dirs, files in os.walk(dir):

         filelist = []
         crawl_urls = None

         quitcounter = 0
         quitnum = len(files)

         lcnt = 37
         curcnt = 0

         for name in files:

            quitcounter += 1
            if ( quitcounter == quitnum ):
               curcnt = lcnt
            else:
               curcnt += 1

            fullpath = os.path.join(path, name)
            filelist.append(fullpath)
            filecount += 1

            if ( curcnt == lcnt ):
               #print "============================="
               crawl_urls = self.do_crawl_urls(crawl_urls, filelist,
                                               synchro, parenturl, truefollow)
               #print "============================="
               curcnt = 0
               lcnt -= 1
               resp = self.enqueue_it(srvr, collection, crawl_urls)
               #print etree.tostring(crawl_urls)
               filelist = []
               crawl_urls = None
               if ( lcnt == 0 ):
                  lcnt = 37
   
         print "FILES ENQUEUED (interim):  ", filecount


      print "FILES ENQUEUED (final):  ", filecount

      return filecount

   def run(self):

      self.filecount = self.do_enqueues(self.dir, self.srvr,
                                        self.collection, self.parenturl,
                                        self.truefollow)

      return
#
#   End enqueue thread class
#
###############################################################
def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1
      else:
         pseudo_match = az_constitution_check(checkfor, item)
         if ( pseudo_match == 1 ):
            return 1

   return 0


def usage():

   return


def build_a_url(fullname=None):

   url = ''.join(['file://', fullname])

   return url

def collection_reset(srvr, collection_name):

   collection_xml = collection_name + '.xml'

   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Create empty collection", collection_name
   #
   #   Empty collection to be filled using crawl-urls
   #
   cex = srvr.cgi.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      srvr.cgi.delete_collection(collection=collection_name)

   srvr.vapi.api_sc_create(collection=collection_name, based_on='default-push')
   srvr.vapi.api_repository_update(xmlfile=collection_xml)

   return

#
#   End of identical routines, sort of.
#
#####################################################################

if __name__ == "__main__":

   global dumpofd

   fail = 0
   datalist1 = ["/testenv/test_data/law/US/1",
                "/testenv/test_data/law/US/450",
                "/testenv/test_data/law/F2/450"]
   datalist2 = ["/testenv/test_data/law/US/164",
                "/testenv/test_data/law/US/13",
                "/testenv/test_data/law/F3/6",
                "/testenv/test_data/law/F3/351"]
   datalist3 = ["/testenv/test_data/law/US/528",
                "/testenv/test_data/law/US/99",
                "/testenv/test_data/law/US/316",
                "/testenv/test_data/law/F2/646"]
   datalist4 = ["/testenv/test_data/law/US/27",
                "/testenv/test_data/law/F2/992",
                "/testenv/test_data/law/US/75",
                "/testenv/test_data/law/US/202"]

   parenturls = ["http://www.parent.com/testenv/test_data/law/US/1",
                 "http://www.parent.com/this/is/bogus",
                 "http://www.parent.com/audi/R/8",
                 "http://www.parent.com/Newfies/are/nice/dogs",
                 "http://www.parent.com/once/again/this/is/work"]


   tname = 'cascade_delete'
   collection_name = tname

   dumpofd = open("what_i_did", "w+")
   dumpofd.write("<output>")

   hostname = os.getenv('VIVHOST', None)
   srvr = host_environ.HOSTENVIRON(hostname=hostname)

   srvr.cgi.version_check(minversion=8.0)

   ###############################################################

  
   print "#######################################################"
   print tname, ":  Case 1"
   print tname, ":     A few docs, no one has a parent."
   print tname, ":     Recursive should still allow the url in"
   print tname, ":     question to be deleted, even with no children."

   collection_reset(srvr, collection_name)

   for item in parenturls:
      parents_enqueue(collection_name, srvr, item)

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 5"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 5 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"

   crawl_delete = build_schema_node.create_crawl_delete(url=parenturls[2],
                                    synchronization='indexed-no-sync',
                                    recursive='recursive')

   #print etree.tostring(crawl_delete)

   resp = srvr.vapi.api_sc_enqueue_xml(
                    collection=collection_name,
                    subc='live',
                    crawl_nodes=etree.tostring(crawl_delete))

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 4"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 4 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"

   if ( fail == 0 ):
      print tname, ":  Case Passed"
   else:
      print tname, ":  Case Failed"
   print "#######################################################"

   ###############################################################

   print "#######################################################"
   print tname, ":  Case 2"
   print tname, ":     Many urls with one parent, everything as the"
   print tname, ":     same parent so recursive should empty the index."

   oldfail = fail
   collection_reset(srvr, collection_name)

   parents_enqueue(collection_name, srvr, parenturls[2])

   zooboo = []
   for item in datalist1:
      thing = doTheEnqueue(item, srvr, collection_name, parenturls[2], False)
      thing.start()
      zooboo.append(thing)

   for thing in zooboo:
      thing.join()

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 438"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 438 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"

   crawl_delete = build_schema_node.create_crawl_delete(url=parenturls[2],
                                    synchronization='indexed-no-sync',
                                    recursive='recursive')

   #print etree.tostring(crawl_delete)
   resp = srvr.vapi.api_sc_enqueue_xml(
                    collection=collection_name,
                    subc='live',
                    crawl_nodes=etree.tostring(crawl_delete))

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 0"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 0 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"

   if ( fail == oldfail ):
      print tname, ":  Case Passed"
   else:
      print tname, ":  Case Failed"
   print "#######################################################"

   ###############################################################

   print "#######################################################"
   print tname, ":  Case 3"
   print tname, ":     Many urls with one parent, but not all item."

   oldfail = fail
   collection_reset(srvr, collection_name)

   for item in parenturls:
      parents_enqueue(collection_name, srvr, item)

   zooboo = []
   for item in datalist1:
      thing = doTheEnqueue(item, srvr, collection_name, parenturls[2], False)
      thing.start()
      zooboo.append(thing)

   for item in datalist2:
      thing = doTheEnqueue(item, srvr, collection_name, parenturls[3], False)
      thing.start()
      zooboo.append(thing)

   for item in datalist3:
      thing = doTheEnqueue(item, srvr, collection_name, None, False)
      thing.start()
      zooboo.append(thing)

   for item in datalist4:
      thing = doTheEnqueue(item, srvr, collection_name, 'http://www.myjunk.com/haberdashery', False)
      thing.start()
      zooboo.append(thing)

   for thing in zooboo:
      thing.join()

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 2591"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 2591 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"

   crawl_delete = build_schema_node.create_crawl_delete(url=parenturls[2],
                                    synchronization='indexed-no-sync',
                                    recursive='recursive')

   #print etree.tostring(crawl_delete)
   resp = srvr.vapi.api_sc_enqueue_xml(
                    collection=collection_name,
                    subc='live',
                    crawl_nodes=etree.tostring(crawl_delete))

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 2153"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 2153 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"

   if ( fail == oldfail ):
      print tname, ":  Case Passed"
   else:
      print tname, ":  Case Failed"
   print "#######################################################"

   ###############################################################

   print "#######################################################"
   print tname, ":  Case 4"
   print tname, ":     Many urls with one parent, everything as the"
   print tname, ":     same parent so recursive should empty the index."
   print tname, ":     The actual parent is created AFTER the nodes"
   print tname, ":     using it as a parent."

   oldfail = fail
   collection_reset(srvr, collection_name)

   zooboo = []
   for item in datalist1:
      thing = doTheEnqueue(item, srvr, collection_name, parenturls[2], False)
      thing.start()
      zooboo.append(thing)

   for thing in zooboo:
      thing.join()

   parents_enqueue(collection_name, srvr, parenturls[2])

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 438"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 438 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"


   crawl_delete = build_schema_node.create_crawl_delete(url=parenturls[2],
                                    synchronization='indexed-no-sync',
                                    recursive='recursive')

   #print etree.tostring(crawl_delete)
   resp = srvr.vapi.api_sc_enqueue_xml(
                    collection=collection_name,
                    subc='live',
                    crawl_nodes=etree.tostring(crawl_delete))

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 0"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 0 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"

   if ( fail == oldfail ):
      print tname, ":  Case Passed"
   else:
      print tname, ":  Case Failed"
   print "#######################################################"

   ###############################################################

   print "#######################################################"
   print tname, ":  Case 5"
   print tname, ":     Many urls with following parent, everything starts"
   print tname, ":     with a common parent but a follow trail is set up"
   print tname, ":     with each item pointing to the previous item as a"
   print tname, ":     parent.  This should react as if all were pointed"
   print tname, ":     at the same parent."

   oldfail = fail
   collection_reset(srvr, collection_name)

   parents_enqueue(collection_name, srvr, parenturls[2])

   zooboo = []
   for item in datalist1:
      thing = doTheEnqueue(item, srvr, collection_name, parenturls[2], True)
      thing.start()
      zooboo.append(thing)

   for thing in zooboo:
      thing.join()

   srvr.cgi.wait_for_idle(collection=collection_name)
   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 438"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 438 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"


   crawl_delete = build_schema_node.create_crawl_delete(url=parenturls[2],
                                    synchronization='indexed-no-sync',
                                    recursive='recursive')

   #print etree.tostring(crawl_delete)
   resp = srvr.vapi.api_sc_enqueue_xml(
                    collection=collection_name,
                    subc='live',
                    crawl_nodes=etree.tostring(crawl_delete))

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 0"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 0 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"

   if ( fail == oldfail ):
      print tname, ":  Case Passed"
   else:
      print tname, ":  Case Failed"
   print "#######################################################"

   ###############################################################

   print "#######################################################"
   print tname, ":  Case 6"
   print tname, ":     Many urls with following parent, everything starts"
   print tname, ":     with a common parent but a follow trail is set up"
   print tname, ":     with each item pointing to the previous item as a"
   print tname, ":     parent.  This should react as if all were pointed"
   print tname, ":     at the same parent.  Not all the items have the"
   print tname, ":     same base parent."

   oldfail = fail
   collection_reset(srvr, collection_name)

   for item in parenturls:
      parents_enqueue(collection_name, srvr, item)

   zooboo = []
   for item in datalist1:
      thing = doTheEnqueue(item, srvr, collection_name, parenturls[2], True)
      thing.start()
      zooboo.append(thing)

   for item in datalist2:
      thing = doTheEnqueue(item, srvr, collection_name, parenturls[3], True)
      thing.start()
      zooboo.append(thing)

   for item in datalist3:
      thing = doTheEnqueue(item, srvr, collection_name, None, True)
      thing.start()
      zooboo.append(thing)

   for item in datalist4:
      thing = doTheEnqueue(item, srvr, collection_name, 'http://www.myjunk.com/haberdashery', True)
      thing.start()
      zooboo.append(thing)

   for thing in zooboo:
      thing.join()

   srvr.cgi.wait_for_idle(collection=collection_name)
   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 2591"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 2591 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"


   crawl_delete = build_schema_node.create_crawl_delete(url=parenturls[2],
                                    synchronization='indexed-no-sync',
                                    recursive='recursive')

   #print etree.tostring(crawl_delete)
   resp = srvr.vapi.api_sc_enqueue_xml(
                    collection=collection_name,
                    subc='live',
                    crawl_nodes=etree.tostring(crawl_delete))

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 2153"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 2153 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"

   if ( fail == oldfail ):
      print tname, ":  Case Passed"
   else:
      print tname, ":  Case Failed"
   print "#######################################################"

   ###############################################################

   print "#######################################################"
   print tname, ":  Case 7"
   print tname, ":     Many urls with following parent, everything starts"
   print tname, ":     with a common parent but a follow trail is set up"
   print tname, ":     with each item pointing to the previous item as a"
   print tname, ":     parent.  This should react as if all were pointed"
   print tname, ":     at the same parent.  The actual base parent is"
   print tname, ":     created AFTER the items using the parent."

   oldfail = fail
   collection_reset(srvr, collection_name)

   zooboo = []
   for item in datalist1:
      thing = doTheEnqueue(item, srvr, collection_name, parenturls[2], True)
      thing.start()
      zooboo.append(thing)

   for thing in zooboo:
      thing.join()

   parents_enqueue(collection_name, srvr, parenturls[2])

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 438"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 438 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"


   crawl_delete = build_schema_node.create_crawl_delete(url=parenturls[2],
                                    synchronization='indexed-no-sync',
                                    recursive='recursive')

   #print etree.tostring(crawl_delete)
   resp = srvr.vapi.api_sc_enqueue_xml(
                    collection=collection_name,
                    subc='live',
                    crawl_nodes=etree.tostring(crawl_delete))

   srvr.cgi.wait_for_idle(collection=collection_name)

   srvrresp = srvr.vapi.api_qsearch(source=collection_name, num=100000,
                                    query='', filename='srvr_search')

   srvridxcnt = srvr.vapi.getTotalResults(resptree=srvrresp,
                                          filename='srvr_search')
   print tname, ":  Document Count Check"
   print tname, ":     Expected - 0"
   print tname, ":     Actual -", srvridxcnt
   if ( srvridxcnt != 0 ):
      print tname, ":  Check Failed"
      fail += 1
   else:
      print tname, ":  Check Passed"

   if ( fail == oldfail ):
      print tname, ":  Case Passed"
   else:
      print tname, ":  Case Failed"
   print "#######################################################"

   ###############################################################

   dumpofd.write("</output>")
   dumpofd.close()

   if ( fail == 0 ):
      srvr.cgi.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
