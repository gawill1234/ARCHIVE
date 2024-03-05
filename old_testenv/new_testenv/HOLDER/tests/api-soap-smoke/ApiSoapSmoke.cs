using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web.Services.Protocols;
using System.Xml;
using NUnit.Framework;

namespace api_soap_smoke
{
    [TestFixture]
    public class ApiSoapSmoke
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        const string ENQ_URL = "http://testbed4.test.vivisimo.com";
        string CrawlerStarted = "is-live-running";
        string[] servers;

        [Test]
        public void AuditLog_WithoutErrors()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement XmlToAdd;
            SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
            SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
            string collection = "auditlog-noerrors";
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-noerrors.xml");

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestAuditLog_WithoutErrors Server: {0}", s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    // Start Crawl
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);
                    auditlog.authentication = auth;
                    auditlog.collection = collection;
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    Assert.AreNotEqual(0, auditresponse.auditlogretrieveresponse.auditlogentry.Length,
                        "No audit log entries.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    // Delete the collection
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

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: CollectionBrokerEnqueue_AdvancedContent_Email Server: {0}", s);
                service.Url = s;

                try
                {
                    Console.WriteLine("Test Setup.");
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
                    Console.WriteLine("Submitting enqueue request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.status == collectionbrokerenqueueresponseStatus.success,
                        "Enqueue failed with an error.");
                    Assert.IsTrue(response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.errorSpecified == false,
                        "There was an error specified in the enqueue.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");

                    // Verify results
                    Console.WriteLine("Validating results.");
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
                    Console.WriteLine("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
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

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: CollectionBrokerEnqueue_UrlValid Server: {0}", s);
                service.Url = s;

                try
                {
                    Console.WriteLine("Test Setup.");
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
                    Console.WriteLine("Submitting request.");
                    response = service.CollectionBrokerEnqueueXml(enqueue);
                    Assert.IsTrue(response.collectionbrokerenqueueresponse != null, "No response returned.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    // Verify data was enqueued
                    Console.WriteLine("Verifying enqueue.");
                    search.authentication = auth;
                    search.query = "devils tower";
                    search.sources = collection;
                    qsResponse = service.QuerySearch(search);

                    Assert.IsTrue(qsResponse.queryresults.list != null, "No results returned.");
                    Assert.AreEqual(0, response.collectionbrokerenqueueresponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
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
                    Console.WriteLine("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void QueryBrowse_Query()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            XmlElement XmlToAdd;
            string collection = "query-browse";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: QueryBrowse_Query Server: {0}", s);
                service.Url = s;

                try
                {
                    Console.WriteLine("Test Setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("query-browse.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);

                    // Configure QuerySearch
                    search.browse = true;
                    search.authentication = auth;
                    search.query = "admiral";
                    search.sources = collection;

                    browse.authentication = auth;
                    browse.file = TestUtilities.GetQueryBrowseFile(search, s);

                    Console.WriteLine("Submitting QueryBrowse request.");
                    response = service.QueryBrowse(browse);

                    // Check results
                    Assert.IsNotNull(response.queryresults, "No query results.");
                    Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                    Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    Console.WriteLine("Test Cleanup.");
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_MoveTrue()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_MoveTrue";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: CollectionBrokerExportData_MoveTrue Server: {0}", s);
                service.Url = s;

                try
                {
                    Console.WriteLine("Test Setup.");
                    TestUtilities.CreateSearchCollection("CBExportData", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("CBExportData.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("CBExportData", auth, s);
                    TestUtilities.WaitIdle("CBExportData", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "CBExportData";
                    export.destinationcollection = collection;
                    export.move = true;

                    Console.WriteLine("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.query = "admiral";
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(3, qsResponse.queryresults.list.document.Length,
                        "Incorrect Results returned.  Data not exported.");

                    TestUtilities.WaitIdle("CBExportData", auth, s);
                    search.query = "admiral";
                    search.sources = "CBExportData";
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(null, qsResponse.queryresults.list,
                        "Incorrect Results returned.  Data not moved.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    Console.WriteLine("Cleanup.");
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.StopCrawlAndIndex("CBExportData", auth, s);
                    TestUtilities.DeleteSearchCollection("CBExportData", auth, s);
                }
            }
        }
        [Test]
        public void CollectionBrokerSet_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerSet set = new CollectionBrokerSet();
            CollectionBrokerSetConfiguration config = new CollectionBrokerSetConfiguration();
            CollectionBrokerGet get = new CollectionBrokerGet();
            CollectionBrokerGetResponse response = new CollectionBrokerGetResponse();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: CollectionBrokerGet_Started Server: {0}", s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    Console.WriteLine("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    Console.WriteLine("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.Less(0, response.collectionbrokerconfiguration.checkonlinetime,
                        "Collection not online.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    Console.WriteLine("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerGet_Started()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerGet get = new CollectionBrokerGet();
            CollectionBrokerGetResponse response = new CollectionBrokerGetResponse();
            CollectionBrokerSet set = new CollectionBrokerSet();
            CollectionBrokerSetConfiguration config = new CollectionBrokerSetConfiguration();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: CollectionBrokerGet_Started Server: {0}", s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                config.collectionbrokerconfiguration.checkmemoryusagetime = 100;

                set.authentication = auth;
                set.configuration = config;

                service.CollectionBrokerSet(set);

                get.authentication = auth;

                try
                {
                    Console.WriteLine("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "Response object returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    Console.WriteLine("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSearch_Query()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            XmlElement XmlToAdd;

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: CollectionBrokerSearch_Query Server: {0}", s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection("CBSearch", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("CBSearch.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("CBSearch", auth, s);

                    search.authentication = auth;
                    search.query = "abdiel";
                    search.collection = "CBSearch";

                    response = service.CollectionBrokerSearch(search);
                    Assert.AreNotEqual(null, response.collectionbrokersearchresponse.queryresults.list,
                        "No results returned.");
                    Assert.AreEqual(1, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                        "Incorrect results returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex("CBSearch", auth, s);
                    TestUtilities.DeleteSearchCollection("CBSearch", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerStart_StartandCheckStatus()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerStart start = new CollectionBrokerStart();
            SearchServiceGet ssg = new SearchServiceGet();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: CollectionBrokerStartTests_StartandCheckStatus Server: {0}", s);
                service.Url = s;
                try
                {
                    // Start the collection broker
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerStartCollection_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStartCollection start = new CollectionBrokerStartCollection();
            string collection = "CollectionBrokerStartCollection";
            CollectionBrokerStatus status = new CollectionBrokerStatus();
            CollectionBrokerStatusResponse response = new CollectionBrokerStatusResponse();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: CollectionBrokerStartCollection_Default Server: {0}", s);
                service.Url = s;

                try
                {
                    // Configure request
                    Console.WriteLine("Test setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    Console.WriteLine("Submitting CollectionBrokerStartCollection request.");
                    start.collection = collection;
                    start.authentication = auth;
                    service.CollectionBrokerStartCollection(start);

                    // Check status, make sure collection specified is started.
                    status.authentication = auth;
                    response = service.CollectionBrokerStatus(status);

                    Assert.AreNotEqual(null, response.collectionbrokerstatusresponse,
                        "No CollectionBrokerStatus response.");
                    foreach (collectionbrokerstatusresponseCollection c in response.collectionbrokerstatusresponse.collection)
                    {
                        if (c.name == collection)
                        {
                            Assert.AreEqual(true, c.starttimeSpecified,
                                "Collection has no start time.  Collection not started.");
                            break;
                        }
                        Assert.Fail("Expected collection not in Status response");
                    }
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerStatus_Running()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStatus status = new CollectionBrokerStatus();
            CollectionBrokerStatusResponse response = new CollectionBrokerStatusResponse();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: CollectionBrokerStatus_Running Server: {0}", s);
                service.Url = s;

                // Start collection broker
                TestUtilities.StartCollectionBrokerandWait(auth, s);
                try
                {
                    // Configure request
                    Console.WriteLine("Submitting CollectionBrokerStatus request.");
                    status.authentication = auth;

                    response = service.CollectionBrokerStatus(status);

                    Assert.AreNotEqual(null, response, "No response for status request.");
                    Assert.AreEqual(collectionbrokerstatusresponseStatus.running, response.collectionbrokerstatusresponse.status,
                        "Collection Broker Status incorrectly reported.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerStop_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStop stop = new CollectionBrokerStop();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: CollectionBrokerStop_Default Server: {0}", s);
                service.Url = s;

                try
                {
                    // Configure request
                    Console.WriteLine("Submitting CollectionBrokerStatus request.");

                    stop.authentication = auth;
                    service.CollectionBrokerStop(stop);

                    Assert.Pass("CollectionBrokerStop call successful.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void IndexAtomic_Crawlurl()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: {0} Server: {1}", CollectionName, s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "APISOAP.id.1";
                    inda.synchronization = indexatomicSynchronization.indexednosync;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse, "Null auditresponse.");
                    Assert.NotNull(auditresponse.auditlogretrieveresponse, "Null auditlogretreiveresponse.");
                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Should only return one audit log entry");

                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        Assert.AreEqual(entry.Items.Length, 1, "Should only return one result");
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsNotNull(a.crawlurl, "Indexatomic should have a crawlurl child");
                        }
                    }
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void QuerySearch_QueryOr()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            XmlElement XmlToAdd;

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: QuerySearch_QueryOr Server: {0}", s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection("QuerySearch", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("QuerySearch.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("QuerySearch", auth, s);

                    search.authentication = auth;
                    search.query = "acasta OR achates";
                    search.sources = "QuerySearch";
                    response = service.QuerySearch(search);
                    Assert.AreEqual(2, response.queryresults.list.document.Length,
                        "Incorrect results returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("QuerySearch", auth, s);
                    TestUtilities.DeleteSearchCollection("QuerySearch", auth, s);
                }
            }
        }

        [Test]
        public void ReportsSystemReporting()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            ReportsSystemReporting report = new ReportsSystemReporting();
            ReportsSystemReportingResponse response = new ReportsSystemReportingResponse();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: TestReportsSystemReporting Server: {0}", s);
                report.authentication = auth;
                report.start = DateTime.Today;
                report.end = DateTime.Now;

                try
                {
                    response = service.ReportsSystemReporting(report);
                    Assert.AreNotEqual(null, response.systemreport.systemreportingdatabase,
                        "No system reporting database node returned.");
                    Assert.AreNotEqual(0, response.systemreport.systemreportitem.Length,
                        "No report results returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void RepositoryAdd()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            string result = null;

            xmltoadd = TestUtilities.ReadXmlFile("oracle-1.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: TestRepositoryAdd Server: {0}", s);

                add.authentication = auth;
                add.node = xmltoadd;
                try
                {
                    result = service.RepositoryAdd(add);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "oracle-1";
                    service.RepositoryDelete(delete);
                }
            }

        }

        [Test]
        public void RepositoryDelete_Md5()
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string result;
            XmlElement xmltoadd;

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: TestRepositoryDelete_Md5 Server: {0}", s);

                xmltoadd = TestUtilities.ReadXmlFile("oracle-1.xml");
                try
                {
                    add.node = xmltoadd;
                    add.authentication = auth;
                    result = service.RepositoryAdd(add);
                    delete.md5 = result;
                    delete.name = "oracle-1";
                    delete.element = "vse-collection";
                    delete.authentication = auth;
                    service.RepositoryDelete(delete);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }

        }
        [Test]
        public void RepositoryGetMd5()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement results;
            RepositoryGetMd5 md5 = new RepositoryGetMd5();
            Dictionary<string, string> dict = new Dictionary<string, string>();

            dict.Add("vse-collection", "enron-email-tutorial");
            dict.Add("function", "BBC-parser");
            dict.Add("application", "api-soap");
            dict.Add("source", "CNN");
            dict.Add("report", "search-engine-summary");
            dict.Add("parser", "proxy");
            dict.Add("macro", "url-state");
            dict.Add("kb", "custom");
            dict.Add("dictionary", "base");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: TestRepositoryGetMd5 Server: {0}", s);

                foreach (KeyValuePair<string, string> kvp in dict)
                {
                    md5.authentication = auth;
                    md5.element = kvp.Key;
                    md5.name = kvp.Value;

                    try
                    {
                        results = service.RepositoryGetMd5(md5);
                        Assert.IsTrue(results.InnerXml.Contains("<md5>") == true, "Md5 node not returned.");
                    }
                    catch (SoapException se)
                    {
                        TestUtilities.HandleSoapException(se);
                    }
                }
            }
        }

        [Test]
        public void RepositoryList()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryListXml list = new RepositoryListXml();
            XmlElement results;

            list.authentication = auth;

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: TestRepositoryList Server: {0}", s);

                // Make call
                try
                {
                    results = service.RepositoryListXml(list);
                    Assert.IsTrue(results.InnerXml != null, "XML results not returned.");
                }

                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void RepositoryUpdate_Md5()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            RepositoryGetMd5 md5 = new RepositoryGetMd5();
            XmlElement xmltoadd;
            XmlElement xmltoupdate;
            XmlElement md5result;
            string result = null;

            xmltoadd = TestUtilities.ReadXmlFile("SearchCollectionStatus.xml");
            xmltoupdate = TestUtilities.ReadXmlFile("samba-2.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: TestRepositoryUpdate_Md5 Server: {0}", s);

                add.authentication = auth;
                add.node = xmltoadd;
                update.authentication = auth;
                update.node = xmltoupdate;
                md5.authentication = auth;
                md5.element = "vse-collection";
                md5.name = "SearchCollectionStatus";

                try
                {

                    result = service.RepositoryAdd(add);
                    md5result = service.RepositoryGetMd5(md5);
                    update.md5 = md5result.SelectSingleNode("./md5").InnerText.ToString();
                    result = service.RepositoryUpdate(update);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "SearchCollectionStatus";
                    service.RepositoryDelete(delete);
                }
            }
        }

        [Test]
        public void ReposityGet()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryGet get = new RepositoryGet();
            XmlElement results;
            Dictionary<string, string> dict = new Dictionary<string, string>();

            dict.Add("vse-collection", "enron-email-tutorial");
            dict.Add("function", "BBC-parser");
            dict.Add("application", "api-soap");
            dict.Add("source", "CNN");
            dict.Add("report", "search-engine-summary");
            dict.Add("parser", "proxy");
            dict.Add("macro", "url-state");
            dict.Add("kb", "custom");
            dict.Add("dictionary", "base");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: TestReposityGet Server: {0}", s);

                get.authentication = auth;
                foreach (KeyValuePair<string, string> kvp in dict)
                {
                    get.element = kvp.Key;
                    get.name = kvp.Value;
                    try
                    {
                        results = service.RepositoryGet(get);
                        Assert.IsTrue(results.InnerXml.ToString().Length != 0 == true,
                            "Expected item not returned in repository: " + kvp.Key + " " + kvp.Value);
                    }
                    catch (SoapException se)
                    {
                        TestUtilities.HandleSoapException(se);
                    }
                }
            }
        }

        [Test]
        public void SchedulerServiceStop()
        {
            // variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SchedulerServiceStatusXml status = new SchedulerServiceStatusXml();
            XmlElement results;
            string StartedCompare = "<service-status started=\"";
            string StopCompare = "";

            GetServers();
            foreach (string s in this.servers)
            {
                service.Url = s;
                Console.WriteLine("Test: TestSchedulerServiceStop Server: {0}", s);

                // check if Service is running.
                status.authentication = auth;
                results = service.SchedulerServiceStatusXml(status);
                if (results.InnerXml.ToString().Contains(StartedCompare) == true)
                {
                    try
                    {
                        // Stop service
                        TestUtilities.StopSchedulerService(auth, s);
                        // check service status
                        results = service.SchedulerServiceStatusXml(status);
                        Assert.IsTrue(results.InnerXml.ToString().Contains(StopCompare), "Service was not stopped.");
                    }
                    catch (SoapException se)
                    {
                        TestUtilities.HandleSoapException(se);
                    }
                }
                // Start Service then stop it.
                else
                {
                    TestUtilities.StartSchedulerService(auth, s);
                    try
                    {
                        // Stop service
                        TestUtilities.StopSchedulerService(auth, s);
                        // check service status
                        results = service.SchedulerServiceStatusXml(status);
                        Assert.IsTrue(results.InnerXml.ToString().Contains(StopCompare), "Service was not stopped.");
                    }
                    catch (SoapException se)
                    {
                        TestUtilities.HandleSoapException(se);
                    }
                }
            }
        }

        [Test]
        public void SchedulerServiceStatusXml_Started()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement results;
            SchedulerServiceStatusXml status = new SchedulerServiceStatusXml();
            string ResultsCompare = "<service-status started=\"";

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: TestSchedulerServiceStatusXml_Started Server: {0}", s);

                status.authentication = auth;
                // Start the service
                TestUtilities.StartSchedulerService(auth, s);

                try
                {
                    results = service.SchedulerServiceStatusXml(status);
                    Assert.IsTrue(results.InnerXml.ToString().Contains(ResultsCompare) == true,
                        "Started Status Returned Incorrectly.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }

        }

        [Test]
        public void SearchCollectionCleanTests_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionClean scc = new SearchCollectionClean();
            string collection = "SearchCollectionClean";
            string XmlFile = "SearchCollectionStatus.xml";
            XmlElement XmltoAdd;

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: SearchCollectionCleanTests_Default Server: {0}", s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile(XmlFile);
                    TestUtilities.UpdateCollection(XmltoAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);

                    scc.authentication = auth;
                    scc.collection = collection;

                    // Clean the collection
                    TestUtilities.StopCrawlAndIndexStaging(collection, auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    service.SearchCollectionClean(scc);
                    TestUtilities.StartIndexerandWait(collection, auth, s);

                    // Check the status of the collection
                    SearchCollectionStatus status = new SearchCollectionStatus();
                    status.collection = collection;
                    status.authentication = auth;
                    SearchCollectionStatusResponse response;
                    response = service.SearchCollectionStatus(status);
                    int ndocs = -1;
                    bool cleanfailed = false;
                    if (response.vsestatus != null && response.vsestatus.vseindexstatus != null)
                    {
                        ndocs = response.vsestatus.vseindexstatus.ndocs;
                        Console.WriteLine("Documents: {0}", ndocs);
                    }

                    if (response.vsestatus.cleanfailedSpecified)
                    {
                        Console.WriteLine("The clean failed.");
                        cleanfailed = true;
                    }

                    Assert.IsTrue(ndocs == 0, "The collection was not cleaned because it still has documents.");
                    Assert.IsFalse(cleanfailed, "The clean failed.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Cleanup
                    Console.WriteLine("Test Cleanup.");
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchServiceGet()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestSearchServiceGet Server: {0}", s);
                service.Url = s;

                try
                {
                    get.authentication = auth;
                    response = service.SearchServiceGet(get);
                    Assert.IsTrue(response.vseqs != null, "Search Service not returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void SearchServiceRestart()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchServiceRestart restart = new SearchServiceRestart();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestSearchServiceRestart Server: {0}", s);
                service.Url = s;

                try
                {
                    restart.authentication = auth;
                    service.SearchServiceRestart(restart);
                    Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, s), "Service not started.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void SearchServiceSet()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchServiceSet set = new SearchServiceSet();
            SearchServiceSetConfiguration config = new SearchServiceSetConfiguration();
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestSearchServiceSet Server: {0}", s);
                service.Url = s;

                try
                {
                    set.authentication = auth;
                    config.vseqs = new vseqs();
                    config.vseqs.id = "1";
                    config.vseqs.vseqsoption = new vseqsoption();
                    config.vseqs.vseqsoption.allowips = "true";
                    set.configuration = config;
                    service.SearchServiceSet(set);

                    get.authentication = auth;
                    response = service.SearchServiceGet(get);
                    Assert.IsTrue(response.vseqs.id == "1" && response.vseqs.vseqsoption.allowips == "true",
                        "Specified options not set.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void SearchServiceStart()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchServiceStart start = new SearchServiceStart();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestSearchServiceStart Server: {0}", s);
                service.Url = s;

                try
                {
                    start.authentication = auth;
                    service.SearchServiceStart(start);
                    Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, s), "Service not started.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

            }
        }

        [Test]
        public void SearchServiceStatusXml()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchServiceStatusXml status = new SearchServiceStatusXml();
            XmlElement response;

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestSearchServiceSet Server: {0}", s);
                service.Url = s;

                try
                {
                    status.authentication = auth;
                    response = service.SearchServiceStatusXml(status);
                    Assert.IsFalse(response.IsEmpty, "Response is empty");
                    Assert.AreEqual("vse-qs-status", response.Name, "Response has wrong name");
                    Assert.AreEqual("", response.NamespaceURI, "Response has wrong namespace");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

            }
        }

        [Test]
        public void SearchServiceStop()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchServiceStop stop = new SearchServiceStop();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestSearchServiceStop Server: {0}", s);
                service.Url = s;

                try
                {
                    stop.authentication = auth;
                    service.SearchServiceStop(stop);
                    Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, s) == false, "Service not stopped.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StartQueryService(auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionWorkingCopyAccept()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            SearchCollectionWorkingCopyAccept accept = new SearchCollectionWorkingCopyAccept();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: SearchCollectionWorkingCopyAccept Server: {0}", s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("SearchCollectionWorkingCopy.xml");
                TestUtilities.CreateSearchCollection("SearchCollectionWorkingCopy", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("SearchCollectionWorkingCopy", auth, s);
                TestUtilities.WaitIdle("SearchCollectionWorkingCopy", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "SearchCollectionWorkingCopy";
                    service.SearchCollectionWorkingCopyCreate(create);

                    accept.authentication = auth;
                    accept.collection = "SearchCollectionWorkingCopy";
                    TestUtilities.StartQueryService(auth, s);
                    service.SearchCollectionWorkingCopyAccept(accept);

                    status.authentication = auth;
                    status.collection = "SearchCollectionWorkingCopy(working-copy)";
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                try
                {
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    Console.WriteLine("SoapException Details: " + se.Code);
                    Console.WriteLine("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.",
                    "The appropriate SoapException was not thrown.");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("SearchCollectionWorkingCopy", auth, s);
                    TestUtilities.DeleteSearchCollection("SearchCollectionWorkingCopy", auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionWorkingCopyCreate()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestSearchCollectionWorkingCopyCreate Server: {0}", s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("SearchCollectionWorkingCopy.xml");
                TestUtilities.CreateSearchCollection("SearchCollectionWorkingCopy", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("SearchCollectionWorkingCopy", auth, s);
                TestUtilities.WaitIdle("SearchCollectionWorkingCopy", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "SearchCollectionWorkingCopy";
                    service.SearchCollectionWorkingCopyCreate(create);

                    status.authentication = auth;
                    status.collection = "SearchCollectionWorkingCopy(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response.vsestatus != null, "Working Copy not Created.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("SearchCollectionWorkingCopy", auth, s);
                    TestUtilities.DeleteSearchCollection("SearchCollectionWorkingCopy", auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionWorkingCopyDelete()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            SearchCollectionWorkingCopyDelete delete = new SearchCollectionWorkingCopyDelete();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestSearchCollectionWorkingCopyDelete Server: {0}", s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("SearchCollectionWorkingCopy.xml");
                TestUtilities.CreateSearchCollection("SearchCollectionWorkingCopy", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("SearchCollectionWorkingCopy", auth, s);
                TestUtilities.WaitIdle("SearchCollectionWorkingCopy", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "SearchCollectionWorkingCopy";
                    service.SearchCollectionWorkingCopyCreate(create);

                    status.authentication = auth;
                    status.collection = "SearchCollectionWorkingCopy(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response.vsestatus != null, "Working Copy not Created.");

                    delete.authentication = auth;
                    delete.collection = "SearchCollectionWorkingCopy";
                    service.SearchCollectionWorkingCopyDelete(delete);
                    Console.WriteLine("Working Copy deleted.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                try
                {
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    Console.WriteLine("SoapException Details: " + se.Code);
                    Console.WriteLine("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.",
                    "The appropriate SoapException was not thrown.");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("SearchCollectionWorkingCopy", auth, s);
                    TestUtilities.StopCrawlAndIndexStaging("SearchCollectionWorkingCopy", auth, s);
                    TestUtilities.DeleteSearchCollection("SearchCollectionWorkingCopy", auth, s);
                }

            }
        }

        [Test]
        public void SearchCollectionUpdateConfiguration()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUpdateConfiguration update = new SearchCollectionUpdateConfiguration();
            string collection = "TestSearchCollectionUpdateConfiguration";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestSearchCollectionUpdateConfiguration Server: {0}", s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    update.authentication = auth;
                    update.collection = collection;
                    service.SearchCollectionUpdateConfiguration(update);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionStatus()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: SearchCollectionStatus Server: {0}", s);
                service.Url = s;

                try
                {
                    // Create collection
                    XmlToAdd = TestUtilities.ReadXmlFile("SearchCollectionStatus.xml");
                    TestUtilities.CreateSearchCollection("SearchCollectionStatus", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("SearchCollectionStatus", auth, s);
                    TestUtilities.WaitIdle("SearchCollectionStatus", auth, s);


                    // Get status
                    status.authentication = auth;
                    status.collection = "SearchCollectionStatus";
                    response = service.SearchCollectionStatus(status);

                    // Check status
                    Assert.IsTrue(response.vsestatus.crawlerstatus != null && response.vsestatus.vseindexstatus != null,
                        "Incorrect status returned.");
                    Assert.IsTrue(response.vsestatus.which == vsestatusWhich.live, "Wrong Status returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("SearchCollectionStatus", auth, s);
                    TestUtilities.StopCrawlAndIndex("SearchCollectionStatus", auth, s);
                    TestUtilities.DeleteSearchCollection("SearchCollectionStatus", auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionUrlStatusQueryTest()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            XmlElement XmlToAdd;

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: SearchCollectionUrlStatusQueryTest Server: {0}", s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("SearchCollectionStatus.xml");
                TestUtilities.CreateSearchCollection("SearchCollectionStatus", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("SearchCollectionStatus", auth, s);
                TestUtilities.WaitIdle("SearchCollectionStatus", auth, s);


                try
                {
                    status.authentication = auth;
                    status.collection = "SearchCollectionStatus";
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    filter.name = crawlurlstatusfilterName.url;
                    filter.nameSpecified = true;
                    filter.comparison = crawlurlstatusfilterComparison.wc;
                    filter.comparisonSpecified = true;
                    filter.value = "*";
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation();
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter[0] = filter;
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.IsTrue(response.crawlurlstatusresponse.crawlurl.Length == 55, "Incorrect number of URLs returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("SearchCollectionStatus", auth, s);
                    TestUtilities.StopCrawlAndIndex("SearchCollectionStatus", auth, s);
                    TestUtilities.DeleteSearchCollection("SearchCollectionStatus", auth, s);
                }

            }
        }

        [Test]
        public void SearchCollectionSetXmlTests_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionSetXml xml = new SearchCollectionSetXml();
            XmlElement XmltoAdd;
            SearchCollectionXml scxml = new SearchCollectionXml();

            string collection = "samba-1";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: SearchCollectionSetXmlTests_Default Server: {0}", s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile("samba-1.xml");

                    // Set collection xml
                    xml.authentication = auth;
                    xml.collection = collection;
                    xml.xml = XmltoAdd;
                    service.SearchCollectionSetXml(xml);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionReadOnlyTests_EnabledModifyCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            SearchCollectionReadOnlyResponse response = new SearchCollectionReadOnlyResponse();
            string collection = "SearchCollectionReadOnlyTests_EnabledModifyCollection";
            SearchCollectionDelete delete = new SearchCollectionDelete();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;

                try
                {
                    // Test Setup
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    scro.authentication = auth;
                    scro.collection = collection;
                    scro.mode = SearchCollectionReadOnlyMode.enable;
                    delete.authentication = auth;
                    delete.collection = collection;
                    delete.killservices = true;

                    response = service.SearchCollectionReadOnly(scro);
                    Assert.AreNotEqual(null, response, "No response returned.");

                    // Attempt to modify and catch exception.
                    service.SearchCollectionDelete(delete);

                }
                catch (SoapException se)
                {
                    Console.WriteLine("SoapException Details: " + se.Code);
                    Console.WriteLine("SoapException Message: " + se.Message);
                    Console.WriteLine("Additional Info: {0}", se.Detail.InnerXml.ToString());
                    Assert.AreEqual("The exception [search-collection-delete-read-only] was thrown.", se.Message,
                        "Incorrect exception thrown.");
                }
                finally
                {
                    TestUtilities.DisableReadOnlyandWait(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }

        [Test]
        public void SearchCollectionPushStaging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionPushStaging push = new SearchCollectionPushStaging();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();


            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestSearchCollectionPushStaging Server: {0}", s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection("SearchCollectionPushStaging", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("SearchCollectionPushStaging.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StopQueryService(auth, s);
                    System.Threading.Thread.Sleep(2000);

                    TestUtilities.StartCrawlandWaitStaging("SearchCollectionPushStaging", auth, s);

                    TestUtilities.StartQueryService(auth, s);

                    // need a way to keep the collection in staging to do a push...
                    push.collection = "SearchCollectionPushStaging";
                    push.authentication = auth;
                    service.SearchCollectionPushStaging(push);

                    TestUtilities.WaitIdle("SearchCollectionPushStaging", auth, s);

                    status.authentication = auth;
                    status.collection = "SearchCollectionPushStaging";
                    status.subcollection = SearchCollectionStatusSubcollection.staging;
                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response == null, "Collection not live, status returned for staging.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("SearchCollectionPushStaging", auth, s);
                    TestUtilities.DeleteSearchCollection("SearchCollectionPushStaging", auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionList_Add()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = this.username;
            auth.password = this.password;
            XmlElement element;
            SearchCollectionListXml list = new SearchCollectionListXml();
            SearchCollectionCreate create = new SearchCollectionCreate();
            string results = null;
            SearchCollectionDelete delete = new SearchCollectionDelete();

            // Result Compare String
            string ResultCompare = "name=\"TestSearchCollectionList_Add\"";

            // Configure for servers to run tests against
            this.GetServers();
            foreach (string s in this.servers)
            {
                service.Url = s;
                Console.WriteLine("Test: TestSearchCollectionList_Add Server: {0}", s);

                // Create call using defaults where available.
                create.authentication = auth;
                create.collection = "TestSearchCollectionList_Add";
                try
                {
                    service.SearchCollectionCreate(create);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                // Get List and verify newly created collection present
                list.authentication = auth;
                try
                {
                    element = service.SearchCollectionListXml(list);
                    results = element.InnerXml.ToString();
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");
                    Console.WriteLine("XML returned: {0}", results);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    // Delete the created collection
                    delete.authentication = auth;
                    delete.collection = "TestSearchCollectionList_Add";
                    service.SearchCollectionDelete(delete);
                }
            }

        }

        [Test]
        public void SearchCollectionIndexerRestart()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionIndexerStop stop = new SearchCollectionIndexerStop();
            SearchCollectionIndexerRestart restart = new SearchCollectionIndexerRestart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerRestart";
            XmlElement results;
            XmlNode node;

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: {0} Server: {1}", CollectionName, s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                    start.collection = CollectionName;
                    start.authentication = auth;
                    // Start Indexer
                    service.SearchCollectionIndexerStart(start);

                    // check status
                    list.authentication = auth;
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerRestart\"]");
                    Assert.IsTrue(node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"live\" />"), "Indexer was not started.");

                    // Restart
                    restart.authentication = auth;
                    restart.collection = CollectionName;
                    service.SearchCollectionIndexerRestart(restart);

                    // Recheck status
                    list.authentication = auth;
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerRestart\"]");
                    Assert.IsTrue(node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"live\" />"), "Indexer was not started.");

                    // Stop Service
                    stop.authentication = auth;
                    stop.collection = CollectionName;
                    service.SearchCollectionIndexerStop(stop);


                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionIndexerStart()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStart";
            XmlElement results;
            XmlNode node;

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: {0} Server: {1}", CollectionName, s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                    start.collection = CollectionName;
                    start.authentication = auth;
                    // Start Indexer
                    service.SearchCollectionIndexerStart(start);

                    // check status
                    list.authentication = auth;
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStart\"]");
                    Assert.IsTrue(node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"live\" />"), "Indexer was not started.");
                }
                finally
                {
                    // Stop the Crawl
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionIndexerStop_Kill()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionIndexerStop stop = new SearchCollectionIndexerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStop_Kill";
            XmlElement results;
            XmlNode node;

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: {0} Server: {1}", CollectionName, s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                    start.collection = CollectionName;
                    start.authentication = auth;
                    // Start Indexer
                    service.SearchCollectionIndexerStart(start);

                    // check status
                    list.authentication = auth;
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStop_Kill\"]");
                    if (node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"live\" />"))
                    {
                        stop.collection = CollectionName;
                        stop.authentication = auth;
                        stop.kill = true;
                        service.SearchCollectionIndexerStop(stop);
                        System.Threading.Thread.Sleep(1000);
                        node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStop\"]");
                        //Assert.IsTrue();
                    }
                    else
                    {
                        Assert.Fail("Indexer could not be started.");
                    }

                }
                finally
                {
                    // Stop the Crawl
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

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

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: SearchCollectionEnqueueXml_AdvancedContent Server: {0}", s);
                service.Url = s;

                try
                {
                    Console.WriteLine("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    Console.WriteLine("Enqueueing data.");
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
                    Console.WriteLine("Submitting enqueue request.");
                    enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, enqueueResponse.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, enqueueResponse.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, enqueueResponse.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");

                    // Verify results
                    Console.WriteLine("Validating results.");
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
                    Console.WriteLine("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_Default";
            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: SearchCollectionEnqueueUrl_Default Server: {0}", s);
                service.Url = s;

                try
                {
                    Console.WriteLine("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;

                    // Make call
                    Console.WriteLine("Submitting enqueue request.");
                    response = service.SearchCollectionEnqueueUrl(enqueue);

                    // Validate
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    Console.WriteLine("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueDeletes_CrawlDeleteVseKey()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueue enqueue = new SearchCollectionEnqueue();
            SearchCollectionEnqueueResponse response = new SearchCollectionEnqueueResponse();
            SearchCollectionEnqueueDeletes enqueueDelete = new SearchCollectionEnqueueDeletes();
            SearchCollectionEnqueueDeletesResponse deleteResponse = new SearchCollectionEnqueueDeletesResponse();
            string collection = "SearchCollectionEnqueueDeletes_CrawlDeleteVseKey";
            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: SearchCollectionEnqueueDeletes_CrawlDeleteVseKey Server: {0}", s);
                service.Url = s;

                try
                {
                    Console.WriteLine("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    Console.WriteLine("Enqueue data.");
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

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;
                    enqueue.crawlurls.crawlurl = cus;

                    // Make call
                    Console.WriteLine("Submitting enqueue request.");
                    response = service.SearchCollectionEnqueue(enqueue);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, response.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(2, response.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, response.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    if (TestUtilities.ensureQueryable(collection, auth, s) == false)
                    {
                        // Resubmit enqueue. and try again.
                        response = service.SearchCollectionEnqueue(enqueue);
                    }
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Content not indexed on initial load.");

                    // validate results
                    Console.WriteLine("Validating results.");
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

                    Console.WriteLine("Deleting data.");
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.enqueued;
                    cds[0].vsekey = "myproto://doc?id=1:80/";
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;


                    // Make call
                    Console.WriteLine("Submitting enqueue delete request.");
                    deleteResponse = service.SearchCollectionEnqueueDeletes(enqueueDelete);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, deleteResponse.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, deleteResponse.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, deleteResponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, deleteResponse.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    // validate results
                    Console.WriteLine("Validating results.");
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
                    Console.WriteLine("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
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

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: SearchCollectionEnqueue_AdvancedContent_Email Server: {0}", s);
                service.Url = s;

                try
                {
                    Console.WriteLine("Test Setup.");
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
                    Console.WriteLine("Submitting enqueue request.");
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
                    Console.WriteLine("Validating results.");
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
                    Console.WriteLine("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionCreate_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string ResultCompare = "name=\"TestSearchCollectionCreate_Default\"";
            string collection = "TestSearchCollectionCreate_Default";

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: {0} Server: {1}", collection, s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.collection = collection;
                sc.authentication = auth;
                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();
                string results = null;
                XmlElement element;

                try
                {
                    service.SearchCollectionCreate(sc);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                // Get List and verify newly created collection present
                list.authentication = auth;
                try
                {
                    element = service.SearchCollectionListXml(list);
                    results = element.InnerXml.ToString();
                    Console.WriteLine("XML returned: {0}", results);
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    // Delete the created collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        [Test]
        public void TestSearchCollectionXml_WithData()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionXml xml = new SearchCollectionXml();
            XmlNode scxml;
            string collection = "TestSearchCollectionXml_WithData";
            XmlElement XmltoAdd;

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;

                try
                {
                    // Add collection
                    XmltoAdd = TestUtilities.ReadXmlFile("samba-1.xml");
                    TestUtilities.AddCollection(XmltoAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("samba-1", auth, s);
                    TestUtilities.WaitIdle("samba-1", auth, s);

                    // Get Xml
                    xml.authentication = auth;
                    xml.collection = "samba-1";
                    scxml = service.SearchCollectionXml(xml);
                    Assert.IsTrue(scxml.InnerXml != null, "Xml not returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-1", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-1", auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionCrawlerStart_New()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string TestName = "TestSearchCollectionCrawlerStart_New";
            XmlElement results;
            XmlNode node;
            string collection = "samba-1";
            XmlElement XmlToAdd;

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: {0} Server: {1}", TestName, s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(collection, auth, s);
                XmlToAdd = TestUtilities.ReadXmlFile("samba-1.xml");
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                start.authentication = auth;
                start.collection = collection;
                start.type = SearchCollectionCrawlerStartType.@new;
                list.authentication = auth;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    // Check the crawler was started
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"samba-1\"]");
                    if (node.Attributes.GetNamedItem("name").Value == collection &&
                        node.Attributes.GetNamedItem("is-live-running").Value == CrawlerStarted)
                    {
                        Assert.Pass("Crawler was started.");
                    }
                    else
                    {
                        Assert.Fail("Crawler status is not running.");
                    }

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Stop the Crawl
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionCrawlerRestart()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement collection;
            SearchCollectionCrawlerRestart restart = new SearchCollectionCrawlerRestart();
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();

            GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: SearchCollectionCrawlerRestart Server: {0}", s);

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    collection = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(collection, auth, s);

                    // Start Crawl
                    Console.WriteLine("Starting Crawler.");
                    start.authentication = auth;
                    start.collection = "oracle-1";
                    service.SearchCollectionCrawlerStart(start);

                    // Restart crawl
                    Console.WriteLine("Restarting Crawler.");
                    restart.authentication = auth;
                    restart.collection = "oracle-1";
                    service.SearchCollectionCrawlerRestart(restart);

                    // Check Status = running
                    Console.WriteLine("Checking crawler status.");
                    status.authentication = auth;
                    status.collection = "oracle-1";
                    statusresponse = service.SearchCollectionStatus(status);
                    Assert.IsTrue(statusresponse.vsestatus.crawlerstatus.servicestatus == crawlerstatusServicestatus.running,
                        "Crawler is not running.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("oracle-1", auth, s);
                    TestUtilities.StopCrawlAndIndexStaging("oracle-1", auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }

        }

        [Test]
        public void TestSearchCollectionCrawlerStop_Live()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string TestName = "TestSearchCollectionCrawlerStop_Live";
            XmlElement results;
            XmlNode node;
            string CollectionName = "samba-1";
            XmlElement XmlToAdd;

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: {0} Server: {1}", TestName, s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                XmlToAdd = TestUtilities.ReadXmlFile("samba-1.xml");
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                start.authentication = auth;
                start.collection = CollectionName;
                list.authentication = auth;
                stop.collection = CollectionName;
                stop.authentication = auth;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    // Check the crawler was started
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"samba-1\"]");
                    Assert.IsTrue(node.Attributes.GetNamedItem("name").Value == CollectionName &&
                        node.Attributes.GetNamedItem("is-live-running").Value == CrawlerStarted,
                        "Crawler was not started.");
                    service.SearchCollectionCrawlerStop(stop);
                    System.Threading.Thread.Sleep(4000);
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"samba-1\"]");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Stop the Crawl
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

    }
}
