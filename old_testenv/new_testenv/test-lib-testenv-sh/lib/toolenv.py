#!/usr/bin/python

import os, sys, string, subprocess

#
#   Simple class to get the pertinent available
#   test environment variables.
#

############################################

class VIVTENV(object):

   httpport = None
   user = None
   pswd = None
   target = None
   targetos = None
   collection = None
   port = 0
   project = None
   testroot = None
   newtestsave = "No"
   virtualdir = None
   killall = None
   vivversion = 0
   partner = "Vivisimo"
   targarch = None
   defaultsubcoll = "live"

   #########################################

   def __init__(self, envlist=None):

      user = None
      pswd = None
      target = None
      targetos = None
      collection = None
      port = 0
      project = None
      testroot = None
      httpport = None
      virtualdir = None
      killall = None
      vivversion = 0
      partner = None
      targarch = None
      defaultsubcoll = None

      if ( envlist != None ):
         for x in envlist:
            if x == 'VIVUSER':
               user = envlist[x]
            if x == 'VIVPW':
               pswd = envlist[x]
            if x == 'VIVHOST':
               target = envlist[x]
            if x == 'VIVTARGETOS':
               targetos = envlist[x]
            if x == 'VIVCOLLECTION':
               collection = envlist[x]
            if x == 'VIVPORT':
               port = envlist[x]
            if x == 'VIVPROJECT':
               project = envlist[x]
            if x == 'TEST_ROOT':
               testroot = envlist[x]
            if x == 'VIVHTTPPORT':
               httpport = envlist[x]
            if x == 'VIVVIRTUALDIR':
               virtualdir = envlist[x]
            if x == 'VIVVERSION':
               vivversion = envlist[x]
            if x == 'VIVPARTNER':
               partner = envlist[x]
            if x == 'DEFAULTSUBCOLLECTION':
               defaultsubcoll = envlist[x]
            if x == 'VIVTARGETARCH':
               targarch = envlist[x]
            if x == 'VIVKILLALL':
               killall = envlist[x]
     
      self.find_user(user)
      self.find_password(pswd)
      self.find_target(target)
      self.find_targetos(targetos)
      self.find_collection(collection)
      self.find_port(port)
      self.find_project(project)
      self.find_testroot(testroot)
      self.find_newtestsave()
      self.find_httpport(httpport)
      self.find_virtualdir(virtualdir)
      self.find_version(vivversion)
      self.find_partner(partner)
      self.find_subcollection(defaultsubcoll)
      self.find_targarch(targarch)
      self.find_killall(killall)

      return

   def get_target(self):
      return self.target

   #########################################
   #
   #   Find the collection being used, if applicable.
   #
   def find_newtestsave(self):

      self.newtestsave = os.getenv('NEWTESTSAVE', "No")

      return

   #########################################
   #
   #   Find the collection being used, if applicable.
   #
   def find_virtualdir(self, virtualdir=None):

      if ( virtualdir == None ):
         self.virtualdir = os.getenv('VIVVIRTUALDIR', None)
      else:
         self.virtualdir = virtualdir

      if ( self.virtualdir == None ):
         self.virtualdir = 'vivisimo'

      return
   #########################################
   #
   #   Find the collection being used, if applicable.
   #
   def find_httpport(self, httpport=None):

      if ( httpport == None ):
         self.httpport = os.getenv('VIVHTTPPORT', None)
      else:
         self.httpport = httpport

      if ( self.httpport == None ):
         self.httpport = 80

      return
   #########################################
   #
   #   Find the collection being used, if applicable.
   #
   def find_project(self, project=None):

      if ( project == None ):
         self.project = os.getenv('VIVPROJECT', None)
      else:
         self.project = project

      if ( self.project == None ):
         #print "VIVPROJECT environment variable not specified.  Assuming query-meta."
         self.project = "query-meta"

      return
   #########################################
   #
   #   Find the collection being used, if applicable.
   #
   def find_port(self, port=0):

      if ( port == 0 ):
         self.port = os.getenv('VIVPORT', 0)
      else:
         self.port = port

      if ( self.port == 0 ):
         print "VIVPORT environment variable not specified.  Assuming 7205."
         self.project = 7205

      return

   #########################################
   #
   #   Find the target machine architecture
   #   valid values are: linux64, linux32, solaris64,
   #                     solaris32, windows64, windows32
   #
   def find_targarch(self, targarch=None):

      if ( targarch == None ):
         self.targarch = os.getenv('VIVTARGETARCH', None)
      else:
         self.targarch = targarch

      if ( self.targarch == None ):
         self.targarch = ''.join([self.targetos, '32'])

      return

   #########################################
   #
   #   Find the collection being used, if applicable.
   #
   def find_version(self, vivversion=0):

      if ( vivversion == 0 ):
         self.vivversion = os.getenv('VIVVERSION', 0)
      else:
         self.vivversion = vivversion

      if ( self.vivversion == 0 ):
         self.vivversion = "6.0"

      self.vivfloatversion = float(self.vivversion)

      return

   def find_partner(self, partner=None):

      if ( partner == None ):
         self.partner = os.getenv('VIVPARTNER', None)
      else:
         self.partner = partner

      if ( self.partner == None ):
         self.partner = "Vivisimo"

      return
   #########################################
   #
   #   Find the collection being used, if applicable.
   #
   def find_collection(self, collection=None):

      if ( collection == None ):
         self.collection = os.getenv('VIVCOLLECTION', None)
      else:
         self.collection = collection

      return

   def find_killall(self, killall=None):

      if ( killall == None ):
         self.killall = os.getenv('VIVKILLALL', None)
      else:
         self.killall = killall

      return

   #########################################
   #
   #   Target machine operating system
   #
   def find_targetos(self, targetos=None):

      if ( targetos == None ):
         self.targetos = os.getenv('VIVTARGETOS', None)
      else:
         self.targetos = targetos

      if ( self.targetos == None ):
         print "VIVTARGETOS environment variable not specified.  Assuming linux."
         self.targetos = "linux"

      return


   #########################################
   #
   #   Default subcollection to use (if any)
   #
   def find_subcollection(self, defaultsubcoll=None):

      if ( defaultsubcoll == None ):
         self.defaultsubcoll = os.getenv('DEFAULTSUBCOLLECTION', None)
      else:
         self.defaultsubcoll = defaultsubcoll

      if ( self.defaultsubcoll == None ):
         #print "DEFAULTSUBCOLLECTION environment variable not specified.  Assuming old."
         self.defaultsubcoll = "live"

      return


   #########################################
   #
   #   Find the users password (Vivisimo password)
   #
   def find_password(self, pswd=None):

      if ( pswd == None ):
         self.pswd = os.getenv('VIVPW', None)
      else:
         self.pswd = pswd

      if ( self.pswd == None ):
         print "VIVPW environment variable not specified.  Required.  Exiting."
         sys.exit(1)

      return


   #########################################
   #
   #   Find the users userid (Vivisimo userid)
   #
   def find_user(self, user=None):

      if ( user == None ):
         self.user = os.getenv('VIVUSER', None)
      else:
         self.user = user

      if ( self.user == None ):
         print "VIVUSER environment variable not specified.  Required.  Exiting."
         sys.exit(1)

      return


   #########################################
   #
   #   Find the users userid (Vivisimo userid)
   #
   def find_testroot(self, testroot=None):

      if ( testroot == None ):
         self.testroot = os.getenv('TEST_ROOT', None)
      else:
         self.testroot = testroot

      if ( self.testroot == None ):
         print "TEST_ROOT environment variable not specified.  Required.  Exiting."
         sys.exit(1)

      return


   #########################################
   #
   #   Find the target machine
   #
   def find_target(self, target=None):

      if ( target == None ):
         self.target = os.getenv('VIVHOST', None)
      else:
         self.target = target

      if ( self.target == None ):
         print "VIVHOST environment variable not specified.  Assuming 127.0.0.1."
         self.target = "127.0.0.1"

      return

   #########################################

if __name__ == "__main__":
   cmd = VIVTENV(target="testbed4")
   print "TARGET: ", cmd.target

   cmd.find_target(target="testbed2-2")
   print "TARGET: ", cmd.target
   print "USER: ", cmd.user
