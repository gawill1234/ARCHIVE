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
   #   In this case, the collection file is dump_dictionary.xml
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
def open_data_file(filename=None, mymode="r"):

   if (filename is not None):
      infd = open(filename, mymode)

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

def dump_dict_data(tname, yy, xx, dictionary_name, dictionary_file):

   #
   #   Probably easier ways, but this illustrates exactly what is 
   #   happening to get the words in the dictionary.
   #
   letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
              'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
              'w', 'x', 'y', 'z']
   wordcount = 0

   try:
      os.remove("word_dump_file")
   except:
      print tname, ":  File did not exist, continue"

   outfd = open_data_file("word_dump_file", "w+")

   for baseletter in letters:
      #
      #   Created the dictionary with autocomplete enabled so that we
      #   could get all of the words in it easily with out  a lot of
      #   post processing of the file.
      #
      zz = yy.api_autocomplete_suggest(dictionary_name=dictionary_name,
                                    basestr=baseletter, num=1200)
      print tname, ":  --------------------------------------"
      print tname, ":  Returned phrase list for letter", baseletter
      try:
         if ( zz is not None and zz != [] ):
            for item in zz:
               wordcount += 1
               print tname, ", word: ", item
               outfd.write(item)
               outfd.write('\n')
      except:
         print tname, ":  --------------------------------------"

   outfd.close()
   print tname, ": Found", wordcount, "words"

   return


if __name__ == "__main__":
 
   stime = etime = 0
   total_results = 0
   counted_results = 0

   #   Initialize ...
   #   tname or Test Name
   tname = "dump_dictionary"
   #   Self explanatory
   collection_name = "dump_dictionary"
   #   Use the collection name and build the name of the collection xml file
   #   which will be used to update the repository with the correct collection
   #   configuration.
   colfile = collection_name + '.xml'

   dictionary_name = "word-collection-dictionary"
   dictionary_file = "dictionary.xml"

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

   #get_rid_of_dictionary(tname, yy, xx, dictionary_name)
   #dict_create_with_collection(tname, yy, xx, dictionary_name, dictionary_file, True)

   #dump_dict_data(tname, yy, xx, dictionary_name, dictionary_file)

   #sys.exit(0)

   try:
   
      stime = time.time()

      #   Set up the collection and do the crawl
      Start_The_Crawl(tname, xx, yy, collection_name)
   
      print "#################################################"
      #
      #   This is a series of queries for words in the document.
   
      #   Open the data file
      infd_valid = open_data_file("word_data", "r")

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
      infd_not_valid = open_data_file("not_word_data", "r")

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

      #
      #   If the old dictionary exists, get rid of it
      #
      get_rid_of_dictionary(tname, yy, xx, dictionary_name)
      #
      #   Creae the new dictionary
      #
      dict_create_with_collection(tname, yy, xx, dictionary_name, dictionary_file, True)

      #
      #   Dump the dictionary words to a file
      #
      dump_dict_data(tname, yy, xx, dictionary_name, dictionary_file)
   
   finally:
      infd_valid.close()
      infd_not_valid.close()
      etime = time.time()
      print "#################################################"
      print tname, ": TEST RUN TIME(seconds) =", etime - stime
      print "#################################################"

   sys.exit(0)
   
   #   Overall test result printed
   if (Do_Exit_Routine(tname, total_results, counted_results) == 0):
      #   If the test passed, delete the collection
      xx.delete_collection(collection=collection_name, force=1)
      #   If the test passed, exit 0
      sys.exit(0)
   
   #   If the test failed, keep the collection
   #   If the test failed, exit NOT 0
   sys.exit(1)
      
