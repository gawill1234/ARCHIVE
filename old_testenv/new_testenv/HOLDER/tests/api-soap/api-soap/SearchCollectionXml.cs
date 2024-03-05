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
    class SearchCollectionXmlTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void TestSearchCollectionXml_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionXml xml = new SearchCollectionXml();
            XmlNode scxml;
            string collection = "TestSearchCollectionXml_Default";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionXml_Default Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get Xml
                    xml.authentication = auth;
                    xml.collection = collection;
                    scxml = service.SearchCollectionXml(xml);
                    Assert.IsTrue(scxml.InnerXml != null, "Xml not returned.");

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
        public void TestSearchCollectionXml_WithData()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionXml xml = new SearchCollectionXml();
            XmlNode scxml;
            XmlElement XmltoAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionXml_WithData Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    XmltoAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
                    TestUtilities.AddCollection(XmltoAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("samba-erin", auth, s);
                    TestUtilities.WaitIdle("samba-erin", auth, s);

                    // Get Xml
                    xml.authentication = auth;
                    xml.collection = "samba-erin";
                    scxml = service.SearchCollectionXml(xml);
                    Assert.IsTrue(scxml.InnerXml != null, "Xml not returned.");

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
        public void TestSearchCollectionXml_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionXml xml = new SearchCollectionXml();
            XmlNode scxml;
            string collection = "TestSearchCollectionXml_CollectionNotExist";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionXml_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    // Get Xml
                    xml.authentication = auth;
                    xml.collection = collection;
                    scxml = service.SearchCollectionXml(xml);
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
        public void TestSearchCollectionXml_StaleNotOk()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionXml xml = new SearchCollectionXml();
            XmlNode scxml;
            string collection = "TestSearchCollectionXml_StaleNotOk";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionXml_StaleNotOk Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get Xml
                    xml.authentication = auth;
                    xml.collection = collection;
                    xml.staleok = false;
                    scxml = service.SearchCollectionXml(xml);
                    Assert.IsTrue(scxml.InnerXml != null, "Xml not returned.");

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
        public void TestSearchCollectionXml_StaleOk()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionXml xml = new SearchCollectionXml();
            XmlNode scxml;
            string collection = "TestSearchCollectionXml_StaleOk";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionXml_StaleOk Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get Xml
                    xml.authentication = auth;
                    xml.collection = collection;
                    xml.staleok = true;
                    scxml = service.SearchCollectionXml(xml);
                    Assert.IsTrue(scxml.InnerXml != null, "Xml not returned.");

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
        public void TestSearchCollectionXml_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionXml xml = new SearchCollectionXml();
            XmlNode scxml;
            string collection = "TestSearchCollectionXml_NoCollection";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionXml_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get Xml
                    xml.authentication = auth;
                    scxml = service.SearchCollectionXml(xml);
                    Assert.IsTrue(scxml.InnerXml != null, "Xml not returned.");

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
        public void TestSearchCollectionXml_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionXml xml = new SearchCollectionXml();
            XmlNode scxml;
            string collection = "TestSearchCollectionXml_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSearchCollectionXml_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get Xml
                    xml.collection = collection;
                    scxml = service.SearchCollectionXml(xml);
                    Assert.Fail("An exception should have been thrown.");

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

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

    }
}
