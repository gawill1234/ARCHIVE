#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, time, cgi_interface, vapi_interface
import velocityAPI
import os, getopt, re
from optparse import OptionParser
from xml.etree import ElementTree

#
#  Query a word in the collection
#  return the result of total count number
#

def query_a_word(velocity_api_instance, collection, query_word):

   crawl_start_time = time.time()
   #   Query the collection for the word in the "query_word" parameter and dump
   #   to the USout file.
   result_tree = velocity_api_instance.api_qsearch(source=collection, query=query_word, filename="USout",
                         num=100000, odup='true')
   crawl_end_time = time.time()

   #  Get the total results (document count returned) in 'total-results'
   total_result_num = velocity_api_instance.getTotalResults(resptree=result_tree)
   #  Get the total results (actual document returned) by counting them
   total_count_result_num = velocity_api_instance.getResultUrlCount(resptree=result_tree)


   return crawl_end_time - crawl_start_time, total_result_num, total_count_result_num



#
#   Common exit routine for every routine to bail to if needed.
#
def check_final_test_result(test_name="not defined", total_results=0, expected_total=-1):

   if (total_results == expected_total):
      print test_name, ":  Test Passed"
      return 1
   print test_name, ":  Test Failed"
   return 0

#
#   Open the data file.
#
def open_data_file(filename=None):

   if (filename is not None):
      file_handler = open(filename, 'r')

      if (file_handler is not None):
         return file_handler
      else:
         return None
   else:
      return None


#
#   Split a line by the separator
#
def split_text_line(file_handler, separator):
   if file_handler == None:
      return None

   line = file_handler.readline()
   if ( line == None or line == ''):
      return None
   line = line.replace('\n', '')
   word_list = line.split(separator)
   return word_list


#
#  Write content to a file
#
def write_content_to_file(filename, content, write_type):
   output = open (filename, write_type)
   output.write(content)
   output.close()

#
#  Make sure the total crawled file number is the same as what we expected.
#  There are 2 possible error.
#  1) The first one is that the total crawled file number is less than what we expected which means
#     some files are ignored by DE or some files fail to be crawled.
#  2) The second one is that there is a error occured during crawling process,
#     so the total crawled file number is more than what we expected. (DE splits 1 file to several files)
#
def check_total_crawled_file_number(test_name=None, velocity_cgi_instance=None,
                                    velocity_api_instance=None, collection=None, expected_result=1):

   #   Initialize
   print "======================================================================="
   print test_name, ": QUERY TO RETURN ALL FILES WITHOUT GIVEN ANY KEYWORD: "


   crawling_time, total_result_num, total_count_result_num = \
       query_a_word(velocity_api_instance, collection, "")

   print "   Approximate search time (seconds) =", crawling_time
   print "   Totaled Results : ", total_result_num
   print "   Counted Results : ", total_count_result_num
   print "   Expected Results: ", expected_result


   if total_result_num == expected_result and total_count_result_num == expected_result:
      return 0
   elif total_result_num < expected_result or total_count_result_num < expected_result:
      print "Case Failed: Crawled file number is less than what we expected"
      return 1  # crawl failed
   elif total_result_num > expected_result or total_count_result_num > expected_result:
      print "Case Failed: Crawled file number is more than what we expected."
      print "             Some files may be splitted to several files when crawling."
      return 2   #file split


#
#   Modify default xml file based on user input
#   Return a proper new xml file for testing
#
def modify_collection_xml(user_input):
   DEFAULT_XML = "template"    # template.xml is a default file

   timestamp = str(time.time()) # Use timestamp as a part of file name

   # If there is an input specific xml file, don't use the default one
   if (user_input.xmlfile):
      xmlname = user_input.xmlfile + '_' + timestamp
      tree = ElementTree.parse(user_input.xmlfile)
   else:
      xmlname = DEFAULT_XML + '_' + timestamp
      tree = ElementTree.parse(DEFAULT_XML + ".xml")

   # Get arguments values
   host = user_input.host
   username = user_input.username
   password = user_input.password
   shares = user_input.shares

   # Start to modify xml content...
   collection = tree.getroot()
   config = collection[0]
   meta = collection [1]
   crawler = config[0]
   index = config[1]
   converters = config[2]

   # Change the content based on user input
   collection.set('name', xmlname)
   meta.set('name', xmlname)
   for f in crawler.findall('call-function'):
      if f.get('type'):
         for w in f.findall('with'):
            if w.get('name') == "host" and host:
               w.text = host
            elif w.get('name') == "username" and host:
               w.text = username
            elif w.get('name') == "password" and host:
               w.text = password
            elif w.get('name') == "shares" and shares:
               w.text = shares

   tree.write ( xmlname + '.xml' )

   return xmlname

#
#   Make sure the collection name is specified
#
def ensure_collection_is_specified(collection, test_name):
   if ( collection is None ):
      print test_name, ":  Test Failed, no collection specified, input collection name is None"
      raise Exception("Collection Error")
      sys.exit(1)


#
#   Start the initial crawl.
#   Breakdown of steps inline
#
def start_the_crawl(test_name=None, velocity_cgi_instance=None, velocity_api_instance=None, collection=None):

   ensure_collection_is_specified(collection, test_name)

   #   If the collection already exists, delete it
   collection_exists = velocity_cgi_instance.collection_exists(collection=collection)
   if ( collection_exists == 1 ):
      velocity_cgi_instance.delete_collection(collection=collection, force=1)

   collection_xml_filename = ''.join([collection, '.xml'])

   #   Create the collection
   velocity_cgi_instance.create_collection(collection=collection)

   #   Update the collection so it is what we want.
   #   The file(s) are read and put into the Data Explorer repository
   velocity_cgi_instance.repo_update(importfile=collection_xml_filename)

   #   Start the crawl
   print test_name, ":  Starting the first crawl in live"
   velocity_api_instance.api_sc_crawler_start(collection=collection, stype='new')

   #   Record the time of crawling
   crawl_start_time = crawl_end_time = 0
   crawl_start_time = time.time()
   #   Wait for the crawl to complete
   velocity_cgi_instance.wait_for_idle(collection=collection)
   crawl_end_time = time.time()

   print test_name, ":  Approximate crawl time (seconds) =", crawl_end_time - crawl_start_time

   return


#
#   Check if there is any illegal character in input xml file.
#   Remove illegal xml character and return a clean xml file.
#
def strip_illegal_chars_in_xml(input_file):
    clean_xml = ''
    illegal_xml_chars = re.compile(u'[\x00-\x08\x0b\x0c\x0e-\x1F\uD800-\uDFFF\uFFFE\uFFFF]')

    for line in input_file:
        new_line, count = illegal_xml_chars.subn('', line)
        clean_xml += new_line

    return clean_xml
