
import velocity.*;
import velocity.objects.*;
import velocity.soap.*;
import velocity.types.*;

import Vivisimo.tAPI.*;

import java.util.Set;
import java.util.*;
import java.io.IOException;
import java.io.*;
import java.math.BigInteger;

//
//   This is a generic crawl and query test program.
//   It creates a collection, crawls the collection,  
//   waits for the crawl to be complete, issues queries
//   and checks the results, and then cleans up the collection.
//   It accepts the following options:
//   -collection <collection name>
//      Argument is the name of the collection to be created.  It
//      uses a file of the name <collection name>.xml.
//   -query <query> <expected query result count>
//      Arguments are a space separated pair of the query and the number
//      expected results.
//         Example:  -query my_query 5
//      query for "my_query" and expect 5 results
//   -tname <test name>
//      Argument is the test name this program is to run as.  Supplied
//      so it does not have its multiple runs confused with each other.
//   -errors <expected error count>
//      Argument is the expected number of crawl errors.  The default
//      is 0.
//   -dosetup 
//      No arguments.  Boolean which will cause the test to do
//      collection creation.  This is the default.
//   -doteardown
//      No arguments.  Boolean which will cause the test to do
//      collection destruction/deletion at completion.  This is
//      the default.
//   -nosetup
//      No arguments.  Boolean which will cause the test to NOT do
//      collection creation.  Assume the collection to be used
//      already exists.
//   -noteardown
//      No arguments.  Boolean which will cause the test to NOT do
//      collection creation.  Leave the collection around regardless
//      of whether or not the test fails.
//
//   java generalTest -collection my_collection -tname my_test \
//        -query q1 5 -query q2 87 -query q3 1119
//
//   The test will automatically do a blank query with the expected
//   count to be the n-docs attribute of the vse-index-status node.
//   Crawl errors are gotten by the API and by extracting them from
//   the repository.  They are compared to each other and the expected
//   error count to assure consistency and correctness.
//   All other results are determined by crawl completion and the query
//   results.
//

public class generalTest
{

    static String testName = "generalTest";

    //
    //   Create the collection and wait for the crawl to finish.
    //
    public static vSourceCollection createIt(String collectionName,
                                             java.lang.Boolean doSetup,
                                             java.lang.Boolean reCrawl,
                                             java.lang.Boolean doUpdates,
                                             String crawlMode,
                                             String subCollection,
                                             tCommonCases tCC) {

        vSourceCollection zz = null;

        long start, end, elapsed;
        start = end = elapsed = 0;

        try  {

           zz = new vSourceCollection(collectionName);

           zz.setUser("gary_testing");
           zz.setPassword("mustang5");
           zz.setSubcollection(subCollection);

           if (doSetup) {
              //
              //   If the collection exists, delete it.
              //
              if (zz.collectionExists()) {
                 zz.deleteCollection();
              }

              //
              //   Create the collection
              //   Make sure it exists
              //   Start the crawl.
              //
              zz.createCollection();
              if (zz.collectionExists()) {
                 if (doUpdates) {
                    tCC.doCollectionUpdates();
                 }
                 System.out.println("====================================");
                 System.out.println("Crawl is new on a new collection.");
                 System.out.println("Crawl mode          : " + crawlMode);
                 System.out.println("Crawl sub-collection: " + subCollection);
                 System.out.println("====================================");
                 start = System.currentTimeMillis();
                 zz.startCrawl(crawlMode);
              }
           } else {
              if (reCrawl) {
                 if (zz.collectionExists()) {
                    System.out.println("====================================");
                    System.out.println("Crawl is recrawl of an old collection.");
                    System.out.println("Crawl mode          : " + crawlMode);
                    System.out.println("Crawl sub-collection: " + subCollection);
                    System.out.println("====================================");
                    start = System.currentTimeMillis();
                    zz.startCrawl(crawlMode);
                 }
              } else {
                 System.out.println("====================================");
                 System.out.println("Crawl is none.  Should be complete.");
                 System.out.println("Crawl sub-collection: " + subCollection);
                 System.out.println("====================================");
                 start = System.currentTimeMillis();
              }
           }
           if (zz.collectionExists()) {
              zz.waitForCrawlToFinish();
              end = System.currentTimeMillis();
              //
              //   Wait for all the internal files to sync up.
              //
              Thread.sleep(5*1000);
           }
        } catch (java.lang.Exception e) {
           e.printStackTrace();
        }

        elapsed = end - start;
        System.out.println("====================================");
        System.out.println("=");
        System.out.println("=  Crawl run time in milliseconds:  " + elapsed);
        System.out.println("=");
        System.out.println("====================================");
        return(zz);
    }

    //
    //   Delete the collection
    //
    public static void getRidOfIt(vSourceCollection zz) {
       try  {
          zz.deleteCollection();
       } catch (java.lang.Exception e) {
          e.printStackTrace();
       }
    }

