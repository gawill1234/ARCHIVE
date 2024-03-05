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

public class tapi_dict_funcs_1
{

    private static Logger log = Logger.getLogger(tapi_dict_funcs_1.class.getName());

    public static int runTest(API m, String qfile,
                               String myquery) throws java.lang.Exception
    {

        int passfail = 0;
        String resp;

        System.out.println("==================================");
        System.out.println("BUILD NON-EXISTENT DICTIONARY");

        try {
           m.dictBuild("garbage");
           log.severe("No exception generated");
           passfail = 1;
           log.severe("   SECTION FAILED");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "dictionary-does-not-exist")) {
              log.info("Correct error on build of non-existent dictionary");
           } else {
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
        }

        System.out.println("==================================");
        System.out.println("STATUS OF NON-EXISTENT DICTIONARY");
        try {
           resp = m.dictStatus("garbage");
           log.severe("No exception generated: " + resp);
           passfail = 1;
           log.severe("   SECTION FAILED");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "dictionary-does-not-exist")) {
              log.info("Correct error on status of non-existent dictionary");
           } else {
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
        }

        System.out.println("==================================");
        System.out.println("DELETE NON-EXISTENT DICTIONARY");
        try {
           m.dictDelete("garbage");
           log.severe("No exception generated");
           passfail = 1;
           log.severe("   SECTION FAILED");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "dictionary-does-not-exist")) {
              log.info("Correct error on status of non-existent dictionary");
           } else {
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
        }

        System.out.println("==================================");
        System.out.println("DICTIONARY CREATE, BUILD, STATUS, DELETE");
        m.dictCreate("garbage", "base");
        m.dictBuild("garbage");
        resp = m.dictStatus("garbage");
        while (!resp.equals("finished")) {
           System.out.println("Current build status: " + resp);
           resp = m.dictStatus("garbage");
        }
        System.out.println("Final build status: " + resp);

        System.out.println("==================================");
        System.out.println("CREATE EXISTING DICTIONARY");
        try {
           m.dictCreate("garbage", "base");
           log.severe("No exception generated");
           passfail = 1;
           log.severe("   SECTION FAILED");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "dictionary-already-exists")) {
              log.info("Correct error on create of existing dictionary");
           } else {
              System.out.println("ERROR: " + e);
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
        }

        m.dictDelete("garbage");

        System.out.println("==================================");
        System.out.println("CREATE DICTIONARY USING BAD BASE");
        try {
           m.dictCreate("fizzle", "hardyharhar");
           log.severe("No exception generated");
           passfail = 1;
           log.severe("   SECTION FAILED");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "dictionary-invalid-name")) {
              log.info("Correct error on create of existing dictionary");
           } else {
              System.out.println("ERROR: " + e);
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
        }

        System.out.println("==================================");
        System.out.println("CREATE DICTIONARY USING NULL NAME");
        try {
           m.dictCreate(null, "base");
           log.severe("No exception generated");
           passfail = 1;
           log.severe("   SECTION FAILED");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "xml-resolve-missing-var-error")) {
              log.info("Correct error on create of null dictionary");
           } else {
              System.out.println("ERROR: " + e);
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
        }

        System.out.println("==================================");
        System.out.println("CREATE/DELETE DICTIONARY USING NULL BASE");
        try {
           m.dictCreate("badboy", null);
           log.info("Create succeeded");
           m.dictBuild("badboy");
           resp = m.dictStatus("badboy");
           while (!resp.equals("finished")) {
              System.out.println("Current build status: " + resp);
              resp = m.dictStatus("badboy");
           }
           System.out.println("Final build status: " + resp);
           m.dictDelete("badboy");
           log.info("Delete succeeded");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "xml-resolve-missing-var-error")) {
              log.severe("Error on create of null dictionary base");
              passfail = 1;
              log.severe("   SECTION FAILED");
           } else {
              System.out.println("ERROR: " + e);
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
        }

        System.out.println("==================================");
        System.out.println("BUILD DELETED DICTIONARY");
        try {
           m.dictBuild("garbage");
           log.severe("No exception generated");
           passfail = 1;
           log.severe("   SECTION FAILED");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "dictionary-does-not-exist")) {
              log.info("Correct error on build of non-existent dictionary");
           } else {
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
        }

        System.out.println("==================================");
        System.out.println("STATUS OF DELETED DICTIONARY");
        try {
           resp = m.dictStatus("garbage");
           log.severe("No exception generated: " + resp);
           passfail = 1;
           log.severe("   SECTION FAILED");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "dictionary-does-not-exist")) {
              log.info("Correct error on status of non-existent dictionary");
           } else {
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
        }

        System.out.println("==================================");
        System.out.println("DELETE DELETED DICTIONARY");
        try {
           m.dictDelete("garbage");
           log.severe("No exception generated");
           passfail = 1;
           log.severe("   SECTION FAILED");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "dictionary-does-not-exist")) {
              log.info("Correct error on status of non-existent dictionary");
           } else {
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
        }

        System.out.println("==================================");
        System.out.println("DELETE DICTIONARY USING NULL NAME");
        try {
           m.dictDelete(null);
           log.severe("No exception generated");
           passfail = 1;
           log.severe("   SECTION FAILED");
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "xml-resolve-missing-var-error")) {
              log.info("Correct error on create of null dictionary");
           } else {
              System.out.println("ERROR: " + e);
              passfail = 1;
              log.severe("   SECTION FAILED");
           }
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
        String collectionName = "None";

        for (int i = 0; i < args.length; i++) {
            //log.info("processing [" + args[i] + "]");
            if (args[i].equals("--url")) {
                i++;
                url = args[i]; 
            } else if (args[i].equals("--file-name")) {
                i++;
                qfile = args[i];
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
           System.out.println("tapi_dict_funcs_1(java):  Test Passed");
           System.exit(0);
        }

        System.out.println("tapi_dict_funcs_1(java):  Test Failed");
        System.exit(1);
    }
}
