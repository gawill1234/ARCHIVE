using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web.Services.Protocols;
using System.Xml;
using NUnit.Framework;
using log4net;
using log4net.Config;

namespace APITests
{
    [TestFixture]
    class SearchCollectionEnqueueXmlTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        const string ENQ_URL = "http://testbed4.test.vivisimo.com";
        string[] servers;

        [Test]
        public void SearchCollectionEnqueueXml_AdvancedContent()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            string collection = "SearchCollectionEnqueueXml_AdvancedContent";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueXml_AdvancedContent Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueueing data.");
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();

                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    crawlurl[] cus = new crawlurl[2];
                    cus[0] = new crawlurl();
                    cus[0].enqueuetype = crawlurlEnqueuetype.reenqueued;
                    cus[0].synchronization = crawlurlSynchronization.indexednosync;
                    cus[0].url = ENQ_URL;

                    String MY_CRAWL_URL = "myproto://doc?id=1";
                    cus[1] = new crawlurl();
                    cus[1].url = MY_CRAWL_URL;
                    cus[1].synchronization = crawlurlSynchronization.indexednosync;
                    cus[1].status = crawlurlStatus.complete;
                    cus[1].crawldata = new crawldata[1];
                    cus[1].crawldata[0] = new crawldata();
                    cus[1].crawldata[0].contenttype = "application/vxml-unnormalized";
                    cus[1].crawldata[0].encoding = crawldataEncoding.xml;
                    cus[1].crawldata[0].vxml = new crawldataVxml();
                    cus[1].crawldata[0].vxml.document = new document[2];
                    cus[1].crawldata[0].vxml.document[0] = new document();
                    cus[1].crawldata[0].vxml.document[0].content = new content[2];
                    cus[1].crawldata[0].vxml.document[0].content[0] = new content();
                    cus[1].crawldata[0].vxml.document[0].content[0].name = "email";
                    cus[1].crawldata[0].vxml.document[0].content[0].Value = "jeff.skilling@enron.com";

                    cus[1].crawldata[0].vxml.document[1] = new document();
                    cus[1].crawldata[0].vxml.document[1].content = new content[2];
                    cus[1].crawldata[0].vxml.document[1].content[0] = new content();
                    cus[1].crawldata[0].vxml.document[1].content[0].name = "email";
                    cus[1].crawldata[0].vxml.document[1].content[0].Value = "erin.me@enron.com";

                    cus[1].crawldata[0].vxml.advancedcontent = new advancedcontent[1];
                    cus[1].crawldata[0].vxml.advancedcontent[0] = new advancedcontent();
                    cus[1].crawldata[0].vxml.advancedcontent[0].vseindexstream = new vseindexstream[1];
                    cus[1].crawldata[0].vxml.advancedcontent[0].vseindexstream[0] = new vseindexstream();
                    cus[1].crawldata[0].vxml.advancedcontent[0].vseindexstream[0].vsetokenizer = new vsetokenizer();
                    cus[1].crawldata[0].vxml.advancedcontent[0].vseindexstream[0].vsetokenizer.name = vsetokenizerName.simple;
                    cus[1].crawldata[0].vxml.advancedcontent[0].vseindexstream[0].vsetokenizer.nameSpecified = true;
                    cus[1].crawldata[0].vxml.advancedcontent[0].vseindexstream[0].vsetokenizer.wordchars = "@.";
                    cus[1].crawldata[0].vxml.advancedcontent[0].vseindexstream[0].vsetokenizer.symbols = "_!&()*^~-=+[]\\;:',<>/?";


                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;


                    // Make call
                    logger.Info("Submitting enqueue request.");
                    enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, enqueueResponse.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, enqueueResponse.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, enqueueResponse.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");

                    // Verify results
                    logger.Info("Validating results.");
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "skilling@enron.com";

                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No results returned.");
                    Assert.AreEqual(1, qres.list.document.Length, "Incorrect results returned.");
                    Assert.AreEqual("email", qres.list.document[0].content[1].name,
                        "Expected result not returned.");
                    Assert.AreEqual("jeff.skilling@enron.com", qres.list.document[0].content[1].Value,
                        "Incorrect email address returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueXml_NoCrawlUrl()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            string collection = "SearchCollectionEnqueueXml_Defaults";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueXml_Defaults Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueueing data.");
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;
                    
