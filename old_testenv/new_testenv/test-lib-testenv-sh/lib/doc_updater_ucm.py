#!/usr/bin/python
# -*- coding: utf-8 -*-

import subprocess, os, time, sys

def exec_command_stdout_ucm(cmd, cmdopts, fp=None):

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


def build_command_ucm(site=None, user=None, pw=None, domain=None, dowhat=None,
                  thingwhat=None, itemname=None, mountpoint=None,
                  quantity=None, port=None):
   
   validdowhat = ['create', 'delete', 'update', 'showall', 'quickcheck']
   validthingwhat = ['folder', 'tree', 'file', 'document', 'name', 'title',
                     'list', 'listitem', 'listitembunch', 'listbunch']

   if (dowhat in validdowhat):
      cmd = 'run_bulk_loader'
      cmdstring = '-connector UCM'
   
      cmdstring = cmdstring + ' -site ' + site
      cmdstring = cmdstring + ' -user ' + user
      cmdstring = cmdstring + ' -pw ' + pw
      if (domain is not None):
         if (domain != ''):
            cmdstring = cmdstring + ' -domain ' + domain
      if (port is not None):
         if (port != ''):
            cmdstring = cmdstring + ' -port ' + port

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
            elif (thingwhat == 'title'):
               cmdstring = cmdstring + ' -itemname ' + itemname
            elif (thingwhat == 'name'):
               cmdstring = cmdstring + ' -itemname ' + itemname
            else:
               cmdstring = cmdstring + ' -mountpoint ' + mountpoint
               cmdstring = cmdstring + ' -itemname ' + itemname
            if ( quantity is not None ):
               cmdstring = cmdstring + ' -numitems ' + quantity
            print "-------------------------------------"
            print cmdstring
            print "-------------------------------------"
            return cmd, cmdstring

   return None, None

def updateDocument_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "update", "document", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createTree_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "tree", None,
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteTree_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "tree", None,
                                  cmd_params['listname'], cmd_params['port'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteList_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "list", cmd_params['listname'],
                                  "/")

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteListItem_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "listitem", cmd_params['listitem'],
                                  cmd_params['listname'])


   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createList_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "list", cmd_params['listname'],
                                  "/")

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteListBunch_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "listbunch", cmd_params['listname'],
                                  "/", cmd_params['quantity'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createListBunch_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "listbunch", cmd_params['listname'],
                                  "/", cmd_params['quantity'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createDocument_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "document", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteDocument_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "document", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def deleteDocumentByName_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "delete", "title", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createFolder_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "folder", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createListItemBunch_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "listitembunch", cmd_params['listitem'],
                                  cmd_params['listname'], cmd_params['quantity'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

def createListItem_ucm(**cmd_params):

   cmd, cmdstring = build_command_ucm(cmd_params['site'], cmd_params['user'],
                                  cmd_params['pw'], cmd_params['domain'],
                                  "create", "listitem", cmd_params['listitem'],
                                  cmd_params['listname'])

   #print cmdstring

   y = exec_command_stdout_ucm(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')

   return

#
#
##############################################################
#
#   For sharepoint tests, this flushes anything that any of the tests
#   use so that the installation can be reused between tests.
#
#
def flush_all_data_ucm(tname=None, xx=None, yy=None, listcount=0, **cmd_params):

   liststoplace = ['Klingons', 'Federation', 'Romulan']

   if ( listcount == 0 ):
      listcount = 2000

   cmd_params['listname'] = "/testenv"
   cmd_params['listitem'] = None
   print tname, ":  deleteTree, ", cmd_params['listname']
   deleteTree(**cmd_params)

   return 0
#
#
##############################################################
#

