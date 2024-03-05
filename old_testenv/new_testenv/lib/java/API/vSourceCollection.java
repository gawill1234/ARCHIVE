
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

import java.net.URL;
import javax.xml.namespace.QName;

import java.util.logging.*;
import java.util.StringTokenizer;

public class vSourceCollection
{
    private static final String COLLECTION_NAME_DEFAULT = "test-suite-collection";
    private static final String WSDL_CGI_PARAMS = "?v.app=api-soap&wsdl=1&specialize-for=&use-types=true";
    private static final String URLS_FILE = "urls.txt";

    private static Logger log = Logger.getLogger(vSourceCollection.class.getName());

    /* -- */

    private SearchCollectionCreate.CollectionMeta cMetaNode = null;
    private VseMetaInfo vMetaInfo = null;

    private String user;
    private String password;
    private String origUrl;
    private String url;
    private String defaultCrawl = "new";
    private String collectionName;
    private String sourcesNames = null;
    private String subcollection = "live";
    private String CONFIG_FILENAME;

    private ENVIRONMENT scEnv;
    private VelocityPort p;
    private Authentication auth;
    private vRepository scRepo;
    private vServices scServices;
    public boolean testHadError = false;

    public vSourceCollection(String url, String collectionName) throws java.lang.Exception
    {

        envInit();
        commonInit(url, collectionName);

    }

    public vSourceCollection(String collectionName) throws java.lang.Exception
    {

        envInit();
        commonInit(this.scEnv.getVelocityUrl(), collectionName);

    }

    private void envInit() {

        this.scEnv = new ENVIRONMENT();

        this.auth = new Authentication();
        this.setUser(this.scEnv.getVivUser());
        this.setPassword(this.scEnv.getVivPassword());

    }

    public void commonInit(String url, String collectionName) throws java.lang.Exception
    {
        //log.info("Created a new test object");

        this.origUrl = url;
        this.url = url + WSDL_CGI_PARAMS;
        this.collectionName = collectionName;
        this.CONFIG_FILENAME = collectionName + ".xml";

        //log.info("Using \"" + this.url + "\"");

        URL wsdlLocation = new URL(this.url);
        QName serviceName = new QName("urn:/velocity", "VelocityService");

        VelocityService s = new VelocityService(wsdlLocation, serviceName);
        this.p = s.getVelocityPort();

        this.scRepo = new vRepository(url, this.collectionName);
        this.scServices = new vServices(url, this.collectionName);

    }

    public void TestIt()
    {
       System.out.println("Hello World");
    }

    public String getCollectionName()
    {
        return(this.collectionName);
    }

    public void setSubcollection(String subc)
    {
        this.subcollection = subc;
        this.scServices.setSubcollection(subc);
    }

    public void setUser(String user)
    {
        auth.setUsername(user);
    }

    public void setPassword(String password)
    {
        auth.setPassword(password);
    }

    public boolean testHadError()
    {
        return this.testHadError;
    }

    public void updateCollection() throws java.lang.Exception
    {
        Element config = this.loadConfigurationFromFile();
        this.setConfiguration(config);
    }

    private void createFullCollection(boolean doFull) throws java.lang.Exception
    {
        //log.info("Creating the collection");
        System.out.println("Creating collection: " + this.collectionName);


        SearchCollectionCreate create = new SearchCollectionCreate();

        create.setAuthentication(this.auth);
        create.setBasedOn("default");
        create.setCollection(this.collectionName);

        if (this.cMetaNode != null) {
           if (this.vMetaInfo != null) {
              System.out.println("Adding collection meta info");
              VseMeta vMeta = new VseMeta();
              vMeta.getVseMetaInfo().add(this.vMetaInfo);
          
              this.cMetaNode.setVseMeta(vMeta);
              create.setCollectionMeta(this.cMetaNode);
              System.out.println("Collection meta info addition complete");
           }
        }

        try {
           this.p.searchCollectionCreate(create);
        } catch (SOAPFaultException sfe) {
            if (checkSOAPFaultExceptionType(sfe, "search-collection-already-exists")) {
                if (doFull) {
                   log.warning("createCollection:  Collection already exists, updating");
                } else {
                   log.warning("createCollection:  Collection already exists");
                }
            } else {
                throw sfe;
            }
        }

        if (doFull) {
           this.updateCollection();
        }
    }

