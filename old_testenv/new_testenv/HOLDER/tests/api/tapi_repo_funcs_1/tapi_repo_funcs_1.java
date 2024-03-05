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

public class tapi_repo_funcs_1
{

    private static Logger log = Logger.getLogger(tapi_repo_funcs_1.class.getName());

    public static int runTest(API m, String qfile,
                               String myquery) throws java.lang.Exception
    {

        int passfail = 0;
        String resp;
        int listcount;

        System.out.println("==================================");
        System.out.println("COUNT NODES USING REPO LIST");
        listcount = m.apiRepositoryListCount("function");
        if (listcount > 700) {
           log.info("Repo functions apparently correct: " + listcount);
        } else {
           passfail = 1;
           log.severe("Repo functions not complete: " + listcount);
        }
        listcount = m.apiRepositoryListCount("vse-collection");
        if (listcount > 15) {
           log.info("Repo collections apparently correct: " + listcount);
        } else {
           passfail = 1;
           log.severe("Repo collections not complete: " + listcount);
        }

        System.out.println("==================================");
        System.out.println("CREATE A COLLECTION, REPO UPDATE");
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
            m.createCollection();
            config = m.loadConfigurationFromFile();
            m.setConfiguration(config);
        } catch (java.lang.Exception e) {
            m.testHadError = true;
            passfail = 1;
            throw e;
        }

        System.out.println("==================================");
        System.out.println("GET VARIOUS REPOSITORY NODE TYPES");
        resp = m.apiRepositoryGet("base", "dictionary", "name");
        if (resp.equals("base")) {
           System.out.println("tapi_repo_funcs_1: " + resp + " is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: " + resp + " is not correct");
           passfail = 1;
        }

        resp = m.apiRepositoryGet("repotest", "vse-collection", "name");
        if (resp.equals("repotest")) {
           System.out.println("tapi_repo_funcs_1: " + resp + " is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: " + resp + " is not correct");
           passfail = 1;
        }
        resp = m.apiRepositoryGet("repotest", "source", "name");
        if (resp.equals("repotest")) {
           System.out.println("tapi_repo_funcs_1: " + resp + " is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: " + resp + " is not correct");
           passfail = 1;
        }


        resp = m.apiRepositoryGet("core-help", "function", "name");
        if (resp.equals("core-help")) {
           System.out.println("tapi_repo_funcs_1: " + resp + " is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: " + resp + " is not correct");
           passfail = 1;
        }

        resp = m.apiRepositoryGet("api-soap", "application", "name");
        if (resp.equals("api-soap")) {
           System.out.println("tapi_repo_funcs_1: " + resp + " is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: " + resp + " is not correct");
           passfail = 1;
        }

        resp = m.apiRepositoryGet("CNN", "source", "name");
        if (resp.equals("CNN")) {
           System.out.println("tapi_repo_funcs_1: " + resp + " is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: " + resp + " is not correct");
           passfail = 1;
        }

        resp = m.apiRepositoryGet("source-summary", "report", "name");
        if (resp.equals("source-summary")) {
           System.out.println("tapi_repo_funcs_1: " + resp + " is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: " + resp + " is not correct");
           passfail = 1;
        }

        resp = m.apiRepositoryGet("proxy", "parser", "name");
        if (resp.equals("proxy")) {
           System.out.println("tapi_repo_funcs_1: " + resp + " is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: " + resp + " is not correct");
           passfail = 1;
        }

        resp = m.apiRepositoryGet("url-state", "macro", "name");
        if (resp.equals("url-state")) {
           System.out.println("tapi_repo_funcs_1: " + resp + " is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: " + resp + " is not correct");
           passfail = 1;
        }

        resp = m.apiRepositoryGet("custom", "kb", "name");
        if (resp.equals("custom")) {
           System.out.println("tapi_repo_funcs_1: " + resp + " is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: " + resp + " is not correct");
           passfail = 1;
        }

        resp = m.apiRepositoryGet("simple-clusty-gov", "fizzybizzy", "name");
        if (resp == null) {
           System.out.println("tapi_repo_funcs_1: null response is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: incorrect response (not null)");
           passfail = 1;
        }

        resp = m.apiRepositoryGet("hardyharhar", "application", "name");
        if (resp == null) {
           System.out.println("tapi_repo_funcs_1: null response is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: incorrect response (not null)");
           passfail = 1;
        }

        System.out.println("==================================");
        System.out.println("DELETE COLLECTION USING REPO DELETE");
        m.apiRepositoryDelete("repotest", "vse-collection");

        resp = m.apiRepositoryGet("repotest", "vse-collection", "name");
        if (resp == null) {
           System.out.println("tapi_repo_funcs_1: null response is correct");
        } else {
           System.out.println("tapi_repo_funcs_1: incorrect response (not null)");
           passfail = 1;
        }

        System.out.println("==================================");
        System.out.println("PUT COLLECTION BACK USING ADD, CRAWL AND QUERY");

        try {
            Element config;

            //
            //   Check for collection existence.  If it does exist,
            //   delete it so it can be recreated as part of the test.
            //
            config = m.loadConfigurationFromFile();
            m.addConfiguration(config);
            m.startCrawl("new");
            m.waitForIdle();
            m.setNum(200);
            m.runQueries(myquery, "urls.txt");
            m.stopCrawl("true");
            m.stopIndexer("true");
            m.deleteCollection();
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
           System.out.println("tapi_repo_funcs_1(java):  Test Passed");
           System.exit(0);
        }

        System.out.println("tapi_repo_funcs_1(java):  Test Failed");
        System.exit(1);
    }
}