                    // Make call
                    logger.Info("Submitting enqueue request.");
                    enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void SearchCollectionEnqueueXml_Defaults()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            string collection = "SearchCollectionEnqueueXml_Defaults";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueXml_Defaults Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueueing data.");
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();

                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    crawlurl[] cus = new crawlurl[2];
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;
                    cus[0] = new crawlurl();
                    cus[0].enqueuetype = crawlurlEnqueuetype.reenqueued;
                    cus[0].synchronization = crawlurlSynchronization.indexednosync;
                    cus[0].url = ENQ_URL;

                    String MY_CRAWL_URL = "myproto://doc?id=1";
                    cus[1] = new crawlurl();
                    cus[1].url = MY_CRAWL_URL;
                    cus[1].synchronization = crawlurlSynchronization.indexednosync;
                    cus[1].status = crawlurlStatus.complete;
                    cus[1].crawldata = new crawldata[2];
                    cus[1].crawldata[0] = new crawldata();
                    cus[1].crawldata[0].contenttype = "text/html";
                    cus[1].crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";

                    cus[1].crawldata[1] = new crawldata();
                    cus[1].crawldata[1].contenttype = "application/vxml";
                    cus[1].crawldata[1].vxml = new crawldataVxml();
                    document[] doc = new document[1];
                    cus[1].crawldata[1].vxml.document = doc;
                    doc[0] = new document();
                    doc[0].content = new content[2];
                    doc[0].content[0] = new content();
                    doc[0].content[0].name = "field1";
                    doc[0].content[0].Value = "My first field";
                    doc[0].content[1] = new content();
                    doc[0].content[1].name = "field2";
                    doc[0].content[1].Value = "My second field";


                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;


                    // Make call
                    logger.Info("Submitting enqueue request.");
                    enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, enqueueResponse.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, enqueueResponse.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, enqueueResponse.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");

                    // validate results
                    logger.Info("Validating results.");
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "DOCUMENT:\"" + ENQ_URL + "\"";

                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No results returned.");
                    Assert.IsTrue(qres.list.document[0].url == ENQ_URL,
                        "Expected result {0} not returned.  Result returned: {1}", ENQ_URL, qres.list.document[0].url);

                    qs.query = "DOCUMENT:\"" + MY_CRAWL_URL + "\"";
                    qsr = service.QuerySearch(qs);
                    qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No results returned.");
                    Assert.IsTrue(qres.list.document[0].url == MY_CRAWL_URL,
                        "Expected result {0} not returned.  Result returned: {1}", MY_CRAWL_URL, qres.list.document[0].url);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        [Test]
        public void SearchCollectionEnqueueXml_EnqueueForced()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            string collection = "SearchCollectionEnqueueXml_EnqueueForced";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueXml_EnqueueForced Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueueing data.");
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();

                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    crawlurl[] cus = new crawlurl[2];
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;
                    cus[0] = new crawlurl();
                    cus[0].enqueuetype = crawlurlEnqueuetype.forced;
                    cus[0].synchronization = crawlurlSynchronization.indexednosync;
                    cus[0].url = ENQ_URL;

                    String MY_CRAWL_URL = "myproto://doc?id=1";
                    cus[1] = new crawlurl();
                    cus[1].url = MY_CRAWL_URL;
                    cus[1].synchronization = crawlurlSynchronization.indexednosync;
                    cus[1].status = crawlurlStatus.complete;
                    cus[1].crawldata = new crawldata[2];
                    cus[1].crawldata[0] = new crawldata();
                    cus[1].crawldata[0].contenttype = "text/html";
                    cus[1].crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";

                    cus[1].crawldata[1] = new crawldata();
                    cus[1].crawldata[1].contenttype = "application/vxml";
                    cus[1].crawldata[1].vxml = new crawldataVxml();
                    document[] doc = new document[1];
                    cus[1].crawldata[1].vxml.document = doc;
                    doc[0] = new document();
                    doc[0].content = new content[2];
                    doc[0].content[0] = new content();
                    doc[0].content[0].name = "field1";
                    doc[0].content[0].Value = "My first field";
                    doc[0].content[1] = new content();
                    doc[0].content[1].name = "field2";
                    doc[0].content[1].Value = "My second field";


                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;


