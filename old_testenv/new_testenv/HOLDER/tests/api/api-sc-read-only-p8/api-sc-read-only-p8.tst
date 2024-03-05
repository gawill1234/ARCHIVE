#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import random
import multi_verse
import build_schema_node
from threading import Thread
from lxml import etree

def gen_collection_list(maxcollections=12):

   collection_list = []

   i = 1
   while ( i <= maxcollections ):
      colname = ''.join(['scro_p8_', '%s' % i])
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
           ( i < 100 ) ):
      time.sleep(5)
      seefoo = yy.api_sc_read_only(collection=cname, mode='status')
      crostat = yy.getResultGenericTagValue(resptree=seefoo,
                                            tagname='read-only-state',
                                            attrname='mode')
      i += 1

   print tname, ":  final read only status for", collection
   print tname, ":     Expected:", otherstatus
   print tname, ":     Actual  :", crostat

   if ( crostat != otherstatus ):
      print tname, ":  Waiting for read-only status switch failed"
      print tname, ":  Wait time exceeded 10 minutes."
      print tname, ":  Test Failed"
      sys.exit(1)

   return err

if __name__ == "__main__":

   global done, fail

   collection_name = "scro_p8"
   tname = "api_sc_read_only_p8"

   g = random.Random(time.time())

   fail = done = 0
   #
   #   If this variable is 1, it will cause 
   #   collection-broker-enqueue-xml to be used.  If it is
   #   0, normal old enqueue-xml will be used.
   #
   cbex = 0

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   os.environ['VIVEXCONTINUE'] = 'True'

   thing = xx.TENV.target
   crappy = thing.split('.')

   if ( crappy[0] == 'testbed2' ):
      num_collections = 2
   else:
      if ( xx.TENV.targetos == 'windows' ):
         num_collections = 10
      else:
         num_collections = 20

   #
   #   Just in case the stupid collectio broker is running,
   #   make it stop
   #
   yy.api_cb_stop()

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  read only all, go into read-only while doing"
   print tname, ":  multiple enqueues"

   collection_list = gen_collection_list(maxcollections=num_collections)

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
   counter = 0
   for cname in collection_list:
      counter += 1
      cc = multi_verse.ThreadedCreate(collection=cname)
      cList.append(cc)
      cc.start()

   for item in cList:
      counter -= 1
      item.join()

   for item in cList:
      if item.isAlive():
         print "Item is alive in section 1"

   print "Value should be 0.  COUNTER:", counter
      
   #
   #   Enqueue 500 items in each of hte collections
   #
   eList = []
   for cname in collection_list:
      ee = multi_verse.ThreadedEnqueue(collection=cname, eCount=2500,
                                       basedir='/testenv/test_data/law/F2',
                                       usesynchro='enqueued', usecb=cbex)
      eList.append(ee)
      ee.start()

   time.sleep(num_collections + 5)

   err1 = err2 = err3 = err4 = err5 = 0

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
   idxdcnt1 = []
   for item in collection_list:
      resp = yy.api_qsearch(xx=xx, source=item, query='')
      idxdcnt1.append(yy.getTotalResults(resptree=resp))


   time.sleep(30)

   for item in eList:
      item.join(180)

   for item in eList:
      if item.isAlive():
         print "Item is alive in section 2"

   #
   #   Get secondary check data.  This should be the same as the
   #   initial data if read-only mode took
   #
   idxdcnt2 = []
   for item in collection_list:
      resp = yy.api_qsearch(xx=xx, source=item, query='')
      idxdcnt2.append(yy.getTotalResults(resptree=resp))


   len1 = len(idxdcnt1)
   len2 = len(idxdcnt2)

   if ( len1 != len2 ):
      err2 = 1
      print tname, ":     collection count mismatch"

   i = 0
   print tname, ":   ########################################"
   print tname, ":     Query counts,", idxdcnt1, idxdcnt2
   while ( i < len1 ):
      if ( idxdcnt1[i] != idxdcnt2[i] ):
         err3 = 1
         print tname, ":     collection number,", i + 1
         print tname, ":        Query count expected,", idxdcnt1[i]
         print tname, ":        Query count actual,  ", idxdcnt2[i]
      i += 1
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
      item.join()

   for item in eList:
      if item.isAlive():
         print "Thread is still alive in section 3"

   #
   #   Wait for the collections to go idle
   #
   for item in collection_list:
      print tname, ":  BOTTOM WAIT ######################################"
      print tname, ":  Wait for collection", item
      xx.wait_for_idle(collection=item)
      print tname, ":  ##################################################"

   #
   #   Query the collections to make sure all of the data made it.
   #
   qList2 = []
   for item in collection_list:
      resp = yy.api_qsearch(xx=xx, source=item,
                            query='', num=10000)
      qList2.append(yy.getTotalResults(resptree=resp))

   i = 0
   for item in qList2:
      expcount = idxdcnt1[i] + 201
      print tname, ":   Collection number,", i + 1
      print tname, ":      Expected, greater than", expcount
      print tname, ":      Actual,   ", item
      if ( expcount > item ):
         err5 += 1
         print tname, ":      Collection size is wrong"
      i += 1

   print tname, ":   Section one result, enable read only mode"
   if ( err1 == 0 ):
      print tname, ":      Section one passed"
   else:
      print tname, ":      Section one failed"
   print tname, ":   Section two result, collection count"
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

   if ( err == 0 ):
      for cname in collection_list:
         xx.delete_collection(collection=cname)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
