#!/usr/bin/python

import os, sys, string, getopt, posix, time, stat
from cgi_interface import CGIINTERFACE

from confile import FILES

def MAIN():

   err = 0
   cname = None
   optlist = None
   mytarget = None
   mytargetdir = "/tmp"
   mytype = "converter"
   sep = '/'

   input_path = "./inputs"
   output_path = "./outputs"
   compare_path = "./compare_files"

   opts, args = getopt.getopt(sys.argv[1:], "r:hc:o:i:O:C:T:t:", ["help", "command=", "options=", "inputs=", "outputs=", "compare=", "target=", "cmdtype=", "rundir="])

   for o, a in opts:
      if o in ("-h", "--help"):
         print "blah"
         sys.exit(2)
      if o in ("-c", "--command"):
         cname = a
      if o in ("-o", "--options"):
         optlist = a
      if o in ("-i", "--inputs"):
         input_path = a
      if o in ("-O", "--outputs"):
         output_path = a
      if o in ("-C", "--compare"):
         compare_path = a
      if o in ("-T", "--target"):
         mytarget = a
      if o in ("-t", "--cmdtype"):
         mytype = a
      if o in ("-r", "--rundir"):
         mytargetdir = a

   if ( cname == None ):
      print "No command given to execute"
      sys.exit(1)

   #
   #   Get access to the cgi commands (gronk)
   #
   go = CGIINTERFACE()

   if ( go.TENV.targetos == "windows" ):
      sep = '\\'
      mytargetdir = go.vivisimo_dir(which="tmp")
   else:
      mytargetdir = "/tmp"
   targetdir = go.vivisimo_dir(which=mytype)

   if ( optlist == None ):
      cmdstring = ''.join([targetdir, sep, cname])
   else:
      cmdstring = ''.join([targetdir, sep, cname, ' ', optlist])

   input_list = os.listdir(input_path)
   #input_list = ['eastern05.xls', 'junk']
   total = 0

   print "Testing:", cname

   for fname in input_list:
      theseopts = None

      name = ''.join([input_path, '/', fname])
      fobj = FILES(name, targetdir=mytargetdir, resdir=go.workingdir)

      targetname = ''.join([fobj.whereontarget, sep, fobj.name])
      targetresult = ''.join([fobj.whereontarget, sep, fobj.filestdout])
      localresult = ''.join([go.workingdir, '/', fobj.filestdout])

      mymode = os.stat(fobj.fullpath).st_mode
      if ( stat.S_ISREG(mymode) ):
         total = total + 1
         print "######", fname, " Begin ############"
         print "     Transferring file to target ..."
         print "     from:", fobj.fullpath
         print "     to  :", fobj.whereontarget

         go.delete_file(removefile=targetname)
         go.delete_file(removefile=targetresult)

         go.put_file(putfile=fobj.fullpath, targetdir=fobj.whereontarget)

         if ( cname == "pdftotext" ):
            theseopts = ' '.join([targetname, targetresult])
         else:
            theseopts = ''.join([targetname, ' > ', targetresult])
         fullcmd = ' '.join([cmdstring, theseopts])

         print "     Go ...", cmdstring, targetname
         #print "     Go ...", fullcmd

         go.execute_command(cmd=fullcmd)

         #
         #   Give files a chance to make it to disk.  And yes,
         #   the apps on the other end to attempt to sync to force
         #   data to disk.
         #
         time.sleep(1)

         print "   Getting:", targetresult
         go.get_file(getfile=targetresult)

         posix.rename(fobj.filestdout, localresult)

         go.delete_file(removefile=targetname)
         go.delete_file(removefile=targetresult)

         if ( fobj.diffit() != 0 ):
            err = err + 1
            print "!!!  Case Failed: ", fobj.name
         else:
            print "     Case Passed: ", fobj.name
         print "######", fname, " End   ############"

   print "Ran ", total, " cases"
   print err, " case(s) failed"

   sys.exit(err)

######################################

if __name__ == "__main__":
   MAIN()

