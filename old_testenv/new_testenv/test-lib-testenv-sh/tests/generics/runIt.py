#!/usr/bin/python

import cgi_interface, vapi_interface
import os, sys, time, getopt, shutil
import subprocess, string

class daDoRunRun(object):

   def __init__(self, collection_name=None, test_name=None,
                      default_base_name='generalTest', load_q=0, dump_d=0):

      self.test_root = os.getenv('TEST_ROOT', ".")
      self.target_dir = self.test_root + '/tests/generics'

      self.cpath = os.getenv('CLASSPATH', "")
      self.cpath = self.cpath + ':' + self.target_dir

      self.default_base_name = default_base_name
      self.collection_name = collection_name
      if ( test_name is not None ):
         self.test_name = test_name
      else:
         self.test_name = "NoName"

      self.xx =cgi_interface.CGIINTERFACE()
      self.yy = vapi_interface.VAPIINTERFACE()

      self.cleanup()
      self.dump_desc = dump_d
      self.load_queries = load_q

      self.compiled = 0
      self.no_set_up_but_do_crawl = 0

      self.dump_test_description()

      return

   def get_queries_from_file(self, query_file=None):

      if (query_file is None):
         query_file = "TEST_QUERIES"

      my_opt_string = None
      initial_word = "-query"

      if (self.load_queries != 1):
         return(None)

      if ( os.access(query_file, os.R_OK) == 1 ):
         print "======================================================="
         print "==  QUERY LIST FROM FILE"
         fd = open(query_file, 'r')
         for item in fd.readlines():
            item = item.replace('\n', '')
            print item
            flipp = item.split(' ')
            if ( len(flipp) != 2 ):
               print "Query data entered poorly:  exiting"
               sys.exit(-1)
            else:
               if ( my_opt_string is not None ):
                  my_opt_string = my_opt_string + ' ' + initial_word + ' "' + flipp[0] + '" ' + flipp[1]
               else:
                  my_opt_string = initial_word + ' "' + flipp[0] + '" ' + flipp[1]
         fd.close()
         print "==  END QUERY LIST"
         print "======================================================="

      return(my_opt_string)

   def dump_test_description(self):

      if (self.dump_desc != 1):
         return

      if ( os.access("TEST_DESCRIPTION", os.R_OK) == 1 ):
         print "======================================================="
         print "==  DESCRIPTION OF TEST:", self.test_name
         fd = open('./TEST_DESCRIPTION', 'r')
         print fd.read()
         fd.close()
         print "==  END TEST DESCRIPTION"
         print "======================================================="

      return

   def cleanup(self, status=1):

      try:
         if ( self.yy.repository_node_exists(elemtype="syntax", elemname="custom") ):
            self.yy.api_repository_del(elemtype="syntax", elemname="custom")
      except:
         print "No custom/syntax node in the repository"
     
      try:
         if ( self.yy.repository_node_exists(elemtype="options", elemname="query-meta") ):
            self.yy.api_repository_del(elemtype="options", elemname="query-meta")
      except:
         print "No query-meta/options node in the repository"

      if ( status == 0 ):
         shutil.rmtree("logs")
         shutil.rmtree("querywork")

      return

   def compileIt(self, java_file=None):

      java_compile_string = 'javac ' + java_file + ' -d ' + self.target_dir

      print java_compile_string

      if ( os.access(java_file, os.F_OK) != 1 ):
         print java_file, "can not be found"
         sys.exit(-1)

      p = subprocess.Popen(java_compile_string, shell=True)
      os.waitpid(p.pid, 0)

      return


   def checkAndCompile(self, file_base=None, force_compile=0):

      class_file = self.target_dir + '/' + file_base + '.class'
      java_file = self.target_dir + '/' + file_base + '.java'

      if ( os.access(class_file, os.F_OK) != 1 ):
         self.compileIt(java_file)
      else:
         if ( force_compile ):
            self.compileIt(java_file)
         else:
            print class_file, "exists.  No recompile needed.  Continuing ..."

      self.compiled = 1

      return

   def buildThisQuery(self, blurg=None, initial_word=None):

      my_opt_string = None

      for item in blurg:
         flipp = item.split('::')
         if ( len(flipp) != 2 ):
            print "Query data entered poorly:  exiting"
            sys.exit(-1)
         else:
            if ( my_opt_string is not None ):
               my_opt_string = my_opt_string + ' ' + initial_word + ' "' + flipp[0] + '" ' + flipp[1]
            else:
               my_opt_string = initial_word + ' "' + flipp[0] + '" ' + flipp[1]

      return(my_opt_string)

   def genericOptionStringBuild(self, blurg=None, initial_word=None):

      my_opt_string = None

      if ( initial_word == "-query" ):
         my_opt_string = self.buildThisQuery(blurg=blurg, initial_word=initial_word)
      else:
         for item in blurg:
            if ( my_opt_string is not None ):
               my_opt_string = my_opt_string + ' ' + initial_word + ' ' + item
            else:
               my_opt_string = initial_word + ' ' + item

      return(my_opt_string)

   def createCollection(self, update_files=None):

      cfile = self.collection_name + '.xml'
      cex = self.xx.collection_exists(collection=self.collection_name)
      if ( cex == 1 ):
         self.xx.delete_collection(collection=self.collection_name)

      self.yy.api_sc_create(collection=self.collection_name, based_on='default')
      self.yy.api_repository_update(xmlfile=cfile)

      if ( update_files is not None ):
         file_list = update_files.split(";;")
         for item in file_list:
            print "UPDATE REPOSITORY USING", item
            self.yy.api_repository_update(xmlfile=item)

      self.no_set_up_but_do_crawl = 1

      return

   def makeAString(self, blurg=None, initial_word=None):

      my_opt_string = None
      blurg = blurg.split(";;")

      if ( initial_word is not None ):
         my_opt_string = self.genericOptionStringBuild(blurg=blurg,
                                                       initial_word=initial_word)
      else:
         for item in blurg:
            if ( my_opt_string is not None ):
               my_opt_string = my_opt_string + ' ' + item
            else:
               my_opt_string = item

      return(my_opt_string)

   def runJavaTest(self, option_string=None, query_string=None, query_file=None):

      java_run_string = 'java -classpath' + ' "' + self.cpath + '" '
      java_run_string = java_run_string + self.default_base_name + ' -tname ' + self.test_name + ' -collection ' + self.collection_name

      if ( self.no_set_up_but_do_crawl ):
         java_run_string = java_run_string + ' -crawlmode new -nosetup'


      if ( option_string is not None ):
         option_list = self.makeAString(blurg=option_string)
         if ( option_list is not None ):
            java_run_string = java_run_string + ' ' + option_list

      if ( query_string is not None ):
         query_list = self.makeAString(blurg=query_string, initial_word="-query")
         if ( query_list is not None ):
            java_run_string = java_run_string + ' ' + query_list

      query_list = self.get_queries_from_file(query_file=query_file)
      if ( query_list is not None ):
         java_run_string = java_run_string + ' ' + query_list

      print java_run_string
      p = subprocess.Popen(java_run_string, shell=True)
      status = p.wait()
      #os.waitpid(p.pid, 0)

      return(status)



