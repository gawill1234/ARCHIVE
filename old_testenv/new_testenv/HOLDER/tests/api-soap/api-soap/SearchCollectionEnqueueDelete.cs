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
    class SearchCollectionEnqueueDeletesTests
    {
        [Test]
        public void SearchCollectionEnqueueDeletes_CrawlDeleteUrl()
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
            string collection = "SearchCollectionEnqueueDeletes_CrawlDeleteUrl";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_CrawlDeleteUrl Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
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
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

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
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.enqueued;
                    cds[0].url = ENQ_URL;
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
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
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueDeletes_NoCrawlDelete()
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
            string collection = "SearchCollectionEnqueueDeletes_NoCrawlDelete";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_NoCrawlDelete Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
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
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

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
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.enqueued;
                    cds[0].url = ENQ_URL;
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    deleteResponse = service.SearchCollectionEnqueueDeletes(enqueueDelete);
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
        public void SearchCollectionEnqueueDeletes_CrawlDeleteUrlSyncIndex()
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
            string collection = "SearchCollectionEnqueueDeletes_CrawlDeleteUrlSyncIndex";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_CrawlDeleteUrlSyncIndex Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
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
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

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
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.indexed;
                    cds[0].url = ENQ_URL;
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
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
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }

        [Test]
        public void SearchCollectionEnqueueDeletes_CrawlDeleteUrlSyncNone()
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
            string collection = "SearchCollectionEnqueueDeletes_CrawlDeleteUrlSyncNone";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_CrawlDeleteUrlSyncNone Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
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
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

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
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.none;
                    cds[0].url = ENQ_URL;
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
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
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }

        [Test]
        public void SearchCollectionEnqueueDeletes_CrawlDeleteUrlSyncToBeIndexed()
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
            string collection = "SearchCollectionEnqueueDeletes_CrawlDeleteUrlSyncToBeIndexed";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_CrawlDeleteUrlSyncToBeIndexed Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
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
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

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
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.tobeindexed;
                    cds[0].url = ENQ_URL;
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
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
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }


        [Test]
        public void SearchCollectionEnqueueDeletes_CrawlDeleteEmptyUrl()
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
            string collection = "SearchCollectionEnqueueDeletes_CrawlDeleteUrl";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_CrawlDeleteUrl Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
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
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

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
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.enqueued;
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    deleteResponse = service.SearchCollectionEnqueueDeletes(enqueueDelete);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.invalid, deleteResponse.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

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
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }


        [Test]
        public void SearchCollectionEnqueueDeletes_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueDeletes enqueueDelete = new SearchCollectionEnqueueDeletes();
            SearchCollectionEnqueueDeletesResponse deleteResponse = new SearchCollectionEnqueueDeletesResponse();
            string collection = "SearchCollectionEnqueueDeletes_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Deleting data.");
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.enqueued;
                    cds[0].url = ENQ_URL;
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.collection = collection;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    deleteResponse = service.SearchCollectionEnqueueDeletes(enqueueDelete);
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
        public void SearchCollectionEnqueueDeletes_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueDeletes enqueueDelete = new SearchCollectionEnqueueDeletes();
            SearchCollectionEnqueueDeletesResponse deleteResponse = new SearchCollectionEnqueueDeletesResponse();
            string collection = "SearchCollectionEnqueueDeletes_NoCollection";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Deleting data.");
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.enqueued;
                    cds[0].url = ENQ_URL;
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.authentication = auth;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    deleteResponse = service.SearchCollectionEnqueueDeletes(enqueueDelete);
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
        public void SearchCollectionEnqueueDeletes_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueDeletes enqueueDelete = new SearchCollectionEnqueueDeletes();
            SearchCollectionEnqueueDeletesResponse deleteResponse = new SearchCollectionEnqueueDeletesResponse();
            string collection = "SearchCollectionEnqueueDeletes_CollectionNotExist";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection

                    logger.Info("Deleting data.");
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.enqueued;
                    cds[0].url = ENQ_URL;
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    deleteResponse = service.SearchCollectionEnqueueDeletes(enqueueDelete);
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_CrawlDeleteVseKey Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
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
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    if (TestUtilities.ensureQueryable(collection, auth, s) == false)
                    {
                        // Resubmit enqueue. and try again.
                        response = service.SearchCollectionEnqueue(enqueue);
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
                    logger.Info("Submitting enqueue delete request.");
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
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }
        [Test]
        public void SearchCollectionEnqueueDeletes_CrawlDeleteVseKeyNotExist()
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
            string collection = "SearchCollectionEnqueueDeletes_CrawlDeleteVseKeyNotExist";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_CrawlDeleteVseKeyNotExist Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
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
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

                    System.Threading.Thread.Sleep(10000);

                    if (TestUtilities.ensureQueryable(collection, auth, s) == false)
                    {
                        // Resubmit enqueue. and try again.
                        response = service.SearchCollectionEnqueue(enqueue);
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
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.indexed;
                    cds[0].vsekey = "erin";
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;


                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    deleteResponse = service.SearchCollectionEnqueueDeletes(enqueueDelete);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, deleteResponse.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(0, deleteResponse.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, deleteResponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(1, deleteResponse.crawlerserviceenqueueresponse.nfailed,
                        "Enqueue not successful.");
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");
                    
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
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }

        [Test]
        public void SearchCollectionEnqueueDeletes_CrawlDeleteNotExist_22470()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueDeletes enqueueDelete = new SearchCollectionEnqueueDeletes();
            SearchCollectionEnqueueDeletesResponse deleteResponse = new SearchCollectionEnqueueDeletesResponse();
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
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;
                    enqueueDelete.exceptiononfailure = false;

                    logger.Info("Deleting data.");
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.indexed;
                    cds[0].url = ENQ_URL;
                    enqueueDelete.crawldeletes.crawldelete = cds;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
                    deleteResponse = service.SearchCollectionEnqueueDeletes(enqueueDelete);
                    Assert.AreEqual(crawlerserviceenqueueresponseError.database, deleteResponse.crawlerserviceenqueueresponse.error,
                        "Error occurred with enqueue.");
                    Assert.AreEqual(1, deleteResponse.crawlerserviceenqueueresponse.nsuccess,
                        "Enqueue not successful");
                    Assert.AreEqual(0, deleteResponse.crawlerserviceenqueueresponse.offlinequeuesize,
                        "Documents added to offline queue.");
                    Assert.AreEqual(0, deleteResponse.crawlerserviceenqueueresponse.nfailed,
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
        public void SearchCollectionEnqueueDeletes_26947()
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
            string collection = "SearchCollectionEnqueueDeletes_26947";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            crawlurl url = new crawlurl();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueDeletes_26947 Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Enqueue data.");
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

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    enqueue.exceptiononfailure = false;
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
                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, auth, s), "Index not queryable.");

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
                    enqueueDelete.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    enqueueDelete.crawldeletes.crawldelete = new crawldelete[1];
                    crawldelete[] cds = new crawldelete[1];
                    cds[0] = new crawldelete();
                    cds[0].synchronization = crawldeleteSynchronization.indexednosync;
                    cds[0].url = ENQ_URL;
                    enqueueDelete.crawldeletes.crawldelete = cds;
                    enqueueDelete.authentication = auth;
                    enqueueDelete.collection = collection;

                    // Make call
                    logger.Info("Submitting enqueue delete request.");
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
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        const string ENQ_URL = "http://testbed4.test.vivisimo.com";
        string[] servers;

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

    }
}
