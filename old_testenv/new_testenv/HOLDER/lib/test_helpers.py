#!/usr/bin/python

import sys, os, time, simpleLock
import vapi_interface, velocityAPI, cgi_interface

#
#   A collection of things I've done in so many tests
#   I'm sick of doing them in all of those tests.
#

class TEST_HELPERS:

   __vapi = None
   __cgi = None
   __collection = None
   __test_name = None

   def __init__(self, vapi_iface=None, cgi_iface=None,
                collection=None, tname=None):

      self.set_vapi(vapi_iface)
      self.set_cgi(cgi_iface)
      self.set_test_name(tname)
      self.set_collection(collection)

      return

   #
   #   Get a connection to the vapi_interface stuff.
   #
   def set_vapi(self, vapi_iface=None):

      if ( vapi_iface is None ):
         self.__vapi = vapi_interface.VAPIINTERFACE()
      else:
         self.__vapi = vapi_iface

      return

   #
   #   Get a connection to the cgi_interface stuff.
   #
   def set_cgi(self, cgi_iface=None):

      if ( cgi_iface is None ):
         self.__cgi = cgi_interface.CGIINTERFACE()
      else:
         self.__cgi = cgi_iface

      return

   #
   #  Set the collection name or set it to "None"
   #
   def set_collection(self, collection=None):

      if ( collection is None ):
         print self.__test_name, ":  test_helpers.set_collection()"
         print "WARNING:  Setting collection name to None"

      self.__collection = collection

      return

   #
   #   Set the test name
   #
   def set_test_name(self, test_name=None):
   
      if ( test_name is None ):
         print self.__test_name, ":  test_helpers.set_test_name()"
         print "WARNING:  Setting test name to -No test name given-"
         self.__test_name = "-No test name given-"
      else:
         self.__test_name = test_name

      return

   #
   #   Query routines.  Get vapi, cgi, collection or test name.
   #
   def get_vapi(self):

      return self.__vapi

   def get_cgi(self):

      return self.__cgi

   def get_collection(self):

      return self.__collection

   def get_test_name(self):

      return self.__test_name

   #
   #   Check to see if "checkfor" is in the list "thelist".
   #   If it is, return True, otherwise, False.
   #
   def isInList(self, checkfor, thelist):

      for item in thelist:
         if ( item == checkfor ):
            return True

      return False

   def Do_Pass_Fail_Routine(self, total_results=0,
                            expected_total=-1, doexit=False):

      if ( total_results == expected_total ):
         print self.__test_name, ":  Test Passed"
         if ( doexit ):
            sys.exit(0)
         else:
            return 0

      print self.__test_name, ":  Test Failed"
      if ( doexit ):
         sys.exit(1)
      else:
         return 1

   def Collection_Exists(self):

      if ( self.__cgi.collection_exists(collection=self.__collection) ):
         return True

      return False

   def Open_Data_File(self, file_name=None, mode='r'):

      if ( file_name is not None ):
         try:
            file_handler = open(file_name, mode)
            if ( file_handles is not None ):
               return file_handler
         except:
            print self.__test_name, ":  test_helpers.Open_Data_File()"
            print self.__test_name, ":  I/O Error:", sys.exc_info()
      else:
         print self.__test_name, ":  test_helpers.Open_Data_File()"
         print self.__test_name, ":  File open ERROR:", \
               "file name not specified"

      return None

   def Write_Content_To_File(self, content=None, file_name=None, mode='w'):

      if ( file_name is None or content is None ):
         print self.__test_name, ":  test_helpers.Write_Content_To_File()"
         print self.__test_name, ":  File write ERROR:", \
               "content or file name not specified, nothing to write"
         return

      outfp = self.Open_Data_File(file_name, mode)
      if ( outfp is not None ):
         outfp.write(content)
         outfp.close()

      return

   def Split_Text_Line(self, line=None, separator=' '):

      line = line.replace('\n', '')
      word_list = line.split(separator)

      return word_list

   #
   #   Sets up a collection and starts a crawl.
   #
   def Start_The_Crawl(self, crlWait=True):

      stime = etime = 0

      if ( self.__collection is None ):
         print self.__test_name, ":  BARF ..."
         print self.__test_name, ":  Test Failed, no collection"
         raise Exception("Collection Error")
         sys.exit(1)

      if ( self.Collection_Exists() ):
         self.__cgi.delete_collection(collection=self.__collection, force=1)

      colfile = ''.join([self.__collection, '.xml'])

      self.__vapi.api_sc_create(collection=self.__collection,
                                based_on='default')
      self.__vapi.api_repository_update(xmlfile=colfile)
      print self.__test_name, ":  Starting the first crawl in live"
      self.__vapi.api_sc_crawler_start(collection=self.__collection,
                                       stype='new')
      #
      #   To wait, or not to wait, that is the question
      #
      if ( crlWait ):
         stime = time.time()
         self.__cgi.wait_for_idle(collection=self.__collection)
         etime = time.time()

         print self.__test_name, \
               ":  Approximate crawl time (seconds) =", \
               etime - stime

      return

   #
   #   Run a crawl without waiting for it to finish before returning
   #
   def Start_The_Crawl_No_Wait(self):

      self.Start_The_Crawl(False)

      return

   def New_Refresh_The_Crawl(self, crlWait=True):

      self.Some_Refresh_The_Crawl(crlWait, "refresh-new")

      return

   def Refresh_The_Crawl(self, crlWait=True):

      self.Some_Refresh_The_Crawl(crlWait, "refresh-inplace")

      return

   #
   #   Refresh the crawl in an existing collection
   #
   def Some_Refresh_The_Crawl(self, crlWait=True, refreshType=None):

      subc='live'

      if ( refreshType is None ):
         refreshType = 'refresh-inplace'

      if ( refreshType == 'refresh-new' ):
         subc='staging'

      stime = etime = 0

      if ( self.__collection is None ):
         print self.__test_name, ":  BARF ..."
         print self.__test_name, ":  Test Failed, no collection"
         raise Exception("Collection Error")
         sys.exit(1)

      if ( self.Collection_Exists() ):
         print self.__test_name, ":  Refreshing the crawl in live"
         self.__vapi.api_sc_crawler_start(collection=self.__collection,
                                          stype=refreshType, subc=subc)
         #
         #   To wait, or not to wait, that is the question
         #
         if ( crlWait ):
            stime = time.time()
            self.__cgi.wait_for_idle(collection=self.__collection)
            etime = time.time()
            print self.__test_name, \
                  ":  Approximate crawl time (seconds) =", \
                   etime - stime

      return

   #
   #   Refresh a crawl without waiting for it to finish before returning
   #
   def Refresh_The_Crawl_No_Wait(self):

      self.Refresh_The_Crawl(False)

      return