    //
    //   Run the test, obviously
    //
    public static void runTest(String collectionName,
                               java.lang.Boolean doSetup,
                               java.lang.Boolean doTearDown, 
                               java.lang.Boolean reCrawl, 
                               java.lang.Boolean doUpdates, 
                               Hashtable<String,ArrayList<String>> queryECount,
                               BigInteger eErrors,
                               String crawlMode,
                               String subCollection,
                               java.lang.Boolean exitWithLastQueryValue,
                               String queryFile) {

       vSourceCollection zz = null;

       ///////////////////////////////////////////////
       //
       //   Load the test data from query file
       //
       tInputData tData = new tInputData(queryFile, queryECount);
       if (tData.getCollectionName() == null ||
           tData.getCollectionName().equals("No Collection Name")) {
          System.out.println("Setting collection name:  " + collectionName);
          tData.setCollectionName(collectionName);
       }
       if (tData.getTestName() == null ||
           tData.getTestName().equals("No Test Name")) {
          System.out.println("Setting test name:  " + testName);
          tData.setTestName(testName);
       }
       Integer ePassCount = tData.getExpectedPassCount();
       //
       //   Set the data up to be consumed.
       //
       tCommonCases tCC = new tCommonCases(tData);
       //
       ///////////////////////////////////////////////

       ///////////////////////////////////////////////
       //
       //   Create the collection and wait for the crawl to finish.
       //
       try {
          // vSourceCollection zz = createIt(collectionName, doSetup);
          zz = createIt(collectionName, doSetup, reCrawl, doUpdates,
                        crawlMode, subCollection, tCC);
       } catch (java.lang.Exception jle) {
          System.out.println("=======================================");
          System.out.println(testName + ":  Create, Crawl, Wait");
          System.out.println(testName + ":  This fail means that the");
          System.out.println(testName + ":  collection could not be created,");
          System.out.println(testName + ":  crawled, or have status found for");
          System.out.println(testName + ":  some unknown reason.");
          System.out.println("=======================================");
          System.exit(-9);
       }
       //
       ///////////////////////////////////////////////

       ///////////////////////////////////////////////
       //
       //   Run the tests
       //
       tCC.errorStatisticsMatch(eErrors);
       tCC.checkCollectionStatistics();
       tCC.doAllQueries();
       //
       ///////////////////////////////////////////////

       if (tCC.getActualPassCount() == tCC.getExpectedPassCount()) {
          if (doTearDown) {
             getRidOfIt(zz);
          }
          System.out.println(testName + ":  Test Passed");
          if (exitWithLastQueryValue) {
             System.exit(tCC.getNDocs());
          } else {
             System.exit(0);
          }
       } else {
          System.out.println(testName + ":  Test Failed");
          System.exit(1);
       }
    }

    public static void main(String[] args) {

       Hashtable<String,ArrayList<String>> queryECount = new Hashtable<String,ArrayList<String>>();
       String collectionName = null;
       String crawlMode = "new";
       String subCollection = "live";
       String queryFile = "TEST_QUERIES";
       BigInteger eErrors;
       java.lang.Boolean doSetup, doTearDown, reCrawl, doUpdates;
       java.lang.Boolean exitWithLastQueryValue;
       int i;

       doSetup = doTearDown = doUpdates = true;
       exitWithLastQueryValue = false;
       reCrawl = false;
       eErrors = new BigInteger("0");

       //
       //   Option processing.  See top of file for information on
       //   the options.
       //
       for (i = 0; i < args.length; i++) {
          if (args[i].equals("-collection")) {
             collectionName = args[i + 1];
             i++;
          } else if (args[i].equals("-query")) {
             String queryStr = args[i + 1];
             ArrayList<String> junk = new ArrayList<String>();
             junk.add(args[i + 2]);
             queryECount.put(queryStr, junk);
             i = i + 2;
          } else if (args[i].equals("-tname")) {
             testName = args[i + 1];
             i++;
          } else if (args[i].equals("-queryfile")) {
             queryFile = args[i + 1];
             i++;
          } else if (args[i].equals("-crawlmode")) {
             crawlMode = args[i + 1];
             i++;
             reCrawl = true;
          } else if (args[i].equals("-subcollection")) {
             subCollection = args[i + 1];
             i++;
          } else if (args[i].equals("-dosetup")) {
             doSetup = true;
          } else if (args[i].equals("-ewlqv")) {
             exitWithLastQueryValue = true;
          } else if (args[i].equals("-doteardown")) {
             doTearDown = true;
          } else if (args[i].equals("-nosetup")) {
             doSetup = false;
          } else if (args[i].equals("-noupdate")) {
             doUpdates = false;
          } else if (args[i].equals("-noteardown")) {
             doTearDown = false;
          } else if (args[i].equals("-errors")) {
             eErrors = new BigInteger(args[i + 1]);
             i++;
          } else {
             System.out.println("I dunno");
          }
       }

       //
       //   Information is gathered ...
       //   run the test.
       //
       runTest(collectionName, doSetup, doTearDown, reCrawl, doUpdates,
               queryECount, eErrors, crawlMode,
               subCollection, exitWithLastQueryValue, queryFile);

    }
}

