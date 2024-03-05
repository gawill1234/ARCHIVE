
import velocity.*;
import velocity.objects.*;
import velocity.soap.*;
import velocity.types.*;

import java.io.File;
import java.io.FileWriter;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Attr;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import javax.xml.ws.soap.SOAPFaultException;
import static soapfault.SOAPFaultExceptionUtils.*;

import java.io.*;

import java.util.Set;
import java.util.HashSet;
import java.net.URL;
import javax.xml.namespace.QName;

import java.util.logging.*;
import java.util.StringTokenizer;

public class vRepository
{
    private Set<String> internalStuff = null;
    private static final String COLLECTION_NAME_DEFAULT = "test-suite-collection";
    private static final String WSDL_CGI_PARAMS = "?v.app=api-soap&wsdl=1&specialize-for=&use-types=true";
    private static final String URLS_FILE = "urls.txt";

    private static Logger log = Logger.getLogger(vRepository.class.getName());

    /* -- */

    private SearchCollectionCreate.CollectionMeta cMetaNode = null;
    private VseMetaInfo vMetaInfo = null;

    private String url;
    private String defaultCrawl = "new";
    private String collectionName;
    private String sourcesNames = null;
    private String subcollection = "live";
    private String CONFIG_FILENAME;

    private int nostart = 0;

    private ENVIRONMENT repoEnv;
    private VelocityPort p;
    private Authentication auth;
    private boolean killer = false;
    public boolean testHadError = false;

    public vRepository(String url, String collectionName) throws java.lang.Exception
    {

       envInit();
       commonInit(url, collectionName);

    }

    public vRepository(String collectionName) throws java.lang.Exception
    {
       envInit();
       commonInit(this.repoEnv.getVelocityUrl(), collectionName);

    }

    public vRepository() throws java.lang.Exception
    {
       envInit();
       commonInit(this.repoEnv.getVelocityUrl());

    }

    private void envInit() {

        this.auth = new Authentication();

        this.repoEnv = new ENVIRONMENT();
        this.setUser(this.repoEnv.getVivUser());
        this.setPassword(this.repoEnv.getVivPassword());

    }

    private void commonInit(String url, String collectionName) throws java.lang.Exception
    {
        //log.info("Created a new test object");

        this.url = url + WSDL_CGI_PARAMS;
        this.collectionName = collectionName;
        this.CONFIG_FILENAME = collectionName + ".xml";

        //log.info("Using \"" + this.url + "\"");

        URL wsdlLocation = new URL(this.url);
        QName serviceName = new QName("urn:/velocity", "VelocityService");

        VelocityService s = new VelocityService(wsdlLocation, serviceName);
        this.p = s.getVelocityPort();
    }

    private void commonInit(String url) throws java.lang.Exception
    {
        //log.info("Created a new test object");

        this.url = url + WSDL_CGI_PARAMS;

        //log.info("Using \"" + this.url + "\"");

        URL wsdlLocation = new URL(this.url);
        QName serviceName = new QName("urn:/velocity", "VelocityService");

        VelocityService s = new VelocityService(wsdlLocation, serviceName);
        this.p = s.getVelocityPort();
    }

    public void TestIt()
    {
       System.out.println("Hello World");
    }

    public void setUser(String user)
    {
        auth.setUsername(user);
    }

    public void setCollectionName(String collectionName) {
        this.collectionName = collectionName;
        this.CONFIG_FILENAME = collectionName + ".xml";
    }

    public void setPassword(String password)
    {
        auth.setPassword(password);
    }

    public boolean testHadError()
    {
        return this.testHadError;
    }

    public Element loadConfigurationFromFile() throws java.lang.Exception
    {
        //log.info("Loading configuration from file \"" + CONFIG_FILENAME + "\"");

        File file = new File(CONFIG_FILENAME);
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db = dbf.newDocumentBuilder();
        org.w3c.dom.Document doc = db.parse(file);

        Element config = doc.getDocumentElement();
        config.setAttribute("name", this.collectionName);

        return config;
    }

    public Element loadConfigurationFromFile(String fname) throws java.lang.Exception
    {
        //log.info("Loading configuration from file \"" + fname + "\"");

        File file = new File(fname);
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db = dbf.newDocumentBuilder();
        org.w3c.dom.Document doc = db.parse(file);

        Element config = doc.getDocumentElement();
        config.setAttribute("name", this.collectionName);

        return config;
    }

