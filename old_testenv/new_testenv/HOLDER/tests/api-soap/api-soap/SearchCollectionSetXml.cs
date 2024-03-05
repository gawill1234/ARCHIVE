using System;
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
    class SearchCollectionSetXmlTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

        [Test]
        public void SearchCollectionSetXmlTests_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionSetXml xml = new SearchCollectionSetXml();
            XmlElement XmltoAdd;
            SearchCollectionXml scxml = new SearchCollectionXml();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            string collection = "samba-erin";

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionSetXmlTests_Default Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile("samba-erin.xml");

                    // Set collection xml
                    xml.authentication = auth;
                    xml.collection = collection;
                    xml.xml = XmltoAdd;
                    service.SearchCollectionSetXml(xml);
                    
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
        public void SearchCollectionSetXmlTests_IndexerRunning()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionSetXml xml = new SearchCollectionSetXml();
            XmlElement XmltoAdd, XmltoAdd2;
            SearchCollectionXml scxml = new SearchCollectionXml();
            string collection = "samba-erin";
            string XmlFile = "samba-erin.xml";
            string XmlFile2 = "samba-erin-mod.xml";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionSetXmlTests_IndexerRunning Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    // Add collection
                    XmltoAdd = TestUtilities.ReadXmlFile(XmlFile);
                    TestUtilities.AddCollection(XmltoAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);

                    // Set collection xml
                    XmltoAdd2 = TestUtilities.ReadXmlFile(XmlFile2);
                    xml.authentication = auth;
                    xml.collection = collection;
                    xml.xml = XmltoAdd2;
                    service.SearchCollectionSetXml(xml);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndexStaging(collection, auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionSetXmlTests_DoAdd()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionSetXml xml = new SearchCollectionSetXml();
            XmlElement XmltoAdd;
            SearchCollectionXml scxml = new SearchCollectionXml();
            SearchCollectionListXml list = new SearchCollectionListXml();
            XmlElement element;
            string results = null;
            string collection = "samba-erin";
            string ResultCompare = "name=\"" + collection + "\"";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionSetXmlTests_DoAdd Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    XmltoAdd = TestUtilities.ReadXmlFile("samba-erin.xml");

                    // Set collection xml
                    xml.authentication = auth;
                    xml.collection = collection;
                    xml.doadd = true;
                    xml.xml = XmltoAdd;
                    service.SearchCollectionSetXml(xml);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                // Get List and verify newly created collection present
                list.authentication = auth;
                try
                {
                    element = service.SearchCollectionListXml(list);
                    results = element.InnerXml.ToString();
                    logger.Info("XML returned: " + results);
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");

                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        [Ignore ("Bug 23007.  Re-enabled when fixed.")]
        public void SearchCollectionSetXmlTests_DoAddCollectionExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionSetXml xml = new SearchCollectionSetXml();
            XmlElement XmltoAdd;
            SearchCollectionXml scxml = new SearchCollectionXml();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            string collection = "samba-erin";

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionSetXmlTests_DoAddCollectionExist Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile("samba-erin.xml");

                    // Set collection xml
                    xml.authentication = auth;
                    xml.collection = collection;
                    xml.doadd = true;
                    xml.xml = XmltoAdd;
                    service.SearchCollectionSetXml(xml);

                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-update-failed] was thrown.",
                        "Incorrect exception thrown.");
                }
                finally
                {
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        //[Ignore ("Known Bug: 21753")]
        public void SearchCollectionSetXmlTests_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionSetXml xml = new SearchCollectionSetXml();
            XmlElement XmltoAdd;
            SearchCollectionXml scxml = new SearchCollectionXml();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            string collection = "samba-erin";

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionSetXmlTests_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    XmltoAdd = TestUtilities.ReadXmlFile("samba-erin.xml");

                    // Set collection xml
                    xml.authentication = auth;
                    xml.collection = collection;
                    xml.xml = XmltoAdd;
                    service.SearchCollectionSetXml(xml);

                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-update-failed] was thrown.",
                        "Incorrect exception thrown.");
                }
                finally
                {
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionSetXmlTests_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionSetXml xml = new SearchCollectionSetXml();
            XmlElement XmltoAdd;
            SearchCollectionXml scxml = new SearchCollectionXml();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            string collection = "samba-erin";

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionSetXmlTests_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile("samba-erin.xml");

                    // Set collection xml
                    xml.collection = collection;
                    xml.xml = XmltoAdd;
                    service.SearchCollectionSetXml(xml);

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

        [Test]
        public void SearchCollectionSetXmlTests_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionSetXml xml = new SearchCollectionSetXml();
            XmlElement XmltoAdd;
            SearchCollectionXml scxml = new SearchCollectionXml();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            string collection = "samba-erin";

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionSetXmlTests_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile("samba-erin.xml");

                    // Set collection xml
                    xml.authentication = auth;
                    xml.xml = XmltoAdd;
                    service.SearchCollectionSetXml(xml);

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
        public void SearchCollectionSetXmlTests_NoXml()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionSetXml xml = new SearchCollectionSetXml();
            XmlElement XmltoAdd;
            SearchCollectionXml scxml = new SearchCollectionXml();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            string collection = "samba-erin";

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionSetXmlTests_NoXml Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmltoAdd = TestUtilities.ReadXmlFile("samba-erin.xml");

                    // Set collection xml
                    xml.authentication = auth;
                    xml.collection = collection;
                    service.SearchCollectionSetXml(xml);

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
    }
}
