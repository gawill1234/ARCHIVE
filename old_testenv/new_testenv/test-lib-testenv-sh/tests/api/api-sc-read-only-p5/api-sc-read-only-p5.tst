#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import multi_verse
import build_schema_node
from threading import Thread
from lxml import etree

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

   collection_name = "scro_p5"
   tname = "api_sc_read_only_p5"

   fail = done = 0

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  read only all, go immediately to data push"

   collection_list = ['scro_p5_1', 'scro_p5_2', 'scro_p5_3',
                      'scro_p5_4', 'scro_p5_5', 'scro_p5_6',
                      'scro_p5_7', 'scro_p5_8', 'scro_p5_9',
                      'scro_p5_10', 'scro_p5_11', 'scro_p5_12']

   for cname in collection_list:
      cex = xx.collection_exists(collection=cname)
      if ( cex == 1 ):
         xx.delete_collection(collection=cname)

   cList = []
   for cname in collection_list:
      cc = multi_verse.ThreadedCreate(collection=cname)
      cList.append(cc)
      cc.start()

   for item in cList:
      item.join()
      
   eList = []
   for cname in collection_list:
      ee = multi_verse.ThreadedEnqueue(collection=cname, eCount=500,
                                       basedir='/testenv/test_data/law/F2')
      eList.append(ee)
      ee.start()

   for item in eList:
      item.join()

   for item in collection_list:
      xx.wait_for_idle(collection=item)

   qList = []
   for item in collection_list:
      resp = yy.api_qsearch(xx=xx, source=item,
                            query='', num=10000)
      idxdcnt1 = yy.getTotalResults(resptree=resp)
      qList.append(idxdcnt1)

   i = 0
   err1 = 0
   err2 = 0

   while ( i <= 10 ):
      try:
         yy.api_sc_read_only_all(mode='enable')
      except:
         print tname, ":  One or more read only enables failed"
      for cname in collection_list:
         err1 = err1 + check_ro_status(collection=cname, whichstatus='disabled')

      if ( err1 != 0 ):
         print tname, ":  read only failure count =", err1

      try:
         yy.api_sc_read_only_all(mode='disable')
      except:
         print tname, ":  One or more read only disables failed"

      for cname in collection_list:
         err2 = err2 + check_ro_status(collection=cname, whichstatus='enabled')

      if ( err2 != 0 ):
         print tname, ":  read only failure count =", err2

      i += 1

   eList = []
   for cname in collection_list:
      ee = multi_verse.ThreadedEnqueue(collection=cname, eCount=200,
                                       basedir='/testenv/test_data/law/US')
      eList.append(ee)
      ee.start()

   for item in eList:
      item.join()

   for item in collection_list:
      xx.wait_for_idle(collection=item)

   qList2 = []
   for item in collection_list:
      resp = yy.api_qsearch(xx=xx, source=item,
                            query='', num=10000)
      idxdcnt1 = yy.getTotalResults(resptree=resp)
      qList2.append(idxdcnt1)

   i = 0
   err3 = 0
   for item in qList:
      print tname, ":   Size change in collection,", i
      print tname, ":      Old, ", item
      print tname, ":      New, ", qList2[i]
      if ( qList2[i] <= item ):
         err3 += 1
         print tname, ":      Collection did not grow"
      i += 1

   for cname in collection_list:
      xx.delete_collection(collection=cname)

   if ( err1 == 0 and err2 == 0 and err3 == 0 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
