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

public class api_sc_crdel_1
{

    private static Logger log = Logger.getLogger(api_sc_crdel_1.class.getName());
    public static int onlyDelete(API m) throws java.lang.Exception
    {
        int tfail = 0;
        try {
            Element config;

            //
            //   Check for collection existence.  If it does exist,
            //   delete it so it can be recreated as part of the test.
            //
            m.killCollection("true");
            m.deleteCollection();
            if (m.collectionExists()) {
               log.severe("Collection exists, could not be deleted.");
               tfail = 1;
            }

        } catch (javax.xml.ws.soap.SOAPFaultException sfe) {
            if (checkSOAPFaultExceptionType(sfe, "search-collection-invalid-name")) {
                log.warning("api_sc_crdel_1:  Collection name invalid, correct");

            } else {
               tfail = 1;
            }
        }

        return tfail;
    }

    public static int createDelete(API m, int shouldexist) throws java.lang.Exception
    {
        int tfail = 0;
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

            if (m.collectionExists()) {
               if (shouldexist == 1) {
                  log.info("Collection exists, deleting.");
               } else {
                  log.info("Collection exists and should not, deleting.");
                  tfail = 1;
               }
               //m.killCollection("true");
               m.deleteCollection();
               if (m.collectionExists()) {
                  log.severe("Collection still exists, could not be deleted.");
                  tfail = 1;
               }
            } else {
               if (shouldexist == 1) {
                  log.info("Collection should exist, does not.");
                  tfail = 1;
               } else {
                  log.info("Collection should not exist, does not.");
               }
            }

        } catch (java.lang.Exception e) {
            m.testHadError = true;
            throw e;
        }

        return tfail;
    }

    public static void main(String[] args) throws java.lang.Exception
    {
        String url = null;
        String qfile = null;
   
        int passorfail = 0;
        int dnexist = 0;
        int ddexist = 0;
        int valcoll = 0;
        int invalcoll = 0;
        int shouldexist = 1;
        String should[] = {"abcdefg",
                           "abc999",
                           "999012"};
        String shouldnot[] = {"abc defg",
                              "#$%^%$#",
                              "    "};

        String user = System.getenv("VIVUSER");
        String password = System.getenv("VIVPW");
        String vivhost = System.getenv("VIVHOST");
        String OSgeneric = System.getenv("VIVTARGETOS");

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

       System.out.println("================================");
       System.out.println("DELETE A NON-EXISTENT COLLECTION");
       for (String myCollectionName : should) {
           try {
               API m = new API(url, myCollectionName);
               m.setUser(user);
               m.setPassword(password);

               dnexist = dnexist + onlyDelete(m);
            
           } catch (javax.xml.ws.soap.SOAPFaultException sfe) {
               throw sfe;
           }
       }

       System.out.println("================================");
       System.out.println("CREATE/DELETE VALID COLLECTIONS");
       for (String myCollectionName : should) {
           try {
               API m = new API(url, myCollectionName);
               m.setUser(user);
               m.setPassword(password);

               valcoll = valcoll + createDelete(m, shouldexist);
            
           } catch (javax.xml.ws.soap.SOAPFaultException sfe) {
               throw sfe;
           }
       }

       System.out.println("================================");
       System.out.println("CREATE/DELETE INVALID COLLECTIONS");
       for (String myCollectionName : shouldnot) {
           shouldexist = 0;
           try {
               API m = new API(url, myCollectionName);
               m.setUser(user);
               m.setPassword(password);

               invalcoll = invalcoll + createDelete(m, shouldexist);

           } catch (javax.xml.ws.soap.SOAPFaultException sfe) {
               throw sfe;
           }
       }

       System.out.println("================================");
       System.out.println("DELETE A DELETED COLLECTION");
       for (String myCollectionName : should) {
           try {
               API m = new API(url, myCollectionName);
               m.setUser(user);
               m.setPassword(password);

               ddexist = ddexist + onlyDelete(m);
            
           } catch (javax.xml.ws.soap.SOAPFaultException sfe) {
               throw sfe;
           }
       }

       passorfail = dnexist + ddexist + valcoll + invalcoll;
       System.out.println("api_sc_crdel_1:  delete non-existent collection");
       if (dnexist == 0) {
          System.out.println("api_sc_crdel_1:     Section passed");
       } else {
          System.out.println("api_sc_crdel_1:     Section failed");
       }
       System.out.println("api_sc_crdel_1:  delete deleted collection");
       if (ddexist == 0) {
          System.out.println("api_sc_crdel_1:     Section passed");
       } else {
          System.out.println("api_sc_crdel_1:     Section failed");
       }
       System.out.println("api_sc_crdel_1:  create/delete valid collection");
       if (valcoll == 0) {
          System.out.println("api_sc_crdel_1:     Section passed");
       } else {
          System.out.println("api_sc_crdel_1:     Section failed");
       }
       System.out.println("api_sc_crdel_1:  create/delete invalid collection");
       if (invalcoll == 0) {
          System.out.println("api_sc_crdel_1:     Section passed");
       } else {
          System.out.println("api_sc_crdel_1:     Section failed");
       }

       if (passorfail == 0) {
          System.out.println("api_sc_crdel_1:  Test Passed");
       } else {
          System.out.println("api_sc_crdel_1:  Test Failed");
       }

       System.exit(passorfail);
    }
}
