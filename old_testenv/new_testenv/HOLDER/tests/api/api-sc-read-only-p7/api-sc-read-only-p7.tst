#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import random
import multi_verse
import build_schema_node
from threading import Thread
from lxml import etree

def check_cb_status(waitforstatus=None):

   err = 0
   i = 0

   seefoo = yy.api_cb_status()
   crostat = yy.getResultGenericTagValue(resptree=seefoo,
                                tagname='collection-broker-status-response',
                                attrname='status')

   while ( ( crostat != waitforstatus ) and
           ( i < 100 ) ):
      time.sleep(5)
      seefoo = yy.api_cb_status()
      crostat = yy.getResultGenericTagValue(resptree=seefoo,
                                tagname='collection-broker-status-response',
                                attrname='status')
      i += 1

   print tname, ":   Current collection broker run status,", crostat
   if ( crostat != waitforstatus ):
      print tname, ":  Collection broker failed to change state to", waitforstatus
      print tname, ":  It has been waiting for 10 minutes"
      print tname, ":  Test Failed"
      sys.exit(1)
   else:
      err = i

   return err

def gen_collection_list(maxcollections=12):

   collection_list = []

   i = 1
   while ( i <= maxcollections ):
      colname = ''.join(['scro_p7_', '%s' % i])
      collection_list.append(colname)
      i += 1

   print collection_list

   return collection_list

def check_ro_status(collection=None, whichstatus=None):

   global fail, done

   err = 0
   i = 0

   if ( whichstatus == 'disabled' ):
      otherstatus = 'enabled'
   else:
      otherstatus = 'disabled'

   seefoo = yy.api_sc_read_only(collection=cname, mode='status')
   crostat = yy.getResultGenericTagValue(resptree=seefoo,
                                         tagname='read-only-state',
                                         attrname='mode')

   while ( ( crostat == whichstatus or crostat == 'pending' ) and
           ( i < 15 ) ):
      time.sleep(1)
      seefoo = yy.api_sc_read_only(collection=cname, mode='status')
      crostat = yy.getResultGenericTagValue(resptree=seefoo,
                                            tagname='read-only-state',
                                            attrname='mode')
      i += 1

   print tname, ":  final read only status for", collection
   print tname, ":     Expected:", otherstatus
   print tname, ":     Actual  :", crostat

   if ( crostat != otherstatus ):
      err = 1
      fail += 1
      done = 1

   return err

