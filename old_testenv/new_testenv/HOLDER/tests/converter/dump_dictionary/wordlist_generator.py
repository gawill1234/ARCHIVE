#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   This is the program that will generate the word list of a file
#   This test does
#   A)  A basic crawl
#       It crawls a file in a collection
#   B)  Generate a dictionary for this collection
#   C)  Use gronk to save its dictionary under /tmp directory if there is one
#   D)  Deletet the collection and the dictionary
#
#   This test requires the samba connector.  It is installed by default when
#   Data Explorer is installed.
#
#   This test does NOT check that the metadata within the document is correctly crawled.
#
#

import sys, re, codecs, time, cgi_interface, vapi_interface
import velocityAPI
import os, getopt
import urllib2, ntpath, urllib
import converter_test_helper
from optparse import OptionParser
from xml.etree import ElementTree
from lxml import etree
from os import path


reload(sys)
sys.setdefaultencoding("utf-8")



#
#   Create and build the dictionary based on given search collection
#
def build_dict_with_collection(test_name, velocity_api_instance, velocity_cgi_instance, \
                                  dictionary_name, dictionary_file, do_create):

   # Create the new dictionary if needed
   if ( do_create ):
      print test_name, ":  Create dictionary", dictionary_name
      velocity_api_instance.api_dictionary_create(dictionary_name=dictionary_name)

      print test_name, ":  Update dictionary", dictionary_name,
      velocity_api_instance.api_repository_update(xmlfile=dictionary_file)

   # Bulid the dictionary
   print test_name, ":  Build dictionary", dictionary_name
   velocity_api_instance.api_dictionary_build(dictionary_name=dictionary_name)

   dict_status = velocity_api_instance.api_dictionary_status(xx=velocity_cgi_instance, dictionary_name=dictionary_name)
   while ( dict_status != "aborted" ) and ( dict_status != "finished" ):
      print test_name, ":  Current build status,", dict_status
      time.sleep(5)
      print test_name, ":  Recheck the dictionary status"
      dict_status = velocity_api_instance.api_dictionary_status(xx=velocity_cgi_instance, dictionary_name=dictionary_name)

   if ( dict_status == "aborted" ):
      print test_name, ":  Dictionary build failed", dictionary_name
      print test_name, ":  Test Failed"
      sys.exit(99)
   else:
      print test_name, ":  Dictionary build complete"
      print test_name, ":  Sleep of a couple of seconds let filesystem data flush"
      time.sleep(2)

   return

#
#   Delete the dictionary
#
def get_rid_of_dictionary(test_name, velocity_api_instance, velocity_cgi_instance, dictionary_name):

   try:
      velocity_api_instance.api_dictionary_delete(dictionary_name=dictionary_name)
      velocity_api_instance.api_repository_get(elemtype="dictionary",
                            elemname=dictionary_name)
   except velocityAPI.VelocityAPIexception:
      print test_name, ":  Dictionary gone!"
      return

   print test_name, ":  Dictionary delete failed"
   print test_name, ":  Test Failed"
   sys.exit(1)


#
#   Modify default xml file based on user input and
#   return a proper new xml file
#
def modify_dictionary_xml(collection_name):

   DEFAULT_XML = "dictionary"    # dictionary.xml is a default file

   xml_tree = ElementTree.parse(DEFAULT_XML + ".xml")
   dictionary = xml_tree.getroot()
   dictionary.set('name', collection_name + "_dict")

   dictionary_input = dictionary[0]
   call = dictionary_input[0]
   name = call[0]

   name.text = collection_name

   xml_tree.write(collection_name + "_dict.xml")

   return

#
#   Get word list generation arguments from clients
#
def get_arguments():

    parser = OptionParser(usage= "\n" + \
                              "%prog -s /converter_test/test.doc [if your file in on testbed5]\n" +\
                              "%prog -s /test.doc -h ubuntu -u user -p pass [if you have yourown smb]",\
                              version="%prog 1.0")
    parser.add_option("-n", "--xmlfile", dest="xmlfile", default="template.xml",
                     help="xml file name", metavar="FILE")
    parser.add_option("-s", "--shares", dest="shares",
                      help="source directory or file which contains testing data", metavar="FILE")
    parser.add_option("-t", "--host", dest="host", default="testbed5.test.vivisimo.com",
                      help="host of smb source directory/file")
    parser.add_option("-u", "--username", dest="username", default="gaw",
                      help="login username of smb source directory/file")
    parser.add_option("-p", "--password", dest="password", default="[[vcrypt]]TMWiymi8UsQ9QvtqWkxuhw==",
                      help="login password of smb source directory/file")
    parser.add_option("-q", "--quiet",
                      action="store_false", dest="verbose", default=True,
                      help="don't print status messages to stdout")

    (options, args) = parser.parse_args()

    if options.shares is None:
        parser.error("Please specify the path of your file which wants to generate its dictionary\n")

    return options

