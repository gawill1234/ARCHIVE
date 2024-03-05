#!/usr/bin/python

import os, sys, string, time
import cgi_interface, vapi_interface
from lxml import etree

if __name__ == "__main__":

   fail = 0

   collection_name = 'samba-pst'
   tname = "samba-pst"
   cfile = collection_name + '.xml'

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name)

   yy.api_sc_create(collection=collection_name, based_on='default')
   yy.api_repository_update(xmlfile=cfile)

   yy.api_sc_crawler_start(collection=collection_name, subc='live')
   xx.wait_for_idle(collection=collection_name)

   ######################################################################

   print tname, ":  ####################################"
   print tname, ":  CASE 1, Query all data"

   resp = yy.api_qsearch(source=collection_name, query="",
                         num=2000, filename="pstout1")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0

   filename = yy.look_for_file(filename='pstout1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   if ( urlcount != 1745 ):
      fail += 1
      print tname, ":  Urlcount wrong"
      print tname, ":     Expected, 1745"
      print tname, ":     Actual,  ", urlcount
      print tname, ":  CASE 1 FAILED"
   else:
      print tname, ":  CASE 1 PASSED"
   print tname, ":  ####################################"

   ######################################################################

   print tname, ":  ####################################"
   print tname, ":  CASE 2, Query Hilton"

   resp = yy.api_qsearch(source=collection_name, query="Hilton",
                         num=20, filename="pstout2")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0

   filename = yy.look_for_file(filename='pstout2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   if ( urlcount != 6 ):
      fail += 1
      print tname, ":  Urlcount wrong"
      print tname, ":     Expected, 6"
      print tname, ":     Actual,  ", urlcount
      print tname, ":  CASE 2 FAILED"
   else:
      print tname, ":  CASE 2 PASSED"
   print tname, ":  ####################################"

   ######################################################################

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)

