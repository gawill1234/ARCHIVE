#!/usr/bin/python

from toolenv import VIVTENV
import time, sys, os, re
import urllib, httplib

# Try to get the newer MD5 implementation, with fallback to the older one.
HASHLIB = False
try:
   import hashlib
   HASHLIB = True
except ImportError:
   import md5

############################################

class TCINTERFACE(object):

   def __init__(self, environment=[]):

      self.TENV = VIVTENV(envlist=environment)

      if ( self.TENV.targetos == "windows" ):
         self.gronk = ''.join(['/', self.TENV.virtualdir, '/cgi-bin/gronk.exe'])
         self.admin = ''.join(['/', self.TENV.virtualdir, '/cgi-bin/admin.exe'])
         self.qmeta = ''.join(['/', self.TENV.virtualdir, '/cgi-bin/query-meta.exe'])
         self.apps = ''.join(['/', self.TENV.virtualdir, '/cgi-bin/velocity.exe'])
         self.dump = 'dump.exe'
      else:
         self.gronk = ''.join(['/', self.TENV.virtualdir, '/cgi-bin/gronk'])
         self.admin = ''.join(['/', self.TENV.virtualdir, '/cgi-bin/admin'])
         self.qmeta = ''.join(['/', self.TENV.virtualdir, '/cgi-bin/query-meta'])
         self.apps = ''.join(['/', self.TENV.virtualdir, '/cgi-bin/velocity'])
         self.dump = 'dump'

      return

   ###################################################################

   def http_roundtrip_latency(self):

      i = 0
      totaltime = 0

      if ( sys.platform.startswith('win') ):
         default_timer = time.clock
      else:
         default_timer = time.time

      site = ''.join([])

      action = "installed-dir"
      httpcmd = self.gronk
      httpstring = ''.join(['action=', action])
      args = ''.join([httpcmd, '?', httpstring])

      while ( i < 20 ):
         try:
            start = default_timer()
            conn = httplib.HTTPConnection(self.TENV.target, 80)
            conn.request('GET', args)
            conn.getresponse().read()
            conn.close()
            finish = default_timer()
            elapsed = finish - start
            totaltime += elapsed
            #print "SINGLE:", ('%.3f' % elapsed)
            #print "TOTAL:", ('%.3f' % totaltime)
         except:
            print "BARF"

         i += 1

      elapsed = totaltime / i
      #print "FINAL:", ('%.3f' % elapsed)

      return elapsed

   ###################################################################
   #
   #   Use of this function (time_a_function):
   #   From the calling routine (where ever it is)
   #   set up the params.  To do that:
   #      fparam = {}
   #      fparam['param1'] = param1_value
   #      fparam['param2'] = param2_value
   #      fparam['param3'] = param3_value
   #
   #   Call function:
   #      function_result, elapsed = time_a_function(myfunction, **fparam)
   #
   #   function_result will contain the <myfunction> return value.
   #   elapsed will contain the time <myfunction> took to complete.
   #
   def time_a_function(self, function_name, **function_params):

      start_time = time.time()
      function_result = function_name(**function_params)
      end_time = time.time()

      elapsed = end_time - start_time

      return function_result, elapsed

   def httpstr_appnd(self, httpstr=None, argname=None, argval=None, dorep=0):

      plusisspace = 1
      keepplus = 2
      psign = 0

      if ( argname != None ):
         if ( argval != None ):

            try:
               pls = re.findall(r'\+', argval)
               if ( pls != [] ):
                  psign = 1
            except:
               pls = []
               psign = 0

            #
            #  if we have a % followed by 2 hex digits, the argval
            #  string is considered to be already url encoded so
            #  skip that step.
            #
            try:
               zz = re.findall(r'%[0-9a-fA-F]{2}', argval)
            except:
               zz = []
            if ( zz == [] ):
               httpstring2 = urllib.urlencode({argname:argval})

               if ( dorep == plusisspace or psign == 0 ):
                  httpstring2 = httpstring2.replace('+', '%20')

               if ( dorep == keepplus ):
                  httpstring2 = httpstring2.replace('%2B', '+')
            else:
               httpstring2 = ''.join([argname, "=", argval])


            if ( httpstr != None ):
               httpstring = ''.join([httpstr, '&', httpstring2])
            else:
               httpstring = httpstring2

      return httpstring

   ###################################################################
   def gen_collection_list(self, basename=None, maxcollections=12):

      if ( basename is None ):
         basename = 'generic'

      collection_list = []

      i = 1
      while ( i <= maxcollections ):
         colname = ''.join([basename, '_', '%s' % i])
         collection_list.append(colname)
         i += 1

      print collection_list

      return collection_list

   def tc_begin(self, tname=None, tc_num=0):

      if ( tname == None ):
         tname = "test name unspecified"

      print tname, ":  #######################################"
      print tname, ":  CASE", tc_num
      print tname, ": ", tc_comment

      return

   def tc_end(self, tname=None, tc_num=0, tc_comment=None):

      if ( tname == None ):
         tname = "test name unspecified"

      print tname, ":  END CASE", tc_num
      print tname, ":  #######################################"

      return

   def tc_reverse(self, text=None):

      squib = None
      
      if ( text is not None ):
         squib = ''.join([text[i] for i in range(len(text)-1,-1,-1)])

      return squib

   def look_for_file(self, filename=None):

      if ( filename == None ):
         return None

      f2 = ''.join(['querywork/', filename])
      f3 = ''.join(['querywork/', filename, '.wazzat'])

      if ( os.access(filename, os.R_OK) == 1 ):
         return filename

      if ( os.access(f2, os.R_OK) == 1 ):
         return f2

      if ( os.access(f3, os.R_OK) == 1 ):
         return f3

      return None

   #
   #   Turn returned string into a list and remove any empty
   #   list elements
   #
   def listify(self, mystring=None, sep=' '):

      mylist = []

      if ( mystring == None ):
         return mylist

      z = mystring.split(sep)
      for item in z:
         if ( item != '' ):
            mylist.append(item)

      return mylist

   def replace_string_in_file(self, infile=None, outfile=None,
                              oldstring=None, newstring=None,
                              delete=1):

      if ( infile == None ):
         return 0

      if ( outfile == None ):
         return 0

      if ( oldstring == None ):
         return 0

      if ( newstring == None ):
         return 0

      if ( os.access(outfile, os.F_OK) == 1 ):
         if ( delete == 1 ):
            print "Deleting: ", outfile
            os.remove(outfile)
         else:
            print "File exists: ", outfile
            return 0

      try:
         infd = open(infile, 'r')
      except OSError, e:
         print "Could not open input file", infile
         print "Error:", e
         return 0

      try:
         outfd = open(outfile, 'w')
      except OSError, e:
         print "Could not create output file", outfile
         print "Error:", e
         return 0

      outfd.write(infd.read().replace(oldstring, newstring))

      infd.close()
      outfd.close()

      return 1

   def threecharsplit(self, instring=None, inc=3):

      groupsofthree = []

      incstr = '%s' % inc

      if ( not incstr.isdigit() ):
         return groupsofthree

      if ( inc <= 0 ):
         return groupsofthree

      if ( instring == None ):
         return groupsofthree

      length = len(instring)
      beg = 0
      end = inc

      while ( beg < length ):
         groupsofthree.append(instring[beg:end])
         beg = beg + inc
         end = end + inc

      return groupsofthree

   def getMD5Hash(self, textToHash=None):

      if textToHash == None:
         return ''

      if HASHLIB:
         zz = hashlib.md5(textToHash)
      else:
         zz = md5.new(textToHash)

      return zz.hexdigest()

################################################################
# Simple use of the MD5 hash method (check for 'import' warnings).
if __name__ == "__main__":
   import sys
   print HASHLIB
   tc = TCINTERFACE()
   for arg in sys.argv:
      print arg, tc.getMD5Hash(arg)
