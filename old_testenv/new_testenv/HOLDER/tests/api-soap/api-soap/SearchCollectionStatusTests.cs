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
    /// Contains tests for SearchCollectionStatus and SearchCollectionUrlStatusQuery
    /// </summary>
    [TestFixture]
    class SearchCollectionStatusTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void SearchCollectionUrlStatusQueryTest()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);


                try
                {
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus(); 
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    filter.name = crawlurlstatusfilterName.url;
                    filter.nameSpecified = true;
                    filter.comparison = crawlurlstatusfilterComparison.wc; 
                    filter.comparisonSpecified = true; 
                    filter.value = "*"; 
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation(); 
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and; 
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter[0] = filter;
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.IsTrue(response.crawlurlstatusresponse.crawlurl.Length == 55, "Incorrect number of URLs returned.");
                    
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }

        [Test]
        public void SearchCollectionUrlStatusQueryTest_NoMatches()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);


                try
                {
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    filter.name = crawlurlstatusfilterName.url;
                    filter.nameSpecified = true;
                    filter.comparison = crawlurlstatusfilterComparison.wc;
                    filter.comparisonSpecified = true;
                    filter.value = "erin";
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation();
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter[0] = filter;
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.IsTrue(response.crawlurlstatusresponse.crawlurl == null && response.crawlurlstatusresponse.errorSpecified == false,
                      "Urls returned or an error was returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void SearchCollectionUrlStatusQueryTest_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    filter.name = crawlurlstatusfilterName.url;
                    filter.nameSpecified = true;
                    filter.comparison = crawlurlstatusfilterComparison.wc;
                    filter.comparisonSpecified = true;
                    filter.value = "*";
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation();
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter[0] = filter;
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.IsTrue(response.crawlurlstatusresponse.crawlurl.Length == 55, "Incorrect number of URLs returned.");

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
        public void SearchCollectionUrlStatusQueryTest_NoFilter()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation();
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.IsTrue(response.crawlurlstatusresponse.errorSpecified == true, "An error should have been returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void SearchCollectionUrlStatusQueryTest_NocrawlUrlStatus()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest_NocrawlUrlStatus Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    response = service.SearchCollectionUrlStatusQuery(status);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void SearchCollectionUrlStatusQueryTest_NoForceSync()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);


                try
                {
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.forcesync = false;
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    filter.name = crawlurlstatusfilterName.url;
                    filter.nameSpecified = true;
                    filter.comparison = crawlurlstatusfilterComparison.wc;
                    filter.comparisonSpecified = true;
                    filter.value = "*";
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation();
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter[0] = filter;
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.IsTrue(response.crawlurlstatusresponse.crawlurl.Length == 55, "Incorrect number of URLs returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }

        [Test]
        public void SearchCollectionUrlStatusQueryTest_ForceSync()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest Server: " + s);
                service.Url = s;

                try
                {
                    XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                    TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                    TestUtilities.WaitIdle("samba-erin", auth, s);

                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.forcesync = true;
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    filter.name = crawlurlstatusfilterName.url;
                    filter.nameSpecified = true;
                    filter.comparison = crawlurlstatusfilterComparison.wc;
                    filter.comparisonSpecified = true;
                    filter.value = "*";
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation();
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter[0] = filter;
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.IsTrue(response.crawlurlstatusresponse.crawlurl.Length == 55, "Incorrect number of URLs returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void SearchCollectionUrlStatusQueryTest_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest_NoCollection Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);


                try
                {
                    status.authentication = auth;
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    filter.name = crawlurlstatusfilterName.url;
                    filter.nameSpecified = true;
                    filter.comparison = crawlurlstatusfilterComparison.wc;
                    filter.comparisonSpecified = true;
                    filter.value = "*";
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation();
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter[0] = filter;
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.IsTrue(response.crawlurlstatusresponse.crawlurl.Length == 55, "Incorrect number of URLs returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s); 
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void SearchCollectionUrlStatusQueryTest_Staging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest_Staging Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");

                try
                {
                    TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StopQueryService(auth, s);
                    TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                    TestUtilities.WaitIdle("samba-erin", auth, s);

                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.subcollection = SearchCollectionUrlStatusQuerySubcollection.staging;
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    filter.name = crawlurlstatusfilterName.url;
                    filter.nameSpecified = true;
                    filter.comparison = crawlurlstatusfilterComparison.wc;
                    filter.comparisonSpecified = true;
                    filter.value = "*";
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation();
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter[0] = filter;
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.IsTrue(response.crawlurlstatusresponse.crawlurl.Length == 55, "Incorrect number of URLs returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.SearchServiceStart(auth, s);
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void SearchCollectionUrlStatusQueryTest_NocrawledUrls()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.AddCollection(XmlToAdd, auth, s);

                try
                {
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    filter.name = crawlurlstatusfilterName.url;
                    filter.nameSpecified = true;
                    filter.comparison = crawlurlstatusfilterComparison.wc;
                    filter.comparisonSpecified = true;
                    filter.value = "*";
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation();
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter[0] = filter;
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.IsTrue(response.crawlurlstatusresponse.crawlurl == null && response.crawlurlstatusresponse.errorSpecified == false, 
                    "Incorrect number of URLs returned or an error was returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void SearchCollectionUrlStatusQueryTest_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionUrlStatusQuery status = new SearchCollectionUrlStatusQuery();
            SearchCollectionUrlStatusQueryResponse response = new SearchCollectionUrlStatusQueryResponse();
            SearchCollectionUrlStatusQueryCrawlurlstatus url = new SearchCollectionUrlStatusQueryCrawlurlstatus();
            crawlurlstatus urlstatus = new crawlurlstatus();
            crawlurlstatusfilter filter = new crawlurlstatusfilter();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionUrlStatusQueryTest Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");

                try
                {
                    TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    status.collection = "samba-erin";
                    status.crawlurlstatus = new SearchCollectionUrlStatusQueryCrawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus = new crawlurlstatus();
                    status.crawlurlstatus.crawlurlstatus.limit = 100;
                    status.crawlurlstatus.crawlurlstatus.limitSpecified = true;
                    status.forcesync = true;
                    filter.name = crawlurlstatusfilterName.url;
                    filter.nameSpecified = true;
                    filter.comparison = crawlurlstatusfilterComparison.wc;
                    filter.comparisonSpecified = true;
                    filter.value = "*";
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation = new crawlurlstatusfilteroperation();
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.name = crawlurlstatusfilteroperationName.and;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.nameSpecified = true;
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter = new crawlurlstatusfilter[1];
                    status.crawlurlstatus.crawlurlstatus.crawlurlstatusfilteroperation.crawlurlstatusfilter[0] = filter;
                    response = service.SearchCollectionUrlStatusQuery(status);

                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }



        [Test]
        public void SearchCollectionStatus()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionStatus Server: " + s);
                service.Url = s;

                try
                {
                    // Create collection
                    XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                    TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                    TestUtilities.WaitIdle("samba-erin", auth, s);


                    // Get status
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    response = service.SearchCollectionStatus(status);

                    // Check status
                    Assert.IsTrue(response.vsestatus.crawlerstatus != null && response.vsestatus.vseindexstatus != null,
                        "Incorrect status returned.");
                    Assert.IsTrue(response.vsestatus.which == vsestatusWhich.live, "Wrong Status returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionStatus_StaleOk()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionStatus_StaleOk Server: " + s);
                service.Url = s;

                try
                {
                    // Create collection
                    XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                    TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                    TestUtilities.WaitIdle("samba-erin", auth, s);


                    // Get status
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.staleok = true;
                    response = service.SearchCollectionStatus(status);

                    // Check status
                    Assert.IsTrue(response.vsestatus.crawlerstatus != null && response.vsestatus.vseindexstatus != null,
                        "Incorrect status returned.");
                    Assert.IsTrue(response.vsestatus.which == vsestatusWhich.live, "Wrong Status returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionStatus_StaleNotOk()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionStatus_StaleNotOk Server: " + s);
                service.Url = s;

                try
                {
                    // Create collection
                    XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                    TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                    TestUtilities.WaitIdle("samba-erin", auth, s);


                    // Get status
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.staleok = false;
                    response = service.SearchCollectionStatus(status);

                    // Check status
                    Assert.IsTrue(response.vsestatus.crawlerstatus != null && response.vsestatus.vseindexstatus != null,
                        "Incorrect status returned.");
                    Assert.IsTrue(response.vsestatus.which == vsestatusWhich.live, "Wrong Status returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }


        [Test]
        public void SearchCollectionStatus_Staging()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionStatus_Staging Server: " + s);
                service.Url = s;

                try
                {
                    // Create collection
                    TestUtilities.StopQueryService(auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                    TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                    
                    // Get status
                    status.authentication = auth;
                    status.collection = "samba-erin";
                    status.subcollection = SearchCollectionStatusSubcollection.staging;
                    response = service.SearchCollectionStatus(status);

                    // Check status
                    Assert.IsTrue(response.vsestatus != null, "No status returned.");
                    Assert.IsTrue(response.vsestatus.crawlerstatus != null && response.vsestatus.vseindexstatus != null,
                        "Incorrect status returned.");
                    Assert.IsTrue(response.vsestatus.which == vsestatusWhich.staging, "Wrong Status returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StartQueryService(auth, s);
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }


        [Test]
        public void SearchCollectionStatus_NoStatus()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            string collection = "SearchCollectionStatus_NotStarted";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionStatus_NoStatus Server: " + s);
                service.Url = s;


                try
                {
                    // Create Collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get Status
                    status.authentication = auth;
                    status.collection = collection;
                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response == null, "Status should not have been returned.");

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
        public void SearchCollectionStatus_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            string collection = "SearchCollectionStatus_NoCollection";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionStatus_NoCollection Server: " + s);
                service.Url = s;


                try
                {
                    // Create Collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get Status
                    status.authentication = auth;
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");

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


        [Test]
        public void SearchCollectionStatus_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            string collection = "SearchCollectionStatus_NoCollection";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionStatus_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    // Get Status
                    status.authentication = auth;
                    status.collection = collection;
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");

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
        public void SearchCollectionStatus_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            string collection = "SearchCollectionStatus_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionStatus_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    // Get Status
                    status.collection = collection;
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");

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
