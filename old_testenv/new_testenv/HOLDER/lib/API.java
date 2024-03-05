
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

public class API
{
    private static final String COLLECTION_NAME_DEFAULT = "test-suite-collection";
    private static final String WSDL_CGI_PARAMS = "?v.app=api-soap&wsdl=1&specialize-for=&use-types=true";
    private static final String URLS_FILE = "urls.txt";

    private static Logger log = Logger.getLogger(API.class.getName());

    /* -- */

    //
    //   Query search option values
    //
    private int start = -1;
    private boolean startSetIt = false;

    private int num = -1;
    private boolean numSetIt = false;

    private int numMax = -1;
    private boolean numMaxSetIt = false;

    private int fetchTimeOut = -1;
    private boolean fetchTimeOutSetIt = false;

    private double numOverRequest = -1.0;
    private boolean numOverRequestSetIt = false;

    private int numPerSource = -1;
    private boolean numPerSourceSetIt = false;

    //
    //   Aggregation query parameter items
    //
    private boolean OAggregate = false;
    private boolean OAggregateSetIt = false;
  
    private int OAggregateMP = -1;
    private boolean OAggregateMPSetIt = false;

    //
    //   Content list query parameter items
    //
    private String OContents = null;
    private boolean OContentsSetIt = false;

    private String OContentsMode = null;
    private boolean OContentsModeSetIt = false;

    private String QABinningMode = null;
    private boolean QABinningModeSetIt = false;

    private String QABinningState = null;
    private boolean QABinningStateSetIt = false;

    //
    //   Output query parameter items
    //
    private boolean OSummary = false;
    private boolean OSummarySetIt = false;

    private boolean OScore = false;
    private boolean OScoreSetIt = false;

    private boolean OShingles = false;
    private boolean OShinglesSetIt = false;

    private boolean ODups = false;
    private boolean ODupsSetIt = false;

    private boolean OKey = false;
    private boolean OKeySetIt = false;

    private boolean OCacheRef = false;
    private boolean OCacheRefSetIt = false;

    private boolean OCacheData = false;
    private boolean OCacheDataSetIt = false;

    private boolean OSortKeys = false;
    private boolean OSortKeysSetIt = false;

    private SearchCollectionCreate.CollectionMeta cMetaNode = null;
    private VseMetaInfo vMetaInfo = null;

    private String url;
    private String defaultCrawl = "new";
    private String collectionName;
    private String sourcesNames = null;
    private String subcollection = "live";
    private String CONFIG_FILENAME;

    private int nostart = 0;

    private VelocityPort p;
    private Authentication auth;
    private boolean killer = false;
    public boolean testHadError = false;

    public API(String url, String collectionName) throws java.lang.Exception
    {
        log.info("Created a new test object");

        this.url = url + WSDL_CGI_PARAMS;
        this.collectionName = collectionName;
        this.CONFIG_FILENAME = collectionName + ".xml";

        log.info("Using \"" + this.url + "\"");

        URL wsdlLocation = new URL(this.url);
        QName serviceName = new QName("urn:/velocity", "VelocityService");

        VelocityService s = new VelocityService(wsdlLocation, serviceName);
        this.p = s.getVelocityPort();

        this.auth = new Authentication();
    }

    public void TestIt()
    {
       System.out.println("Hello World");
    }


    public int countLinesInFile(String filename) {
       //...checks on aFile are elided
       File testFile = new File(filename);
       StringBuilder contents = new StringBuilder();
       int LineCount = 0;
    
       try {
         //use buffering, reading one line at a time
         //FileReader always assumes default encoding is OK!
         BufferedReader input =  new BufferedReader(new FileReader(testFile));
         try {
           String line = null; //not declared within while loop
           /*
           * readLine is a bit quirky :
           * it returns the content of a line MINUS the newline.
           * it returns null only for the END of the stream.
           * it returns an empty String if two newlines appear in a row.
           */
           while (( line = input.readLine()) != null){
             LineCount = LineCount + 1;
             //contents.append(line);
             //contents.append(System.getProperty("line.separator"));
           }
         }
         finally {
           input.close();
         }
       }
       catch (IOException ex){
         ex.printStackTrace();
       }
    
       return LineCount;
     }

