#!/usr/bin/python

import os, sys, string, time
import build_schema_node
import cgi_interface, vapi_interface
from lxml import etree

def dopartone(myvsekey, myurl, mydata, mycollection, cname):

   newcrwlurl = build_schema_node.create_crawl_url(status='complete',
                                  url=myurl,
                                  synchronization='indexed')
   newcrwldata = build_schema_node.create_crawl_data(
                       contenttype='application/vxml',
                       addnodeto=newcrwlurl, encoding='xml')
   newdoc = build_schema_node.create_document(
                              vsekey=myvsekey,
                              addnodeto=newcrwldata)
   newcont = build_schema_node.create_content(name=cname, text=mydata,
                               addnodeto=newdoc)
   print etree.tostring(newcrwlurl)

   yy.api_sc_enqueue_xml(collection=mycollection, subc='live',
                     crawl_nodes=etree.tostring(newcrwlurl))

   return

def doparttwo(myvsekey, myurl, mydata, mycollection, cname):

   newcrwlurl = build_schema_node.create_crawl_url(status='complete',
                                  url=myurl,
                                  synchronization='indexed')
   newcrwldata = build_schema_node.create_crawl_data(
                       contenttype='application/vxml',
                       addnodeto=newcrwlurl, encoding='xml')
   newcont = build_schema_node.create_content(name=cname,
                               text=mydata, addto=myvsekey,
                               addnodeto=newcrwldata)
   print etree.tostring(newcrwlurl)
   yy.api_sc_enqueue_xml(collection=mycollection, subc='live',
                     crawl_nodes=etree.tostring(newcrwlurl))

   return

if __name__ == "__main__":

   collection_name = 'really_long_url_collection2'
   tname = "really_long_url_name_2"
   cfile = collection_name + '.xml'

   print tname, ":   TEST PURPOSE"
   print tname, ":   Add content that has really long urls"
   print tname, ":   greater than 512 characters"
   print tname, ":   many levels in the url (/ separators)"

   fail = 0

   #
   #   While we are using a number of urls in the test, these are the only two
   #   that should actually appear in queries.
   #
   fullurl = 'http://127.0.0.1:7205/this/is/a/really/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/abcdefghijklmonpqrstuvwxyz/0123456789/this/is/a/really/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/toperform/abcdefghijklmonpqrstuvwxyz/0123456789/this/is/a/really/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/whichi/am/attempting/to/perform/abcdefghijklmonpqrstuvwxyz/0123456789'

   fullurl2 = 'http://127.0.0.1:7205/this/is/a/really/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/9876543210this/is/areally/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/9876543210this/is/areally/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/9876543210'

   #
   #   REALLY long urls (greater than 512 characters)
   #
   url = "this/is/a/really/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/abcdefghijklmonpqrstuvwxyz/0123456789/this/is/a/really/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/toperform/abcdefghijklmonpqrstuvwxyz/0123456789/this/is/a/really/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/whichi/am/attempting/to/perform/abcdefghijklmonpqrstuvwxyz/0123456789"

   data1 = "This is a test of the emergency broadcast system."
   data2 = "The quick brown fox jumps over the lazy dog."

   url3 = "this/is/a/really/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/9876543210this/is/areally/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/9876543210this/is/areally/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/9876543210"

   url4 = "thisisareallylongbutbogusnamedesignedtomakethingslookalittlewonkywhilenotreallydoinganythingtothefunctionofactionwhichiamattemptingtoperformsomemoreagain12345678901234567890this/is/areally/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/9876543210this/is/areally/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/9876543210"

   url5 = "wtfthis/is/areally/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/9876543210this/is/areally/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/987654321this/is/areally/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/9876543210this/is/areally/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/some/more/abcdefghijklmonpqrstuvwxyz/0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ/98765432100"

   data3 = "We the people, of the United States, in order to form a"
   data4 = "more perfect union, establish justice, insure domestic"
   data5 = "tranquility, provide for the common defence, promote"
   data6 = "the general welfare, and serure the blessings of liberty"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name)

   #
   #   Done this way to get rid of light crawler in an easy way.
   #
   yy.api_sc_create(collection=collection_name, based_on='default-push')
   yy.api_repository_update(xmlfile=cfile)

