#!/usr/bin/python

import os, sys, string, subprocess
from conenv import VIVTENV

############################################

class VIVTCMD(object):

   name = None
   dir = None
   cmdtype = None
   options = None

   TENV = None

   #########################################

   def __init__(self, command, cmdtype=None, opts=None, target=None):

      self.TENV = VIVTENV(target=target)

      self.name = command

      self.setcmdtype(cmdtype)
      self.setopts(opts)
      self.cmdpath()
     
      return


   def setcmdtype(self, cmdtype):

      if ( cmdtype != None):

         if ( self.cmdtype != cmdtype ):
            self.setcmdpath()

         self.cmdtype = cmdtype

      return

   def setopts(self, opts):

      if ( opts != None):
         if ( self.options == None ):
            self.options = opts
         else:
            self.options = string.join((self.options, opts), ' ')

      return

   #########################################
   #
   #   Find the command path on the target
   #
   def cmdpath(self):

      mycmd = string.join(('vivisimo_dir'), '')
      myargs= string.join(('-H', self.TENV.target, '-D', self.cmdtype), ' ')

      try:
         p = subprocess.Popen([mycmd, myargs],
                              stdin=None,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE)
         os.waitpid(p.pid, 0)
         (csout, cserr) = (p.stdout, p.stderr)

         self.dir = string.join((csout), '')
      except OSError, e:
         print "Could not execute ", mycmd, ": ", e

      return

   #########################################
   #
   #   Execute the command
   #
   def fireremcmd(self, opts=None):
 
      if ( opts != None ):
         if ( self.options != None ):
            localopts = string.join((self.options, opts), ' ')
         else:
            localopts = opts
      else:
         localopts = self.options

      wget = "wget"
      action = "execute"
      if ( self.TENV.targetos != "windows" ):
         mycmd = "gronk"
      else:
         mycmd = "gronk.exe"

      if ( localopts == None ):
         httpstring = string.join(('http://', self.TENV.target,
                                   '/vivisimo/cgi-bin/', mycmd,
                                   '?action=', action,
                                   '&command=', self.dir, '/',
                                   self.name, '&type=binary'), '')
      else:
         httpstring = string.join(('http://', self.TENV.target,
                                   '/vivisimo/cgi-bin/', mycmd,
                                   '?action=', action,
                                   '&command=', self.dir, '/',
                                   self.name, ' ', localopts,
                                   '&type=binary'), '')

      wgetopts = string.join(('\'', httpstring, '\'', ' -o ', '/dev/null',
                              ' -O ', '/dev/null'), '')
      #wgetopts = string.join(('\'', httpstring, '\'', ' -o ', self.name,
      #                        '.getlog -O ', self.name), '')

      #print "fCMD:  ", self.name
      #print "fARGS: ", self.options

      try:
         #print wget, wgetopts
         p = subprocess.Popen(wget + ' ' + wgetopts, shell=True)
         #p = subprocess.Popen([wget, wgetopts])
         os.waitpid(p.pid, 0)
      except OSError, e:
         print "Could not execute ", mycmd, ": ", e

      return

   #########################################
   #
   #   Set the command path for the target machine
   #   Basically, a doorway which check the allowed conditions
   #
   def setcmdpath(self):

      if (( self.TENV.target != None ) and ( self.cmdtype != None )):
         self.cmdpath()

      return

   #########################################
   #
   #   Set the command path for the target machine
   #   Basically, a doorway which check the allowed conditions
   #
   def getcmdpath(self):

      return self.dir
 

   #########################################
   #
   #   Find the target machine
   #
   def find_target(self, target=None):

      oldtarget = self.TENV.target

      self.TENV.find_target(target=target)

      if ( target != oldtarget ):
         self.setcmdpath()

      return

   #########################################

if __name__ == "__main__":
   cmd = VIVTCMD("xlhtml", target="testbed4", cmdtype="converter", opts="-te")
   cmd.setopts("/tmp/junkfile")

   cmd.find_target(target="testbed2-2")
   print "FULL OPTS: ", cmd.options
   print "LAST TARGET: ", cmd.TENV.target
   print "LAST DIRECTORY: ", cmd.dir
   cmd.fireremcmd()

