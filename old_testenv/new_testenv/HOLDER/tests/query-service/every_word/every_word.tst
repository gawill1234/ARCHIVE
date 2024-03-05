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

def build_must_have():

   filelist = ['proof.html']

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
      print tname, ":  FAIL, proof.html not found in urllist"

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
   print tname, ":  query for every word in proof.html"

   failure = 0

   failure = failure + QueryThis(xx=xx, queryString="Wine",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="merchant",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="caterer",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="Tony",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="Beach",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="is",
                       count=31, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="present",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="at",
                       count=7, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="an",
                       count=25, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="outdoor",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="gala",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="when",
                       count=8, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="accident",
                       count=7, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="takes",
                       count=8, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="lives",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="many",
                       count=3, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="guests",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="including",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="a",
                       count=38, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="horse",
                       count=18, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="owning",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="horse-owning",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="1984",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="Arab",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="Sheik",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="thus",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="begins",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="begin",
                       count=2, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="envelopment",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="case",
                       count=5, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="counterfeit",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="liquors",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="and",
                       count=32, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="murder",
                       count=6, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="an",
                       count=25, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="the",
                       count=38, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="of",
                       count=36, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="in",
                       count=28, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="Proof",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="counterfeit liquors",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="Arab Sheik",
                       count=1, expvals=must_have)
   failure = failure + QueryThis(xx=xx, queryString="horse-owning Arab Sheik",
                       count=1, expvals=must_have)
   
   #
   #   Query the whole text of the proof.html document.
   #
   qs = "Wine merchant and caterer Tony Beach is present at an outdoor gala when an accident takes the lives of many guests including a horse-owning Arab Sheik And thus begins Tonys envelopment in a case of counterfeit liquor and murder"
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