if __name__ == "__main__":

   collection = file_list_string = query_file = None
   tname = query_list_string = run_options_string = None
   dd = rq = 0

   opts, args = getopt.getopt(sys.argv[1:], "C:U:F:Q:R:T:rd", ["collection=", "update_files=", "query_file=", "query_list=", "run_options=", "test_name=", "readqueryfile", "dumpdesc"])

   for o, a in opts:
      if o in ("-C", "--collection"):
         collection_name = a
      if o in ("-T", "--test_name"):
         tname = a
      if o in ("-U", "--update_files"):
         file_list_string = a
      if o in ("-F", "--query_file"):
         query_file = a
      if o in ("-Q", "--query_list"):
         query_list_string = a
      if o in ("-R", "--run_options"):
         run_options_string = a
      if o in ("-r", "--readqueryfile"):
         rq = 1
      if o in ("-d", "--dumpdesc"):
         dd = 1

   colonel_klink = daDoRunRun(test_name=tname, collection_name=collection_name,
                              load_q=rq, dump_d=dd)
   colonel_klink.createCollection(update_files=file_list_string)
   colonel_klink.checkAndCompile(file_base="generalTest")
   status = colonel_klink.runJavaTest(run_options_string, query_list_string, query_file)
   
   colonel_klink.cleanup(status)

   if ( status == 0 ):
      print tname, ":  Test Passed"
   else:
      print tname, ":  Test Failed"

   sys.exit(status)