    public void createCollection() throws java.lang.Exception {
       this.createFullCollection(true);
    }

    public void createCollection(boolean doFull) throws java.lang.Exception {
       this.createFullCollection(doFull);
    }

    public void buildCollectionMeta()
    {
       if (this.cMetaNode == null) {
          this.cMetaNode = new SearchCollectionCreate.CollectionMeta();
       }
       if (this.vMetaInfo == null) {
          this.vMetaInfo = new VseMetaInfo();
       }
    }

    public void metaSetLiveIndexFile(String myfile)
    {

       if (this.vMetaInfo == null) {
          this.vMetaInfo = new VseMetaInfo();
       }

       this.vMetaInfo.setLiveIndexFile(myfile);

       return;
    }

    public void metaSetStagingIndexFile(String myfile)
    {

       if (this.vMetaInfo == null) {
          this.vMetaInfo = new VseMetaInfo();
       }

       this.vMetaInfo.setStagingIndexFile(myfile);

       return;
    }

    public void metaSetStagingCrawlDir(String mydir)
    {

       if (this.vMetaInfo == null) {
          this.vMetaInfo = new VseMetaInfo();
       }

       this.vMetaInfo.setStagingCrawlDir(mydir);

       return;
    }

    public void metaSetLiveCrawlDir(String mydir)
    {

       if (this.vMetaInfo == null) {
          this.vMetaInfo = new VseMetaInfo();
       }

       this.vMetaInfo.setLiveCrawlDir(mydir);

       return;
    }

    public void metaSetCacheDir(String mydir)
    {

       if (this.vMetaInfo == null) {
          this.vMetaInfo = new VseMetaInfo();
       }

       this.vMetaInfo.setCacheDir(mydir);

       return;
    }

    public void metaSetStagingLogDir(String mydir)
    {

       if (this.vMetaInfo == null) {
          this.vMetaInfo = new VseMetaInfo();
       }

       this.vMetaInfo.setStagingLogDir(mydir);

       return;
    }

    public void metaSetLiveLogDir(String mydir)
    {

       if (this.vMetaInfo == null) {
          this.vMetaInfo = new VseMetaInfo();
       }

       this.vMetaInfo.setLiveLogDir(mydir);

       return;
    }

    public void metaSetIndexDirectory(String mydir)
    {

       if (this.vMetaInfo == null) {
          this.vMetaInfo = new VseMetaInfo();
       }

       this.vMetaInfo.setIndexDir(mydir);

       return;
    }

    public Element loadConfigurationFromFile() throws java.lang.Exception
    {
        //log.info("Loading configuration from file \"" + this.CONFIG_FILENAME + "\"");

        File file = new File(this.CONFIG_FILENAME);
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db = dbf.newDocumentBuilder();
        org.w3c.dom.Document doc = db.parse(file);

        Element config = doc.getDocumentElement();
        config.setAttribute("name", this.collectionName);

        return config;
    }

    public void setConfigurationFileName(String fname) throws java.lang.Exception
    {

        this.CONFIG_FILENAME = fname;

    }

    public void setConfiguration(Element config) throws java.lang.Exception
    {
        //log.info("Setting collection configuration");

        Element myconfig = this.scRepo.loadConfigurationFromFile(this.CONFIG_FILENAME);
        this.scRepo.setConfiguration(myconfig);

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


    public boolean collectionExists() throws java.lang.Exception
    {
        //log.info("collectionExists:  Checking for collection " + this.collectionName);

        RepositoryGet collectionNode = new RepositoryGet();

        collectionNode.setAuthentication(this.auth);
        collectionNode.setElement("vse-collection");
        collectionNode.setName(this.collectionName);

        try {
           RepositoryGetResponse resp = this.p.repositoryGet(collectionNode);
           if (resp == null) {
              return false;
           }
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //prettyPrintSOAPFaultException(e);
              //log.info("collectionExists:  Collection does not exist");
              return false;
           } else {
              throw e;
           }
        }
        
        //log.info("collectionExists:  Collection exists");
        return true;
    }

