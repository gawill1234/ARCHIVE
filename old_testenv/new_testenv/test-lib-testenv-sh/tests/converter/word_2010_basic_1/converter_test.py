#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   This is the basic crawl test created to test several text converters
#   This test does
#   A)  A basic crawl
#       Serveral file types can be crawled with basic constructs in it, such as:
#          Text box
#          Various heading levels
#          Paragraph
#          Table
#          Bullet list
#          Numbered list
#          Nested list
#          Bold
#       We put our test files in \\testbed5.test.vivisimo.com\testfiles\test_data\real_documents\
#   B)  Query to return all files
#   C)  Make sure the total return number is the same as what we expected. (The number of docs)
#   D)  query every word in the crawled data
#   E)  Checks that each queried/crawled word returns the document
#   F)  Checks that words NOT in the file return no documents when queried.
#
#   This test requires the samba connector.  It is installed by default when
#   Data Explorer is installed.
#
#   This test does NOT check that the metadata within the document is correctly crawled.
#
#

import sys, time, cgi_interface, vapi_interface
import velocityAPI
import converter_test_helper
import os, getopt
from optparse import OptionParser
from xml.etree import ElementTree

# This is the error report for debugging
error_context = ''

#
#   Make sure the collection name is specified
#
def ensure_collection_is_specified(collection, test_name):
   if ( collection is None ):
      print test_name, ":  Test Failed. no collection specified."
      print "Input collection name is None. "
      raise Exception("Collection Error")
      sys.exit(1)


#
#   Start the initial crawl.
#   Breakdown of steps inline
#
def start_the_crawl(test_name=None, velocity_cgi_instance=None, \
                       velocity_api_instance=None, collection=None):

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

   print test_name, ":  Approximate crawl time (seconds) =", \
       crawl_end_time - crawl_start_time

   return crawl_end_time - crawl_start_time


#
#   For every word in the given word list, query the collection and make sure that the query
#   returns our expected documents.
#
def check_query_result_in_word_list(test_name, velocity_cgi_instance, velocity_api_instance,
                                    collection_name, word_list, expected_result):
   #   Initialize
   total_results = 0
   counted_results = 0

   #   This is a series of queries for words in the document.
   #   Open the data file
   word_list_file = converter_test_helper.open_data_file(word_list)
   #   For every word, query the collection and check the return number
   word_freq = converter_test_helper.split_text_line(word_list_file, '\t')
   while ( ( word_freq != None ) and ( word_freq != '' ) ):
      query_word = word_freq[0]     # word
      if ( len(word_freq) == 1 ):
         freq = expected_result     # No expected count info in the word list
      else:
         freq = int(word_freq[1])   # Use the expected count info in the give word list

      current_results = compare_query_result_num_with_expected_num(\
         test_name, velocity_api_instance, collection_name, query_word, freq)
      total_results += current_results
      counted_results += 1

      #   Get the next word line in the word list file
      word_freq = converter_test_helper.split_text_line(word_list_file, '\t')

   word_list_file.close()

   # If all the words in the word list pass, return 1,
   # else return 0
   return converter_test_helper.check_final_test_result(\
      "Test using word list " + word_list, total_results, counted_results)


#
#  Query a word in the collection
#  Make sure the number of file return is the same as what we expected
#
def compare_query_result_num_with_expected_num(test_name=None, \
                                                  velocity_api_instance=None, \
                                                  collection=None, \
                                                  query_word=None, expected_result=1):

   #   Initialize
   case_result = 0
   final_result = 2

   print "=================================================="
   print test_name, ":  WORD BEING QUERIED : ", query_word

   crawling_time, total_result_num, total_count_result_num = \
       converter_test_helper.query_a_word(velocity_api_instance, \
                                             collection, query_word)

   print "   Approximate search time (seconds) =", crawling_time
   print "   Totaled Results : ", total_result_num
   print "   Counted Results : ", total_count_result_num
   print "   Expected Results: ", expected_result



   #   Check that one of the results matches the expected result
   if (total_result_num == expected_result):
      case_result += 1
      print "   CASE 1A(Document count matches expected count):  Case Passed"
   else:
      print "   CASE 1A(Document count matches expected count):  Case Failed"

   #   Check that the results match each other
   if (total_result_num == total_count_result_num):
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
      global error_context
      error_context += query_word + "\t" + str(total_result_num) + "\t" \
          + str(total_count_result_num) + "\t" + str(expected_result) + "\n"

      #  Case failed
      return 0


