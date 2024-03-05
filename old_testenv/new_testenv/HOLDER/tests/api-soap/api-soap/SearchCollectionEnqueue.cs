using System;
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
    class SearchCollectionEnqueueTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        const string ENQ_URL = "http://testbed4.test.vivisimo.com";
        string[] servers;

        [Test]
        public void SearchCollectionEnqueue_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_Default";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_Default Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
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
                    cus[1].crawldata = new crawldata[3];
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

                    cus[1].crawldata[2] = new crawldata();
                    byte[] binarydata = new byte[4] { 98, 97, 100, 0 };
                    cus[1].crawldata[2].base64 = System.Convert.ToBase64String(binarydata);
                    cus[1].crawldata[2].contenttype = "text/plain";

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;
                    enqueue.crawlurls.crawlurl = cus;

                    // Make call
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
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
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueue_CrawlTypeResume()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_CrawlTypeResume";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_CrawlTypeResume Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
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
                    cus[1].crawldata = new crawldata[3];
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

                    cus[1].crawldata[2] = new crawldata();
                    byte[] binarydata = new byte[4] { 98, 97, 100, 0 };
                    cus[1].crawldata[2].base64 = System.Convert.ToBase64String(binarydata);
                    cus[1].crawldata[2].contenttype = "text/plain";

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;
                    enqueue.crawlurls.crawlurl = cus;
                    enqueue.crawltype = SearchCollectionEnqueueCrawltype.resume;

                    // Make call
                    logger.Info("Enqueueing data");
                    response = service.SearchCollectionEnqueue(enqueue);
                    logger.Info("Validating response"); 
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
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
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueue_CrawlTypeResumeandIdle()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_CrawlTypeResumeandIdle";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_CrawlTypeResumeandIdle Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
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
                    cus[1].crawldata = new crawldata[3];
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

                    cus[1].crawldata[2] = new crawldata();
                    byte[] binarydata = new byte[4] { 98, 97, 100, 0 };
                    cus[1].crawldata[2].base64 = System.Convert.ToBase64String(binarydata);
                    cus[1].crawldata[2].contenttype = "text/plain";

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;
                    enqueue.crawlurls.crawlurl = cus;
                    enqueue.crawltype = SearchCollectionEnqueueCrawltype.resumeandidle;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    logger.Info("Validating response.");
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
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
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueue_AdvancedContent_Email()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_AdvancedContent_Email";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_AdvancedContent_Email Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
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
                    enqueue.exceptiononfailure = true;
                    enqueue.crawlurls.crawlurl = cus;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
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
        public void SearchCollectionEnqueue_AdvancedContent_Reenqueue()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_AdvancedContent_Reenqueue";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_AdvancedContent_Reenqueue Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
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
                    cus[1].crawldata[0].vxml.document[0].content[0].Value = "jeff-skilling-enron-com";

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
                    cus[1].crawldata[0].vxml.advancedcontent[0].vseindexstream[0].vsetokenizer.wordchars = "-";
                    cus[1].crawldata[0].vxml.advancedcontent[0].vseindexstream[0].vsetokenizer.symbols = "@.!&()*^~-=+[]\\;:',<>/?";

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;
                    enqueue.crawlurls.crawlurl = cus;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");

                    // Verify results
                    logger.Info("Validating results.");
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "erin.me@enron.com";

                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No Results returned.  Query: erin.me@enron.com");
                    Assert.AreEqual("email", qres.list.document[0].content[1].name, "Content not correct.");

                    QuerySearch qs2 = new QuerySearch();
                    qs2.authentication = auth;
                    qs2.sources = collection;
                    qs2.query = "jeff-skilling";

                    QuerySearchResponse qsr2 = service.QuerySearch(qs2);
                    queryresults qres2 = qsr2.queryresults;

                    Assert.IsTrue(qres2.list != null, "No results returned. Query: jeff-skilling");
                    Assert.AreEqual(1, qres2.list.document.Length, "Incorrect results returned.");
                    Assert.AreEqual("email", qres2.list.document[0].content[1].name,
                        "Expected result not returned.");
                    Assert.AreEqual("jeff-skilling-enron-com", qres2.list.document[0].content[1].Value,
                        "Incorrect email address returned.");

                    QuerySearch qs3 = new QuerySearch();
                    qs3.authentication = auth;
                    qs3.sources = collection;
                    qs3.query = "jeff";

                    QuerySearchResponse qsr3 = service.QuerySearch(qs3);
                    queryresults qres3 = qsr3.queryresults;

                    Assert.IsTrue(qres3.list != null, "No results returned. Query: jeff");
                    Assert.AreEqual(1, qres3.list.document.Length, "Incorrect results returned.");
                    Assert.AreEqual("email", qres3.list.document[0].content[1].name,
                        "Expected result not returned.");
                    Assert.AreEqual("jeff-skilling-enron-com", qres3.list.document[0].content[1].Value,
                        "Incorrect email address returned.");


                    // Reenqueue data
                    cus[1].crawldata[0].vxml.document[1].content[0].name = "test change";
                    cus[1].enqueuetype = crawlurlEnqueuetype.reenqueued;
                    
                    logger.Info("Submitting re-enqueue request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");

                    // Verify results
                    logger.Info("Validating results.");

                    qsr = service.QuerySearch(qs);
                    qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No Results returned.  Query: erin.me@enron.com");
                    Assert.AreEqual("test change", qres.list.document[0].content[1].name, "Content not updated.");

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
        public void SearchCollectionEnqueue_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_CollectionNotExist";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    crawlurl[] cus = new crawlurl[2];
                    enqueue.crawlurls.crawlurl = cus;
                    cus[0] = new crawlurl();
                    cus[0].enqueuetype = crawlurlEnqueuetype.reenqueued;
                    cus[0].synchronization = crawlurlSynchronization.indexednosync;
                    cus[0].url = ENQ_URL;

                    String MY_CRAWL_URL = "myproto://doc?id=1";
                    cus[1] = new crawlurl();
                    cus[1].url = MY_CRAWL_URL;
                    cus[1].synchronization = crawlurlSynchronization.indexednosync;
                    cus[1].status = crawlurlStatus.complete;
                    cus[1].crawldata = new crawldata[3];
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

                    cus[1].crawldata[2] = new crawldata();
                    byte[] binarydata = new byte[4] { 98, 97, 100, 0 };
                    cus[1].crawldata[2].base64 = System.Convert.ToBase64String(binarydata);
                    cus[1].crawldata[2].contenttype = "text/plain";

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;
                    enqueue.crawlurls.crawlurl = cus;

                    // Make call
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                    Assert.AreEqual("The exception [search-collection-invalid-name] was thrown.", se.Message,
                        "Incorrect exception thrown: " + se.Message.ToString());
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueue_UrlStatusComplete()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_UrlStatusComplete";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_UrlStatusComplete Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
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
                    cus[1].crawldata = new crawldata[3];
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

                    cus[1].crawldata[2] = new crawldata();
                    byte[] binarydata = new byte[4] { 98, 97, 100, 0 };
                    cus[1].crawldata[2].base64 = System.Convert.ToBase64String(binarydata);
                    cus[1].crawldata[2].contenttype = "text/plain";

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;
                    enqueue.crawlurls.crawlurl = cus;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
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
        public void SearchCollectionEnqueue_UrlValid()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_UrlValid";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_UrlValid Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.indexednosync;
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;

                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");

                    // Verify data was enqueued
                    logger.Info("Verifying enqueue.");
                    search.authentication = auth;
                    search.query = "devils tower";
                    search.sources = collection;
                    qsResponse = service.QuerySearch(search);

                    Assert.IsTrue(qsResponse.queryresults.list != null, "No results returned.");
                    Assert.AreEqual(1, qsResponse.queryresults.list.document.Length, "Incorrect number of results returned.");
                    Assert.AreEqual("http://testbed4.test.vivisimo.com/textandinfo.htm", qsResponse.queryresults.list.document[0].url,
                        "Incorrect document returned.");

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
        public void SearchCollectionEnqueue_UrlEnqueueTypeForced()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_UrlEnqueueTypeForced";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_UrlEnqueueTypeForced Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.indexednosync;
                    url.enqueuetype = crawlurlEnqueuetype.forced;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;

                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    // Verify data was enqueued
                    logger.Info("Verifying enqueue.");
                    search.authentication = auth;
                    search.query = "devils tower";
                    search.sources = collection;
                    qsResponse = service.QuerySearch(search);

                    Assert.IsTrue(qsResponse.queryresults.list != null, "No results returned.");
                    Assert.AreEqual(1, qsResponse.queryresults.list.document.Length, "Incorrect number of results returned.");
                    Assert.AreEqual("http://testbed4.test.vivisimo.com/textandinfo.htm", qsResponse.queryresults.list.document[0].url,
                        "Incorrect document returned.");

                    // Re-enqueue duplicate data
                    logger.Info("Submitting second request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.IsTrue(response.crawlerserviceenqueueresponse != null, "No response returned.");

                    // Verify data was enqueued
                    logger.Info("Verifying enqueue.");
                    search.authentication = auth;
                    search.query = "devils tower";
                    search.sources = collection;
                    qsResponse = service.QuerySearch(search);

                    Assert.IsTrue(qsResponse.queryresults.list != null, "No results returned.");
                    Assert.AreEqual(1, qsResponse.queryresults.list.document.Length, "Incorrect number of results returned.");
                    Assert.AreEqual("http://testbed4.test.vivisimo.com/textandinfo.htm", qsResponse.queryresults.list.document[0].url,
                        "Incorrect document returned.");

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
        public void SearchCollectionEnqueue_SyncToBeIndex()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_SyncToBeIndex";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_SyncToBeIndex Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.tobeindexed;
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 2;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;

                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    // Verify data was enqueued
                    System.Threading.Thread.Sleep(1000);                      
                    logger.Info("Verifying enqueue.");
                    search.authentication = auth;
                    search.query = "devils tower";
                    search.sources = collection;
                    qsResponse = service.QuerySearch(search);

                    Assert.IsTrue(qsResponse.queryresults.list != null, "No results returned.");
                    Assert.AreEqual(1, qsResponse.queryresults.list.document.Length, "Incorrect number of results returned.");
                    Assert.AreEqual("http://testbed4.test.vivisimo.com/textandinfo.htm", qsResponse.queryresults.list.document[0].url,
                        "Incorrect document returned.");

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
        public void SearchCollectionEnqueue_SyncIndexNoSync()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_SyncIndexNoSync";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_SyncIndexNoSync Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.indexednosync;
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;
                    
                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    // Verify data was enqueued
                    logger.Info("Verifying enqueue.");
                    search.authentication = auth;
                    search.query = "devils tower";
                    search.sources = collection;
                    qsResponse = service.QuerySearch(search);

                    Assert.IsTrue(qsResponse.queryresults.list != null, "No results returned.");
                    Assert.AreEqual(1, qsResponse.queryresults.list.document.Length, "Incorrect number of results returned.");
                    Assert.AreEqual("http://testbed4.test.vivisimo.com/textandinfo.htm", qsResponse.queryresults.list.document[0].url,
                        "Incorrect document returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueue_SyncEnqueued()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_SyncEnqueued";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_SyncEnqueued Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.indexednosync;
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;

                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    // Verify data was enqueued
                    logger.Info("Verifying enqueue.");
                    search.authentication = auth;
                    search.query = "devils tower";
                    search.sources = collection;
                    qsResponse = service.QuerySearch(search);

                    Assert.IsTrue(qsResponse.queryresults.list != null, "No results returned.");
                    Assert.AreEqual(1, qsResponse.queryresults.list.document.Length, "Incorrect number of results returned.");
                    Assert.AreEqual("http://testbed4.test.vivisimo.com/textandinfo.htm", qsResponse.queryresults.list.document[0].url,
                        "Incorrect document returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueue_SyncNone()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_SyncNone";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_SyncNone Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.none;
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 2;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;

                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    // Verify data was enqueued
                    logger.Info("Verifying enqueue.");
                    search.authentication = auth;
                    search.query = "devils tower";
                    search.sources = collection;
                    
                    // start crawl
                    SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
                    start.authentication = auth;
                    start.collection = collection;
                    service.SearchCollectionCrawlerStart(start);
                    System.Threading.Thread.Sleep(10000);

                    qsResponse = service.QuerySearch(search);

                    Assert.IsTrue(qsResponse.queryresults.list != null, "No results returned.");
                    Assert.AreEqual(1, qsResponse.queryresults.list.document.Length, 
                        "Incorrect number of results returned: {0}", qsResponse.queryresults.list.document.Length);
                    Assert.AreEqual("http://testbed4.test.vivisimo.com/textandinfo.htm", qsResponse.queryresults.list.document[0].url,
                        "Incorrect document returned.");

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
        public void SearchCollectionEnqueue_SynchEmpty()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_SynchEmpty";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_SynchEmpty Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;

                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

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
        public void SearchCollectionBrokerEnqueue_EnqueueTypeNone()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "CollectionBrokerEnqueue_EnqueueTypeNone";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_EnqueueTypeNone Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.indexednosync;
                    url.enqueuetype = crawlurlEnqueuetype.none;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;

                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    // Verify data was enqueued
                    logger.Info("Verifying enqueue.");
                    search.authentication = auth;
                    search.query = "devils tower";
                    search.sources = collection;
                    qsResponse = service.QuerySearch(search);

                    Assert.IsTrue(qsResponse.queryresults.list != null, "No results returned.");
                    Assert.AreEqual(1, qsResponse.queryresults.list.document.Length, "Incorrect number of results returned.");
                    Assert.AreEqual("http://testbed4.test.vivisimo.com/textandinfo.htm", qsResponse.queryresults.list.document[0].url,
                        "Incorrect document returned.");

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
        public void SearchCollectionEnqueue_UrlInvalid()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_UrlInvalid";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_UrlInvalid Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbederin.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.indexednosync;
                    url.enqueuetype = crawlurlEnqueuetype.reenqueued;

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 1;

                    url.curloptions = new curloptions();
                    url.curloptions = copts;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;

                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                    Assert.AreEqual("The exception [search-collection-enqueue] was thrown.", se.Message,
                        "Incorrect exception thrown.");
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueue_Exception()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_Exception";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_Exception Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;

                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();

                    // Make call
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Detail);
                    logger.Info("Additional Info: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-enqueue-malformed-crawl-url] was thrown.",
                       "Incorrect exception: " + se.Message);
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
        public void SearchCollectionEnqueue_NoCrawlUrl()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_NoCrawlUrl";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_NoCrawlUrl Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;

                    // Make call
                    response = service.SearchCollectionEnqueue(enqueue);
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
        public void SearchCollectionEnqueue_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_NoCollection";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://vivisimo.com/";

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 2;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;
                    enqueue.crawlurls.crawlurl[0].curloptions = new curloptions();
                    enqueue.crawlurls.crawlurl[0].curloptions = copts;

                    // Make call
                    response = service.SearchCollectionEnqueue(enqueue);
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
        public void SearchCollectionEnqueue_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            string collection = "SearchCollectionEnqueue_NoAuth";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueue_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://vivisimo.com/";

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 2;

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    enqueue.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlurls.crawlurl[0] = url;
                    enqueue.crawlurls.crawlurl[0].curloptions = new curloptions();
                    enqueue.crawlurls.crawlurl[0].curloptions = copts;

                    // Make call
                    response = service.SearchCollectionEnqueue(enqueue);
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

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }


    }
}
