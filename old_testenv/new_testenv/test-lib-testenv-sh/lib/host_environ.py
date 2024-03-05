
import os, sys, re
import cgi_interface
import vapi_interface

class HOSTENVIRON(object):

   testbeds = {}

   testbedlist = ['testbed1', 'testbed2', 'testbed3', 'testbed4',
                  'testbed5', 'testbed6', 'testbed7', 'testbed8',
                  'testbed9', 'testbed10', 'testbed11', 'testbed12',
                  'testbed13', 'testbed14', 'testbed15', 'testbed16',
                  'testbed16-1', 'testbed16-2', 'testbed16-3', 'testbed16-4',
                  'testbed1.test.vivisimo.com',
                  'testbed2.test.vivisimo.com',
                  'testbed3.test.vivisimo.com',
                  'testbed4.test.vivisimo.com',
                  'testbed5.test.vivisimo.com',
                  'testbed6.test.vivisimo.com',
                  'testbed7.test.vivisimo.com',
                  'testbed8.test.vivisimo.com',
                  'testbed9.test.vivisimo.com',
                  'testbed10.test.vivisimo.com',
                  'testbed11.test.vivisimo.com',
                  'testbed12.test.vivisimo.com',
                  'testbed13.test.vivisimo.com',
                  'testbed14.test.vivisimo.com',
                  'testbed15.test.vivisimo.com',
                  'testbed16.test.vivisimo.com',
                  'testbed16-1.test.vivisimo.com',
                  'testbed16-2.test.vivisimo.com',
                  'testbed16-3.test.vivisimo.com',
                  'testbed16-4.test.vivisimo.com',
                  'testbed17',
                  'testbed18',
                  'testbed19',
                  'testbed20',
                  'testbed17.test.vivisimo.com',
                  'testbed18.test.vivisimo.com',
                  'testbed19.test.vivisimo.com',
                  'testbed20.test.vivisimo.com',
                  'symc-slim',
                  'symc-slim.vivisimo.com']

   testbeds['testbed1'] = ['linux64', 'linux', 'linux']
   testbeds['testbed2'] = ['windows64', 'windows', 'windows']
   testbeds['testbed3'] = ['linux64', 'linux', 'linux']
   testbeds['testbed4'] = ['linux64', 'linux', 'linux']
   testbeds['testbed5'] = ['linux64', 'linux', 'linux']
   testbeds['testbed6'] = ['linux64', 'linux', 'linux']
   testbeds['testbed7'] = ['solaris32', 'solaris', 'solaris']
   testbeds['testbed8'] = ['windows32', 'windows', 'windows']
   testbeds['testbed9'] = ['windows64', 'windows', 'windows']
   testbeds['testbed10'] = ['linux32', 'linux', 'linux']
   testbeds['testbed11'] = ['windows32', 'windows', 'windows']
   testbeds['testbed12'] = ['solaris64', 'solaris', 'solaris']
   testbeds['testbed13'] = ['windows64', 'windows', 'windows']
   testbeds['testbed14'] = ['linux64', 'linux', 'linux']
   testbeds['testbed15'] = ['windows64', 'windows', 'windows']
   testbeds['testbed16'] = ['windows64', 'windows', 'windows']
   testbeds['testbed16-1'] = ['linux64', 'linux', 'linux']
   testbeds['testbed16-2'] = ['linux64', 'linux', 'linux']
   testbeds['testbed16-3'] = ['windows64', 'windows', 'windows']
   testbeds['testbed16-4'] = ['windows64', 'windows', 'windows']
   testbeds['testbed17'] = ['windows64', 'windows', 'windows']
   testbeds['testbed18'] = []
   testbeds['testbed19'] = []
   testbeds['testbed20'] = []
   testbeds['symc-slim'] = ['windows64', 'windows', 'windows']
   testbeds['testbed1.test.vivisimo.com'] = ['linux64', 'linux', 'linux']
   testbeds['testbed2.test.vivisimo.com'] = ['windows64', 'windows', 'windows']
   testbeds['testbed3.test.vivisimo.com'] = ['linux64', 'linux', 'linux']
   testbeds['testbed4.test.vivisimo.com'] = ['linux64', 'linux', 'linux']
   testbeds['testbed5.test.vivisimo.com'] = ['linux64', 'linux', 'linux']
   testbeds['testbed6.test.vivisimo.com'] = ['linux64', 'linux', 'linux']
   testbeds['testbed7.test.vivisimo.com'] = ['solaris32', 'solaris', 'solaris']
   testbeds['testbed8.test.vivisimo.com'] = ['windows32', 'windows', 'windows']
   testbeds['testbed9.test.vivisimo.com'] = ['windows64', 'windows', 'windows']
   testbeds['testbed10.test.vivisimo.com'] = ['linux32', 'linux', 'linux']
   testbeds['testbed11.test.vivisimo.com'] = ['windows32', 'windows', 'windows']
   testbeds['testbed12.test.vivisimo.com'] = ['solaris64', 'solaris', 'solaris']
   testbeds['testbed13.test.vivisimo.com'] = ['windows64', 'windows', 'windows']
   testbeds['testbed14.test.vivisimo.com'] = ['linux64', 'linux', 'linux']
   testbeds['testbed15.test.vivisimo.com'] = ['windows64', 'windows', 'windows']
   testbeds['testbed16.test.vivisimo.com'] = ['windows64', 'windows', 'windows']
   testbeds['testbed16-1.test.vivisimo.com'] = ['linux64', 'linux', 'linux']
   testbeds['testbed16-2.test.vivisimo.com'] = ['linux64', 'linux', 'linux']
   testbeds['testbed16-3.test.vivisimo.com'] = ['windows64', 'windows', 'windows']
   testbeds['testbed16-4.test.vivisimo.com'] = ['windows64', 'windows', 'windows']
   testbeds['testbed17.test.vivisimo.com'] = ['windows64', 'windows', 'windows']
   testbeds['testbed18.test.vivisimo.com'] = []
   testbeds['testbed19.test.vivisimo.com'] = []
   testbeds['testbed20.test.vivisimo.com'] = []
   testbeds['symc-slim.vivisimo.com'] = ['windows64', 'windows', 'windows']

   cgi = None
   vapi = None

   def __init__(self, hostname=None, user=None, pw=None,
                      port=None, vproject=None, target=None,
                      arch=None, troot=None, vers=None,
                      vdir=None, partner=None, killall=None,
                      osstring=None, vwipe=None, vdel=None,
                      subc=None, configfile=None):

      self.hostValues = {}

      orig_hostname = hostname
      env_hostname = os.getenv('VIVHOST')

      if ( configfile is None ):
         configfile = self.look_for_cfg_file(hostname=hostname)

      if ( configfile is not None ):
         hostname, host_data_list = self.process_config_file(cfg=configfile,
                                                             hostname=hostname)
         self.add_to_testbeds(host_data_list)
      else:
         if ( os.access('host_environ.cfg', os.R_OK) == 1 ):
            host_data_list = self.host_list_reader()
            if ( len(host_data_list) > 0 ):
               self.add_to_testbeds(host_data_list)

      if ( hostname is not None ):
         if ( not self.isfqdn(hostname) ):
            self.hostValues['VIVHOST'] = ''.join([hostname, '.test.vivisimo.com'])
            hostname = self.hostValues['VIVHOST']
         else:
            self.hostValues['VIVHOST'] = hostname
      else:
         hostname = os.getenv('VIVHOST')
         if ( not self.isfqdn(hostname) ):
            self.hostValues['VIVHOST'] = ''.join([hostname, '.test.vivisimo.com'])
            hostname = self.hostValues['VIVHOST']

      print "###########################################"
      print "INITA: ", hostname
      print "INITB: ", self.hostValues['VIVHOST']
      print "###########################################"

      self.fixed_hostValues(hostname, 'TEST_ROOT', troot, None)


      #
      # config file line should look like this:
      # host_fqdn::arch::targetos::osstring::vivport::user::pw::http_port
      #
      # example:
      # testbed4.test.vivismo.com::linux64::linux::linux::7205::gaw::blah::80
      #
      self.setable_hostValues(hostname, 'VIVTARGETARCH', arch, 1, 'linux64')
      self.setable_hostValues(hostname, 'VIVTARGETOS', target, 2, 'linux')
      self.setable_hostValues(hostname, 'OSSTRING', target, 3, 'linux')
      self.setable_hostValues(hostname, 'VIVPORT', port, 4, '7205')
      self.setable_hostValues(hostname, 'VIVUSER', user, 5, 'gary_testing')
      self.setable_hostValues(hostname, 'VIVPW', pw, 6, 'mustang5')
      self.setable_hostValues(hostname, 'VIVHTTPPORT', port, 7, '80')
      self.setable_hostValues(hostname, 'VIVVIRTUALDIR', vdir, 8, 'vivisimo')

      self.fixed_hostValues(hostname, 'VIVPROJECT', vproject, 'query-meta')
      self.fixed_hostValues(hostname, 'VIVVERSION', vers, '8.0')
      self.fixed_hostValues(hostname, 'VIVPARTNER', partner, 'Vivisimo')
      self.fixed_hostValues(hostname, 'VIVKILLALL', killall, True)
      self.fixed_hostValues(hostname, 'VIVWIPE', vwipe, False)
      self.fixed_hostValues(hostname, 'VIVDELETE', vdel, 'never')
      self.fixed_hostValues(hostname, 'DEFAULTSUBCOLLECTION', subc, 'live')

      self.set_up_interfaces()

      return

   def look_for_cfg_file(self, hostname=None):

      if ( hostname is None ):
         return None

      fname = hostname + '.cfg'
      fname2 = None
      if ( self.isfqdn(hostname) ):
         basenm = hostname.split('.')[0]
         fname2 = basenm + '.cfg'

      if ( os.access(fname, os.R_OK) == 1 ):
         return fname
      else:
         if ( fname2 is not None ):
            if ( os.access(fname2, os.R_OK) == 1 ):
               return fname2

      return None

   def process_config_file(self, cfg=None, hostname=None):

      varvalues = {'VIVHOST' : 0,
                   'VIVTARGETARCH' : 1,
                   'VIVTARGETOS' : 2,
                   'OSSTRING' : 3,
                   'VIVPORT' : 4,
                   'VIVUSER' : 5,
                   'VIVPW' : 6,
                   'VIVHTTPPORT' : 7,
                   'VIVVIRTUALDIR' : 8}

      revvarvalues = { 0 : 'VIVHOST',
                       1 : 'VIVTARGETARCH',
                       2 : 'VIVTARGETOS',
                       3 : 'OSSTRING',
                       4 : 'VIVPORT',
                       5 : 'VIVUSER',
                       6 : 'VIVPW',
                       7 : 'VIVHTTPPORT',
                       8 : 'VIVVIRTUALDIR'}
      mydef = { 0 : None,
                1 : 'linux64',
                2 : 'linux',
                3 : 'linux',
                4 : '7205',
                5 : 'gary_testing',
                6 : 'mustang5',
                7 : '80',
                8 : 'vivisimo'}

      local_list = [None, None, None, None, None, None, None, None, None]
      host_data_list = []

      if ( cfg is None ):
         return

      if ( os.access(cfg, os.R_OK) == 1 ):
         f = open(cfg)
      else:
         return None, None

      for item in f.readlines():
         if ( item[0] != '#' ):
            item = item.strip('\n')
            eh = re.search('export.*', item)
            viv = None
            if ( eh is not None ):
               viv = re.search('VIV.*', eh.group(0))
               if ( viv is None ):
                  viv = re.search('OSSTRING.*', eh.group(0))
            if ( viv is not None ):
               values = viv.group(0).split('=')
               place = varvalues[values[0]]
               if ( place >= 0 ):
                  local_list[place] = values[1].strip('"')
               if ( place == 0 ):
                  hostname = values[1].strip('"')

      f.close()

      #
      #   If we sent in no host, get the global one.
      #
      if ( hostname is None ):
         hostname = os.getenv('VIVHOST')

      #
      #   If the config file had no host, use ours.  This way,
      #   if we had passed in a host it would be favored over
      #   the environment host.
      #
      if ( local_list[0] is None ):
         local_list[0] = hostname

      #
      #   Anything that is still empty, get from the environment.
      #
      zz = 0
      for item in local_list:
         if ( item is None ):
            local_list[zz] = os.getenv(revvarvalues[zz], mydef[zz])
         zz += 1

      #
      #   Make the local list look like the list file list
      #
      host_data_list.append(local_list)

      return hostname, host_data_list


   def setable_hostValues(self, hostname, vivwhat, notnone,
                                listminlen, defaultvalue):

      try:
         if ( notnone is not None ):
            self.hostValues[vivwhat] = notnone
         elif ( len(self.testbeds[hostname]) >= listminlen ):
            self.hostValues[vivwhat] = self.testbeds[hostname][listminlen - 1]
         else:
            self.hostValues[vivwhat] = os.getenv(vivwhat, defaultvalue)
      except KeyError:
         self.hostValues[vivwhat] = os.getenv(vivwhat, defaultvalue)

      return

   def fixed_hostValues(self, hostname, vivwhat, notnone, defaultvalue):

      if ( notnone is not None ):
         self.hostValues[vivwhat] = notnone
      else:
         self.hostValues[vivwhat] = os.getenv(vivwhat, defaultvalue)

      return

   def isfqdn(self, name=None):

      domain_tail = ['com', 'net', 'org', 'xxx']

      justthename = name.split(':')
      tail = justthename[0].split('.')

      z = len(tail)
      z = z - 1

      for item in domain_tail:
         if ( tail[z] == item ):
            return True

      return False

   def get_fqdn(self):

      return self.hostValues['VIVHOST']


   def set_host_environment(self):

      os.environ['VIVHOST'] = self.hostValues['VIVHOST']

      os.environ['VIVUSER'] = self.hostValues['VIVUSER']
      os.environ['VIVPW'] = self.hostValues['VIVPW']

      os.environ['VIVPORT'] = self.hostValues['VIVPORT']
      os.environ['VIVHTTPPORT'] = self.hostValues['VIVHTTPPORT']
      os.environ['DEFAULTSUBCOLLECTION'] = self.hostValues['DEFAULTSUBCOLLECTION']

      os.environ['VIVPROJECT'] = self.hostValues['VIVPROJECT']

      os.environ['VIVTARGETOS'] = self.hostValues['VIVTARGETOS']
      os.environ['VIVTARGETARCH'] = self.hostValues['VIVTARGETARCH']

      os.environ['TEST_ROOT'] = self.hostValues['TEST_ROOT']

      os.environ['VIVVERSION'] = self.hostValues['VIVVERSION']
      os.environ['VIVVIRTUALDIR'] = self.hostValues['VIVVIRTUALDIR']
      os.environ['VIVPARTNER'] = self.hostValues['VIVPARTNER']

      os.environ['VIVKILLALL'] = self.hostValues['VIVKILLALL']
      os.environ['VIVDELETE'] = self.hostValues['VIVDELETE']
      os.environ['VIVWIPE'] = self.hostValues['VIVWIPE']
      os.environ['OSSTRING'] = self.hostValues['OSSTRING']

      return

   def dump_host_data(self):

      print "Host name:", self.hostValues['VIVHOST']
      print "Host user:", self.hostValues['VIVUSER']
      print "Host pw:", self.hostValues['VIVPW']
      print "Host version:", self.hostValues['VIVVERSION']
      print "Host port:", self.hostValues['VIVPORT']
      print "Host project:", self.hostValues['VIVPROJECT']
      print "Host root:", self.hostValues['TEST_ROOT']

      return

   def set_up_interfaces(self):

      self.set_host_environment()

      self.cgi = cgi_interface.CGIINTERFACE()
      self.vapi = vapi_interface.VAPIINTERFACE()

      return

   def dump_testbeds(self):

      for item in self.testbedlist:
         if (len(self.testbeds[item]) >= 3 ):
            print item, self.testbeds[item]

      return

   def add_to_testbeds(self, host_data_list):

      for item in host_data_list:
         itemlen = len(item)
         if ( itemlen >= 2 ):
            itemlist = []
            zz = 1
            while ( zz < itemlen ):
               itemlist.append(item[zz])
               zz += 1
            self.testbeds[item[0]] = itemlist
            inMyList = False
            for thing in self.testbedlist:
               if ( item[0] == thing ):
                  inMyList = True
            if ( not inMyList ):
               self.testbedlist.append(item[0])
         else:
            print "Configured hosts list:  Not enough data, skipping"

      return

   def host_list_reader(self):

      f = open('host_environ.cfg')

      tmplist = []

      for item in f.readlines():
         if ( item[0] != '#' ):
            item = item.strip('\n')
            item = item.split('::')
            if ( len(item) >= 4 ):
               tmplist.append(item)

      f.close()

      return tmplist


