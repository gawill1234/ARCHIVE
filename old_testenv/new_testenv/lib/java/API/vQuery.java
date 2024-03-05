
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

import java.io.*;

import java.net.URL;
import javax.xml.namespace.QName;

import java.util.Set;
import java.util.HashSet;
import java.util.logging.*;
import java.util.StringTokenizer;

public class vQuery
{
    private static final String COLLECTION_NAME_DEFAULT = "test-suite-collection";
    private static final String WSDL_CGI_PARAMS = "?v.app=api-soap&wsdl=1&specialize-for=&use-types=true";
    private static final String URLS_FILE = "urls.txt";

    private static Logger log = Logger.getLogger(vQuery.class.getName());

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

    //
    //   Output query parameter items
    //
    private boolean OSummary = false;
    private boolean OSummarySetIt = false;

    private String QABinningState = null;
    private boolean QABinningStateSetIt = false;

    private String QABinningMode = null;
    private boolean QABinningModeSetIt = false;

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

    private String origUrl;
    private String url;
    private String collectionName;
    private String lastQuery;
    private String sourcesNames = null;
    private String CONFIG_FILENAME;

    private int nostart = 0;
    private long elapsedTimeMillis;

    private vSourceCollection vQuerySrc;
    private ENVIRONMENT vQueryEnv;;
    private VelocityPort p;
    private Authentication auth;
    private boolean killer = false;
    public boolean testHadError = false;

    public vQuery(String url, String collectionName) throws java.lang.Exception
    {
       envInit();
       commonInit(url, collectionName);
    }

    public vQuery(String collectionName) throws java.lang.Exception
    {
       envInit();
       commonInit(this.vQueryEnv.getVelocityUrl(), collectionName);
    }

    private void envInit() {

        this.auth = new Authentication();

        this.vQueryEnv = new ENVIRONMENT();
        this.setUser(this.vQueryEnv.getVivUser());
        this.setPassword(this.vQueryEnv.getVivPassword());
    }

    public void commonInit(String url, String collectionName) throws java.lang.Exception
    {
        //log.info("Created a new test object");

        this.origUrl = url;
        this.url = url + WSDL_CGI_PARAMS;
        //this.url = url;
        this.collectionName = collectionName;
        this.CONFIG_FILENAME = collectionName + ".xml";

        //log.info("Using \"" + this.url + "\"");

        URL wsdlLocation = new URL(this.url);
        QName serviceName = new QName("urn:/velocity", "VelocityService");

        VelocityService s = new VelocityService(wsdlLocation, serviceName);
        this.p = s.getVelocityPort();

        this.vQuerySrc = new vSourceCollection(url, collectionName);

    }

    public String getCollectionName() {
       return(this.collectionName);
    }

    public String getLastQuery() {
       return(this.lastQuery);
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
        if (this.QABinningModeSetIt != false) {
           search.setBinningMode(this.QABinningMode);
        }
        if (this.QABinningStateSetIt != false) {
           search.setBinningState(this.QABinningState);
        }
   
    }

    public void setSearchSources(String sourcesString)
    {
       this.sourcesNames = sourcesString;
    }

    //
    //   Introduced the reset because doing that is MUCH faster than
    //   rebuilding the entire object for subsequent queries.
    //
    public void reset() {
       this.lastQuery = null;
       this.QABinningState = null;
       this.QABinningStateSetIt = false;
    }

    

    private QueryResults executeQuery(String myquery) throws java.lang.Exception
    {
        //log.info("Running queries");

        if (myquery == null) {
           myquery = "";
        }

        //
        //  Try this.  If we are running with a binning state, queries
        //  should be empty or we will get some odd stuff.
        //
        if (this.QABinningStateSetIt) {
           this.lastQuery = this.QABinningState;
        } else {
           this.lastQuery = myquery;
        }

        //this.doSearchServiceCheckStart();

        QuerySearch search = new QuerySearch();

        search.setAuthentication(this.auth);
        if (this.sourcesNames == null) {
           search.setSources(this.collectionName);
        } else {
           search.setSources(this.sourcesNames);
        }
        search.setQuery(myquery);
        this.doQueryOptSet(search);

        // Get current time
        long start = System.currentTimeMillis();

        // Do the query
        QuerySearchResponse response = this.p.querySearch(search);

        long end = System.currentTimeMillis();
        // Get elapsed time in milliseconds
        this.elapsedTimeMillis = end - start;

        if (response == null) {
            //log.severe("Response is null");
            return null;
        }

        QueryResults results = response.getQueryResults();
        if (results == null) {
            //log.severe("Results is null");
            return null;
        }

        return results;
    }

    public long getElapsedTimeInMillis() {
       return(this.elapsedTimeMillis);
    }

    public float getElapsedTimeInSeconds() {
       return(this.elapsedTimeMillis/1000F);
    }

