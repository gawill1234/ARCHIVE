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
    class QueryBrowseTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        VelocityService service = new VelocityService();
        authentication auth = new authentication();

        [TestFixtureSetUp]
        public void Setup()
        {
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  
            auth.username = username;
            auth.password = password;
            XmlElement XmlToAdd;

            logger.Info("Test Fixture Setup");
            logger.Info("Create and crawl collection: oracle-1");
            TestUtilities.CreateSearchCollection("query-browse", auth, serverlist);
            XmlToAdd = TestUtilities.ReadXmlFile("query-browse.xml");
            TestUtilities.UpdateCollection(XmlToAdd, auth, serverlist);
            TestUtilities.StartCrawlandWait("query-browse", auth, serverlist);
        }

        [TestFixtureTearDown]
        public void Cleanup()
        {
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test Fixture Tear Down.");
            logger.Info("Delete collection: query-browse");
            TestUtilities.DeleteSearchCollection("query-browse", auth, serverlist);
        }


        [Test]
        public void QueryBrowse_ResultCount()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_NoAuth Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "";
                search.sources = "query-browse";

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(352, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QueryBrowse_BrowseNum6()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_BrowseNum6 Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.browsenum = 6;
                browse.browsenumSpecified = true;

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(352, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Total Results returned.");
                Assert.AreEqual(6, response.queryresults.list.document.Length,
                    "Incorrect List of Documents returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QueryBrowse_BrowseStart10()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_BrowseStart10 Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.browsenum = 50;
                browse.browsenumSpecified = true;
                browse.browsestart = 1;
                browse.browsestartSpecified = true;

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(352, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Total Results returned.");
                Assert.AreEqual(9, response.queryresults.list.document.Length,
                    "Incorrect List of Documents returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }


        [Test]
        [Ignore("Bug 23471")]
        public void QueryBrowse_BrowseNum0()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_BrowseNum0 Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.browsenum = 0;
                browse.browsenumSpecified = true;

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(352, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Total Results returned.");
                Assert.IsNull(response.queryresults.list,
                    "Incorrect List of Documents returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QueryBrowse_StateNonsense()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_NoAuth Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.state = "blah";
                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(352, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QueryBrowse_StateDefault()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_StateDefault Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.state = "root|root";
                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(352, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QueryBrowse_Query()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_Query Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "admiral";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        [Ignore("Bug 23493")]
        public void QueryBrowse_OutputDisplayLimited()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_OutputDisplayLimited Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "admiral";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.outputdisplaymode = QueryBrowseOutputdisplaymode.limited;

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");
                Assert.Fail("Requirements not known. This test needs validation for the excluded XML.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }


        [Test]
        public void QueryBrowse_OutputQueryNodeFalse()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_OutputQueryNodeFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "admiral";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.outputquerynode = false;

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");
                Assert.IsNull(response.queryresults.query, "Query Node returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QueryBrowse_OutputQueryNode()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_OutputQueryNode Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "admiral";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.outputquerynode = true;

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");
                Assert.IsNotNull(response.queryresults.query, "Query Node returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QueryBrowse_OutputBold()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_OutputBold Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "admiral";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.outputboldcontents = "title";

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");
                foreach (content c in response.queryresults.list.document[0].content)
                {
                    if (c.name == "title" && c.Value.Contains("admiral") == true)
                        Assert.IsTrue(c.Value.Contains("<b>") == true,
                            "Title doesn't contain bold text: " + c.Value);
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QueryBrowse_OutputBoldClassRoot()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_OutputBoldClassRoot Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "admiral";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.outputboldcontents = "title";
                browse.outputboldclusterclassroot = "erin";

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");
                foreach (content c in response.queryresults.list.document[0].content)
                {
                    if (c.name == "title" && c.Value.Contains("admiral") == true)
                        Assert.IsTrue(c.Value.Contains("<span class=\"erin0\"") == true,
                            "Title doesn't contain bold tag: " + c.Value);
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }
        
        [Test]
        public void QueryBrowse_OutputBoldExcept()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_OutputBoldExcept Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "admiral";
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);
                browse.outputboldcontents = "title";
                browse.outputboldcontentsexcept = true;

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");
                foreach (content c in response.queryresults.list.document[0].content)
                {
                    if (c.name == "title" && c.Value.Contains("admiral") == true)
                        Assert.IsFalse(c.Value.Contains("<b>") == true,
                            "Title doesn't contain bold text: " + c.Value);
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QueryBrowse_NoQuery()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_NoQuery Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.sources = collection;

                browse.authentication = auth;
                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                // Check results
                Assert.IsNotNull(response.queryresults, "No query results.");
                Assert.IsNotNull(response.queryresults.addedsource, "No addedsource returned.");
                Assert.AreEqual(352, response.queryresults.addedsource[0].totalresults,
                    "Incorrect Results returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QueryBrowse_NoFile()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_NoFile Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                browse.authentication = auth;

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                Assert.Fail("An exception should have been thrown.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleMissingVar(se);
            }
        }

        [Test]
        public void QueryBrowse_FileNotExist()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_NoFile Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                browse.authentication = auth;
                browse.file = "blah";

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                Assert.Fail("An exception should have been thrown.");

            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                Assert.AreEqual("The exception [metasearch-file-error] was thrown.", se.Message,
                    "Incorrect exception thrown.");
            }
        }

        [Test]
        public void QueryBrowse_NoAuth()
        {
            // Variables
            QueryBrowse browse = new QueryBrowse();
            QueryBrowseResponse response = new QueryBrowseResponse();
            QuerySearch search = new QuerySearch();
            string collection = "query-browse";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QueryBrowse_NoAuth Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Configure QuerySearch
                search.browse = true;
                search.authentication = auth;
                search.query = "";
                search.sources = collection;

                browse.file = TestUtilities.GetQueryBrowseFile(search, serverlist);

                logger.Info("Submitting QueryBrowse request.");
                response = service.QueryBrowse(browse);

                Assert.Fail("An exception should have been thrown.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleNoAuth(se);
            }
        }
    }
}