#####################################################################

   print "#"
   print "#############################################################"
   print "#"

   print tname, ":   CASE 1"
   print tname, ":      Initial enqueue"
   explist = [fullurl]
   dopartone("0", url, data1, collection_name, "main")
   xx.wait_for_idle(collection=collection_name)
   resp = yy.api_qsearch(source=collection_name, query="", filename="blah")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0
   filename = yy.look_for_file(filename='blah')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   ret = yy.check_list(explist, urllist)
   print tname, ":  urlcount", urlcount
   if ( ret != 0 or urlcount != 1 ):
      fail += 1
      print tname, ":  CASE FAILED"
   else:
      print tname, ":  CASE PASSED"

   print "#"
   print "#############################################################"
   print "#"

   print tname, ":   CASE 2"
   print tname, ":      Enqueue for add-to using same url as CASE 1"
   explist = [fullurl]
   doparttwo("0", url, data2, collection_name, "added")
   xx.wait_for_idle(collection=collection_name)
   resp = yy.api_qsearch(source=collection_name, query="", filename="munchy")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0
   filename = yy.look_for_file(filename='munchy')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   print tname, ":  Primary list check for case 2"
   ret = yy.check_list(explist, urllist)
   print tname, ":  urlcount", urlcount
   if ( ret != 0 or urlcount != 1 ):
      fail += 1
      print tname, ":  CASE FAILED"
   else:
      print tname, ":  CASE PASSED"

   print "#"
   print "#############################################################"
   print "#"

   print tname, ":   CASE 3"
   print tname, ":      Redo the Initial enqueue"
   explist = [fullurl]
   dopartone("0", url, data1, collection_name, "main")
   xx.wait_for_idle(collection=collection_name)
   resp = yy.api_qsearch(source=collection_name, query="", filename="blah")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0

   filename = yy.look_for_file(filename='blah')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   ret = yy.check_list(explist, urllist)
   print tname, ":  urlcount", urlcount
   if ( ret != 0 or urlcount != 1 ):
      fail += 1
      print tname, ":  CASE FAILED"
   else:
      print tname, ":  CASE PASSED"

   print "#"
   print "#############################################################"
   print "#"

   print tname, ":   CASE 4"
   print tname, ":      Initial enqueue of another url"
   explist = [fullurl, fullurl2]
   dopartone("1", url3, data3, collection_name, "main")
   xx.wait_for_idle(collection=collection_name)
   resp = yy.api_qsearch(source=collection_name, query="", filename="blah")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0
   filename = yy.look_for_file(filename='blah')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   ret = yy.check_list(explist, urllist)
   print tname, ":  urlcount", urlcount
   if ( ret != 0 or urlcount != 2 ):
      fail += 1
      print tname, ":  CASE FAILED(part 1)"
   else:
      print tname, ":  CASE PASSED(part 1)"

   explist = [fullurl2]
   resp = yy.api_qsearch(source=collection_name, query="people",
                         filename="blah")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0
   filename = yy.look_for_file(filename='blah')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   ret = yy.check_list(explist, urllist)
   print tname, ":  urlcount", urlcount
   if ( ret != 0 or urlcount != 1 ):
      fail += 1
      print tname, ":  CASE FAILED(part 2)"
   else:
      print tname, ":  CASE PASSED(part 2)"

   print "#"
   print "#############################################################"
   print "#"

   print tname, ":   CASE 5"
   print tname, ":      add-to enqueue of another url, added to Case 4 data"
   explist = [fullurl, fullurl2]
   doparttwo("1", url4, data4, collection_name, "added")
   xx.wait_for_idle(collection=collection_name)
   resp = yy.api_qsearch(source=collection_name, query="", filename="blah")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0
   filename = yy.look_for_file(filename='blah')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   ret = yy.check_list(explist, urllist)
   print tname, ":  urlcount", urlcount
   if ( ret != 0 or urlcount != 2 ):
      fail += 1
      print tname, ":  CASE FAILED(part 1)"
   else:
      print tname, ":  CASE PASSED(part 1)"

   explist = [fullurl2]
   resp = yy.api_qsearch(source=collection_name, query="domestic",
                         filename="blah")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0
   filename = yy.look_for_file(filename='blah')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   ret = yy.check_list(explist, urllist)
   print tname, ":  urlcount", urlcount
   if ( ret != 0 or urlcount != 1 ):
      fail += 1
      print tname, ":  CASE FAILED(part 2)"
   else:
      print tname, ":  CASE PASSED(part 2)"

   print "#"
   print "#############################################################"
   print "#"

   print tname, ":   CASE 6"
   print tname, ":      add-to enqueue of another url, added to Case 4 data"
   explist = [fullurl, fullurl2]
   doparttwo("1", url5, data5, collection_name, "addmore")
   xx.wait_for_idle(collection=collection_name)
   resp = yy.api_qsearch(source=collection_name, query="", filename="blah")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0
   filename = yy.look_for_file(filename='blah')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   ret = yy.check_list(explist, urllist)
   print tname, ":  urlcount", urlcount
   if ( ret != 0 or urlcount != 2 ):
      fail += 1
      print tname, ":  CASE FAILED(part 1)"
   else:
      print tname, ":  CASE PASSED(part 1)"

   explist = [fullurl2]
   resp = yy.api_qsearch(source=collection_name, query="tranquility",
                         filename="blah")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0
   filename = yy.look_for_file(filename='blah')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   ret = yy.check_list(explist, urllist)
   print tname, ":  urlcount", urlcount
   if ( ret != 0 or urlcount != 1 ):
      fail += 1
      print tname, ":  CASE FAILED(part 2)"
   else:
      print tname, ":  CASE PASSED(part 2)"

   print "#"
   print "#############################################################"
   print "#"

   print tname, ":   CASE 7"
   print tname, ":      Enqueue for add-to using same url as CASE 1"
   explist = [fullurl, fullurl2]
   doparttwo("0", url, data2, collection_name, "addmore")
   xx.wait_for_idle(collection=collection_name)
   resp = yy.api_qsearch(source=collection_name, query="", filename="blah")
   try:
      urlcount = yy.getTotalResults(resptree=resp)
   except:
      urlcount = 0
   filename = yy.look_for_file(filename='blah')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   ret = yy.check_list(explist, urllist)
   print tname, ":  urlcount", urlcount
   if ( ret != 0 or urlcount != 2 ):
      fail += 1
      print tname, ":  CASE FAILED"
   else:
      print tname, ":  CASE PASSED"

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
