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
    class CollectionBrokerGetAndSet
    {        
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerGet_Started Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_24247()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerSet setFirst = new CollectionBrokerSet();
            CollectionBrokerSet setSecond = new CollectionBrokerSet();
            CollectionBrokerSetConfiguration firstConfig = new CollectionBrokerSetConfiguration();
            CollectionBrokerSetConfiguration secondConfig = new CollectionBrokerSetConfiguration();
            CollectionBrokerGet get = new CollectionBrokerGet();
            CollectionBrokerGetResponse firstUpdate = new CollectionBrokerGetResponse();
            CollectionBrokerGetResponse finalUpdate = new CollectionBrokerGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerGet_Started Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                try
                {
                    // update config with a couple settings
                    logger.Info("Set first update.");
                    firstConfig.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    firstConfig.collectionbrokerconfiguration.maximumcollections = 500;
                    firstConfig.collectionbrokerconfiguration.name = "global";
                    setFirst.authentication = auth;
                    setFirst.configuration = firstConfig;
                    service.CollectionBrokerSet(setFirst);

                    // get config
                    logger.Info("Get configuration after first update.");
                    get.authentication = auth;
                    firstUpdate = service.CollectionBrokerGet(get);
                    Assert.IsNotNull(firstUpdate, "No configuration returned for first update.");

                    // set a different config
                    logger.Info("Set second update.");
                    secondConfig.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    secondConfig.collectionbrokerconfiguration.checkonlinetime = 500;
                    setSecond.authentication = auth;
                    setSecond.configuration = secondConfig;
                    service.CollectionBrokerSet(setSecond);

                    // get config
                    logger.Info("Get config after second update.");
                    finalUpdate = service.CollectionBrokerGet(get);
                    Assert.IsNotNull(finalUpdate, "No configuration returned for final update.");

                    // check that none of the values set in first step were overwritten
                    logger.Info("Verifying results.");
                    Assert.AreNotEqual(firstUpdate.collectionbrokerconfiguration.maximumcollections, 
                        finalUpdate.collectionbrokerconfiguration.maximumcollections,
                        "Set configuration maximumcollections not overwritten with a default setting.");
                    Assert.AreEqual(firstUpdate.collectionbrokerconfiguration.name, finalUpdate.collectionbrokerconfiguration.name,
                        "Name configuration overwritten with a default setting.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }

        }

        [Test]
        public void CollectionBrokerSet_MaxCollections()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_MaxCollections Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.maximumcollections = 2;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(2, response.collectionbrokerconfiguration.maximumcollections,
                        "Collection not online.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerSet_AlwaysAllowOneCollection()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_AlwaysAllowOneCollection Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.alwaysallowonecollection = true;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(true, response.collectionbrokerconfiguration.alwaysallowonecollection,
                        "Always allow one collection not correct value.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_PreferRequests_Enqueue()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_PreferRequests_Enqueue Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.preferrequests = collectionbrokerconfigurationPreferrequests.enqueue;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(collectionbrokerconfigurationPreferrequests.enqueue, response.collectionbrokerconfiguration.preferrequests,
                        "Always allow one collection not correct value.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_PreferRequests_Search()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_PreferRequests_Search Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.preferrequests = collectionbrokerconfigurationPreferrequests.search;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(collectionbrokerconfigurationPreferrequests.search, response.collectionbrokerconfiguration.preferrequests,
                        "Always allow one collection not correct value.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_MinimumFreeMemory()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_MinimumFreeMemory Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.minimumfreememory = 1000;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(1000, response.collectionbrokerconfiguration.minimumfreememory,
                        "Minimum free memory not correct value.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_MinimumFreeMemory_0()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_MinimumFreeMemory_0 Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.minimumfreememory = 0;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(0, response.collectionbrokerconfiguration.minimumfreememory,
                        "Minimum free memory not correct value.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_OverCommitFactor_Greater1()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_OverCommitFactor Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.overcommitfactor = 1.2;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(1.2, response.collectionbrokerconfiguration.overcommitfactor,
                        "Overcommit factor not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_OverCommitFactor_Less1()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_OverCommitFactor_Less1 Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.overcommitfactor = 0.5;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(0.5, response.collectionbrokerconfiguration.overcommitfactor,
                        "Overcommit factor not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_IndexerOverhead()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_IndexerOverhead Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.indexeroverhead = 1000;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(1000, response.collectionbrokerconfiguration.indexeroverhead,
                        "Indexer Overhead value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_CrawlerOverhead()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_CrawlerOverhead Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.crawleroverhead = 1000;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(1000, response.collectionbrokerconfiguration.crawleroverhead,
                        "Indexer Overhead value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_MemoryGranularity()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_MemoryGranularity Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.memorygranularity = 1000;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(1000, response.collectionbrokerconfiguration.memorygranularity,
                        "Memory Granularity value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerSet_TimeGranularity()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_TimeGranularity Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.timegranularity = 1000;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(1000, response.collectionbrokerconfiguration.timegranularity,
                        "Time Granularity value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerSet_CheckOnlineTime()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_CheckOnlineTime Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.checkonlinetime = 100;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(100, response.collectionbrokerconfiguration.checkonlinetime,
                        "Check onlime time value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerSet_CurrentStatusTime()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_CurrentStatusTime Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.currentstatustime = 100;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(100, response.collectionbrokerconfiguration.currentstatustime,
                        "Current Status time value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        [Ignore("Replace test when 22635 is fixed.")]
        public void CollectionBrokerSet_CurrentStatusTime_Neg_22635()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_CurrentStatusTime_Neg Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.currentstatustime = -100;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(100, response.collectionbrokerconfiguration.currentstatustime,
                        "Current Status time value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerSet_StartOfflineTime()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_StartOfflineTime Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.startofflinetime = 100;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(100, response.collectionbrokerconfiguration.startofflinetime,
                        "Start offline time value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        [Ignore ("Replace test when 22635 is fixed.")]
        public void CollectionBrokerSet_StartOfflineTime_Neg_22635()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_StartOfflineTime_Neg Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.startofflinetime = -100;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(100, response.collectionbrokerconfiguration.startofflinetime,
                        "Start offline time value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerSet_CheckMemoryUsageTime()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_CheckMemoryUsageTime Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.checkmemoryusagetime = 100;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(100, response.collectionbrokerconfiguration.checkmemoryusagetime,
                        "Check Memory Usage time value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerSet_PersistentSaveTime()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_PersistentSaveTime Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.persistentsavetime = 100;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(100, response.collectionbrokerconfiguration.persistentsavetime,
                        "Persistant Save time value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerSet_LivePingProbability()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_LivePingProbability Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.livepingprobability = 100;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(100, response.collectionbrokerconfiguration.livepingprobability,
                        "Live Ping Probability value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerSet_CrawlerMinimum()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_CrawlerMinimum Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.crawlerminimum = 1000;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(1000, response.collectionbrokerconfiguration.crawlerminimum,
                        "Crawler Minimum value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerSet_IndexerMinimum()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_IndexerMinimum Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.indexerminimum = 1000;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(1000, response.collectionbrokerconfiguration.indexerminimum,
                        "Indexer Minimum value not correct.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_AlwaysAllowOneCollectionFalse()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_AlwaysAllowOneCollectionFalse Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.alwaysallowonecollection = false;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(false, response.collectionbrokerconfiguration.alwaysallowonecollection,
                        "Always allow one collection not correct value.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s); 
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        [Ignore("Replace test when 22635 is fixed.")]
        public void CollectionBrokerSet_MaxCollectionsNegative_22635()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerGet_Started Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.maximumcollections = -2;

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response.collectionbrokerconfiguration != null, "No response object.");
                    Assert.AreEqual(2, response.collectionbrokerconfiguration.maximumcollections,
                        "Collection not online.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }


        [Test]
        public void CollectionBrokerSet_NameNotGlobal()
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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_NameNotGlobal Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.name = "erin";

                    set.authentication = auth;
                    set.configuration = config;

                    service.CollectionBrokerSet(set);

                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Detail.InnerXml.ToString());
                    logger.Info("Additional Info: " + se.Message);
                    Assert.AreEqual("The exception [collection-broker-set-name] was thrown.", se.Message,
                        "Incorrect exception thrown.");
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.ResetCollectionBrokerSettings(auth, s);
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerSet_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerSet set = new CollectionBrokerSet();
            CollectionBrokerSetConfiguration config = new CollectionBrokerSetConfiguration();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerSet_NameNotGlobal Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StartCollectionBrokerandWait(auth, s);

                try
                {
                    logger.Info("Submitting CollectionBrokerSet request.");

                    config.collectionbrokerconfiguration = new collectionbrokerconfiguration();
                    config.collectionbrokerconfiguration.name = "erin";

                    set.configuration = config;

                    service.CollectionBrokerSet(set);

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
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerGet_Started Server: " + s);
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
                    logger.Info("Submitting CollectionBrokerGet request.");
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
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerGet_Stopped()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerGet get = new CollectionBrokerGet();
            CollectionBrokerGetResponse response = new CollectionBrokerGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerGet_Stopped Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StopCollectionBrokerandWait(auth, s);

                // Configure request
                get.authentication = auth;

                try
                {
                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
                    Assert.IsTrue(response != null, "Response object returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup");
                    // Delete collection and stop broker.
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerGet_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerGet get = new CollectionBrokerGet();
            CollectionBrokerGetResponse response = new CollectionBrokerGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerGet_NoAuth Server: " + s);
                service.Url = s;

                //Setup
                TestUtilities.StopCollectionBrokerandWait(auth, s);

                try
                {
                    logger.Info("Submitting CollectionBrokerGet request.");
                    response = service.CollectionBrokerGet(get);

                    // Verify response
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
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }
    }
}
