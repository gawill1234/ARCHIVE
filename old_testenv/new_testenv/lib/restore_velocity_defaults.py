#!/usr/bin/python

#
#   This program resets the velocity installation to its default state.
#

import sys, time, cgi_interface, vapi_interface

if __name__ == "__main__":

   ##############################################################
   print "restore_velocity_defaults:  ##################"
   print "restore_velocity_defaults:  Resetting Velocity back to its"
   print "restore_velocity_defaults:  default state."
   print "restore_velocity_defaults:  This means 0 collections and an"
   print "restore_velocity_defaults:  empty repository file."
   print "restore_velocity_defaults:  query-search should be running"
   print "restore_velocity_defaults:  when this is complete."

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.restore_defaults()

   sys.exit(0)

