#!/usr/bin/python

#
#   Test of NOT/OR queries which should yield
#   identical results even thought the queries
#   look different.
#

import sys, time, cgi_interface, vapi_interface
import urlparse

def fix_url_list(myurllist):

   newlist = []

   if ( xx.TENV.targetos == "windows" ):
      for item in myurllist:
         item = item.replace('%3a', ':')
         item = item.replace('%5c', '/')
         newlist.append(item)
      return(newlist)

   return myurllist

def build_exp_list():

   filelist = [
      '400.html',
      'blowout.html',
      'broke_down.html',
      'broken_mirror.html',
      'classic_autos.html',
      'classic_deception.html',
      'cold_hand.html',
      'dealership_dramas.html',
      'dealers.html',
      'drivers_side.html',
      'driving_glove.html',
      'from_detroit.html',
      'from_italy.html',
      'from_japan.html',
      'from_mexico.html',
      'historic_gas_stations.html',
      'index.html',
      'lemon.html',
      'lonely_digits.html',
      'lug_nuts.html',
      'manx.html',
      'mechanics_memoirs.html',
      'mille_miglia.html',
      'missed_signal.html',
      'monte_carlo.html',
      'mort_prix.html',
      'movie_cars.html',
      'muffler.html',
      'off_road.html',
      'presidential_state_cars.html',
      'roadside_reports.html',
      'second_right.html',
      'singers_and_cars.html',
      'slow_leak.html',
      'stars_and_cars.html',
      'sudden_stop.html',
      'tow_truck_tales.html',
      'truck_stop.html',
      'understanding_car_repairs.html',
      'understanding_cars.html',
      'used_lots.html',
      'world_champion.html',
      'writing_turns.html']

   explist = []

   insdir = xx.vivisimo_dir()
   if ( xx.TENV.targetos == "windows" ):
      insdir = insdir.replace('\\', '/')
      fulldir = ''.join(['file:///', insdir, '/examples/data/metadata-example/'])
   else:
      fulldir = ''.join(['file://', insdir, '/examples/data/metadata-example/'])

   for item in filelist:
      thing = ''.join([fulldir, item])
      explist.append(thing)

   return explist


if __name__ == "__main__":

   collection_name = "example-metadata"
   tname = 'odd_or_and'

   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Crawl and query of files on each OS"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.5)

   explist = build_exp_list()

   #print tname, ":     ++++++++++++++++++++++++++++++++++++++"
   #print tname, ":  Expected list"
   #for item in explist:
   #   print item
   #print tname, ":     ++++++++++++++++++++++++++++++++++++++"


   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  #######################################"
   print tname, ":  Crawl files"
   print tname, ":     Uses the example metadata to have"
   print tname, ":     consistently available files on all"
   print tname, ":     platforms"
   print tname, ":  Test for bug 20521"

   print tname, ":  #######################################"
   print tname, ":  CASE 1"
   print tname, ":  blank query"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='',
                       filename='qry1', qsyn='Default', num=200)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=43, num=43, filename='qry1',
                      testname=tname)

   filename = yy.look_for_file(filename='qry1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   urllist = fix_url_list(urllist)

   #print tname, ":     ++++++++++++++++++++++++++++++++++++++"
   #print tname, ":  Result list"
   #for item in urllist:
   #   print item
   #print tname, ":     ++++++++++++++++++++++++++++++++++++++"

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  #######################################"
   print tname, ":  CASE 2"
   print tname, ":  AND/OR query syntax check"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='is',
                       filename='qry2', qsyn='Default', num=200)

   urlcount1 = int(yy.get_query_data(xx=xx, filename='qry2.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='is OR (story continue)',
                       filename='qry3', qsyn='Default', num=200)

   urlcount2 = int(yy.get_query_data(xx=xx, filename='qry3.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='is OR (story AND continue)',
                       filename='qry4', qsyn='Default', num=200)

   urlcount3 = int(yy.get_query_data(xx=xx, filename='qry4.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='(story AND continue)',
                       filename='qry5', qsyn='Default', num=200)

   urlcount4 = int(yy.get_query_data(xx=xx, filename='qry5.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='story',
                       filename='qry6', qsyn='Default', num=200)

   urlcount5 = int(yy.get_query_data(xx=xx, filename='qry6.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='continue',
                       filename='qry7', qsyn='Default', num=200)

   urlcount6 = int(yy.get_query_data(xx=xx, filename='qry7.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='(story)',
                       filename='qry8', qsyn='Default', num=200)

   urlcount7 = int(yy.get_query_data(xx=xx, filename='qry8.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='(continue)',
                       filename='qry9', qsyn='Default', num=200)

   urlcount8 = int(yy.get_query_data(xx=xx, filename='qry9.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='story AND continue',
                       filename='qry10', qsyn='Default', num=200)

   urlcount9 = int(yy.get_query_data(xx=xx, filename='qry10.wazzat',
                                 trib="query-url-count"))
   print tname, ":  #######################################"

   print tname, ":  URL COUNT 1(\"is\"):                        ", urlcount1
   print tname, ":  URL COUNT 2(\"is OR (story continue)\"):      ", urlcount2
   print tname, ":  URL COUNT 3(\"is OR (story AND continue)\"):  ", urlcount3
   print tname, ":  URL COUNT 4(\"(story AND continue)\"):         ", urlcount4
   print tname, ":  URL COUNT 9(\"story AND continue\"):           ", urlcount9
   print tname, ":  URL COUNT 5(\"story\"):                      ", urlcount5
   print tname, ":  URL COUNT 6(\"continue\"):                     ", urlcount6
   print tname, ":  URL COUNT 7(\"(story)\"):                    ", urlcount7
   print tname, ":  URL COUNT 8(\"(continue)\"):                   ", urlcount8

   failure = 0
   if (urlcount2 != urlcount3):
      print tname, ":  Equivalent name query failed"
      print tname, ":  2 should = 3"
      failure = 1

   if (urlcount8 != urlcount6):
      print tname, ":  Equivalent paren query failed"
      print tname, ":  8 should = 6"
      failure = 1

   if (urlcount7 != urlcount5):
      print tname, ":  Equivalent paren query failed"
      print tname, ":  7 should = 5"
      failure = 1

   if (urlcount4 != urlcount9):
      print tname, ":  Equivalent paren query failed"
      print tname, ":  4 should = 9"
      failure = 1

   if (urlcount1 > urlcount2):
      print tname, ":  Larger query failed"
      print tname, ":  2 should be >= 1"
      failure = 1

   if (urlcount1 != 23):
      print tname, ":  query of the failed"
      print tname, ":  URL COUNT 1 should be = 23"
      failure = 1

   if (urlcount2 != 24):
      print tname, ":  query of \"is OR (story continue)\" failed"
      print tname, ":  URL COUNT 2 should be = 24"
      failure = 1

   if (urlcount9 != 1):
      print tname, ":  query of \"story AND continue\" failed"
      print tname, ":  URL COUNT 9 should be = 1"
      failure = 1

   if (urlcount7 != 4):
      print tname, ":  query of \"(story)\" failed"
      print tname, ":  URL COUNT 7 should be = 4"
      failure = 1

   if (urlcount8 != 3):
      print tname, ":  query of \"(continue)\" failed"
      print tname, ":  URL COUNT 8 should be = 3"
      failure = 1

   xx.stop_crawl(collection=collection_name, force=1)
   xx.stop_indexing(collection=collection_name, force=1)

   if ( cs_pass == 2 and failure == 0):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
