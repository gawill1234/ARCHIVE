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
    class SearchCollectionPushStagingTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void TestSearchCollectionPushStaging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionPushStaging push = new SearchCollectionPushStaging();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionCrawlerStart startcrawler = new SearchCollectionCrawlerStart();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionPushStaging Server: " + s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StopQueryService(auth, s);
                    System.Threading.Thread.Sleep(2000);

                    // Start Crawler
                    startcrawler.authentication = auth;
                    startcrawler.collection = "oracle-1";
                    startcrawler.subcollection = SearchCollectionCrawlerStartSubcollection.staging;
                    status.authentication = auth;
                    status.collection = "oracle-1";
                    status.subcollection = SearchCollectionStatusSubcollection.staging;

                    service.SearchCollectionCrawlerStart(startcrawler);

                    System.Threading.Thread.Sleep(4000);

                    while (true)
                    {
                        // Get status
                        System.Threading.Thread.Sleep(1000);
                        statusresponse = service.SearchCollectionStatus(status);
                        if (statusresponse == null)
                            break;
                        if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                            statusresponse.vsestatus.vseindexstatus.idletime > 0)
                            break;
                        if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                            statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                            break;
                        logger.Info("Crawl status: " + statusresponse.vsestatus.crawlerstatus.servicestatus.ToString());
                        logger.Info("Index status: " + statusresponse.vsestatus.vseindexstatus.servicestatus.ToString());

                        System.Threading.Thread.Sleep(1000);
                    }

                    //TestUtilities.StartQueryService(auth, s);

                    // need a way to keep the collection in staging to do a push...
                    push.collection = "oracle-1";
                    push.authentication = auth;
                    TestUtilities.StartQueryService(auth, s);
                    service.SearchCollectionPushStaging(push);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    status.authentication = auth;
                    status.collection = "oracle-1";
                    status.subcollection = SearchCollectionStatusSubcollection.staging;
                    statusresponse = service.SearchCollectionStatus(status);
                    Assert.AreEqual(null, statusresponse, 
                        "Collection not live, status returned for staging.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("oracle-1", auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void TestSearchCollectionPushStaging_InvalidException()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionPushStaging push = new SearchCollectionPushStaging();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();


            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionPushStaging_InvalidException Server: " + s);
                service.Url = s;

                try
                {
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.AddCollection(XmlToAdd, auth, s);
                    
                    TestUtilities.StartCrawlandWaitStaging("oracle-1", auth, s);

                    // need a way to keep the collection in staging to do a push...
                    push.collection = "oracle-1";
                    push.authentication = auth;
                    service.SearchCollectionPushStaging(push);

                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                    Assert.IsTrue(se.Message == "The exception [search-collection-push-staging] was thrown.",
                        "Incorrect exception thrown.");

                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("oracle-1", auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void TestSearchCollectionPushStaging_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionPushStaging push = new SearchCollectionPushStaging();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();


            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionPushStaging_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    TestUtilities.StartCrawlandWaitStaging("oracle-1", auth, s);

                    // need a way to keep the collection in staging to do a push...
                    push.collection = "oracle-1";
                    service.SearchCollectionPushStaging(push);

                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("oracle-1", auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void TestSearchCollectionPushStaging_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionPushStaging push = new SearchCollectionPushStaging();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();


            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionPushStaging_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    TestUtilities.StartCrawlandWaitStaging("oracle-1", auth, s);

                    // need a way to keep the collection in staging to do a push...
                    push.authentication = auth;
                    service.SearchCollectionPushStaging(push);

                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("oracle-1", auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

    }
}