if __name__ == "__main__":

   global done, fail

   collection_name = "scro_p7"
   tname = "api_sc_read_only_p7"

   g = random.Random(time.time())

   fail = done = 0
   #
   #   If this variable is 1, it will cause
   #   collection-broker-enqueue-xml to be used.  If it is
   #   0, normal old enqueue-xml will be used.
   #
   cbex = 1

   num_collections = 10
   check_which = g.randint(0, num_collections - 1)

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   #
   #   Make sure collection broker is in default configuration.
   #
   if ( cbex == 1 ):
      #
      #   Reset the collection broker back to defaults and restart
      #
      cbcfg = build_schema_node.create_cb_config()

      yy.api_cb_set(xmlnode=cbcfg)

      yy.api_cb_stop()
      check_cb_status(waitforstatus='stopped')

      yy.api_cb_start()
      check_cb_status(waitforstatus='running')

      #
      #   Give the collection broker time to figure out what is up.
      #
      time.sleep(20)

      yy.api_cb_get(filename='cb_back_to_default')
      yy.api_cb_status(filename='cb_reset_status_1')

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  read only all, go immediately to data push"

   collection_list = gen_collection_list(maxcollections=num_collections)
   check_collection = collection_list[check_which]

   #
   #   If the collections exist, delete them
   #
   for cname in collection_list:
      cex = xx.collection_exists(collection=cname)
      if ( cex == 1 ):
         xx.delete_collection(collection=cname)

   #
   #   Create the collections
   #
   cList = []
   for cname in collection_list:
      cc = multi_verse.ThreadedCreate(collection=cname, usecb=cbex)
      cList.append(cc)
      cc.start()

   for item in cList:
      item.join()

   #
   #   Enqueue 500 items in each of the collections
   #
   eList = []
   for cname in collection_list:
      ee = multi_verse.ThreadedEnqueue(collection=cname, eCount=2500,
                                       basedir='/testenv/test_data/law/F2',
                                       usesynchro='enqueued', usecb=cbex)
      eList.append(ee)
      ee.start()

   for item in eList:
      item.join(180)

   time.sleep(3)
   #for item in collection_list:
   #   print tname, ":  TOP WAIT #########################################"
   #   print tname, ":  Wait for collection", item
   #   xx.wait_for_idle(collection=item)
   #   print tname, ":  ##################################################"

   err1 = err2 = err3 = err4 = err5 = 0

   #for cname in collection_list:
   #   try:
   #      err=yy.api_sc_indexer_full_merge(collection=cname,
   #                                       subc='live')
   #   except:
   #      print tname, ":  full merge error but continuing"

   #
   #   Put the collections in read only mode
   #
   try:
      yy.api_sc_read_only_all(mode='enable')
   except:
      print tname, ":  One or more read only enables failed"

   for cname in collection_list:
      err1 = err1 + check_ro_status(collection=cname, whichstatus='disabled')

   if ( err1 != 0 ):
      print tname, ":  read only failure count =", err1

   #
   #   Get initial check data.  This should not change
   #
   resp = yy.api_qsearch(xx=xx, source=check_collection, query='')
   idxdcnt1 = yy.getTotalResults(resptree=resp)

   #stattree = yy.api_sc_status(collection=check_collection, subc='live')
   #mrgwritten = yy.getResultGenericTagIntAttrTotal(resptree=stattree,
   #                                       tagname='vse-index-merge-status',
   #                                       attrname='written')
   #mrgflcnt = yy.getResultGenericTagCount(resptree=stattree,
   #                                        tagname='vse-index-file',
   #                                        attrname='fname')

   #time.sleep(30)

   #
   #   Get secondary check data.  This should be the same as the
   #   initial data if read-only mode took
   #
   resp = yy.api_qsearch(xx=xx, source=check_collection, query='')
   idxdcnt2 = yy.getTotalResults(resptree=resp)

   #stattree = yy.api_sc_status(collection=check_collection, subc='live')
   #mrgwritten2 = yy.getResultGenericTagIntAttrTotal(resptree=stattree,
   #                                       tagname='vse-index-merge-status',
   #                                       attrname='written')
   #mrgflcnt2 = yy.getResultGenericTagCount(resptree=stattree,
   #                                        tagname='vse-index-file',
   #                                        attrname='fname')

   #print tname, ":   ########################################"
   #print tname, ":   Query/Data collection,", check_collection
   #print tname, ":     File counts, ", mrgflcnt, mrgflcnt2
   #print tname, ":     Write counts,", mrgwritten, mrgwritten2
   #if ( mrgwritten != mrgwritten2 and mrgflcnt != mrgflcnt2 ):
   #   err2 = 1
   #   print tname, ":     Read-only in merge failed"

   print tname, ":     Query counts,", idxdcnt1, idxdcnt2
   if ( idxdcnt1 != idxdcnt2 ):
      err3 = 1
      print tname, ":     Query failed"
   print tname, ":   ########################################"

   time.sleep(10)

   #
   #   Disable read only mode
   #
   try:
      yy.api_sc_read_only_all(mode='disable')
   except:
      print tname, ":  One or more read only disables failed"

   for cname in collection_list:
      err4 = err4 + check_ro_status(collection=cname, whichstatus='enabled')

   if ( err4 != 0 ):
      print tname, ":  read only failure count =", err4
      print tname, ":  Test Failed"
      yy.api_cb_stop()
      xx.kill_all_services()
      sys.exit(1)


   #
   #   Enqueue 200 more items per collection
   #
   eList = []
   for cname in collection_list:
      ee = multi_verse.ThreadedEnqueue(collection=cname, eCount=200,
                                       basedir='/testenv/test_data/law/US',
                                       usesynchro='enqueued', usecb=cbex)
      eList.append(ee)
      ee.start()

   for item in eList:
      item.join(180)

   #
   #   Wait for the collections to go idle
   #
   for item in collection_list:
      print tname, ":  BOTTOM WAIT ######################################"
      print tname, ":  Wait for collection", item
      xx.wait_for_idle(collection=item, usecb=cbex)
      print tname, ":  ##################################################"

   #
   #   Query the collections to make sure all of the data made it.
   #
   qList2 = []
   for item in collection_list:
      if ( cbex == 0 ):
         resp = yy.api_qsearch(xx=xx, source=item,
                               query='', num=10000)
      else:
         resp = yy.api_cb_search(xx=xx, source=item,
                               query='', num=10000)
      idxdcnt1 = yy.getTotalResults(resptree=resp)
      qList2.append(idxdcnt1)

   expcount = 2789
   i = 0
   for item in qList2:
      print tname, ":   Collection size of collection", i + 1
      print tname, ":      Expected, ", expcount
      print tname, ":      Actual,   ", item
      if ( expcount != item ):
         err5 += 1
         print tname, ":      Collection size is wrong"
      i += 1

   print tname, ":   Section one result, enable read only mode"
   if ( err1 == 0 ):
      print tname, ":      Section one passed"
   else:
      print tname, ":      Section one failed"
   print tname, ":   Section two result, initial query results correct"
   if ( err2 == 0 ):
      print tname, ":      Section two passed"
   else:
      print tname, ":      Section two failed"
   print tname, ":   Section three result, interim query results correct"
   if ( err3 == 0 ):
      print tname, ":      Section three passed"
   else:
      print tname, ":      Section three failed"
   print tname, ":   Section four result, disable read only mode"
   if ( err4 == 0 ):
      print tname, ":      Section four passed"
   else:
      print tname, ":      Section four failed"
   print tname, ":   Section five result, final query results correct"
   if ( err5 == 0 ):
      print tname, ":      Section five passed"
   else:
      print tname, ":      Section five failed"

   yy.api_cb_status(filename='cb_reset_status_2')

   err = err1 + err2 + err3 + err4 + err5

   print tname, ":  time before all services stopped -"
   print tname, ":    ", time.strftime("%Y-%m-%d %H:%M:%S")

   xx.kill_all_services()

   if ( err == 0 ):
      for cname in collection_list:
         xx.delete_collection(collection=cname)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
