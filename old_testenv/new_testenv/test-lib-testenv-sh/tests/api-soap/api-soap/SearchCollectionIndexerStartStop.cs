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
    public class SearchCollectionIndexerStartStop
    {
        // Variables
        string username = ConfigurationManager.AppSettings["username"];
        string password = ConfigurationManager.AppSettings["password"];
        string serverlist = ConfigurationManager.AppSettings["serverlist"];
        string[] servers;

        // Tests
        [Test]
        public void TestSearchCollectionIndexerRestart()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerRestart Server: " + s);

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
        public void TestSearchCollectionIndexerRestart_Staging()
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
            string CollectionName = "TestSearchCollectionIndexerRestart_Staging";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerRestart_Staging Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                    start.collection = CollectionName;
                    start.authentication = auth;
                    start.subcollection = SearchCollectionIndexerStartSubcollection.staging;
                    // Start Indexer
                    service.SearchCollectionIndexerStart(start);

                    // check status
                    list.authentication = auth;
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerRestart_Staging\"]");
                    Assert.IsTrue(node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"staging\" />"), "Indexer was not started.");

                    // Restart
                    restart.authentication = auth;
                    restart.collection = CollectionName;
                    restart.subcollection = SearchCollectionIndexerRestartSubcollection.staging;
                    service.SearchCollectionIndexerRestart(restart);

                    // Recheck status
                    list.authentication = auth;
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerRestart_Staging\"]");
                    Assert.IsTrue(node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"staging\" />"), "Indexer was not started.");

                    // Stop Service
                    stop.authentication = auth;
                    stop.collection = CollectionName;
                    stop.subcollection = SearchCollectionIndexerStopSubcollection.staging;
                    service.SearchCollectionIndexerStop(stop);


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


        // Tests
        [Test]
        public void TestSearchCollectionIndexerRestart_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerRestart restart = new SearchCollectionIndexerRestart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerRestart_NoCollection Server: " + s);

                try
                {
                    // Restart
                    restart.authentication = auth;
                    service.SearchCollectionIndexerRestart(restart);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
            }
        }

        [Test]
        public void TestSearchCollectionIndexerRestart_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionIndexerRestart restart = new SearchCollectionIndexerRestart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerRestart_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerRestart_NoAuth Server: " + s);

                try
                {
                    // Restart
                    restart.collection = CollectionName;
                    service.SearchCollectionIndexerRestart(restart);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
            }
        }


        [Test]
        public void TestSearchCollectionIndexerStart()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStart Server: " + s);

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
        public void TestSearchCollectionIndexerStop()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionIndexerStop stop = new SearchCollectionIndexerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStop";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStop Server: " + s);

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
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStop\"]");
                    if (node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"live\" />"))
                    {
                        stop.collection = CollectionName;
                        stop.authentication = auth;
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
        public void TestSearchCollectionIndexerStop_Kill()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStop_Kill Server: " + s);

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
        public void TestSearchCollectionIndexerStop_NotRunning()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStop stop = new SearchCollectionIndexerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStop_NotRunning";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStop_NotRunning Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                    // check status
                    list.authentication = auth;
                    stop.collection = CollectionName;
                    stop.authentication = auth;
                    service.SearchCollectionIndexerStop(stop);
                    System.Threading.Thread.Sleep(1000);
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStop_NotRunning\"]");
                    //Assert.IsTrue();

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
        public void TestSearchCollectionIndexerStop_Staging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionIndexerStop stop = new SearchCollectionIndexerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStop_Staging";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStop_Staging Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                    start.collection = CollectionName;
                    start.authentication = auth;
                    start.subcollection = SearchCollectionIndexerStartSubcollection.staging;
                    // Start Indexer
                    service.SearchCollectionIndexerStart(start);

                    // check status
                    list.authentication = auth;
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStop_Staging\"]");
                    if (node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"staging\" />"))
                    {
                        stop.collection = CollectionName;
                        stop.authentication = auth;
                        stop.subcollection = SearchCollectionIndexerStopSubcollection.staging;
                        service.SearchCollectionIndexerStop(stop);
                        System.Threading.Thread.Sleep(1000);
                        node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStop_Staging\"]");
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
                    TestUtilities.StopCrawlAndIndexStaging(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }
        [Test]
        public void TestSearchCollectionIndexerStop_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionIndexerStop stop = new SearchCollectionIndexerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStop_NoAuth";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStop_NoAuth Server: " + s);

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
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStop_NoAuth\"]");
                    if (node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"live\" />"))
                    {
                        stop.collection = CollectionName;
                        service.SearchCollectionIndexerStop(stop);
                        Assert.Fail("An exception was not thrown.");
                    }

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
                    // Stop the Crawl
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }


        [Test]
        public void TestSearchCollectionIndexerStop_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStop stop = new SearchCollectionIndexerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStop_CollectionNotExist";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStop_CollectionNotExist Server: " + s);

                try
                {
                    stop.authentication = auth;
                    stop.collection = CollectionName;
                    service.SearchCollectionIndexerStop(stop);
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
        public void TestSearchCollectionIndexerStop_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStop stop = new SearchCollectionIndexerStop();
            SearchCollectionListXml list = new SearchCollectionListXml();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStop_NoCollection Server: " + s);

                try
                {
                    stop.authentication = auth;
                    service.SearchCollectionIndexerStop(stop);
                    Assert.Fail("An exception was not thrown.");
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
        public void TestSearchCollectionIndexerStart_LiveandStaging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStart_LiveandStaging";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStart_LiveandStaging Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                    start.collection = CollectionName;
                    start.authentication = auth;
                    // Start Indexer
                    service.SearchCollectionIndexerStart(start);
                    start.subcollection = SearchCollectionIndexerStartSubcollection.staging;
                    service.SearchCollectionIndexerStart(start);

                    // check status
                    list.authentication = auth;
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStart_LiveandStaging\"]");
                    Assert.IsTrue(node.OuterXml.ToString().Contains
                        ("<running name=\"indexer\" which=\"live\" /><running name=\"indexer\" which=\"staging\" />"),
                        "Indexer was not started.");
                }
                finally
                {
                    // Stop the Crawl
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    TestUtilities.StopCrawlAndIndexStaging(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);

                }
            }
        }

        [Test]
        public void TestSearchCollectionIndexerStart_AlreadyStarted()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStart_AlreadyStarted";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStart_AlreadyStarted Server: " + s);

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
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStart_AlreadyStarted\"]");
                    if(node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"live\" />") == true)
                    {
                        service.SearchCollectionIndexerStart(start);
                        Assert.IsTrue(node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"live\" />"), 
                            "Indexer wasn't started.");
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
        public void TestSearchCollectionIndexerStart_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStart_CollectionNotExist";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStart_CollectionNotExist Server: " + s);

                try
                {
                    start.collection = CollectionName;
                    start.authentication = auth;
                    // Start Indexer
                    service.SearchCollectionIndexerStart(start);
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
        public void TestSearchCollectionIndexerStart_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStart_NoCollection";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStart_NoCollection Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                    start.authentication = auth;
                    // Start Indexer
                    service.SearchCollectionIndexerStart(start);
                    Assert.Fail("An exception was not thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [xml-resolve-missing-var-error] was thrown.",
                        "Incorrect exception thrown.");
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
        public void TestSearchCollectionIndexerStart_Staging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStart_Staging";
            XmlElement results;
            XmlNode node;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStart_Staging Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                    start.collection = CollectionName;
                    start.authentication = auth;
                    start.subcollection = SearchCollectionIndexerStartSubcollection.staging;
                    // Start Indexer
                    service.SearchCollectionIndexerStart(start);

                    // check status
                    list.authentication = auth;
                    results = service.SearchCollectionListXml(list);
                    node = results.SelectSingleNode("/vse-collection[@name=\"TestSearchCollectionIndexerStart_Staging\"]");
                    Assert.IsTrue(node.OuterXml.ToString().Contains("<running name=\"indexer\" which=\"staging\" />"), "Indexer was not started.");
                }
                finally
                {
                    // Stop the Crawl
                    TestUtilities.StopCrawlAndIndexStaging(CollectionName, auth, s);
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);

                }
            }
        }

        [Test]
        public void TestSearchCollectionIndexerStart_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SearchCollectionIndexerStart start = new SearchCollectionIndexerStart();
            SearchCollectionListXml list = new SearchCollectionListXml();
            string CollectionName = "TestSearchCollectionIndexerStart_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionIndexerStart_NoAuth Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);

                    start.collection = CollectionName;
                    // Start Indexer
                    service.SearchCollectionIndexerStart(start);
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