    public Element loadConfigurationFromFile(String fname,
                                             String attrName,
                                             String attrValue)
                                             throws java.lang.Exception
    {
        //log.info("Loading configuration from file \"" + fname + "\"");

        File file = new File(fname);
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db = dbf.newDocumentBuilder();
        org.w3c.dom.Document doc = db.parse(file);

        Element config = doc.getDocumentElement();
        config.setAttribute(attrName, attrValue);

        return config;
    }

    public void setConfiguration(Element config) throws java.lang.Exception
    {
        //log.info("Setting collection configuration");

        RepositoryUpdate update = new RepositoryUpdate();
        RepositoryUpdate.Node inner_node = new RepositoryUpdate.Node();

        inner_node.setAny(config);

        update.setAuthentication(this.auth);
        update.setNode(inner_node);

        String new_md5 = this.p.repositoryUpdate(update);
        //log.info("New MD5: " + new_md5);
    }

    public void vRepoUpdate(String fname,
                            String attrName,
                            String attrValue)
                            throws java.lang.Exception
    {
       Element config = this.loadConfigurationFromFile(fname, attrName, attrValue);
       this.setConfiguration(config);
       return;
    }

    public void addConfiguration(Element config) throws java.lang.Exception
    {
        //log.info("Adding repository node");

        RepositoryAdd update = new RepositoryAdd();
        RepositoryAdd.Node inner_node = new RepositoryAdd.Node();

        inner_node.setAny(config);

        update.setAuthentication(this.auth);
        update.setNode(inner_node);

        String new_md5 = this.p.repositoryAdd(update);
        //log.info("New MD5: " + new_md5);
    }

