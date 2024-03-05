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
           ( i < 100 ) ):
      print tname, ":  No read only status change, sleep 5 seconds"
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
      print tname, ":     Change of status failed to occur after 600 seconds"
      print tname, ":  Test Failed"
      sys.exit(1)

   return err

if __name__ == "__main__":

   global done, fail

   collection_name = "scro_p4"
   tname = "api_sc_read_only_p4"

   fail = done = 0

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  read only all test"

   collection_list = ['scro_p4_1', 'scro_p4_2', 'scro_p4_3',
                      'scro_p4_4', 'scro_p4_5', 'scro_p4_6',
                      'scro_p4_7', 'scro_p4_8', 'scro_p4_9',
                      'scro_p4_10', 'scro_p4_11', 'scro_p4_12']

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
      ee = multi_verse.ThreadedEnqueue(collection=cname, eCount=500)
      eList.append(ee)
      ee.start()

   for item in eList:
      item.join(180)

   for item in collection_list:
      xx.wait_for_idle(collection=item)

   qList = []
   for item in collection_list:
      doit = multi_verse.ThreadedQuery(collection=item)
      qList.append(doit)
      doit.start()

   i = 0
   err1 = 0
   err2 = 0

   while ( i <= 100 ):
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

      if ( done == 1 ):
         break

   done = 1

   for item in qList:
      item.setDone()
      item.join()

   for cname in collection_list:
      xx.delete_collection(collection=cname)

   if ( err1 == 0 and err2 == 0 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
