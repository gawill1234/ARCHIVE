
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
import java.math.BigInteger;

import java.net.URL;
import javax.xml.namespace.QName;

import java.util.logging.*;
import java.util.StringTokenizer;
import java.util.Set;
import java.util.HashSet;

public class vServices
{

    private static final String COLLECTION_NAME_DEFAULT = "test-suite-collection";
    private static final String WSDL_CGI_PARAMS = "?v.app=api-soap&wsdl=1&specialize-for=&use-types=true";
    private static final String URLS_FILE = "urls.txt";

    private static Logger log = Logger.getLogger(vServices.class.getName());

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
    private int maximumTime = 0;
    private int idxMSz = 0;
    private int mrgMSz = 0;
    private long idxTtlSz = 0;
    private long mrgTtlSz = 0;
    private boolean itChanged = false;

    private ENVIRONMENT srvEnv;
    private VelocityPort p;
    private Authentication auth;
    private boolean killer = false;
    public boolean testHadError = false;
    private Set ctSet;

    public vServices(String url, String collectionName) throws java.lang.Exception
    {

       envInit();
       commonInit(url, collectionName);

    }

    public vServices(String collectionName) throws java.lang.Exception
    {

       envInit();
       commonInit(this.srvEnv.getVelocityUrl(), collectionName);

    }

    private void envInit() {

        this.auth = new Authentication();

        this.srvEnv = new ENVIRONMENT();
        this.setUser(this.srvEnv.getVivUser());
        this.setPassword(this.srvEnv.getVivPassword());

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


        initValidCrawlTypes();
    }

    private void initValidCrawlTypes() {

       this.ctSet = new HashSet();

       this.ctSet.add("new");
       this.ctSet.add("resume");
       this.ctSet.add("resume-and-idle");
       this.ctSet.add("refresh-new");
       this.ctSet.add("refresh-inplace");
       this.ctSet.add("apply-changes");

    }

    public void TestIt()
    {
       System.out.println("Hello World");
    }