     public int countXMLLinesInFile(String filename, String node, String attr) {

        int LineCount = 0;

        try {
           File file = new File(filename);
           DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
           DocumentBuilder db = dbf.newDocumentBuilder();
           Document doc = db.parse(file);
           doc.getDocumentElement().normalize();
           System.out.println("Root element " + doc.getDocumentElement().getNodeName());
           NodeList nodeLst = doc.getElementsByTagName("employee");
           System.out.println("File XML Dump");

           for (int s = 0; s < nodeLst.getLength(); s++) {
   
              Node fstNode = nodeLst.item(s);
    
              if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
  
                 Element fstElmnt = (Element) fstNode;
                 NodeList fstNmElmntLst = fstElmnt.getElementsByTagName("firstname");
                 Element fstNmElmnt = (Element) fstNmElmntLst.item(0);
                 NodeList fstNm = fstNmElmnt.getChildNodes();
                 System.out.println("First Name : "  + ((Node) fstNm.item(0)).getNodeValue());
                 NodeList lstNmElmntLst = fstElmnt.getElementsByTagName("lastname");
                 Element lstNmElmnt = (Element) lstNmElmntLst.item(0);
                 NodeList lstNm = lstNmElmnt.getChildNodes();
                 System.out.println("Last Name : " + ((Node) lstNm.item(0)).getNodeValue());
              }
           }
        } catch (java.lang.Exception e) {
           e.printStackTrace();
        }

