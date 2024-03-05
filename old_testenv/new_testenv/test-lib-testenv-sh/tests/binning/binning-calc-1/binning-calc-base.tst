#!/usr/bin/python
import sys, os, random, time, shutil
import collectionObj, queryObj, docCmpObj, queryDataObj
import vapi_interface

def setup_compare_files(tname):

   basedir = 'query_cmp_files'

   print tname, ":  Get rid of old compare files"
   try:
      shutil.rmtree(basedir)
   except:
      print tname, ":  query_cmp_files directory does not exist, OK"

   print tname, ":  Put correct compare files in place"
   try:
      targetarch = os.getenv('VIVTARGETARCH', 'linux64')
      moveit = basedir + '.' + targetarch
      shutil.copytree(moveit, basedir)
   except:
      print tname, ":  Could not create compare files in query_cmp_files"
      print tname, ":  Test Failed"
      sys.exit(1)

   return

if __name__ == "__main__":

   try:
      tname = sys.argv[1]
   except:
      print "Test Failed, which one do I run?"
      print "Choose from binning-calc-[1 | 2 | 3 | 4 | 5]"
      sys.exit(1)

   nsave = os.getenv('NEWTESTSAVE', 'NO')
   if ( nsave == 'Yes' ):
      try:
         shutil.rmtree('query_cmp_files')
      except:
         print tname, ":  query_cmp_files directory does not exit, OK"
      os.mkdir('query_cmp_files')
   else:
      setup_compare_files(tname)

   qryfile = tname + '.queries'

   allres = 0
   xmlfile = None

   version = float(os.environ["VIVVERSION"])
   if ( version < 8.0 ):
      print tname, ":  Test Failed"
      print tname, ":  Wrong Velocity Version (min 8.0), Actual:", version
      sys.exit(1)

   print tname, ":  Query File =", qryfile
   thingy = queryDataObj.queryData(qryfile)

   # Add custom repository node for ranged searches
   vapi = vapi_interface.VAPIINTERFACE()
   vapi.api_repository_update(xmlfile='syntaxnode.xml')

   tc = None
   while ( thingy.get_current_query() is not None ):

      print "======================================================"

      thingy.dump_current_query()

      newc = thingy.get_current_query_collection()
      tq = thingy.get_current_query()
      too = thingy.get_current_otheropts()
      to = thingy.get_current_query_file()

      if ( newc != tc ):
         tc = newc
		 # Create search collection, reuse if it doesn't already exist
         thiscollection = collectionObj.Collection(collection_name=tc)

      #
      #   Reqular query-search
      #
      thisquery = queryObj.Query(collection_name=tc, query=tq, outfile=to,
                        otheroptions=too)

      thisquery.run_the_query()

      qout = thisquery.get_query_file()
      qcmp = thisquery.get_compare_file()

      resobj = docCmpObj.Compare(qout, qcmp)

      resobj.vb_score_compare()
      resobj.do_query_compare()
      resobj.do_binning_check()
      cpf = resobj.get_score_compare_result()

      print "---> COLLECTION : ", tc
      print "---> QUERY      : ", tq
      if ( cpf == 0 ):
         print "---> CASE RESULT:  Pass"
      else:
         print "---> CASE RESULT:  Fail"

      print "======================================================"

      allres += cpf

      thingy.next_query()

   if ( allres == 0 ):
      print tname, ":  Test Passed"
      cc = vapi.cleanup_collection(collection=tc, delete=True)
      if ( cc ):
         print "Successfully deleted collection"
      else:
         print "Unsuccessful attempt to delete collection, ignored"
   else:
      print tname, ":  Test Failed"
      cc = vapi.cleanup_collection(collection=tc, kill=True)
      if ( cc ):
         print "Successfully stopped crawler and indexer"
      else:
         print "Unsuccessful attempt to stop services, ignored"


   sys.exit(allres)
