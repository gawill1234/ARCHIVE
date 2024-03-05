#!/usr/bin/python
# -*- coding: utf-8 -*-

import subprocess, os, time, sys

class RUN_BULK_LOADER(object):

   cmd_params = {}

   valid_list = ['folder', 'tree', 'file', 'document', 'title', 'name',
                 'list', 'listitem', 'listitembunch', 'listbunch',
                 'create', 'delete', 'update', 'showall', 'quickcheck',
                 'port', 'site', 'user', 'pw', 'domain', 'mountpoint',
                 'connector', 'itemname']

   def __init__(self, **cmd_params):

      self.cmd_params = cmd_params

   #
   #   Add a parameter to the dictionary
   #   It will be like self.cmd_params['<param_name>'] = <param_value>
   #   All of this will be used by the command line builder and
   #   then executed.
   #
   def add_cmd_parameter(self, param_name=None, param_value=None):

      if ( self.isInList(param_name, self.valid_list) ):
         if ( param_value is not None ):
            self.cmd_params[param_name] = param_value
         else:
            self.cmd_params[param_name] = ''
      else:
         print "Invalid parameter name: ", param_name
         return(-1)

      return(0)

   #
   #   Return the current set of parameters
   #
   def get_cmd_params_list(self):

      return self.cmd_params

   def isInList(self, checkfor, thelist):
   
      for item in thelist:
         if ( item == checkfor ):
            return 1
   
      return 0

   #
   #   Reset all of the parameters except those associated with
   #   creating the connection to the target.
   #
   def reset_non_connection_params(self):

       try:
          self.connector = self.cmd_params['connector']
       except:
          self.connector = None

       try:
          self.site = self.cmd_params['site']
       except:
          self.site = None

       try:
          self.user = self.cmd_params['user']
       except:
          self.user = None

       try:
          self.pw = self.cmd_params['pw']
       except:
          self.pw = None

       try:
          self.port = self.cmd_params['port']
       except:
          self.port = None

       try:
          self.domain = self.cmd_params['domain']
       except:
          self.domain = None


       self.cmd_params = {}

       if ( self.site is not None ):
          self.cmd_params['site'] = self.site
       if ( self.user is not None ):
          self.cmd_params['user'] = self.user
       if ( self.pw is not None ):
          self.cmd_params['pw'] = self.pw
       if ( self.port is not None ):
          self.cmd_params['port'] = self.port
       if ( self.domain is not None ):
          self.cmd_params['domain'] = self.domain
       if ( self.connector is not None ):
          self.cmd_params['connector'] = self.connector
   
       return

   #
   #   reset all of the parameters
   #
   def clear_all_params(self):

       self.cmd_params = {}
   
       return
   
   #
   #   Execute the command with the created option line.
   #
   def exec_command_stdout(self, cmd, cmdopts, fp=None):
   
         p = None
   
         try:
            if ( fp is not None ):
               p = subprocess.Popen(cmd + ' ' + cmdopts + ' ' + fp, shell=True)
               os.waitpid(p.pid, 0)
            else:
               p = subprocess.Popen(cmd + ' ' + cmdopts, shell=True, stdout=subprocess.PIPE).communicate()[0]
         except OSError, e:
            time.sleep(1)
            try:
               if ( fp is not None ):
                  p = subprocess.Popen(cmd + ' ' + cmdopts + ' ' + fp, shell=True)
                  os.waitpid(p.pid, 0)
               else:
                  p = subprocess.Popen(cmd + ' ' + cmdopts, shell=True, stdout=subprocess.PIPE).communicate()[0]
            except OSError, e:
               print "Could not execute ", cmd, ": ", e
               return None
   
         return p
   
   #
   #   Create the command line by adding the options and values to it.
   #
   def add_it_to_the_cmd_line(self, cmdstring=None, dowhat=None, argument=None):
   
      if (argument is None or argument == ''):
         cmdstring = cmdstring + ' -' + dowhat
      else:
         if (argument is not None and argument != '' ):
            cmdstring = cmdstring + ' -' + dowhat  + ' ' + argument
   
      return cmdstring
   
   
   #
   #   Build the command line
   #
   def build_command(self):
   
       cmd = 'run_bulk_loader'
       cmdstring = ''
   
       for key, value in self.cmd_params.items():
          if ( value is not None ):
             #
             #   This is here because it is possible to do a bulk
             #   a = b to set the parameters in __init__ without
             #   checking their validity.
             #
             if ( self.isInList(key, self.valid_list) ):
                cmdstring = self.add_it_to_the_cmd_line(cmdstring, key, value)
   
       return cmd, cmdstring
   
   
   #
   #   Build the command line and execute the command
   #
   def run_doc_update(self, **cmd_params):
   
      cmd, cmdstring = self.build_command(**cmd_params)
   
      print cmdstring
   
      y = self.exec_command_stdout(cmd=cmd, cmdopts=cmdstring, fp='&> querywork/addit')
   
      return
   
   