    public String getDocumentAttribute(velocity.objects.Document d,
                                       String docAttrib) 
    {
        if ( docAttrib.equals("url") ) {
           return(d.getUrl());
        } else if ( docAttrib.equals("vsekey") ) {
           return(d.getVseKey());
        } else if ( docAttrib.equals("source") ) {
           return(d.getSource());
        } else if ( docAttrib.equals("headers") ) {
           return(d.getHeaders());
        } else if ( docAttrib.equals("id") ) {
           return(d.getId());
        } else if ( docAttrib.equals("rank") ) {
           return(d.getRank());
        } else {
           return(d.getUrl());
        }
    }

    public int countQueryDocument(QueryResults results,
                                    String docAttrib)
                           throws java.lang.Exception
    {

        //log.info("Searching for content item " + docAttrib);

        if (results == null) {
            //log.severe("Query result is null");
            return(0);
        }

        List list = results.getList();
        if (list == null) {
            //log.severe("List is null");
            return(0);
        }

        java.util.List<velocity.objects.Document> docs = list.getDocument();
        if (docs == null) {
            //log.severe("Document list is null");
            return(0);
        }

        return(docs.size());
    }

    public Set extractQueryDocument(QueryResults results,
                                    String docAttrib)
                           throws java.lang.Exception
    {

        Set<String> contentSet = new HashSet<String>(this.numMax);

        //log.info("Searching for content item " + docAttrib);

        if (results == null) {
            //log.severe("Query result is null");
            return(null);
        }

        List list = results.getList();
        if (list == null) {
            //log.severe("List is null");
            return(null);
        }

        java.util.List<velocity.objects.Document> docs = list.getDocument();
        if (docs == null) {
            //log.severe("Document list is null");
            return(null);
        }

        for (velocity.objects.Document d : docs) {
           contentSet.add(getDocumentAttribute(d, docAttrib));
        }

        return(contentSet);
    }

    public String getContentByName(velocity.objects.Content c, String contentName)
    {

       if (c.getName().equals(contentName)) {
          return(c.getValue());
       }

       return(null);

    }

    public Set extractQueryContent(QueryResults results,
                                   String contentName)
                           throws java.lang.Exception
    {

        Set<String> contentSet = new HashSet<String>(this.numMax);

        //log.info("Searching for content item " + contentName);

        if (results == null) {
            //log.severe("Query result is null");
            return(null);
        }

        List list = results.getList();
        if (list == null) {
            //log.severe("List is null");
            return(null);
        }

        java.util.List<velocity.objects.Document> docs = list.getDocument();
        if (docs == null) {
            //log.severe("Document list is null");
            return(null);
        }

        for (velocity.objects.Document d : docs) {
           java.util.List<velocity.objects.Content> content = d.getContent();
           for (velocity.objects.Content c : content) {
              if (c.getName().equals(contentName)) {
                 contentSet.add(c.getValue());
              }
           }
        }

        return(contentSet);
    }


    public int queryForContentCount(QueryResults results,
                                   String contentName,
                                   boolean dumpData)
                           throws java.lang.Exception
    {

        int CountLines = 0;

        //log.info("Searching for content item " + contentName);

        if (results == null) {
            //log.severe("Query result is null");
            return 0;
        }

        List list = results.getList();
        if (list == null) {
            //log.severe("List is null");
            return 0;
        }

        java.util.List<velocity.objects.Document> docs = list.getDocument();
        if (docs == null) {
            //log.severe("Document list is null");
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

    public QueryResults getQueryObject(String myquery)
                        throws java.lang.Exception
    {

        QueryResults results = null;

        if (myquery == null) {
           myquery = "";
        }

        if (this.vQuerySrc.collectionExists()) {
           results = this.executeQuery(myquery);
        }
    
        return(results);
    }

    public QueryResults runQueries(String myquery, String qfile) throws java.lang.Exception
    {

        QueryResults results = null;
        System.out.println("Executing Query:  " + myquery);

        if (myquery == null) {
           myquery = "";
        }

        if (qfile == null) {
           qfile = URLS_FILE;
        }

        //log.info("Dump query urls to file " + qfile);

        if (this.vQuerySrc.collectionExists()) {
           results = this.executeQuery(myquery);
        }
        if (results == null) {
            //log.severe("Query result is null");
            return(null);
        }

        List list = results.getList();
        if (list == null) {
            //log.severe("List is null");
            return(null);
        }

        java.util.List<velocity.objects.Document> docs = list.getDocument();
        if (docs == null) {
            //log.severe("Document list is null");
            return(null);
        }

        FileWriter url_file = new FileWriter(qfile);

        for (velocity.objects.Document d : docs) {
            url_file.write(d.getUrl() + "\n");
        }

        url_file.close();

        return(results);
    }

}
