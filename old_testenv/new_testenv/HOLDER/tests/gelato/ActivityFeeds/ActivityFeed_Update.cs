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

namespace ActivityFeeds
{
    [TestFixture]
    public class ActivityFeeds_Update
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string server = ConfigurationManager.AppSettings.Get("server");

        [Test]
        public void ActivityFeed_RemoveContent()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionAuditLogPurge purge = new SearchCollectionAuditLogPurge();
            SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
            SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            SearchCollectionUpdateConfiguration config = new SearchCollectionUpdateConfiguration();
            string CollectionName = "ActivityFeed_Create";
            XmlElement CollectionXml;

            // Create Search Collection
            service.Url = server;
            TestUtilities.CreateSearchCollection(CollectionName, auth, server);

            // Update Config to enable activity feeds
            CollectionXml = TestUtilities.ReadXmlFile("ActivityFeed_Create.xml");
            TestUtilities.UpdateCollection(CollectionXml, auth, server);
            config.authentication = auth;
            config.collection = CollectionName;
            service.SearchCollectionUpdateConfiguration(config);

            // Enqueue data
            enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
            enqueue.crawlnodes.crawlurls = new crawlurls();
            crawlurl[] cus = new crawlurl[1];

            String MY_CRAWL_URL = "myproto://doc?id=1";
            cus[0] = new crawlurl();
            cus[0].url = MY_CRAWL_URL;
            cus[0].synchronization = crawlurlSynchronization.indexednosync;
            cus[0].status = crawlurlStatus.complete;
            cus[0].crawldata = new crawldata[1];
            cus[0].crawldata[0] = new crawldata();
            cus[0].crawldata[0].contenttype = "application/vxml-unnormalized";
            cus[0].crawldata[0].encoding = crawldataEncoding.xml;
            cus[0].crawldata[0].vxml = new crawldataVxml();
            cus[0].crawldata[0].vxml.document = new document[1];
            cus[0].crawldata[0].vxml.document[0] = new document();
            cus[0].crawldata[0].vxml.document[0].content = new content[4];
            cus[0].crawldata[0].vxml.document[0].content[0] = new content();
            cus[0].crawldata[0].vxml.document[0].content[0].name = "author";
            cus[0].crawldata[0].vxml.document[0].content[0].Value = "erin";

            cus[0].crawldata[0].vxml.document[0].content[1] = new content();
            cus[0].crawldata[0].vxml.document[0].content[1].name = "snippet";
            cus[0].crawldata[0].vxml.document[0].content[1].Value = "insert random snippet text here";

            cus[0].crawldata[0].vxml.document[0].content[2] = new content();
            cus[0].crawldata[0].vxml.document[0].content[2].name = "title";
            cus[0].crawldata[0].vxml.document[0].content[2].Value = "insert random title text here";

            cus[0].crawldata[0].vxml.document[0].content[3] = new content();
            cus[0].crawldata[0].vxml.document[0].content[3].name = "content";
            cus[0].crawldata[0].vxml.document[0].content[3].Value = "insert random content text here";

            try
            {
                // Configure request
                enqueue.authentication = auth;
                enqueue.collection = CollectionName;
                enqueue.exceptiononfailure = false;
                enqueue.crawlnodes.crawlurls.crawlurl = cus;

                // Make call
                enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);