        return LineCount;
     }


    //
    //   This function is a cheat.  Did not want to reinvent file
    //   existence check for remote files just yet.  Probably later.
    //
    public int RemoteFileExists(String filepath) throws java.lang.Exception
    {
       Runtime r = Runtime.getRuntime();
       java.lang.Process p = null;

       String mycmd = "file_exists -F " + filepath;

       try {
          p = r.exec(mycmd);
          p.waitFor();
       } catch (java.lang.Exception e) {
          System.err.println("Could not exec " + mycmd);
       }

       return p.exitValue();
    }

    public String VivisimoDir() throws java.lang.Exception
    {
       Runtime r = Runtime.getRuntime();
       java.lang.Process p = null;

       String mycmd = "vivisimo_dir";
       String lastout = "";
       int numchars;
       byte blah[];

       blah = new byte[4096];

       try {
          p = r.exec(mycmd);
          p.waitFor();
       } catch (java.lang.Exception e) {
          System.err.println("Could not exec " + mycmd);
       }

       InputStream qq = p.getInputStream();
       numchars = qq.available();

       if (numchars == 0) {
          return "";
       } else {
          qq.read(blah, 0, numchars);

          for (int i = 0; i < numchars; i++) {
             if ((char)blah[i] != '\n') {
                lastout = lastout + (char)blah[i];
             } else {
                i = numchars + 1;
             }
          }

          return lastout;
       }
    }

    public void setSubcollection(String subc)
    {
        this.subcollection = subc;
    }

    //
    //   Set the QuerySearch values to something other than -1
    //
    public void setStart(int startval)
    {
        this.start = startval;
        this.startSetIt = true;
    }

    public void unsetStart()
    {
        this.startSetIt = false;
    }

    public void unsetOContents()
    {
        this.OContentsSetIt = false;
    }
    public void unsetOContentsMode()
    {
        this.OContentsModeSetIt = false;
    }
    public void unsetOSummary()
    {
        this.OSummarySetIt = false;
    }

    public void unsetOScore()
    {
        this.OScoreSetIt = false;
    }

    public void unsetOShingles()
    {
        this.OShinglesSetIt = false;
    }

    public void unsetODups()
    {
        this.ODupsSetIt = false;
    }

    public void unsetOKey()
    {
        this.OKeySetIt = false;
    }

    public void unsetOCacheRef()
    {
        this.OCacheRefSetIt = false;
    }

    public void unsetOCacheData()
    {
        this.OCacheDataSetIt = false;
    }

    public void unsetOSortKeys()
    {
        this.OSortKeysSetIt = false;
    }
    public void setOContents(String ocont)
    {
        this.OContentsSetIt = true;
        this.OContents = ocont;
    }
    public void setOContentsMode(String ocontmode)
    {
        this.OContentsModeSetIt = true;
        this.OContentsMode = ocontmode;
    }
    public void setOSummary(boolean osum)
    {
        this.OSummarySetIt = true;
        this.OSummary = osum;
    }

    public void setOScore(boolean oscore)
    {
        this.OScoreSetIt = true;
        this.OScore = oscore;
    }

    public void setOShingles(boolean oshingles)
    {
        this.OShinglesSetIt = true;
        this.OShingles = oshingles;
    }

    public void setODups(boolean odup)
    {
        this.ODupsSetIt = true;
        this.ODups = odup;
    }

    public void setOKey(boolean okey)
    {
        this.OKeySetIt = true;
        this.OKey = okey;
    }

    public void setOCacheRef(boolean ocref)
    {
        this.OCacheRefSetIt = true;
        this.OCacheRef = ocref;
    }

    public void setOCacheData(boolean ocdat)
    {
        this.OCacheDataSetIt = true;
        this.OCacheData = ocdat;
    }

    public void setOSortKeys(boolean oskey)
    {
        this.OSortKeysSetIt = true;
        this.OSortKeys = oskey;
    }

    public void setNum(int numval)
    {
        this.num = numval;
        this.numSetIt = true;
    }

    public void setBinningState(String bState)
    {
        this.QABinningState = bState;
        this.QABinningStateSetIt = true;
    }

    public void setBinningMode(String bMode)
    {
        this.QABinningMode = bMode;
        this.QABinningModeSetIt = true;
    }

    public void setNumMax(int numMaxval)
    {
        this.numMax = numMaxval;
        this.numMaxSetIt = true;
    }

    public void setfetchTimeOut(int ftoval)
    {
        this.fetchTimeOut = ftoval;
        this.fetchTimeOutSetIt = true;
    }

    public void setNumOverRequest(double norval)
    {
        this.numOverRequest = norval;
        this.numOverRequestSetIt = true;
    }

    public void setNumPerSource(int npsval)
    {
        this.numPerSource = npsval;
        this.numPerSourceSetIt = true;
    }

    public void unsetNum()
    {
        this.numSetIt = false;
    }

    public void unsetNumMax()
    {
        this.numMaxSetIt = false;
    }

    public void unsetfetchTimeOut()
    {
        this.fetchTimeOutSetIt = false;
    }

    public void unsetNumOverRequest()
    {
        this.numOverRequestSetIt = false;
    }

    public void unsetNumPerSource()
    {
        this.numPerSourceSetIt = false;
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

    public void createCollection() throws java.lang.Exception
    {
        log.info("Creating the collection");
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
                log.warning("createCollection:  Collection already exists, exiting");
                System.exit(1);
            } else {
                throw sfe;
            }
        }
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
        log.info("Loading configuration from file \"" + CONFIG_FILENAME + "\"");

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
        log.info("Loading configuration from file \"" + fname + "\"");

        File file = new File(fname);
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db = dbf.newDocumentBuilder();
        org.w3c.dom.Document doc = db.parse(file);

        Element config = doc.getDocumentElement();
        config.setAttribute("name", this.collectionName);

        return config;
    }

    public void setConfiguration(Element config) throws java.lang.Exception
    {
        log.info("Setting collection configuration");

        RepositoryUpdate update = new RepositoryUpdate();
        RepositoryUpdate.Node inner_node = new RepositoryUpdate.Node();

        inner_node.setAny(config);

        update.setAuthentication(this.auth);
        update.setNode(inner_node);

        String new_md5 = this.p.repositoryUpdate(update);
        log.info("New MD5: " + new_md5);
    }

    public void addConfiguration(Element config) throws java.lang.Exception
    {
        log.info("Adding repository node");

        RepositoryAdd update = new RepositoryAdd();
        RepositoryAdd.Node inner_node = new RepositoryAdd.Node();

        inner_node.setAny(config);

        update.setAuthentication(this.auth);
        update.setNode(inner_node);

        String new_md5 = this.p.repositoryAdd(update);
        log.info("New MD5: " + new_md5);
    }

    public void apiRepositoryDelete(String itemName,
                              String itemType) throws java.lang.Exception
    {

        log.info("Deleting repository item");

        RepositoryDelete repositoryNode = new RepositoryDelete();

        repositoryNode.setAuthentication(this.auth);
        repositoryNode.setElement(itemType);
        repositoryNode.setName(itemName);

        try {
           this.p.repositoryDelete(repositoryNode);
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //prettyPrintSOAPFaultException(e);
              log.info("repositoryGet:  Item does not exist");
           } else {
              throw e;
           }
        }
    }

    public int apiRepositoryListCount(String ndName) throws java.lang.Exception
    {
        int x;

        log.info("Getting repository item");

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
              log.info("repositoryGet:  Item does not exist");
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

        log.info("Getting repository item");

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
              log.info("repositoryGet:  Item does not exist");
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

        log.info("Getting repository item");

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
              log.info("repositoryGet:  Item does not exist");
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

    public boolean collectionExists() throws java.lang.Exception
    {
        log.info("collectionExists:  Checking for collection " + this.collectionName);

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
              log.info("collectionExists:  Collection does not exist");
              return false;
           } else {
              throw e;
           }
        }
        
        log.info("collectionExists:  Collection exists");
        return true;
    }

    public boolean collectionExistsWorks()
    {
        log.info("collectionExists:  Checking for collection " + this.collectionName);

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
           log.info("collectionExists:  collection does not exist");
           return false;
        }

        return true;
    }

    private VseStatus collectionServiceStatus()
    {
        log.info("Getting the collection services status");

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

    public String crawlerStatus()
    {
        log.info("Getting the crawler status");

        String defaultreturn = "idle";

        VseStatus vses = collectionServiceStatus();
        if ( vses != null ) {
           CrawlerStatus vseis = vses.getCrawlerStatus();
           String idlevalue = vseis.getIdle();
           String runvalue = vseis.getServiceStatus();
           //System.out.println("crawler idle: " + idlevalue);
           //System.out.println("crawler status: " + runvalue);
           if ( idlevalue != null ) {
              if ( idlevalue.equals("idle") && runvalue.equals("running") ) {
                 return idlevalue;
              }
           }
           return runvalue;
        } else {
           return defaultreturn;
        }

    }

    public String indexerStatus()
    {
        log.info("Getting the indexer status");
        String defaultreturn = "idle";

        VseStatus vses = collectionServiceStatus();
        if ( vses != null ) {
           VseIndexStatus vseis = vses.getVseIndexStatus();
           String idlevalue = vseis.getIdle();
           String runvalue = vseis.getServiceStatus();
           //System.out.println("indexer idle: " + idlevalue);
           //System.out.println("indexer status: " + runvalue);
           if ( idlevalue != null ) {
              if ( idlevalue.equals("idle") && runvalue.equals("running") ) {
                 return idlevalue;
              }
           }
        return runvalue;
        } else {
           return defaultreturn;
        }

    }

    public void waitForIdle() throws java.lang.Exception
    {
       String cstat = null;
       String istat = null;

       log.info("Wait for crawler and indexer to be idle");
       int idlecount = 0;

       Thread.sleep(4*1000);

       do {
          Thread.sleep(1*1000);
          cstat = crawlerStatus();
          istat = indexerStatus();
          if (cstat.equals("idle") || cstat.equals("stopped")) {
             if (istat.equals("idle") || istat.equals("stopped")) {
                idlecount = idlecount + 1;
                System.out.println("Crawler and indexer are idle, " + idlecount + " of 3 checks");
             } else {
                idlecount = 0;
             }
          } else {
             idlecount = 0;
          }
       } while (idlecount < 3);
       System.out.println("Crawler and indexer are idle.");
    }

    public void startCrawl(String crawlType)
    {
        log.info("Starting the crawler");
        System.out.println("Collection/Subcollection " + 
                            this.collectionName + "/" +
                            this.subcollection);

        if (crawlType == null) {
           crawlType = this.defaultCrawl;
        }

        SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();

        start.setAuthentication(this.auth);
        start.setCollection(this.collectionName);
        if (this.subcollection.equals("live") ||
            this.subcollection.equals("staging")) {
           start.setSubcollection(this.subcollection);
        }
        //start.setType("resume");
        start.setType(crawlType);

        this.p.searchCollectionCrawlerStart(start);
    }

    public void restartCrawl()
    {
        log.info("Restarting the crawler");

        SearchCollectionCrawlerRestart start = new SearchCollectionCrawlerRestart();

        start.setAuthentication(this.auth);
        start.setCollection(this.collectionName);

        this.p.searchCollectionCrawlerRestart(start);
    }

    public void restartIndexer()
    {
        log.info("Restarting the Indexer");

        SearchCollectionIndexerRestart start = new SearchCollectionIndexerRestart();

        start.setAuthentication(this.auth);
        start.setCollection(this.collectionName);

        this.p.searchCollectionIndexerRestart(start);
    }

    public void collectionClean()
    {
        log.info("Cleaning the collection");

        SearchCollectionClean flushit = new SearchCollectionClean();

        flushit.setAuthentication(this.auth);
        flushit.setCollection(this.collectionName);

        this.p.searchCollectionClean(flushit);
    }

    public void searchServiceStart()
    {
        log.info("Starting the search service");

        SearchServiceStart flushit = new SearchServiceStart();

        flushit.setAuthentication(this.auth);

        this.p.searchServiceStart(flushit);
    }

    public void searchServiceRestart()
    {
        log.info("Restarting the search service");

        SearchServiceRestart flushit = new SearchServiceRestart();

        flushit.setAuthentication(this.auth);

        this.p.searchServiceRestart(flushit);
    }

    public void searchServiceStop()
    {
        log.info("Stopping the search service");

        SearchServiceStop flushit = new SearchServiceStop();

        flushit.setAuthentication(this.auth);

        this.p.searchServiceStop(flushit);
    }

    public int searchServiceGet()
    {
        VseQs thing = null;
        VseQsOption thingName;
        int srvPort;

        log.info("Getting search service data");

        SearchServiceGet ssg = new SearchServiceGet();

        ssg.setAuthentication(this.auth);

        try {
           SearchServiceGetResponse resp = this.p.searchServiceGet(ssg);
           if (resp == null) {
              return 0;
           }
           thing = resp.getVseQs();
           thingName = thing.getVseQsOption();
           srvPort = thingName.getPort();
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //prettyPrintSOAPFaultException(e);
              log.info("repositoryGet:  Item does not exist");
              return 0;
           } else {
              throw e;
           }
        }

        return srvPort;
    }

    private VseQs searchServiceGetVseQs()
    {
        VseQs thing = null;
        VseQsOption thingName;

        log.info("Getting search service data");

        SearchServiceGet ssg = new SearchServiceGet();

        ssg.setAuthentication(this.auth);

        try {
           SearchServiceGetResponse resp = this.p.searchServiceGet(ssg);
           if (resp == null) {
              return null;
           }
           thing = resp.getVseQs();
        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //prettyPrintSOAPFaultException(e);
              log.info("repositoryGet:  Item does not exist");
              return null;
           } else {
              throw e;
           }
        }

        return thing;
    }

    public void searchServiceSet(int myport)
    {

        VseQs vsNode;
        VseQsOption vsOptNode;

        log.info("Setting the search service port");

        vsNode = this.searchServiceGetVseQs();
        vsOptNode = vsNode.getVseQsOption();

        vsOptNode.setPort(myport);
        vsNode.setVseQsOption(vsOptNode);

        SearchServiceSet.Configuration sssC =
                         new SearchServiceSet.Configuration();

        sssC.setVseQs(vsNode);

        SearchServiceSet sss = new SearchServiceSet();
        sss.setAuthentication(this.auth);
        sss.setConfiguration(sssC);

        this.p.searchServiceSet(sss);
    }

    public String searchServiceStatus()
    {
        Element respData = null;
        Element srvStatElem = null;
        String thingName = null;
        String statusString = "stopped";
        NodeList srvStatNode = null;

        log.info("Getting search service data");

        SearchServiceStatusXml ssg = new SearchServiceStatusXml();

        ssg.setAuthentication(this.auth);

        try {
           SearchServiceStatusXmlResponse resp = this.p.searchServiceStatusXml(ssg);
           if (resp == null) {
              return null;
           }

           respData = (Element)resp.getAny();

           srvStatNode = respData.getElementsByTagName("service-status");
           srvStatElem = (Element)srvStatNode.item(0);

           if (srvStatElem != null) {
              thingName = srvStatElem.getAttribute("started");
              if (thingName != null) {
                 statusString = "running";
              }
           }

        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //prettyPrintSOAPFaultException(e);
              log.info("repositoryGet:  Item does not exist");
              return null;
           } else {
              throw e;
           }
        }

        return statusString;
    }

    public void waitForCrawlFinish() throws java.lang.Exception
    {
        log.info("Waiting for the crawl to finish");

        log.warning("(sleeping for 3 minutes)");
        Thread.sleep(3*60*1000);
    }

    public void setNoSSStart()
    {
       this.nostart = 1;
    }

    public void setSSStart()
    {
       this.nostart = 0;
    }

    private void doQueryOptSet(QuerySearch search)
    {
        if (this.OAggregateSetIt != false) {
           search.setAggregate(this.OAggregate);
        }
        if (this.OAggregateMPSetIt != false) {
           search.setAggregateMaxPasses(this.OAggregateMP);
        }
        if (this.numPerSourceSetIt != false) {
           search.setNumPerSource(this.numPerSource);
        }
        if (this.numOverRequestSetIt != false) {
           search.setNumOverRequest(this.numOverRequest);
        }
        if (this.fetchTimeOutSetIt != false) {
           search.setFetchTimeout(this.fetchTimeOut);
        }
        if (this.startSetIt != false) {
           search.setStart(this.start);
        }
        if (this.numSetIt != false) {
           search.setNum(this.num);
        }
        if (this.numMaxSetIt != false) {
           search.setNum(this.numMax);
        }
        if (this.OSummarySetIt != false) {
           search.setOutputSummary(this.OSummary);
        }
        if (this.OScoreSetIt != false) {
           search.setOutputScore(this.OScore);
        }
        if (this.OShinglesSetIt != false) {
           search.setOutputShingles(this.OShingles);
        }
        if (this.ODupsSetIt != false) {
           search.setOutputDuplicates(this.ODups);
        }
        if (this.OKeySetIt != false) {
           search.setOutputKey(this.OKey);
        }
        if (this.OCacheRefSetIt != false) {
           search.setOutputCacheReferences(this.OCacheRef);
        }
        if (this.OCacheDataSetIt != false) {
           search.setOutputCacheData(this.OCacheData);
        }
        if (this.OSortKeysSetIt != false) {
           search.setOutputSortKeys(this.OSortKeys);
        }
        if (this.OContentsSetIt != false) {
           search.setOutputContents(this.OContents);
        }
        if (this.OContentsModeSetIt != false) {
           search.setOutputContentsMode(this.OContentsMode);
        }
        if (this.QABinningStateSetIt != false) {
           search.setBinningState(this.QABinningState);
        }
        if (this.QABinningModeSetIt != false) {
           search.setBinningMode(this.QABinningMode);
        }
   
    }

    private void doSearchServiceCheckStart()
    {
        if (this.nostart == 0) {
           log.info("Checking search service status and restarting if needed");
           String sstat = this.searchServiceStatus();
           if (sstat.equals("stopped")) {
              log.info("Query service not running, starting.");
              this.searchServiceStart();
              sstat = this.searchServiceStatus();
              if (sstat.equals("stopped")) {
                 log.severe("Query service not running, could not start.");
                 return;
              }
           } else {
              log.info("Query service running");
           }
        }

        return;
    }

    public void setSearchSources(String sourcesString)
    {
       this.sourcesNames = sourcesString;
    }
    public void unsetSearchSources()
    {
       this.sourcesNames = null;
    }

    private QueryResults executeQuery(String myquery) throws java.lang.Exception
    {
        log.info("Running queries");

        if (myquery == null) {
           myquery = "";
        }

        this.doSearchServiceCheckStart();

        QuerySearch search = new QuerySearch();

        search.setAuthentication(this.auth);
        if (this.sourcesNames == null) {
           search.setSources(this.collectionName);
        } else {
           search.setSources(this.sourcesNames);
        }
        search.setQuery(myquery);
        this.doQueryOptSet(search);

        QuerySearchResponse response = this.p.querySearch(search);
        if (response == null) {
            log.severe("Response is null");
            return null;
        }

        QueryResults results = response.getQueryResults();
        if (results == null) {
            log.severe("Results is null");
            return null;
        }

        return results;
    }

    public int queryForContentCount(String myquery, 
                                    String contentName,
                                    boolean dumpData)
                           throws java.lang.Exception
    {

        int CountLines = 0;

        log.info("Searching for content item " + contentName);

        if (myquery == null) {
           myquery = "";
        }

        QueryResults results = this.executeQuery(myquery);
        if (results == null) {
            log.severe("Query result is null");
            return 0;
        }

        List list = results.getList();
        if (list == null) {
            log.severe("List is null");
            return 0;
        }

        java.util.List<velocity.objects.Document> docs = list.getDocument();
        if (docs == null) {
            log.severe("Document list is null");
            return 0;
        }

        for (velocity.objects.Document d : docs) {
           java.util.List<velocity.objects.Content> content = d.getContent();
           for (velocity.objects.Content c : content) {
              if (c.getName().equals(contentName)) {
                 if (dumpData == true) {
                    System.out.println("VALUE:  " + c.getValue());
                 }
                 CountLines = CountLines + 1;
              }
           }
        }

        return CountLines;
    }

    public void runQueries(String myquery, String qfile)
                           throws java.lang.Exception
    {

        if (myquery == null) {
           myquery = "";
        }

        if (qfile == null) {
           qfile = URLS_FILE;
        }

        log.info("Dump query urls to file " + qfile);

        QueryResults results = this.executeQuery(myquery);
        if (results == null) {
            log.severe("Query result is null");
            return;
        }

        List list = results.getList();
        if (list == null) {
            log.severe("List is null");
            return;
        }

        java.util.List<velocity.objects.Document> docs = list.getDocument();
        if (docs == null) {
            log.severe("Document list is null");
            return;
        }

        FileWriter url_file = new FileWriter(qfile);

        for (velocity.objects.Document d : docs) {
            url_file.write(d.getUrl() + "\n");
        }

        url_file.close();
    }

    public void stopIndexer(String dokill)
    {
        log.info("Stopping the indexer");

        this.killer = false;

        if (dokill != null) {
           if (dokill.equals("true")) {
              this.killer = true;
           }
        }

        SearchCollectionIndexerStop stop = new SearchCollectionIndexerStop();

        stop.setAuthentication(this.auth);
        stop.setCollection(this.collectionName);
        stop.setKill(this.killer);

        this.p.searchCollectionIndexerStop(stop);
    }

    public void startIndexer()
    {
        log.info("Starting the indexer");

        SearchCollectionIndexerStart stop = new SearchCollectionIndexerStart();

        stop.setAuthentication(this.auth);
        stop.setCollection(this.collectionName);

        this.p.searchCollectionIndexerStart(stop);
    }

    public void stopCrawl(String dokill)
    {
        log.info("Stopping the crawler");

        this.killer = false;

        if (dokill != null) {
           if (dokill.equals("true")) {
              this.killer = true;
           }
        }

        SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();

        stop.setAuthentication(this.auth);
        stop.setCollection(this.collectionName);
        stop.setKill(this.killer);

        this.p.searchCollectionCrawlerStop(stop);
    }

    public String waitForCrawlStatus(String wstatus, int count, int secs)
           throws java.lang.Exception
    {
        int exeter = 0;
        int mywait, i;
        int currcount = 0;
        String cstatus;
        String items[] = {null, null, null};
        StringTokenizer st = new StringTokenizer(wstatus, ",");

        i = 0;
        while (st.hasMoreTokens() && i < 3) {
           items[i] = st.nextToken();
           i = i + 1;
        }

        mywait = secs * 1000;

        log.info("Waiting for crawler status:" + wstatus);

        do {
           Thread.sleep(mywait);
           cstatus = this.crawlerStatus();
           log.info("   crawler status:" + cstatus);
           for (String statthing : items) {
              if (cstatus.equals(wstatus)) {
                 exeter = 1;
              }
           }
           currcount = currcount + 1;
           if ( currcount >= count) {
              exeter = 1;
           }
        } while (exeter == 0);

        return cstatus;

    }

    public String waitForIndexerStatus(String wstatus, int count, int secs)
           throws java.lang.Exception
    {
        int exeter = 0;
        int mywait, i;
        int currcount = 0;
        String cstatus;
        String items[] = {null, null, null};
        StringTokenizer st = new StringTokenizer(wstatus, ",");

        i = 0;
        while (st.hasMoreTokens() && i < 3) {
           items[i] = st.nextToken();
           i = i + 1;
        }

        mywait = secs * 1000;

        log.info("Waiting for indexer status:" + wstatus);

        do {
           Thread.sleep(mywait);
           cstatus = this.indexerStatus();
           log.info("   indexer status:" + cstatus);
           for (String statthing : items) {
              if (cstatus.equals(statthing)) {
                 exeter = 1;
              }
           }
           currcount = currcount + 1;
           if ( currcount >= count) {
              exeter = 1;
           }
        } while (exeter == 0);

        return cstatus;

    }

    public void killCollection(String dokill) throws java.lang.Exception
    {

        int mywait = 5 * 1000;

        log.info("Stopping the crawler and the indexer");

        if (dokill != null) {
           if (dokill.equals("true")) {
              mywait = 2 * 1000;
           }
        }

        stopCrawl(dokill);
        Thread.sleep(mywait);
        stopIndexer(dokill);
        Thread.sleep(mywait);
    }

    public void deleteCollection() throws java.lang.Exception
    {
        log.info("Deleting the collection");

        log.warning("Sleeping for 5 seconds to allow services to exit");
        Thread.sleep(5*1000);

        SearchCollectionDelete delete = new SearchCollectionDelete();

        delete.setAuthentication(this.auth);
        delete.setCollection(this.collectionName);

        this.p.searchCollectionDelete(delete);
    }

    public void dictCreate(String dname, String dbaseon)
    {
        log.info("Creating the dictionary");

        DictionaryCreate create = new DictionaryCreate();

        create.setAuthentication(this.auth);
        create.setBasedOn(dbaseon);
        create.setDictionary(dname);

        this.p.dictionaryCreate(create);
    }

    public void dictDelete(String dbname)
    {
        log.info("Deleting the dictionary");

        DictionaryDelete delete = new DictionaryDelete();

        delete.setAuthentication(this.auth);
        delete.setDictionary(dbname);

        this.p.dictionaryDelete(delete);
    }

    public void dictBuild(String dbname)
    {
        log.info("Building the dictionary");

        DictionaryBuild build = new DictionaryBuild();

        build.setAuthentication(this.auth);
        build.setDictionary(dbname);

        this.p.dictionaryBuild(build);
    }

    public String dictStatus(String dbname)
    {
        Element dictResp;
        Element srvStatElem = null;
        String thingName = null;
        String statusString = "broken";
        NodeList srvStatNode = null;

        log.info("Status of the dictionary");

        DictionaryStatusXml delete = new DictionaryStatusXml();

        delete.setAuthentication(this.auth);
        delete.setDictionary(dbname);

        try {
           DictionaryStatusXmlResponse resp = this.p.dictionaryStatusXml(delete);
           if (resp == null) {
              return null;
           }

           dictResp = (Element)resp.getAny();

           srvStatNode = dictResp.getElementsByTagName("dictionary-status");
           srvStatElem = (Element)srvStatNode.item(0);

           if (srvStatElem != null) {
              thingName = srvStatElem.getAttribute("status");
              if (thingName != null) {
                 statusString = thingName;
              }
           }

        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //prettyPrintSOAPFaultException(e);
              log.info("repositoryGet:  Item does not exist");
              return null;
           } else {
              throw e;
           }
        }

        return statusString;
    }

    public void dictStop(String dbname)
    {
        log.info("Stop building the dictionary");

        DictionaryStop build = new DictionaryStop();

        build.setAuthentication(this.auth);
        build.setDictionary(dbname);

        this.p.dictionaryStop(build);
    }

}
