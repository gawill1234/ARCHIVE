#!/usr/bin/python

import os, sys, string, getopt
import file_interface

def MAIN():

   dirname = None

   opts, args = getopt.getopt(sys.argv[1:], "D:", ["directory="])

   for o, a in opts:
      if o in ("-D", "--directory"):
         dirname = a

   mycommand = os.path.basename(sys.argv[0])
   zz = file_interface.FILEINTERFACE()

   if ( mycommand == "getversionfiles" ):
      copylist = []
      zz.get_directory_content(dirname, copylist)
      mylist = zz.remove_chaff(copylist)
      zz.dothecopy(mylist)
      sys.exit(0)

if __name__ == "__main__":
   MAIN()
