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
    class SearchCollectionListTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings["username"];
        string password = ConfigurationManager.AppSettings["password"];
        string serverlist = ConfigurationManager.AppSettings["serverlist"];
        string [] servers;

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

        // Tests
        /// <summary>
        /// Test that submits a request to the service requesting a list
        /// of all SearchCollectionLists.  This test checks that there is 
        /// a non-empty XML Element returned.
        /// </summary>
        [Test]
        public void TestSearchCollectionList()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement element;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            // Configure for servers to run tests against
            this.GetServers();
            foreach (string s in this.servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionList Server: " + s);

                // Set authentication
                SearchCollectionListXml xml = new SearchCollectionListXml();
                xml.authentication = auth;

                try
                {
                    element = service.SearchCollectionListXml(xml);
                    Assert.IsTrue(element.HasChildNodes == true, "No search collections returned.");
                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }
            }
        }
        
        /// <summary>
        /// This test submits a request to SearchCollectionListXml with no
        /// auth object.
        /// </summary>
        [Test]
        public void TestSearchCollectionList_NoAuth()
        {
            VelocityService service = new VelocityService();
            XmlElement element;
            SearchCollectionListXml xml = new SearchCollectionListXml();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            // Configure for servers to run tests against
            this.GetServers();
            foreach (string s in this.servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionList_NoAuth Server: " + s);

                try
                {
                    element = service.SearchCollectionListXml(xml);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
            }
        }

        /// <summary>
        /// This test will add a SearchCollection, then query SearchCollectionListXml
        /// and ensure that the added SearchCollection was returned in list.
        /// </summary>
        [Test]
        public void TestSearchCollectionList_Add()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = this.username;
            auth.password = this.password;
            XmlElement element;
            SearchCollectionListXml list = new SearchCollectionListXml();
            SearchCollectionCreate create = new SearchCollectionCreate();
            string results = null;
            SearchCollectionDelete delete = new SearchCollectionDelete();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            // Result Compare String
            string ResultCompare = "name=\"TestSearchCollectionList_Add\"";

            // Configure for servers to run tests against
            this.GetServers();
            foreach (string s in this.servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionList_Add Server: " + s);

                // Create call using defaults where available.
                create.authentication = auth;
                create.collection = "TestSearchCollectionList_Add";
                try
                {
                    service.SearchCollectionCreate(create);
                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                // Get List and verify newly created collection present
                list.authentication = auth;
                try
                {
                    element = service.SearchCollectionListXml(list);
                    results = element.InnerXml.ToString();
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");
                    logger.Info("XML returned:  " + results);
                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    // Delete the created collection
                    delete.authentication = auth;
                    delete.collection = "TestSearchCollectionList_Add";
                    service.SearchCollectionDelete(delete);
                }
            }

        }

        /// <summary>
        /// This test will add a SearchCollection and query SearchCollectionListXml to
        /// ensure the added Search Collection was returned in the list.  The newly added
        /// collection will then be deleted.  The SearchCollectionListXml call will then be
        /// made again to ensure the deleted collection wasn't returned.
        /// </summary>
        [Test]
        public void TestSearchCollectionList_Delete()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = this.username;
            auth.password = this.password;
            XmlElement element;
            SearchCollectionListXml list = new SearchCollectionListXml();
            SearchCollectionCreate create = new SearchCollectionCreate();
            string results = null;
            SearchCollectionDelete delete = new SearchCollectionDelete();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            // Result Compare String
            string ResultCompare = "name=\"TestSearchCollectionList_Add\"";

            // Configure for servers to run tests against
            this.GetServers();
            foreach (string s in this.servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionList_Delete Server: " + s);

                // Create call using defaults where available.
                create.authentication = auth;
                create.collection = "TestSearchCollectionList_Add";
                try
                {
                    service.SearchCollectionCreate(create);
                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                // Get List and verify newly created collection present
                list.authentication = auth;
                try
                {
                    element = service.SearchCollectionListXml(list);
                    results = element.InnerXml.ToString();
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");
                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                // Delete the created collection
                delete.authentication = auth;
                delete.collection = "TestSearchCollectionList_Add";
                service.SearchCollectionDelete(delete);

                // Query the collection again
                element = service.SearchCollectionListXml(list);
                results = element.InnerXml.ToString();
                Assert.IsFalse(results.Contains(ResultCompare), "Added Search Collection found in SearchCollectionListXml.");
                logger.Info("XML returned: " + results);
            }
        }
    }
}
