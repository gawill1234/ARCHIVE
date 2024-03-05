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
    class SearchCollectionEnqueueUrlTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        const string ENQ_URL = "http://testbed4.test.vivisimo.com";
        string[] servers;

        [Test]
        public void SearchCollectionEnqueueUrl_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_NoCollection";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;

                    // Make call
                    response = service.SearchCollectionEnqueueUrl(enqueue);
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_Default Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_CrawlTypeResume()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_CrawlTypeResume";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_CrawlTypeResume Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.crawltype = SearchCollectionEnqueueUrlCrawltype.resume;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_CrawlTypeResumeAndIdle()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_CrawlTypeResumeAndIdle";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_CrawlTypeResumeAndIdle Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.crawltype = SearchCollectionEnqueueUrlCrawltype.resumeandidle;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_ForceAllow()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_ForceAllow";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_ForceAllow Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.forceallow = true;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_ForceAllowFalse()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_ForceAllowFalse";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_ForceAllowFalse Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.forceallow = false;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_EnqueueTypeNone()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_EnqueueTypeNone";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_EnqueueTypeNone Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.enqueuetype = SearchCollectionEnqueueUrlEnqueuetype.none;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_EnqueueTypeForced()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_EnqueueTypeForced";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_EnqueueTypeForced Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.enqueuetype = SearchCollectionEnqueueUrlEnqueuetype.forced;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_EnqueueTypeReenqueued()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_EnqueueTypeReenqueued";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_EnqueueTypeReenqueued Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.enqueuetype = SearchCollectionEnqueueUrlEnqueuetype.reenqueued;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void SearchCollectionEnqueueUrl_SyncNone_22987()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_SyncNone";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_SyncNone Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    //enqueue.synchronization = SearchCollectionEnqueueUrlSynchronization.none;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_SyncEnqueued()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_SyncEnqueued";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_SyncEnqueued Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.synchronization = SearchCollectionEnqueueUrlSynchronization.enqueued;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_SyncToBeCrawled()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_SyncToBeCrawled";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_SyncToBeCrawled Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.synchronization = SearchCollectionEnqueueUrlSynchronization.tobecrawled;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_SyncIndexed()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_SyncIndexed";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_SyncIndexed Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.synchronization = SearchCollectionEnqueueUrlSynchronization.indexed;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_SyncToBeIndexed()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_SyncToBeIndexed";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_SyncToBeIndexed Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.synchronization = SearchCollectionEnqueueUrlSynchronization.tobeindexed;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void SearchCollectionEnqueueUrl_BadUrl()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_BadUrl";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_BadUrl Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = "erin";
                    enqueue.synchronization = SearchCollectionEnqueueUrlSynchronization.indexed;
                    
                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void SearchCollectionEnqueueUrl_Staging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_Staging";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_Staging Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.subcollection = SearchCollectionEnqueueUrlSubcollection.staging;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_Live()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_Live";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_Live Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.subcollection = SearchCollectionEnqueueUrlSubcollection.live;

                    // Make call
                    logger.Info("Submitting enqueue request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionEnqueueUrl_NoUrl()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_NoUrl";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_NoUrl Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.collection = collection;
                    
                    // Make call
                    response = service.SearchCollectionEnqueueUrl(enqueue);
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
        public void SearchCollectionEnqueueUrl_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_CollectionNotExist";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    
                    // Configure request
                    enqueue.authentication = auth;
                    enqueue.url = ENQ_URL;
                    enqueue.collection = collection;

                    // Make call
                    response = service.SearchCollectionEnqueueUrl(enqueue);
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
        public void SearchCollectionEnqueueUrl_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionEnqueueUrl enqueue = new SearchCollectionEnqueueUrl();
            SearchCollectionEnqueueUrlResponse response = new SearchCollectionEnqueueUrlResponse();
            string collection = "SearchCollectionEnqueueUrl_NoAuth";
            crawlurl url = new crawlurl();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionEnqueueUrl_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    // Set up.  Start broker and create collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    enqueue.collection = collection;
                    enqueue.url = ENQ_URL;

                    // Make call
                    response = service.SearchCollectionEnqueueUrl(enqueue);
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
