import velocity.*;
import velocity.objects.*;
import velocity.soap.*;
import velocity.types.*;

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

public class api_sc_crind_re_1
{

    private static Logger log = Logger.getLogger(api_sc_crind_re_1.class.getName());

    public static int runTest(API m, String qfile,
                               String myquery) throws java.lang.Exception
    {

        String cstatus;
        String istatus;
        int statcount = 0;
        int passfail = 0;

        try {
            Element config;

            //
            //   Check for collection existence.  If it does exist,
            //   delete it so it can be recreated as part of the test.
            //
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

            //
            //   Create a new collection and begin the crawl.
            //
            m.createCollection();
            config = m.loadConfigurationFromFile();
            m.setConfiguration(config);

            System.out.println("==================================");
            System.out.println("RESTART CRAWL/INDEX ON NEW COLLECTION");
            try {
               m.restartCrawl();
               cstatus = m.waitForCrawlStatus("running", 5, 2);
            } catch (SOAPFaultException e) {
               if (checkSOAPFaultExceptionType(e, "search-collection-crawler-restart")) {
                  log.info("api_sc_crind_re_1:  restart failed correctly");
               } else {
                  log.info("api_sc_crind_re_1:  restart status unknown");
                  passfail = 1;
               }
            }
            try {
               m.restartIndexer();
               istatus = m.waitForIndexerStatus("idle,running", 5, 2);
            } catch (SOAPFaultException e) {
               if (checkSOAPFaultExceptionType(e, "search-collection-indexer-restart")) {
                  log.info("api_sc_crind_re_1:  restart failed correctly");
               } else {
                  log.info("api_sc_crind_re_1:  restart status unknown");
                  passfail = 1;
               }
            }

            System.out.println("==================================");
            System.out.println("START CRAWL/INDEX");
            m.startCrawl("new");

            cstatus = m.waitForCrawlStatus("running", 5, 2);
            istatus = m.waitForIndexerStatus("idle,running", 5, 2);

            if (! cstatus.equals("running")) {
               log.severe("Could not start crawler.");
               System.exit(1);
            }

            System.out.println("==================================");
            System.out.println("RESTART CRAWL/INDEX ON RUNNING COLLECTION");
            m.restartCrawl();
            cstatus = m.waitForCrawlStatus("running", 5, 2);
            m.restartIndexer();
            istatus = m.waitForIndexerStatus("idle,running", 5, 2);


            m.waitForIdle();
            m.setNum(200);
            m.runQueries(myquery, qfile);

            //
            //   Delete on completion
            //
            System.out.println("==================================");
            System.out.println("STOP EVERYTHING AND DELETE");
            m.stopCrawl("true");
            m.stopIndexer("true");

            cstatus = m.waitForCrawlStatus("stopped", 5, 2);
            istatus = m.waitForIndexerStatus("stopped", 5, 2);

            if (!(istatus.equals("stopped") && cstatus.equals("stopped"))) {
               passfail = 1;
               log.severe("Could not stop crawler or indexer.");
            }

            m.deleteCollection();

            System.out.println("==================================");
            System.out.println("RESTART CRAWL/INDEX ON DELETED COLLECTION");

            try {
               m.restartCrawl();
            } catch (SOAPFaultException e) {
               if (checkSOAPFaultExceptionType(e, "search-collection-invalid-name")) {
                  log.info("api_sc_crind_re_1:  restart correctly failed");
               } else {
                  log.info("api_sc_crind_re_1:  restart status unknown");
                  passfail = 1;
               }
            }

            try {
               m.restartIndexer();
            } catch (SOAPFaultException e) {
               if (checkSOAPFaultExceptionType(e, "search-collection-invalid-name")) {
                  log.info("api_sc_crind_re_1:  restart correctly failed");
               } else {
                  log.info("api_sc_crind_re_1:  restart status unknown");
                  passfail = 1;
               }
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
        int queryfromdead = 0;
        int passfail = 0;

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
            } else if (args[i].equals("--querydead")) {
                queryfromdead = 1;
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
            passfail = runTest(m, qfile, myquery);

            //if (m.testHadError()) {
            //    System.exit(1);
            //} else {
            //    System.exit(0);
            //}
            
        } catch (javax.xml.ws.soap.SOAPFaultException sfe) {
            throw sfe;
        }

        if (passfail == 0) {
           System.out.println("api_sc_crind_re_1(java):  Test Passed");
           System.exit(0);
        }

        System.out.println("api_sc_crind_re_1(java):  Test Failed");
        System.exit(1);
    }
}
