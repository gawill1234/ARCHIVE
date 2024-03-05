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
      'off_road.html',
      'presidential_state_cars.html',
      'roadside_reports.html',
      'second_right.html',
      'singers_and_cars.html',
      'slow_leak.html',
      'stars_and_cars.html',
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
   tname = 'not_test-1'

   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  NOT/OR queries"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.5)

   explist = build_exp_list()

   #for item in explist:
   #   print item


   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  #######################################"
   print tname, ":  NOT/OR test"
   print tname, ":     All of the queries in this test should"
   print tname, ":     yield identical results using the"
   print tname, ":     example-metadata collection"

   print tname, ":  #######################################"
   print tname, ":  CASE 1"
   print tname, ":  NOT/OR test -(jodie OR wyke)"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='-(jodie OR wyke)',
                       filename='not1', qsyn='Default', num=200)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=41, num=41, filename='not1',
                      testname=tname)

   filename = yy.look_for_file(filename='not1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   urllist = fix_url_list(urllist)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 2"
   print tname, ":  NOT/OR test -(jodie OR wyke) OR jfjjfkjfkjiksdjfo"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='-(jodie OR wyke) OR jfjjfkjfkjiksdjfo',
                       filename='not2', qsyn='Default', num=200)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
                      clustercount=0, perpage=41, num=41, filename='not2',
                      testname=tname)

   filename = yy.look_for_file(filename='not2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   urllist = fix_url_list(urllist)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 3"
   print tname, ":  NOT/OR test -jodie AND -wyke"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='-jodie AND -wyke',
                       filename='not3', qsyn='Default', num=200)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      clustercount=0, perpage=41, num=41, filename='not3',
                      testname=tname)

   filename = yy.look_for_file(filename='not3')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   urllist = fix_url_list(urllist)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 4"
   print tname, ":  NOT/OR test  NOT jodie AND NOT wyke"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='NOT jodie AND NOT wyke',
                       filename='not4', qsyn='Default', num=200)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
                      clustercount=0, perpage=41, num=41, filename='not4',
                      testname=tname)

   filename = yy.look_for_file(filename='not4')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   urllist = fix_url_list(urllist)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 5"
   print tname, ":  NOT/OR test NOT (jodie OR wyke)"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='NOT (jodie OR wyke)',
                       filename='not5', qsyn='Default', num=200)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5,
                      clustercount=0, perpage=41, num=41, filename='not5',
                      testname=tname)

   filename = yy.look_for_file(filename='not5')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   urllist = fix_url_list(urllist)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 6"
   print tname, ":  NOT/OR test NOT (jodie OR wyke) OR jfjjfkjfkjiksdjfo"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='NOT (jodie OR wyke) OR jfjjfkjfkjiksdjfo',
                       filename='not6', qsyn='Default', num=200)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,
                      clustercount=0, perpage=41, num=41, filename='not6',
                      testname=tname)

   filename = yy.look_for_file(filename='not6')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   urllist = fix_url_list(urllist)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   xx.stop_crawl(collection=collection_name, force=1)
   xx.stop_indexing(collection=collection_name, force=1)

   if ( cs_pass == 12 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