    public boolean collectionExistsWorks()
    {
        //log.info("collectionExists:  Checking for collection " + this.collectionName);

        RepositoryGet collectionNode = new RepositoryGet();

        collectionNode.setAuthentication(this.auth);
        collectionNode.setElement("vse-collection");
        collectionNode.setName(this.collectionName);

        try {
           RepositoryGetResponse resp = this.p.repositoryGet(collectionNode);
           if (resp == null) {
              return false;
           }
        } catch (javax.xml.ws.soap.SOAPFaultException e) {
           //log.info("collectionExists:  collection does not exist");
           return false;
        }

        return true;
    }

    private VseStatus collectionServiceStatus()
    {
        //log.info("Getting the collection services status");

        SearchCollectionStatus getstatus = new SearchCollectionStatus();

        getstatus.setAuthentication(this.auth);
        getstatus.setCollection(this.collectionName);
        getstatus.setSubcollection(this.subcollection);

        try {
           SearchCollectionStatusResponse vstat = this.p.searchCollectionStatus(getstatus);
           VseStatus vses = vstat.getVseStatus();
           return vses;
        } catch (java.lang.Exception e) {
           return null;
        }

    }

    public void collectionClean()
    {
        //log.info("Cleaning the collection");

        SearchCollectionClean flushit = new SearchCollectionClean();

        flushit.setAuthentication(this.auth);
        flushit.setCollection(this.collectionName);

        this.p.searchCollectionClean(flushit);
    }


    public void setSearchSources(String sourcesString)
    {
       this.sourcesNames = sourcesString;
    }

    public void killCollection(String dokill) throws java.lang.Exception
    {

        int mywait = 5 * 1000;

        //log.info("Stopping the crawler and the indexer");

        if (dokill != null) {
           if (dokill.equals("true")) {
              mywait = 2 * 1000;
           }
        }

        this.scServices.stopCrawl(dokill);
        Thread.sleep(mywait);
        this.scServices.stopIndexer(dokill);
        Thread.sleep(mywait);
    }

    private void doDeleteCollection(boolean srvDead) throws java.lang.Exception
    {
        String cstatus;
        String istatus;
        String items[] = {"staging", "live"};

        //log.info("Deleting the collection");

        if (!srvDead) {
           for ( String srv : items ) {
              this.scServices.setSubcollection(srv);
              this.scServices.stopCrawl("true");
              this.scServices.stopIndexer("true");

              cstatus = this.scServices.waitForCrawlStatus("stopped", 5, 2);
              istatus = this.scServices.waitForIndexerStatus("stopped", 5, 2);
           }
        }

        //log.warning("Sleeping for 5 seconds to allow services to exit");
        //Thread.sleep(5*1000);

        SearchCollectionDelete delete = new SearchCollectionDelete();

        delete.setAuthentication(this.auth);
        delete.setCollection(this.collectionName);

        this.p.searchCollectionDelete(delete);
    }

    public void deleteCollection() throws java.lang.Exception
    {
       doDeleteCollection(false);
    }

    public void deleteCollection(boolean srvDead) throws java.lang.Exception
    {
       doDeleteCollection(srvDead);
    }

    public void waitForCrawlToFinish() throws java.lang.Exception
    {
       this.scServices.waitForIdle();
    }

    public void startCrawl() throws java.lang.Exception
    {
       this.scServices.startCrawl("resume");
    }

    public void startCrawl(String crawlType) throws java.lang.Exception
    {
       this.scServices.startCrawl(crawlType);
    }

}
