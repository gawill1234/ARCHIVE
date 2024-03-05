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
    class AuditLog
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void TestAuditLogPurge()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            AuditLog log = new AuditLog();
            SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
            SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
            SearchCollectionAuditLogPurge purge = new SearchCollectionAuditLogPurge();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-2.xml");

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Starting test \"TestAuditLogPurge\"");
                logger.Info("Server: " + s);
                service.Url = s;

                try
                {
                    // Start Crawl
                    TestUtilities.CreateSearchCollection("auditlog-2", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("auditlog-2", auth, s);
                    TestUtilities.WaitIdle("auditlog-2", auth, s);
                    
                    // Get audit log
                    auditlog.authentication = auth;
                    auditlog.collection = "auditlog-2";
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    Assert.IsTrue(auditresponse.auditlogretrieveresponse.auditlogentry.Length != 0, "Audit log entries not made.");
                    
                    // Purge log
                    purge.authentication = auth;
                    purge.collection = "auditlog-2";
                    purge.token = auditresponse.auditlogretrieveresponse.token;
                    service.SearchCollectionAuditLogPurge(purge);

                    // Check log
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Cleaning up...");
                    TestUtilities.DeleteSearchCollection("auditlog-2", auth, s);
                }
            }
        }

        [Test]
        public void TestAuditLog_WithErrors()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement XmlToAdd;
            AuditLog log = new AuditLog();
            SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
            SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-1.xml");

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestAuditLog_WithErrors Server: " +  s);
                service.Url = s;

                try
                {
                    // Start Crawl
                    TestUtilities.CreateSearchCollection("auditlog-1", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("auditlog-1", auth, s);
                    TestUtilities.WaitIdle("auditlog-1", auth, s);
                    
                    auditlog.authentication = auth;
                    auditlog.collection = "auditlog-1";
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("auditlog-1", auth, s);
                    // Delete the collection
                    TestUtilities.DeleteSearchCollection("auditlog-1", auth, s);
                }
            }
        }

        [Test]
        public void TestAuditLog_WithoutErrors()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement XmlToAdd;
            SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
            SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-2.xml");

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestAuditLog_WithoutErrors Server: " + s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection("auditlog-2", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    // Start Crawl
                    TestUtilities.StartCrawlandWaitStaging("auditlog-2", auth, s);
                    TestUtilities.WaitIdle("auditlog-2", auth, s);
                    auditlog.authentication = auth;
                    auditlog.collection = "auditlog-2";
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("auditlog-2", auth, s);
                    // Delete the collection
                    TestUtilities.DeleteSearchCollection("auditlog-2", auth, s);
                }

            }
        }

        [Test]
        public void TestAuditLogRetrieveCollection()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveCollection Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse);
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
        public void TestAuditLogRetrieveSubcollectionLive()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveSubcollectionLive Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse);
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
        public void TestAuditLogRetrieveSubcollectionStaging()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveSubcollectionStaging Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.subcollection = SearchCollectionEnqueueXmlSubcollection.staging;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdleStaging(CollectionName, auth, s);


                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.staging;

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.StopCrawlAndIndexStaging(CollectionName, auth, s);
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void TestAuditLogRetrieveLimit()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveLimit Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    cu.url = "myproto://doc?id=2";
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

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse);
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
        public void TestAuditLogRetrieveLimitMulti()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveLimitMulti Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    cu.url = "myproto://doc?id=2";
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

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 2, "Auditlog should have returned two entries");
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
        public void TestAuditLogRetrieveLimitOne()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveLimitOne Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    cu.url = "myproto://doc?id=2";
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
                    auditlog.limit = 1;

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Auditlog should have returned one entry");
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
        public void TestAuditLogRetrieveLimitZero()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveLimitZero Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

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
                    auditlog.limit = 0;

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse);
                    Assert.IsNull(auditresponse.auditlogretrieveresponse.auditlogentry);
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
        public void TestAuditLogRetrieveOffset()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveOffset Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    cu.url = "myproto://doc?id=2";
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
                    auditlog.limit = 1;
                    auditlog.offset = 1;

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Auditlog should have returned one entry");
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
        public void TestAuditLogRetrieveOffsetReturnNull()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveOffsetReturnNull Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    cu.url = "myproto://doc?id=2";
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
                    auditlog.limit = 1;
                    auditlog.offset = 100;

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.IsNull(auditresponse.auditlogretrieveresponse.auditlogentry);
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
        public void TestAuditLogRetrieveOriginator()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveOriginator Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.originator = "APISoap";
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    cu.url = "myproto://doc?id=2";
                    cu.status = crawlurlStatus.complete;
                    cu.originator = "APISoap";
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
                    auditlog.originator = "APISoap";

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
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
        public void TestAuditLogRetrieveToken()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogRetrieveToken Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.originator = "APISoap";
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

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse.token, "Audit log response: Did not return a token!");
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
        public void TestAuditLogEntryOriginator()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogEntryOriginator Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.originator = "APISoap";
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

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Should only return one result");
                    auditlogentry entry = auditresponse.auditlogretrieveresponse.auditlogentry[0];
                    Assert.AreEqual(entry.originator, "APISoap", "Returned incorrect Originator");
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
        public void TestAuditLogEntryEnqueueID()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogEntryEnqueueID Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.enqueueid = "1";
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

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Should only return one result");
                    auditlogentry entry = auditresponse.auditlogretrieveresponse.auditlogentry[0];
                    Assert.AreEqual(entry.enqueueid, "1", "Returned incorrect Enqueue-id");
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
        public void TestAuditLogEntryStatusSuccessful()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogEntryStatusSuccessful Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

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

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Should only return one result");
                    auditlogentry entry = auditresponse.auditlogretrieveresponse.auditlogentry[0];
                    Assert.AreEqual(entry.status, auditlogentryStatus.successful, "Should have returned Status: successuful");
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
        public void TestAuditLogEntryStatusUnsuccessful()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogEntryStatusUnsuccessful Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
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

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Should only return one result");
                    auditlogentry entry = auditresponse.auditlogretrieveresponse.auditlogentry[0];
                    Assert.AreEqual(entry.status, auditlogentryStatus.unsuccessful, "Should have returned Status: unsuccessuful");
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
        public void TestAuditLogEntryCrawlurl()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogEntryCrawlurl Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

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

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Should only return one result");
                    auditlogentry entry = auditresponse.auditlogretrieveresponse.auditlogentry[0];
                    Assert.IsTrue(entry.Items[0] is crawlurl, "Audit log entry: Should have a crawlurl child node");
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
        public void TestAuditLogEntryIndexatomic()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogEntryIndexatomic Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    indexatomic inda = new indexatomic();
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

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Should only return one result");
                    auditlogentry entry = auditresponse.auditlogretrieveresponse.auditlogentry[0];
                    Assert.IsTrue(entry.Items[0] is indexatomic, "Audit log entry: Should have an indexatomic child node");
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
        public void TestAuditLogEntryCrawldelete()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogEntryCrawldelete Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawldelete = new crawldelete[1];
                    crawldelete cd = new crawldelete();
                    scex.crawlnodes.crawlurls.crawldelete[0] = cd;

                    cd.url = "myproto://doc?id=1";
                    cd.synchronization = crawldeleteSynchronization.indexed;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);


                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Should only return one result");
                    auditlogentry entry = auditresponse.auditlogretrieveresponse.auditlogentry[0];
                    Assert.IsTrue(entry.Items[0] is crawldelete, "Audit log entry: Should have a crawldelete child node");
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
        public void TestAuditLogPurgeCollection()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogPurgeCollection Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    cu.url = "myproto://doc?id=2";
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

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);


                    Assert.IsNotNull(auditresponse);
                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse);
                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse.token);

                    // Purge log
                    SearchCollectionAuditLogPurge purge = new SearchCollectionAuditLogPurge();
                    purge.authentication = auth;
                    purge.collection = CollectionName;
                    purge.token = auditresponse.auditlogretrieveresponse.token;
                    service.SearchCollectionAuditLogPurge(purge);
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
        public void TestAuditLogPurgeSubcollectionLive()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogPurgeSubcollectionLive Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.subcollection = SearchCollectionEnqueueXmlSubcollection.live;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    cu.url = "myproto://doc?id=2";
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
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);


                    Assert.IsNotNull(auditresponse);
                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse);
                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse.token);

                    // Purge log
                    SearchCollectionAuditLogPurge purge = new SearchCollectionAuditLogPurge();
                    purge.authentication = auth;
                    purge.collection = CollectionName;
                    purge.subcollection = SearchCollectionAuditLogPurgeSubcollection.live;
                    purge.token = auditresponse.auditlogretrieveresponse.token;
                    service.SearchCollectionAuditLogPurge(purge);
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
        public void TestAuditLogPurgeSubcollectionStaging()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAuditLog";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            XmlToAdd = TestUtilities.ReadXmlFile("auditlog-3.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAuditLogPurgeSubcollectionStaging Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.subcollection = SearchCollectionEnqueueXmlSubcollection.staging;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    scex.crawlnodes.crawlurls.crawlurl[0] = cu;

                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    cu.url = "myproto://doc?id=2";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdleStaging(CollectionName, auth, s);


                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.staging;

                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);


                    Assert.IsNotNull(auditresponse);
                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse);
                    Assert.IsNotNull(auditresponse.auditlogretrieveresponse.token);

                    // Purge log
                    SearchCollectionAuditLogPurge purge = new SearchCollectionAuditLogPurge();
                    purge.authentication = auth;
                    purge.collection = CollectionName;
                    purge.subcollection = SearchCollectionAuditLogPurgeSubcollection.staging;
                    purge.token = auditresponse.auditlogretrieveresponse.token;
                    service.SearchCollectionAuditLogPurge(purge);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.StopCrawlAndIndexStaging(CollectionName, auth, s);
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