                MY_CRAWL_URL = "myproto://doc?id=2";
                cus[0] = new crawlurl();
                cus[0].url = MY_CRAWL_URL;
                cus[0].synchronization = crawlurlSynchronization.indexednosync;
                cus[0].status = crawlurlStatus.complete;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].contenttype = "application/vxml-unnormalized";
                cus[0].crawldata[0].encoding = crawldataEncoding.xml;
                cus[0].crawldata[0].vxml = new crawldataVxml();
                cus[0].crawldata[0].vxml.document = new document[1];
                cus[0].crawldata[0].vxml.document[0] = new document();
                cus[0].crawldata[0].vxml.document[0].content = new content[4];
                cus[0].crawldata[0].vxml.document[0].content[0] = new content();
                cus[0].crawldata[0].vxml.document[0].content[0].name = "author";
                cus[0].crawldata[0].vxml.document[0].content[0].Value = "bob";

                cus[0].crawldata[0].vxml.document[0].content[1] = new content();
                cus[0].crawldata[0].vxml.document[0].content[1].name = "snippet";
                cus[0].crawldata[0].vxml.document[0].content[1].Value = "insert random snippet2 text here";

                cus[0].crawldata[0].vxml.document[0].content[2] = new content();
                cus[0].crawldata[0].vxml.document[0].content[2].name = "title";
                cus[0].crawldata[0].vxml.document[0].content[2].Value = "insert random title2 text here";

                cus[0].crawldata[0].vxml.document[0].content[3] = new content();
                cus[0].crawldata[0].vxml.document[0].content[3].name = "content";
                cus[0].crawldata[0].vxml.document[0].content[3].Value = "insert random content2 text here";
                enqueue.crawlnodes.crawlurls.crawlurl = cus;
                enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);

                // Get Audit Log
                auditlog.authentication = auth;
                auditlog.collection = CollectionName;
                auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                // Check audit log
                Assert.IsNotNull(auditresponse.auditlogretrieveresponse, "No audit log entries");
                Assert.AreEqual(2, auditresponse.auditlogretrieveresponse.auditlogentry.Length,
                    "Incorrect number of audit log entries.");

                purge.authentication = auth;
                purge.collection = CollectionName;
                purge.token = auditresponse.auditlogretrieveresponse.token;
                service.SearchCollectionAuditLogPurge(purge);

                // Enqueue an update
                MY_CRAWL_URL = "myproto://doc?id=2";
                cus[0] = new crawlurl();
                cus[0].url = MY_CRAWL_URL;
                cus[0].synchronization = crawlurlSynchronization.indexednosync;
                cus[0].status = crawlurlStatus.complete;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].contenttype = "application/vxml-unnormalized";
                cus[0].crawldata[0].encoding = crawldataEncoding.xml;
                cus[0].crawldata[0].vxml = new crawldataVxml();
                cus[0].crawldata[0].vxml.document = new document[1];
                cus[0].crawldata[0].vxml.document[0] = new document();
                cus[0].crawldata[0].vxml.document[0].content = new content[3];
                cus[0].crawldata[0].vxml.document[0].content[0] = new content();
                cus[0].crawldata[0].vxml.document[0].content[0].name = "author";
                cus[0].crawldata[0].vxml.document[0].content[0].Value = "bob";

                cus[0].crawldata[0].vxml.document[0].content[1] = new content();
                cus[0].crawldata[0].vxml.document[0].content[1].name = "snippet";
                cus[0].crawldata[0].vxml.document[0].content[1].Value = "insert random snippet2 text here";

                cus[0].crawldata[0].vxml.document[0].content[2] = new content();
                cus[0].crawldata[0].vxml.document[0].content[2].name = "title";
                cus[0].crawldata[0].vxml.document[0].content[2].Value = "insert random title2 text here";

                enqueue.crawlnodes.crawlurls.crawlurl = cus;
                enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);

                // Get Audit Log
                auditlog.authentication = auth;
                auditlog.collection = CollectionName;
                auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                // Check audit log
                Assert.IsNotNull(auditresponse.auditlogretrieveresponse, "No audit log entries");
                Assert.AreEqual(1, auditresponse.auditlogretrieveresponse.auditlogentry.Length,
                    "Incorrect number of audit log entries.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                // Delete Search Collection
                TestUtilities.DeleteSearchCollection(CollectionName, auth, server);
            }
        }

        [Test]
        public void ActivityFeed_ModifyContent()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionAuditLogPurge purge = new SearchCollectionAuditLogPurge();
            SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
            SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            SearchCollectionUpdateConfiguration config = new SearchCollectionUpdateConfiguration();
            string CollectionName = "ActivityFeed_Create";
            XmlElement CollectionXml;

            // Create Search Collection
            service.Url = server;
            TestUtilities.CreateSearchCollection(CollectionName, auth, server);

            // Update Config to enable activity feeds
            CollectionXml = TestUtilities.ReadXmlFile("ActivityFeed_Create.xml");
            TestUtilities.UpdateCollection(CollectionXml, auth, server);
            config.authentication = auth;
            config.collection = CollectionName;
            service.SearchCollectionUpdateConfiguration(config);

            // Enqueue data
            enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
            enqueue.crawlnodes.crawlurls = new crawlurls();
            crawlurl[] cus = new crawlurl[1];

            String MY_CRAWL_URL = "myproto://doc?id=1";
            cus[0] = new crawlurl();
            cus[0].url = MY_CRAWL_URL;
            cus[0].synchronization = crawlurlSynchronization.indexednosync;
            cus[0].status = crawlurlStatus.complete;
            cus[0].crawldata = new crawldata[1];
            cus[0].crawldata[0] = new crawldata();
            cus[0].crawldata[0].contenttype = "application/vxml-unnormalized";
            cus[0].crawldata[0].encoding = crawldataEncoding.xml;
            cus[0].crawldata[0].vxml = new crawldataVxml();
            cus[0].crawldata[0].vxml.document = new document[1];
            cus[0].crawldata[0].vxml.document[0] = new document();
            cus[0].crawldata[0].vxml.document[0].content = new content[4];
            cus[0].crawldata[0].vxml.document[0].content[0] = new content();
            cus[0].crawldata[0].vxml.document[0].content[0].name = "author";
            cus[0].crawldata[0].vxml.document[0].content[0].Value = "erin";

            cus[0].crawldata[0].vxml.document[0].content[1] = new content();
            cus[0].crawldata[0].vxml.document[0].content[1].name = "snippet";
            cus[0].crawldata[0].vxml.document[0].content[1].Value = "insert random snippet text here";

            cus[0].crawldata[0].vxml.document[0].content[2] = new content();
            cus[0].crawldata[0].vxml.document[0].content[2].name = "title";
            cus[0].crawldata[0].vxml.document[0].content[2].Value = "insert random title text here";

            cus[0].crawldata[0].vxml.document[0].content[3] = new content();
            cus[0].crawldata[0].vxml.document[0].content[3].name = "content";
            cus[0].crawldata[0].vxml.document[0].content[3].Value = "insert random content text here";

            try
            {
                // Configure request
                enqueue.authentication = auth;
                enqueue.collection = CollectionName;
                enqueue.exceptiononfailure = false;
                enqueue.crawlnodes.crawlurls.crawlurl = cus;

                // Make call
                enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);

                MY_CRAWL_URL = "myproto://doc?id=2";
                cus[0] = new crawlurl();
                cus[0].url = MY_CRAWL_URL;
                cus[0].synchronization = crawlurlSynchronization.indexednosync;
                cus[0].status = crawlurlStatus.complete;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].contenttype = "application/vxml-unnormalized";
                cus[0].crawldata[0].encoding = crawldataEncoding.xml;
                cus[0].crawldata[0].vxml = new crawldataVxml();
                cus[0].crawldata[0].vxml.document = new document[1];
                cus[0].crawldata[0].vxml.document[0] = new document();
                cus[0].crawldata[0].vxml.document[0].content = new content[4];
                cus[0].crawldata[0].vxml.document[0].content[0] = new content();
                cus[0].crawldata[0].vxml.document[0].content[0].name = "author";
                cus[0].crawldata[0].vxml.document[0].content[0].Value = "bob";

                cus[0].crawldata[0].vxml.document[0].content[1] = new content();
                cus[0].crawldata[0].vxml.document[0].content[1].name = "snippet";
                cus[0].crawldata[0].vxml.document[0].content[1].Value = "insert random snippet2 text here";

                cus[0].crawldata[0].vxml.document[0].content[2] = new content();
                cus[0].crawldata[0].vxml.document[0].content[2].name = "title";
                cus[0].crawldata[0].vxml.document[0].content[2].Value = "insert random title2 text here";

                cus[0].crawldata[0].vxml.document[0].content[3] = new content();
                cus[0].crawldata[0].vxml.document[0].content[3].name = "content";
                cus[0].crawldata[0].vxml.document[0].content[3].Value = "insert random content2 text here";
                enqueue.crawlnodes.crawlurls.crawlurl = cus;
                enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);

                // Get Audit Log
                auditlog.authentication = auth;
                auditlog.collection = CollectionName;
                auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                // Check audit log
                Assert.IsNotNull(auditresponse.auditlogretrieveresponse, "No audit log entries");
                Assert.AreEqual(2, auditresponse.auditlogretrieveresponse.auditlogentry.Length,
                    "Incorrect number of audit log entries.");

                purge.authentication = auth;
                purge.collection = CollectionName;
                purge.token = auditresponse.auditlogretrieveresponse.token;
                service.SearchCollectionAuditLogPurge(purge);

                // Enqueue an update
                MY_CRAWL_URL = "myproto://doc?id=2";
                cus[0] = new crawlurl();
                cus[0].url = MY_CRAWL_URL;
                cus[0].synchronization = crawlurlSynchronization.indexednosync;
                cus[0].status = crawlurlStatus.complete;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].contenttype = "application/vxml-unnormalized";
                cus[0].crawldata[0].encoding = crawldataEncoding.xml;
                cus[0].crawldata[0].vxml = new crawldataVxml();
                cus[0].crawldata[0].vxml.document = new document[1];
                cus[0].crawldata[0].vxml.document[0] = new document();
                cus[0].crawldata[0].vxml.document[0].content = new content[4];
                cus[0].crawldata[0].vxml.document[0].content[0] = new content();
                cus[0].crawldata[0].vxml.document[0].content[0].name = "author";
                cus[0].crawldata[0].vxml.document[0].content[0].Value = "timmy";

                cus[0].crawldata[0].vxml.document[0].content[1] = new content();
                cus[0].crawldata[0].vxml.document[0].content[1].name = "snippet";
                cus[0].crawldata[0].vxml.document[0].content[1].Value = "insert random snippet2 text here";

                cus[0].crawldata[0].vxml.document[0].content[2] = new content();
                cus[0].crawldata[0].vxml.document[0].content[2].name = "title";
                cus[0].crawldata[0].vxml.document[0].content[2].Value = "insert random title2 text here";

                cus[0].crawldata[0].vxml.document[0].content[3] = new content();
                cus[0].crawldata[0].vxml.document[0].content[3].name = "content";
                cus[0].crawldata[0].vxml.document[0].content[3].Value = "insert random content2 text here";

                enqueue.crawlnodes.crawlurls.crawlurl = cus;
                enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);

                // Get Audit Log
                auditlog.authentication = auth;
                auditlog.collection = CollectionName;
                auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                // Check audit log
                Assert.IsNotNull(auditresponse.auditlogretrieveresponse, "No audit log entries");
                Assert.AreEqual(1, auditresponse.auditlogretrieveresponse.auditlogentry.Length,
                    "Incorrect number of audit log entries.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                // Delete Search Collection
                TestUtilities.DeleteSearchCollection(CollectionName, auth, server);
            }
        }

        [Test]
        public void ActivityFeed_AddContent()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionAuditLogPurge purge = new SearchCollectionAuditLogPurge();
            SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
            SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
            SearchCollectionEnqueueXml enqueue = new SearchCollectionEnqueueXml();
            SearchCollectionEnqueueXmlResponse enqueueResponse = new SearchCollectionEnqueueXmlResponse();
            SearchCollectionUpdateConfiguration config = new SearchCollectionUpdateConfiguration();
            string CollectionName = "ActivityFeed_Create";
            XmlElement CollectionXml;

            // Create Search Collection
            service.Url = server;
            TestUtilities.CreateSearchCollection(CollectionName, auth, server);

            // Update Config to enable activity feeds
            CollectionXml = TestUtilities.ReadXmlFile("ActivityFeed_Create.xml");
            TestUtilities.UpdateCollection(CollectionXml, auth, server);
            config.authentication = auth;
            config.collection = CollectionName;
            service.SearchCollectionUpdateConfiguration(config);

            // Enqueue data
            enqueue.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
            enqueue.crawlnodes.crawlurls = new crawlurls();
            crawlurl[] cus = new crawlurl[1];

            String MY_CRAWL_URL = "myproto://doc?id=1";
            cus[0] = new crawlurl();
            cus[0].url = MY_CRAWL_URL;
            cus[0].synchronization = crawlurlSynchronization.indexednosync;
            cus[0].status = crawlurlStatus.complete;
            cus[0].crawldata = new crawldata[1];
            cus[0].crawldata[0] = new crawldata();
            cus[0].crawldata[0].contenttype = "application/vxml-unnormalized";
            cus[0].crawldata[0].encoding = crawldataEncoding.xml;
            cus[0].crawldata[0].vxml = new crawldataVxml();
            cus[0].crawldata[0].vxml.document = new document[1];
            cus[0].crawldata[0].vxml.document[0] = new document();
            cus[0].crawldata[0].vxml.document[0].content = new content[4];
            cus[0].crawldata[0].vxml.document[0].content[0] = new content();
            cus[0].crawldata[0].vxml.document[0].content[0].name = "author";
            cus[0].crawldata[0].vxml.document[0].content[0].Value = "erin";

            cus[0].crawldata[0].vxml.document[0].content[1] = new content();
            cus[0].crawldata[0].vxml.document[0].content[1].name = "snippet";
            cus[0].crawldata[0].vxml.document[0].content[1].Value = "insert random snippet text here";

            cus[0].crawldata[0].vxml.document[0].content[2] = new content();
            cus[0].crawldata[0].vxml.document[0].content[2].name = "title";
            cus[0].crawldata[0].vxml.document[0].content[2].Value = "insert random title text here";

            cus[0].crawldata[0].vxml.document[0].content[3] = new content();
            cus[0].crawldata[0].vxml.document[0].content[3].name = "content";
            cus[0].crawldata[0].vxml.document[0].content[3].Value = "insert random content text here";

            try
            {
                // Configure request
                enqueue.authentication = auth;
                enqueue.collection = CollectionName;
                enqueue.exceptiononfailure = false;
                enqueue.crawlnodes.crawlurls.crawlurl = cus;

                // Make call
                enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);

                MY_CRAWL_URL = "myproto://doc?id=2";
                cus[0] = new crawlurl();
                cus[0].url = MY_CRAWL_URL;
                cus[0].synchronization = crawlurlSynchronization.indexednosync;
                cus[0].status = crawlurlStatus.complete;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].contenttype = "application/vxml-unnormalized";
                cus[0].crawldata[0].encoding = crawldataEncoding.xml;
                cus[0].crawldata[0].vxml = new crawldataVxml();
                cus[0].crawldata[0].vxml.document = new document[1];
                cus[0].crawldata[0].vxml.document[0] = new document();
                cus[0].crawldata[0].vxml.document[0].content = new content[3];
                cus[0].crawldata[0].vxml.document[0].content[0] = new content();
                cus[0].crawldata[0].vxml.document[0].content[0].name = "author";
                cus[0].crawldata[0].vxml.document[0].content[0].Value = "bob";

                cus[0].crawldata[0].vxml.document[0].content[1] = new content();
                cus[0].crawldata[0].vxml.document[0].content[1].name = "snippet";
                cus[0].crawldata[0].vxml.document[0].content[1].Value = "insert random snippet2 text here";

                cus[0].crawldata[0].vxml.document[0].content[2] = new content();
                cus[0].crawldata[0].vxml.document[0].content[2].name = "title";
                cus[0].crawldata[0].vxml.document[0].content[2].Value = "insert random title2 text here";

                enqueue.crawlnodes.crawlurls.crawlurl = cus;
                enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);

                // Get Audit Log
                auditlog.authentication = auth;
                auditlog.collection = CollectionName;
                auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                // Check audit log
                Assert.IsNotNull(auditresponse.auditlogretrieveresponse, "No audit log entries");
                Assert.AreEqual(2, auditresponse.auditlogretrieveresponse.auditlogentry.Length,
                    "Incorrect number of audit log entries.");

                purge.authentication = auth;
                purge.collection = CollectionName;
                purge.token = auditresponse.auditlogretrieveresponse.token;
                service.SearchCollectionAuditLogPurge(purge);

                // Enqueue an update
                MY_CRAWL_URL = "myproto://doc?id=2";
                cus[0] = new crawlurl();
                cus[0].url = MY_CRAWL_URL;
                cus[0].synchronization = crawlurlSynchronization.indexednosync;
                cus[0].status = crawlurlStatus.complete;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].contenttype = "application/vxml-unnormalized";
                cus[0].crawldata[0].encoding = crawldataEncoding.xml;
                cus[0].crawldata[0].vxml = new crawldataVxml();
                cus[0].crawldata[0].vxml.document = new document[1];
                cus[0].crawldata[0].vxml.document[0] = new document();
                cus[0].crawldata[0].vxml.document[0].content = new content[4];
                cus[0].crawldata[0].vxml.document[0].content[0] = new content();
                cus[0].crawldata[0].vxml.document[0].content[0].name = "author";
                cus[0].crawldata[0].vxml.document[0].content[0].Value = "bob";

                cus[0].crawldata[0].vxml.document[0].content[1] = new content();
                cus[0].crawldata[0].vxml.document[0].content[1].name = "snippet";
                cus[0].crawldata[0].vxml.document[0].content[1].Value = "insert random snippet2 text here";

                cus[0].crawldata[0].vxml.document[0].content[2] = new content();
                cus[0].crawldata[0].vxml.document[0].content[2].name = "title";
                cus[0].crawldata[0].vxml.document[0].content[2].Value = "insert random title2 text here";

                cus[0].crawldata[0].vxml.document[0].content[3] = new content();
                cus[0].crawldata[0].vxml.document[0].content[3].name = "content";
                cus[0].crawldata[0].vxml.document[0].content[3].Value = "insert random content2 text here";

                enqueue.crawlnodes.crawlurls.crawlurl = cus;
                enqueueResponse = service.SearchCollectionEnqueueXml(enqueue);

                // Get Audit Log
                auditlog.authentication = auth;
                auditlog.collection = CollectionName;
                auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                // Check audit log
                Assert.IsNotNull(auditresponse.auditlogretrieveresponse, "No audit log entries");
                Assert.AreEqual(1, auditresponse.auditlogretrieveresponse.auditlogentry.Length,
                    "Incorrect number of audit log entries.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                // Delete Search Collection
                TestUtilities.DeleteSearchCollection(CollectionName, auth, server);
            }
        }
    }
}
