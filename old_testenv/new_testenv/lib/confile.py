#!/usr/bin/python

import os, sys, string, difflib, subprocess

############################################

class FILES(object):

   #
   #   Name of file
   #
   name = None

   #
   #   Name of directory where file is put (target host)
   #
   whereontarget = None
   #
   #   Name of file stdout is redirected to
   #
   filestdout = None

   #
   #   Name of file stderr is redirected to
   #
   filestderr = None

   #
   #   Name of directory where result is put (local host)
   #
   whereonhere = None

   #
   #   Directory where file is (local host)
   #
   whereistnow = None

   #
   #   Fullpath of file
   #
   fullpath = None

   #
   #   Name of compare file
   #
   compfile = None

   #########################################

   def __init__(self, filename, targetdir=None, resdir=None):

      self.fullpath = filename
      self.name = os.path.basename(filename)
      self.whereisitnow = os.path.dirname(filename)
      self.whereontarget = targetdir
      self.whereonhere = resdir

      self.filestdout = ''.join([self.name, ".stdout"])
      self.filestderr = ''.join([self.name, ".stderr"])
      self.compfile = ''.join(["output.", self.name])

      return

   #########################################
   #
   #   Diff the files from the comparedir to  those
   #   in the resultdir
   #   Needs some work
   #
   def diffit(self, compdir=None, comparedir=None, resultdir=None):

      err = 0

      if ( comparedir == None ):
         comparedir = "compare_files"

      if ( resultdir == None ):
         resultdir = "querywork"
      
      mydir = os.path.dirname(self.whereisitnow)

      cmppath = ''.join([mydir, "/", comparedir, "/", self.compfile])
      respath = ''.join([mydir, "/", self.whereonhere, "/", self.filestdout])

      if ( os.access(cmppath, os.R_OK) != 1 ):
         print "diffit() - File not found: ", cmppath
         return 1

      if ( os.access(respath, os.R_OK) != 1 ):
         print "diffit() - File not found: ", respath
         return 1

      op = open(cmppath)
      op2 = open(respath)

      one = op.read()
      two = op2.read()

      xyz = list(difflib.Differ().compare(one.splitlines(1), two.splitlines(1)))

      for a in xyz:
         if ( a.startswith("+") ):
            if ( not( a.__contains__("<TITLE>")) ):
               err = err + 1
            if ( not( a.__contains__(self.name)) ):
               err = err + 1
         if ( a.startswith("-") ):
            if ( not( a.__contains__("<TITLE>")) ):
               err = err + 1
            if ( not( a.__contains__(self.name)) ):
               err = err + 1

      op.close()
      op2.close()

      return err


if __name__ == "__main__":
   filet = FILES("inputs/test.xls")
