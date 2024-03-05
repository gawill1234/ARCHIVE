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

public class tapi_sc_conf_fs_1
{

    private static Logger log = Logger.getLogger(tapi_sc_conf_fs_1.class.getName());

    public static int runTest(API m, String qfile,
                               String myquery) throws java.lang.Exception
    {

        String cstatus;
        String istatus;
        String LiveDir;
        String StagDir;
        String CcheDir;
        String VivDir;
        String mainsep = "/";
        String winsep = "\\";
        String sep = mainsep;
        int statcount = 0;
        int passfail = 0;

        String OSgeneric = System.getenv("VIVTARGETOS");
        VivDir = m.VivisimoDir();

        if (OSgeneric.equals("windows")) {
           sep = winsep;
        }

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

            System.out.println("==================================");
            System.out.println("==================================");
            System.out.println("==================================");
            System.out.println("DIRECTORIES TO BE CONFIGURED");

            StagDir = VivDir + sep  + "tmp" + sep + "myStagCrawlDir";
            LiveDir = VivDir + sep  + "tmp" + sep + "myLiveCrawlDir";
            CcheDir = VivDir + sep  + "tmp" + sep + "CacheDirNameOfDeath";

            System.out.println("  LIVE DIR   : " + LiveDir);
            System.out.println("  STAGING DIR: " + StagDir);
            System.out.println("  CACHE DIR  : " + CcheDir);
            System.out.println("==================================");
            System.out.println("==================================");
            System.out.println("==================================");

            m.buildCollectionMeta();
            m.metaSetLiveCrawlDir(LiveDir);
            m.metaSetStagingCrawlDir(StagDir);
            m.metaSetCacheDir(CcheDir);

            m.createCollection();

            config = m.loadConfigurationFromFile();
            m.setConfiguration(config);
            System.out.println("==================================");
            System.out.println("START CRAWL/INDEX, (1)live/new");
            m.startCrawl("new");
            m.waitForIdle();
            if (m.RemoteFileExists(LiveDir) != 1) {
               passfail = 1;
               System.out.println("(1)Configured live directory missing");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("(1)Configured live directory correct");
            }
            if (m.RemoteFileExists(CcheDir) != 1) {
               passfail = 1;
               System.out.println("(1)Configured cache directory missing");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("(1)Configured cache directory correct");
            }

            m.setNum(200);
            m.runQueries(myquery, "querywork/urls-1.txt");

            System.out.println("==================================");
            System.out.println("REFRESH CRAWL, (2)live/refresh-inplace");
            m.setSubcollection("live");
            try {
               m.startCrawl("refresh-inplace");
            } catch (SOAPFaultException sfe) {
               if (checkSOAPFaultExceptionType(sfe, "search-collection-crawler-start")) {
                   log.severe("tapi_sc_conf_fs_1:  Could not start crawl");
                   passfail = 1;
                   log.severe("     SECTION FAILED");
               } else {
                   throw sfe;
               }
            }

            if (m.RemoteFileExists(LiveDir) != 1) {
               passfail = 1;
               System.out.println("(2)Configured live directory missing");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("(2)Configured live directory correct");
            }
            if (m.RemoteFileExists(CcheDir) != 1) {
               passfail = 1;
               System.out.println("(2)Configured cache directory missing");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("(2)Configured cache directory correct");
            }

            m.waitForIdle();
            m.setNum(200);
            m.runQueries(myquery, "querywork/urls-2.txt");

            System.out.println("==================================");
            System.out.println("REFRESH CRAWL, (3)staging/refresh-new");
            m.setSubcollection("staging");
            try {
               m.startCrawl("refresh-new");
            } catch (SOAPFaultException sfe) {
               if (checkSOAPFaultExceptionType(sfe, "search-collection-crawler-start")) {
                   log.severe("tapi_sc_conf_fs_1:  Could not start crawl");
                   passfail = 1;
                   log.severe("     SECTION FAILED");
               } else {
                   throw sfe;
               }
            }

            if (m.RemoteFileExists(StagDir) != 1) {
               passfail = 1;
               System.out.println("(3)Configured staging directory missing");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("(3)Configured staging directory correct");
            }
            if (m.RemoteFileExists(CcheDir) != 1) {
               passfail = 1;
               System.out.println("(3)Configured cache directory missing");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("(3)Configured cache directory correct");
            }

            m.waitForIdle();
            m.setNum(200);
            m.runQueries(myquery, "querywork/urls-3.txt");

            System.out.println("==================================");
            System.out.println("REFRESH CRAWL, (4)live/refresh-inplace");
            m.setSubcollection("live");
            try {
               m.startCrawl("refresh-inplace");
            } catch (SOAPFaultException sfe) {
               if (checkSOAPFaultExceptionType(sfe, "search-collection-crawler-start")) {
                   log.severe("tapi_sc_conf_fs_1:  Could not start crawl");
                   passfail = 1;
                   log.severe("     SECTION FAILED");
               } else {
                   throw sfe;
               }
            }

            if (m.RemoteFileExists(StagDir) != 1) {
               passfail = 1;
               System.out.println("(4)Configured live directory missing");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("(4)Configured live directory correct");
            }

            //if (m.RemoteFileExists(CcheDir) != 1) {
            //   passfail = 1;
            //   System.out.println("(4)Configured cache directory missing");
            //   log.severe("     SECTION FAILED");
            //} else {
            //   System.out.println("(4)Configured cache directory correct");
            //}

            m.waitForIdle();

            m.setNum(200);
            m.runQueries(myquery, "querywork/urls-4.txt");

            System.out.println("==================================");
            System.out.println("REFRESH CRAWL, (5)live/refresh-inplace");
            m.setSubcollection("staging");
            try {
               m.startCrawl("refresh-inplace");
            } catch (SOAPFaultException sfe) {
               if (checkSOAPFaultExceptionType(sfe, "search-collection-crawler-start")) {
                   log.severe("tapi_sc_conf_fs_1:  Could not start crawl");
                   passfail = 1;
                   log.severe("     SECTION FAILED");
               } else {
                   throw sfe;
               }
            }


            if (m.RemoteFileExists(StagDir) != 1) {
               passfail = 1;
               System.out.println("(5)Configured live directory missing");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("(5)Configured live directory correct");
            }
            if (m.RemoteFileExists(CcheDir) != 1) {
               passfail = 1;
               System.out.println("(5)Configured cache directory missing");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("(5)Configured cache directory correct");
            }

            m.waitForIdle();
            m.setNum(200);
            m.runQueries(myquery, "querywork/urls-5.txt");
            //
            //   Delete on completion
            //
            System.out.println("==================================");
            System.out.println("STOP EVERYTHING AND DELETE");
            m.setSubcollection("live");
            m.stopCrawl("true");
            m.stopIndexer("true");

            cstatus = m.waitForCrawlStatus("stopped", 5, 2);
            istatus = m.waitForIndexerStatus("stopped", 5, 2);

            if (!(istatus.equals("stopped") && cstatus.equals("stopped"))) {
               passfail = 1;
               log.severe("Could not stop crawler or indexer.");
               log.severe("     SECTION FAILED");
            }

            m.deleteCollection();

            if (m.RemoteFileExists(LiveDir) != 0) {
               passfail = 1;
               System.out.println("Configured live directory not removed");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("Configured live directory removed");
            }
            if (m.RemoteFileExists(CcheDir) != 0) {
               passfail = 1;
               System.out.println("Configured cache directory not removed");
               log.severe("     SECTION FAILED");
            } else {
               System.out.println("Configured cache directory removed");
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
           System.out.println("tapi_sc_conf_fs_1(java):  Test Passed");
           System.exit(0);
        }

        System.out.println("tapi_sc_conf_fs_1(java):  Test Failed");
        System.exit(1);
    }
}
