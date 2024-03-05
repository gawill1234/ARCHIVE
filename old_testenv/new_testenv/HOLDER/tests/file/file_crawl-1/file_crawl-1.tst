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
         item = item.replace('%20', ' ')
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
   tname = 'file_crawl-1'

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

   #for item in explist:
   #   print item


   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  #######################################"
   print tname, ":  Crawl files"
   print tname, ":     Uses the example metadata to have"
   print tname, ":     consistently available files on all"
   print tname, ":     platforms"

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
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   xx.stop_crawl(collection=collection_name, force=1)
   xx.stop_indexing(collection=collection_name, force=1)

   if ( cs_pass == 2 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
