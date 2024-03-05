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
    class SearchCollectionUpdateConfigurationTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void TestSearchCollectionUpdateConfiguration()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUpdateConfiguration update = new SearchCollectionUpdateConfiguration();
            string collection = "TestSearchCollectionUpdateConfiguration";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionUpdateConfiguration Server: " + s);
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
        public void TestSearchCollectionUpdateConfiguration_CrawlRunning()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUpdateConfiguration update = new SearchCollectionUpdateConfiguration();
            XmlElement XmltoAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionUpdateConfiguration_CollectionNotExist Server: " + s);
                service.Url = s;

                XmltoAdd = TestUtilities.ReadXmlFile("searchcollectionupdate.xml");
                TestUtilities.CreateSearchCollection("SearchCollectionUpdateConfig", auth, s);
                TestUtilities.UpdateCollection(XmltoAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("SearchCollectionUpdateConfig", auth, s);
                TestUtilities.WaitIdle("SearchCollectionUpdateConfig", auth, s);

                try
                {
                    update.authentication = auth;
                    update.collection = "SearchCollectionUpdateConfig";
                    service.SearchCollectionUpdateConfiguration(update);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("SearchCollectionUpdateConfig", auth, s);
                    TestUtilities.StopCrawlAndIndexStaging("SearchCollectionUpdateConfig", auth, s);
                    TestUtilities.DeleteSearchCollection("SearchCollectionUpdateConfig", auth, s);
                }
            }

        }

        [Test]
        public void TestSearchCollectionUpdateConfiguration_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUpdateConfiguration update = new SearchCollectionUpdateConfiguration();
            string collection = "TestSearchCollectionUpdateConfiguration_CollectionNotExist";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionUpdateConfiguration_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    update.authentication = auth;
                    update.collection = collection;
                    service.SearchCollectionUpdateConfiguration(update);

                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.",
                        "Incorrect exception thrown.");

                }
                finally
                {
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void TestSearchCollectionUpdateConfiguration_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUpdateConfiguration update = new SearchCollectionUpdateConfiguration();
            string collection = "TestSearchCollectionUpdateConfiguration_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionUpdateConfiguration_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    update.collection = collection;
                    service.SearchCollectionUpdateConfiguration(update);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void TestSearchCollectionUpdateConfiguration_Nocollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUpdateConfiguration update = new SearchCollectionUpdateConfiguration();
            string collection = "TestSearchCollectionUpdateConfiguration_Nocollection";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionUpdateConfiguration_Nocollection Server: " + s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    update.authentication = auth;
                    service.SearchCollectionUpdateConfiguration(update);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
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
