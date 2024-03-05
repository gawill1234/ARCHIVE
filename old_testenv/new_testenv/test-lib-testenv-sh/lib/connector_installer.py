#!/usr/bin/python

import sys, getopt
import connect_avail

def check_install(connector_list=[], connector_version=[], do_an_install=0):

   count = 0

   for connector_name in connector_list:
      cnctr = connect_avail.CONNECTOR(connector_name=connector_name,
                    connector_version=connector_version[connector_name])
      if ( cnctr.is_connector_available() ):
         print connector_name, "connector is installed"
         count += 1
      else:
         print connector_name, "connector is NOT installed"

         if ( do_an_install == 1 ):
            cnctr.install_connector()

   return count


if __name__ == "__main__":

   connector_name = None
   connector_list = []
   connector_version = {}
   count = 0
   current_connector = None

   opts, args = getopt.getopt(sys.argv[1:], "c:v:", ["connector=", "version="])

   for o, a in opts:
      if o in ("-c", "--connector"):
         connector_list.append(a)
         current_connector = a
         connector_version[current_connector] = "default"
      if o in ("-v", "--version"):
         connector_version[current_connector] = a

   count = len(connector_list)
   ins = check_install(connector_list=connector_list, 
                       connector_version=connector_version,
                       do_an_install=1)
   if ( ins < count ):
      ins = check_install(connector_list=connector_list,
                          connector_version=connector_version,
                          do_an_install=0)

   if ( ins == count ):
      print "All connectors were properly installed"
      sys.exit(0)
   else:
      print "Some connectors were not properly installed"
      sys.exit(1)

