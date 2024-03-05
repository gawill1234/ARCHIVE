#!/usr/bin/python

import os, re, string, sys, time, urllib
import cgi_interface, vapi_interface
import velocityAPI, build_schema_node
from toolenv import VIVTENV
from lxml import etree
from threading import Thread

############################################

class ThreadedQuery ( Thread ):

   def __init__(self, collection=None):

      Thread.__init__(self)

      self.collection = collection
      self.done = 0
      self.fail = 0

      return

   def setDone(self):

      self.done = 1

      return

   def run(self):

      xx = cgi_interface.CGIINTERFACE()
      yy = vapi_interface.VAPIINTERFACE()

      tname = "api-sc-read-only-p2"

      i = 0
      resp = yy.api_qsearch(xx=xx, source=self.collection,
                                    query='', num=10000)
      idxdcnt1 = yy.getTotalResults(resptree=resp)

      while ( i < 300 ):
         print tname, ":  Doing thread loop query"
         resp = yy.api_qsearch(xx=xx, source=self.collection,
                                    query='', num=10000)
         print tname, ":  Query complete"

         idxdcnt2 = yy.getTotalResults(resptree=resp)

         print tname, ":     results expected, ", idxdcnt1
         print tname, ":     results actual,   ", idxdcnt2


         if ( idxdcnt1 != idxdcnt2 ):
            self.fail += 1
            print tname, ":  query failed for read only"

         i += 1

         if ( self.done == 1 ):
            break
         else:
            time.sleep(.25)

      return

class ThreadedCreate ( Thread ):

   def __init__(self, cCount=10, cList=[], collection=None,
                baseName='one_of_many', xmlfile=None, usecb=0):

      Thread.__init__(self)

      self.collection = collection
      self.xmlfile = xmlfile
      self.cList = []
      self.usecb = usecb

      pid = os.getpid()

      if ( cList == [] ):
         if ( collection == None ):
            i = 0
            while ( i < cCount ):
               thecollection = ''.join([baseName, '_', pid, '_', i])
               self.cList.append(thecollection)
               i += 1
         else:
            self.cList.append(collection)
      else:
         self.cList = cList

      return


   def run(self):

      xx = cgi_interface.CGIINTERFACE()
      yy = vapi_interface.VAPIINTERFACE()

      successcount = 0

      for item in self.cList:
         cex = xx.collection_exists(collection=item)
         if ( cex != 1 ):
            createfailed = 0
            createupdate = 0
            try:
               if ( self.usecb == 0 ):
                  yy.api_sc_create(collection=item,
                                        based_on="default-push")
               else:
                  yy.api_sc_create(collection=item,
                                        based_on="default-broker-push")
            except:
               createfailed = 1

            if ( createfailed == 0 ):
               if ( self.xmlfile is not None ):
                  try:
                     yy.api_repository_update(xmlfile=self.xmlfile)
                  except:
                     createupdate = 1

            if ( createfailed == 0 and createupdate == 0 ):
               successcount += 1
            else:
               print "Collection not created:", item
               sys.exit(1)

         else:
            print "Collection already exists:", item

      return successcount

class ThreadedEnqueue ( Thread ):

   def __init__(self, collection=None, basedir='/testenv/test_data/law',
                eCount=2000, usesynchro='indexed-no-sync', usecb=0):

      Thread.__init__(self)

      self.basedir = basedir
      self.usesynchro = usesynchro
      self.eCount = eCount
      self.collection = collection
      self.usecb = usecb

      return

   def do_crawl_urls(self, crawl_urls=None, filelist=None, synchro=None):

      usesynchro = ['none', 'indexed', 'none', 'enqueued', 'indexed-no-sync',
                     'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                     'indexed-no-sync', 'enqueued']

      thingbomb = 0

      if ( filelist is None ):
         return []

      if ( crawl_urls is None ):
         crawl_urls = build_schema_node.create_crawl_urls()

      for item in filelist:

         if ( synchro == None ):
            whichone = thingbomb % 10
            thissynchro = usesynchro[whichone]
            thingbomb += 1
         else:
            thissynchro = synchro

         #print item, thissynchro
         fname = os.path.basename(item)
         #fdir = os.path.dirname(item)
         #mydirpart = fdir.strip('/testenv/test_data/law/')
         #print fname

         #url = ''.join(['http://junkurl/', mydirpart, '/', fname])
         url = ''.join(['file://', item])
         crawl_url = build_schema_node.create_crawl_url(url=url,
                     status='complete', enqueuetype='reenqueued',
                     synchronization=thissynchro, addnodeto=crawl_urls)
         crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                      contenttype='text/html', addnodeto=crawl_url,
                      filename=item)

      return crawl_urls


   def run(self):

      yy = vapi_interface.VAPIINTERFACE()

      filecount = 0

      for path, dirs, files in os.walk(self.basedir):

         filelist = []
         crawl_urls = None

         quitcounter = 0
         quitnum = len(files)
         if ( quitnum > self.eCount ):
            quitnum = self.eCount

         lcnt = 103
         if ( lcnt > self.eCount ):
            lcnt = self.eCount
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
               which = filecount % 10
               #print "=============================, ", self.usesynchro
               crawl_urls = self.do_crawl_urls(crawl_urls, filelist,
                                               self.usesynchro)
               #print "============================="
               curcnt = 0
               lcnt -= 1
               if ( self.usecb == 0 ):
                  resp = yy.api_sc_enqueue_xml(
                                   collection=self.collection,
                                   subc='live',
                                   crawl_nodes=etree.tostring(crawl_urls))
               else:
                  resp = yy.api_cb_enqueue_xml(
                                   collection=self.collection,
                                   crawl_nodes=etree.tostring(crawl_urls))
               #print etree.tostring(crawl_urls)
               filelist = []
               crawl_urls = None
               if ( lcnt == 0 ):
                  lcnt = 103

               if ( filecount >= self.eCount ):
                  break

         print "FILES ENQUEUED (interim):  ", filecount

         if ( filecount >= self.eCount ):
            break




      print "FILES ENQUEUED (final):  ", filecount

      return filecount