#
#   Parse the Arguments from clients
#
def get_arguments():

   parser = OptionParser(usage= "\n" + \
                     "%prog -n test.xml -w /tmp/word_list  [if you have xml file]\n" + \
                     "%prog -s /converter_test/test.doc -w /tmp/word_list"
                     "[if your file in on testbed5]\n" +\
                     "%prog -s /test.doc -t ubuntu -u user -p pass -w /tmp/word_list" +
                     "[if you have yourown smb]", version="%prog 1.0")
   parser.add_option("-n", "--xmlfile", dest="xmlfile", default="template.xml",
                     help="xml file name", metavar="FILE")
   parser.add_option("-s", "--shares", dest="shares",
                     help="source directory or file which contains testing data", \
                        metavar="FILE")
   parser.add_option("-t", "--host", dest="host", default="testbed5.test.vivisimo.com",
                     help="host of smb source directory/file")
   parser.add_option("-u", "--username", dest="username", default="gaw",
                     help="login username of smb source directory/file")
   parser.add_option("-p", "--password", dest="password", \
                        default="[[vcrypt]]TMWiymi8UsQ9QvtqWkxuhw==",
                     help="login password of smb source directory/file")
   parser.add_option("-w", "--wordlist", dest="wordlist",
                     help="location of word list")
   parser.add_option("-x", "--non-wordlist", dest="nonwordlist", default="not_word_data",
                     help="location of non-word list")
   parser.add_option("-c", "--filenumber", dest="filenumber", default=1, type="int",
                     help="file number in this test. Default = 1")
   parser.add_option("-q", "--quiet",
                     action="store_false", dest="verbose", default=True,
                     help="don't print status messages to stdout")

   (options, args) = parser.parse_args()
   if options.wordlist is None:
      parser.error("Please specify your word list. ")
   if options.xmlfile == "template.xml" and options.shares is None:
      parser.error("Please specify the path of your test file/directory or xml file\n")

   return options




def main(argv=None):
   if argv is not None:
      sys.argv[1:] = argv

   #   Get input arguments
   options = get_arguments()

   #   Initialize ...
   #   Test Name, xmlname and collection_name with timestamp as a part
   test_name = collection_name = \
       converter_test_helper.modify_collection_xml(options)

   #   Use the collection name and build the name of the collection xml file
   #   which will be used to update the repository with the correct collection
   #   configuration.
   collection_xml_filename = collection_name + '.xml'

   #   Get the total testing file number in this testing collection
   file_number = options.filenumber

   ##############################################################
   print test_name, ":  ##################"
   print test_name, ":  INITIALIZE, Set up for basic crawl"
   print test_name, ":     Basic crawl of testing files in ", options.shares,
   print            "      into collection ", collection_name
   print            "      Test the total crawled file number is correct."
   print            "      Words in the word list can be found in the collection"
   print            "      Words in the non-word list shouldn't be found in the collection"

   #   Initialize the CGI interface
   velocity_cgi_instance = cgi_interface.CGIINTERFACE()
   #   Initialize the API interface
   velocity_api_instance = vapi_interface.VAPIINTERFACE()

   try:
      test_start_time = time.time()

      #   Set up the collection and do the crawl
      crawling_time = start_the_crawl(test_name, velocity_cgi_instance, \
                                         velocity_api_instance, collection_name)
      converter_test_helper.write_content_to_file(options.wordlist + ".time", \
                                                     str(crawling_time), 'w')

      print "#################################################"
      #   Make sure the total crawled file in the collection is the same
      #   as what we expected.
      check_result = converter_test_helper.check_total_crawled_file_number(\
         test_name, velocity_cgi_instance, velocity_api_instance, \
            collection_name, int(file_number))

      #   If the result is different from our expectation,
      #   return, and no need to do the search test
      if check_result == 1:
         return 1
      elif check_result == 2:
         return 2

      #   Initialize the total testing result
      total_check_result = 0
      test_count = 0

      # Use the word list to run the test
      print "#################################################"
      check_result = check_query_result_in_word_list(test_name, \
                                                        velocity_cgi_instance, \
                                                        velocity_api_instance, \
                                                        collection_name, \
                                                        options.wordlist, 1)
      total_check_result += check_result
      test_count += 1

      # Use the non-word list to run the test
      print "#################################################"
      check_result = check_query_result_in_word_list(test_name, \
                                                        velocity_cgi_instance, \
                                                        velocity_api_instance, \
                                                        collection_name, \
                                                        options.nonwordlist, 0)
      total_check_result += check_result
      test_count += 1

      print "#################################################"

   finally:
      test_end_time = time.time()
      print "#################################################"
      print test_name, ": TEST RUN TIME(seconds) =", test_end_time - test_start_time
      print "#################################################"

   #   Overall test result printed
   if (converter_test_helper.check_final_test_result( \
         test_name, total_check_result, test_count) == 1):
      #   If the test passed, delete the collection, and its xml file
      os.remove(collection_xml_filename)
      velocity_cgi_instance.delete_collection(collection=collection_name, force=1)

      #   If the test passed, exit 0
      return 0

   #   If the test failed, keep the collection
   global error_context
   converter_test_helper.write_content_to_file(\
      options.shares + ".error", error_context, 'w')
   #   If the test failed, exit NOT 0
   return 3

if __name__ == "__main__":
   result = main()
   sys.exit(result)

