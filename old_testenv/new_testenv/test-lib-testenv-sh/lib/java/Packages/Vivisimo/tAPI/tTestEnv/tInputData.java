package Vivisimo.tAPI;

import velocity.*;
import velocity.objects.*;
import velocity.soap.*;
import velocity.types.*;

import java.util.Set;
import java.util.*;
import java.io.IOException;
import java.io.*;
import java.math.BigInteger;


public class tInputData
{

    Hashtable<String,ArrayList<String>> tID_updateShit = null;
    Hashtable<String,ArrayList<String>> tID_statusShit = null;
    Hashtable<String,ArrayList<String>> tID_queryECount = null;

    String tID_CollectionName = null;
    String tID_TestName = null;

    Integer tID_EPassCount = 0;

    testXML tID_stuffit = null;

    private void testDescriptionDump() {
       
       if ( (new File("TEST_DESCRIPTION")).exists() ) {
          System.out.println("================================================");
          System.out.println("===   TEST DESCRIPTION FOR TEST:  " + this.tID_TestName);
          try {
             /*  Sets up a file reader to read the file passed on the command
                 line one character at a time */
             FileReader input = new FileReader("TEST_DESCRIPTION");
                 
             /* Filter FileReader through a Buffered read to read a line at a
                time */
             BufferedReader bufRead = new BufferedReader(input);
                 
             String line;    // String that holds current file line
                 
             // Read first line
             line = bufRead.readLine();

             // Read through file one line at time. Print line # and line
             while (line != null){
                 System.out.println(line);
                 line = bufRead.readLine();
             }
                 
             bufRead.close();
          } catch (IOException iox) {
             System.out.println(iox);
          }
          System.out.println("===   END TEST DESCRIPTION");
          System.out.println("================================================");
       }

       return;
    }

    private Integer getQueriesFromFile(String queryFile) {
       
       if ( this.tID_stuffit != null ) {
          System.out.println("================================================");
          System.out.println("===   TEST QUERY LIST FOR TEST:  " + this.tID_TestName);
          System.out.println("===   TEST QUERY FILE         :  " + queryFile);
          try {
             this.tID_stuffit.getQueryData(this.tID_queryECount);
             Enumeration queries = this.tID_queryECount.keys();
             while (queries.hasMoreElements()) {
                String queryStr = (String)queries.nextElement();
                ArrayList<String> squib = this.tID_queryECount.get(queryStr);
                if (squib.size() < 2) {
                   System.out.println(queryStr + " -- " + squib.get(0));
                } else {
                   System.out.println(queryStr + " -- " + squib.get(0) + ", " + squib.get(1));
                }
             }
             this.tID_EPassCount = this.tID_queryECount.size();
          } catch (java.lang.Exception iox) {
             System.out.println(iox);
             System.out.println("ERROR: TEST EXIT =========================");
             System.out.println("Test query file exists but had problems.");
             System.out.println("It either could not be read or was improperly");
             System.out.println("formed.  Therefore, the test will be failed.");
             System.out.println("ERROR: TEST EXIT ==========================");
             System.exit(-1);
          }
          System.out.println("===   END TEST QUERY LIST");
          System.out.println("================================================");
       }

       return(this.tID_EPassCount);
    }

    public Integer getExpectedPassCount() {
       return(this.tID_EPassCount);
    }

    public String getTestName() {
       return(this.tID_TestName);
    }

    public String getCollectionName() {
       return(this.tID_CollectionName);
    }

    public void setCollectionName(String collectionName) {
       this.tID_CollectionName = collectionName;
    }

    public void setTestName(String testName) {
       this.tID_TestName = testName;
    }

    public Hashtable getQueryHash() {
       return(this.tID_queryECount);
    }

    public Hashtable getUpdateHash() {
       return(this.tID_updateShit);
    }

    public Hashtable getStatusValueHash() {
       return(this.tID_statusShit);
    }

    private void getCollectionUpdates() {

       if ( this.tID_stuffit != null ) {
          try {
             this.tID_updateShit = this.tID_stuffit.getUpdateData();
          } catch (java.lang.Exception jle) {
             System.out.println("No update data.");
             return;
          }
       }

    }

    private void getStatusValues() {

       if ( this.tID_stuffit != null ) {
          System.out.println("================================================");
          System.out.println("===   TEST STATUS LIST FOR TEST:  " + this.tID_TestName);
          try {
             this.tID_statusShit = this.tID_stuffit.getStatusData();
             Enumeration stati = this.tID_statusShit.keys();
             while (stati.hasMoreElements()) {
                String statStr = (String)stati.nextElement();
                System.out.println(statStr + " -- " + this.tID_statusShit.get(statStr));
             }
          } catch (java.lang.Exception iox) {
             System.out.println(iox);
             System.out.println("ERROR: TEST EXIT =========================");
             System.out.println("Test query file exists but had problems.");
             System.out.println("It either could not be read or was improperly");
             System.out.println("formed.  Therefore, the test will be failed.");
             System.out.println("ERROR: TEST EXIT ==========================");
             System.exit(-1);
          }
          System.out.println("===   END TEST STATUS LIST");
          System.out.println("================================================");
        }


    }

    public void commonInit(String queryFile) {

       if ( (new File(queryFile)).exists() ) {
          this.tID_stuffit = new testXML(queryFile);
          this.tID_CollectionName = this.tID_stuffit.getCollectionName();
          this.tID_TestName = this.tID_stuffit.getTestName();
       }

       if (this.tID_TestName == null) {
          this.tID_TestName = new String("No Test Name");
       }

       if (this.tID_CollectionName == null) {
          this.tID_CollectionName = new String("No Collection Name");
       }

       this.testDescriptionDump();
       this.getCollectionUpdates();
       this.getStatusValues();
       if ( (new File(queryFile)).exists() ) {
          this.getQueriesFromFile(queryFile);
       } else {
          this.tID_EPassCount = this.tID_queryECount.size();
       }
    }

    public tInputData() {

       String queryFile = "TEST_QUERIES";
       this.tID_queryECount = new Hashtable<String,ArrayList<String>>();
       this.commonInit(queryFile);
    }

    public tInputData(Hashtable<String,ArrayList<String>> queryECount) {

       String queryFile = "TEST_QUERIES";
       this.tID_queryECount = queryECount;
       this.commonInit(queryFile);
    }

    public tInputData(String queryFile) {

       this.tID_queryECount = new Hashtable<String,ArrayList<String>>();
       this.commonInit(queryFile);
    }

    public tInputData(String queryFile, Hashtable<String,ArrayList<String>> queryECount) {

       this.tID_queryECount = queryECount;
       this.commonInit(queryFile);
    }
}

