#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   This is the basic crawl test created to test a word 2010 connector
#   This test does
#   A)  A basic crawl
#       The crawl is against a word 2010 file with basic constructs in it, such as:
#          Text box
#          Various heading levels
#          Paragraph
#          Table
#          Bullet list
#          Numbered list
#          Nested list
#          Bold
#   B)  query every word in the crawled data
#   C)  Checks that each queried/crawled word returns the document
#   D)  Checks that words NOT in the file return no documents when queried.
#
#   This test requires the samba connector.  It is installed by default when
#   Data Explorer is installed.
#
#   This test does NOT check that the metadata within the document is correctly crawled.
#
#

import sys, time, cgi_interface, vapi_interface 
import velocityAPI
import os, getopt

#
#   Start the initial crawl.
#   Breakdown of steps inline
#
def Start_The_Crawl(tname=None, xx=None, yy=None, collection=None):

   stime = etime = 0

   #
   #   The collection name must be specified
   #
   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      raise Exception("Collection Error")
      sys.exit(1)

   #   See if the collection already exists
   cex = xx.collection_exists(collection=collection)
   if ( cex == 1 ):
      #   If the collection already exists, delete it
      xx.delete_collection(collection=collection, force=1)

   colfile = ''.join([collection, '.xml'])

   #   Create the collection
   yy.api_sc_create(collection=collection, based_on='default')
   #   Update the collection so it is what we want.
   #   In this case, the collection file is word_2010_basic_1.xml
   #   That file is read and put into the Data Explorer repository
   yy.api_repository_update(xmlfile=colfile)

   #   Start the crawl
   print tname, ":  Starting the first crawl in live"
   yy.api_sc_crawler_start(collection=collection, stype='new')

   stime = time.time()
   #   Wait for the crawl to complete
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate crawl time (seconds) =", etime - stime

   return


#
#
def Do_Case_1(tname=None, xx=None, yy=None, collection=None, qword=None, hard_result=1):

   #   Initialize
   case_result = 0
   final_result = 2

   stime = etime = 0

   print "======================================="
   print tname, ":  WORD BEING QUERIED : ", qword

   stime = time.time()
   #   Query the collection for the word in the "qword" parameter and dump
   #   to the USout file.
   resp = yy.api_qsearch(source=collection, query=qword, filename="USout",
                         num=100000, odup='true')
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      #  Get the total results (document count returned) in 'total-results'
      urlcount = yy.getTotalResults(resptree=resp)
      #  Get the total results (actual document returned) by counting them
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   #  For this test case, we always expect 1 document because we are querying,
   #  1 by 1, each of the words in the document.
   print "   CASE 1:  Totaled Results : ", urlcount
   print "   CASE 1:  Counted Results : ", urlcount2
   print "   CASE 1:  Expected Results: ", hard_result

   #   Check that one of the results matches the expected result
   if (urlcount == hard_result):
      case_result += 1
      print "   CASE 1A(Document count matches expected count):  Case Passed"
   else:
      print "   CASE 1A(Document count matches expected count):  Case Failed"

   #   Check that the results match each other
   if (urlcount == urlcount2):
      case_result += 1
      print "   CASE 1B(counted result matches document search count):  Case Passed"
   else:
      print "   CASE 1B(counted result matches document search count):  Case Failed"
   print "======================================="

   #   Both of the checks above must pass for the case to pass
   if ( case_result == final_result ):
      #  Case passed
      return 1
   else:
      #  Case failed
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

#
#   Open the data file.  This is the file that contains the list of
#   words in the file we are crawling.
#
def open_data_file(filename=None):

   if (filename is not None):
      infd = open(filename, 'r')

      if (infd is not None):
         return infd
      else:
         return None
   else:
      return None

#
#   Within the data file there is one word per line
#   Read each line and make it usable by the query
#
def readaword(infd):

   data = infd.readline()

   if ( data == '' or data == None ):
      return None

   data = data.replace('\n', '')

   return data


if __name__ == "__main__":
 
   stime = etime = 0
   total_results = 0
   counted_results = 0

   #   Initialize ...
   #   tname or Test Name
   tname = "word_2010_basic_1"
   #   Self explanatory
   collection_name = "word_2010_basic_1"
   #   Use the collection name and build the name of the collection xml file
   #   which will be used to update the repository with the correct collection
   #   configuration.
   colfile = collection_name + '.xml'

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Set up for SPOC basic crawl"
   print tname, ":     Basic crawl using the new sharepoint connector"

   #   Initialize the CGI interface
   #   Though this is a misnomer.  A lot more goes on in this than CGI stuff.
   #   But that will have to do for now.
   xx = cgi_interface.CGIINTERFACE()
   #   Initialize the API interface
   yy = vapi_interface.VAPIINTERFACE()

   try:
   
      stime = time.time()

      #   Set up the collection and do the crawl
      Start_The_Crawl(tname, xx, yy, collection_name)
   
      print "#################################################"
      #
      #   This is a series of queries for words in the document.
   
      #   Open the data file
      infd_valid = open_data_file("word_data")

      #   For every word, query the collection and make sure that the query
      #   returns our document
      expected_result = 1
      zzz = readaword(infd_valid)
      while ( ( zzz != None ) and ( zzz != '' ) ):
         current_results = Do_Case_1(tname, xx, yy, collection_name, zzz, expected_result)
         total_results += current_results
         counted_results += 1
         zzz = readaword(infd_valid)

      if (total_results != counted_results):
         Do_Exit_Routine(tname, total_results, counted_results)
   
      print "#################################################"
      print "#################################################"
      #
      #   This is a series of queries for words NOT in the document.
   
      #   Open the data file
      infd_not_valid = open_data_file("not_word_data")

      #   For every word, query the collection and make sure that the query
      #   returns NO document
      expected_result = 0
      zzz = readaword(infd_not_valid)
      while ( ( zzz != None ) and ( zzz != '' ) ):
         current_results = Do_Case_1(tname, xx, yy, collection_name, zzz, expected_result)
         total_results += current_results
         counted_results += 1
         zzz = readaword(infd_not_valid)

      if (total_results != counted_results):
         Do_Exit_Routine(tname, total_results, counted_results)
   
      print "#################################################"
   
   finally:
      infd_valid.close()
      infd_not_valid.close()
      etime = time.time()
      print "#################################################"
      print tname, ": TEST RUN TIME(seconds) =", etime - stime
      print "#################################################"
   
   #   Overall test result printed
   if (Do_Exit_Routine(tname, total_results, counted_results) == 0):
      #   If the test passed, delete the collection
      #xx.delete_collection(collection=collection_name, force=1)
      #   If the test passed, exit 0
      sys.exit(0)
   
   #   If the test failed, keep the collection
   #   If the test failed, exit NOT 0
   sys.exit(1)
      
