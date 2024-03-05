#!/usr/bin/python

import os, sys, string, subprocess, time
import urllib, urllib2
from toolenv import VIVTENV
from tc_generic import TCINTERFACE
from http_interface import HTTPINTERFACE
from datafiles import DATAFILES
import libxml2, re, random, shutil
import vapi_interface
from lxml import etree

############################################

class CGIINTERFACE(object):

   wget = "wget"
   gronk = "/vivisimo/cgi-bin/gronk"
   search = "/search"
   apps = "/vivisimo/cgi-bin/velocity"
   qmeta = "/vivisimo/cgi-bin/query-meta"
   admin = "/vivisimo/cgi-bin/admin"
   dump = "/vivisimo/bin/dump"
   errlog = "/dev/null"
   outlog = "/dev/null"
   targetdir = "/tmp"
   workingdir = "querywork"
   cmpfiledir = "query_cmp_files"
   logfiledir = "logs"
   collectionname = None
   perfdata = "perfdata/tperf"
   perfdatadir = None
   collectionxml = None
   index_name = None
   defconverters = None
   retrymax = 3
   filefd = 0
   vapi = None

   #
   #   Should we resuse an admin info file or not.
   #   Default is no.
   #
   save_file_reuse = 0

   #
   #   Variables to check for possible hangs
   #
   global_progress = 0
   global_progress_time = 0
   crawl_progress = 0
   crawl_progress_time = 0
   indexer_progress = 0
   indexer_progress_time = 0
   last_ops = 0
   last_idu = 0
   last_cerr = 0
   last_idoc = 0
   adminxmltime = 0

   #########################################

   def __init__(self, targetdir=None, workingdir=None, environment=[], use_cba=False):

      self.TENV = VIVTENV(envlist=environment)
      self.urlencoded_password = urllib.urlencode({'password':self.TENV.pswd}).split('=')[1]
      self.TCG = TCINTERFACE()

      self.tmpdir = ''.join([self.TENV.testroot, '/tmp'])
      if ( os.access(self.tmpdir, os.F_OK) == 0 ):
         try:
            os.mkdir(self.tmpdir)
         except OSError, e:
            print "Error creating", self.tmpdir, e

      self.HTTP = HTTPINTERFACE(site=self.TENV.target, port=self.TENV.httpport, env=self.TENV, use_cba=use_cba)
      # The Search Service is never protected by CBA, so always pass in FALSE
      self.srchHTTP = HTTPINTERFACE(site=self.TENV.target, port=self.TENV.port, env=self.TENV, use_cba=False)

      subdir = os.getenv('VIVASPXDIR', 'cgi-bin')
      grok = ''.join(['/cgi-bin/gronk'])
      admn = ''.join(['/cgi-bin/admin'])
      qrym = ''.join(['/cgi-bin/query-meta'])
      vlcy = ''.join(['/', subdir, '/velocity'])

      if ( subdir != 'cgi-bin' ):
         self.apps = ''.join(['/', self.TENV.virtualdir, vlcy, '.aspx'])
      else:
         if ( self.TENV.targetos == "windows" ):
            self.apps = ''.join(['/', self.TENV.virtualdir, vlcy, '.exe'])
         else:
            self.apps = ''.join(['/', self.TENV.virtualdir, vlcy])

      if ( self.TENV.targetos == "windows" ):
         self.gronk = ''.join(['/', self.TENV.virtualdir, grok, '.exe'])
         self.admin = ''.join(['/', self.TENV.virtualdir, admn, '.exe'])
         self.qmeta = ''.join(['/', self.TENV.virtualdir, qrym, '.exe'])
         self.dump = 'dump.exe'
      else:
         self.gronk = ''.join(['/', self.TENV.virtualdir, grok])
         self.admin = ''.join(['/', self.TENV.virtualdir, admn])
         self.qmeta = ''.join(['/', self.TENV.virtualdir, qrym])
         self.dump = 'dump'

      self.perfdata = ''.join([self.TENV.testroot, '/', self.perfdata, '.', self.TENV.targarch, '.', self.TENV.vivversion])

      self.perfdatadir = ''.join([self.TENV.testroot, '/perfdata'])

      self.defconverters = ''.join([self.TENV.testroot, '/lib/defconverters'])

      self.settargetdir(targetdir=targetdir)

      if ( os.access(self.workingdir, os.F_OK) == 0 ):
         try:
            os.mkdir(self.workingdir)
         except OSError, e:
            print "Error creating", self.workingdir, e

      if ( os.access(self.logfiledir, os.F_OK) == 0 ):
         try:
            os.mkdir(self.logfiledir)
         except OSError, e:
            print "Error creating", self.logfiledir, e

      if ( os.access(self.perfdatadir, os.F_OK) == 0 ):
         try:
            os.mkdir(self.perfdatadir)
         except OSError, e:
            print "Error creating", self.perfdatadir, e

      self.filefd = open(self.perfdata, 'a+')

      if ( self.TENV.targetos != "windows" ):
         self.preserve_repository()

      # Some of the methods in this class use the vapi instead of direct CGI calls
      self.vapi = vapi_interface.VAPIINTERFACE(use_cba=use_cba)

      return

   def version_check(self, minversion=None):

      if ( minversion == None ):
         return

      if ( self.TENV.vivfloatversion < minversion ):
         print "Test not supported in version", self.TENV.vivversion
         print "Minimum allowed version is", minversion
         print "Exit with failing value"
         sys.exit(-1)

      return

   def dumpperfdata(self, mystring=None):

      if ( mystring is not None ):
         if ( self.filefd is not None ):
            self.filefd.write(mystring)
            self.filefd.write('\n')

      return

   ###################################################################

   def is_testenv_mounted(self, checkfile=None):

      if ( checkfile is None ):
         checkfile = "/testenv/CHECKFILE"

      if ( os.access(checkfile, os.R_OK) == 1 ):
         print "/testenv is mounted.  We can continue"
         return

      print "TEST FAILED"
      print "/testenv is not mounted"
      print "Create a local directory name /testenv.  Then, as root, do:"
      print "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
      print "Then rerun the test"
      print "TEST FAILED"

      sys.exit(-1)

   ###################################################################

   def testtest(self):

      print "INTERNAL"
      print "VIVHOST:", self.TENV.target
      print "VIVUSER:", self.TENV.user
      print "VIVPW:", self.TENV.pswd
      print "VIVPORT:", self.TENV.port
      print "VIVPROJECT:", self.TENV.project
      print "VIVTARGETOS:", self.TENV.targetos
      print "VIVTARGETARCH:", self.TENV.targarch
      print "TEST_ROOT:", self.TENV.testroot
      print "VIVVERSION:", self.TENV.vivversion
      print "VIVVIRTUALDIR:", self.TENV.virtualdir
      print "VIVPARTNER:", self.TENV.partner
      print "VIVKILLALL:", self.TENV.killall
      print "PERFROMANCE DATA FILE:", self.perfdata

      #print "EXTERNAL"
      #print "VIVHOST:", os.getenv('VIVHOST')
      #print "VIVUSER:", os.getenv('VIVUSER')
      #print "VIVPW:", os.getenv('VIVPW')
      #print "VIVPORT:", os.getenv('VIVPORT')
      #print "VIVPROJECT:", os.getenv('VIVPROJECT')
      #print "VIVTARGETOS:", os.getenv('VIVTARGETOS')
      #print "VIVTARGETARCH:", os.getenv('VIVTARGETARCH')
      #print "TEST_ROOT:", os.getenv('TEST_ROOT')
      #print "VIVVERSION:", os.getenv('VIVVERSION')
      #print "VIVVIRTUALDIR:", os.getenv('VIVVIRTUALDIR')
      #print "VIVPARTNER:", os.getenv('VIVPARTNER')
      #print "VIVKILLALL:", os.getenv('VIVKILLALL')
      #print "PERFROMANCE DATA FILE:", self.perfdata

      return 99

   #########################################
   #
   #   Initialize the target directory on the
   #   target machine
   #
   def resultdir(self, resdir=None):
      if ( resdir == None ):
         self.resdir = "querywork"
      else:
         self.resdir = resdir

      return

   #########################################
   #
   #   Initialize the target directory on the
   #   target machine
   #
   def settargetdir(self, targetdir=None):

      if ( targetdir == None ):
         if ( self.TENV.targetos == "windows" ):
            self.targetdir = "C:\\temp"
         else:
            self.targetdir = "/tmp"
      else:
         self.targetdir = targetdir

      return

   #########################################
   #
   #   Initialize the target directory on the
   #   target machine
   #
   def gettargetdir(self):

      if ( self.targetdir == None ):
         if ( self.TENV.targetos == "windows" ):
            self.targetdir = "C:\\temp"
         else:
            self.targetdir = "/tmp"

      return self.targetdir

   def get_repo_elem_name(self, collection=None, trib="collection",
                          searchfile=None):

      cmd = "xsltproc"

      if ( collection == None ):
         return

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
      opts = ''.join(['--stringparam mynode repo-item --stringparam mytrib ', trib])
      if ( searchfile == None ):
         dumpit = ''.join(['querywork/', collection, '.xml.wazzat'])
      else:
         dumpit = searchfile

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = self.exec_command_stdout(cmd, cmdopts, None)

      return y

   def get_md5_name(self, collection=None, searchfile=None):

      cmd = "xsltproc"

      if ( collection == None ):
         return

      arg1 = ''.join([self.TENV.testroot, '/utils/xsl/parse_admin_60.xsl'])
      opts = '--stringparam mynode wcdict-name'
      if ( searchfile == None ):
         dumpit = ''.join(['querywork/', collection, '.admin.xml'])
      else:
         dumpit = searchfile

      cmdopts = ' '.join([opts, arg1, dumpit])

      y = self.exec_command_stdout(cmd, cmdopts, None)

      return y

   def repo_collection_exists(self, collection=None):

      if ( collection == None ):
         return

      if ( self.TENV.vivfloatversion >= 7.0 ):
         vfunc = "repository-get"
         elemtype = "vse-collection"

         httpcmd = self.apps

         dumpit = ''.join(['querywork/', collection, '.xml.wazzat'])

         appname = 'api-rest'

         httpstring = ''.join(['v.app=', appname,
                               '&v.function=', vfunc,
                               '&element=', elemtype,
                               '&name=', collection])

         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                               dumpfile=dumpit)
      else:
         dumpit = ''.join([collection, ".xml.raw"])
         self.get_raw_collection(collectionname=collection)

      if ( os.stat(dumpit).st_size > 0 ):
         xmlcollection = self.get_repo_elem_name(collection=collection,
                                                 searchfile=dumpit)
      else:
         xmlcollection = None

      if ( xmlcollection is not None ):
         if ( xmlcollection == collection ):
            return 1

      #
      #   If the xml is not found, get rid of the empty file.
      #
      os.remove(dumpit)

      return 0

   #########################################
   #
   #   Run xsltproc.  No user input
   #

   def runxsltproc(self, which, file, opts=None, outfile=None):

      cmd = "xsltproc"
      fp = None

      go = 0
      if ( os.access(file, os.F_OK) != 0 ):
         xx = os.stat(file).st_size
         if ( xx > 0 ):
            go = 1

      if ( go == 0 ):
         return None

      if ( outfile is not None ):
         fp = ' '.join(['>', outfile, '2>/dev/null'])

      if ( which == "op_data" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/op_data.xsl'])
      if ( which == "bin_url" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/bin_url.xsl'])
      if ( which == "op_outcome" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/op_outcome.xsl'])
      if ( which == "stripper" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/stripper'])
      if ( which == "noscore_stripper" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/noscore_stripper'])
      if ( which == "binning_data_norm" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/binning_data_norm.xsl'])
      if ( which == "op_where" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/op_where.xsl'])
      if ( which == "crawl_dups" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/crawl_dups.xsl'])
      if ( which == "crawl_errors" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/crawl_errors.xsl'])
      if ( which == "crawl_output" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/crawl_output.xsl'])
      if ( which == "index_content" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/index_content.xsl'])
      if ( which == "index_docs" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/index_docs.xsl'])
      if ( which == "valid_index_docs" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/valid_index_docs.xsl'])
      if ( which == "raw_collection" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/collnode.xsl'])
      if ( which == "raw_source" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/sourcenode.xsl'])
      if ( which == "raw_function" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/functionnode.xsl'])
      if ( which == "raw_dictionary" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/dictionarynode.xsl'])
      if ( which == "index_files" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/index_file_list.xsl'])
      if ( which == "stag_status" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/stag_status.xsl'])
      if ( which == "bin_attribute" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/bin_attribute.xsl'])
      if ( which == "admin_error" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/admin_error.xsl'])
      if ( which == "query_xml" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/query_xml.xsl'])
      if ( which == "errors" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/errors.xsl'])
      if ( which == "pid-list" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/pid_list.xsl'])
      if ( which == "default_converters" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/extconvert.xsl'])
      if ( which == "add_default_converters" ):
         arg1 = ''.join([self.TENV.testroot, '/utils/xsl/chgconvert.xsl'])
      if ( which == "parse_admin" ):
         if ( self.TENV.vivfloatversion >= 6.0 ):
            arg1 = ''.join([self.TENV.testroot, '/utils/xsl/parse_admin_60.xsl'])
         else:
            arg1 = ''.join([self.TENV.testroot, '/utils/xsl/parse_admin.xsl'])

      if ( opts == None ):
         cmdopts = ' '.join([arg1, file])
      else:
         cmdopts = ' '.join([opts, arg1, file])

      xx = self.exec_command_stdout(cmd, cmdopts, fp)

      return xx

   #################################################
   #
   #   Set the object collection (for the moment)
   #
   def setcollection(self, collection=None):

      if ( collection == None ):
         return

      if ( collection.endswith(".xml") ):
         self.collectionxml = collection
         self.collectionname = os.path.basename(collection)
         self.collectionname = self.collectionname.strip(".xml")
      else:
         self.collectionxml = ''.join([collection, ".xml"])
         self.collectionname = os.path.basename(collection)

      return

   def donts(self, res=None, cmp=None):

      if ( self.cmpfiledir == None ):
         self.cmpfiledir = "query_cmp_files"

      if ( os.access(self.cmpfiledir, os.F_OK) == 0 ):
         os.mkdir(self.cmpfiledir)

      if ( os.access(cmp, os.F_OK) == 0 ):
         os.rename(res, cmp)

      return

   #########################################
   #
   #   Get and check an attribute of a bin
   #
   def check_bin_attribute(self, collection=None, attrib="label", num=1000):

      err = 1
      if ( collection == None ):
         return err

      self.setcollection(collection)

      self.get_bin_attribute(collectionname=collection,
                             attribname=attrib, num=num)

      xsldump = ''.join([collection, '.bin.', attrib])
      xsldump = ''.join([self.workingdir, '/', xsldump])

      resultfile = ''.join([collection, '.bin.', attrib, '.grep'])
      resultfile = ''.join([self.workingdir, '/', resultfile])

      comparefile = ''.join([collection, '.bin.', attrib, '.cmp'])
      comparefile = ''.join([self.cmpfiledir, '/', comparefile])

      difffile = ''.join([collection, '.bin.', attrib, '.diff'])
      difffile = ''.join([self.workingdir, '/', difffile])

      #
      #   Need to pythonize the diff and grep.  Did it this way because I
      #   just wanted to get the logic to work from a previous shell script.
      #
      try:
         xx = os.stat(xsldump).st_size
         if ( xx > 0 ):
            grepopts = ' '.join(['-v', '"<\?xml"', xsldump, '>', resultfile])
            p = subprocess.Popen('grep' + ' ' + grepopts, shell=True)
            os.waitpid(p.pid, 0)
            os.remove(xsldump)
            if ( self.TENV.newtestsave != "Yes" ):
               diffopts = ' '.join([comparefile, resultfile, '>', difffile])
               p = subprocess.Popen('diff' + ' ' + diffopts, shell=True)
               os.waitpid(p.pid, 0)
               err = p.returncode
               xx = os.stat(difffile).st_size
               if ( xx > 0 ):
                  err = 1
            else:
               self.donts(res=resultfile, cmp=comparefile)
               err = 0
      except OSError, e:
         print "Error in check_bin_attribute,", e

      if ( ( err == None ) or ( err == 0 ) ):
         print self.collectionname, ":", attrib, "bin attribute compare passed"
         err = 0
      else:
         print self.collectionname, ":", attrib, "bin attribute compare failed"
         print "see ", difffile

      print "################", self.collectionname, "end    ##################"

      return err

   #########################################
   #
   #   Get the contents of a bin
   #
   def check_bin(self, binlist="", collection=None, num=1000):

      err = 1
      if ( collection == None ):
         return err

      self.setcollection(collection)

      print "################", self.collectionname, "start  ##################"

      binfname = DATAFILES(binlist, "binning")

      FILENAME = binfname.getwanted("result", "xml")

      #  xsltproc output, grep input
      xsldump = ''.join([self.workingdir, '/bjnk'])

      #  xsltproc input
      rsltFILENAME = ''.join([self.workingdir, '/', FILENAME])

      #  diff left, exists at time test runs
      comparefile = binfname.getwanted("compare", "uri")
      comparefile = ''.join([self.cmpfiledir, '/', comparefile])

      #  diff right, grep output
      resultfile = binfname.getwanted("result", "uri")
      resultfile = ''.join([self.workingdir, '/', resultfile])

      #  diff output
      difffile = binfname.getwanted("diff", "uri")
      difffile = ''.join([self.workingdir, '/', difffile])

      self.get_bin(binlist=binlist, collection=collection, num=num)
      os.rename(FILENAME, rsltFILENAME)

      #
      #   Need to pythonize the diff and grep.  Did it this way because I
      #   just wanted to get the logic to work from a previous shell script.
      #
      self.runxsltproc("bin_url", rsltFILENAME, "--html --novalid", xsldump)
      try:
         xx = os.stat(xsldump).st_size
         if ( xx > 0 ):
            grepopts = ' '.join(["http", xsldump, '>', resultfile])
            p = subprocess.Popen('grep' + ' ' + grepopts, shell=True)
            os.waitpid(p.pid, 0)
            os.remove(xsldump)
            if ( self.TENV.newtestsave != "Yes" ):
               diffopts = ' '.join([comparefile, resultfile, '>', difffile])
               p = subprocess.Popen('diff' + ' ' + diffopts, shell=True)
               os.waitpid(p.pid, 0)
               err = p.returncode
               xx = os.stat(difffile).st_size
               if ( xx > 0 ):
                  err = 1
            else:
               self.donts(res=resultfile, cmp=comparefile)
               err = 0
      except OSError, e:
         print "Error in check_bin,", e

      if ( ( err == None ) or ( err == 0 ) ):
         print self.collectionname, ":", binlist, "bin URI compare passed"
         err = 0
      else:
         print self.collectionname, ":", binlist, "bin URI compare failed"
         print "see ", difffile

      print "################", self.collectionname, "end    ##################"

      return err

   #########################################
   #
   #   Get the contents of admin page for a collection
   #
   def get_collection_admin_xml(self, collection=None):

      if ( collection == None ):
         return 1

      self.setcollection(collection)

      interim = ''.join(['querywork/', collection, '.admin.xml'])

      #
      #   Assume we will be getting a new copy of the file
      #
      get_new_file = 1

      #
      #   Check to see if the assumption is correct
      #   Conditions to reuse the file:
      #      1)  I have permission
      #      2)  The file exists
      #      3)  File size is greater than 0
      #      4)  File age is less than 1.5 second
      #
      if ( self.save_file_reuse == 1 ):
         if ( os.access(interim, os.F_OK) != 0 ):
            xx = os.stat(interim)
            q = time.time()
            if ( xx.st_size > 0 ):
               if ( self.adminxmltime != 0 ):
                  td = q - self.adminxmltime
                  if ( td < 1.5 ):
                     #print "USE OLD FILE:", td
                     get_new_file = 0
                     err = 0
                  #else:
                  #   print "USE NEW FILE:", td

      if ( self.collection_exists(self.collectionname) == 0 ):
         print "ERROR:  Collection does not exist:", self.collectionname
         return None

      #
      #   If we are getting a new copy of the file ...
      #
      if ( get_new_file == 1 ):
         httpcmd = self.admin
         httpstring = ''.join(['id=se.overview',
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password,
                               '&xml=-1'])

         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)
         self.adminxmltime = time.time()

      return err

   #########################################
   #
   #   Get the contents of admin page for a collection
   #
   def get_collection_admin(self, collection=None):

      if ( collection == None ):
         return 1

      self.setcollection(collection)

      interim = ''.join(['querywork/', collection, '.admin.html'])

      httpcmd = self.admin
      httpstring = ''.join(['id=se.overview',
                            '&collection=', self.collectionname,
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)

      return 0

   #########################################
   #
   #   Get the contents of admin page for a collection
   #
   def admin_unpack(self):

      interim = ''.join(['querywork/', 'unpack.html'])

      httpcmd = self.admin
      httpstring = ''.join(['&username=', self.TENV.user,
                            '&password=', self.urlencoded_password,
                            '&id=bootstrap.check',
                            '&force-unpack=true'])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)

      return 0

   #########################################
   #
   #   Run an apps/velocity application.
   #
   def run_velocity(self, appname=None, runargs=None):

      if ( appname == None ):
         return 1

      interim = ''.join(['querywork/', appname, '.velocity'])

      httpcmd = self.apps
      if ( runargs == None ):
         httpstring = ''.join(['v.app=', appname])
      else:
         httpstring = ''.join(['v.app=', appname, '&', runargs])

      print "qm:  ", httpcmd
      print "hs:  ", httpstring
      print "if:  ", interim
      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=interim)

      return 0

   def random_number_string(self, digits=3):

      nums = '0123456789'

      numstring = None

      g = random.Random(time.time())

      cnt = 0
      while ( cnt < digits ):
         anum = nums[g.randint(0,9)]
         if ( numstring == None ):
            numstring = anum
         else:
            numstring = ''.join([numstring, anum])
         cnt = cnt + 1

      return numstring

   def build_express_id(self):

      littles = 'abcdefghijklmnopqrstuvwxyz'
      bigs = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      nums = '0123456789'

      g = random.Random(time.time())

      begin = 'SD71'
      p2 = ''.join([littles[g.randint(0,25)], littles[g.randint(0,25)]])
      p3 = ''.join([bigs[g.randint(0,25)], bigs[g.randint(0,25)],
                    bigs[g.randint(0,25)], bigs[g.randint(0,25)],
                    bigs[g.randint(0,25)]])
      anum = nums[g.randint(0,9)]

      myeid = ''.join([begin, p2, p3, anum])

      return myeid

   def express_tag_create(self, doclist=[], filenm=None,
                          query=None, tagname=None, tags=None):

      if ( query == None ):
         query = ""

      if ( tags == None ):
         return 1

      if ( tagname == None ):
         return 1

      docids = None
      delim = ''
      overwrite = 'on'

      icsaction = 'bunk'
      appname = "express-tag-nodes"

      tagattrname = ''.join(['vivtag-', tagname])
      delimattrname = ''.join(['vivdelimiter-', tagname])

      qfilename = self.get_query_file(query=query, filenm=filenm)

      ndocs = len(doclist)

      for item in doclist:
         if ( docids == None ):
            docids = item
         else:
            docids = ''.join([docids, '%20', item])

      expressid = self.build_express_id()

      interim = ''.join(['querywork/expresstag', self.random_number_string(), '.velocity'])

      httpcmd = self.apps
      httpstring = ''.join(['v.app=', appname,
                            '&project=query-meta',
                            '&v:project=query-meta',
                            '&v:file=', qfilename,
                            '&ICSaction=', icsaction,
                            '&express-id=', expressid,
                            '&overwrite=', overwrite,
                            '&doc-count=', '%s' % ndocs,
                            '&docids=', docids,
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password,
                            '&', delimattrname, '=', delim,
                            '&', tagattrname, '=', tags,
                            '&tags=', tagname])

      #print httpcmd
      #print httpstring
      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=interim)

      return expressid

   #########################################
   #
   #   Get the contents of a bin
   #
   def get_bin_orig(self, binlist="", collection=None, num=1000):

      if ( collection == None ):
         return 1

      self.setcollection(collection)
      snum = '%s' % num

      binstring = subprocess.Popen(['mbinstr', binlist], stdout=subprocess.PIPE).communicate()[0]

      binfname = DATAFILES(binlist, "binning")

      interim = binfname.getwanted("result", "xml")

      httpcmd = self.qmeta
      httpstring = ''.join(['v:project=', self.TENV.project,
                            '&v:username=', self.TENV.user,
                            '&v:password=', self.urlencoded_password,
                            '&&v:sources=', self.collectionname,
                            '&', binstring,
                            '&render.list-show=', snum])

      #print "qm:  ", httpcmd
      #print "hs:  ", httpstring
      #print "if:  ", interim
      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)

      return 0

   def get_bin(self, binlist="", collection=None, num=1000):

      if ( collection == None ):
         return 1

      self.setcollection(collection)
      snum = '%s' % num

      binstring = subprocess.Popen(['mbinstr', binlist], stdout=subprocess.PIPE).communicate()[0]

      binfname = DATAFILES(binlist, "binning")

      interim = binfname.getwanted("result", "xml")

      binmode = "normal"
      snum = '%s' % num
      show_dups = "1"
      xmlpretty = "1"

      httpcmd = self.search
      httpstring = ''.join(['&binning-mode=', binmode,
                            '&', binstring,
                            '&num=', snum,
                            '&collection=', self.collectionname,
                            '&show-duplicates=', show_dups,
                            '&xml-pretty=', xmlpretty])
      print httpstring
      err = self.srchHTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)

      return 0

   #########################################
   #
   #   Run a simple query
   #
   def run_query(self, query=None, collection=None, source=None,
                 defoutput=None, rights=None, num="200", dupshow="1",
                 nocount=None, ficond=None, debug=None):


      if ( collection == None ):
         if ( source == None ):
            return 1
         else:
            self.setcollection(source)
      else:
         self.setcollection(collection)

      if ( query == None ):
         query = ""

      binmode = "normal"
      snum = '%s' % num
      ftimeout = '1000000'
      staging = "0"
      show_dups = '%s' % dupshow
      gen_key = "0"
      score = "0"
      cache = "0"
      conv_time = "0"
      summarize = "1"
      rop = "0"
      if ( debug == None ):
         debug = "1"
      else:
         debug = '%s' % debug
      xmlpretty = "1"

      if (rights is not None) :
	 rightstr = ''.join(['&rights=', rights])
      else:
	 rightstr = ''

      if ( defoutput == None ):
         interim = "query_results"
      else:
         interim = defoutput

      #                         '&query=', query,
      if ( collection is not None ):
         print 'DEPRECATED! "/search" is undocumented/unsupported. See bug 27413.'
         httpcmd = self.search
         httpstring = ''.join(['collection=', self.collectionname,
                               '&binning-mode=', binmode,
                               '&num=', snum,
                               '&staging=', staging,
                               '&show-duplicates=', show_dups,
                               '&gen-key=', gen_key,
                               '&score=', score,
                               '&cache=', cache,
                               '&conversion-time=', conv_time,
                               '&summarize=', summarize,
                               '&r-o-p=', rop,
                               '&debug=', debug,
                               '&xml-pretty=', xmlpretty,
			       rightstr])

         httpstring = self.TCG.httpstr_appnd(httpstring, "query", query, dorep=2)
         if ( ficond is not None ):
            httpstring = self.TCG.httpstr_appnd(httpstring, "fi-cond", ficond)

         #print httpstring
         start = time.time()
         err = self.srchHTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)
         now = time.time()
         elapsed = now - start
         print collection,":   QUERY TIME =", elapsed
         logtime = time.time()
         if ( nocount == None ):
            urlcount = self.query_url_count(filenm=interim)
         else:
            urlcount = num
         mystring = ''.join(['%f' % logtime, ', ', collection, ', ', '%f' % elapsed, ', ', 'seconds, query_time'])
         self.dumpperfdata(mystring=mystring)
         mystring = ''.join(['%f' % logtime, ', ', collection, ', ', urlcount, ', ', 'count, query_urls'])
         self.dumpperfdata(mystring=mystring)
      else:
         #                     '&render.function=export-xml',
         #                     '&content-type=text/xml',
         #                      '&query=', query,
         #                     '&fetch.timeout=', ftimeout,
         httpcmd = self.qmeta
         httpstring = ''.join(['v:sources=', source,
                               '&v:project=query-meta',
                               '&v:xml=1',
                               '&v:debug=', debug,
                               '&v:num-total=', snum,
                               '&render.list-show=', snum,
                               '&query.num-total=', snum,
                               '&v:username=', self.TENV.user,
                               '&v:password=', self.urlencoded_password,
                               '&xml-pretty=', xmlpretty])

         httpstring = self.TCG.httpstr_appnd(httpstring, "query", query)
         #print httpstring
         start = time.time()
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)
         now = time.time()
         elapsed = now - start
         print "QUERY TIME:", elapsed
         logtime = time.time()
         mystring = ''.join(['%f' % logtime, ', ', source, ':', query, ', ', '%f' % elapsed, ', ', 'seconds, query_time'])
         self.dumpperfdata(mystring=mystring)

      return 0

   def get_sterm(self, action):

      retterm = "DIRECTORY"

      if (action is None):
         return retterm

      if ( action == "installed-dir" ):
         return retterm

      if ( action == "install-dir" ):
         return retterm

      if ( action == "search-collections-dir" ):
         return retterm

      if ( action == "tmp-dir" ):
         return retterm

      if ( action == "debug-dir" ):
         return retterm

      if ( action == "repository-dir" ):
         return retterm

      if ( action == "users-dir" ):
         return retterm

      if ( action == "cookie-path" ):
         return retterm

      retterm = "FILE"

      if ( action == "repository" ):
         return retterm

      if ( action == "current-repository" ):
         return retterm

      if ( action == "vivisimo-conf" ):
         return retterm

      if ( action == "users-file" ):
         return retterm

      if ( action == "brand-file" ):
         return retterm

      retterm = "URL"
      if ( action == "base-url" ):
         return retterm

      retterm = "PROJECT"
      if ( action == "default-project" ):
         return retterm

      retterm = "AUTH"
      if ( action == "authentication-macro" ):
         return retterm

      retterm = "ADMINAUTH"
      if ( action == "admin-authentication-macro" ):
         return retterm

      retterm = "DIRECTORY"

      return retterm

   def get_the_thing(self, action=None):

      mydir = None

      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      interim = "installed.dir"

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)

      doc = libxml2.parseDoc(err)
      root = doc.children
      child = root.children

      searchterm = self.get_sterm(action)

      while ( child is not None ):
         if ( child.name == searchterm ):
            mydir = child.content
         child = child.next

      doc.freeDoc()

      return mydir

   #########################################
   #
   #   Get the vivisimo directory
   #
   def vivisimo_dir(self, which="base"):

      if ( which == "base" or
           which == "install-dir" or
           which == "installed-dir" ):
         name = self.get_the_thing(action="installed-dir")
      elif ( which == "collection" or which == "collections" or
             which == "search-collections-dir" ):
         name = self.get_the_thing(action="search-collections-dir")
      elif ( which == "tmp" or which == "tmp-dir" ):
         name = self.get_the_thing(action="tmp-dir")
      elif ( which == "repository" ):
         name = self.get_the_thing(action="repository")
      elif ( which == "repository-dir" ):
         name = self.get_the_thing(action="repository-dir")
      elif ( which == "project" or which == "default-project" ):
         name = self.get_the_thing(action="default-project")
      else:

         sep = '/'
         if ( self.TENV.targetos == "windows" ):
            sep = "\\"

         mydir = self.get_the_thing(action="installed-dir")

         if ( which == "bin" ):
            name = ''.join([mydir, sep, "bin"])
         elif ( which == "service" ):
            name = ''.join([mydir, sep, "bin", sep, "services"])
         elif ( which == "services" ):
            name = ''.join([mydir, sep, "bin", sep, "services"])
         elif ( which == "converter" ):
            name = ''.join([mydir, sep, "bin", sep, "converters"])
         elif ( which == "converters" ):
            name = ''.join([mydir, sep, "bin", sep, "converters"])
         elif ( which == "dictionary" ):
            name = ''.join([mydir, sep, "data", sep, "dictionaries"])
         elif ( which == "dictionaries" ):
            name = ''.join([mydir, sep, "data", sep, "dictionaries"])
         elif ( which == "data" ):
            name = ''.join([mydir, sep, "data"])
         else:
            name = mydir

      return name


   #########################################
   #
   #   Get the vivisimo directory
   #
   def vivisimo_dir_old(self, which="base"):

      mydir = None
      action = "installed-dir"
      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      interim = "install.dir"

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)
      doc = libxml2.parseDoc(err)
      root = doc.children
      child = root.children
      while ( child is not None ):
         if ( child.name == "DIRECTORY" ):
            mydir = child.content
         child = child.next

      if ( which == "bin" ):
         name = ''.join([mydir, sep, "bin"])
      elif ( which == "service" ):
         name = ''.join([mydir, sep, "bin", sep, "services"])
      elif ( which == "services" ):
         name = ''.join([mydir, sep, "bin", sep, "services"])
      elif ( which == "converter" ):
         name = ''.join([mydir, sep, "bin", sep, "converters"])
      elif ( which == "converters" ):
         name = ''.join([mydir, sep, "bin", sep, "converters"])
      elif ( which == "collection" ):
         name = ''.join([mydir, sep, "data", sep, "collections"])
      elif ( which == "collections" ):
         name = ''.join([mydir, sep, "data", sep, "collections"])
      elif ( which == "dictionary" ):
         name = ''.join([mydir, sep, "data", sep, "dictionaries"])
      elif ( which == "dictionaries" ):
         name = ''.join([mydir, sep, "data", sep, "dictionaries"])
      elif ( which == "data" ):
         name = ''.join([mydir, sep, "data"])
      elif ( which == "repository" ):
         name = ''.join([mydir, sep, "data"])
      elif ( which == "tmp" ):
         name = ''.join([mydir, sep, "tmp"])
      else:
         name = mydir

      doc.freeDoc()

      return name


   def where_is_vivisimo(self):

      return self.vivisimo_dir(which="base")


   #########################################
   #
   #   Look for an error in the collection.admin.html
   #
   def check_admin_page_error(self, collection=None):

      if ( collection == None ):
         return 1

      interim = ''.join(['querywork/', collection, '.admin.html'])

      statstring = self.runxsltproc("admin_error", interim, "--html --novalid")
      if ( statstring is not None ):
         if ( statstring.__contains__("Unexpected termination") ):
            print statstring
            return 2
         else:
            return 0

      return 1

   def check_admin_error(self, collection=None):

      if ( collection == None ):
         return 1

      interim = ''.join(['querywork/', collection, '.admin.html'])

      err = self.get_collection_admin(collection=collection)

      if ( err == 0 ):
         err = self.check_admin_page_error(collection=collection)
         #if ( err == 0 ):
         #   os.remove(interim)
      else:
         print "Could not get admin page for", collection

      return err


   #########################################
   #
   #   See if crawler quit or not
   #
   def crawler_service_status(self, collection=None):

      if ( collection == None ):
         return 1

      interim = ''.join(['querywork/', collection, '.staging'])

      err = self.get_staging(collection=collection, interimfile=interim)

      if ( err == 0 ):
         statstring = self.runxsltproc("stag_status",
                      interim, "--html --novalid")
         print statstring
         if ( statstring is not None ):
            #os.remove(interim)
            if ( statstring.__contains__("Unexpected termination") ):
               return 2
            else:
               return 0

      return 1

   #########################################
   #
   #   See if tests worked on index
   #
   def indexing_test_status(self, collection=None):

      if ( collection == None ):
         return 1

      interim = ''.join(['querywork/', collection, '.staging_indexer'])

      err = self.get_staging_indexer(collection=collection, interimfile=interim)

      if ( err == 0 ):
         statstring = self.runxsltproc("stag_status", interim, "--html --novalid")
         if ( statstring is not None ):
            #os.remove(interim)
            if ( statstring.__contains__("Tests failed") ):
               return 2
            else:
               return 0

      return 1

   #########################################
   #
   #   This will kill all services except the query-service.
   #   It works on windows and linux.  Not solaris yet.
   #
   def kill_all_services(self):

      err = 0

      if ( self.TENV.killall == "True" ):
         action = "kill-all-services"

         httpcmd = self.gronk
         httpstring = ''.join(['action=', action])

         self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)

      return err

   #########################################
   #
   #   Restore a collection.
   #   The default is to do a repository restore and restart
   #   the indexer.  If you do not do a repository restore, the
   #   indexer can not be started.  Also, if the collection to
   #   be restored already exists the old one will be deleted.
   #
   def restore_collection(self, testname=None, collection=None,
                          repo_update=True, fullrestore=True,
                          xmlfile=None):

      err = 0

      yy = self.vapi
      action = "restore-collection"

      cex = self.collection_exists(collection=collection)
      if ( cex == 1 ):
         self.delete_collection(collection=collection)

      yy.api_sc_create(collection=collection)

      if ( repo_update ):
         if ( xmlfile is None ):
            xmlfile = ''.join([collection, '.xml'])

      httpcmd = self.gronk
      if ( testname is None ):
         dumpit = ''.join(['querywork/', collection, '_restore.wazzat'])
         httpstring = ''.join(['action=', action,
                               '&collection=', collection])
      else:
         dumpit = ''.join(['querywork/', testname, '_', collection, '_restore.wazzat'])
         httpstring = ''.join(['action=', action,
                               '&testname=', testname,
                               '&collection=', collection])

      print "Copy collection data from CGIINTERFACE restore_collection"
      err = self.HTTP.doget(tocmd=httpcmd,
                            argstring=httpstring,
                            dumpfile=dumpit)
      print "Copy complete"

      if ( repo_update ):
         yy.api_repository_update(xmlfile=xmlfile)
         if ( fullrestore ):
            yy.api_sc_indexer_start(collection=collection)
            print "Full collection restoration complete"

      return err

   #########################################
   #
   #   This will kill all services except the query-service.
   #   It works on windows and linux.  Not solaris yet.
   #
   def kill_query_services(self):

      err = 0

      if ( self.TENV.killall == "True" ):
         action = "kill-query-services"

         httpcmd = self.gronk
         httpstring = ''.join(['action=', action])

         self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)

      return err

   #########################################
   #
   #   This will kill all services except the query-service.
   #   It works on windows and linux.  Not solaris yet.
   #
   def kill_admin(self):

      err = 0

      if ( self.TENV.killall == "True" ):
         action = "kill-admin"

         httpcmd = self.gronk
         httpstring = ''.join(['action=', action])

         self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)

      return err

   def get_process_memory(self, pid=None):

      if ( pid == None ):
         return None

      mydir = None
      yourdir = None

      rss = None
      vmsize = None

      action = "process-memory"
      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&pid=', pid])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)
      #print err
      doc = libxml2.parseDoc(err)
      root = doc.children
      child = root.children
      while ( child is not None ):
         if ( child.name == "MEMSIZE" ):
            mydir = child.content
         if ( child.name == "VMEMSIZE" ):
            yourdir = child.content
         child = child.next

      rss = mydir
      vmsize = yourdir

      doc.freeDoc()

      return rss, vmsize

   #########################################
   #
   #   Stop the query service.
   #
   def get_crawl_dir(self, collection=None):

      if ( collection == None ):
         return None

      mydir = None
      name = None
      action = "get-crawl-dir"
      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&collection=', collection])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)
      #print err
      doc = libxml2.parseDoc(err)
      root = doc.children
      child = root.children
      while ( child is not None ):
         if ( child.name == "DIRECTORY" ):
            mydir = child.content
         child = child.next

      name = mydir

      doc.freeDoc()

      return name

   #########################################
   #
   #   Stop the query service.
   #
   def find_core(self):

      mycore = None
      name = None
      action = "find-core"

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)
      doc = libxml2.parseDoc(err)
      root = doc.children
      child = root.children
      while ( child is not None ):
         if ( child.name == "FINDFILE" ):
            c2 = child.children
            while ( c2 is not None ):
               if ( c2.name == "FILEPATH" ):
                  mycore = c2.content
               c2 = c2.next
         child = child.next

      name = mycore

      doc.freeDoc()

      return name

   #########################################
   #########################################
   #
   #   Stop the query service.
   #
   def find_cgi_core(self):

      mycore = None
      name = None
      action = "find-cgi-core"

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)
      doc = libxml2.parseDoc(err)
      root = doc.children
      child = root.children
      while ( child is not None ):
         if ( child.name == "FINDFILE" ):
            c2 = child.children
            while ( c2 is not None ):
               if ( c2.name == "FILEPATH" ):
                  mycore = c2.content
               c2 = c2.next
         child = child.next

      name = mycore

      doc.freeDoc()

      return name

   #########################################
   #########################################
   #
   #   Stop the query service.
   #
   def find_collection_core(self, collection=None):

      if ( collection == None ):
         return None

      mycore = None
      name = None
      action = "find-collection-core"

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&collection=', collection])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)
      if ( err != 1 ):
         doc = libxml2.parseDoc(err)
         root = doc.children
         child = root.children
         while ( child is not None ):
            if ( child.name == "FINDFILE" ):
               c2 = child.children
               while ( c2 is not None ):
                  if ( c2.name == "FILEPATH" ):
                     mycore = c2.content
                  c2 = c2.next
            child = child.next

         name = mycore

         doc.freeDoc()
      else:
         print "find_collection_core:  http/gronk returned error"
         name = None

      return name

   def velocity_shutdown(self):

      httpcmd = 'http://' + self.TENV.target + ":" + self.TENV.httpport + self.gronk

      httpstring = {}
      httpstring['action'] = "velocity-shutdown"

      savefile = "querywork/velocity_shutdown.status"

      fd = open(savefile, 'w+')

      enc_string = urllib.urlencode(httpstring)
      gronkstring = httpcmd + '?' + enc_string
      text = urllib2.urlopen(gronkstring).read()

      fd.write(text)
      fd.close()

      return 0

   def restore_defaults(self):

      httpcmd = 'http://' + self.TENV.target + ":" + self.TENV.httpport + self.gronk

      httpstring = {}
      httpstring['action'] = "restore-default"

      self.kill_all_services()
      self.stop_query_service()

      #
      #   The sleep is because sometimes it takes a few seconds
      #   for windows to figure out that it should not hold on to
      #   a file.
      #
      time.sleep(10)

      savefile = "querywork/restore_default.status"

      fd = open(savefile, 'w+')

      enc_string = urllib.urlencode(httpstring)
      gronkstring = httpcmd + '?' + enc_string
      text = urllib2.urlopen(gronkstring).read()

      fd.write(text)
      fd.close()

      self.admin_unpack()

      self.start_query_service()

      return 0

   #########################################
   #
   #   Stop the query service.
   #
   def query_service_status(self):

      httpcmd = 'http://' + self.TENV.target + ":" + self.TENV.httpport + self.gronk

      httpstring = {}
      httpstring['action'] = "query-service-status"
      httpstring['username'] = self.TENV.user
      httpstring['password'] = self.TENV.pswd

      savefile = "querywork/query_service.status"

      if ( savefile == None ):
         return None

      fd = open(savefile, 'w+')

      enc_string = urllib.urlencode(httpstring)
      gronkstring = httpcmd + '?' + enc_string
      text = urllib2.urlopen(gronkstring).read()

      fd.write(text)
      fd.close()

      interim = etree.fromstring(text)
      if ( interim.xpath('OUTCOME')[0].text == 'Success' ):
         statstring = interim.xpath('DATA')[0].text
         if ( statstring is not None ):
            if ( statstring.__contains__("Query service idle") ):
               return 0

      return 1

   def get_remote_file_size(self, filename=None):

      if ( filename is None ):
         return -1

      httpcmd = 'http://' + self.TENV.target + ":" + self.TENV.httpport + self.gronk

      httpstring = {}
      httpstring['action'] = "file-size"
      httpstring['file'] = filename

      basefilename = os.path.basename(filename)
      savefile = ''.join(['querywork/', basefilename, '.file.size'])

      if ( savefile == None ):
         return None

      fd = open(savefile, 'w+')

      enc_string = urllib.urlencode(httpstring)
      gronkstring = httpcmd + '?' + enc_string
      text = urllib2.urlopen(gronkstring).read()

      fd.write(text)
      fd.close()

      interim = etree.fromstring(text)
      if ( interim.xpath('FILENAME')[0].text == filename ):
         statstring = interim.xpath('SIZE')[0].text
         return statstring

      return -1

   #########################################
   #
   #   Stop the query service.
   #
   def stop_query_service(self):

      action = "stop"
      id = "se.qs_status"

      httpcmd = self.admin
      httpstring = ''.join(['action=', action,
                            '&id=', id,
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=self.outlog)

      return err

   #########################################
   #
   #   Start the query service.
   #
   def start_query_service(self):

      action = "start"
      id = "se.qs_status"

      httpcmd = self.admin
      httpstring = ''.join(['action=', action,
                            '&id=', id,
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=self.outlog)

      return err

   def use_query_xml(self, query=None, cmd=None, which=None, value=None, filenm=None):

      if ( cmd == None ):
         return

      err = "No Status"

      if ( filenm == None ):
         file1 = ''.join(['bin.', query, '.xml.rslt'])
         file2 = ''.join(['qry.', query, '.xml.rslt'])

         interim1 = ''.join(['querywork/', file1])
         interim2 = ''.join(['querywork/', file2])

         if ( os.access(interim1, os.F_OK) != 0 ):
            interim = interim1
         elif ( os.access(interim2, os.F_OK) != 0 ):
            interim = interim2
         elif ( os.access(file1, os.F_OK) != 0 ):
            interim = file1
         elif ( os.access(file2, os.F_OK) != 0 ):
            interim = file2
         else:
            print "No file for query", query, "found.  Returning."
            return
      else:
         interim = filenm

      opts = ' '.join(['--stringparam mynode', cmd])
      if ( which is not None ):
         opts = ' '.join([opts, '--stringparam which', which])
      if ( value is not None ):
         opts = ' '.join([opts, '--stringparam value', value])

      #
      #   We already have the query result, so just use the file.
      #
      statstring = self.runxsltproc("query_xml", interim, opts=opts)

      if ( statstring is not None ):
         #os.remove(interim)
         return statstring

      return err

   def query_url_count(self, query=None, filenm=None):

      if ( query == None ):
         query=""

      try:
         value = self.use_query_xml(query=query, cmd="url_count",
                                    filenm=filenm)
      except:
         return "0"

      return value

   def get_query_file(self, query=None, filenm=None):

      if ( query == None ):
         query=""

      value = self.use_query_xml(query=query, cmd="query_file", filenm=filenm)

      return value

   def get_content_titles(self, query=None, filenm=None):

      if ( query == None ):
         query=""

      value = self.use_query_xml(query=query, cmd="content_titles", filenm=filenm)

      return value

   def query_matches(self, query=None, filenm=None):

      if ( query == None ):
         query=""

      value = self.use_query_xml(query=query, cmd="matches", filenm=filenm)

      return value

   def query_match_counts(self, query=None, filenm=None):

      if ( query == None ):
         query=""

      try:
         value = self.use_query_xml(query=query, cmd="match_counts",
                                    filenm=filenm)
      except:
         return "0"

      return value

   def count_query_urls(self, query=None, filenm=None):

      if ( query == None ):
         query=""

      try:
         value = self.use_query_xml(query=query, cmd="count_urls",
                                    filenm=filenm)
      except:
         return "0"

      return value

   def get_one_url(self, query=None, value=None, filenm=None):

      if ( query == None ):
         query=""

      if ( value == None ):
         print "Which URL to get is not specified."
         return

      value = self.use_query_xml(query=query, cmd="get_one_url",
                                 value=value, filenm=filenm)

      return value

   def get_url_by_id(self, query=None, value=None, filenm=None):

      if ( query == None ):
         query=""

      if ( value == None ):
         print "Which document id to get the url from is not specified."
         return

      value = self.use_query_xml(query=query, cmd="url_by_id",
                                 value=value, filenm=filenm)

      return value

   def get_query_urls(self, query=None, filenm=None, retlist=0):

      if ( query == None ):
         query=""

      value = self.use_query_xml(query=query, cmd="urls", filenm=filenm)

      if ( retlist == 1 ):
         valuel = self.TCG.listify(mystring=value, sep='\n')
         return valuel
      else:
         return value

   def get_sorted_query_urls(self, query=None, filenm=None, retlist=0):

      if ( query == None ):
         query = ""

      value = self.use_query_xml(query=query, cmd="sort_urls", filenm=filenm)

      if ( retlist == 1 ):
         valuel = self.TCG.listify(mystring=value, sep='\n')
         return valuel
      else:
         return value


   def count_bin_urls(self, query=None, value=None, filenm=None):

      if ( query == None ):
         query=""

      if ( value == None ):
         print "Which BIN to count is not specified."
         return

      if ( filenm is not None ):
         filenm = self.TCG.look_for_file(filename=filenm)

      valuel = self.use_query_xml(query=query, cmd="bin_url_count",
                                 value=value, filenm=filenm)

      if ( valuel != "" and valuel is not None ):
         valuel = self.TCG.listify(mystring=valuel, sep='\n')

         value = 0
         for item in valuel:
            value = value + int(item)
      else:
         value = 0

      return value

   def urls_by_content(self, query=None, which=None, value=None, filenm=None):

      if ( query == None ):
         query=""

      if ( which == None ):
         print "Which CONTENT item to get is not specified."
         return

      if ( value == None ):
         print "Content value is not specified."
         return

      if ( filenm is not None ):
         filenm = self.TCG.look_for_file(filename=filenm)

      value = self.use_query_xml(query=query, cmd="url_by_content",
                                 which=which, value=value, filenm=filenm)

      return value

   #########################################
   #
   #   Common parse_admin usage routine.  They're all the
   #   same, so they all call this.
   #
   def use_parse_admin(self, collection=None, which=None):

      if ( collection == None ):
         return

      if ( which == None ):
         return

      self.setcollection(collection)

      sfr_reset = 0
      if ( self.save_file_reuse != 1 ):
         self.save_file_reuse = 1
         sfr_reset = 1

      interim = ''.join(['querywork/', collection, '.admin.xml'])
      opts = ' '.join(['--stringparam mynode', which])

      #
      #   Allow multiple attempts to get the status file
      #
      retry = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.get_collection_admin_xml(collection=collection)

         if ( err is not None ):
            try:
               xx = os.stat(interim).st_size
               if ( xx <= 0 ):
                  err = None
               else:
                  retry = self.retrymax + 10
            except OSError, e:
               err = None

      if (sfr_reset == 1 ):
         self.save_file_reuse = 0

      if ( err is not None ):
         statstring = self.runxsltproc("parse_admin", interim, opts=opts)

         if ( statstring is not None ):
            #os.remove(interim)
            return statstring

      return err

   def use_parse_status(self, collection=None, which=None):

      if ( collection == None ):
         return

      if ( which == None ):
         return

      self.setcollection(collection)

      interim = ''.join([collection, '.xml.run'])
      opts = ' '.join(['--stringparam mynode', which])

      #
      #   Allow multiple attempts to get the status file
      #
      retry = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.get_collection(collection=collection)

         if ( err is not None ):
            try:
               xx = os.stat(interim).st_size
               if ( xx <= 0 ):
                  err = None
               else:
                  retry = self.retrymax + 10
            except OSError, e:
               err = None

      if ( err is not None ):
         statstring = self.runxsltproc("parse_admin", interim, opts=opts)

         if ( statstring is not None ):
            #os.remove(interim)
            return statstring

      #print "Unknown"
      return err

   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_crawled_urls(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawl-urls")

      return err

   #########################################
   #
   #   Get the current number of index files in a
   #   collection.
   #
   #   Generally used to see if a merge is worth doing.
   #
   def get_index_file_count(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="index-file-count")

      return err

   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_indexer_pid(self, collection=None, which="old"):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="indexer-pid")

      return err

   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_index_path(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="index-path")

      return err

   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_crawl_dups(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawl-dups")

      return err

   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_crawl_elapsed(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawl-elapsed")

      return err

   #########################################
   #
   #   Get the crawlers idea of the size of the data
   #   it has crawled.
   #
   def get_crawled_bytes(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawled-bytes")

      return err

   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_crawl_errors(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawl-errors")

      return err
   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_crawl_pending(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawl-pending")

      return err

   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_crawl_outputs(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawl-outputs")

      return err
   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_crawl_inputs(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawl-inputs")

      return err
   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_crawl_idx_reply(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawl-idx-reply")

      return err

   def get_crawl_idx_input(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawl-idx-input")

      return err

   def get_crawl_idx_output_state(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="ct-idx-output-state")

      return err

   def hang_check(self, collection=None):

      if ( collection == None ):
         return 0
      #
      #   We can reuse the file used for getting information
      #
      ##sfr_reset = 0
      ##if ( self.save_file_reuse != 1 ):
      ##   self.save_file_reuse = 1
      ##   sfr_reset = 1

      cios = ""
      possibly_hung = 0

      cpend = self.get_crawl_pending(collection=collection)
      if ( cpend == 0 ):
         return 0
      #
      #   Message counts
      #
      cir = self.get_crawl_idx_reply(collection=collection)
      cii = self.get_crawl_idx_input(collection=collection)

      #
      #   Crawler progress counts
      #
      ops = self.get_crawl_outputs(collection=collection)
      cerr = self.get_crawl_errors(collection=collection)

      #
      #   indexer progress counts
      #
      idu = self.get_index_urls(collection=collection)
      idoc = self.get_index_docs(collection=collection)

      #
      #   Crawler/Indexer communication state message
      #
      cios = self.get_crawl_idx_output_state(collection=collection)

      #print "OUTPUTS:", ops
      #print "OLD OUTPUTS:", self.last_ops
      #print "CERRORS:", cerr
      #print "OLD CERRORS:", self.last_cerr
      #print "DOCS:", idoc
      #print "OLD DOCS:", self.last_idoc
      #print "URLs:", idu
      #print "OLD URLs:", self.last_idu

      ##if (sfr_reset == 1 ):
      ##   self.save_file_reuse = 0

      #
      #   If we have a state message, it could be hung
      #
      if ( cios == "waiting for connection information from the indexer" ):
         print "crawler/indexer state message problem possible"
         possibly_hung = possibly_hung + 1

      #
      #   If nothing is progressing, it could be hung
      #
      if ( ops == self.last_ops and
           idu == self.last_idu and
           idoc == self.last_idoc and
           cerr == self.last_cerr ):

         if ( self.global_progress == 0 ):
            self.global_progress_time = time.time()
         if ( self.crawl_progress == 0 ):
            self.crawl_progress_time = time.time()
         if ( self.indexer_progress == 0 ):
            self.indexer_progress_time = time.time()

         self.global_progress = self.global_progress + 1
         self.crawl_progress = self.crawl_progress + 1
         self.indexer_progress = self.indexer_progress + 1

         if ( self.global_progress > 5 ):
            z = time.time()
            q = z - self.global_progress_time
            r = z - self.crawl_progress_time
            s = z - self.indexer_progress_time
            print "No crawler/indexer progress in", self.global_progress, "tries."
            print "No crawler/indexer progress in", q, "seconds."
            print "No crawler progress in", r, "seconds."
            print "No indexer progress in", s, "seconds."

         if ( cii != "0" and cii is not None ):
            possibly_hung = possibly_hung + 1

         if ( cir != "0" and cir is not None ):
            possibly_hung = possibly_hung + 1
      else:
         self.global_progress = 0
         self.global_progress_time = 0

         if ( ops == self.last_ops and cerr == self.last_cerr ):
            if ( self.crawl_progress == 0 ):
               self.crawl_progress_time = time.time()
            self.crawl_progress = self.crawl_progress + 1
         else:
            self.crawl_progress = 0
            self.crawl_progress_time = 0

         if ( idoc == self.last_idoc and idu == self.last_idu ):
            if ( self.indexer_progress == 0 ):
               self.indexer_progress_time = time.time()
            self.indexer_progress = self.indexer_progress + 1
         else:
            self.indexer_progress = 0
            self.indexer_progress_time = 0

      self.last_ops = ops
      self.last_idu = idu
      self.last_idoc = idoc
      self.last_cerr = cerr

      return possibly_hung

   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_index_docs(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="index-docs")

      return err

   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_index_size(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="index-size")

      return err
   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_index_time(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="index-time")

      return err
   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_index_contents(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="index-contents")

      return err
   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_valid_index(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="valid-index")

      return err
   #########################################
   #
   #   Get the current indexer pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_index_urls(self, collection=None):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="index-urls")

      return err
   #########################################
   #
   #   Get the current crawler pid of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   pid is checked.
   #
   def get_crawler_pid(self, collection=None, which="old"):

      if ( collection == None ):
         return

      err = self.use_parse_admin(collection=collection, which="crawler-pid")

      return err

   #########################################
   #
   #   Get the current crawl status of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   status is checked.
   #
   def get_status_old(self, collection=None):

      crawler_running = 3
      indexer_running = 2
      unknown = 1
      all_idle = 0

      if ( collection == None ):
         return

      action = "get-status"

      self.setcollection(collection)

      interim = ''.join(['querywork/', self.collectionname, '.status'])

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&collection=', self.collectionname,
                            '&user=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      #
      #   Allow multiple attempts to get the status file
      #
      retry = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)

         if ( err is not None ):
            try:
               xx = os.stat(interim).st_size
               if ( xx <= 0 ):
                  err = None
               else:
                  retry = self.retrymax + 10
            except OSError, e:
               err = None

      if ( err is not None ):
         statstring = self.runxsltproc("op_data", interim)

         if ( statstring is not None ):
            #os.remove(interim)
            if ( statstring.__contains__("Indexer running") ):
               #print "Indexer running"
               return indexer_running
            if ( statstring.__contains__("Crawler running") ):
               #print "Crawler running"
               return crawler_running
            if ( statstring.__contains__("Crawler and indexer are idle.") ):
               #print "Crawler and indexer are idle."
               return all_idle

      #print "Unknown"
      return unknown

   #########################################
   #
   #   Get the current crawl status of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   status is checked.
   #
   def get_status_new(self, collection=None):

      crawler_running = 3
      indexer_running = 2
      unknown = 1
      all_idle = 0

      if ( collection == None ):
         return

      action = "get-status"

      self.setcollection(collection)

      interim = ''.join(['querywork/', collection, '.admin.xml'])

      opts = "--stringparam mynode crawl-status"


      #
      #   Allow multiple attempts to get the status file
      #
      retry = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.get_collection_admin_xml(collection=collection)

         if ( err is not None ):
            try:
               xx = os.stat(interim).st_size
               if ( xx <= 0 ):
                  err = None
               else:
                  retry = self.retrymax + 10
            except OSError, e:
               err = None

      if ( err is not None ):
         statstring = self.runxsltproc("parse_admin", interim, opts=opts)

         if ( statstring is not None ):
            #os.remove(interim)
            if ( statstring.__contains__("Indexer running") ):
               #print "Indexer running"
               return indexer_running
            if ( statstring.__contains__("Crawler running") ):
               #print "Crawler running"
               return crawler_running
            if ( statstring.__contains__("Crawler and indexer are idle") ):
               #print "Crawler and indexer are idle"
               return all_idle

      #print "Unknown"
      return unknown

   #########################################
   #
   #   Get the current crawl status of the named
   #   collection.
   #
   #   collection the name of the collection whose
   #   status is checked.
   #
   def get_status_old(self, collection=None):

      crawler_running = 3
      indexer_running = 2
      unknown = 1
      all_idle = 0

      if ( collection == None ):
         return

      action = "get-status"

      self.setcollection(collection)

      interim = ''.join(['querywork/', self.collectionname, '.status'])

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&collection=', self.collectionname,
                            '&user=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      #
      #   Allow multiple attempts to get the status file
      #
      retry = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)

         if ( err is not None ):
            try:
               xx = os.stat(interim).st_size
               if ( xx <= 0 ):
                  err = None
               else:
                  retry = self.retrymax + 10
            except OSError, e:
               err = None

      if ( err is not None ):
         statstring = self.runxsltproc("op_data", interim)

         if ( statstring is not None ):
            #os.remove(interim)
            if ( statstring.__contains__("Indexer running") ):
               #print "Indexer running"
               return indexer_running
            if ( statstring.__contains__("Crawler running") ):
               #print "Crawler running"
               return crawler_running
            if ( statstring.__contains__("Crawler and indexer are idle.") ):
               #print "Crawler and indexer are idle."
               return all_idle

      #print "Unknown"
      return unknown

   def get_status(self, collection=None):

      if ( self.TENV.vivfloatversion >= 6.0 ):
         return self.get_status_new(collection=collection)
      else:
         return self.get_status_old(collection=collection)

      return 0

   #########################################
   #
   #   Wait for the crawl on the named collection
   #   to complete, or kill it if vmaxtime is exceeded.
   #
   #   collection the name of the collection whose
   #   status is checked.
   #   vmaxtime is the max crawl time.  vmaxtime of
   #   0 is crawl till done crawling (no time out)
   #
   #   waitfor has 2 values: crawl or merge
   #
   def wait_for_idle(self, collection=None,
                     vmaxtime=0, waitfor=None, usecb=0):

      doaquery = 0
      if ( collection == None ):
         return

      if ( usecb == 1 ):
         yy = self.vapi
         doaquery = 1

      start = time.time()
      keepchecking = 1
      amt = 0
      exitstat = 0
      runstat = 0
      hung = 0
      hungtime = 100
      mfl = None

      if ( waitfor == None ):
         waitfor = "crawl"

      if ( waitfor == "merge" ):
         mfl = self.get_index_file_count(collection=collection)

      sfr_reset = 0
      if ( self.save_file_reuse == 0 ):
         self.save_file_reuse = 1
         sfr_reset = 1

      while ( keepchecking ):
         doublecheck = 0
         time.sleep(5)
         print amt,": Checking status ..."

         if ( usecb == 1 ):
            olq = int(yy.getOfflineQueueSize(collection=collection))
            print amt,": offline queue size =", olq
            hungtime = 500
         else:
            olq = 0
            hungtime = 100

         amt = amt + 1

         if ( olq == 0 ):
            #
            #   This is here on the assumption that once it hits 0
            #   wait_for_idle can proceed a bit more quickly without
            #   continuing to check the offline queue size
            #
            #   Also, set the hung checks to what they would have
            #   been if there had never been an offline queue
            #
            if ( usecb == 1 ):
               hung = 0
               hungtime = 100
               usecb = 0

            #
            #   A kludge.  If collection broker, force the collection
            #   to reload and go to idle so we can get a correct status.
            #
            if ( doaquery == 1 and ( hung % 10 ) == 0 ):
               self.run_query(source=collection, query="loadthedamncollection")

            runstat = self.get_status(collection=collection)
         #
         #   runstat of 0 means everything is complete
         #   Make sure this is true.
         #
         if ( runstat == 0 ):
            while ( doublecheck < 3 ):
               time.sleep(3)
               runstat = self.get_status(collection=collection)
               if ( runstat == 0 ):
                 doublecheck = doublecheck + 1
                 if ( doublecheck >= 3 ):
                    keepchecking = 0
               else:
                 doublecheck = 3
         else:
            if ( self.TENV.vivfloatversion >= 6.0 ):
               if ( waitfor == "crawl" ):
                  if ( self.hang_check(collection=collection) != 0 ):
                     hung = hung + 1
                  else:
                     hung = 0
                  if ( hung >= hungtime ):
                     exitstat = 2
                     keepchecking = 0
                     print "CRAWLER/INDEXER APPARENTLY HUNG"
            #
            #   runstat of 3 means it believes the crawler is
            #   still running.  Every 20 iterations, make sure
            #   the crawler has not crashed.
            #
            #   This is apparently no longer working, so comment it out
            #   until I can get a more permanent fix.
            #
            #if ( runstat == 3 ):
            #   if ( ( amt % 20 ) == 0 ):
            #      crlstat = self.crawler_service_status(collection)
            #      if ( crlstat == 2 ):
            #         keepchecking = 0
            #         existstat = 1
            #         print "Crawler apparently terminated"

            if ( vmaxtime > 0 ):
               now = time.time()
               elapsed = now - start
               print "TIME ELAPSED:", elapsed, "MAX:", vmaxtime
               if ( elapsed > vmaxtime ):
                  self.stop_crindex(collection)
                  exitstat = 1
                  keepchecking = 0

      if ( self.TENV.vivfloatversion >= 6.0 ):
         if ( waitfor == "crawl" ):
            idxtm = self.get_index_time(collection=collection)
            crltm = self.get_crawl_elapsed(collection=collection)

         ifl = self.get_index_file_count(collection=collection)
         idxsz = self.get_index_size(collection=collection)
         if ( idxsz == "" or idxsz == None ):
            idxsz = "0"

         crldsz = self.get_crawled_bytes(collection=collection)
         if ( crldsz == "" or crldsz == None ):
            crldsz = "0"

      now = time.time()
      elapsed = now - start

      if ( exitstat == 0 ):
         print "Crawler and indexer are idle."
      else:
         print "Crawl time limit exceeded, crawler quit or hung.  Crawl over."

      if ( sfr_reset == 1 ):
         self.save_file_reuse = 0

      #
      #   A bunch of performance data to be output.
      #   crawl size, index size, crawl time, index time,
      #   total user time, and the relative size of the
      #   index as compared to the crawl size.
      #   Most is only valid for 6.0 or later.
      #
      if ( waitfor == "crawl" ):
         print ""
         print "TOTAL USER TIME:", elapsed
         mystring = ''.join(['%f' % time.time(), ', ', collection, ', ', '%f' % elapsed, ', ', 'seconds, user_time'])
         self.dumpperfdata(mystring=mystring)
      else:
         print ""
         print "TOTAL MERGE TIME:", elapsed
         mystring = ''.join(['%f' % now, ', ', collection, ', ', '%f' % elapsed, ', ', 'seconds, merge_time'])
         self.dumpperfdata(mystring=mystring)
         if ( mfl is None ):
            mfl = self.get_index_file_count(collection=collection)
         mystring = ''.join(['%f' % now, ', ', collection, ', ', mfl, ', ', 'count, index_files'])
         self.dumpperfdata(mystring=mystring)


      if ( self.TENV.vivfloatversion >= 6.0 ):

         print ""
         print "THERE ARE", ifl, "INDEX FILES.  INDEX SIZE IS"
         print "THE COMBINED TOTAL OF ALL INDEX FILE SIZES."

         crlint = float(crldsz)
         idxint = float(idxsz)
         if ( crlint > 0.0 ):
            icperc = idxint / crlint
         else:
            icperc = 0.0

         if ( waitfor == "crawl" ):
            print ""
            print "CRAWL TIME:", crltm
            print "INDEX TIME:", idxtm
            mystring = ''.join(['%f' % time.time(), ', ', collection,  ', ', crltm, ', ', 'seconds, crawl_time'])
            self.dumpperfdata(mystring=mystring)
            mystring = ''.join(['%f' % time.time(), ', ', collection, ', ', idxtm, ', ', 'seconds, index_time'])
            self.dumpperfdata(mystring=mystring)

         print ""
         print "CRAWLED BYTES:", crldsz
         print "INDEX SIZE   :", idxsz
         mystring = ''.join(['%f' % time.time(), ', ', collection, ', ',  crldsz, ', ', 'bytes, crawled_bytes'])
         self.dumpperfdata(mystring=mystring)
         mystring = ''.join(['%f' % time.time(), ', ', collection, ', ', idxsz, ', ', 'bytes, index_size'])
         self.dumpperfdata(mystring=mystring)

         print ""
         print "INDEX AS A PERCENT OF BYTES CRAWLED:", int(icperc * 100.0)
         mystring = ''.join(['%f' % time.time(), ', ', collection, ', ', '%d' % int(icperc * 100.0), ', ', 'percent, index_crawl_ratio'])
         self.dumpperfdata(mystring=mystring)
         print ""



      return exitstat

   #########################################
   #
   #   Get the named collection vce xml and return to local
   #   directory.  Return the raw vce.
   #
   #   collection the name of the collection whose
   #              xml is to be retrieved
   #   num is the per page rendering count
   #
   def get_vce(self, collection=None, num=1000):

      if ( collection == None ):
         return

      self.setcollection(collection)
      interim = ''.join([self.workingdir, '/', self.collectionxml, '.vce'])
      snum = '%s' % num

      httpcmd = self.qmeta
      httpstring = ''.join(['v:sources=', self.collectionname,
                            '&v:xml=1',
                            '&render.list-show=', snum,
                            '&v:username=', self.TENV.user,
                            '&v:password=', self.urlencoded_password])


      #
      #   Allow multiple attempts to get the xml file
      #
      #print "httpcmd:", httpcmd
      #print "httpstring:", httpstring
      retry = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)

         try:
            xx = os.stat(interim).st_size
            if ( xx <= 0 ):
               err = 1
            else:
               retry = self.retrymax + 10
         except OSError, e:
            err = 1

      return err

   #########################################
   #
   #   Get the named collection and return to local
   #   directory.
   #
   #   collection the name of the collection whose
   #   xml is to be retrieved
   #
   def get_collection(self, collection=None):

      if ( collection == None ):
         return

      action = "get-collection"
      err = 0

      self.setcollection(collection)
      interim = ''.join([self.collectionxml, '.run'])

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&collection=', self.collectionname,
                            '&type=binary'])


      #print httpstring
      #
      #   Allow multiple attempts to get the collection file
      #
      retry = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=interim)

         try:
            xx = os.stat(interim).st_size
            if ( xx <= 0 ):
               time.sleep(2)
               err = 1
            else:
               retry = self.retrymax + 10
         except OSError, e:
            err = 1

      return err

   #########################################
   #
   #   Get the named collection and return to local
   #   directory.
   #
   #   collection the name of the collection whose
   #   xml is to be retrieved
   #
   def get_service_pid(self, service=None, collection=None):

      if ( service == None ):
         return None

      httpcmd = 'http://' + self.TENV.target + ":" + self.TENV.httpport + self.gronk
      httpstring = {}
      httpstring['action'] = "get-pid-list"
      httpstring['service'] = service
      # We are only capable of selecting by collection name on Linux.
      if ( collection is not None and self.TENV.targetos == 'linux' ):
         httpstring['collection'] = collection

      savefile = ''.join(['querywork/', service, '.srv.pids'])

      if ( savefile == None ):
         return None

      fd = open(savefile, 'w+')

      #
      #   Allow multiple attempts to get the collection file
      #
      retry = 0

      enc_string = urllib.urlencode(httpstring)
      gronkstring = httpcmd + '?' + enc_string

      while ( retry < self.retrymax ):
         retry = retry + 1
         text = urllib2.urlopen(gronkstring).read()

         try:
            interim = etree.fromstring(text)
            if ( interim.xpath('OUTCOME')[0].text != 'Success' ):
               time.sleep(2)
               err = 1
               interim = None
            else:
               retry = self.retrymax + 10
         except OSError, e:
            err = 1
            interim = None
            print e

      fd.write(text)
      fd.close()
      return interim

   def get_service_pid_count(self, service=None, collection=None):

      if ( service == None ):
         return

      count = 0

      interim = self.get_service_pid(service=service, collection=collection)
      if ( interim is not None ):
         for pid in interim.xpath('PIDLIST/PID'):
            count += 1

      return count

   def get_service_pid_list(self, service=None, collection=None):

      interim = self.get_service_pid(service=service, collection=collection)
      if ( interim is not None ):
         return [pid.text for pid in interim.xpath('PIDLIST/PID')]

      print "The PID string is empty."
      print "This means one of three things happened."
      print "A)  Whatever was being looked at finished"
      print "B)  Gronk crashed."
      print "C)  The Velocity service(s) crashed or quit"
      print "    causing the entry in /proc (or equivalent)"
      print "    to disappear.  While unlikely, this may have"
      print "    at just the right time to cause gronk to"
      print "    crash."
      print "    So, either gronk crashed, Velocity crashed, or both"
      return []

   def get_system_errors(self):

      id = "report.view.system"

      timebegin = "1219204800"
      datebegin = "2008-08-20"
      dateend = "2008-08-20"

      #
      #   Initial html file returned from target
      #
      stagename = ''.join(['querywork/syserror.html'])


      #
      #   html file after it has been edited using sed
      #
      errorfile = ''.join(['querywork/syserror.sed'])

      #
      #   file of file names and errors
      #
      outfile = ''.join(['querywork/syserror.out'])

      #
      #   Command to process initial html file and remove <br> and replace with
      #   actual line feeds.
      #
      cmdstrng = ' '.join(['cat', stagename, '| sed -e \'1,$s/<\/a><br>/<\/a>\\nERROR: /g\' >', errorfile])

      httpcmd = self.admin
      httpstring = ''.join(['&id=', id,
                            '&time-unit=day',
                            '&time-begin=', timebegin,
                            '&date-begin=', datebegin,
                            '&date-end=', dateend,
                            '&selected-name=system-errors',
                            'selected-type=report',
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      #
      #   Allow multiple attempts to get the collection file
      #
      retry = 0
      err = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=stagename)

         try:
            xx = os.stat(stagename).st_size
            if ( xx <= 0 ):
               time.sleep(2)
               err = 1
            else:
               retry = self.retrymax + 10
               os.system(cmdstrng)
               opts = "--stringparam mynode url_error --html"
               #self.runxsltproc(which="errors", file=errorfile,
               #                       opts=opts, outfile=outfile)
               #
               #   Get rid of interim files
               #
               #os.remove(errorfile)
               #os.remove(stagename)

         except OSError, e:
            err = 1

      return err


   #########################################
   #
   #
   def get_url_errors(self, collection=None, host=None,
                      interimfile=None, which=None):

      if ( collection == None ):
         return

      if ( host == None ):
         return

      if ( self.TENV.vivfloatversion >= 6.0 and which != "old" ):
         id = "se.live_crawled_urls"
      else:
         id = "se.staging_crawled_urls"

      self.setcollection(collection)

      #
      #   Initial html file returned from target
      #
      if ( interimfile == None ):
         stagename = ''.join(['querywork/', collection, '.', host, '.errs'])
      else:
         stagename = interimfile


      #
      #   html file after it has been edited using sed
      #
      errorfile = ''.join(['querywork/', collection, '.', host, '.errfile'])

      #
      #   file of file names and errors
      #
      outfile = ''.join(['querywork/', collection, '.', host, '.errors'])

      #
      #   Command to process initial html file and remove <br> and replace with
      #   actual line feeds.
      #
      cmdstrng = ' '.join(['cat', stagename, '| sed -e \'1,$s/<\/a><br>/<\/a>\\nERROR: /g\' >', errorfile])

      httpcmd = self.admin
      httpstring = ''.join(['&id=', id,
                            '&collection=', self.collectionname,
                            '&host=', host,
                            '&start=0&host-sort=n-errors&url-sort=url&per=10',
                            '&status=error&per-2=-1&start-2=0&&scroll-to=0:'
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      #
      #   Allow multiple attempts to get the collection file
      #
      retry = 0
      err = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=stagename)

         try:
            xx = os.stat(stagename).st_size
            if ( xx <= 0 ):
               time.sleep(2)
               err = 1
            else:
               retry = self.retrymax + 10
               os.system(cmdstrng)
               opts = "--stringparam mynode url_error --html"
               self.runxsltproc(which="errors", file=errorfile,
                                      opts=opts, outfile=outfile)
               #
               #   Get rid of interim files
               #
               os.remove(errorfile)
               os.remove(stagename)

         except OSError, e:
            err = 1

      return err


   #########################################
   #
   #
   def get_staging(self, collection=None, interimfile=None):

      if ( collection == None ):
         return

      id = "se.staging"

      self.setcollection(collection)
      if ( interimfile == None ):
         stagename = ''.join(['querywork/', collection, '.staging'])
      else:
         stagename = interimfile

      httpcmd = self.admin
      httpstring = ''.join(['&id=', id,
                            '&collection=', self.collectionname,
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      #
      #   Allow multiple attempts to get the collection file
      #
      retry = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=stagename)

         try:
            xx = os.stat(stagename).st_size
            if ( xx <= 0 ):
               time.sleep(2)
               err = 1
            else:
               retry = self.retrymax + 10
         except OSError, e:
            err = 1

      return err


   #########################################
   #
   #
   def get_staging_indexer(self, collection=None, interimfile=None):

      if ( collection == None ):
         return

      id = "se.staging_indexer"

      self.setcollection(collection)
      if ( interimfile == None ):
         stagename = ''.join(['querywork/', collection, '.staging_indexer'])
      else:
         stagename = interimfile

      httpcmd = self.admin
      httpstring = ''.join(['&id=', id,
                            '&collection=', self.collectionname,
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      #
      #   Allow multiple attempts to get the collection file
      #
      retry = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=stagename)

         try:
            xx = os.stat(stagename).st_size
            if ( xx <= 0 ):
               time.sleep(2)
               err = 1
            else:
               retry = self.retrymax + 10
         except OSError, e:
            err = 1

      return err

   def force_unpack(self):

      id = "bootstrap.check"

      httpcmd = self.admin
      httpstring = ''.join(['id=', id,
                            '&force-unpack=true',
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)

      return err


   #########################################
   #
   #   Flush the data from the named collection
   #   without deleting the collection
   #
   #   collection is the name of the collection to
   #   be cleared
   #
   def delete_data(self, collection=None, force=0):

      if ( collection == None ):
         return

      action = "clean-data"
      id = "se.overview"

      self.setcollection(collection)

      httpcmd = self.admin
      httpstring = ''.join(['action=', action,
                            '&id=', id,
                            '&collection=', self.collectionname,
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring)

      return err


   #########################################
   #
   #   Delete a named collection from a target
   #
   #   collection is the name of the collection to
   #   be deleted from the target
   #
   def unload_collection(self, collection=None):

      if ( collection == None ):
         return

      action = "unload"
      id = "se.qs_status"

      self.setcollection(collection)

      httpcmd = self.admin
      httpstring = ''.join(['action=', action,
                            '&id=', id,
                            '&collection=', self.collectionname,
                            '&unload=', self.collectionname,
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=self.outlog)

      if ( self.collection_exists(self.collectionname) == 0 ):
         return 0

      return 1

   def delete_collection_api(self, collection=None, force=0, silent=0):

      yy = self.vapi

      yy.api_sc_crawler_stop(collection=collection, killit='true', subc='live')
      yy.api_sc_indexer_stop(collection=collection, killit='true', subc='live')
      yy.api_sc_crawler_stop(collection=collection, killit='true',
                             subc='staging')
      yy.api_sc_indexer_stop(collection=collection, killit='true',
                             subc='staging')

      #self.do_gronk_force_delete(collection=collection, force=force, silent=silent)

      if ( self.TENV.vivfloatversion >= 7.5 ):
         #
         #   Uses the force option on collection delete API which was not
         #   introduced until Velocity version 7.5-5.
         #
         if ( force == 1 ):
            yy.vapi.search_collection_delete(collection=collection,
                                             force='true',
                                             kill_services='true')
         else:
            yy.api_sc_delete(collection=collection)
      else:
         yy.api_sc_delete(collection=collection)

      if ( self.collection_exists(collection) == 0 ):
         if ( silent == 0 ):
            print "Delete of collection", collection, "was successful."
         return 0

      if ( silent == 0 ):
         print "Delete of collection", collection, "was not successful."

      return 1

   #########################################
   #
   #   Delete a named collection from a target
   #
   #   collection is the name of the collection to
   #   be deleted from the target
   #
   def do_gronk_force_delete(self, collection=None, force=0, silent=0):

      forceaction="rm-collection"
      fhttpcmd = self.gronk
      fhttpstring = ''.join(['action=', forceaction,
                             '&collection=', collection])

      err = self.HTTP.doget(tocmd=fhttpcmd, argstring=fhttpstring,
                               dumpfile="gronk_garbage")

      print err

      return

   def delete_collection_old(self, collection=None, force=0, silent=0):

      if ( collection == None ):
         return

      if ( self.collection_exists(collection=collection, delete_old=0) == 0 ):
         print "Collection", collection, "has already been deleted"
         return 0

      if ( self.TENV.vivfloatversion >= 6.0 ):
         self.stop_crawl(collection=collection, force=1, which="all")
         self.stop_indexing(collection=collection, force=0, which="all")
         time.sleep(1)

      action = "delete"
      forceaction="rm-collection"
      if ( self.TENV.vivfloatversion >= 6.1 ):
         id = "se.overview"
      else:
         id = "se.select"

      self.setcollection(collection)

      httpcmd = self.admin
      httpstring = ''.join(['action=', action,
                               '&id=', id,
                               '&collection=', self.collectionname,
                               '&delete=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
      fhttpcmd = self.gronk
      fhttpstring = ''.join(['action=', forceaction,
                               '&collection=', self.collectionname])

      #
      #   Leaving in this snippet commented out.  Just to let
      #   me know that if windows misbehaves, there is a possible
      #   work around.
      #
      qsstop = 0
      mys = 0
      if ( silent == 0 ):
         print "Deleting collection", collection
      if ( force == 1 ):
         if ( silent == 0 ):
            print "   Forced delete is enabled."
         if ( self.TENV.vivfloatversion < 7.0 ):
            if ( self.TENV.targetos == "windows" ):
               mys = self.query_service_status()
               if ( mys == 1 ):
                  self.stop_query_service()
                  qsstop = 1

         err = self.HTTP.doget(tocmd=fhttpcmd, argstring=fhttpstring,
                               dumpfile=self.outlog)

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=self.outlog)

      time.sleep(1)

      #
      #   If it is still there, try and remove it by force.
      #
      ckcnt = 0
      while (  ( self.collection_exists(self.collectionname) == 1 ) and
               ( ckcnt < 5 ) ):
         if ( silent == 0 ):
            print "Delete of collection", collection, "failed"
            print "   Using force.  First, delete xml file and directory."
         err = self.HTTP.doget(tocmd=fhttpcmd, argstring=fhttpstring,
                               dumpfile=self.outlog)
         print "   Next, reissue normal collection delete command."
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                               dumpfile=self.outlog)
         ckcnt = ckcnt + 1
         if ( ckcnt < 5 ):
            time.sleep(1)

      if ( self.TENV.vivfloatversion < 7.0 ):
         if ( qsstop == 1 ):
            self.start_query_service()

      if ( self.collection_exists(self.collectionname) == 0 ):
         if ( silent == 0 ):
            print "Delete of collection", collection, "was successful."
         return 0

      if ( silent == 0 ):
         print "Delete of collection", collection, "was not successful."
      return 1

   def delete_collection(self, collection=None, force=0,
                         silent=0, forceold=0):

      whatever = 0

      if ( forceold != 0 ):
         whatever = self.delete_collection_old(collection=collection,
                                               force=force, silent=silent)
      else:
         if ( self.TENV.vivfloatversion < 7.5 ):
            whatever = self.delete_collection_old(collection=collection,
                                               force=force, silent=silent)
         else:
            whatever = self.delete_collection_old(collection=collection,
                                               force=force, silent=silent)

      return whatever

   #########################################
   #
   #   Create a named collection on a target
   #
   #   collection is the name of the collection to
   #   be created from a local xml file
   #
   def create_collection_api(self, collection=None, usedefcon=0):

      if ( collection == None ):
         return

      yy = self.vapi
      colfile = ''.join([collection, '.xml'])

      if ( usedefcon != 0 ):
         self.add_default_converters(collection=collection)

      if ( self.collection_exists(collection=collection, delete_old=1) == 1 ):
         self.delete_collection(collection=collection)

      yy.api_sc_create(collection=collection)
      #yy.api_repository_update(xmlfile=colfile)
      yy.api_sc_set_xml(collection=collection, urlfile=colfile)

      if ( self.collection_exists(collection) == 1 ):
         return 0

      return 1

   def create_collection_old(self, collection=None, usedefcon=0):

      if ( collection == None ):
         return

      if ( usedefcon != 0 ):
         self.add_default_converters(collection=collection)

      if ( self.collection_exists(collection=collection, delete_old=1) == 1 ):
         self.delete_collection(collection=collection)

      action = "send-collection"
      id = "se.overview"

      self.setcollection(collection)
      interim = ''.join(['querywork/', self.collectionname, '.createlog'])

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&collection=', self.collectionname])

      err = self.HTTP.dopost(tocmd=httpcmd, argstring=httpstring,
                             postfile=self.collectionxml, outfile=interim)

      if ( err is not None ):
         statstring = self.runxsltproc("op_outcome", interim)

         if ( statstring is not None ):
            #os.remove(interim)
            if ( statstring.__contains__("Success") ):
               return 0

      return 1

   def create_collection(self, collection=None, usedefcon=0, forceold=0):

      whatever = 0

      if ( forceold != 0 ):
         whatever = self.create_collection_old(collection=collection,
                                               usedefcon=usedefcon)
      else:
         if ( self.TENV.vivfloatversion < 7.5 ):
            whatever = self.create_collection_old(collection=collection,
                                                  usedefcon=usedefcon)
         else:
            whatever = self.create_collection_api(collection=collection,
                                                  usedefcon=usedefcon)

      return whatever
   #########################################
   #
   #   Rebuild/start indexing for the named collection
   #
   #   collection is the name of the collection to
   #   index
   #
   def collection_exists(self, collection=None, delete_old=0):

      if ( collection == None ):
         return

      action = "check-collection-exists"

      self.setcollection(collection)

      interim = ''.join(['querywork/', self.collectionname, '.exstchk'])

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&collection=', self.collectionname])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=interim)

      if ( err == 0 ):
         statstring = self.runxsltproc("op_outcome", interim)
         if ( statstring is not None ):
            #os.remove(interim)
            if ( statstring.__contains__("Yes") ):
               if ( self.TENV.vivfloatversion >= 7.0 ):
                  if ( self.repo_collection_exists(collection=collection) == 0 ):
                     if ( delete_old == 1 ):
                        self.delete_collection(collection=collection,
                                               force=1, silent=1)
                     else:
                        return 1
                  else:
                     return 1
               else:
                  return 1
            else:
               print "Collection xml file does not exist, checking repository"
               return self.repo_collection_exists(collection=collection)

      return 0

   def file_exists(self, filename=None):

      if ( filename == None ):
         return

      workingname = filename

      if ( self.TENV.targetos == "windows" ):
         nf = workingname.replace('\\', '/')
         nf2 = nf.replace(':', '/')
         workingname = nf2

      bfilename = os.path.basename(workingname)
      action = "check-file-exists"

      interim = ''.join(['querywork/', bfilename, '.exstchk'])

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&file=', filename])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=interim)

      if ( err == 0 ):
         statstring = self.runxsltproc("op_outcome", interim)
         if ( statstring is not None ):
            #os.remove(interim)
            if ( statstring.__contains__("Yes") ):
               return 1

      return 0


   #########################################
   #
   #   Remove a collection from the repository
   #
   def remove_collection(self, collection=None):

      if ( collection == None ):
         return

      action = "delete"
      id = "sources.xml.all"
      deletetype = "vse-collection"

      self.setcollection(collection)

      httpcmd = self.admin
      httpstring = ''.join(['action=', action,
                            '&id=', id,
                            '&delete-name=', self.collectionname,
                            '&delete-type=', deletetype,
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=self.outlog)

      return err

   def push_to_live(self, collection=None):

      if ( collection == None ):
         return

      action = "push"
      id = "se.overview"

      self.stop_crawl(collection=collection, force=1, which="staging")
      self.stop_indexing(collection=collection, which="staging")

      self.setcollection(collection)

      print "Push staging to live for ", self.collectionname
      httpcmd = self.admin
      httpstring = ''.join(['action=', action,
                            '&id=', id,
                            '&subcollection=staging',
                            '&collection=', self.collectionname,
                            '&username=', self.TENV.user,
                            '&password=', self.urlencoded_password])

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=self.outlog)

      return err

   #########################################
   #
   #   Rebuild/start indexing for the named collection
   #
   #   collection is the name of the collection to
   #   index
   #
   def build_index(self, collection=None, which="old"):

      if ( collection == None ):
         return

      action = "start-index"
      id = "se.overview"

      self.setcollection(collection)

      print "Start indexing for ", self.collectionname
      httpcmd = self.admin
      if ( self.TENV.vivfloatversion >= 6.0 and which != "old" ):
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                                '&subcollection=live',
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
         httpstrings = ''.join(['action=', action,
                                '&id=', id,
                                '&subcollection=staging',
                                '&collection=', self.collectionname,
                                '&username=', self.TENV.user,
                                '&password=', self.urlencoded_password])

         if ( which == "all" or which == "live"):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                                  dumpfile=self.outlog)
         if ( which == "all" or which == "staging"):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstrings,
                                  dumpfile=self.outlog)

      else:
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                               dumpfile=self.outlog)

      return err

   #########################################
   #
   #   Stop any of indexing or crawling on a named collection
   #
   #   collection is the name of the collection to
   #   halt crawling on
   #
   def stop_crindex(self, collection=None, force=0):

      if ( collection == None ):
         return

      action = "stop-crawler"
      forceaction = "stop-crindex"
      id = "se.overview"

      self.setcollection(collection)

      if ( force == 0 ):
         httpcmd = self.admin
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                               '&collection=', self.collectionname,
                               '&force=1',
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
      else:
         httpcmd = self.gronk
         httpstring = ''.join(['action=', forceaction,
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])

      print "Stop indexing and/or crawling for ", self.collectionname
      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=self.outlog)

      return err


   #########################################
   #
   #   Stop indexing on a named collection
   #
   #   collection is the name of the collection to
   #   halt crawling on
   #
   def stop_indexing(self, collection=None, force=0, which="old"):

      if ( collection == None ):
         return

      err = 0
      action = "stop-index"
      id = "se.overview"

      self.setcollection(collection)

      if ( force == 0 ):
         httpcmd = self.admin
         if ( self.TENV.vivfloatversion >= 6.0 and which != "old" ):
            httpstring = ''.join(['action=', action,
                                  '&id=', id,
                                  '&collection=', self.collectionname,
                                  '&subcollection=live',
                                  '&force=1',
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])
            httpstring2 = ''.join(['action=', action,
                                  '&id=', id,
                                  '&collection=', self.collectionname,
                                  '&subcollection=staging',
                                  '&force=1',
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])
         else:
            httpstring = ''.join(['action=', action,
                                  '&id=', id,
                                  '&collection=', self.collectionname,
                                  '&force=1',
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])

         print "Stop indexing (admin) for ", self.collectionname
         if ( which == "live" or which == "all" or which == "old" ):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                                  dumpfile=self.outlog)

         if ( which == "staging" or which == "all" ):
            if ( self.TENV.vivfloatversion >= 6.0 ):
               err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring2,
                                     dumpfile=self.outlog)

      else:
         httpcmd = self.gronk
         httpstring = ''.join(['action=', action,
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])

         print "Stop indexing (kill) for ", self.collectionname
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                               dumpfile=self.outlog)

      return err

   #########################################
   #
   #   Stop the crawler nanny children on a named collection
   #
   #   collection is the name of the collection to
   #   halt crawling on
   #
   #   Valid services are:
   #      crawler
   #      indexer
   #      query
   #      crindex (both crawler and indexer)
   #      supplied  (you will supply the parent process id as ppid)
   #
   def kill_service_children(self, collection=None,
                                   service="crawler", ppid=0):

      action = "kill-service-kids"

      level = "kill service children"
      httpcmd = self.gronk
      if ( collection == None ):
         httpstring = ''.join(['action=', action,
                               '&service=', service,
                               '&ppid=', '%s' % ppid,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
      else:
         self.setcollection(collection)
         httpstring = ''.join(['action=', action,
                               '&service=', service,
                               '&ppid=', '%s' % ppid,
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])

      print "Stopping", service, "for", self.collectionname, "at", level
      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=self.outlog)

      return err


   #########################################
   #
   #   Stop the crawl on a named collection
   #
   #   collection is the name of the collection to
   #   halt crawling on
   #
   def stop_crawl(self, collection=None, force=0, which="old"):

      if ( collection == None ):
         return

      action = "stop-crawler"
      id = "se.overview"

      self.setcollection(collection)

      if ( force == 0 ):
         level = "admin no force"
      elif ( force == 1 ):
         level = "admin force"
      else:
         level = "kill process"

      print "Stopping crawl for ", self.collectionname, " at ", level
      if ( self.TENV.vivfloatversion >= 6.0 and which != "old" ):
         if ( force == 0 ):
            level = "admin no force"
            httpcmd = self.admin
            httpstring = ''.join(['action=', action,
                                  '&id=', id,
                                  '&subcollection=live',
                                  '&collection=', self.collectionname,
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])
            httpstrings = ''.join(['action=', action,
                                  '&id=', id,
                                  '&subcollection=staging',
                                  '&collection=', self.collectionname,
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])

            if ( which == "all" or which == "live" ):
               err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                                     dumpfile=self.outlog)

            if ( which == "all" or which == "staging" ):
               err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstrings,
                                     dumpfile=self.outlog)
         elif ( force == 1 ):
            level = "admin force"
            httpcmd = self.admin
            httpstring = ''.join(['action=', action,
                                  '&id=', id,
                                  '&subcollection=live',
                                  '&collection=', self.collectionname,
                                  '&force=1',
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])
            httpstrings = ''.join(['action=', action,
                                  '&id=', id,
                                  '&subcollection=staging',
                                  '&collection=', self.collectionname,
                                  '&force=1',
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])
            if ( which == "all" or which == "live" ):
               err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                                     dumpfile=self.outlog)

            if ( which == "all" or which == "staging" ):
               err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstrings,
                                     dumpfile=self.outlog)
         else:
            level = "kill process"
            httpcmd = self.gronk
            httpstring = ''.join(['action=', action,
                                  '&collection=', self.collectionname,
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])

            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                                  dumpfile=self.outlog)
      else:
         if ( force == 0 ):
            level = "admin no force"
            httpcmd = self.admin
            httpstring = ''.join(['action=', action,
                                  '&id=', id,
                                  '&collection=', self.collectionname,
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])
         elif ( force == 1 ):
            level = "admin force"
            httpcmd = self.admin
            httpstring = ''.join(['action=', action,
                                  '&id=', id,
                                  '&collection=', self.collectionname,
                                  '&force=1',
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])
         else:
            level = "kill process"
            httpcmd = self.gronk
            httpstring = ''.join(['action=', action,
                                  '&collection=', self.collectionname,
                                  '&username=', self.TENV.user,
                                  '&password=', self.urlencoded_password])

         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                               dumpfile=self.outlog)

      return err

   #########################################
   #
   #   Refresh a crawl on a named collection
   #
   #   collection is the name of the collection to
   #   be crawled
   #
   def refresh_crawl(self, collection=None, which="old"):

      if ( collection == None ):
         return

      err = 0
      action = "refresh-crawler"
      id = "se.overview"

      self.setcollection(collection)

      print "Refresh crawl for ", self.collectionname

      httpcmd = self.admin
      if ( self.TENV.vivfloatversion >= 6.0 and which != "old" ):
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                                '&subcollection=live',
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
         httpstrings = ''.join(['action=', action,
                                '&id=', id,
                                '&subcollection=staging',
                                '&collection=', self.collectionname,
                                '&username=', self.TENV.user,
                                '&password=', self.urlencoded_password])

         if ( which == "all" or which == "live"):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                                  dumpfile=self.outlog)
         if ( which == "all" or which == "staging"):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstrings,
                                  dumpfile=self.outlog)

      else:
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                               dumpfile=self.outlog)


      return err


   #########################################
   #
   #   Resume a crawl on a named collection
   #
   #   collection is the name of the collection to
   #   be crawled
   #
   def resume_crawl(self, collection=None, which="old"):

      if ( collection == None ):
         return

      action = "resume-crawler"
      id = "se.overview"

      self.setcollection(collection)

      print "Resume crawl for ", self.collectionname
      httpcmd = self.admin

      if ( self.TENV.vivfloatversion >= 6.0 and which != "old" ):
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                                '&subcollection=live',
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
         httpstrings = ''.join(['action=', action,
                                '&id=', id,
                                '&subcollection=staging',
                                '&collection=', self.collectionname,
                                '&username=', self.TENV.user,
                                '&password=', self.urlencoded_password])

         if ( which == "all" or which == "live"):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                                  dumpfile=self.outlog)
         if ( which == "all" or which == "staging"):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstrings,
                                  dumpfile=self.outlog)

      else:
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                               dumpfile=self.outlog)


      return err


   #########################################
   #
   #   Start a crawl on a named collection
   #
   #   collection is the name of the collection to
   #   be crawled
   #
   def start_crawl(self, collection=None, which="old"):

      if ( collection == None ):
         return

      err = 0
      action = "start-crawler"
      id = "se.overview"

      self.setcollection(collection)

      if (self.TENV.vivfloatversion >= 6.0):
         if ( which == "old" ):
            self.stop_indexing(collection=collection, which="staging")
         else:
            self.stop_indexing(collection=collection, which=which)

      print "Starting crawl for ", self.collectionname
      httpcmd = self.admin
      if ( self.TENV.vivfloatversion >= 6.0 and which != "old" ):
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                                '&subcollection=live',
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
         httpstrings = ''.join(['action=', action,
                                '&id=', id,
                                '&subcollection=staging',
                                '&collection=', self.collectionname,
                                '&username=', self.TENV.user,
                                '&password=', self.urlencoded_password])

         if ( which == "all" or which == "live"):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                                  dumpfile=self.outlog)
         if ( which == "all" or which == "staging"):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstrings,
                                  dumpfile=self.outlog)
      else:
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                               dumpfile=self.outlog)


      return err

   #########################################
   #
   #   Do a merge on a named collection
   #
   #   collection is the name of the collection to
   #   be merged
   #
   def merge_index(self, collection=None, which="old"):

      if ( collection == None ):
         return

      action = "merge-index"
      id = "se.live_indexer"

      self.setcollection(collection)

      print "Starting merge for ", self.collectionname
      httpcmd = self.admin
      if ( self.TENV.vivfloatversion >= 6.0 and which != "old" ):
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                               '&subcollection=live',
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
         httpstrings = ''.join(['action=', action,
                                '&id=', id,
                                '&subcollection=staging',
                                '&collection=', self.collectionname,
                                '&username=', self.TENV.user,
                                '&password=', self.urlencoded_password])

         if ( which == "all" or which == "live"):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                                  dumpfile=self.outlog)
         if ( which == "all" or which == "staging"):
            err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstrings,
                                  dumpfile=self.outlog)
      else:
         httpstring = ''.join(['action=', action,
                               '&id=', id,
                               '&collection=', self.collectionname,
                               '&username=', self.TENV.user,
                               '&password=', self.urlencoded_password])
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                               dumpfile=self.outlog)


      return err

   #########################################
   #
   #   Backup the repository to the same repository
   #   directory, but to a file name repository.backup.xml.
   #   This allows us to completely overwrite the old one and
   #   still do a restore later.
   #
   def backup_repository(self, filename=None):

      if ( filename == None ):
         filename = 'repository.backup.xml'

      err = 0
      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      datadir = self.vivisimo_dir(which="data")
      origrepo = ''.join([datadir, sep, 'repository.xml'])

      backuprepo = ''.join([datadir, sep, filename])

      print "Backup up repository:"
      print "     FROM: ", origrepo
      print "     TO  : ", backuprepo

      if ( self.file_exists(backuprepo) == 1 ):
         print "Backup repository already exists:", backuprepo
         print "Remove it with delete_file command if"
         print "you really want it over-written"
         return err

      cmd = ' '.join(['cp', origrepo, backuprepo])
      if ( self.TENV.targetos == "windows" ):
         cmd = ' '.join(['copy', origrepo, backuprepo])

      err = self.execute_command(cmd=cmd)
      if ( err != 0 ):
         print "Could not backup repository", origrepo
         return err

      return err

   def preserve_repository(self):

      filename = 'repository.preserve.xml'

      err = 0
      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      datadir = self.vivisimo_dir(which="data")
      origrepo = ''.join([datadir, sep, 'repository.xml'])

      backuprepo = ''.join([datadir, sep, filename])
      if ( self.file_exists(backuprepo) == 1 ):
         return err
      else:
         if ( self.file_exists(backuprepo) == 1 ):
            return err
         else:
            err = self.backup_repository(filename=filename)

      return err

   def delete_repository(self, filename=None):

      if ( filename == None ):
         filename = 'repository.backup.xml'

      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      datadir = self.vivisimo_dir(which="data")

      backuprepo = ''.join([datadir, sep, filename])

      if ( self.file_exists(backuprepo) == 1 ):
         self.delete_file(removefile=backuprepo)
      else:
         print "Repository does not exist:", backuprepo

      return 0

   #########################################
   #
   #   Restore the repository from repository.backup.xml.
   #   If the file does not exist, nothing changes on the
   #   target.
   #
   def restore_repository(self, filename=None, collection=None):

      if ( filename == None ):
         filename = 'repository.backup.xml'

      if ( collection is not None ):
         collection_list = collection.split(' ')

      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      datadir = self.vivisimo_dir(which="data")
      origrepo = ''.join([datadir, sep, 'repository.xml'])
      repoindex = ''.join([datadir, sep, 'repository.xml.index'])

      backuprepo = ''.join([datadir, sep, filename])

      print "Restoring repository:"
      print "     FROM: ", backuprepo
      print "     TO  : ", origrepo

      cmd = ' '.join(['cp', backuprepo, origrepo])
      if ( self.TENV.targetos == "windows" ):
         cmd = ' '.join(['copy', backuprepo, origrepo])

      if ( self.file_exists(backuprepo) == 1 ):
         if ( self.TENV.targetos == "windows" ):
            self.kill_all_services()
            self.stop_query_service()
            time.sleep(1)
            self.stop_query_service()
            time.sleep(2)
         err = self.execute_command(cmd=cmd)
         self.delete_file(removefile=repoindex)
         if ( self.TENV.targetos == "windows" ):
            self.start_query_service()
            if ( collection is not None ):
               for item in collection_list:
                  self.build_index(collection=item)
                  self.start_crawl(collection=item)
         if ( err != 0 ):
            print "Could not restore repository", origrepo
            return err
         else:
            self.delete_file(removefile=repoindex)
      else:
         err = 1
         print "Could not restore repository, backup", backuprepo, "does not exist"
         return err

      return err

   #########################################
   #
   #   Reset repository to original contents.
   #
   def reset_repository(self, filename=None, collection=None):

      if ( filename == None ):
         filename = 'repository.preserve.xml'

      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      datadir = self.vivisimo_dir(which="data")
      origrepo = ''.join([datadir, sep, 'repository.xml'])
      repoindex = ''.join([datadir, sep, 'repository.xml.index'])

      if ( self.TENV.vivfloatversion >= 7.0 ):
         if ( collection is not None ):
            collection_list = collection.split(' ')
         if ( self.TENV.targetos == "windows" ):
            self.kill_all_services()
            self.stop_query_service()
            time.sleep(1)
            self.stop_query_service()
            time.sleep(2)
         self.delete_file(removefile=origrepo)
         self.delete_file(removefile=repoindex)
         if ( self.TENV.targetos == "windows" ):
            self.start_query_service()
            if ( collection is not None ):
               for item in collection_list:
                  self.build_index(collection=item)
                  self.start_crawl(collection=item)
         err = 0
      else:
         err = self.restore_repository(filename=filename, collection=collection)

      return err

   #########################################
   #
   #   Overwrite the repository with any named file.  It
   #   checks for the existence of a backup.  If no backup
   #   exists, it creates one.  Otherwise, it behaves like
   #   you know what you are doing.
   #
   def new_repository(self, filename=None):

      targetdir = self.vivisimo_dir(which="data")

      origrepo = ''.join([targetdir, '/repository.xml'])
      backuprepo = ''.join([targetdir, '/repository.backup.xml'])
      repoindex = ''.join([targetdir, '/repository.xml.index'])

      if ( self.file_exists(backuprepo) == 0 ):
         err = self.backup_repository()
         if ( err != 0 ):
            print "Could not create backup repository, new repository not created"
            return err

      self.delete_file(removefile=origrepo)

      action = "send-file"
      localfile = "repository.xml"

      if ( self.TENV.targetos == "windows" ):
         targetfile = ''.join([targetdir, "\\", localfile])
      else:
         targetfile = ''.join([targetdir, "/", localfile])

      print "COPY: ", filename
      print "  TO: ", targetfile

      targetfile = self.HTTP.uriit(targetfile)

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&file=', targetfile])

      try:
         err = self.HTTP.dopost(tocmd=httpcmd, argstring=httpstring,
                                postfile=filename)
      except:
         return 1

      self.delete_file(removefile=repoindex)


      return err

   def repo_delete(self, elemtype=None, elemname=None):

      vpi = self.vapi

      try:
         vpi.api_repository_del(elemtype=elemtype, elemname=elemname)
      except:
         print "cgi_interface.repo_delete: delete failed, retry ..."
         try:
            vpi.api_repository_del(elemtype=elemtype, elemname=elemname)
         except:
            print "cgi_interface.repo_delete: delete failed, continuing ..."

      return

   def repo_import(self, importfile=None, backitup=1, backupfile=None):


      if ( self.TENV.vivfloatversion < 6.1 ):
         self.repo_import_old(importfile=importfile, backitup=backitup,
                              backupfile=backupfile)
      else:
         self.repo_import_new(importfile=importfile, backitup=backitup,
                              backupfile=backupfile)

      return

   def repo_update(self, importfile=None, backitup=1, backupfile=None):


      if ( importfile == None ):
         return

      vpi = self.vapi

      try:
         vpi.api_repository_update(xmlfile=importfile)
      except:
         print "cgi_interface.repo_update: update failed, retry ..."
         try:
            vpi.api_repository_update(xmlfile=importfile)
         except:
            print "cgi_interface.repo_update: update failed, retry ..."

      return

   def repo_import_new(self, importfile=None, backitup=1, backupfile=None):


      if ( importfile == None ):
         return

      vpi = self.vapi

      vpi.api_repository_add(xmlfile=importfile)

      return
   #
   #   Import the file "importfile" into the repository.
   #   importfile is a full path specification.
   #   This does not check the validity of the file,
   #   it just stuffs the data into the repo.  This is
   #   a testing function and needs to be able to put
   #   bad functions/apps into the repository.
   #
   def repo_import_old(self, importfile=None, backitup=1, backupfile=None):

      if ( importfile == None ):
         return

      #
      #   Temporary location of imported file on target
      #
      importdir = self.vivisimo_dir(which="tmp")

      #
      #   Repository directory
      #
      datadir = self.vivisimo_dir(which="data")

      #
      #   file name of imported file
      #
      localfile = os.path.basename(importfile)

      #
      #   Stash the success/failure of the import here
      #
      resultfile = ''.join(["querywork", "/", localfile, ".postres"])

      #
      #   The full path of the repo index on the target
      #
      repoindex = ''.join([datadir, '/repository.xml.index'])

      if ( self.TENV.targetos == "windows" ):
         targetfile = ''.join([importdir, "\\", localfile])
      else:
         targetfile = ''.join([importdir, "/", localfile])

      #
      #   Put the file to be imported to the target
      #
      self.put_file(putfile=importfile, targetdir=importdir)

      #
      #   Back up the repository before we import
      #
      if ( backitup > 0 ):
         self.backup_repository(filename=backupfile)

      action = "repository-import"

      #
      #   do the import
      #
      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&importfile=', targetfile])

      try:
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                                dumpfile=resultfile)
      except:
         return 1

      #
      #   Delete the repository index so the imported stuff
      #   gets recognized.
      #
      self.delete_file(removefile=repoindex)

      #
      #   Delete the imported file from the target machine.
      #
      self.delete_file(removefile=targetfile)

      return err

   #########################################
   #
   #   Send the named file from the local directory
   #   to a named directory on the target.
   #
   #   putfile is the full or relative path name
   #   of the file as it exists on the local host.
   #
   #   targetdir is where you want the file put
   #   on the target host
   #
   def put_file(self, putfile=None, targetdir=None):

      if ( putfile == None ):
         return

      if ( targetdir == None ):
         targetdir = self.targetdir

      cmd = ''.join(['mkdir -p ', targetdir])
      if ( self.TENV.targetos == "windows" ):
         cmd = ''.join(['mkdir.exe ', targetdir])

      err = self.execute_command(cmd=cmd)
      if ( err != 0 ):
         print "Could not create directory", targetdir
         return err

      action = "send-file"
      localfile = os.path.basename(putfile)
      if ( self.TENV.targetos == "windows" ):
         targetfile = ''.join([targetdir, "\\", localfile])
      else:
         targetfile = ''.join([targetdir, "/", localfile])

      print "COPY: ", putfile
      print "  TO: ", targetfile

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action])
      httpstring = self.TCG.httpstr_appnd(httpstring, "file", targetfile, dorep=1)

      err = self.HTTP.dopost(tocmd=httpcmd, argstring=httpstring,
                             postfile=putfile)

      return err

   def put_dir(self, targdirname=None, targetdir=None, collection=None):

      errcnt = 0

      if ( targdirname == None ):
         return

      if ( targetdir == None ):
         return

      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      stuff = os.walk(targdirname, topdown=True)

      for root, dirs, files in stuff:
         basedir = root.replace(targdirname, '')
         for afile in files:

            sourcefile = ''.join([root, '/', afile])
            destdir = ''.join([targetdir, basedir])

            targetdir = targetdir.replace('/', sep)
            destdir = destdir.replace('/', sep)
            if ( not ( sourcefile.__contains__(".svn") ) ):
               err = self.put_file(sourcefile, destdir)
               errcnt = errcnt + err

      return errcnt

   #########################################
   #
   #   Get the raw collection xml from the repository
   #   on the target machine.
   #
   #
   def dump_indices(self, collectionname=None):

      #if ( self.TENV.targetos == "windows" ):
      #   print "Not yet implemented for windows"
      #   return 1

      err = 0
      self.setcollection(collectionname)
      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      bindir = self.vivisimo_dir(which="bin")
      dumpcmd = ''.join([bindir, sep, self.dump])

      coldir = self.vivisimo_dir(which="collection")
      if ( self.TENV.vivfloatversion < 6.0 ):
         indexdir = ''.join([coldir, sep, collectionname, sep, "indices"])
      else:
         indexdir = self.get_crawl_dir(collection=collectionname)
         #if ( self.TENV.targetos == "windows" ):
         #   indexdir = self.get_index_path(collection=collectionname)
         #   if ( indexdir == "crawl*" ):
         #      indexdir = ''.join([coldir, sep, collectionname, sep, "crawl*"])
         #else:
         #   indexdir = ''.join([coldir, sep, collectionname, sep, "crawl*"])

      #print indexdir
      self.get_collection(collection=collectionname)
      interim = ''.join([self.collectionxml, '.run'])

      go = 0
      if ( os.access(interim, os.F_OK) != 0 ):
         xx = os.stat(interim).st_size
         if ( xx > 0 ):
            go = 1
         else:
            os.remove(interim)

      if ( go == 1 ):
         indexname = ''.join([collectionname, ".index"])

         filestring = self.runxsltproc(which="index_files", file=interim)
         os.remove(interim)

         newstring = re.sub('<.*xml.*>', '', filestring)
         newstring = newstring.replace('\n', '')
         newstring = newstring.rstrip()
         #print "FILESTRING:", newstring
         filelist = newstring.split(' ')

         #
         #   Temp file gyrations because python will not
         #   let me assign my own directory name.
         #
         g = random.Random(time.time())
         myfile = ''.join(["ti.index.", '%s' % g.randint(1, 1000), '%s' % g.randint(1, 100), '%s' % g.randint(1, 1000)])
         mypath = ''.join([self.vivisimo_dir(), sep, "tmp", sep, myfile])

         for iname in filelist:
            print "dumping", iname
            indexfile = ''.join([indexdir, sep, iname])
            if ( self.TENV.targetos == "windows" ):
               cmd = ' '.join([dumpcmd, "nul:", indexfile, ">>", mypath])
            else:
               cmd = ' '.join([dumpcmd, "/dev/null", indexfile, ">>", mypath])
            #print cmd
            err = self.execute_command(cmd=cmd)

         self.get_file(getfile=mypath)
         self.delete_file(removefile=mypath)

         os.rename(myfile, indexname)

         self.index_name = indexname
      else:
         err = 1

      return err

   #########################################
   #
   #   Get the raw collection xml from the repository
   #   on the target machine.
   #
   #
   def get_raw_dictionary(self, dictionary=None):

      err = 0
      err = self.get_repository()
      sep = '/'

      if ( err == 0 ):
         repositoryfile = "repository.xml"
         savefile = ''.join([self.workingdir, sep, repositoryfile])

         outfile = ''.join([dictionary, ".xml.raw"])

         opts = ''.join(["--stringparam dictionary ", dictionary])

         err = self.runxsltproc(which="raw_dictionary", file=repositoryfile,
                                opts=opts, outfile=outfile)

         os.rename(repositoryfile, savefile)

      return err

   #########################################
   #
   #   Get the raw collection xml from the repository
   #   on the target machine.
   #
   #
   def get_raw_function(self, functionname=None):

      err = 0
      err = self.get_repository()
      sep = '/'

      if ( err == 0 ):
         repositoryfile = "repository.xml"
         savefile = ''.join([self.workingdir, sep, repositoryfile])

         outfile = ''.join([functionname, ".xml.raw"])

         opts = ''.join(["--stringparam functionname ", functionname])

         err = self.runxsltproc(which="raw_function", file=repositoryfile,
                                opts=opts, outfile=outfile)

         os.rename(repositoryfile, savefile)

      return err

   #########################################
   #
   #   Get the raw collection xml from the repository
   #   on the target machine.
   #
   #
   def get_raw_source(self, sourcename=None):

      err = 0
      err = self.get_repository()
      sep = '/'

      if ( err == 0 ):
         repositoryfile = "repository.xml"
         savefile = ''.join([self.workingdir, sep, repositoryfile])

         outfile = ''.join([sourcename, ".xml.raw"])

         opts = ''.join(["--stringparam source ", sourcename])

         err = self.runxsltproc(which="raw_source", file=repositoryfile,
                                opts=opts, outfile=outfile)

         os.rename(repositoryfile, savefile)

      return err

   #########################################
   #
   #   Get the raw collection xml from the repository
   #   on the target machine.
   #
   #
   def get_raw_collection(self, collectionname=None):

      err = 0
      err = self.get_repository()
      sep = '/'

      if ( err == 0 ):
         repositoryfile = "repository.xml"
         savefile = ''.join([self.workingdir, sep, repositoryfile])

         outfile = ''.join([collectionname, ".xml.raw"])

         opts = ''.join(["--stringparam collection ", collectionname])

         err = self.runxsltproc(which="raw_collection", file=repositoryfile,
                                opts=opts, outfile=outfile)

         os.rename(repositoryfile, savefile)

      return err

   #########################################
   #
   #   Get the raw collection xml from the repository
   #   on the target machine.
   #
   #
   def get_bin_attribute(self, collectionname=None, attribname="label", num=1000):

      sep = '/'

      infile = ''.join([self.workingdir, sep, collectionname, ".xml.vce"])
      outfile = ''.join([self.workingdir, sep, collectionname, ".bin.", attribname])

      if ( os.access(infile, os.F_OK) == 0 ):
         self.get_vce(collection=collectionname, num=num)

      opts = ''.join(["--stringparam mytrib ", attribname])

      err = self.runxsltproc(which="bin_attribute", file=infile,
                             opts=opts, outfile=outfile)

      return err

   #########################################
   #
   #   Get the repository.xml file
   #
   #
   def get_repository(self, repointernal=0):


      repositoryfile = self.vivisimo_dir(which="repository")

      err = self.get_file(getfile=repositoryfile)

      return err

   #########################################
   #
   #   Get the repository.xml file
   #
   #
   def get_default_collection(self):

      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      #
      #   In 7.0, the default collection as a seperate file was
      #   eliminated (default.xml) and it was simply incorporated
      #   into the internal repository (repository-internal.xml).
      #   This gets the file we need to extract the default converters
      #   from with which we can rebuild various collection xml
      #   files.
      #
      if ( self.TENV.vivfloatversion >= 7.0 ):
         mydir = self.vivisimo_dir(which="data")
         defaultcoll = ''.join([mydir, sep, "repository-internal.xml"])
      else:
         mydir = self.vivisimo_dir(which="collections")
         defaultcoll = ''.join([mydir, sep, "default.xml"])

      print defaultcoll

      err = self.get_file(getfile=defaultcoll)

      return err

   def get_default_converters(self):

      if ( self.TENV.vivfloatversion >= 7.0 ):
         opts = ' '.join(['--stringparam mynode internal_default'])
         filename = "repository-internal.xml"
      else:
         filename = "default.xml"

      outfile = self.defconverters

      self.get_default_collection()

      if ( self.TENV.vivfloatversion >= 7.0 ):
         self.runxsltproc(which="default_converters", file=filename,
                          opts=opts, outfile=outfile)
      else:
         self.runxsltproc(which="default_converters", file=filename,
                          outfile=outfile)

      return

   def add_default_converters(self, collection=None):

      if ( collection == None ):
         return

      outfile =''.join([collection, '.xml'])
      savefile =''.join([collection, '.xml.save'])
      infile = self.defconverters

      opts = ' '.join(['--stringparam convertfile', infile])

      shutil.copy(outfile, savefile)

      try:
         xx = os.stat(infile)
         q = time.time()
         age = q - xx.st_ctime
         if ( age > 900 ):
            print "Updating converters file"
            self.get_default_converters()
         else:
            print "Converters file is current.", age, "seconds old."
      except OSError, e:
         print "Getting converters file"
         self.get_default_converters()

      try:
         xx = os.stat(infile)
         if ( xx.st_size > 0 ):
            self.runxsltproc(which="add_default_converters", file=savefile,
                             opts=opts, outfile=outfile)
      except:
         return

      return



   #########################################
   #
   #   Get the named file and return to local
   #   directory.
   #
   #   getfile is the full path name of the file
   #   as it exists on the target machine
   #
   def get_file(self, getfile=None, dumpdir=None, binary=0):

      if ( getfile == None ):
         return

      #time.sleep(2)

      action = "get-file"
      if ( self.TENV.targetos == "windows" ):
         zozo = getfile.replace("\\", "/")
         localfile = os.path.basename(zozo)
      else:
         localfile = os.path.basename(getfile)

      if ( dumpdir is not None ):
         copylocation = dumpdir + '/' + localfile
      else:
         copylocation = localfile

      if ( os.access(copylocation, os.F_OK) == 1 ):
         os.remove(copylocation)

      if ( os.access(localfile, os.F_OK) == 1 ):
         os.remove(localfile)

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&type=binary'])
      httpstring = self.TCG.httpstr_appnd(httpstring, "file", getfile, dorep=1)

      #
      #   Allow multiple attempts to get the file
      #
      retry = 0
      while ( retry < self.retrymax ):
         retry = retry + 1
         err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                               dumpfile=localfile, binary=binary)

         if ( err == 0 ):
            try:
               xx = os.stat(localfile).st_size
               if ( xx <= 0 ):
                  if ( retry < 3 ):
                     time.sleep(2)
                  err = 1
               else:
                  if ( dumpdir is not None ):
                     shutil.move(localfile, dumpdir)
                  retry = self.retrymax + 10
            except OSError, e:
               err = 1

      return err

   #########################################
   #
   #   Check the target and get rid of the named file
   #   if it exists in the target run directory.  Do this
   #   we do not get stuck with old files and the output
   #   file does not grow because we keep writing to it.
   #   Used to get rid of the file to be operated on and
   #   the result file (stdout).
   #
   #   removefile is the full path name of the file on
   #   the target host
   #
   def delete_file(self, removefile=None):

      if ( removefile == None ):
         return

      action = "rm-file"

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&type=binary'])
      httpstring = self.TCG.httpstr_appnd(httpstring, "file", removefile, dorep=1)

      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=self.outlog)

      return err

   #########################################
   def exec_command_tryit(self, cmd, cmdopts):

      p = None

      try:
         p = os.popen(cmd + ' ' + cmdopts).read()
      except OSError, e:
         time.sleep(1)
         try:
            p = os.popen(cmd + ' ' + cmdopts).read()
         except OSError, e:
            print "Could not execute ", cmd, ": ", e
            return None

      return p

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

   #########################################

   def exec_command(self, wgetopts):

      try:
         #print self.wget, wgetopts
         p = subprocess.Popen(self.wget + ' ' + wgetopts, shell=True)
         os.waitpid(p.pid, 0)
      except OSError, e:
         time.sleep(1)
         try:
            p = subprocess.Popen(self.wget + ' ' + wgetopts, shell=True)
            os.waitpid(p.pid, 0)
         except OSError, e:
            print "Could not execute ", self.wget, ": ", e
            return 1

      return 0

   def get_db_filename(self, db="system", collection=None):

      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      if ( db == "cache" or db == "log" ):
         if ( collection == None ):
            print "Collection DB has no collection specified."
            return None

      if ( db == "cache" ):
         db = "cache.sqlt"
         dbdirname = self.get_crawl_dir(collection=collection)
      elif ( db == "log" ):
         db = "log.sqlt"
         dbdirname = self.get_crawl_dir(collection=collection)
      elif ( db == "report" ):
         db = "database"
         dbdirname = self.vivisimo_dir(which="data")
         dbdirname = ''.join([dbdirname, sep, 'reporting'])
      elif ( db == "system" ):
         db = time.strftime("%Y-%m")
         dbdirname = self.vivisimo_dir(which="data")
         dbdirname = ''.join([dbdirname, sep, 'system-reporting'])
      else:
         db = time.strftime("%Y-%m")
         dbdirname = self.vivisimo_dir(which="data")
         dbdirname = ''.join([dbdirname, sep, 'system-reporting'])

      dumpspace = ''.join(['querywork/', db])
      db = ''.join([dbdirname, sep, db])

      return dumpspace, db

   def get_remote_database(self, db="system", collection=None):

      statstring = None
      err = 0

      dumpspace, db = self.get_db_filename(db=db, collection=collection)

      if ( db is not None ):
         self.get_file(getfile=db, dumpdir="querywork", binary=1)

      return dumpspace

   def run_db_query(self, dbfile=None, query=None):

      if ( query == None ):
         return

      if ( query[0] != '"' ):
         query = ''.join(['"', query, '"'])

      if ( dbfile == None ):
         db = time.strftime("%Y-%m")
         dbfile = ''.join(['querywork/', db])

      sqlite = "/usr/bin/sqlite3"
      cmdopts = ' '.join([dbfile, query])

      #print cmdopts
      lll = self.exec_command_tryit(sqlite, cmdopts)

      return lll

   #
   #   collection cache:  data/collections/collection/<curcrawl>/cache.sqlt
   #   collection log:    data/collections/collection/<curcrawl>/log.sqlt
   #   sys reports:       data/system-reporting/<year>-<month>
   #   reports:           data/reporting/database
   #
   def run_database_remote(self, dbcmd=None, db="system",
                          collection=None, sql=None):

      if ( dbcmd != "use_current_file" ):
         ldbfile = self.get_remote_database(db=db, collection=collection)
      else:
         ldbfile, db = self.get_db_filename(db=db, collection=collection)

      qres = self.run_db_query(dbfile=ldbfile, query=sql)

      return qres

   def get_db_table_list(self):

      table_list = []

      sqry = ''.join(['".tables"'])
      qres = self.run_database_remote(sql=sqry).split(' ')
      for item in qres:
         if ( item != '' ):
            newitem = item.split('\n')
            for thing in newitem:
               if ( thing != '' ):
                  table_list.append(thing)

      #for item in table_list:
      #   print item

      return table_list

   #
   #   VIVSRVERRIGN can contain (service table):
   #      indexer
   #      crawler
   #
   #   VIVERRIGN can contain (message_id table):
   #     SEARCH_ENGINE_QUERY_SERVICE_STARTING
   #     SEARCH_ENGINE_CRAWLER_STARTED
   #     COLLECTION_SERVICE_SERVICE_TERMINATED
   #     SEARCH_ENGINE_DELETE
   #     SEARCH_ENGINE_EMPTY_INDEX
   #     CONVERTER_EXECUTE_EXIT
   #     SEARCH_ENGINE_DELETE_DIRECTORY
   #     COLLECTION_SERVICE_REFRESH_INPLACE_NOT_IDLE
   #     SEARCH_ENGINE_QUERY_SERVICE_STOPPED
   #     CRAWLER_DISPATCH_TERMINATED
   #     REMOTE_CONNECTING
   #     REMOTE_CONNECT_FROM
   #     REMOTE_CONNECTED
   #     REMOTE_PUSH_FILE
   #     REMOTE_RECEIVE_FILE
   #     REMOTE_PUSHED_FILE
   #     REMOTE_RECEIVED_FILE
   #     REMOTE_SWAPPING
   #     REMOTE_STARTING_TO_SWAP
   #     REMOTE_RENAME
   #     REMOTE_SWAP
   #     REMOTE_SWAPPED
   #     COLLECTION_SERVICE_LOCK_PROCESS_DIED
   #     SEARCH_ENGINE_INDEXER_STARTED
   #     CRAWLER_DISPATCH_PARSE
   #     COLLECTION_SERVICE_PROXY_COMMAND
   #     COLLECTION_SERVICE_SERVICE_START
   #     CORE_AUTHENTICATE
   #
   def get_collection_system_errors(self, collection=None, starttime=0):


      if ( collection == None ):
         return

      errorcount = 0
      ignoreit = 0
      mymod = 0

      errors_ignore = None
      errors_ignore_string = os.getenv('VIVERRIGN', None)
      if ( errors_ignore_string is not None ):
         errors_ignore = errors_ignore_string.split(' ')
         print "SERVICE IGNORE:", errors_ignore
         mymod = mymod + 1

      service_ignore = None
      service_ignore_string = os.getenv('VIVSRVERRIGN', None)
      if ( service_ignore_string is not None ):
         service_ignore = service_ignore_string.split(' ')
         print "SERVICE IGNORE:", service_ignore
         mymod = mymod + 2

      if ( starttime == 0 ):
         starttime = int(os.getenv('VIVSTARTTIME', 0))

      now = time.time()

      table_list = self.get_db_table_list()
      #qry = ''.join(['"select id from collection where value = \'', collection, '\'"'])

      #qry = ''.join(['"select id from reporting where date > ', '%s' % starttime, ' and date < ', '%s' % now, '"'])
      qry = ''.join(['"select reporting.id from collection, reporting where reporting.id = collection.id and collection.value = \'', collection, '\' and reporting.date > ', '%s' % starttime, ' and reporting.date < ', '%s' % now, '"'])

      #print qry

      print "######################"
      print "ERRORS FOR COLLECTION:", collection
      print "   START DATE:        ", time.ctime(starttime)
      print "   END DATE:          ", time.ctime(now)
      #
      #   Added to give the error database time to be updated so stuff from
      #   current test does not overflow into the next test.
      #
      #   This is of course adding 3 seconds to the runtime of every test.
      #
      time.sleep(3)
      qres = self.run_database_remote(dbcmd="use_current_file", sql=qry).split('\n')

      for item in qres:
         if ( item != "" ):
            qry = ''.join(['"select date from reporting where id = \'', item, '\'"'])
            qres2 = self.run_database_remote(dbcmd="use_current_file", sql=qry).split('\n')
            for item2 in qres2:
               if ( item2 != "" ):
                  qr2int = int(item2)
                  if ( qr2int < now ):
                     if ( qr2int > starttime ):
                        print ""
                        print "ERROR DATE:           ", time.ctime(qr2int)
                        qry = ''.join(['"select value from level where id = \'', item, '\'"'])
                        qres3 = self.run_database_remote(dbcmd="use_current_file", sql=qry).split('\n')
                        for item3 in qres3:
                           if ( item3 != "" ):
                              print "ERROR LEVEL:          ", item3

                              if ( item3 == 'errors-high' ):
                                 errorcount = errorcount + 1

                              if ( 'message' in table_list ):
                                 qry = ''.join(['"select value from message where id = \'', item, '\'"'])
                                 qres4 = self.run_database_remote(dbcmd="use_current_file", sql=qry).split('\n')
                                 for item4 in qres4:
                                    if ( item4 != "" ):
                                       print "ERROR MESSAGE:        ", item4

                              if ( 'message_id' in table_list ):
                                 qry = ''.join(['"select value from message_id where id = \'', item, '\'"'])
                                 qres5 = self.run_database_remote(dbcmd="use_current_file", sql=qry).split('\n')
                                 for item5 in qres5:
                                    if ( item5 != "" ):
                                       print "ERROR MESSAGE ID:     ", item5
                                       if ( errors_ignore is not None ):
                                          for zz in errors_ignore:
                                             if ( item5 == zz ):
                                                ignoreit = ignoreit + 1

                              if ( 'module' in table_list ):
                                 qry = ''.join(['"select value from module where id = \'', item, '\'"'])
                                 qres6 = self.run_database_remote(dbcmd="use_current_file", sql=qry).split('\n')
                                 for item6 in qres6:
                                    if ( item6 != "" ):
                                       print "ERROR MODULE:         ", item6

                              if ( 'command' in table_list ):
                                 qry = ''.join(['"select value from command where id = \'', item, '\'"'])
                                 qres7 = self.run_database_remote(dbcmd="use_current_file", sql=qry).split('\n')
                                 for item7 in qres7:
                                    if ( item7 != "" ):
                                       print "ERROR COMMAND:         ", item7

                              if ( 'service' in table_list ):
                                 qry = ''.join(['"select value from service where id = \'', item, '\'"'])
                                 qres8 = self.run_database_remote(dbcmd="use_current_file", sql=qry).split('\n')
                                 for item8 in qres8:
                                    if ( item8 != "" ):
                                       print "ERROR SERVICE:        ", item8
                                       if ( service_ignore is not None ):
                                          for zz in service_ignore:
                                             if ( item8 == zz ):
                                                ignoreit = ignoreit + 2


      if ( mymod > 0 ):
         errorcount = errorcount - ( ignoreit / mymod )

      if ( errorcount > 0 ):
         print "TOTAL ERRORS OF errors-high:", errorcount

      print "######################"

      return errorcount
   #
   #   collection cache:  data/collections/collection/<curcrawl>/cache.sqlt
   #   collection log:    data/collections/collection/<curcrawl>/log.sqlt
   #   sys reports:       data/system-reporting/<year>-<month>
   #   reports:           data/reporting/database
   #
   def run_database_old(self, dbcmd=None, db="system",
                           collection=None, sql=None):

      statstring = None
      err = 0

      sep = '/'
      if ( self.TENV.targetos == "windows" ):
         sep = "\\"

      if ( db == "cache" or db == "log" ):
         if ( collection == None ):
            print "Collection DB has no collection specified."
            return 1

      if ( sql == None ):
         print "No query specified"
         return 1

      if ( db == "cache" ):
         db = "cache.sqlt"
         dbdirname = self.get_crawl_dir(collection=collection)
      elif ( db == "log" ):
         db = "log.sqlt"
         dbdirname = self.get_crawl_dir(collection=collection)
      elif ( db == "report" ):
         db = "database"
         dbdirname = self.vivisimo_dir(which="data")
         dbdirname = ''.join([dbdirname, '/reporting'])
      elif ( db == "system" ):
         db = time.strftime("%Y-%m")
         dbdirname = self.vivisimo_dir(which="data")
         dbdirname = ''.join([dbdirname, '/system-reporting'])
      else:
         db = time.strftime("%Y-%m")
         dbdirname = self.vivisimo_dir(which="data")
         dbdirname = ''.join([dbdirname, '/system-reporting'])

      db = ''.join([dbdirname, sep, db])

      #
      #   The { and } are used to get around problems with
      #   sending quoted strings using http.  It seems that the
      #   quotes are removed no matter how you escape it or
      #   otherwise set it aside.  The {} are pseudo quotes that
      #   will be transcribed into quotes before the command is
      #   executed.  I'm not saying it's a great idea, just that
      #   it works.
      #
      if ( dbcmd == None ):
         cmddirname = self.vivisimo_dir(which="bin")
         command = "sqlite-shell"
         fullcmd = ''.join(['\"', cmddirname, sep, command, ' ',
                            db, ' {', sql, '}', '\"'])
      else:
         fullcmd = ''.join(['\"', dbcmd, ' ',
                            db, ' {', sql, '}', '\"'])

      targetfile = "/tmp/vivdb_output.tmp"

      #print fullcmd

      err = self.execute_command(cmd=fullcmd, dumpfile=targetfile, binary=0)

      if ( err == 0 ):
         statstring = self.runxsltproc("op_data", targetfile)
         #os.remove(targetfile)


      p = re.compile('(<\?xml.*\?>\n)')
      statstring = p.sub('', statstring, count=1)

      print statstring

      return err

   def make_remote_file_executable(self, filename=None, dumpfile=None):

      if (filename == None ):
         return

      if (dumpfile == None ):
         dumpfile = self.outlog

      action = "alter-file"

      httpcmd = self.gronk
      httpstring = ''.join(['action=', action,
                            '&chmod=755',
                            '&file=', filename])

      #print httpstring
      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=dumpfile)

      return err

   def execute_command(self, cmd=None, dumpfile=None, binary=1):

      if ( cmd == None ):
         return

      if (dumpfile == None ):
         dumpfile = self.outlog

      action = "execute"

      cmd = self.HTTP.uriit(cmd)

      httpcmd = self.gronk
      if ( binary == 1 ):
         httpstring = ''.join(['action=', action,
                               '&command=', cmd,
                               '&type=binary'])
      else:
         httpstring = ''.join(['action=', action,
                               '&command=', cmd])

      #print httpstring
      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=dumpfile)

      return err

   def execute_command_as_root(self, cmd=None, dumpfile=None, binary=1):

      if ( cmd == None ):
         return

      if (dumpfile == None ):
         dumpfile = self.outlog

      action = "execute"

      cmd = self.HTTP.uriit(cmd)

      httpcmd = self.gronk
      if ( binary == 1 ):
         httpstring = ''.join(['action=', action,
                               '&runasroot=runasroot',
                               '&command=', cmd,
                               '&type=binary'])
      else:
         httpstring = ''.join(['action=', action,
                               '&runasroot=runasroot',
                               '&command=', cmd])

      print httpstring
      err = self.HTTP.doget(tocmd=httpcmd, argstring=httpstring,
                            dumpfile=dumpfile)

      return err




if __name__ == "__main__":
   filet = CGIINTERFACE()
   filet.put_file("inputs/phonyfile", None)
   filet.get_file("/herbie/rides/again")
   filet.delete_file(removefile="/tmp/herring")
   filet.create_collection(collection="/tmp/herring.xml")
   filet.create_collection(collection="herring")
   filet.create_collection(collection="/tmp/herring")