#
#   Dump the dictionary words to a word list file by gronk
#
def get_dictionary_wildcard(velocity_cgi_instance, dictionary_name, dictionary_file, test_file):
   # Read dictionary wildcard by gronk http
   gronk_http = 'http://' + velocity_cgi_instance.TENV.target + ":" + \
       velocity_cgi_instance.TENV.httpport + velocity_cgi_instance.gronk

   action = "get-file"
   dict_dir = velocity_cgi_instance.vivisimo_dir("dictionary") + "/" + \
       dictionary_name + "/wildcard.dict"

   http_string = ''.join(['action=', action,
                          '&file=', dict_dir])

   wildcard_http = gronk_http + '?' + http_string

   dict_wildcard = urllib2.urlopen(wildcard_http).read()

   dict_wildcard_xml = converter_test_helper.strip_illegal_chars_in_xml(dict_wildcard)

   word_list = save_to_wordlist_format(dict_wildcard_xml, test_file)

   return word_list


#
#   Save a xml file to a word list format for testing
#   Word list has the same format that first column must be a word
#   There may be word frequency on the second column and
#   other information on the following columns
#
def save_to_wordlist_format(xml_file, test_file):

   xml_etree = etree.fromstring(xml_file)
   #  Get the complete word list from xml
   for s in xml_etree.xpath("//DATA"):
      xml_text = s.text.rstrip('\n')

   #  If there is no dictionary, return
   if (not xml_text):
      print "None dictionary content return"
      return 1

   # find a valid place to save the output
   output_wordlist_file = find_the_valid_wordlist_output_path(test_file)
   # remove the one already exists
   if path.exists(output_wordlist_file) and path.isfile(output_wordlist_file):
      os.remove(output_wordlist_file)

   # save the word list to a file
   wordlist = open(output_wordlist_file, 'a+b')
   for word in xml_text.split('\n'):
      wordlist.write(unicode(word).split()[0] + '\n')
   return 0

#
#   If test file is in the local fs,
#   just save it under the same path with test file
#   Otherwise, save it under /tmp directory
#
def find_the_valid_wordlist_output_path(test_file):

   if path.exists(test_file):
      wordlist_file = test_file + ".words"
   else:
      wordlist_file = '/tmp/' + test_file + ".words"
      wordlist_path = os.path.dirname(wordlist_file)

      #  Create the same directory structure under /tmp
      if not path.exists(wordlist_path):
         os.makedirs(wordlist_path)
   return wordlist_file


def main(argv=None):
    if argv is not None:
        sys.argv[1:] = argv

    #  Parse the arguments from user
    options = get_arguments()
    #  Modify xml file based on input arguments
    test_name = collection_name = converter_test_helper.modify_collection_xml(options)

    #   Use the collection name and build the name of the collection xml file
    #   which will be used to update the repository with the correct collection
    #   configuration.
    collection_xml_filename = collection_name + '.xml'
    test_file = options.shares

    #   Initialize ...
    stime = etime = 0

    #   Initialize the CGI interface
    #   Though this is a misnomer.  A lot more goes on in this than CGI stuff.
    #   But that will have to do for now.
    velocity_cgi_instance = cgi_interface.CGIINTERFACE()
   #   Initialize the API interface
    velocity_api_instance = vapi_interface.VAPIINTERFACE()

    try:
       stime = time.time()
       #   Set up the collection and do the crawl
       converter_test_helper.start_the_crawl(test_name, velocity_cgi_instance, velocity_api_instance, collection_name)
       print "#################################################"

       # Modify dictionary xml file based on collection name
       modify_dictionary_xml(collection_name)

       dictionary_name = collection_name + "_dict"
       dictionary_file = collection_name + "_dict.xml"


       #   If the old dictionary exists, get rid of it
       get_rid_of_dictionary(test_name, velocity_api_instance, \
                                velocity_cgi_instance, dictionary_name)

       #   Create the new dictionary
       build_dict_with_collection(test_name, velocity_api_instance, \
                                     velocity_cgi_instance, dictionary_name, dictionary_file, True)

       #   Dump dictionary wildcard to the word list
       word_list_result = get_dictionary_wildcard(velocity_cgi_instance, \
                                                     dictionary_name, dictionary_file, test_file)

    finally:
       etime = time.time()
       print "#################################################"
       print test_name, ": TEST RUN TIME(seconds) =", etime - stime
       print "#################################################"

    #   Overall test result printed
    if word_list_result == 0:
       #   If the test passed, delete the collection and the dictionary
       velocity_cgi_instance.delete_collection(collection=collection_name, force=1)
       velocity_cgi_instance.delete_collection(collection=collection_name + "_dict-autocomplete", force=1)
       get_rid_of_dictionary(test_name, velocity_api_instance, velocity_cgi_instance, dictionary_name)
       os.remove(collection_xml_filename)
       os.remove(dictionary_file)

    #   If the test passed, exit 0
       return 0

    #   If the test failed, keep the collection
    #   If the test failed, exit NOT 0
    converter_test_helper.write_content_to_file('nodict.log', test_file, 'a')

    return 1


if __name__ == "__main__":
    sys.exit(main())
