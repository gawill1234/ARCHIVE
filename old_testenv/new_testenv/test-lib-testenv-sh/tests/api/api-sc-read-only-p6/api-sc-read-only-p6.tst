#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
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

   #
   #   This loop represents an approximate wait of 10 minutes for the
   #   collection broker to change state.  If it takes longer than that
   #   I think we've got a problem in the cb.
   #
   #   5 * 100 = 500 seconds plus the time to get status and stuff like
   #   that.
   #
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
      colname = ''.join(['scro_p6_', '%s' % i])
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

   collection_name = "scro_p6"
   tname = "api_sc_read_only_p6"

   fail = done = 0
   #
   #   If this variable is 1, it will cause
   #   collection-broker-enqueue-xml to be used.  If it is
   #   0, normal old enqueue-xml will be used.
   #
   cbex = 1

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  read only all, go immediately to data push"

   collection_list = gen_collection_list(maxcollections=20)

   #
   #   If the collections exist, delete them
   #
   for cname in collection_list:
      cex = xx.collection_exists(collection=cname)
      if ( cex == 1 ):
         xx.delete_collection(collection=cname)

   #
   #   Configure and start the collection broker
   #   This config should force everything to the offline queue.
   #
   if ( cbex == 1 ):
      cbcfg = build_schema_node.create_cb_config(maximum_collections='0',
                                       always_allow_one_collection='false')

      yy.api_cb_set(xmlnode=cbcfg)

      yy.api_cb_stop()
      check_cb_status(waitforstatus='stopped')

      yy.api_cb_start()
      check_cb_status(waitforstatus='running')

      yy.api_cb_get(filename='cb_first_pos')
   else:
      yy.api_cb_stop()
      check_cb_status(waitforstatus='stopped')

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

   time.sleep(2)

   #
   #   Enqueue 500 items in each of hte collections
   #
   eList = []
   for cname in collection_list:
      ee = multi_verse.ThreadedEnqueue(collection=cname, eCount=500,
                                       basedir='/testenv/test_data/law/F2',
                                       usesynchro='enqueued', usecb=cbex)
      eList.append(ee)
      ee.start()

   for item in eList:
      item.join(180)

   err1 = err2 = err3 = err4 = err5 = 0

   #
   #   Put the collections in read only mode
   #
   print tname, ":  Line 169, enable read only for all"
   try:
      yy.api_sc_read_only_all(mode='enable')
   except:
      print tname, ":  One or more read only enables failed"
   for cname in collection_list:
      err1 = err1 + check_ro_status(collection=cname, whichstatus='disabled')

   if ( err1 != 0 ):
      print tname, ":  read only failure count =", err1

   #
   #   Query the collections to make sure all of the data made it.
   #
   qList = []
   print tname, ":  Line 183, query search to check read only"
   for item in collection_list:
      resp = yy.api_qsearch(xx=xx, source=item,
                            query='', num=10000)
      idxdcnt1 = yy.getTotalResults(resptree=resp)
      qList.append(idxdcnt1)
      if ( idxdcnt1 != 0 ):
         err2 = 1
         print tname, ":   Error on enqueue with collection broker"
         print tname, ":      Expected results, 0"
         print tname, ":      Actual results  ,", idxdcnt1

   time.sleep(30)

   i = 0
   print tname, ":  Line 197, query search to check read only"
   for item in collection_list:
      resp = yy.api_qsearch(xx=xx, source=item,
                            query='', num=10000)
      idxdcnt1 = yy.getTotalResults(resptree=resp)
      if ( idxdcnt1 != qList[i] ):
         err3 = 1
         print tname, ":   Error on enqueue with collection broker"
         print tname, ":   Data is being added when it should not be"
         print tname, ":      Expected results,", qList[i]
         print tname, ":      Actual results  ,", idxdcnt1
      i += 1

   if ( err3 != 0 ):
      print tname, ":  read only failure count =", err3
      print tname, ":  Test Failed, bailed out at err3"
      yy.api_cb_stop()
      sys.exit(1)

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

   #
   #   Disable read only mode
   #
   print tname, ":  Line 239 marker, disable read only for all"
   try:
      yy.api_sc_read_only_all(mode='disable')
   except:
      print tname, ":  One or more read only disables failed"

   for cname in collection_list:
      err4 = err4 + check_ro_status(collection=cname, whichstatus='enabled')

   if ( err4 != 0 ):
      print tname, ":  read only failure count =", err4
      print tname, ":  Test Failed, bailed out at err4"
      if ( cbex == 1 ):
         yy.api_cb_stop()
      sys.exit(1)


   #
   #   Enqueue 200 more items per collection
   #
   print tname, ":  Line 258, 200 item enqueue begin marker"
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
      print tname, ":  ##################################################"
      print tname, ":  Wait for collection", item
      xx.wait_for_idle(collection=item)
      print tname, ":  ##################################################"

   #
   #   Query the collections to make sure all of the data made it.
   #
   qList2 = []
   print tname, ":  Line 286, query search"
   for item in collection_list:
      resp = yy.api_qsearch(xx=xx, source=item,
                            query='', num=10000)
      idxdcnt1 = yy.getTotalResults(resptree=resp)
      qList2.append(idxdcnt1)

   expcount = 702
   i = 0
   for item in qList2:
      print tname, ":   Size of collection,", i
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

   if ( cbex == 1 ):
      yy.api_cb_status(filename='cb_reset_status_2')

   err = err1 + err2 + err3 + err4 + err5

   xx.kill_all_services()

   if ( err == 0 ):
      for cname in collection_list:
         xx.delete_collection(collection=cname)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
