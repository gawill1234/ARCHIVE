package Vivisimo.tAPI;

import velocity.*;
import velocity.objects.*;
import velocity.soap.*;
import velocity.types.*;

import java.util.Set;
import java.util.*;
import java.io.IOException;
import java.io.*;
import java.net.URL;
import java.math.BigInteger;

///////////////////////////////////////////////////////////////////
//
//   This class is a pure consumer.  Filled in hash tables are
//   provided to it and they are processed accordingly for each 
//   individual hash.  This does not ever look for data in some
//   other location.  It ONLY consumes what is provided.
//
public class tCommonCases
{

    Hashtable<String,ArrayList<String>> tCC_updateShit = null;
    Hashtable<String,ArrayList<String>> tCC_statusShit = null;
    Hashtable<String,ArrayList<String>> tCC_queryECount = null;
    //Hashtable<String,String> tCC_queryECount = null;

    String tCC_CollectionName = null;
    String tCC_TestName = null;

    Integer tCC_EPassCount = 0;
    Integer tCC_APassCount = 0;

    Integer grNDocs = 0;
    Integer grNErrors = 0;
    BigInteger nErrors = new BigInteger("0");

    GRONK tCC_grnk = null;

    //
    //   Methods to use the class values.
    //   Execute the class.
    //
    //
    //   Create a query object of the given collection.
    //
    private static vQuery buildQueryObj(String collectionName, Integer nDocs) {

       vQuery yy = null;

       //
       //   Make it so any query can always return every document in the
       //   collection by setting the num value of the query to the number
       //   of docs APPARENTLY in the collection plus two thousand.
       //
       try  {
          yy = new vQuery(collectionName);
          yy.setNumMax(nDocs + 2000);
          yy.setODups(true);
          yy.setFetchTimeOut(60000 * 10);
       } catch (java.lang.Exception e) {
          e.printStackTrace();
       }

       return(yy);
    }

    ///////////////////////////////////////////////////
    //
    //   Some of the binning queries may have a # as a proxy
    //   for a line feed.  This function replaces the # with an
    //   actual line feed.  The proxy is used to make it easier to
    //   present to the test queries which use multiple bins.
    //
    private String massageQuery(String myQuery, vQuery yy) {

        if (myQuery != null) {
           if (myQuery.indexOf("==") > 0) {
              if (myQuery.indexOf('#') > 0) {
                 myQuery = myQuery.replace("#", "\n");
              }
              yy.setBinningState(myQuery);

              return(myQuery);
           }
        }

        return(null);
    }
    //
    ///////////////////////////////////////////////////

    private boolean dumpCompareData(vQuery yy, String cmpFile, QueryResults blah) {

        Integer m1cnt = 0;
        Integer m2cnt = 0;
        Integer m12diff = 0;

        System.out.println("   Compare File....:" + cmpFile);
        String realFile = "query_cmp_files/" + cmpFile;

        try {
           Set<String> fizzy = yy.extractQueryDocument(blah, "url");
           Set<String> dizzy = new queryXML(realFile, true).getQDocUrlList();
           for (String cN : dizzy) {
              if (!fizzy.contains(cN)) {
                 m1cnt++;
                 System.out.println("   Compare Diff(1).:" + cN);
              }
           }
           for (String cN : fizzy) {
              if (!dizzy.contains(cN)) {
                 m2cnt++;
                 System.out.println("   Compare Diff(2).:" + cN);
              }
           }
           if (m1cnt > m2cnt) {
              m12diff = m1cnt - m2cnt;
           } else {
              m12diff = m2cnt - m1cnt;
           }
           System.out.println("   Compare Diff....:" + m12diff);
        } catch (java.lang.Exception jle) {
           System.out.println("   Case Error......:BLAH");
           //return(false);
        }

        if (m12diff == 0) {
           return(true);
        }

        return(false);
    }

    private boolean fileIsUsable(String cmpFile) {

       if (cmpFile != null) {
           String realFile = "query_cmp_files/" + cmpFile;
           File f = new File(realFile);
           if (f.exists()) {
              return(true);
           }
       }

       return(false);
    }

