
import velocity.*;
import velocity.objects.*;
import velocity.soap.*;
import velocity.types.*;

import Vivisimo.tAPI.*;

import java.util.Set;
import java.util.HashSet;
import java.io.*;

public class cleanCollection
{

    static int ggoyle = 0;

    public static Set readMyFile(String MyFile) {

       Set<String> doneTests = new HashSet<String>();

       System.out.println("Load completed test data");
       try{

          // Open the file that is the first 
          // command line parameter
          FileInputStream fstream = new FileInputStream(MyFile);

          // Get the object of DataInputStream
          DataInputStream in = new DataInputStream(fstream);
          BufferedReader br = new BufferedReader(new InputStreamReader(in));
          String strLine;

          //Read File Line By Line
          while ((strLine = br.readLine()) != null)   {
             // Print the content on the console
             doneTests.add(strLine.split(",")[0]);
          }

          //Close the input stream
          in.close();
       } catch (java.lang.Exception e){
          //Catch exception if any
          System.err.println("Error: " + e.getMessage());
       }

       return(doneTests);
    }

    //
    //   Do the actual delete.  First try a normal kill and delete.  If that
    //   generatates an error, do a hard remove of the directory and the 
    //   repository nodes.
    //
    public static void doDelete(vSourceCollection qq, GRONK zz,
                                vRepository rid, int howKill) {

       int killByPID = 0;
       int killByCrIdx = 1;
       int killByCol = 2;
       Set<String> gruber = null;

       System.out.println("Delete collection " + qq.getCollectionName());
       try {
          System.out.println("DELETE IT");

          if (howKill == killByPID) {

             //
             //   This section will get the PIDs for the named service
             //   and delete them all.  Then it will delete the collection
             //   without attempting to kill the services again UNLESS
             //   both services appear to already be done, in which case
             //   we make sure by killing them again
             //
             gruber = zz.getServicePidList(qq.getCollectionName(), "crawler");
             if (gruber != null) {
                while (gruber != null) {
                   for (String cN : gruber) {
                      System.out.println("Kill Crawler PID: " + cN);
                      zz.killServicePID(qq.getCollectionName(), cN);
                   }
                   gruber = zz.getServicePidList(qq.getCollectionName(),"crawler");
                }
             } else {
                killByPID += 1;
             }
             gruber = zz.getServicePidList(qq.getCollectionName(), "indexer");
             if (gruber != null) {
                while (gruber != null) {
                   for (String cN : gruber) {
                      System.out.println("Kill Indexer PID: " + cN);
                      zz.killServicePID(qq.getCollectionName(), cN);
                   }
                   gruber = zz.getServicePidList(qq.getCollectionName(),"indexer");
                }
             } else {
                killByPID += 1;
             }
             if (killByPID < 2) {
                qq.deleteCollection(true);
             } else {
                qq.deleteCollection(false);
             }

          } else if (howKill == killByCrIdx) {

             //
             //   This section will kill the service by collection.  Then
             //   it deletes the collection without trying to do the service
             //   kill again (since the "again" would be a repeat of the kills).
             //
             zz.killCrawler(qq.getCollectionName());
             zz.killIndexer(qq.getCollectionName());
             qq.deleteCollection(true);

          } else {

             //
             //   Delete the collection.  The function will attempt to 
             //   kill the services.
             //
             qq.deleteCollection(false);
          }

          if (zz.checkCollectionExists(qq.getCollectionName()) ||
              qq.collectionExists()) {
             zz.rmCollection(qq.getCollectionName());
             rid.repositoryCollectionFlush(qq.getCollectionName());
          }

       } catch (java.lang.Exception jle) {
          System.out.println("Delete failed.  Try the hard way ...");
          zz.rmCollection(qq.getCollectionName());
          rid.repositoryCollectionFlush(qq.getCollectionName());
       }
    }

    //
    //   Look for an item in gruber that is NOT in old_gruber.  If that is
    //   the case it means everything in old_gruber is through and can be
    //   obliterated.
    //
    public static java.lang.Boolean thereIsANewOne(Set<String> gruber,
                                                   Set<String> old_gruber) {
       try {
          for (String cN : gruber) {
             if (!old_gruber.contains(cN)) {
                return(true);
             }
          }
       } catch (java.lang.Exception jle) {
          return(false);
       }
       return(false);
    }

