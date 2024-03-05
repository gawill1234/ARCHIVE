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
    class CollectionBrokerEnqueue
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        const string ENQ_URL = "http://testbed4.test.vivisimo.com";
        string[] servers;

        [Test]
        public void CollectionBrokerEnqueue_NotStarted()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_NotStarted";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_NotStarted Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
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
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;
                   
                    // Make call
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.online == true || response.collectionbrokerenqueueresponse.started == true, 
                        "Collection Broker not online.");
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerEnqueue_AdvancedContent_Email()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_AdvancedContent_Email";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_AdvancedContent_Email Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
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
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.errorSpecified == false,
                        "There was an error specified in the enqueue.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");

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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerEnqueue_AdvancedContent_Dash()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_AdvancedContent_Dash";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_AdvancedContent_Dash Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
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
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.errorSpecified == false,
                        "There was an error specified in the enqueue.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");

                    // Verify results
                    logger.Info("Validating results.");
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "erin.me@enron.com";

                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No Results returned.  Query: erin.me@enron.com");

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

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        /// <summary>
        /// Bug 22469 was filed as a result of this test.
        /// </summary>
        [Test]
        public void CollectionBrokerEnqueue_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_CollectionNotExist";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
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
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;

                    // Make call
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                    Assert.AreEqual("The exception [collection-broker-enqueue-xml] was thrown.", se.Message,
                        "Incorrect exception thrown: {0}", se.Message.ToString());
                    Assert.IsTrue(se.Detail.InnerXml.Contains("COLLECTION_BROKER_COLLECTION_DOES_NOT_EXIST") == true,
                        "Incorrect reason for exception.");
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerEnqueue_UrlStatusComplete()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_NotStarted";
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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
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
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.online == true || response.collectionbrokerenqueueresponse.started == true,
                        "Collection Broker not online.");
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");

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
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerEnqueue_Base64()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_Base64";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_Base64 Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    /* example start: cs-cb-enqueue-xml */
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    crawlurl[] cus = new crawlurl[3];
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

                    cus[2] = new crawlurl();
                    cus[2].url = "http://me.com";
                    cus[2].synchronization = crawlurlSynchronization.indexednosync;
                    cus[2].status = crawlurlStatus.complete;
                    cus[2].crawldata = new crawldata[1];
                    cus[2].crawldata[0] = new crawldata();
                    byte[] binarydata = new byte[4] { 98, 97, 100, 0 };
                    cus[2].crawldata[0].base64 = System.Convert.ToBase64String(binarydata);
                    cus[2].crawldata[0].contenttype = "text/plain";

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.AreNotEqual(3, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.noffline,
                        "Items went to offline queue.");

                    // validate results
                    logger.Info("Validating results.");
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "";
                    
                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No results returned.");
                    Assert.AreEqual(3, qres.list.document.Length,
                        "Expected results not returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerEnqueue_UrlValid()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_UrlValid";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_UrlValid Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
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
                    
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse != null, "No response returned.");
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
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
     
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerEnqueue_UrlEnqueueTypeForced()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_UrlEnqueueTypeForced";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_UrlEnqueueTypeForced Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
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

                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse != null, "No response returned.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
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
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse != null, "No response returned.");

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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerEnqueue_CrawlDeleteUrl()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_CrawlDelete";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_CrawlDeleteUrl Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
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
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    System.Threading.Thread.Sleep(10000);
                    
                    //Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Content not indexed on initial load.");

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

                    logger.Info("Deleting data.");
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.enqueued;
                    cds[0].url = ENQ_URL;
                    enqueue.crawlnodes.crawlurls.crawldelete = cds;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.online == true || response.collectionbrokerenqueueresponse.started == true,
                        "Collection Broker not online.");
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    System.Threading.Thread.Sleep(10000);
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Content not indexed.");

                    // validate results
                    logger.Info("Validating results.");
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "";

                    qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "Results returned.");
                    Assert.AreEqual(1, qres.list.document.Length, "Too many results returned.  Content not deleted.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }

        [Test]
        public void CollectionBrokerEnqueue_CrawlDeleteVseKey()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_CrawlDeleteVseKey";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_CrawlDeleteVseKey Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
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

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    System.Threading.Thread.Sleep(10000);

                    if (TestUtilities.ensureQueryable(collection, auth, s) == false)
                    {
                        // Resubmit enqueue. and try again.
                        response = service.CollectionBrokerEnqueueXml(enqueue);
                    }
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Content not indexed on initial load.");

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

                    logger.Info("Deleting data.");
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.enqueued;
                    cds[0].vsekey = "myproto://doc?id=1:80/";
                    enqueue.crawlnodes.crawlurls.crawldelete = cds;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.online == true || response.collectionbrokerenqueueresponse.started == true,
                        "Collection Broker not online.");
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    System.Threading.Thread.Sleep(10000);
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Content not indexed.");

                    // validate results
                    logger.Info("Validating results.");
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "";

                    qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "Results returned.");
                    Assert.AreEqual(1, qres.list.document.Length, "Too many results returned.  Content not deleted.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }

        /// <summary>
        /// This test is incomplete.  Different results are being returned from the query search with no query
        /// and searching through admin with no query.  Need to find out why.  Admin shows 2 documents in the 
        /// index.
        /// </summary>
        [Test]
        public void CollectionBrokerEnqueue_CrawlDeleteVseKeyNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_CrawlDeleteVseKey";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_CrawlDeleteVseKeyNotExist Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
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

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;
                    enqueue.crawlnodes.crawlurls.crawlurl = cus;

                    // Make call
                    logger.Info("Submitting enqueue request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");

                    System.Threading.Thread.Sleep(10000);

                    if (TestUtilities.ensureQueryable(collection, auth, s) == false)
                    {
                        // Resubmit enqueue. and try again.
                        response = service.CollectionBrokerEnqueueXml(enqueue);
                    }
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Content not indexed on initial load.");

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

                    logger.Info("Deleting data.");
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.indexed;
                    cds[0].vsekey = "erin";
                    enqueue.crawlnodes.crawlurls.crawldelete = cds;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.online == true || response.collectionbrokerenqueueresponse.started == true,
                        "Collection Broker not online.");
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    System.Threading.Thread.Sleep(10000);
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Content not indexed.");

                    // validate results
                    logger.Info("Validating results.");
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "";
                    qs.num = 100;
                    qsr = service.QuerySearch(qs);
                    qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "Results returned.");
                    Assert.AreEqual(2, qres.list.document.Length, "Incorrect results returned after delete.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }


        [Test]
        [Ignore ("Bug 22470 not scheduled for IK release.")]
        public void CollectionBrokerEnqueue_CrawlDeleteNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_CrawlDeleteNotExist";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_CrawlDelete Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
                    TestUtilities.CreateSearchCollection(collection, auth, s);


                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;

                    logger.Info("Deleting data.");
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawldelete = new crawldelete[1];
                    crawlurl[] cus = new crawlurl[2];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.indexed;
                    cds[0].url = ENQ_URL;
                    enqueue.crawlnodes.crawlurls.crawldelete = cds;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.online == true || response.collectionbrokerenqueueresponse.started == true,
                        "Collection Broker not online.");
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.AreEqual(1, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.nsuccess, 
                        "Enqueue succeeded.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue failed.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }


        [Test]
        public void CollectionBrokerEnqueue_SyncToBeIndex_22427()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_SyncToBeIndex";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_SyncToBeIndex Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.tobeindexed;
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

                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse != null, "No response returned.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");

                    // wait idle
                    System.Threading.Thread.Sleep(5000);

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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerEnqueue_SyncIndexNoSync()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_SyncIndexNoSync";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_SyncIndexNoSync Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
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

                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse != null, "No response returned.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");

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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerEnqueue_SyncEnqueued()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_SyncEnqueued";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_SyncEnqueued Server: " + s);
                service.Url = s;

                TestUtilities.StartQueryService(auth, s);
                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://testbed4.test.vivisimo.com/";
                    url.synchronization = crawlurlSynchronization.enqueued;
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

                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    System.Threading.Thread.Sleep(5000);
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse != null, "No response returned.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");

                    // Verify data was enqueued
                    logger.Info("Verifying enqueue.");
                    System.Threading.Thread.Sleep(5000);
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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerEnqueue_SyncNone()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_SyncNone";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_SyncNone Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
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

                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse != null, "No response returned.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");

                    // Verify data was enqueued
                    logger.Info("Verifying enqueue.");
                    search.authentication = auth;
                    search.query = "devils tower";
                    search.sources = collection;
                    qsResponse = service.QuerySearch(search);

                    Assert.IsTrue(qsResponse.queryresults.list == null, "Results returned.");

                    // start crawl
                    SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
                    start.authentication = auth;
                    start.collection = collection;
                    service.SearchCollectionCrawlerStart(start);
                    System.Threading.Thread.Sleep(10000);

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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        /// <summary>
        /// Bug 22447 was filed as a result of this test.
        /// </summary>
        [Test]
        public void CollectionBrokerEnqueue_SynchEmpty()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_EmptySynch";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_EmptySynch Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
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

                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.Pass("Passed.");
                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                    Assert.AreEqual("The exception [collection-broker-enqueue-xml] was thrown.", se.Message,
                        "Incorrect exception thrown.");
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerEnqueue_EnqueueTypeNone()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
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
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
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

                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse != null, "No response returned.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    
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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerEnqueue_UrlInvalid()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_UrlInvalid";
            crawlurl url = new crawlurl();
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qsResponse = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_UrlInvalid Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
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

                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;

                    // Make call
                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                    Assert.AreEqual("The exception [collection-broker-enqueue-xml] was thrown.", se.Message,
                        "Incorrect exception thrown.");
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerEnqueue_Exception()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_Exception";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_Exception Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = true;
                    
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();

                    // Make call
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Detail);
                    logger.Info("Additional Info: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [collection-broker-enqueue-xml] was thrown.",
                        "Incorrect exception: {0}", se.Message);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);

                }
            }
        }


        [Test]
        public void CollectionBrokerEnqueue_NoCrawlUrl()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_NoCrawlUrl";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_NoCrawlUrl Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;

                    // Make call
                    response = service.CollectionBrokerEnqueueXml(enqueue);
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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);

                }
            }
        }


        [Test]
        public void CollectionBrokerEnqueue_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_NoCollection";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://vivisimo.com/";

                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 2;

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;
                    enqueue.crawlnodes.crawlurls.crawlurl[0].curloptions = new curloptions();
                    enqueue.crawlnodes.crawlurls.crawlurl[0].curloptions = copts;
                    
                    // Make call
                    response = service.CollectionBrokerEnqueueXml(enqueue);
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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerEnqueue_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
            CollectionBrokerEnqueueXmlResponse response = new CollectionBrokerEnqueueXmlResponse();
            string collection = "CollectionBrokerEnqueue_NoAuth";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
                        
            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerEnqueue_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure data
                    url.url = "http://vivisimo.com/";
                    
                    curloptions copts = new curloptions();
                    copts.curloption = new curloption();
                    copts.curloption.maxhops = 2;

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                    enqueue.crawlnodes.crawlurls = new crawlurls();
                    enqueue.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = new crawlurl();
                    enqueue.crawlnodes.crawlurls.crawlurl[0] = url;
                    enqueue.crawlnodes.crawlurls.crawlurl[0].curloptions = new curloptions();
                    enqueue.crawlnodes.crawlurls.crawlurl[0].curloptions = copts;

                    // Make call
                    response = service.CollectionBrokerEnqueueXml(enqueue);
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
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
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
