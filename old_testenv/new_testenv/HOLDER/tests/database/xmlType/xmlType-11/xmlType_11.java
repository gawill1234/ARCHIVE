
import velocity.*;
import velocity.objects.*;
import velocity.soap.*;
import velocity.types.*;

import java.util.Set;
import java.io.IOException;

public class xmlType_11
{

    static String testName = "xmlType_11";

    //
    //   Create the collection and wait for the crawl to finish.
    //
    public static vSourceCollection createIt(String collectionName) {

        vSourceCollection zz = null;

        try  {
           zz = new vSourceCollection(collectionName);

           //zz.setUser("gary_testing");
           //zz.setPassword("mustang5");

           if (zz.collectionExists()) {
              zz.deleteCollection();
           }

           zz.createCollection();
           zz.collectionExists();
           zz.startCrawl("new");
           zz.waitForCrawlToFinish();
        } catch (java.lang.Exception e) {
           e.printStackTrace();
        }

        return(zz);
    }

    //
    //   Create a query object of the given collection.
    //
    public static vQuery buildQueryObj(String collectionName) {

       vQuery yy = null;

       try  {
          yy = new vQuery(collectionName);
          yy.setNumMax(500);
       } catch (java.lang.Exception e) {
          e.printStackTrace();
       }

       return(yy);
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

    public static void queryResults(vQuery yy, int expected, int actual) {
        System.out.println("=======================================");
        System.out.println("Test " + testName);
        System.out.println("   Collection......:" + yy.getCollectionName());
        System.out.println("   (:Query:)......(:" + yy.getLastQuery() + ":)");
        System.out.println("   Query Time......:" + yy.getElapsedTimeInSeconds() + " seconds");
        System.out.println("   Expected Value..:" + expected);
        System.out.println("   Actual Value....:" + actual);
        System.out.println("=======================================");
    }

    //
    //   Do a query on the collection and count the results.
    //
    public static boolean goodQuery(vQuery yy, String myQuery, int expectedCount) {

        Set<String> gruber = null;
        int resultCount = 0;
        String displayQuery = ":" + myQuery + ":";

        try  {
           QueryResults blah = yy.getQueryObject(myQuery);
           if (blah != null) {
              resultCount = yy.queryForContentCount(blah, "SYS_NC_ROWINFO$", false);
              queryResults(yy, expectedCount, resultCount);
              if (resultCount != expectedCount) {
                 gruber = yy.extractQueryContent(blah, "SYS_NC_ROWINFO$");
                 if (gruber != null) {
                    for (String c: gruber) {
                       System.out.println("TITLE: " + c);
                    }
                 }
              }
           } else {
              System.out.println("No QueryResult object to process");
           }
        } catch (java.lang.Exception e) {
           e.printStackTrace();
        }

        if (resultCount != expectedCount) {
           return(false);
        }
        return(true);
    }

    public static void main(String[] args) {

       String collectionName = "xmlType_test_11";
       int passCount = 0;
       int ePassCount = 4;

       vSourceCollection zz = createIt(collectionName);
       vQuery yy = buildQueryObj(collectionName);

       if (goodQuery(yy, "", 138)) {
          passCount += 1;
       }
       if (goodQuery(yy, "", 138)) {
          passCount += 1;
       }
       if (goodQuery(yy, "samba", 88)) {
          passCount += 1;
       }
       if (goodQuery(yy, "oracle", 10)) {
          passCount += 1;
       }

       if (passCount == ePassCount) {
          getRidOfIt(zz);
          System.out.println(testName + ":  Test Passed");
          System.exit(0);
       } else {
          System.out.println(testName + ":  Test Failed");
          System.exit(1);
       }
    }
}