    //
    //   Get the list of collections as represented within the repository.
    //   When it is possible, delete some of them.
    //
    public static Set gargoyle(Set<String> old_gruber, int flag) {

       Set<String> gruber = null;

       GRONK zz = new GRONK();
       vRepository repo = null;
       vSourceCollection tCol = null;

       try {
          repo = new vRepository();
       } catch (java.lang.Exception jle) {
          System.out.println("Could not build repo object, done here");
          repo = null;
       }

       if (repo != null) {
          try {
             if (flag == 0) {
                gruber = repo.apiRepositoryListCollections();
             } else {
                gruber = zz.getCollectionList();
             }
          } catch (java.lang.Exception jle) {
             System.out.println("Collection list failed");
          }
       }

       if (old_gruber != null) {
          if (thereIsANewOne(gruber, old_gruber)) {
             ggoyle += 1;
             if (ggoyle == 3) {
                ggoyle = 0;
                for (String cN : old_gruber) {

                   try {
                      tCol = new vSourceCollection(cN);
                   } catch (java.lang.Exception jle) {
                      System.out.println("Bogus");
                   }

                   System.out.println("COLLECTION:  " + cN);
                   try {
                      //
                      //   This routine is for deletion in any form.  So find
                      //   any remnants of a collection and get rid of them.  Try
                      //   the sane way and follow it immediately with a means
                      //   will force the deletion.
                      //
                      if (zz.checkCollectionExists(cN) ||
                         tCol.collectionExists()) {
                         System.out.println("Yup");
                         System.out.println("Delete it");
                         doDelete(tCol, zz, repo, 0);
                      }
                   } catch (java.lang.Exception jle) {
                      System.out.println("Crud");
                   }
                }
             }
             //
             //   Get the list again.  Since so many have been deleted
             //   this should help make subsequent passes shorter if
             //   the first pass was a long list.
             //
             try {
                if (flag == 0) {
                   gruber = repo.apiRepositoryListCollections();
                } else {
                   gruber = zz.getCollectionList();
                }
             } catch (java.lang.Exception jle) {
                System.out.println("Collection re-list failed");
             }
          }
       }

       return(gruber);
    }

    //
    //   Basic collection removal scheme.  Depends on collection having
    //   the same name as the test, which is true most of the time.  So,
    //   after we periodically read the RESULTS file and get finished tests
    //   we know we have those collectios as finished; the test has a result,
    //   therefore we are done with it and its collections.  We can delete
    //   them.
    //
    public static void stupid2(Set<String> globby) {

       Set<String> repogruber = null;

       GRONK zz = new GRONK();
       vRepository repo = null;
       vSourceCollection tCol = null;

       try {
          repo = new vRepository();
       } catch (java.lang.Exception jle) {
          System.out.println("Could not build repo object, done here");
          repo = null;
       }

       for (String cN : globby) {

          try {
             tCol = new vSourceCollection(cN);

             System.out.println("COLLECTION:  " + cN);
             if (zz.checkCollectionExists(cN)) {
                doDelete(tCol, zz, repo, 0);
             }

             try {
                if (tCol.collectionExists()) {
                   if (repo != null) {
                      System.out.println("Forced flush from repository of " + cN);
                      repo.repositoryCollectionFlush(cN);
                   }
                }
             } catch (java.lang.Exception jle) {
                System.out.println("Forced delete failed for " + cN);
             }

          } catch (java.lang.Exception jle) {
             System.out.println("Could not get collection object for " + cN);
          }
       }
    }

    public static void showUsage() {

       System.out.println("Usage:");
       System.out.println("   cleanCollection -R|T <filename>|D|A");
       System.out.println("   -R : Get the collection list from the repository");
       System.out.println("        Any source or collection which is not part");
       System.out.println("        of the Velocity install");
       System.out.println("   -T <filename> : Get collections based on");
       System.out.println("        test results in the named file (RESULTS)");
       System.out.println("        Assumes collection name is same as test");
       System.out.println("   -D : Get collections from search-collections");
       System.out.println("        directories");
       System.out.println("   -A <filename>: Alternate using all 3 of above");
       System.out.println("        <filename> is for the -T portion");
       System.exit(1);
    }

    public static void main(String[] args) {

      Set<String> globby = null;
      Set<String> dirtbag = null;
      Set<String> old_gruber = null;
      String filename = null;
      int passCount = 0;
      int flag = 0;
      int i;
      java.lang.Boolean alternator = false;
  
      if (args.length == 0) {
         showUsage();
      } else {
         for (i = 0; i < args.length; i++) {
            if ( args[i].equals("-R")) {
               flag = 0;
            } else if ( args[i].equals("-T")) {
               flag = 1;
               filename = args[i + 1];
            } else if ( args[i].equals("-D")) {
               flag = 2;
            } else if ( args[i].equals("-A")) {
               flag = 0;
               filename = args[i + 1];
               alternator = true;
            } else {
               showUsage();
            }
         }
      }

      while ( true ) {

         if (flag == 0) {
            //
            //  Grab collections based on being in the repository
            //    R
            //
            old_gruber = gargoyle(old_gruber, flag);
            for (String cN : old_gruber) {
               System.out.println("Repository collection: " + cN);
            }
         } else if (flag == 1) {
            //
            //  Grab collections based on test results
            //    T
            //
            globby = readMyFile(filename);
            stupid2(globby);
         } else {
            //
            //  Grab collections based on search-collections directories
            //    D
            //
            dirtbag = gargoyle(dirtbag, flag);
         }

         if (alternator) {
            flag += 1;
            if (flag > 2) {
               flag = 0;
            }
         }

         try {
            Thread.sleep(15000);
         } catch (java.lang.Exception jle) {
            System.out.println("Sleep failed.  Do not care.  Continuing.");
         }
      }
   }
}
