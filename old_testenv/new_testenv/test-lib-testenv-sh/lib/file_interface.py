#!/usr/bin/python

import os
import string
from toolenv import VIVTENV
from http_interface import HTTPINTERFACE
from datafiles import DATAFILES
from stat import *
import shutil

############################################

class FILEINTERFACE(object):

   def __init__(self, environment=[]):

      self.TENV = VIVTENV(envlist=environment)

      return

   def is_a_target_os(self, osname=None):

      oslist = ['linux', 'linux64', 'linux32',
                'windows', 'windows32', 'windows64',
                'solaris', 'solaris32', 'solaris64']

      isit = 0

      if ( osname in oslist ):
         isit = 1

      return isit

   def is_a_release(self, release=None):

      isit = 0
      i = 0
      hasdash = 0

      if ( release == None ):
         return isit

      x = len(release)

      while ( i < x ):
         if ( release[i] in string.digits ):
            isit = 1
         elif ( release[i] == '-' ):
            isit = 1
            hasdash = 1
         else:
            isit = 0
            break

         i = i + 1

      if ( hasdash == 0 ):
         isit = 0

      return isit

   def release_file(self, filename=None):

      release = 0.0
      os = 'any'
      ospos = 1

      if ( filename == None ):
         return release

      fpartlist = filename.split('.')

      if ( self.is_a_release(fpartlist[0]) == 1 ):
         xx = fpartlist[0].replace('-', '.')
         release = float(xx)
         #print xx
      else:
         ospos = 0

      return release

   #
   #   Is the file designed for a specific OS.
   #
   def os_file(self, filename=None):

      if ( filename == None ):
         return None

      osname = None

      #
      #   Yes, doing this here means it is probably done
      #   twice, but this is much less error prone because
      #   if means the software checks itself and only needs
      #   the filename to do it.
      #
      release = self.release_file(filename=filename)

      if ( release == 0.0 ):
         ospos = 0
      else:
         ospos = 1

      if ( filename == None ):
         return osname

      fpartlist = filename.split('.')

      if ( len(fpartlist) < ospos + 1 ):
         return None

      if ( self.is_a_target_os(fpartlist[ospos]) == 1 ):
         #print fpartlist[ospos], "is an os"
         osname = fpartlist[ospos]

      return osname

   #
   #   Strip off the release and os info and return only the
   #   name of the target file to be copied.
   #
   def copy_to(self, filename=None, release=None, osname=None):

      ospos = 0
      copytarget = None

      if ( release != None and release != 0.0 ):
         ospos = ospos + 1

      if ( osname != None ):
         ospos = ospos + 1

      fpartlist = filename.split('.')

      listlen = len(fpartlist)

      i = ospos
      while ( i < listlen ):
         if ( i == ospos ):
            copytarget = fpartlist[i]
         else:
            copytarget = ''.join([copytarget, fpartlist[i]])

         i = i + 1
         if ( i < listlen ):
            copytarget = ''.join([copytarget, '.'])

      return copytarget



   #
   #   The actual guts of the automatic versioned file
   #   copy utility.  In here, we have a list of every
   #   file that is in the directory (recursive).  This goes
   #   through and eliminate files that are not versioned and
   #   those that are not applicable to the release being run
   #   based on software version and target os.
   #
   def remove_chaff(self, copylist=[]):

      if ( copylist == [] ):
         return

      newlist = []
      minrel = 0
      maxrel = 0

      listlen = len(copylist)
 
      testrel = self.TENV.vivfloatversion
      usethis = 0.0

      i = 0
      while ( i < listlen ):
         if ( copylist[i][0] != 0.0 ):
            if ( copylist[i][0] == testrel ):
               usethis = copylist[i][0]
               break
            else:
               if ( copylist[i][0] <= testrel ):
                  if ( copylist[i][0] > maxrel ):
                     maxrel = copylist[i][0]
                     usethis = maxrel
               if ( copylist[i][0] >= testrel ):
                  if ( minrel == 0 ):
                     minrel = copylist[i][0]
                  if ( copylist[i][0] < minrel ):
                     minrel = copylist[i][0]
         i = i + 1

      if ( usethis == 0.0 ):
         usethis = minrel

      i = 0
      while ( i < listlen ):
         if ( copylist[i][0] == usethis and usethis > 0 ):
            if ( copylist[i][1] == None ):
               newlist.append(copylist[i])
            else:
               if ( copylist[i][1] == self.TENV.targetos or
                    copylist[i][1] == self.TENV.targarch ):
                  newlist.append(copylist[i])
         else:
            if ( copylist[i][1] != None ):
               if ( copylist[i][1] == self.TENV.targetos or
                    copylist[i][1] == self.TENV.targarch ):
                  newlist.append(copylist[i])

         i = i + 1

      return newlist


   #
   #   Ok, so I got sick of constantly doing a stat
   #   followed by a check.  This does it all for me
   #   and I have less to remember.
   #
   def pathtype(self, name=None):

      xx = os.stat(name)

      if ( S_ISDIR(xx.st_mode) ):
         return "directory"
      if ( S_ISREG(xx.st_mode) ):
         return "file"
      if ( S_ISFIFO(xx.st_mode) ):
         return "pipe"
      if ( S_ISCHR(xx.st_mode) ):
         return "character"
      if ( S_ISBLK(xx.st_mode) ):
         return "block"
      if ( S_ISLNK(xx.st_mode) ):
         return "symlink"
      if ( S_ISSOCK(xx.st_mode) ):
         return "socket"

      return "unknown"

   def collection_from_filename(self, filename=None):

      collection = None

      if ( filename is not None ):
         zoom = filename.split('.')
         listlen = len(zoom)
         if ( listlen > 0 ):
            if ( zoom[listlen - 1] == 'xml' ):
               collection = zoom[0]

      return collection

   def dir_split(self, dirname=None):

      if ( dirname is None ):
         return []

      name_list = dirname.split('/')

      return name_list

   def get_directory_file_list(self, dirname=None, copylist=None):

      if ( copylist is None ):
         copylist = []

      if ( dirname == None ):
         return copylist

      dirlist = os.listdir(dirname)

      for item in dirlist:
 
         if ( item != ".changes" ):
            newpath = ''.join([dirname, '/', item])

            if ( self.pathtype(name=newpath) == "directory" ):
               #print "DIRECTORY:", newpath
               copylist = self.get_directory_file_list(newpath, copylist)
            else:
               if ( self.pathtype(name=newpath) == "file" ):
                  #print "FILE:", newpath
                  copylist.append([dirname, item])

      return copylist

   def get_directory_content(self, dirname=None, copylist=None):
  
      if ( copylist is None ):
         copylist = []

      if ( dirname == None ):
         return

      dirlist = os.listdir(dirname)

      for item in dirlist:
 
         if ( item != ".changes" ):
            newpath = ''.join([dirname, '/', item])

            if ( self.pathtype(name=newpath) == "directory" ):
               #print "DIRECTORY:", newpath
               copylist = self.get_directory_content(newpath, copylist)
            else:
               if ( self.pathtype(name=newpath) == "file" ):
                  #print "FILE:", newpath
                  release = self.release_file(item)
                  osname = self.os_file(item)
                  copytarg = self.copy_to(filename=item, release=release, osname=osname)
                  if ( copytarg != None ):
                     newcopypath = ''.join([dirname, '/', copytarg])
                     copylist.append([release, osname, newpath, newcopypath])

      return copylist

   def copyafile(self, source=None, dest=None):

      if ( source == None ):
         return 1

      if ( dest == None ):
         return 1

      try:
         print "COPY:", source
         print "TO  :", dest
         shutil.copy(source, dest)
      except OSError, e:
         print "File copy error:", e
         return 1

      return 0

   #
   #   This is a copy that is specific for the automatic version
   #   find/copy utility for versioned files.  It calls the generic
   #   copy routine.
   #
   def dothecopy(self, copylist=[]):
      
      i = 0
      listlen = len(copylist)

      while ( i < listlen ):
         cpfrom = copylist[i][2]
         cpto = copylist[i][3]
         self.copyafile(source=cpfrom, dest=cpto)
         i = i + 1

      return

   def pathNameExists(self, path_name=None):

      if ( path_name is not None ):
         if ( os.path.exists(path_name) ):
            return True

      return False
