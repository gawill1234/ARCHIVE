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
    /// <summary>
    /// This set of tests will test the following API methods:
    ///     SearchCollectionCrawlerStart
    ///     SearchCollectionCrawlerStop
    ///     SearchCollectionCrawlerRestart
    /// </summary>
    [TestFixture]
    public class SearchCollectionCrawlerStartStop
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;
        string CrawlerStarted = "is-live-running";
        string StagingCrawlerStarted = "is-staging-running";

        /// <summary>
        /// This test will start a crawl for a search-collection.  For setup, a search
        /// collection will be created based on the default, then deleted at the end of 
        /// the test.
        /// </summary>
        [Test]
        public void TestSearchCollectionCrawlerStart_Defaults()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "SearchCollectionCrawlerStart_Defaults";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStart_Defaults Server: " + s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                start.authentication = auth;
                start.collection = CollectionName;
                list.authentication = auth;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    // Check the crawler was started
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"SearchCollectionCrawlerStart_Defaults\"]");
                    if (node.Attributes.GetNamedItem("name").Value == CollectionName &&
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
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }
        
        /// <summary>
        /// Test that doesn't include the required parameter collection in the call
        /// to SearchCollectionCrawlerStart.  An exception is expected.  The test checks
        /// that the correct exception was thrown.
        /// </summary>
        [Test]
        public void TestSearchCollectionCrawlerStart_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionCrawlerStart_NoCollection";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStart_NoCollection Server: " + s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                start.authentication = auth;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    Assert.Fail("An exception was not thrown.");
                    // Check the crawler was started
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [xml-resolve-missing-var-error] was thrown.",
                        "Incorrect exception thrown.");
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        /// <summary>
        /// Test that submits a request to SearchCollectionCrawlerStart including the name
        /// of a search collection that does not exist.  The test is expecting an exception
        /// to be thrown.
        /// </summary>
        [Test]
        public void TestSearchCollectionCrawlerStart_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionCrawlerStart_CollectionNotExist";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            start.collection = CollectionName;
            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStart_CollectionNotExist Server: " + s);

                // Don't create collection
                start.authentication = auth;
                start.collection = CollectionName;
                list.authentication = auth;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    Assert.Fail("An exception was not thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.",
                        "Incorrect exception thrown.");
                }
                
            }
        }

        /// <summary>
        /// Test that submits a request to SearchCollectionCrawlerStart without an authentication
        /// obje
        /// </summary>
        [Test]
        public void TestSearchCollectionCrawlerStart_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionCrawlerStart_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            start.collection = CollectionName;
            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStart_NoAuth Server: " + s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    Assert.Fail("An exception was not thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Code.ToString() == "urn:/velocity/objects:rights-execute", 
                        "The appropriate SoapException was not thrown.");
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }

        }

        /// <summary>
        /// 
        /// </summary>
        [Test]
        public void TestSearchCollectionCrawlerStart_AlreadyStarted()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            XmlElement results;
            XmlNode node;
            XmlElement collection;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStart_AlreadyStarted Server: " + s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                collection = TestUtilities.ReadXmlFile("oracle-1.xml");
                TestUtilities.UpdateCollection(collection, auth, s);

                start.authentication = auth;
                start.collection = "oracle-1";
                list.authentication = auth;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    // Check the crawler was started
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"oracle-1\"]");
                    if (node.Attributes.GetNamedItem("name").Value == "oracle-1" &&
                        node.Attributes.GetNamedItem("is-live-running").Value == CrawlerStarted)
                    {
                        Assert.Pass("Crawler was started.");
                    }
                    else
                    {
                        Assert.Fail("Crawler status is not running.");
                    }
                    service.SearchCollectionCrawlerStart(start);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Stop the Crawl
                    TestUtilities.StopCrawlAndIndex("oracle-1", auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }

        }

        [Test]
        public void TestSearchCollectionCrawlerStart_Resume()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionCrawlerStart_Resume";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStart_Resume Server: " + s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                start.authentication = auth;
                start.collection = CollectionName;
                start.type = SearchCollectionCrawlerStartType.resume;
                list.authentication = auth;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    // Check the crawler was started
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionCrawlerStart_Resume\"]");
                    if (node.Attributes.GetNamedItem("name").Value == CollectionName &&
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
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void TestSearchCollectionCrawlerStart_Resume_and_Idle()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "SearchCollectionCrawlerStart_Resume_and_Idle";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStart_Resume_and_Idle Server: " + s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                start.authentication = auth;
                start.collection = CollectionName;
                start.type = SearchCollectionCrawlerStartType.resumeandidle;
                list.authentication = auth;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    // Check the crawler was started
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"SearchCollectionCrawlerStart_Resume_and_Idle\"]");
                    if (node.Attributes.GetNamedItem("name").Value == CollectionName &&
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
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        //[Ignore ("Known Bug: 21469")]
        public void TestSearchCollectionCrawlerStart_RefreshNew_21469()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            XmlElement xmltoadd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStart_RefreshNew_21469 Server: " + s);

                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                xmltoadd = TestUtilities.ReadXmlFile("samba-erin.xml");
                // Create Search Collection
                TestUtilities.UpdateCollection(xmltoadd, auth, s);

                start.authentication = auth;
                start.collection = "samba-erin";
                start.subcollection = SearchCollectionCrawlerStartSubcollection.staging;
                list.authentication = auth;

                // Start Crawler
                try
                {
                    TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                    TestUtilities.WaitIdle("samba-erin", auth, s);
                    logger.Info("Initial Crawl complete.");
                    
                    start.type = SearchCollectionCrawlerStartType.refreshnew;
                    start.subcollection = SearchCollectionCrawlerStartSubcollection.staging;
                    service.SearchCollectionCrawlerStart(start);

                    TestUtilities.WaitIdle("samba-erin", auth, s);
                    logger.Info("Recrawl complete.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Stop the Crawl
                    logger.Info("Test Cleanup.");
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }

        [Test]
        public void TestSearchCollectionCrawlerStart_New()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            XmlElement results;
            XmlNode node;
            string collection = "samba-erin";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStart_New Server: " + s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(collection, auth, s);
                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
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
                    node = results.SelectSingleNode("/vse-collection[@name=\"samba-erin\"]");
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
            XmlElement results;
            XmlNode node;
            string CollectionName = "samba-erin";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStop_Live Server: " + s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
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
                    node = results.SelectSingleNode("/vse-collection[@name=\"samba-erin\"]");
                    Assert.IsTrue(node.Attributes.GetNamedItem("name").Value == CollectionName &&
                        node.Attributes.GetNamedItem("is-live-running").Value == CrawlerStarted,
                        "Crawler was not started.");
                    service.SearchCollectionCrawlerStop(stop);
                    System.Threading.Thread.Sleep(4000);
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"samba-erin\"]");

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

        [Test]
        public void TestSearchCollectionCrawlerStop_Staging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "oracle-1";
            XmlElement results;
            XmlNode node;
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStop_Staging Server: " + s);

                // Create Search Collection
                TestUtilities.StopQueryService(auth, s);
                TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                start.authentication = auth;
                start.collection = CollectionName;
                start.subcollection = SearchCollectionCrawlerStartSubcollection.staging;
                list.authentication = auth;
                stop.collection = CollectionName;
                stop.authentication = auth;
                stop.subcollection = SearchCollectionCrawlerStopSubcollection.staging;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    // Check the crawler was started
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"oracle-1\"]");
                    Assert.IsTrue(node.Attributes.GetNamedItem("name").Value == CollectionName &&
                        node.Attributes.GetNamedItem("is-staging-running").Value == StagingCrawlerStarted,
                        "Crawler was not started.");
                    service.SearchCollectionCrawlerStop(stop);
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"oracle-1\"]");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Stop the Crawl
                    TestUtilities.StartQueryService(auth, s);
                    TestUtilities.StopCrawlAndIndexStaging(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }
        [Test]
        public void TestSearchCollectionCrawlerStop_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionCrawlerStop_NoAuth";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStop_NoAuth Server: " + s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                start.authentication = auth;
                start.collection = CollectionName;
                list.authentication = auth;
                stop.collection = CollectionName;
                
                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStart(start);
                    // Check the crawler was started
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionCrawlerStop_NoAuth\"]");
                    Assert.IsTrue(node.Attributes.GetNamedItem("name").Value == CollectionName &&
                        node.Attributes.GetNamedItem("is-live-running").Value == CrawlerStarted,
                        "Crawler was not started.");
                    service.SearchCollectionCrawlerStop(stop);

                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Code.ToString() == "urn:/velocity/objects:rights-execute", "The appropriate SoapException was not thrown.");
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
        public void TestSearchCollectionCrawlerStop_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStop_NoCollection Server: " + s);

                start.authentication = auth;
                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStop(stop);
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [xml-resolve-missing-var-error] was thrown.",
                        "Incorrect exception thrown.");
                }
            }

        }
        [Test]
        public void TestSearchCollectionCrawlerStop_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();
            string CollectionName = "TestSearchCollectionCrawlerStop_CollectionNotExist";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            stop.collection = CollectionName;
            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStop_CollectionNotExist Server: " + s);

                // Don't create collection
                stop.authentication = auth;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStop(stop);
                    Assert.Fail("An exception was not thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.",
                        "Incorrect exception thrown.");
                }

            }

        }
        [Test]
        public void TestSearchCollectionCrawlerStop_NotStarted()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerStart start = new SearchCollectionCrawlerStart();
            SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionCrawlerStop_NotStarted";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCrawlerStop_NotStarted Server: " + s);

                // Create Search Collection
                TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                start.authentication = auth;
                start.collection = CollectionName;
                list.authentication = auth;
                stop.collection = CollectionName;
                stop.authentication = auth;

                // Start Crawler
                try
                {
                    service.SearchCollectionCrawlerStop(stop);
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionCrawlerStop_NotStarted\"]");
                    Assert.IsTrue(node.HasChildNodes == false, "Crawler was not stopped.");

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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: SearchCollectionCrawlerRestart Server: " + s);

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    collection = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(collection, auth, s);

                    // Start Crawl
                    logger.Info("Starting Crawler.");
                    start.authentication = auth;
                    start.collection = "oracle-1";
                    service.SearchCollectionCrawlerStart(start);

                    logger.Info("Stop query service.");
                    TestUtilities.StopQueryService(auth, s);

                    // Restart crawl
                    logger.Info("Restarting Crawler.");
                    restart.authentication = auth;
                    restart.collection = "oracle-1";
                    service.SearchCollectionCrawlerRestart(restart);

                    // Check Status = running
                    logger.Info("Checking crawler status.");
                    status.authentication = auth;
                    status.collection = "oracle-1";
                    statusresponse = service.SearchCollectionStatus(status);
                    System.Threading.Thread.Sleep(500);
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
        public void SearchCollectionCrawlerRestart_Staging()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: SearchCollectionCrawlerRestart Server: " + s);

                try
                {
                    // Add collection
                    logger.Info("Test setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    collection = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(collection, auth, s);

                    // Start Crawl
                    logger.Info("Starting initial crawl."); 
                    start.authentication = auth;
                    start.collection = "oracle-1";
                    start.subcollection = SearchCollectionCrawlerStartSubcollection.staging;
                    service.SearchCollectionCrawlerStart(start);

                    logger.Info("Stop query service.");
                    TestUtilities.StopQueryService(auth, s);

                    // Restart crawl
                    restart.authentication = auth;
                    restart.collection = "oracle-1";
                    restart.subcollection = SearchCollectionCrawlerRestartSubcollection.staging;
                    service.SearchCollectionCrawlerRestart(restart);
                    
                    // Check Status = running
                    status.authentication = auth;
                    status.collection = "oracle-1";
                    status.subcollection = SearchCollectionStatusSubcollection.staging;
                    statusresponse = service.SearchCollectionStatus(status);
                    System.Threading.Thread.Sleep(500);
                    Assert.AreEqual(crawlerstatusServicestatus.running, statusresponse.vsestatus.crawlerstatus.servicestatus,
                        "Crawler is not running.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StartQueryService(auth, s);
                    TestUtilities.StopCrawlAndIndexStaging("oracle-1", auth, s);
                    TestUtilities.StopCrawlAndIndex("oracle-1", auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }

        }


        [Test]
        public void SearchCollectionCrawlerRestart_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerRestart restart = new SearchCollectionCrawlerRestart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: SearchCollectionCrawlerRestart_NoCollection Server: " + s);

                try
                {
                    // Restart crawl
                    restart.authentication = auth;
                    service.SearchCollectionCrawlerRestart(restart);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
            }

        }


        [Test]
        public void SearchCollectionCrawlerRestart_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionCrawlerRestart restart = new SearchCollectionCrawlerRestart();
            SearchCollectionStatus status = new SearchCollectionStatus();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: SearchCollectionCrawlerRestart_NoAuth Server: " + s);

                try
                {
                    // Restart crawl
                    restart.collection = "oracle-1";
                    service.SearchCollectionCrawlerRestart(restart);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
            }

        }

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

    }
}