    public void setSubcollection(String subc)
    {
        this.subcollection = subc;
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

    public BigInteger crawlerNErrors()
    {

        VseStatus vses = collectionServiceStatus();
        if ( vses != null ) {
           CrawlerStatus vseis = vses.getCrawlerStatus();
           BigInteger oVal = vseis.getNErrors();
           return oVal;
        } else {
           return new BigInteger("0");
        }

    }

    public BigInteger crawlerNOutput()
    {

        VseStatus vses = collectionServiceStatus();
        if ( vses != null ) {
           CrawlerStatus vseis = vses.getCrawlerStatus();
           BigInteger oVal = vseis.getNOutput();
           return oVal;
        } else {
           return new BigInteger("0");
        }

    }

    public Integer crawlerNPending()
    {

        VseStatus vses = collectionServiceStatus();
        if ( vses != null ) {
           CrawlerStatus vseis = vses.getCrawlerStatus();
           Integer oVal = vseis.getNPending();
           return oVal;
        } else {
           return 0;
        }

    }

    public Integer crawlerNDuplicates()
    {

        VseStatus vses = collectionServiceStatus();
        if ( vses != null ) {
           CrawlerStatus vseis = vses.getCrawlerStatus();
           Integer oVal = vseis.getNDuplicates();
           return oVal;
        } else {
           return 0;
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


    private void idxMrgProgress() {

       Set<String> mrgGruber = null;
       Set<String> idxGruber = null;
       String fileName = null;
       int currentTime, oldMaxTime, mrgCnt, idxCnt;
       int currentSize, idxMaxSize, mrgMaxSize;
       long idxTotalSize, mrgTotalSize;

       currentTime = 0;
       oldMaxTime = this.maximumTime;

       idxMaxSize = this.idxMSz;
       mrgMaxSize = this.mrgMSz;
       currentSize = 0;
       idxCnt = mrgCnt = 0;
       idxTotalSize = mrgTotalSize = 0;

       GRONK zz = new GRONK();

       //
       //   Get the crawl directory for the crawl.
       //
       String crawlDir = zz.getCollectionCrawlDirectory(this.collectionName);

       //
       //   Get the list of merge files for the collection
       //   Get the list of index files for the collection
       //
       mrgGruber = zz.grnkGetCollectionIndexMergeFileList(this.collectionName);
       idxGruber = zz.grnkGetCollectionIndexFileList(this.collectionName);

       //
       //  Some brief explanation of the output.
       //
       System.out.println("==================================");
       System.out.println("   TRACK MERGE FILES WHICH HAVE CHANGED DURING THE MERGE.");
       System.out.println("      (mrg) means a file created to manage the merge");
       System.out.println("      (idx) means one of the new index files");

       //
       //  Get the size and time data for the merge files.  Keep track
       //  of the largest of each.
       //
       for (String cN : mrgGruber) {
          mrgCnt += 1;
          fileName = crawlDir + "/" + cN;
          currentSize = zz.fileSize(fileName);
          mrgTotalSize = mrgTotalSize + currentSize;
          if (currentSize > mrgMaxSize) {
             this.mrgMSz = currentSize;
          }
          currentTime = zz.fileTime(fileName);
          if (currentTime > maximumTime) {
             this.maximumTime = currentTime;
             System.out.println("               Changed file(mrg):  " + cN + ", " + currentSize);
          }
       }

       //
       //  Get the size and time data for the index files.  Keep track
       //  of the largest of each.
       //
       for (String cN : idxGruber) {
          idxCnt += 1;
          fileName = crawlDir + "/" + cN;
          currentSize = zz.fileSize(fileName);
          idxTotalSize = idxTotalSize + currentSize;
          if (currentSize > idxMaxSize) {
             this.idxMSz = currentSize;
          }
          currentTime = zz.fileTime(fileName);
          if (currentTime > maximumTime) {
             this.maximumTime = currentTime;
             System.out.println("               Changed file(idx):  " + cN + ", " + currentSize);
          }
       }

       if (mrgCnt == 0 && idxCnt == 0) {
          return;
       }

       //
       //   Dump the current data as compared to the last pass
       //
       System.out.println("        ------");
       System.out.println("    MAX FILE SIZE  -  MERGE:  " + this.mrgMSz);
       System.out.println("    MAX FILE SIZE  -  INDEX:  " + this.idxMSz);
       System.out.println("        ------");
       System.out.println("    TOTAL FILE SIZE - MERGE(last):  " + this.mrgTtlSz);
       System.out.println("    TOTAL FILE SIZE - MERGE(curr):  " + mrgTotalSize);
       System.out.println("        ------");
       System.out.println("    TOTAL FILE SIZE - INDEX(last):  " + this.idxTtlSz);
       System.out.println("    TOTAL FILE SIZE - INDEX(curr):  " + idxTotalSize);
       System.out.println("        ------");
       System.out.println("    FILE COUNT -  MERGE:  " + mrgCnt);
       System.out.println("    FILE COUNT -  INDEX:  " + idxCnt);
       System.out.println("        ------");
       System.out.println("    TIMESTAMP - OLD MAX:  " + oldMaxTime);
       System.out.println("    TIMESTAMP - NEW MAX:  " + this.maximumTime);
       System.out.println("        ------");

       //
       //   Statements of what changed and what did not.
       //
       if (this.maximumTime != oldMaxTime) {
          this.itChanged = true;
          System.out.println("    SUCCESS:  Merge made some progress");
       } else {
          this.itChanged = false;
          System.out.println("    WARNING:  Merge is making no progress");
          System.out.println("              No (mrg) or (idx) to show");
       }

       System.out.println("==================================");

       this.idxTtlSz = idxTotalSize;
       this.mrgTtlSz = mrgTotalSize;

       return;

    }

    public void waitForIdle() throws java.lang.Exception
    {
       String cstat = null;
       String istat = null;

       log.info("Wait for crawler and indexer to be idle");
       int idlecount = 0;
       int mrgcount = 0;

       Thread.sleep(4*1000);

       //
       //   While the crawl is ongoing ...
       //
       do {
          //
          //   ... sleep for a second.
          //
          Thread.sleep(1*1000);
          //
          //   Get the current crawler and indexer status
          //
          cstat = crawlerStatus();
          istat = indexerStatus();
          //
          //   If the crawler is done ...
          //
          if (cstat.equals("idle") || cstat.equals("stopped")) {
             //
             //   ... and the indexer is done ...
             //
             if (istat.equals("idle") || istat.equals("stopped")) {
                //
                //   ... print an idle message.
                //
                idlecount = idlecount + 1;
                System.out.println("Crawler and indexer are idle, " + idlecount + " of 3 checks");
             //
             //   ... but the indexer is not done ...
             //
             } else {
                //
                //   ... check the merge status of the indexer.
                //
                mrgcount += 1;
                idxMrgProgress();
                //
                //   ... if the merge has made progress ...
                //
                if (this.itChanged) {
                   //
                   //   ... reset the merge counter
                   //
                   mrgcount = 0;
                //
                //   ... if the merge has made NO progress ...
                //
                } else {
                   //
                   //   ... print no pass progress.
                   //
                   System.out.println("NO PROGRESS PASSES:  " + mrgcount);
                   System.out.println("   TEST WILL EXIT AT 151");
                   //
                   //   If there has been no progress for 150 iterations
                   //
                   if (mrgcount > 150) {
                      //
                      //   Exit.  The merge portion is hung or making no
                      //   progess.
                      //
                      System.out.println("    Collection merge is hung.");
                      System.out.println("    Bailing out of the entire run.");
                      System.exit(99);
                   }
                }
                idlecount = 0;
             }
          } else {
             idlecount = 0;
             idxMrgProgress();
          }
       } while (idlecount < 3);
       System.out.println("Crawler and indexer are idle.");
    }

    private boolean isValidCrawlType(String crawlType) {

       return(this.ctSet.contains(crawlType));

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

        if (isValidCrawlType(crawlType)) {

           SearchCollectionCrawlerStart start =
                 new SearchCollectionCrawlerStart();

           start.setAuthentication(this.auth);
           start.setCollection(this.collectionName);
           start.setSubcollection(this.subcollection);

           start.setType(crawlType);

           try {
              this.p.searchCollectionCrawlerStart(start);
           } catch (javax.xml.ws.soap.SOAPFaultException e) {
              System.out.println("Could not start crawl using crawl type " + crawlType);
           }
        }
    }

    public void restartCrawl()
    {
        log.info("Restarting the crawler");

        SearchCollectionCrawlerRestart start = new SearchCollectionCrawlerRestart();

        start.setAuthentication(this.auth);
        start.setCollection(this.collectionName);
        if (this.subcollection.equals("live") ||
            this.subcollection.equals("staging")) {
           start.setSubcollection(this.subcollection);
        }

        this.p.searchCollectionCrawlerRestart(start);
    }

    public void restartIndexer()
    {
        log.info("Restarting the Indexer");

        SearchCollectionIndexerRestart start = new SearchCollectionIndexerRestart();

        start.setAuthentication(this.auth);
        start.setCollection(this.collectionName);
        if (this.subcollection.equals("live") ||
            this.subcollection.equals("staging")) {
           start.setSubcollection(this.subcollection);
        }

        this.p.searchCollectionIndexerRestart(start);
    }

    public void collectionClean()
    {
        log.info("Cleaning the collection");

        SearchCollectionClean flushit = new SearchCollectionClean();

        flushit.setAuthentication(this.auth);
        flushit.setCollection(this.collectionName);
        if (this.subcollection.equals("live") ||
            this.subcollection.equals("staging")) {
            flushit.setSubcollection(this.subcollection);
        }

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
              //log.info("repositoryGet:  Item does not exist");
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
              //log.info("repositoryGet:  Item does not exist");
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

        //log.info("Setting the search service port");

        vsNode = this.searchServiceGetVseQs();
        vsOptNode = vsNode.getVseQsOption();

        vsOptNode.setPort(myport);
        vsOptNode.setAllowIps("*");
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
              //log.info("repositoryGet:  Item does not exist");
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

    private void doSearchServiceCheckStart()
    {
        if (this.nostart == 0) {
           //log.info("Checking search service status and restarting if needed");
           String sstat = this.searchServiceStatus();
           if (sstat.equals("stopped")) {
              //log.info("Query service not running, starting.");
              this.searchServiceStart();
              sstat = this.searchServiceStatus();
              if (sstat.equals("stopped")) {
                 log.severe("Query service not running, could not start.");
                 return;
              }
           } else {
              //log.info("Query service running");
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
        if (this.subcollection.equals("live") ||
            this.subcollection.equals("staging")) {
            stop.setSubcollection(this.subcollection);
        }

        this.p.searchCollectionIndexerStop(stop);
    }

    public void startIndexer()
    {
        log.info("Starting the indexer");

        SearchCollectionIndexerStart stop = new SearchCollectionIndexerStart();

        stop.setAuthentication(this.auth);
        stop.setCollection(this.collectionName);
        if (this.subcollection.equals("live") ||
            this.subcollection.equals("staging")) {
            stop.setSubcollection(this.subcollection);
        }

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
        if (this.subcollection.equals("live") ||
            this.subcollection.equals("staging")) {
            stop.setSubcollection(this.subcollection);
        }

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
           //log.info("   crawler status:" + cstatus);
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
           //log.info("   indexer status:" + cstatus);
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

}
