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
      'wild_horses.html']

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
   print tname, ":  NOT/OR test -(york OR kinloch)"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='-(york OR kinloch)',
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
   print tname, ":  NOT/OR test -(york OR kinloch) OR jfjjfkjfkjiksdjfo"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='-(york OR kinloch) OR jfjjfkjfkjiksdjfo',
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
   print tname, ":  NOT/OR test -york AND -kinlock"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='-york AND -kinloch',
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
   print tname, ":  NOT/OR test  NOT york AND NOT kinlock"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='NOT york AND NOT kinloch',
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
   print tname, ":  NOT/OR test NOT (york OR kinloch)"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='NOT (york OR kinloch)',
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
   print tname, ":  NOT/OR test NOT (york OR kinloch) OR jfjjfkjfkjiksdjfo"

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='NOT (york OR kinloch) OR jfjjfkjfkjiksdjfo',
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