    ///////////////////////////////////////////////////
    //
    //   Dump the results of executed queries in a consistent manner.
    //
    private boolean queryResults(vQuery yy, int expected, int actual,
                              String cmpFile, QueryResults blah) {

        boolean itPass = true;

        System.out.println("=======================================");
        System.out.println("=    QUERY RETURN CHECKS              =");
        System.out.println("Test " + this.tCC_TestName);
        System.out.println("   Collection......:" + yy.getCollectionName());
        System.out.println("   (:Query:)......(:" + yy.getLastQuery() + ":)");
        System.out.println("   Query Time......:" + yy.getElapsedTimeInSeconds() + " seconds");
        System.out.println("   Expected Value..:" + expected);
        System.out.println("   Actual Value....:" + actual);
        if (fileIsUsable(cmpFile)) {
           if (!dumpCompareData(yy, cmpFile, blah)) {
              itPass = false;
           }
        }
        if (actual == expected) {
           System.out.println("   Case Result.....:PASS");
        } else {
           System.out.println("   Case Result.....:FAIL");
           itPass = false;
        }
        System.out.println("=======================================");

        return(itPass);
    }
    //
    ///////////////////////////////////////////////////

    ///////////////////////////////////////////////////
    //
    //   Run each individual query.
    //
    private boolean goodQuery(vQuery yy, String myQuery,
                              int expectedCount, String cmpFile) {

        Set<String> gruber = null;
        int resultCount = 0;
        boolean useEmptyQuery = false;
        boolean itPasses = true;
        QueryResults blah = null;

        String glimmer = this.massageQuery(myQuery, yy);

        if (glimmer != null) {
           useEmptyQuery = true;
        }

        try  {
           if (useEmptyQuery) {
              //blah = yy.runQueries("", "last_query_file");
              blah = yy.getQueryObject("");
           } else {
              //blah = yy.runQueries(myQuery, "last_query_file");
              blah = yy.getQueryObject(myQuery);
           }
           if (blah != null) {
              //resultCount = yy.queryForContentCount(blah, "title", false);
              resultCount = yy.countQueryDocument(blah, "url");
              itPasses = this.queryResults(yy, expectedCount, resultCount,
                                           cmpFile, blah);
              if (resultCount != expectedCount) {
                 gruber = yy.extractQueryDocument(blah, "title");
                 if (gruber != null) {
                    for (String c: gruber) {
                       System.out.println("URL: " + c);
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
           itPasses = false;
        }
        return(itPasses);
    }
    //
    ///////////////////////////////////////////////////

    private void loadServiceStatistics() {

       try {
          vServices vs = new vServices(this.tCC_CollectionName);
          this.nErrors = vs.crawlerNErrors();
          this.incrExpectedPassCount();
       } catch (java.lang.Exception jle) {
          this.nErrors = new BigInteger("-1");
       }
    }

    private void loadGronkStatistics() {
       try {
          this.grNErrors = this.tCC_grnk.grnkGetCrawlerStatusIntAttr(
                      this.tCC_CollectionName, "n-errors");
          this.grNDocs = this.tCC_grnk.grnkGetIndexerStatusIntAttr(
                      this.tCC_CollectionName, "n-docs");
          this.incrExpectedPassCount();
       } catch (java.lang.Exception jle) {
          System.out.println("=======================================");
          System.out.println(this.tCC_TestName + ":  GRONK data gather");
          System.out.println(this.tCC_TestName + ":  This fail means GRONK could not");
          System.out.println(this.tCC_TestName + ":  retrieve the needed data.  Some");
          System.out.println(this.tCC_TestName + ":  likely culprits are:");
          System.out.println(this.tCC_TestName + ":  * The connector being tested has");
          System.out.println(this.tCC_TestName + ":  not been properly installed.");
          System.out.println(this.tCC_TestName + ":  Please check and try again.");
          System.out.println(this.tCC_TestName + ":  * The collection being sought is");
          System.out.println(this.tCC_TestName + ":  not the same name as the one");
          System.out.println(this.tCC_TestName + ":  which was installed.  Check the");
          System.out.println(this.tCC_TestName + ":  command line and the TEST_QUERIES");
          System.out.println(this.tCC_TestName + ":  file to make sure conflicting");
          System.out.println(this.tCC_TestName + ":  collection names are not being");
          System.out.println(this.tCC_TestName + ":  used.");
          System.out.println("=======================================");
       }
    }

    private void loadStandardStatistics() {

       this.loadGronkStatistics();
       this.loadServiceStatistics();

    }
    //
    ////////////////////////////////////////////////////////
    private void statisticResults(String updStr, String attrName, String attrEValue,
                                  String aValue) {
       System.out.println("=======================================");
       System.out.println("=    STATUS/STATISTICS VALUE CHECKS   =");
       System.out.println("Test " + this.tCC_TestName);
       System.out.println("   Collection......:" + this.tCC_CollectionName);
       System.out.println("   XPath...........:" + updStr);
       System.out.println("   (:ATTR:).......(:" + attrName + ":)");
       System.out.println("   Expected Value..:" + attrEValue);
       System.out.println("   Actual Value....:" + aValue);
       if (aValue.equals("NOT FOUND")) {
          System.out.println("   The specified path or attribute may");
          System.out.println("   not exist.  Please check that:");
          System.out.println("   XPath:     " + updStr);
          System.out.println("   Attribute: " + attrName);
          System.out.println("   are, in fact, correct names.");
       }
       if (attrEValue.equals(aValue)) {
          this.incrActualPassCount();
          System.out.println("   Case Result.....:PASS");
       } else {
          System.out.println("   Case Result.....:FAIL");
       }
       System.out.println("=======================================");
    }
    ////////////////////////////////////////////////////////
    //
    //   Based on the status values in the test data file (TEST_QUERIES),
    //   check that the expected value and the real values match.
    //
    public void checkCollectionStatistics() {

       Enumeration myStatus;
       boolean myPass = true;
       GRONK yabba = new GRONK();

       if (this.tCC_statusShit == null) {
          return;
       }

       String answer = yabba.getCollection(this.tCC_CollectionName);
       if (answer != null) {
          GoGetXML dabba = new GoGetXML(answer);

          myStatus = this.tCC_statusShit.keys();
          while (myStatus.hasMoreElements()) {
             String numStr = (String)myStatus.nextElement();
             this.incrExpectedPassCount();
             ArrayList<String> fuzzy = this.tCC_statusShit.get(numStr);
             String updStr = fuzzy.get(0);
             String attrEValue = fuzzy.get(1);
             String attrName = fuzzy.get(2);
             try {
                String aValue = (String)dabba.xPathAttrGet(updStr, attrName).iterator().next();
                this.statisticResults(updStr, attrName, attrEValue, aValue);
             } catch (java.lang.Exception jle) {
                this.statisticResults(updStr, attrName, attrEValue, "NOT FOUND");
             }
          }
       }
    }
    //
    ////////////////////////////////////////////////////////

    private void runCollectionUpdates() {

        Enumeration myUpdates;
        vRepository scRepo = null;

        if (this.tCC_updateShit == null) {
           return;
        }

        try {
           scRepo = new vRepository();;
        } catch (java.lang.Exception jle) {
           System.out.println("Could not build repository object.");
           return;
        }

        myUpdates = this.tCC_updateShit.keys();
        while (myUpdates.hasMoreElements()) {
           String updStr = (String)myUpdates.nextElement();
           ArrayList<String> fuzzy = this.tCC_updateShit.get(updStr);
           String attrName = fuzzy.get(0);
           String attrType = fuzzy.get(1);
           try {
              scRepo.vRepoUpdate(updStr, attrName, attrType);
           } catch (java.lang.Exception jle) {
              System.out.println("Repository update failed on: " + updStr);
           }
        }
    }

    public void doCollectionUpdates() {
       this.runCollectionUpdates();
    }

    public void doCollectionUpdates(tInputData tData) {
 
       this.setUpdateHash(tData.getUpdateHash());
       this.runCollectionUpdates();
    }

    public void doCollectionUpdates(Hashtable<String,ArrayList<String>> myArray) {
 
       this.setUpdateHash(myArray);
       this.runCollectionUpdates();
    }

    public boolean errorStatisticsMatch(BigInteger eErrors) {

       boolean myMatch = false;

       this.loadStandardStatistics();

       ///////////////////////////////////////////////
       //
       //   This compares what is being dumped into the repository with
       //   what is being returned by the API.  They should match.
       //
       System.out.println("=======================================");
       if (this.nErrors.longValue() == eErrors.longValue()) {
          if (this.grNErrors == this.nErrors.intValue()) {
             this.incrActualPassCount();
             myMatch = true;
          } else {
             System.out.println("Collection file errors and API errors differ");
          }
       } else {
          System.out.println("Actual errors and expected errors differ");
       }
       //
       ///////////////////////////////////////////////

       System.out.println("Error check result, expected: " + eErrors);
       System.out.println("                    got:      " + nErrors);
       System.out.println("=======================================");

       return(myMatch);
    }

    //////////////////////////////////////////////////////////////
    //
    //   Process all of the queries in the query hash structure.
    //
    public Integer doAllQueries() {

       //
       //   Create the query objects.  grNDocs will be used as a basis
       //   for setting the max number of query results to return.
       //
       vQuery yy = this.buildQueryObj(tCC_CollectionName, this.grNDocs);

       //
       //   A blank query.  This should return the number of documents
       //   as specified by n-docs in the vse-indexer-status node.
       //   If the number of expected docs is greater than 100000,
       //   don't do this check.  It could seriously bog things down.
       //
       if (this.grNDocs < 100000) {
          if (this.goodQuery(yy, "", this.grNDocs, null)) {
             this.incrActualPassCount();
          }
       } else {
          this.incrActualPassCount();
       }

       //
       //   Process command line query/expected count pairs.
       //
       Enumeration queries = this.tCC_queryECount.keys();
       while (queries.hasMoreElements()) {
          yy.reset();
          String queryStr = (String)queries.nextElement();
          String cmpFile = null;
          ArrayList<String> doofus = this.tCC_queryECount.get(queryStr);
          Integer qcnt = new Integer(Integer.valueOf(doofus.get(0)));
          if (doofus.size() > 1) {
             cmpFile = doofus.get(1);
             if (cmpFile.equals("")) {
                cmpFile = null;
             }
          }

          if (this.goodQuery(yy, queryStr, qcnt, cmpFile)) {
             this.incrActualPassCount();
          }
       }

       System.out.println(this.tCC_APassCount + " OF " + this.tCC_EPassCount + " CASES PASSED");

       if (this.tCC_APassCount == this.tCC_EPassCount) {
          return(0);
       } else {
          return(-1);
       }
    }
    //
    //////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////
    //
    //   Methods to set or get the various values.
    //   Build the class.
    //

    /////////////////////
    //
    //   Get, set, and increment the actual and expected pass
    //   count variables.
    //
    public void incrExpectedPassCount() {
       this.tCC_EPassCount++;
    }

    public void incrActualPassCount() {
       this.tCC_APassCount++;
    }

    public void setExpectedPassCount(Integer qECnt) {

       this.tCC_EPassCount = qECnt;
       return;
    }

    public Integer getExpectedPassCount() {

       return(this.tCC_EPassCount);
    }

    public Integer getActualPassCount() {

       return(this.tCC_APassCount);
    }
    //
    /////////////////////
    /////////////////////
    //
    //   Make a number of the statistics values externally available.
    //   These are things like the indexer n-docs or the crawlers n-errors
    //   values.
    //
    public Integer getNDocs() {

       return(this.grNDocs);
    }

    public Integer getNErrors() {

       return(this.grNErrors);
    }
    //
    /////////////////////

    public void setQueryHash(Hashtable<String,ArrayList<String>> qEC) {

       this.tCC_queryECount = qEC;
       return;
    }

    public Hashtable getQueryHash() {

       return(this.tCC_queryECount);
    }

    public void setUpdateHash(Hashtable<String,ArrayList<String>> qUS) {

       this.tCC_updateShit = qUS;
       return;
    }

    public Hashtable getUpdateHash() {

       return(this.tCC_updateShit);
    }

    public void setStatusHash(Hashtable<String,ArrayList<String>> qSS) {

       this.tCC_statusShit = qSS;
       return;
    }

    public Hashtable getStatusHash() {

       return(this.tCC_statusShit);
    }

    public void setCollectionName(String cName) {

       this.tCC_CollectionName = cName;
       return;
    }

    public void setTestName(String tName) {

       this.tCC_TestName = tName;
       return;
    }

    public void commonInit(String tname, String cname,
                           Hashtable<String,ArrayList<String>> qEC,
                           Hashtable<String,ArrayList<String>> qUS,
                           Hashtable<String,ArrayList<String>> qSS,
                           Integer qECnt) {

       this.setCollectionName(cname);
       this.setTestName(tname);
       this.setQueryHash(qEC);
       this.setUpdateHash(qUS);
       this.setStatusHash(qSS);
       this.setExpectedPassCount(qECnt);

       this.tCC_grnk = new GRONK();

       if (this.tCC_TestName == null) {
          this.tCC_TestName = new String("No Test Name");
       }

       if (this.tCC_CollectionName == null) {
          this.tCC_CollectionName = new String("No Collection Name");
       }

    }

    public tCommonCases() {

       this.commonInit(null, null, null, null, null, 0);
    }

    public tCommonCases(String tname, String cname) {

       this.commonInit(tname, cname, null, null, null, 0);
    }

    public tCommonCases(String tname, String cname,
                        Hashtable<String,ArrayList<String>> qEC,
                        Hashtable<String,ArrayList<String>> qUS,
                        Hashtable<String,ArrayList<String>> qSS,
                        Integer qECnt) {

       this.commonInit(tname, cname, qEC, qUS, qSS, qECnt);
    }

    public tCommonCases(tInputData tData) {

       this.commonInit(tData.getTestName(),
                       tData.getCollectionName(),
                       tData.getQueryHash(),
                       tData.getUpdateHash(),
                       tData.getStatusValueHash(),
                       tData.getExpectedPassCount());
    }
}

