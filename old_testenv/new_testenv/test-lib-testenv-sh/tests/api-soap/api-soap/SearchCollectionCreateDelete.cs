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
    /// This set of tests works with the following API methods:
    ///     SearchCollectionCreate
    ///     SearchCollectionDelete
    /// While these calls are used in other tests, these tests are
    /// specifically exercising these methods.
    /// </summary>
    [TestFixture]
    class SearchCollectionCreateDelete
    {
        // Variables
        string username = ConfigurationManager.AppSettings["username"];
        string password = ConfigurationManager.AppSettings["password"];
        string serverlist = ConfigurationManager.AppSettings["serverlist"];
        string[] servers;

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

        /// <summary>
        /// This test creates a valid Search Collection, queries search collection
        /// list to ensure it was added, then deletes it.
        /// </summary>
        [Test]
        public void TestSearchCollectionCreate_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string ResultCompare = "name=\"TestSearchCollectionCreate_Default\"";
            string collection = "TestSearchCollectionCreate_Default";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCreate_Default Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.collection = collection;
                sc.authentication = auth;
                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();
                string results = null;
                XmlElement element;

                try
                {
                    service.SearchCollectionCreate(sc);
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
                    logger.Info("XML returned: " + results);
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");

                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    // Delete the created collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        /// <summary>
        /// This test attempts to create a search collection without passing an
        /// auth object.  The test checks the exception returned to ensure it is 
        /// the expected exception.
        /// </summary>
        [Test]
        public void TestSearchCollectionCreate_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            string collection = "TestSearchCollectionCreate_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCreate_NoAuth Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.collection = collection;
                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();

                try
                {
                    service.SearchCollectionCreate(sc);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
            }
        }

        [Test]
        public void TestSearchCollectionCreate_NoName()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCreate_NoName Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.authentication = auth;
                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();

                try
                {
                    service.SearchCollectionCreate(sc);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
            }
        }



        /// <summary>
        /// This test creates a search collection, then attempts to create a second with
        /// the same name.  The exception is checked to ensure the appropriate exception
        /// was thrown.
        /// </summary>
        [Test]
        public void TestSearchCollectionCreate_DuplicateName()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string collection = "SearchCollectionCreate_DuplicateName";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCreate_DuplicateName Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.authentication = auth;
                sc.collection = collection;
                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();

                // Create two search collections with the same name.  The second call should throw an exception.
                try
                {
                    service.SearchCollectionCreate(sc);
                    service.SearchCollectionCreate(sc);
                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-already-exists] was thrown.",
                    "The appropriate SoapException was not thrown.");

                }
                finally
                {
                    // Delete the created collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void TestSearchCollectionCreate_InvalidName()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string collection = "TestSearchCollectionCreate_InvalidName";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCreate_InvalidName Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.authentication = auth;
                sc.collection = collection;
                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();

                // Create two search collections with the same name.  The second call should throw an exception.
                try
                {
                    service.SearchCollectionCreate(sc);
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
                    // Delete the created collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        /// <summary>
        /// This test creates a search collection and includes the collection meta
        /// information.
        /// </summary>
        [Test]
        public void TestSearchCollectionCreate_MetaInfo()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string ResultCompare = "name=\"TestSearchCollectionCreate_MetaInfo\"";
            string collection = "TestSearchCollectionCreate_MetaInfo";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCreate_MetaInfo Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.authentication = auth;
                sc.collection = collection;
                sc.collectionmeta = new SearchCollectionCreateCollectionmeta();
                sc.collectionmeta.vsemeta = new vsemeta();
                sc.collectionmeta.vsemeta.vsemetainfo = new vsemetainfo[1];
                sc.collectionmeta.vsemeta.vsemetainfo[0] = new vsemetainfo();
                sc.collectionmeta.vsemeta.vsemetainfo[0].livecrawldir = "c:\\foo1\\live";
                sc.collectionmeta.vsemeta.vsemetainfo[0].stagingcrawldir = "c:\\foo2\\staging";
                sc.collectionmeta.vsemeta.vsemetainfo[0].cachedir = "c:\\foo3\\cache";

                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();
                string results = null;
                XmlElement element;

                try
                {
                    service.SearchCollectionCreate(sc);
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
                    logger.Info("XML returned: " + results);
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");

                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    // Delete the created collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        /// <summary>
        /// This test creates a search collection and includes the collection meta
        /// information.  No LiveDir information is specified in the call.  It would
        /// be expected that this call should fail.
        /// </summary>
        [Test]
        public void TestSearchCollectionCreate_MetaInfoNoLiveDir()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string ResultCompare = "name=\"TestSearchCollectionCreate_MetaInfoNoLiveDir\"";
            string collection = "TestSearchCollectionCreate_MetaInfoNoLiveDir";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCreate_MetaInfoNoLiveDir Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.authentication = auth;
                sc.collection = collection;
                sc.collectionmeta = new SearchCollectionCreateCollectionmeta();
                sc.collectionmeta.vsemeta = new vsemeta();
                sc.collectionmeta.vsemeta.vsemetainfo = new vsemetainfo[1];
                sc.collectionmeta.vsemeta.vsemetainfo[0] = new vsemetainfo();
                sc.collectionmeta.vsemeta.vsemetainfo[0].stagingcrawldir = "c:\\foo2\\staging";
                sc.collectionmeta.vsemeta.vsemetainfo[0].cachedir = "c:\\foo3\\cache";

                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();
                string results = null;
                XmlElement element;

                try
                {
                    service.SearchCollectionCreate(sc);
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
                    logger.Info("XML returned: " + results);
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");

                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    // Delete the created collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        /// <summary>
        /// This test creates a search collection and includes the collection meta
        /// information.  No CacheDir information is specified in the call.  It would
        /// be expected that this call should fail.
        /// </summary>
        [Test]
        public void TestSearchCollectionCreate_MetaInfoNoCacheDir()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string ResultCompare = "name=\"TestSearchCollectionCreate_MetaInfoNoCacheDir\"";
            string collection = "TestSearchCollectionCreate_MetaInfoNoCacheDir";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCreate_MetaInfoNoCacheDir Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.authentication = auth;
                sc.collection = collection;
                sc.collectionmeta = new SearchCollectionCreateCollectionmeta();
                sc.collectionmeta.vsemeta = new vsemeta();
                sc.collectionmeta.vsemeta.vsemetainfo = new vsemetainfo[1];
                sc.collectionmeta.vsemeta.vsemetainfo[0] = new vsemetainfo();
                sc.collectionmeta.vsemeta.vsemetainfo[0].livecrawldir = "c:\\foo1\\live";
                sc.collectionmeta.vsemeta.vsemetainfo[0].stagingcrawldir = "c:\\foo2\\staging";

                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();
                string results = null;
                XmlElement element;

                try
                {
                    service.SearchCollectionCreate(sc);
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
                    logger.Info("XML returned: " + results);
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");

                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    // Delete the created collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        /// <summary>
        /// This test creates a search collection and includes the collection meta
        /// information.  No StagingDir information is specified in the call.  It would
        /// be expected that this call should fail.
        /// </summary>

        [Test]
        public void TestSearchCollectionCreate_MetaInfoNoStagingDir()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string ResultCompare = "name=\"TestSearchCollectionCreate_MetaInfoNoStagingDir\"";
            string collection = "TestSearchCollectionCreate_MetaInfoNoStagingDir";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCreate_MetaInfoNoStagingDir Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.authentication = auth;
                sc.collection = collection;
                sc.collectionmeta = new SearchCollectionCreateCollectionmeta();
                sc.collectionmeta.vsemeta = new vsemeta();
                sc.collectionmeta.vsemeta.vsemetainfo = new vsemetainfo[1];
                sc.collectionmeta.vsemeta.vsemetainfo[0] = new vsemetainfo();
                sc.collectionmeta.vsemeta.vsemetainfo[0].livecrawldir = "c:\\foo1\\live";
                sc.collectionmeta.vsemeta.vsemetainfo[0].cachedir = "c:\\foo3\\cache";

                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();
                string results = null;
                XmlElement element;

                try
                {
                    service.SearchCollectionCreate(sc);
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
                    logger.Info("XML returned: " + results);
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");

                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    // Delete the created collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }
        /// <summary>
        /// This test creates a search collection and specifies the optional field
        /// description.  The test verifies that the description is set correctly
        /// when the search collection list is checked.  The newly created search
        /// collection is then deleted.
        /// </summary>
        [Test]
        public void TestSearchCollectionCreate_Description()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string ResultCompare = "description=\"Test TestSearchCollectionCreate_Description\"";
            string collection = "TestSearchCollectionCreate_Description";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionCreate_Description Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.authentication = auth;
                sc.collection = collection;
                sc.description = "Test TestSearchCollectionCreate_Description";
                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();
                string results = null;
                XmlElement element;

                try
                {
                    service.SearchCollectionCreate(sc);
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
                    logger.Info("XML returned: " + results);
                    Assert.IsTrue(results.Contains(ResultCompare), "Description not set for added search collection.");

                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    // Delete the created collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }

        }

        /// <summary>
        /// This test creates a search collection and attempts to delete it without
        /// the delete call passing an auth object.  The finally block will ensure that 
        /// the search collection is deleted by including a second call with the auth 
        /// object.
        /// </summary>
        [Test]
        public void TestSearchCollectionDelete_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string ResultCompare = "name=\"TestSearchCollectionDelete_NoAuth\"";
            string collection = "TestSearchCollectionDelete_NoAuth";
            this.GetServers();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionDelete_NoAuth Server: " + s);

                // Configure search collection
                SearchCollectionCreate sc = new SearchCollectionCreate();
                sc.authentication = auth;
                sc.collection = collection;
                SearchCollectionDelete delete = new SearchCollectionDelete();
                SearchCollectionListXml list = new SearchCollectionListXml();
                string results = null;
                XmlElement element;

                try
                {
                    service.SearchCollectionCreate(sc);
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
                    logger.Info("XML returned: " + results);
                    Assert.IsTrue(results.Contains(ResultCompare), "Added Search Collection not found in SearchCollectionListXml.");

                }
                catch (SoapException se)
                {
                    APITests.TestUtilities.HandleSoapException(se);
                }

                try
                {
                    // Delete the created collection
                    delete.collection = "TestSearchCollectionDelete_NoAuth";
                    service.SearchCollectionDelete(delete);
                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Code.ToString() == "urn:/velocity/objects:rights-execute", "The appropriate SoapException was not thrown.");

                }
                finally
                {
                    // Delete the created collection
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        /// <summary>
        /// This test attempts to delete a search collection that does not exist.
        /// </summary>
        [Test]
        public void TestSearchCollectionDelete_NotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionDelete_NotExist Server: " + s);

                SearchCollectionDelete delete = new SearchCollectionDelete();
                delete.authentication = auth;
                delete.collection = "TestSearchCollectionDelete_NotExist";

                try
                {
                    // Delete a collection that doesn't exist
                    service.SearchCollectionDelete(delete);
                }
                catch (SoapException se)
                {
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [search-collection-invalid-name] was thrown.", 
                        "The appropriate SoapException was not thrown.");
                }

            }
        }

        [Test]
        public void TestSearchCollectionDelete_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            this.GetServers();

            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSearchCollectionDelete_NoCollection Server: " + s);

                SearchCollectionDelete delete = new SearchCollectionDelete();
                delete.authentication = auth;

                try
                {
                    // Delete a collection that doesn't exist
                    service.SearchCollectionDelete(delete);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }

            }
        }
    }
}
