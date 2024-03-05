#!/usr/bin/python

import sys, subprocess, os
import pycurl
import cgi_interface
import vapi_interface
import velocityAPI
import gronkClient
import time

class CONNECTOR(object):

   #
   #   Basic class variables
   #
   connector = None
   avail = 0
   yy = None
   xx = None
   vivdir = None

   #
   #   dictionary values of data needed get and/or 
   #   determeine the presence of the connector
   #   on the target.
   #
   #   connfunc:  List of functions which should be 
   #   there if the connector is present.
   #   If any of the functions are missing, the 
   #   connector is not installed.  Use the list to
   #   update the repository as well.
   #
   connfunc = {}
   #
   #   connurl:  Maven url for the location of the 
   #   current connector.  Use to get the connector
   #   distribution file.
   #
   connurl = {}
   #
   #   connfile:  The main connector file.  If this 
   #   isn't there, the connector is missing.
   #
   connfile = {}
   connversion = {}

   def __init__(self, connector_name=None, connector_version=None):

      valid_list = ['lotus-notes', 'io-sharepoint', 'sharepoint', 'ucm',
                    'livelink', 'filenetp8', 'siebel', 'samba-airbus',
                    'database', 'samba', 'documentum', 'eroom', 'confluence']

      base_http = "https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/"

      #
      #   This dictionary approach should probably be replaced by a method
      #   that unpacks the zip files and then looks for the functions in
      #   the extracted xml files.  But, for the moment, this was faster to
      #   get something going.  Yes, I know that is the software equivalent of
      #   "I was just following orders ...".  Too bad.  Live with it.
      #
