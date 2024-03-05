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
    class SearchService
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        VelocityService service = new VelocityService();
        authentication auth = new authentication();

        [Test]
        public void TestSearchServiceStatusXml()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceStatusXml status = new SearchServiceStatusXml();
            XmlElement response;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceSet Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                status.authentication = auth;
                response = service.SearchServiceStatusXml(status);
                Assert.IsFalse(response.IsEmpty, "Response is empty");
                Assert.AreEqual("vse-qs-status", response.Name, "Response has wrong name");
                Assert.AreEqual("", response.NamespaceURI, "Response has wrong namespace");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void TestSearchServiceStatusXml_NoAuth()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceStatusXml status = new SearchServiceStatusXml();
            XmlElement response;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceSet Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                response = service.SearchServiceStatusXml(status);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleNoAuth(se);
            }
        }

        [Test]
        public void TestSearchServiceSet()
        {
            // Variables
            auth.password = password;
            auth.username = username;
            SearchServiceSet set = new SearchServiceSet();
            SearchServiceSetConfiguration config = new SearchServiceSetConfiguration();
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();
            SearchServiceGet getInitial = new SearchServiceGet();
            SearchServiceGetResponse responseInitial = new SearchServiceGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceSet Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                getInitial.authentication = auth;
                responseInitial = service.SearchServiceGet(getInitial);

                set.authentication = auth;
                config.vseqs = new vseqs();
                config.vseqs.id = "1";
                config.vseqs.vseqsoption = new vseqsoption();
                config.vseqs.vseqsoption.allowips = "true";
                set.configuration = config;
                service.SearchServiceSet(set);

                get.authentication = auth;
                response = service.SearchServiceGet(get);
                Assert.AreEqual("true", response.vseqs.vseqsoption.allowips,
                    "Specified options not set.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                set.configuration.vseqs = responseInitial.vseqs;
                service.SearchServiceSet(set);
            }
        }

        [Test]
        public void TestSearchServiceSet_NoOption()
        {
            // Variables
            auth.password = password;
            auth.username = username;
            SearchServiceSet set = new SearchServiceSet();
            SearchServiceSetConfiguration config = new SearchServiceSetConfiguration();
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();
            SearchServiceGet getInitial = new SearchServiceGet();
            SearchServiceGetResponse responseInitial = new SearchServiceGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceSet_NoOption Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                getInitial.authentication = auth;
                responseInitial = service.SearchServiceGet(getInitial);

                set.authentication = auth;
                config.vseqs = new vseqs();
                config.vseqs.id = "1";
                set.configuration = config;
                service.SearchServiceSet(set);

                get.authentication = auth;
                response = service.SearchServiceGet(get);
                Assert.IsTrue(response.vseqs.id != null, "Specified options not set.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                set.configuration.vseqs = responseInitial.vseqs;
                service.SearchServiceSet(set);
            }
        }

        /// <summary>
        /// I would expect this to not be permitted, but the value is ok'd
        /// even through the admin tool.
        /// </summary>
        [Test]
        public void TestSearchServiceSet_NonsenseValue()
        {
            // Variables
            auth.password = password;
            auth.username = username;
            SearchServiceSet set = new SearchServiceSet();
            SearchServiceSetConfiguration config = new SearchServiceSetConfiguration();
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();
            SearchServiceGet getInitial = new SearchServiceGet();
            SearchServiceGetResponse responseInitial = new SearchServiceGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceSet Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                getInitial.authentication = auth;
                responseInitial = service.SearchServiceGet(getInitial);

                set.authentication = auth;
                config.vseqs = new vseqs();
                config.vseqs.vseqsoption = new vseqsoption();
                config.vseqs.vseqsoption.allowips = "erin";
                set.configuration = config;
                service.SearchServiceSet(set);

                get.authentication = auth;
                response = service.SearchServiceGet(get);
                Assert.AreEqual("erin", response.vseqs.vseqsoption.allowips,
                    "Specified options not set.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                set.configuration.vseqs = responseInitial.vseqs;
                service.SearchServiceSet(set);
            }
        }

        [Test]
        public void TestSearchServiceSet_EmptyConfig()
        {
            // Variables
            auth.password = password;
            auth.username = username;
            SearchServiceSet set = new SearchServiceSet();
            SearchServiceSetConfiguration config = new SearchServiceSetConfiguration();
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();
            SearchServiceGet getInitial = new SearchServiceGet();
            SearchServiceGetResponse responseInitial = new SearchServiceGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            getInitial.authentication = auth;
            responseInitial = service.SearchServiceGet(getInitial);

            logger.Info("Test: TestSearchServiceSet Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                set.authentication = auth;
                set.configuration = config;
                service.SearchServiceSet(set);

                get.authentication = auth;
                response = service.SearchServiceGet(get);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("AdditionalInfo: " + se.Detail.InnerXml);
                Assert.IsTrue(se.Message == "The exception [libxml-xsl-generic-error] was thrown.",
                    "Incorrect exception thrown.");
            }
            finally
            {
                set.configuration.vseqs = responseInitial.vseqs;
                service.SearchServiceSet(set);
            }
        }

        [Test]
        public void TestSearchServiceSet_NoConfig_22693()
        {
            // Variables
            auth.password = password;
            auth.username = username;
            SearchServiceSet set = new SearchServiceSet();
            SearchServiceSetConfiguration config = new SearchServiceSetConfiguration();
            SearchServiceGet getInitial = new SearchServiceGet();
            SearchServiceGetResponse responseInitial = new SearchServiceGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceSet_NoConfig Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                getInitial.authentication = auth;
                responseInitial = service.SearchServiceGet(getInitial);

                set.authentication = auth;
                config.vseqs = new vseqs();
                config.vseqs.id = "1";
                config.vseqs.vseqsoption = new vseqsoption();
                config.vseqs.vseqsoption.allowips = "true";
                service.SearchServiceSet(set);

                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Detail.InnerXml.ToString());
                logger.Info("Additional Info: " + se.Message);
                Assert.AreEqual("The exception [libxml-xsl-generic-error] was thrown.", se.Message,
                    "Incorrect exception thrown.");
            }
        }

        [Test]
        public void TestSearchServiceSet_NoAuth()
        {
            // Variables
            auth.password = password;
            auth.username = username;
            SearchServiceSet set = new SearchServiceSet();
            SearchServiceSetConfiguration config = new SearchServiceSetConfiguration();
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceSet Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                config.vseqs = new vseqs();
                config.vseqs.id = "1";
                config.vseqs.vseqsoption = new vseqsoption();
                config.vseqs.vseqsoption.allowips = "true";
                set.configuration = config;
                service.SearchServiceSet(set);

                get.authentication = auth;
                response = service.SearchServiceGet(get);
            }
            catch (SoapException se)
            {
                TestUtilities.HandleNoAuth(se);
            }
        }

        [Test]
        public void TestSearchServiceGet()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceGet Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                get.authentication = auth;
                response = service.SearchServiceGet(get);
                Assert.IsTrue(response.vseqs != null, "Search Service not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void TestSearchServiceGet_Started()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceGet Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                TestUtilities.StartQueryService(auth, serverlist);
                get.authentication = auth;
                response = service.SearchServiceGet(get);
                Assert.IsTrue(response.vseqs != null, "Search Service not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void TestSearchServiceGet_Stopped()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceGet Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                TestUtilities.StopQueryService(auth, serverlist);
                get.authentication = auth;
                response = service.SearchServiceGet(get);
                Assert.IsTrue(response.vseqs != null, "Search Service not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void TestSearchServiceGet_NoAuth()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceGet get = new SearchServiceGet();
            SearchServiceGetResponse response = new SearchServiceGetResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceGet_NoAuth Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                response = service.SearchServiceGet(get);
                Assert.IsTrue(response.vseqs != null, "Search Service not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleNoAuth(se);
            }
        }

        [Test]
        public void TestSearchServiceRestart()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceRestart restart = new SearchServiceRestart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceRestart Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                restart.authentication = auth;
                service.SearchServiceRestart(restart);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist), "Service not started.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void TestSearchServiceRestart_Stopped()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceRestart restart = new SearchServiceRestart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceRestart_Stopped Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                TestUtilities.StopQueryService(auth, serverlist);
                restart.authentication = auth;
                service.SearchServiceRestart(restart);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist),
                    "Service not started.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void TestSearchServiceRestart_Started()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceRestart restart = new SearchServiceRestart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceRestart_Started Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                TestUtilities.StartQueryService(auth, serverlist);
                restart.authentication = auth;
                service.SearchServiceRestart(restart);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist),
                    "Service not started.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void TestSearchServiceRestart_NoAuth()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceRestart restart = new SearchServiceRestart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceRestart_NoAuth Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                service.SearchServiceRestart(restart);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist), "Service not started.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleNoAuth(se);
            }
        }

        [Test]
        public void TestSearchServiceStop()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceStop stop = new SearchServiceStop();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceStop Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                stop.authentication = auth;
                service.SearchServiceStop(stop);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist) == false,
                    "Service not stopped.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                TestUtilities.StartQueryService(auth, serverlist);
            }
        }

        [Test]
        public void TestSearchServiceStop_AlreadyStopped()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceStop stop = new SearchServiceStop();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceStop_AlreadyStopped Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                TestUtilities.StartQueryService(auth, serverlist);
                stop.authentication = auth;
                service.SearchServiceStop(stop);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist) == false,
                    "Service not stopped.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                TestUtilities.StartQueryService(auth, serverlist);
            }
        }

        [Test]
        public void TestSearchServiceStop_NoAuth()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceStop stop = new SearchServiceStop();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceStop_NoAuth Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                service.SearchServiceStop(stop);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist) == false, "Service not stopped.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleNoAuth(se);
            }
            finally
            {
                TestUtilities.StartQueryService(auth, serverlist);
            }
        }

        [Test]
        public void TestSearchServiceStop_Started()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceStop stop = new SearchServiceStop();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceStop_Started Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                TestUtilities.SearchServiceStart(auth, serverlist);
                stop.authentication = auth;
                service.SearchServiceStop(stop);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist) == false, "Service not stopped.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                TestUtilities.StartQueryService(auth, serverlist);
            }
        }

        [Test]
        public void TestSearchServiceStart()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceStart start = new SearchServiceStart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceStart Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                start.authentication = auth;
                service.SearchServiceStart(start);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist), "Service not started.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void TestSearchServiceStart_AlreadyStarted()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceStart start = new SearchServiceStart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceStart_AlreadyStarted Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                start.authentication = auth;
                service.SearchServiceStart(start);
                service.SearchServiceStart(start);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist), "Service not started.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void TestSearchServiceStart_NoAuth()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceStart start = new SearchServiceStart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceStart_NoAuth Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                service.SearchServiceStart(start);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleNoAuth(se);
            }
        }

        [Test]
        public void TestSearchServiceStart_KnowStopped()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            SearchServiceStart start = new SearchServiceStart();
            SearchServiceStop stop = new SearchServiceStop();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestSearchServiceStart_KnowStopped Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                stop.authentication = auth;
                service.SearchServiceStop(stop);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist) == false,
                    "Service not stopped.");
                start.authentication = auth;
                service.SearchServiceStart(start);
                Assert.IsTrue(TestUtilities.IsQueryServiceStarted(auth, serverlist),
                    "Service not started.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

    }
}
