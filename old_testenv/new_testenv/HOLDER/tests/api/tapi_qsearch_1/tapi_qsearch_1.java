import velocity.*;
import velocity.objects.*;
import velocity.soap.*;
import velocity.types.*;

import Vivisimo.tAPI.*;

import java.io.File;
import java.io.FileWriter;

import org.w3c.dom.Element;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import javax.xml.ws.soap.SOAPFaultException;
import static soapfault.SOAPFaultExceptionUtils.*;

import java.net.URL;
import javax.xml.namespace.QName;

import java.util.logging.*;

public class tapi_qsearch_1
{

    private static Logger log = Logger.getLogger(tapi_qsearch_1.class.getName());

    public static int runTest(API m, String qfile,
                              String myquery, 
                              boolean forceDelete) throws java.lang.Exception
    {

        String cstatus;
        String istatus;
        int statcount = 0;
        int passfail = 0;
        int fileLines = 0;

        try {
            Element config;

            //
            //   Check for collection existence.  If it does exist,
            //   delete it so it can be recreated as part of the test.
            //
            if (forceDelete) {
               if (m.collectionExists()) {
                  log.info("Collection exists, deleting.");
                  m.killCollection("true");
                  m.deleteCollection();
                  if (m.collectionExists()) {
                     log.severe("Collection exists, could not be deleted.");
                     System.exit(1);
                  }
               } else {
                  log.info("Collection does not exist, continuing.");
               }
            }

            if (!m.collectionExists()) {
               //
               //   Create a new collection and begin the crawl.
               //
               m.createCollection();

               config = m.loadConfigurationFromFile();
               m.setConfiguration(config);
               System.out.println("==================================");
               System.out.println("START CRAWL/INDEX, (1)live/new");
               m.startCrawl("new");
               m.waitForIdle();
            } else {
               log.info("Collection already exists, continuing.");
               m.startIndexer();
               m.startCrawl("resume");
            }

            System.out.println("==================================");
            System.out.println("Query:  Defaults");
            m.setNum(200);
            m.runQueries(myquery, "querywork/urls-1.txt");
            fileLines = m.countLinesInFile("querywork/urls-1.txt");
            System.out.println("Expecting 46, Got " + fileLines);
            if (fileLines != 46) {
               passfail = 1;
               log.severe("     SECTION FAILED");
            }

            System.out.println("==================================");
            System.out.println("Query:  Start is 5");
            m.setStart(5);
            m.runQueries(myquery, "querywork/urls-2.txt");
            fileLines = m.countLinesInFile("querywork/urls-2.txt");
            System.out.println("Expecting 41, Got " + fileLines);
            if (fileLines != 41) {
               passfail = 1;
               log.severe("     SECTION FAILED");
            }

            System.out.println("==================================");
            System.out.println("Query:  Start is 5, Num is 46");
            m.setStart(5);
            m.setNum(46);
            m.runQueries(myquery, "querywork/urls-3.txt");
            fileLines = m.countLinesInFile("querywork/urls-3.txt");
            System.out.println("Expecting 41, Got " + fileLines);
            if (fileLines != 41) {
               passfail = 1;
               log.severe("     SECTION FAILED");
            }

            //
            //   Delete on completion
            //
            System.out.println("==================================");
            System.out.println("STOP EVERYTHING");
            m.stopCrawl("true");
            m.stopIndexer("true");

            cstatus = m.waitForCrawlStatus("stopped", 5, 2);
            istatus = m.waitForIndexerStatus("stopped", 5, 2);

            if (!(istatus.equals("stopped") && cstatus.equals("stopped"))) {
               passfail = 1;
               log.severe("Could not stop crawler or indexer.");
               log.severe("     SECTION FAILED");
            }

            if (forceDelete) {
               System.out.println("==================================");
               System.out.println("FORCEDELETE ENABLED, DELETE");
               m.deleteCollection();
            }

            if (m.testHadError()) {
                System.exit(1);
            }

        } catch (java.lang.Exception e) {
            m.testHadError = true;
            passfail = 1;
            throw e;
        }

        return passfail;
    }

    public static void main(String[] args) throws java.lang.Exception
    {
        String url = null;
        String qfile = null;
        String myquery = null;
        String tvals = null;
   
        int deleteit = 0;
        int finishit = 0;
        int passfail = 0;

        boolean forceDelete = false;

        String user = System.getenv("VIVUSER");
        String password = System.getenv("VIVPW");
        String vivhost = System.getenv("VIVHOST");
        String OSgeneric = System.getenv("VIVTARGETOS");
        String collectionName = System.getenv("VIVCOLLECTION");

        for (int i = 0; i < args.length; i++) {
            //log.info("processing [" + args[i] + "]");
            if (args[i].equals("--url")) {
                i++;
                url = args[i]; 
            } else if (args[i].equals("--collection-name")) {
                i++;
                collectionName = args[i];
            } else if (args[i].equals("--file-name")) {
                i++;
                qfile = args[i];
            } else if (args[i].equals("--query")) {
                i++;
                myquery = args[i];
            } else if (args[i].equals("--finish")) {
                finishit = 1;
            } else if (args[i].equals("--forcedelete")) {
                forceDelete = true;
            } else if (args[i].equals("--user")) {
                i++;
                user = args[i];
            } else if (args[i].equals("--password")) {
                i++;
                password = args[i];
            }
        }
        
        if (url == null) {
            log.severe("No Velocity URL specified (use --url)");
            if (OSgeneric.equals("windows")) {
               url = "http://" + vivhost + "/vivisimo/cgi-bin/velocity.exe";
            } else {
               url = "http://" + vivhost + "/vivisimo/cgi-bin/velocity";
            }
            if (url == null) {
               System.exit(1);
            }
        }

        if (user == null) {
            log.severe("No Velocity user specified (use --user)");
            System.exit(1);
        }

        if (password == null) {
            log.severe("No Velocity password specified (use --password)");
            System.exit(1);
        }

        if (collectionName == null) {
            log.severe("No collection specified (use --collection-name)");
            System.exit(1);
        }

        try {
            API m = new API(url, collectionName);
            m.setUser(user);
            m.setPassword(password);

            //m.testDriver();
            passfail = runTest(m, qfile, myquery, forceDelete);

            //if (m.testHadError()) {
            //    System.exit(1);
            //} else {
            //    System.exit(0);
            //}
            
        } catch (javax.xml.ws.soap.SOAPFaultException sfe) {
            throw sfe;
        }

        if (passfail == 0) {
           System.out.println("tapi_qsearch_1(java):  Test Passed");
           System.exit(0);
        }

        System.out.println("tapi_qsearch_1(java):  Test Failed");
        System.exit(1);
    }
}