    public void apiRepositoryDelete(String itemName,
                              String itemType) throws java.lang.Exception
    {

        //log.info("Deleting repository item");

        RepositoryDelete repositoryNode = new RepositoryDelete();

        repositoryNode.setAuthentication(this.auth);
        repositoryNode.setElement(itemType);
        repositoryNode.setName(itemName);

        try {
           this.p.repositoryDelete(repositoryNode);
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //prettyPrintSOAPFaultException(e);
              System.out.println("repositoryDelete:  Item does not exist");
           } else {
              throw e;
           }
        }
    }
     
    public Set getInternalCollection() {
       return(this.internalStuff);
    }

    //
    //   Set up the list of collections and sources that are internal
    //   to velocity.
    //
    private void apiRepositoryInternalCollections() throws java.lang.Exception
    {
        int x, abc;
        NodeList mylist = null;
        String repoItem[] = {"vse-collection", "source"};

        if (this.internalStuff == null) {
           this.internalStuff = new HashSet<String>();
           //
           //  These are the items that are internal to Velocity that
           //  are not marked as internal.  Add them since we can not
           //  find them.
           //
           this.internalStuff.add("example-source-bundle");
           this.internalStuff.add("vse_form-default-sort");
           this.internalStuff.add("iopro-tm-template");
           this.internalStuff.add("BBC-Tutorial");
           this.internalStuff.add("example-metadata");
           this.internalStuff.add("iopro-sm-spotlights");
           this.internalStuff.add("iopro-tm-sample");
           this.internalStuff.add("example-news-bundle");
        } else {
           return;
        }

        //log.info("Getting repository item");

        RepositoryListXml repositoryNode = new RepositoryListXml();
        repositoryNode.setAuthentication(this.auth);

     
        try {
           RepositoryListXmlResponse resp = this.p.repositoryListXml(repositoryNode);
           if (resp == null) {
              return;
           }
           Element rlrNode = (Element)resp.getAny();
           for ( String repoShit : repoItem ) {
              mylist = rlrNode.getElementsByTagName(repoShit);
              x = mylist.getLength();
              abc = 0;
              while (abc < x) {
                 Element nn = (Element)mylist.item(abc);
                 String mything = nn.getAttribute("name");
                 String myintern = nn.getAttribute("internal");
                 if (!myintern.equals("")) {
                    if (!this.internalStuff.contains(mything)) {
                       this.internalStuff.add(mything);
                    }
                 }
                 abc += 1;
              }
           }
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //log.info("repositoryGet:  Item does not exist");
              return;
           } else {
              throw e;
           }
        }

        return;
    }

    //
    //   Get the list of collections and sources that are NOT internal
    //   to velocity.
    //
    public Set apiRepositoryListCollections() {

       int x, abc;
       NodeList mylist = null;
       String repoItem[] = {"vse-collection", "source"};
       Set<String> externalStuff = new HashSet<String>();

       try {
          apiRepositoryInternalCollections();
       } catch(java.lang.Exception jle) {
          System.out.println("FUCK!");
          return(null);
       }

        //log.info("Getting repository item");

       RepositoryListXml repositoryNode = new RepositoryListXml();
       repositoryNode.setAuthentication(this.auth);

     
       try {
          RepositoryListXmlResponse resp = this.p.repositoryListXml(repositoryNode);
          if (resp == null) {
             return(null);
          }
          Element rlrNode = (Element)resp.getAny();
          for ( String repoShit : repoItem ) {
             mylist = rlrNode.getElementsByTagName(repoShit);
             x = mylist.getLength();
             abc = 0;
             while (abc < x) {
                Element nn = (Element)mylist.item(abc);
                String mything = nn.getAttribute("name");
                String myintern = nn.getAttribute("internal");
                if (!this.internalStuff.contains(mything)) {
                   externalStuff.add(mything);
                }
                abc += 1;
             }
          }
       } catch (SOAPFaultException e) {
          if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
             //log.info("repositoryGet:  Item does not exist");
             return(null);
          } else {
             throw e;
          }
       }

       return(externalStuff);
    }

    //
    //  If an item is not on the internal Velocity list, get it out
    //  of the repository in all of its forms.
    //
    public void repositoryCollectionFlush(String cName) {

       try {
          apiRepositoryInternalCollections();
       } catch(java.lang.Exception jle) {
          System.out.println("FUCK!");
          return;
       }

       if (!this.internalStuff.contains(cName)) {
          try {
             apiRepositoryDelete(cName, "vse-collection");
          } catch (java.lang.Exception jle) {
             System.out.println("vse-collection delete failed for " + cName);
          }
          try {
             apiRepositoryDelete(cName, "source");
          } catch (java.lang.Exception jle) {
             System.out.println("source delete failed for " + cName);
          }
          try {
             apiRepositoryDelete(cName + "#staging", "source");
          } catch (java.lang.Exception jle) {
             System.out.println("source delete failed for " + cName + "#staging");
          }
       }

       return;

    }


    public int apiRepositoryListCount(String ndName) throws java.lang.Exception
    {
        int x;

        //log.info("Getting repository item");

        RepositoryListXml repositoryNode = new RepositoryListXml();
        repositoryNode.setAuthentication(this.auth);

        try {
           RepositoryListXmlResponse resp = this.p.repositoryListXml(repositoryNode);
           if (resp == null) {
              return 0;
           }
           Element rlrNode = (Element)resp.getAny();
           NodeList mylist = rlrNode.getElementsByTagName(ndName);
           x = mylist.getLength();
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //log.info("repositoryGet:  Item does not exist");
              return 0;
           } else {
              throw e;
           }
        }

        return x;
    }

    public RepositoryGetResponse apiRepositoryGet(String itemName,
                              String itemType) throws java.lang.Exception
    {

        RepositoryGetResponse resp = null;
        Element thing = null;
        String thingName;
        String thingType;

        //log.info("Getting repository item");

        RepositoryGet repositoryNode = new RepositoryGet();

        repositoryNode.setAuthentication(this.auth);
        repositoryNode.setElement(itemType);
        repositoryNode.setName(itemName);

        try {
           resp = this.p.repositoryGet(repositoryNode);
           if (resp == null) {
              return null;
           }
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //prettyPrintSOAPFaultException(e);
              //log.info("repositoryGet:  Item does not exist");
              return null;
           } else {
              throw e;
           }
        }

        return resp;
    }

    public String apiRepositoryGet(String itemName,
                              String itemType,
                              String returnWhat) throws java.lang.Exception
    {

        RepositoryGetResponse resp = null;
        Element thing = null;
        String thingName;
        String thingType;

        //log.info("Getting repository item");

        RepositoryGet repositoryNode = new RepositoryGet();

        repositoryNode.setAuthentication(this.auth);
        repositoryNode.setElement(itemType);
        repositoryNode.setName(itemName);

        try {
           resp = this.p.repositoryGet(repositoryNode);
           if (resp == null) {
              return null;
           }
           thing = (Element)resp.getAny();
           thingName = thing.getAttribute("name");
           thingType = thing.getTagName();
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //prettyPrintSOAPFaultException(e);
              //log.info("repositoryGet:  Item does not exist");
              return null;
           } else {
              throw e;
           }
        }

        if (returnWhat.equals("name")) {
           return thingName;
        }
        if (returnWhat.equals("type")) {
           return thingType;
        }
        return thingName;
    }

}
