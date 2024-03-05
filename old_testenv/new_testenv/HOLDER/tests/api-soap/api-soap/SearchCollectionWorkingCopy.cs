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
    class SearchCollectionWorkingCopy
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void TestSearchCollectionWorkingCopyDelete()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            SearchCollectionWorkingCopyDelete delete = new SearchCollectionWorkingCopyDelete();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyDelete Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response.vsestatus != null, "Working Copy not Created.");

                    delete.authentication = auth;
                    delete.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyDelete(delete);
                    logger.Info("Working Copy deleted.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                try
                {
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.",
                    "The appropriate SoapException was not thrown.");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.StopCrawlAndIndexStaging("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }

        [Test]
        public void TestSearchCollectionWorkingCopyDelete_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            SearchCollectionWorkingCopyDelete delete = new SearchCollectionWorkingCopyDelete();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyDelete Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response.vsestatus != null, "Working Copy not Created.");

                    delete.authentication = auth;
                    delete.collection = "samba-5";
                    service.SearchCollectionWorkingCopyDelete(delete);

                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response.vsestatus != null, "Working Copy not Deleted.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.",
                        "Incorrect exception thrown.");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void TestSearchCollectionWorkingCopyDelete_NoworkingCopy()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyDelete delete = new SearchCollectionWorkingCopyDelete();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyDelete_NoworkingCopy Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    delete.authentication = auth;
                    delete.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyDelete(delete);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                try
                {
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.",
                    "The appropriate SoapException was not thrown.");
                }

                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void TestSearchCollectionWorkingCopyDelete_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            SearchCollectionWorkingCopyDelete delete = new SearchCollectionWorkingCopyDelete();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyDelete_NoCollection Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response.vsestatus != null, "Working Copy not Created.");

                    delete.authentication = auth;
                    service.SearchCollectionWorkingCopyDelete(delete);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void TestSearchCollectionWorkingCopyDelete_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            SearchCollectionWorkingCopyDelete delete = new SearchCollectionWorkingCopyDelete();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyDelete_NoAuth Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response.vsestatus != null, "Working Copy not Created.");

                    delete.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyDelete(delete);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }

            }
        }


        [Test]
        public void TestSearchCollectionWorkingCopyCreate()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyCreate Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response.vsestatus != null, "Working Copy not Created.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }

        [Test]
        public void TestSearchCollectionWorkingCopyCreate_AlreadyExists()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyCreate_AlreadyExists Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.IsTrue(response.vsestatus != null, "Working Copy not Created.");

                    service.SearchCollectionWorkingCopyCreate(create);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    logger.Info("Additional info: " + se.Detail);
                    Assert.IsTrue(se.Message == "The exception [search-collection-working-copy-exists] was thrown.",
                        "Incorrect exception thrown.");

                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }

        [Test]
        public void TestSearchCollectionWorkingCopyCreate_NoData()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyCreate_NoData Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    logger.Info("Additional info: " + se.Detail);
                    Assert.IsTrue(se.Message == "The exception [search-collection-working-copy-no-live-data] was thrown.",
                        "Incorrect exception thrown.");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }



        [Test]
        public void TestSearchCollectionWorkingCopyCreate_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyCreate_NoCollection Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    service.SearchCollectionWorkingCopyCreate(create);

                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }


        [Test]
        public void TestSearchCollectionWorkingCopyCreate_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            XmlElement XmlToAdd;
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyCreate_NoAuth Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }

        [Test]
        public void TestSearchCollectionWorkingCopyAccept()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            SearchCollectionWorkingCopyAccept accept = new SearchCollectionWorkingCopyAccept();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyAccept Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    accept.authentication = auth;
                    accept.collection = "samba-erin";
                    TestUtilities.StartQueryService(auth, s);
                    service.SearchCollectionWorkingCopyAccept(accept);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                try
                {
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.",
                    "The appropriate SoapException was not thrown.");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }

        [Test]
        public void TestSearchCollectionWorkingCopyAccept_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            SearchCollectionWorkingCopyAccept accept = new SearchCollectionWorkingCopyAccept();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyAccept_CollectionNotExist Server: " + s);
                service.Url = s;

                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    accept.authentication = auth;
                    accept.collection = "samba-5";
                    TestUtilities.StartQueryService(auth, s);
                    service.SearchCollectionWorkingCopyAccept(accept);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.",
                        "Incorrect exception thrown.");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }


        [Test]
        public void TestSearchCollectionWorkingCopyAccept_NoData()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyAccept accept = new SearchCollectionWorkingCopyAccept();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyAccept Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    accept.authentication = auth;
                    accept.collection = "samba-erin";
                    TestUtilities.StartQueryService(auth, s);
                    service.SearchCollectionWorkingCopyAccept(accept);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    logger.Info("Additional info: " + se.Detail);
                    Assert.IsTrue(se.Message == "The exception [libxml-xsl-generic-error] was thrown.",
                        "Incorrect exception thrown.");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }


        [Test]
        public void TestSearchCollectionWorkingCopyAccept_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            SearchCollectionWorkingCopyAccept accept = new SearchCollectionWorkingCopyAccept();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyAccept_NoCollection Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    accept.authentication = auth;
                    TestUtilities.StartQueryService(auth, s);
                    service.SearchCollectionWorkingCopyAccept(accept);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }


        [Test]
        public void TestSearchCollectionWorkingCopyAccept_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionWorkingCopyCreate create = new SearchCollectionWorkingCopyCreate();
            SearchCollectionWorkingCopyAccept accept = new SearchCollectionWorkingCopyAccept();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse response = new SearchCollectionStatusResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionWorkingCopyAccept_NoAuth Server: " + s);
                service.Url = s;

                XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                TestUtilities.CreateSearchCollection("samba-erin", auth, s);
                TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                TestUtilities.WaitIdle("samba-erin", auth, s);

                try
                {
                    create.authentication = auth;
                    create.collection = "samba-erin";
                    service.SearchCollectionWorkingCopyCreate(create);

                    accept.collection = "samba-erin";
                    TestUtilities.StartQueryService(auth, s);
                    service.SearchCollectionWorkingCopyAccept(accept);

                    status.authentication = auth;
                    status.collection = "samba-erin(working-copy)";
                    response = service.SearchCollectionStatus(status);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex("samba-erin", auth, s);
                    TestUtilities.DeleteSearchCollection("samba-erin", auth, s);
                }
            }
        }


        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }
    }
}
