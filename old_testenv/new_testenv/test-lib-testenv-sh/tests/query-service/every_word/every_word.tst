#!/usr/bin/python

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

def build_must_have():

   filelist = ['muffler.html']

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

def is_in_list(xx=None, expvals=None, listtocheck=None):

   result = False

   for item in expvals:
      found = False
      for nitem in listtocheck:
         if ( xx.TENV.targetos == "windows" ):
            iteml = item.lower()
            niteml = nitem.lower()
            if ( iteml == niteml ):
               found = True
         else:
            if ( item == nitem ):
               found = True
         if ( found ):
            result = True

   return result

def QueryThis(xx=None, queryString=None, count=0, expvals=[]):

   failure = 0
   print tname, ":  ==================================================="

   yy.api_qsearch(xx=xx, source=collection_name,
                       query=queryString,
                       filename='qry2', qsyn='Default', num=200)

   urlcount = int(yy.get_query_data(xx=xx, filename='qry2.wazzat',
                                 trib="query-url-count"))
   print '%(tname)s :  URL COUNT (\"%(qs)s\") :           %(cnt)d' % \
          {'tname': tname, 'qs':queryString, 'cnt':urlcount}
   if ( urlcount != count ):
      failure = failure + 1
      print tname, ":  FAIL, Expected a urlcount of", count

   filename = yy.look_for_file(filename='qry2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
   urllist = fix_url_list(urllist)

   ret = is_in_list(xx=xx, expvals=must_have, listtocheck=urllist)
   if ( ret == False ):
      failure = failure + 1
      print tname, ":  FAIL, muffler.html not found in urllist"

   print tname, ":  ==================================================="

   return failure

if __name__ == "__main__":

   collection_name = "example-metadata"
   tname = 'every_word'

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
   must_have = build_must_have()

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

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     FAIL, Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  #######################################"
   print tname, ":  CASE 2"
   print tname, ":  query for every word in muffler.html"

   failure = 0

   failure = failure + QueryThis(xx=xx, queryString="Jodie",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="is",
                       count=23, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="loud",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="very",
                       count=4, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="but",
                       count=8, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="that",
                       count=21, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="what",
                       count=7, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="it",
                       count=13, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="takes",
                       count=7, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="to",
                       count=31, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="be",
                       count=6, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="the",
                       count=41, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="number",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="one",
                       count=5, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="sales",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="associate",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="at",
                       count=11, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="Deal-Em",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="Motors",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="used",
                       count=5, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="car",
                       count=21, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="lot",
                       count=4, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="in",
                       count=31, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="state",
                       count=5, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="world",
                       count=4, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="turned",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="upside-down",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="when",
                       count=17, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="owner",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="old man Winslow",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="dies",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="and",
                       count=36, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="leaves",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="dealership",
                       count=3, expvals=must_have)
   # Removed "a" search to accomodate qa-one-hour test that
   # runs in a such environment where all urls include "a" token 
   #failure = failure + QueryThis(xx=xx, queryString="a",
   #                    count=32, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="monastery",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="has",
                       count=12, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="taken",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="vow",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="of",
                       count=37, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="silence",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="hilarity",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="follow",
                       count=4, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="as",
                       count=15, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="tries",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="keep",
                       count=3, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="doors",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="open",
                       count=4, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="her",
                       count=6, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="mouth",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="shut",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="vow of silence",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="Hilarity follows",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="as Jodie tries to keep the doors open",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="and her mouth shut upside-down",
                       count=1, expvals=must_have)
   
   #
   #   Query the whole text of the muffler.html document.
   #
   qs = "Jodie is loud, very loud, but that is what it takes to be the number one sales associate at Deal-Em Motors, the number one used car lot in the state. But Jodie's world is turned upside-down when the owner, old man Winslow, dies and leaves the dealership to a monastery that has taken a vow of silence. Hilarity follows as Jodie tries to keep the doors open and her mouth shut."
   failure = failure + QueryThis(xx=xx, queryString=qs,
                       count=1, expvals=must_have)
   #failure = failure + QueryThis(xx=xx, queryString="By",
   #                    count=1, expvals=must_have)
   #failure = failure + QueryThis(xx=xx, queryString="Dick",
   #                    count=1, expvals=must_have)
   #failure = failure + QueryThis(xx=xx, queryString="Francis",
   #                    count=1, expvals=must_have)

   print tname, ":  #######################################"

   xx.stop_crawl(collection=collection_name, force=1)
   xx.stop_indexing(collection=collection_name, force=1)

   if ( cs_pass == 2 and failure == 0):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
