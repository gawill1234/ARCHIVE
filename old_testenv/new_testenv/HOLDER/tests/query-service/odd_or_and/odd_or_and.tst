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
      '10_lb_penalty.html', 
      'banker.html', 
      'blood_sport.html', 
      'bolt.html', 
      'bonecrack.html', 
      'break_in.html', 
      'come_to_grief.html', 
      'comeback.html', 
      'decider.html', 
      'driving_force.html', 
      'enquiry.html', 
      'field_of_thirteen.html', 
      'flying_finish.html', 
      'for_kicks.html', 
      'forfeit.html', 
      'high_stakes.html', 
      'hot_money.html', 
      'in_the_frame.html', 
      'index.html', 
      'knockdown.html', 
      'lester.html', 
      'longshot.html', 
      'nerve.html', 
      'odds_against.html', 
      'proof.html', 
      'rat_race.html', 
      'reflex.html', 
      'risk.html', 
      'second_wind.html', 
      'shattered.html', 
      'slayride.html', 
      'smokescreen.html', 
      'sport_of_queens.html', 
      'straight.html', 
      'the_danger.html', 
      'the_edge.html', 
      'trial_run.html', 
      'twice_shy.html', 
      'under_orders.html', 
      'whip_hand.html', 
      'wild_horses.html',
      'dead_cert.html',
      'to_the_hilt.html']

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
                       query='the',
                       filename='qry2', qsyn='Default', num=200)

   urlcount1 = int(yy.get_query_data(xx=xx, filename='qry2.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='the OR (horse jockey)',
                       filename='qry3', qsyn='Default', num=200)

   urlcount2 = int(yy.get_query_data(xx=xx, filename='qry3.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='the OR (horse AND jockey)',
                       filename='qry4', qsyn='Default', num=200)

   urlcount3 = int(yy.get_query_data(xx=xx, filename='qry4.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='(horse AND jockey)',
                       filename='qry5', qsyn='Default', num=200)

   urlcount4 = int(yy.get_query_data(xx=xx, filename='qry5.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='horse',
                       filename='qry6', qsyn='Default', num=200)

   urlcount5 = int(yy.get_query_data(xx=xx, filename='qry6.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='jockey',
                       filename='qry7', qsyn='Default', num=200)

   urlcount6 = int(yy.get_query_data(xx=xx, filename='qry7.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='horse',
                       filename='qry8', qsyn='Default', num=200)

   urlcount7 = int(yy.get_query_data(xx=xx, filename='qry8.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='jockey',
                       filename='qry9', qsyn='Default', num=200)

   urlcount8 = int(yy.get_query_data(xx=xx, filename='qry9.wazzat',
                                 trib="query-url-count"))

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='horse AND jockey',
                       filename='qry10', qsyn='Default', num=200)

   urlcount9 = int(yy.get_query_data(xx=xx, filename='qry10.wazzat',
                                 trib="query-url-count"))
   print tname, ":  #######################################"

   print tname, ":  URL COUNT 1(\"the\"):                        ", urlcount1
   print tname, ":  URL COUNT 2(\"the OR (horse jockey)\"):      ", urlcount2
   print tname, ":  URL COUNT 3(\"the OR (horse AND jockey)\"):  ", urlcount3
   print tname, ":  URL COUNT 4(\"(horse AND jockey)\"):         ", urlcount4
   print tname, ":  URL COUNT 9(\"horse AND jockey\"):           ", urlcount9
   print tname, ":  URL COUNT 5(\"horse\"):                      ", urlcount5
   print tname, ":  URL COUNT 6(\"jockey\"):                     ", urlcount6
   print tname, ":  URL COUNT 7(\"(horse)\"):                    ", urlcount7
   print tname, ":  URL COUNT 8(\"(jockey)\"):                   ", urlcount8

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

   if (urlcount1 != 38):
      print tname, ":  query of the failed"
      print tname, ":  URL COUNT 1 should be = 38"
      failure = 1

   if (urlcount2 != 39):
      print tname, ":  query of \"the OR (horse jockey)\" failed"
      print tname, ":  URL COUNT 2 should be = 39"
      failure = 1

   if (urlcount9 != 6):
      print tname, ":  query of \"horse AND jockey\" failed"
      print tname, ":  URL COUNT 9 should be = 6"
      failure = 1

   if (urlcount7 != 18):
      print tname, ":  query of \"(horse)\" failed"
      print tname, ":  URL COUNT 7 should be = 18"
      failure = 1

   if (urlcount8 != 18):
      print tname, ":  query of \"(jockey)\" failed"
      print tname, ":  URL COUNT 8 should be = 18"
      failure = 1

   xx.stop_crawl(collection=collection_name, force=1)
   xx.stop_indexing(collection=collection_name, force=1)

   if ( cs_pass == 2 and failure == 0):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
