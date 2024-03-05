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
    class SearchCollectionReadOnlyTests
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
        public void SearchCollectionReadOnlyTests_Status()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            SearchCollectionReadOnlyResponse response = new SearchCollectionReadOnlyResponse();
            string collection = "SearchCollectionReadOnlyTests_Status";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionReadOnlyTests_Status Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get the read-only status of the search collection
                    scro.authentication = auth;
                    scro.collection = collection;
                    response = service.SearchCollectionReadOnly(scro);

                    Assert.IsTrue(response.readonlystate.mode == readonlystateMode.disabled, "The read-only mode is not disabled");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Cleanup
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionReadOnlyTests_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            SearchCollectionReadOnlyResponse response = new SearchCollectionReadOnlyResponse();
            string collection = "SearchCollectionReadOnlyTests_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionReadOnlyTests_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get the read-only status of the search collection
                    scro.collection = collection;
                    response = service.SearchCollectionReadOnly(scro);

                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    // Cleanup
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionReadOnlyTests_Enable()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            SearchCollectionReadOnlyResponse response = new SearchCollectionReadOnlyResponse();
            string collection = "SearchCollectionReadOnlyTests_Enable";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionReadOnlyTests_Enable Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get the read-only status of the search collection
                    scro.authentication = auth;
                    scro.collection = collection;
                    scro.mode = SearchCollectionReadOnlyMode.status;
                    response = service.SearchCollectionReadOnly(scro);
                    logger.Info("Read-only mode: " + response.readonlystate.mode);
                    Assert.IsTrue(response.readonlystate.mode == readonlystateMode.disabled, "The read-only mode is not disabled");

                    // Enable read-only mode for the collection
                    TestUtilities.EnableReadOnlyandWait(collection, auth, s);

                    // Get the read-only status of the search collection
                    scro.mode = SearchCollectionReadOnlyMode.status;
                    response = service.SearchCollectionReadOnly(scro);
                    Assert.IsTrue(response.readonlystate.mode == readonlystateMode.enabled, "The read-only mode is not enabled");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Cleanup
                    TestUtilities.DisableReadOnlyandWait(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionReadOnlyTests_UpdateRepository()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            SearchCollectionReadOnlyResponse response = new SearchCollectionReadOnlyResponse();
            string collection = "SearchCollectionReadOnlyTests_UpdateRepository";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionReadOnlyTests_UpdateRepository Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get the read-only status of the search collection
                    scro.authentication = auth;
                    scro.collection = collection;
                    scro.mode = SearchCollectionReadOnlyMode.status;
                    response = service.SearchCollectionReadOnly(scro);
                    logger.Info("Read-only mode: " + response.readonlystate.mode);
                    Assert.IsTrue(response.readonlystate.mode == readonlystateMode.disabled, "The read-only mode is not disabled");

                    // Enable read-only mode for the collection
                    TestUtilities.EnableReadOnlyandWait(collection, auth, s);

                    // Get the read-only status of the search collection
                    scro.mode = SearchCollectionReadOnlyMode.status;
                    response = service.SearchCollectionReadOnly(scro);
                    Assert.IsTrue(response.readonlystate.mode == readonlystateMode.enabled, "The read-only mode is not enabled");

                    XmlToAdd = TestUtilities.ReadXmlFile("SearchCollectionReadOnlyTests_UpdateRepository.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Cleanup
                    TestUtilities.DisableReadOnlyandWait(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }


        [Test]
        public void SearchCollectionReadOnlyTests_Disable()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            SearchCollectionReadOnlyResponse response = new SearchCollectionReadOnlyResponse();
            string collection = "SearchCollectionReadOnlyTests_Disable";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionReadOnlyTests_Disable Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get the read-only status of the search collection
                    scro.authentication = auth;
                    scro.collection = collection;
                    scro.mode = SearchCollectionReadOnlyMode.status;
                    response = service.SearchCollectionReadOnly(scro);
                    logger.Info("Read-only mode: " + response.readonlystate.mode);

                    // Enable read-only mode for the collection
                    TestUtilities.EnableReadOnlyandWait(collection, auth, s);

                    // Get the read-only status of the search collection
                    scro.mode = SearchCollectionReadOnlyMode.status;
                    response = service.SearchCollectionReadOnly(scro);
                    Assert.IsTrue(response.readonlystate.mode == readonlystateMode.enabled, "The read-only mode is not enabled");

                    // Disable read-only mode for the collection
                    scro.mode = SearchCollectionReadOnlyMode.disable;
                    response = service.SearchCollectionReadOnly(scro);
                    Assert.IsTrue(response.readonlystate.mode == readonlystateMode.disabled, "The read-only mode is not disabled");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Cleanup
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionReadOnlyTests_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            string collection = "SearchCollectionReadOnlyTests_NoCollection";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionReadOnlyTests_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    // Add collection
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Get the read-only status of the search collection
                    scro.authentication = auth;
                    service.SearchCollectionReadOnly(scro);

                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    // Cleanup
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void SearchCollectionReadOnlyTests_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            string collection = "TestSearchCollectionReadOnly_CollectionNotExist";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionReadOnlyTests_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    // Get the read-only status of the search collection
                    scro.authentication = auth;
                    scro.collection = collection;
                    service.SearchCollectionReadOnly(scro);

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
        public void SearchCollectionReadOnlyTests_EnabledModifyCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            SearchCollectionReadOnlyResponse response = new SearchCollectionReadOnlyResponse();
            string collection = "SearchCollectionReadOnlyTests_EnabledModifyCollection";
            SearchCollectionDelete delete = new SearchCollectionDelete();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: SearchCollectionReadOnlyTests_EnabledModifyCollection Server: " + s);
                service.Url = s;

                try
                {
                    // Test Setup
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    // Configure request
                    scro.authentication = auth;
                    scro.collection = collection;
                    scro.mode = SearchCollectionReadOnlyMode.enable;
                    delete.authentication = auth;
                    delete.collection = collection;
                    delete.killservices = true;

                    response = service.SearchCollectionReadOnly(scro);
                    Assert.AreNotEqual(null, response, "No response returned.");

                    // Attempt to modify and catch exception.
                    service.SearchCollectionDelete(delete);

                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                    Assert.AreEqual("The exception [search-collection-delete-read-only] was thrown.", se.Message,
                        "Incorrect exception thrown.");
                }
                finally
                {
                    TestUtilities.DisableReadOnlyandWait(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }

        }

        [Test]
        public void SearchCollectionReadOnlyTests_EnabledQuery()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            SearchCollectionReadOnlyResponse scResponse = new SearchCollectionReadOnlyResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: QuerySearch_DictionaryNull Server: " + s);
                service.Url = s;

                try
                {
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    TestUtilities.EnableReadOnlyandWait("oracle-1", auth, s);

                    search.authentication = auth;
                    search.query = "uk";
                    search.sources = "oracle-1";
                    search.dictexpanddictionary = null;
                    response = service.QuerySearch(search);
                    Assert.IsTrue(response.queryresults.list.document.Length == 10, "Incorrect results returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.DisableReadOnlyandWait("oracle-1", auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }

        }
    }
}
