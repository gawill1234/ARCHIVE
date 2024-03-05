#!/usr/bin/python

import os, sys, string, time

class simpleLock(object):


   def __init__(self, lockedResource=None):

      checkfile = "/testenv/CHECKFILE"

      mypid = os.getpid()

      self.maxSleep = 28000
      self.lockRes = lockedResource

      if ( os.access(checkfile, os.R_OK) == 1 ):
         self.myTmpFile = '/testenv/lockDir/tLock.' + '%s' % mypid
         self.lockName = '/testenv/lockDir/' + self.lockRes
      else:
         self.myTmpFile = '/tmp/tLock.' + '%s' % mypid
         self.lockName = '/tmp/' + self.lockRes

      #self.myTmpFile = '/tmp/tLock.' + '%s' % mypid
      #self.lockName = '/tmp/' + self.lockRes
      self.initLock()

      return

   def initLock(self):

      #
      #   Create the lockfile shell.
      #   After this, the lock is ready, but is not yet set.
      #
      try:
         fd = open(self.myTmpFile, 'w+')
         fd.write(self.lockRes)
         fd.close()
      except:
         print "lock initialization failed:", self.myTmpFile
         sys.stdout.flush()
         sys.exit(-1)

      return

   def freeLock(self):

      try:
         os.unlink(self.lockName)
         print "lock released:", self.lockName
         sys.stdout.flush()
      except:
         print "lock not found:", self.lockName

      return

   def setLock(self):

      #
      #   Set the lock.
      #   Setting is a rename of the temp file created in initLock()
      #   because the rename is supposed to be (by POSIX standard) and
      #   atomic operation.
      #
      try:

         cntr = 0
         while ( os.access(self.lockName, os.F_OK) == 1 ):
            time.sleep(1)
            if ( cntr > self.maxSleep ):
               print "lock acquisition failed(timeout):", self.lockName
               sys.stdout.flush()
               sys.exit(-1)
        
         os.rename(self.myTmpFile, self.lockName)
         print "lock acquired:", self.lockName
         sys.stdout.flush()

      except OSError, e:
         print "lock acquisition failed(exception):", self.lockName
         print "  Error:", e
         sys.stdout.flush()
         sys.exit(-1)

      return

   
