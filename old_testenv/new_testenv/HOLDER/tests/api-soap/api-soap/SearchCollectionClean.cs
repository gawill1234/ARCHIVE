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
    class SearchCollectionCleanTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
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
            string collection = "samba-erin";
            string XmlFile = "samba-erin.xml";
            XmlElement XmltoAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionCleanTests_Default Server: " + s);
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
                        logger.Info("Documents: " + ndocs);
                    }

                    if (response.vsestatus.cleanfailedSpecified)
                    {
                        logger.Info("The clean failed.");
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
                    logger.Info("Test Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionCleanTests_Staging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionClean scc = new SearchCollectionClean();
            string collection = "samba-erin";
            string XmlFile = "samba-erin.xml";
            XmlElement XmltoAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionCleanTests_Staging Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile(XmlFile);
                    TestUtilities.UpdateCollection(XmltoAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);

                    
                    // Clean the collection
                    TestUtilities.StopCrawlAndIndexStaging(collection, auth, s);
                    scc.authentication = auth;
                    scc.collection = collection;
                    scc.subcollection = SearchCollectionCleanSubcollection.staging;
                    service.SearchCollectionClean(scc);
                    TestUtilities.StartIndexerandWaitStaging(collection, auth, s);

                    // Check the status of the collection
                    SearchCollectionStatus status = new SearchCollectionStatus();
                    status.collection = collection;
                    status.authentication = auth;
                    status.subcollection = SearchCollectionStatusSubcollection.staging;
                    SearchCollectionStatusResponse response;
                    response = service.SearchCollectionStatus(status);
                    int ndocs = -1;
                    bool cleanfailed = false;
                    if (response.vsestatus != null && response.vsestatus.vseindexstatus != null)
                    {
                        ndocs = response.vsestatus.vseindexstatus.ndocs;
                        logger.Info("Documents: " + ndocs);
                    }

                    if (response.vsestatus.cleanfailedSpecified)
                    {
                        logger.Info("The clean failed.");
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
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionCleanTests_BothSubcollectionsCleanStaging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionClean scc = new SearchCollectionClean();
            string collection = "samba-erin";
            string XmlFile = "samba-erin.xml";
            XmlElement XmltoAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionCleanTests_BothSubcollectionsCleanStaging Server: " + s);
                service.Url = s;

                try
                {
                    TestUtilities.StopQueryService(auth, s);
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile(XmlFile);
                    TestUtilities.UpdateCollection(XmltoAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    
                    // Clean the staging collection
                    TestUtilities.StopCrawlAndIndexStaging(collection, auth, s);
                    scc.authentication = auth;
                    scc.collection = collection;
                    scc.subcollection = SearchCollectionCleanSubcollection.staging;
                    service.SearchCollectionClean(scc);
                    TestUtilities.StartIndexerandWaitStaging(collection, auth, s);

                    // Check the status of the staging collection
                    SearchCollectionStatus status = new SearchCollectionStatus();
                    status.collection = collection;
                    status.authentication = auth;
                    status.subcollection = SearchCollectionStatusSubcollection.staging;
                    SearchCollectionStatusResponse response;
                    response = service.SearchCollectionStatus(status);
                    int ndocs = -1;
                    bool cleanfailed = false;
                    if (response.vsestatus != null && response.vsestatus.vseindexstatus != null)
                    {
                        ndocs = response.vsestatus.vseindexstatus.ndocs;
                        logger.Info("Documents: " + ndocs);
                    }

                    if (response.vsestatus.cleanfailedSpecified)
                    {
                        logger.Info("The clean failed.");
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
                    TestUtilities.StartQueryService(auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionCleanTests_BothSubcollectionsCleanLive()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionClean scc = new SearchCollectionClean();
            string collection = "samba-erin";
            string XmlFile = "samba-erin.xml";
            XmlElement XmltoAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionCleanTests_BothSubcollectionsCleanLive Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile(XmlFile);
                    TestUtilities.UpdateCollection(XmltoAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);

                    // Clean the live collection
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    scc.authentication = auth;
                    scc.collection = collection;
                    service.SearchCollectionClean(scc);
                    TestUtilities.StartIndexerandWait(collection, auth, s);

                    // Check the status of the live collection
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
                            logger.Info("Documents: " + ndocs);
                        }

                        if (response.vsestatus.cleanfailedSpecified)
                        {
                            logger.Info("The clean failed.");
                            cleanfailed = true;
                        }

                        Assert.IsTrue(ndocs == 0, "The collection was not cleaned because it still has documents.");
                        Assert.IsFalse(cleanfailed, "The clean failed.");

                        // Check the status of the staging collection
                        status.subcollection = SearchCollectionStatusSubcollection.staging;
                        response = service.SearchCollectionStatus(status);
                        ndocs = -1;
                        if (response == null)
                        {
                            Assert.Pass("Staging subcollection does not exist.");
                        }
                        else
                        {
                            if (response.vsestatus != null && response.vsestatus.vseindexstatus != null)
                            {
                                ndocs = response.vsestatus.vseindexstatus.ndocs;
                                logger.Info("Documents: " + ndocs);
                            }

                            Assert.IsTrue(ndocs > 0, "The collection was cleaned when it should not have been.");
                        }
                
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Cleanup
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionCleanTests_EmptyCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionClean scc = new SearchCollectionClean();
            string collection = "TestSearchCollectionClean_default";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionCleanTests_EmptyCollection Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    scc.authentication = auth;
                    scc.collection = collection;

                    // Clean the collection
                    service.SearchCollectionClean(scc);

                    Assert.Pass();

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Cleanup
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionCleanTests_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionClean scc = new SearchCollectionClean();
            string collection = "TestSearchCollectionClean_default";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionCleanTests_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Clean the collection
                    scc.collection = collection;
                    service.SearchCollectionClean(scc);

                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    // Cleanup
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionCleanTests_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionClean scc = new SearchCollectionClean();
            string collection = "TestSearchCollectionClean_CollectionNotExist";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionCleanTests_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    // Clean the collection
                    scc.authentication = auth;
                    scc.collection = collection;
                    service.SearchCollectionClean(scc);

                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.AreEqual("The exception [search-collection-invalid-name] was thrown.", se.Message,
                        "Incorrect exception thrown.");
                }
            }
        }

        [Test]
        public void SearchCollectionCleanTests_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionClean scc = new SearchCollectionClean();
            string collection = "SearchCollectionCleanTests_NoCollection";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionCleanTests_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Clean the collection
                    scc.authentication = auth;
                    service.SearchCollectionClean(scc);

                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    // Cleanup
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionCleanTests_IndexerRunning()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionClean scc = new SearchCollectionClean();
            string collection = "oracle-1";
            string XmlFile = "oracle-1.xml";
            XmlElement XmltoAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionCleanTests_IndexerRunning Server: " + s);
                service.Url = s;

                try
                {
                    // Create Collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile(XmlFile);
                    TestUtilities.UpdateCollection(XmltoAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);

                    // Clean the collection
                    scc.authentication = auth;
                    scc.collection = collection;
                    service.SearchCollectionClean(scc);

                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-clean] was thrown.",
                        "Incorrect exception thrown.");
                }
                finally
                {
                    // Cleanup
                    logger.Info("Test Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }
    }
}