                    // Make call
                    logger.Info("Submitting enqueue request.");
                    enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, enqueueResponse.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, enqueueResponse.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, enqueueResponse.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");

                    // validate results
                    logger.Info("Validating results.");
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "DOCUMENT:\"" + ENQ_URL + "\"";

                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No results returned.");
                    Assert.AreEqual(ENQ_URL, qres.list.document[0].url,
                        "Expected result {0} not returned.  Result returned: {1}", ENQ_URL, qres.list.document[0].url);

                    qs.query = "DOCUMENT:\"" + MY_CRAWL_URL + "\"";
                    qsr = service.QuerySearch(qs);
                    qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No results returned.");
                    Assert.AreEqual(MY_CRAWL_URL, qres.list.document[0].url,
                        "Expected result {0} not returned.  Result returned: {1}", MY_CRAWL_URL, qres.list.document[0].url);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueXml_EnqueueExport()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            string collection = "SearchCollectionEnqueueXml_EnqueueExport";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueXml_EnqueueExport Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueueing data.");
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();

                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    crawlurl[] cus = new crawlurl[2];
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;
                    cus[0] = new crawlurl();
                    cus[0].enqueuetype = crawlurlEnqueuetype.export;
                    cus[0].synchronization = crawlurlSynchronization.indexednosync;
                    cus[0].url = ENQ_URL;

                    String MY_CRAWL_URL = "myproto://doc?id=1";
                    cus[1] = new crawlurl();
                    cus[1].url = MY_CRAWL_URL;
                    cus[1].synchronization = crawlurlSynchronization.indexednosync;
                    cus[1].status = crawlurlStatus.complete;
                    cus[1].crawldata = new crawldata[2];
                    cus[1].crawldata[0] = new crawldata();
                    cus[1].crawldata[0].contenttype = "text/html";
                    cus[1].crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";

                    cus[1].crawldata[1] = new crawldata();
                    cus[1].crawldata[1].contenttype = "application/vxml";
                    cus[1].crawldata[1].vxml = new crawldataVxml();
                    document[] doc = new document[1];
                    cus[1].crawldata[1].vxml.document = doc;
                    doc[0] = new document();
                    doc[0].content = new content[2];
                    doc[0].content[0] = new content();
                    doc[0].content[0].name = "field1";
                    doc[0].content[0].Value = "My first field";
                    doc[0].content[1] = new content();
                    doc[0].content[1].name = "field2";
                    doc[0].content[1].Value = "My second field";


                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;


                    // Make call
                    logger.Info("Submitting enqueue request.");
                    enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, enqueueResponse.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, enqueueResponse.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, enqueueResponse.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void SearchCollectionEnqueueXml_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            string collection = "SearchCollectionEnqueueXml_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueXml_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueueing data.");
                    enqueue.collection = collection;
                    enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();

                    crawlurl url = new crawlurl();
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.indexednosync;
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;


                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }            
        }

        [Test]
        public void SearchCollectionEnqueueXml_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            string collection = "SearchCollectionEnqueueXml_NoCollection";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueXml_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueueing data.");
                    enqueue.authentication = auth;

                    crawlurl url = new crawlurl();
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.indexednosync;
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;


                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        [Test]
        public void SearchCollectionEnqueueXml_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            string collection = "SearchCollectionEnqueueXml_CollectionNotExist";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueXml_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection

                    logger.Info("Enqueueing data.");
                    enqueue.authentication = auth;
                    enqueue.collection = collection;

                    crawlurl url = new crawlurl();
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.indexednosync;
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;


                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.AreEqual("The exception [search-collection-invalid-name] was thrown.", se.Message,
                        "Incorrect exception thrown.");
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }


        [Test]
        public void SearchCollectionEnqueueXml_NoCrawlNodes()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            string collection = "SearchCollectionEnqueueXml_NoCrawlNodes";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueXml_NoCrawlNodes Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueueing data.");
                    enqueue.authentication = auth;

                    crawlurl url = new crawlurl();
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.indexednosync;
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }
    }
}
