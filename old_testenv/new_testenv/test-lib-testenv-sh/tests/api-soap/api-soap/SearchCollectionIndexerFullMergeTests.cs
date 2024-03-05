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
    class SearchCollectionIndexerFullMergeTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void SearchCollectionIndexerFullMerge_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionIndexerFullMerge index = new SearchCollectionIndexerFullMerge();
            string collection = "SCIndexerFullMerge";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();


            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionIndexerFullMerge_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    logger.Info("Test Setup.");

                    logger.Info("Submitting request.");
                    index.authentication = auth;
                    index.collection = collection;

                    service.SearchCollectionIndexerFullMerge(index);
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
                    logger.Info("Test Cleanup.");
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void SearchCollectionIndexerFullMerge_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionIndexerFullMerge index = new SearchCollectionIndexerFullMerge();
            XmlElement XmlToAdd;
            string collection = "SCIndexerFullMerge";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();


            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionIndexerFullMerge_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("SCIndexerFullMerge.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);

                    logger.Info("Submitting request.");
                    index.authentication = auth;

                    service.SearchCollectionIndexerFullMerge(index);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    logger.Info("Test Cleanup.");
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionIndexerFullMerge_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionIndexerFullMerge index = new SearchCollectionIndexerFullMerge();
            XmlElement XmlToAdd;
            string collection = "SCIndexerFullMerge";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();


            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionIndexerFullMerge_Default Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("SCIndexerFullMerge.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);

                    logger.Info("Submitting request.");
                    index.authentication = auth;
                    index.collection = collection;

                    service.SearchCollectionIndexerFullMerge(index);


                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Test Cleanup.");
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void SearchCollectionIndexerFullMerge_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionIndexerFullMerge index = new SearchCollectionIndexerFullMerge();
            XmlElement XmlToAdd;
            string collection = "SCIndexerFullMerge";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();


            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionIndexerFullMerge_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("SCIndexerFullMerge.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);

                    logger.Info("Submitting request.");
                    index.collection = collection;
                    service.SearchCollectionIndexerFullMerge(index);

                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    logger.Info("Test Cleanup.");
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
