#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   Test origins:  Bug 26810
#
#   This test set is to test SMB shares with assigned ACLs.  These
#   tests cover limited user access, as defined with SMB ACLs, to a
#   series of user shares.
#  
#   smb-many-user-1 is a full crawl of mixed directory with depth
#                   and breadth.
#   smb-many-user-2 is a full crawl of mixed directories with 
#                   limited depth
#   smb-many-user-3 is a full crawl of mixed directories with breadth
#   smb-many-user-4 is a full crawl of all users where only one user
#                   should be accessible as the collection is defined.
#

import sys, time, cgi_interface, vapi_interface, getopt
from lxml import etree

def stats_check(collection=None, yy=None):

   fail = 0
   coldmp = 'querywork/' + collection + '.stat.dump'
   colbase = collection + '.xml.stats'

   try:
      current_tree = yy.api_sc_status(collection=collection, filename=coldmp)
   except:
      print tname, ":   Could not get status data for", collection
      return 99

   try:
      n_input  = int(current_tree.xpath('crawler-status/@n-input')[0])
      n_output = int(current_tree.xpath('crawler-status/@n-output')[0])
      idx_docs = int(current_tree.xpath('vse-index-status/@indexed-docs')[0])
      n_docs = int(current_tree.xpath('vse-index-status/@n-docs')[0])
      n_errors = int(current_tree.xpath('crawler-status/@n-errors')[0])
   except:
      print tname, ":   Could not extract status data"
      return 99

   try:
      fd = open(colbase, "r+")
      data = fd.read()
      fd.close()
   except:
      print tname, ":   Could not open base file"
      return 99

   base_tree = etree.fromstring(data)

   try:
      n_input_base  = int(base_tree.xpath('//crawler-status/@n-input')[0])
      n_output_base = int(base_tree.xpath('//crawler-status/@n-output')[0])
      idx_docs_base = int(base_tree.xpath('//vse-index-status/@indexed-docs')[0])
      n_docs_base = int(base_tree.xpath('//vse-index-status/@n-docs')[0])
      n_errors_base = int(base_tree.xpath('//crawler-status/@n-errors')[0])
   except:
      print tname, ":   Could not extract base data"
      return 99

   print tname, ":   crawler inputs,   expected:", n_input_base
   print tname, ":                       actual:", n_input
   print tname, ":   crawler outputs,  expected:", n_output_base
   print tname, ":                       actual:", n_output
   print tname, ":   indexed docs,     expected:", idx_docs_base
   print tname, ":                       actual:", idx_docs
   print tname, ":   index n-docs,     expected:", n_docs_base
   print tname, ":                       actual:", n_docs
   print tname, ":   crawler n-errors, expected:", n_errors_base
   print tname, ":                       actual:", n_errors

   if ( n_input != n_input_base ):
      fail += 1
   if ( n_output != n_output_base ):
      fail += 1
   if ( idx_docs != idx_docs_base ):
      fail += 1
   if ( n_docs != n_docs_base ):
      fail += 1

   return fail

def collection_reset(tname=None, xx=None, yy=None, collection=None):

   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      sys.exit(1)

   colfile = ''.join([collection, '.xml'])

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name)

   yy.api_sc_create(collection=collection_name, based_on='default')
   yy.api_repository_update(xmlfile=colfile)

   yy.api_sc_crawler_start(collection=collection_name)

   return

def spew_comments(tname=None):

   if ( tname == 'smb-many-user-1' ):
      print tname, ":   smb-many-user-1 is a full crawl of mixed directory"
      print tname, ":   depth and breadth."
   elif ( tname == 'smb-many-user-10' ):
      print tname, ":   smb-many-user-10 is a full crawl of mixed directories"
      print tname, ":   with limited width surrounding a very wide directory."
   elif ( tname == 'smb-many-user-2' ):
      print tname, ":   smb-many-user-2 is a full crawl of mixed directories"
      print tname, ":   with limited depth."
   elif ( tname == 'smb-many-user-3' ):
      print tname, ":   smb-many-user-3 is a full crawl of mixed directories"
      print tname, ";   with breadth."
   elif ( tname == 'smb-many-user-4' ):
      print tname, ":   smb-many-user-4 is a full crawl of all users where"
      print tname, ":   only one user should be accessible as the collection"
      print tname, ":   is defined."
   elif ( tname == 'smb-many-user-5' ):
      print tname, ":   is not defined."
   elif ( tname == 'smb-many-user-6' ):
      print tname, ":   is not defined."
   elif ( tname == 'smb-many-user-7' ):
      print tname, ":   is not defined."
   elif ( tname == 'smb-many-user-8' ):
      print tname, ":   smb-many-user-8 is a single user crawl of an inner"
      print tname, ":   directory."
   elif ( tname == 'smb-many-user-9' ):
      print tname, ":   smb-many-user-9 is a single user crawl of an inner"
      print tname, ":   directory which the user has no direct access to."
   else:
      print tname, ":   Invalid test name used."
      print tname, ":   Usage: smb-many-user.tst -n <test-name>"
      print tname, ":          <test-name> is one of"
      print tname, ":          smb-many-user-1 or smb-many-user-2 or"
      print tname, ":          smb-many-user-3 or smb-many-user-4"
      print tname, ":   Test Failed"
      sys.exit(1)

   return


if __name__ == "__main__":

   opts, args = getopt.getopt(sys.argv[1:], "n:", ["test_name="])

   fail = 0

   tname = "smb-many-user"

   for o, a in opts:
      if o in ("-n", "--test_name"):
         tname = a
   # end for options

   collection_name = tname
   colfile = collection_name + '.xml'

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Source is Bug 26810"

   spew_comments(tname)
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   try:
      collection_reset(tname=tname, xx=xx, yy=yy, collection=collection_name)
   except:
      print tname, ":   Could not set/run collection"
      fail = 99

   if ( fail == 0 ):
      xx.wait_for_idle(collection=collection_name)
      fail = stats_check(collection=collection_name, yy=yy)

   ##############################################################

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)
   
   print tname, ":  Test Failed"
   sys.exit(1)

