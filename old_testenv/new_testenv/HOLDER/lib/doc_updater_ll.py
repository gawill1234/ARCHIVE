#!/usr/bin/python
# -*- coding: utf-8 -*-

import subprocess, os, time, sys

def exec_command_stdout_ll(cmd, cmdopts, fp=None):

      p = None

      try:
         if ( fp is not None ):
            p = subprocess.Popen(cmd + ' ' + cmdopts + ' ' + fp, shell=True)
            os.waitpid(p.pid, 0)
         else:
            p = subprocess.Popen(cmd + ' ' + cmdopts, shell=True, stdout=subprocess.PIPE).communicate()[0]
      except OSError, e:
         time.sleep(1)
         try:
            if ( fp is not None ):
               p = subprocess.Popen(cmd + ' ' + cmdopts + ' ' + fp, shell=True)
               os.waitpid(p.pid, 0)
            else:
               p = subprocess.Popen(cmd + ' ' + cmdopts, shell=True, stdout=subprocess.PIPE).communicate()[0]
         except OSError, e:
            print "Could not execute ", cmd, ": ", e
            return None

      return p


def build_command_ll(site=None, user=None, pw=None, domain=None, dowhat=None,
                  thingwhat=None, itemname=None, mountpoint=None, quantity=None):
   
   validdowhat = ['create', 'delete', 'update', 'showall', 'quickcheck']
   validthingwhat = ['folder', 'tree', 'file', 'document', 
                     'list', 'listitem', 'listitembunch', 'listbunch']

   if (dowhat in validdowhat):
      cmd = 'run_bulk_loader'
      cmdstring = '-connector livelink'
   
      cmdstring = cmdstring + ' -site ' + site
      cmdstring = cmdstring + ' -user ' + user
      cmdstring = cmdstring + ' -pw ' + pw
      cmdstring = cmdstring + ' -domain ' + domain

      if (dowhat == 'showall' or dowhat == 'quickcheck'):
         if (dowhat == 'showall'):
            cmdstring = cmdstring + ' -showall'
         else:
            cmdstring = cmdstring + ' -quickcheck'
         return cmd, cmdstring
      else:
         if (thingwhat in validthingwhat):
            if (dowhat == 'update'):
               cmdstring = cmdstring + ' -update ' + thingwhat
            elif (dowhat == 'delete'):
               cmdstring = cmdstring + ' -delete ' + thingwhat
            else:
               cmdstring = cmdstring + ' -create ' + thingwhat
            if (thingwhat == 'tree'):
               cmdstring = cmdstring + ' -mountpoint ' + mountpoint
            else:
               cmdstring = cmdstring + ' -mountpoint ' + mountpoint
               cmdstring = cmdstring + ' -itemname ' + itemname
            if ( quantity is not None ):
               cmdstring = cmdstring + ' -numitems ' + quantity
            return cmd, cmdstring

   return None, None

def updateDocument_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "update", "document", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createTree_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "tree", None,
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteTree_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "tree", None,
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteList_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "list", cmd_params['listname'],
                                  "/")

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteListItem_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "listitem", cmd_params['listitem'],
                                  cmd_params['listname'])


   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createList_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "list", cmd_params['listname'],
                                  "/")

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteListBunch_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "listbunch", cmd_params['listname'],
                                  "/", cmd_params['quantity'])

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createListBunch_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "listbunch", cmd_params['listname'],
                                  "/", cmd_params['quantity'])

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createDocument_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "document", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteDocument_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "document", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createFolder_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "folder", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createListItemBunch_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "listitembunch", cmd_params['listitem'],
                                  cmd_params['listname'], cmd_params['quantity'])

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createListItem_ll(**cmd_params):

   cmd, cmdstring = build_command(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "listitem", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

#
#
##############################################################
#
#   For sharepoint tests, this flushes anything that any of the tests
#   use so that the installation can be reused between tests.
#
#
def flush_all_data_ll(tname=None, xx=None, yy=None, listcount=0, **cmd_params):

   liststoplace = ['Klingons', 'Federation', 'Romulan']

   if ( listcount == 0 ):
      listcount = 2000

   for item in liststoplace:
      cmd_params['listname'] = item
      print tname, ":  deleteList, ", cmd_params['listname']
      deleteList(**cmd_params)

   listitemstoplace = ['Constitution', 'Sovereign', 'Ambassador', 'NX',
                       'Excelsior', 'Galaxy', 'Universe', 'Galaxy_Dreadnaught']

   for item in listitemstoplace:
      cmd_params['listname'] = "/Federation"
      cmd_params['listitem'] = item
      print tname, ":  deleteListItem, ", cmd_params['listname'], cmd_params['listitem']
      deleteListItem(**cmd_params)

   cmd_params['listname'] = "/testenv"
   cmd_params['listitem'] = None
   print tname, ":  deleteTree, ", cmd_params['listname']
   deleteTree(**cmd_params)

   cmd_params['listname'] = "/CountedList"
   cmd_params['listitem'] = None
   print tname, ":  deleteList, ", cmd_params['listname']
   deleteList(**cmd_params)

   cmd_params['listname'] = 'NCC-1701'
   cmd_params['listitem'] = None
   cmd_params['quantity'] = '%s' % listcount
   print tname, ":  deleteListBunch, ", cmd_params['listname']
   deleteListBunch(**cmd_params)

   return 0
#
#
##############################################################
#

