#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic

if __name__ == "__main__":

   xx = cgi_interface.CGIINTERFACE()

   print "african american in content?"
   v1 = xx.urls_by_content(filenm='rq3.res', which='spelling',
                      value="african\ american")
   print "---", v1

   print "african-american in content?"
   v2 = xx.urls_by_content(filenm='rq3.res', which='spelling',
                      value="african-american")
   print "---", v2

   print "africanamerican in content?"
   v3 = xx.urls_by_content(filenm='rq3.res', which='spelling',
                      value="africanamerican")
   print "---", v3


   if ( v1 != '' ):
      if ( v2 != '' ):
         if ( v3 != '' ):
            sys.exit(0)

   sys.exit(1)