#https://code.vivisimo.com/maven/content/repositories/releases/com/vivisimo/connector/connector-samba/3.2.0/connector-samba-3.2.0-TEST-distrib-DO_NOT_SHIP.zip
#https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/samba/__VREPLACE__/samba-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip
      self.connversion['lotus-notes'] = "1.1.2"
      self.connfunc['lotus-notes'] = ["lotus-rights",
                                 "vse-converter-lotus-to-xml",
                                 "vse-crawl-seed-lotus-options",
                                 "vse-crawler-seed-lotus-tng",
                                 "vse-crawler-seed-lotus-users-tng",
                                 "vse-crawler-seed-lotus-users",
                                 "vse-crawler-seed-lotus"]
      self.connfile['lotus-notes'] = ["lib/java/plugins/lotus-__VREPLACE__.zip"]
      self.connurl['lotus-notes'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/lotus/__VREPLACE__/lotus-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "lotus-__VREPLACE__.zip"]

      self.connversion['ucm'] = "2.0.2"
      self.connfunc['ucm'] = ["vse-crawler-seed-universal-ucm",
                              "universal-ucm-rights",
                              "universal-ucm-groups"]
      self.connurl['ucm'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/universal-ucm/__VREPLACE__/universal-ucm-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "universal-ucm-__VREPLACE__.zip"]
      self.connfile['ucm'] = ["lib/java/plugins/universal-ucm-__VREPLACE__.zip"]

      self.connversion['sharepoint'] = "1.1.2"
      self.connfunc['sharepoint'] = ["vse-converter-sharepoint-to-xml",
                                 "vse-crawler-seed-sharepoint-options",
                                 "vse-crawler-seed-sharepoint-tng",
                                 "vse-crawler-seed-sharepoint"]
      self.connurl['sharepoint'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/sharepoint/__VREPLACE__/sharepoint-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "sharepoint-__VREPLACE__.zip"]
      self.connfile['sharepoint'] = ["lib/java/plugins/sharepoint-__VREPLACE__.zip"]

      self.connversion['io-sharepoint'] = "1.1.7"
      self.connfunc['io-sharepoint'] = ["vse-converter-io-sharepoint-to-xml",
                                 "vse-converter-sharepoint-user-profile-to-xml",
                                 "vse-crawler-seed-io-sharepoint"]
      self.connfile['io-sharepoint'] = ["lib/java/plugins/io-sharepoint-__VREPLACE__.zip"]
      self.connurl['io-sharepoint'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/io-sharepoint/__VREPLACE__/io-sharepoint-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "io-sharepoint-__VREPLACE__.zip"]

      self.connversion['confluence'] = "2.0.4"
      self.connfunc['confluence'] = ["confluence-rights",
                                 "vse-crawler-seed-confluence-users",
                                 "vse-crawler-seed-confluence"]
      self.connfile['confluence'] = ["lib/java/plugins/confluence-__VREPLACE__.zip"]
      self.connurl['confluence'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/confluence/__VREPLACE__/confluence-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "confluence-__VREPLACE__.zip"]

      self.connversion['livelink'] = "1.1.2"
      self.connfunc['livelink'] = ["livelink-rights",
                                 "vse-crawler-seed-livelink-users",
                                 "vse-crawler-seed-livelink"]
      self.connfile['livelink'] = ["lib/java/plugins/universal-livelink-__VREPLACE__.zip"]
      self.connurl['livelink'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/universal-livelink/__VREPLACE__/universal-livelink-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "livelink-__VREPLACE__.zip"]

      self.connversion['filenetp8'] = "1.1.1"
      self.connfunc['filenetp8'] = ["vse-crawler-seed-filenetp8"]
      self.connfile['filenetp8'] = ["lib/java/plugins/universal-filenetp8-__VREPLACE__.zip"]
      self.connurl['filenetp8'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/universal-filenetp8/__VREPLACE__/universal-filenetp8-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "filenetp8-__VREPLACE__.zip"]

      self.connversion['samba'] = "1.1.3"
      self.connfunc['samba'] = ["vse-crawler-seed-smb"]
      self.connfile['samba'] = ["lib/java/plugins/samba-__VREPLACE__.zip"]
      self.connurl['samba'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/samba/__VREPLACE__/samba-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "samba-__VREPLACE__.zip"]

      self.connversion['database'] = "2.1.1"
      self.connfunc['database'] = ["vse-converter-database",
                                 "vse-crawler-seed-database-key-sql",
                                 "vse-crawler-seed-database-key",
                                 "vse-converter-database-tng",
                                 "vse-crawler-seed-database-options-common"]
      self.connfile['database'] = ["lib/java/plugins/database-__VREPLACE__.zip"]
      self.connurl['database'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/database/__VREPLACE__/database-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "database-__VREPLACE__.zip"]

      self.connversion['documentum'] = "1.1.5"
      self.connfunc['documentum'] = ["documentum-rights",
                                 "vse-converter-documentum-to-xml-tcs",
                                 "vse-converter-documentum-to-xml",
                                 "vse-crawler-seed-documentum-users",
                                 "vse-crawler-seed-documentum"]
      self.connfile['documentum'] = ["lib/java/plugins/documentum-__VREPLACE__.zip"]
      self.connurl['documentum'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/documentum/__VREPLACE__/documentum-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "documentum-__VREPLACE__.zip"]

      self.connversion['siebel'] = "2.1.8"
      self.connfunc['siebel'] = ["vse-crawler-seed-siebel"]
      self.connfile['siebel'] = ["lib/java/plugins/siebel-__VREPLACE__.zip"]
      self.connurl['siebel'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/siebel/__VREPLACE__/siebel-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "siebel-__VREPLACE__.zip"]

      self.connversion['eroom'] = "1.1.0"
      self.connfunc['eroom'] = ["vse-converter-eroom-to-xml",
                                 "vse-crawler-seed-eroom-options",
                                 "vse-crawler-seed-eroom-users",
                                 "eroom-rights",
                                 "vse-crawler-seed-eroom"]
      self.connurl['eroom'] = ["https://code.bigdatalab.ibm.com/maven/content/repositories/releases/com/vivisimo/connector/eroom/__VREPLACE__/eroom-__VREPLACE__-TEST-distrib-DO_NOT_SHIP.zip", "eroom-__VREPLACE__.zip"]
      self.connfile['eroom'] = ["lib/java/plugins/eroom-__VREPLACE__.zip"]
      

      for item in valid_list:
         if ( item == connector_name ):
            self.connector = connector_name
            if ( connector_version != "default" ):
               self.connversion[connector_name] = connector_version
            self.set_version_string()
            self.yy = vapi_interface.VAPIINTERFACE()

            self.xx = cgi_interface.CGIINTERFACE()
            self.vivdir = self.xx.vivisimo_dir()
   
            #
            #   If the connector is already marked as available,
            #   we are done, return
            #
            if ( self.is_connector_available() ):
               return

            #
            #   If the connector is NOT already marked as available,
            #   Check one more time, just in case we ran through the
            #   hard way install.
            #
            self.set_connector_avail()
            return

      print "Invalid connector specified.  Exiting now."
      sys.exit(99)

   def set_version_string(self, connector=None):

      if ( connector is None ):
         connector = self.connector

      self.connfile[connector][0] = self.connfile[connector][0].replace('__VREPLACE__', self.connversion[connector])

      self.connurl[connector][0] = self.connurl[connector][0].replace('__VREPLACE__', self.connversion[connector])
      self.connurl[connector][1] = self.connurl[connector][1].replace('__VREPLACE__', self.connversion[connector])

      print "Using", self.connurl[connector]
      print "     ", self.connfile[connector]

   #
   #   Find out whether or not a connector exists 
   #   on the target.  Set the "avail" value
   #   accordingly.  It uses the known functions 
   #   for the connector and the main connector file
   #   as determinants of availability.
   #
   def set_connector_avail(self):

      gotit = 0
      goodlen = len(self.connfunc[self.connector]) + 1

      print "####"
      for item in self.connfunc[self.connector]:
         print "####"
         if ( self.yy.repository_node_exists(elemtype="function",
                                             elemname=item) ):
            gotit += 1
         else:
            print self.connector, ":  function", item, "DOES NOT EXIST"

      connector_file = self.vivdir + "/" + self.connfile[self.connector][0]

      if (self.xx.file_exists(filename=connector_file)):
         gotit += 1
      else:
         print self.connector, ":  connector file does not exist"

      if (gotit == goodlen):
         self.avail = 1
      else:
         self.avail = 0

      return

   #
   #   User function.  Just return wherher or 
   #   not the connector has been installed on the target.
   #
   def is_connector_available(self):

      return self.avail

   #
   #   Get the connector distribution zip file.
   #
   def get_connector_zip_file(self):

      cmdstring = "curl -k --get " + self.connurl[self.connector][0] + " --output " + self.connurl[self.connector][1]
      cmdunzip = "unzip -uo " +  self.connurl[self.connector][1]

      p = subprocess.Popen(cmdstring, shell=True)
      os.waitpid(p.pid, 0)

      p = subprocess.Popen(cmdunzip, shell=True)
      os.waitpid(p.pid, 0)
 
      return

   #
   #   This puts the connector distribution zip 
   #   file on the target machine.  Failures here
   #   are usually because there is no write permisison 
   #   for the IIS user in the Vivismo virtual
   #   directory. 
   #
   #   This builds a path to, and uses, the curl command 
   #   that is installed with Velocity.  Makes
   #   the assumption that it is there a safe one.
   #
   def put_connector_zip_file(self):

      if ( self.xx.TENV.targetos == "windows" ):
         sep = "\\"
         curlcmd = ''.join([self.vivdir, sep, 'bin', sep, 'curl'])
         cmdcurl = ''.join([curlcmd, ' -k --get ', self.connurl[self.connector][0], ' --output ', self.vivdir, sep, self.connurl[self.connector][1]])
      else:
         cmdcurl = self.vivdir + "/bin/curl -k --get " + self.connurl[self.connector][0] + " --output " + self.vivdir + "/" + self.connurl[self.connector][1]

      print cmdcurl

      err = self.xx.execute_command_as_root(cmd=cmdcurl, binary=0)
      print err

      return

   #
   #   This does the actual installation of the connector.  
   #   It unpacks/unzips the connector
   #   distribution file on the target.  It gets a local copy 
   #   of the connector package and
   #   unpacks it to make the function xml files available.  It 
   #   then uses the function xml
   #   to update the Velocity repository using the APIs.
   #
   #   Again, it safely assumes that unzip and curl are present 
   #   because it uses the unzip that is
   #   installed with Velocity on the target.  Locally, 
   #   this stuff only runs on linux so our use of
   #   curl and unzip is, again, safe.
   #
   def install_connector(self):

      function_dir = "data/repository-supplements/function."
     
      if ( self.xx.TENV.targetos == "windows" ):
         sep = "\\"
         cmdunzip = "cmd.exe /C " + self.vivdir + sep + "bin" + sep + "unzip -uo -d " + self.vivdir + " " + self.vivdir + sep + self.connurl[self.connector][1]
      else:
         cmdunzip = "unzip -uo -d " + self.vivdir + " " + self.vivdir + "/" + self.connurl[self.connector][1]

      #
      #   Put connector to target machine
      #
      self.put_connector_zip_file()
      #
      #   Upack connector on target machine.
      #
      print cmdunzip
      #wait a few seconds for the file to finish queuing to disk beofre trying to use it - stupid windows tricks
      time.sleep(5)

      self.xx.execute_command_as_root(cmd=cmdunzip, binary=0)
      self.xx.force_unpack()

      self.set_connector_avail()

      if ( self.is_connector_available() ):
         return

      #
      #   Get a local copy of the connector distribution
      #
      self.get_connector_zip_file()

      for item in self.connfunc[self.connector]:
         xmlfile = function_dir + item + ".xml"
         try:
            print "Adding connector function to repository."
            self.yy.api_repository_add(xmlfile=xmlfile)
         except:
            try:
               print "Repository add(connector function) failed, attempting update."
               self.yy.api_repository_update(xmlfile=xmlfile)
            except:
               print "Repository add/update(connector function) failed -- function NOT added."
 
      return
