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
    class CollectionBrokerSearchTests2
    {        // Variables
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
            TestUtilities.CreateSearchCollection("oracle-1", auth, serverlist);
            XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
            TestUtilities.UpdateCollection(XmlToAdd, auth, serverlist);
            TestUtilities.StartCrawlandWait("oracle-1", auth, serverlist);

            logger.Info("Create and crawl collection: samba-erin");
            TestUtilities.CreateSearchCollection("samba-erin", auth, serverlist);
            XmlToAdd = TestUtilities.ReadXmlFile("samba-erin.xml");
            TestUtilities.UpdateCollection(XmlToAdd, auth, serverlist);
            TestUtilities.StartCrawlandWait("samba-erin", auth, serverlist);

            logger.Info("Create and crawl collection: binning-1");
            TestUtilities.CreateSearchCollection("binning-1", auth, serverlist);
            XmlToAdd = TestUtilities.ReadXmlFile("binning.xml");
            TestUtilities.UpdateCollection(XmlToAdd, auth, serverlist);
            TestUtilities.StartCrawlandWaitStaging("binning-1", auth, serverlist);
            TestUtilities.WaitIdle("binning-1", auth, serverlist);

        }

        [TestFixtureTearDown]
        public void Cleanup()
        {
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test Fixture Tear Down.");
            logger.Info("Delete collection: oracle-1");
            TestUtilities.DeleteSearchCollection("oracle-1", auth, serverlist);

            logger.Info("Delete collection: samba-erin");
            TestUtilities.DeleteSearchCollection("samba-erin", auth, serverlist);

            logger.Info("Delete collection: samba-erin");
            TestUtilities.DeleteSearchCollection("binning-1", auth, serverlist);
        }

        [Test]
        public void CollectionBrokerSearch_SyntaxRepositoryNodeNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SyntaxRepositoryNodeNotExist Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral OR hipper";
                search.collection = "oracle-1";

                search.syntaxrepositorynode = "erin";

                response = service.CollectionBrokerSearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                Assert.AreEqual("The exception [collection-broker-search] was thrown.", se.Message,
                    "Incorrect exception thrown.");
                Assert.IsTrue(se.Detail.InnerXml.Contains("xml-macro-reference-error"),
                    "Expected text not within exception.");
            }
        }

        /// <summary>
        /// This works differently than I would expect because of the way .Net creates the SOAP
        /// packet.  I would not expect the OR to be recognized as a valid query syntax operator
        /// as I am explicitly setting the parameter to null.  When the SOAP packet is created,
        /// the syntaxoperators parameter is not included so the server side uses the default.
        /// </summary>
        public void CollectionBrokerSearch_SyntaxOperatorsNull()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SyntaxOperatorsNull Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral OR hipper";
                search.collection = "oracle-1";

                search.syntaxoperators = null;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(4, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SyntaxOperatorsInvalid()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SyntaxOperatorsInvalid Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral OR hipper";
                search.collection = "oracle-1";

                search.syntaxoperators = "ERIN";

                response = service.CollectionBrokerSearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                Assert.AreEqual("The exception [collection-broker-search] was thrown.", se.Message,
                    "Incorrect exception thrown.");
                Assert.IsTrue(se.Detail.InnerXml.Contains("query-undefined-operator-error"),
                    "Expected text not within exception.");
            }
        }

        [Test]
        public void CollectionBrokerSearch_RankDecayNegative()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_RankDecayNegative Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.sortby = "date";
                search.rankdecay = -1;
                search.rankdecaySpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect added source status.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SortNumPassagesNegative()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SortNumPassagesNegative Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.sortby = "date";
                search.sortnumpassages = -1;
                search.sortnumpassagesSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect added source status.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SortScoreXPathInvalid_22189()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SortScoreXPathInvalid Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";

                search.sortscorexpath = "erin";
                search.outputscore = true;
                search.outputscoreSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect added source status.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
                Assert.Greater(3, response.collectionbrokersearchresponse.queryresults.list.document[0].score,
                    "Score not calculated correctly.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SortScoreXPathEmpty()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SortScoreXPath Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";

                search.sortscorexpath = "";
                search.outputscore = true;
                search.outputscoreSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect added source status.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
                Assert.Less(2, response.collectionbrokersearchresponse.queryresults.list.document[0].score,
                    "Score not calculated correctly.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SortXPathsDes()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SortXPathsDes Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";

                // Configure sort
                CollectionBrokerSearchSortxpaths xpaths = new CollectionBrokerSearchSortxpaths();
                sort[] sorts = new sort[1];
                sorts[0] = new sort();
                sorts[0].order = sortOrder.descending;
                sorts[0].xpath = "$last-modified";
                xpaths.sort = sorts;
                search.sortxpaths = xpaths;

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect added source status.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SortXPathsEmpty_22471()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SortXPathsEmpty Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";

                // Configure sort
                CollectionBrokerSearchSortxpaths xpaths = new CollectionBrokerSearchSortxpaths();
                sort[] sorts = new sort[1];
                sorts[0] = new sort();
                xpaths.sort = sorts;
                search.sortxpaths = xpaths;

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect added source status.");
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SortByNoQuery()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SortByNoCollectionBroker Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.collection = "oracle-1";
                search.sortby = "date";

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect added source status.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(10, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SortByNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SortByNotExist Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.sortby = "erin";

                response = service.CollectionBrokerSearch(search);
                Assert.AreEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Error status not returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BrowseStartNeg()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_BrowseStartNeg Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.collection = "oracle-1";

                search.start = 10;
                search.nummax = 20;
                search.nummaxSpecified = true;

                search.browse = true;
                search.browsestart = -10;
                search.nummax = 167;
                search.nummaxSpecified = true;


                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.file,
                    "No temp file saved.");

                // Check file to make sure it started past 10.
                QueryBrowse browse = new QueryBrowse();
                browse.authentication = auth;
                browse.file = response.collectionbrokersearchresponse.queryresults.file;
                QueryBrowseResponse qbResponse = new QueryBrowseResponse();
                qbResponse = service.QueryBrowse(browse);
                Assert.IsNotNull(qbResponse.queryresults.list, "No results returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryConditionObjectNull_22471()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryConditionObjectNull Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.queryobject = new CollectionBrokerSearchQueryobject();
                search.queryobject.@operator = new @operator();
                search.queryobject.@operator.logic = "and";
                term te = new term();
                te.field = "title";
                te.str = "achates";
                search.queryobject.@operator.Items = new Object[1];
                search.queryobject.@operator.Items[0] = te;
                search.collection = "oracle-1";
                search.queryconditionobject = new CollectionBrokerSearchQueryconditionobject();

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(1, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryConditionObjectOperatorNull_22417()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryConditionObjectOperatorNull Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.queryobject = new CollectionBrokerSearchQueryobject();
                search.queryobject.@operator = new @operator();
                search.queryobject.@operator.logic = "and";
                term te = new term();
                te.field = "title";
                te.str = "achates";
                search.queryobject.@operator.Items = new Object[1];
                search.queryobject.@operator.Items[0] = te;
                search.collection = "oracle-1";
                search.queryconditionobject = new CollectionBrokerSearchQueryconditionobject();
                search.queryconditionobject.@operator = null;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(1, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryConditionObjectOperatorEmpty_22417()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryConditionObjectOperatorEmpty Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.queryobject = new CollectionBrokerSearchQueryobject();
                search.queryobject.@operator = new @operator();
                search.queryobject.@operator.logic = "and";
                term te = new term();
                te.field = "title";
                te.str = "admiral";
                search.queryobject.@operator.Items = new Object[1];
                search.queryobject.@operator.Items[0] = te;
                search.collection = "oracle-1";
                search.queryconditionobject = new CollectionBrokerSearchQueryconditionobject();
                search.queryconditionobject.@operator = new @operator();

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryModificationMacroNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryModificationMacro Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.collection = "oracle-1";
                search.query = "uk";
                search.num = 100;

                search.querymodificationmacros = "test";

                response = service.CollectionBrokerSearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                Assert.AreEqual("The exception [collection-broker-search] was thrown.", se.Message,
                    "Incorrect exception thrown: " + se.Message.ToString());
                Assert.IsTrue(se.Detail.InnerXml.Contains("xml-macro-reference-error"),
                    "Incorrect reason for exception.");
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryConditionXPathInvalid()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryConditionXPath Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.collection = "oracle-1";
                search.query = "uk";
                search.num = 100;

                search.queryconditionxpath = "blah";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list,
                    "Results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryConditionXPathNotIndexed()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryConditionXPathNotIndexed Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.collection = "oracle-1";
                search.query = "uk";
                search.num = 100;

                search.queryconditionxpath = "$ALIGNED='allied'";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list,
                    "Results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryObjectNull()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryObjectNull Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.queryobject = null;
                search.collection = "oracle-1";
                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(10, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryObjectNullOperator()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryObjectNullOperator Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.queryobject = new CollectionBrokerSearchQueryobject();
                search.queryobject.@operator = null;
                search.collection = "oracle-1";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(10, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_StartMax()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_StartMax Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";
                search.start = 500;
                response = service.CollectionBrokerSearch(search);

                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_DictionaryNull()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_DictionaryNull Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.collection = "oracle-1";
                search.dictexpanddictionary = null;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No result returned.");
                Assert.AreEqual(10, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SpellingNoCorrection()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SpellingNoCorrection Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.spellingenabled = true;
                search.collection = "oracle-1";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.spellingcorrection,
                    "Incorrect spelling correction returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_CollectionNone()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SourcesNone Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                response = service.CollectionBrokerSearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleMissingVar(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputBoldContentsExcept()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputBoldContentsExcept Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.num = 3;
                search.outputboldcontents = "title";
                search.outputboldcontentsexcept = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list, "No results returned.");
                foreach (content c in response.collectionbrokersearchresponse.queryresults.list.document[0].content)
                {
                    if (c.name == "title")
                        Assert.IsFalse(c.Value.Contains("<b>"),
                            "Title contains bold text");
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputShinglesFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputShinglesFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.num = 3;
                search.outputshingles = false;
                search.outputshinglesSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list, "No results returned.");
                foreach (document d in response.collectionbrokersearchresponse.queryresults.list.document)
                {
                    Assert.IsNull(d.mwishingle, "Shingles returned for document: " + d.mwishingle);
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_CollectionNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_CollectionNotExist Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "idontexist";
                response = service.CollectionBrokerSearch(search);
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list, "Incorrect results returned.");
                Assert.IsTrue(response.collectionbrokersearchresponse.queryresults.addedsource[0].status == addedsourceStatus.unknown,
                    "Incorrect status returned.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                Assert.AreEqual("The exception [collection-broker-search] was thrown.", se.Message,
                    "Incorrect exception thrown: " + se.Message.ToString());
                Assert.IsTrue(se.Detail.InnerXml.Contains("COLLECTION_BROKER_COLLECTION_DOES_NOT_EXIST"),
                    "Incorrect reason for exception.");
            }
        }

        [Test]
        public void CollectionBrokerSearch_FetchFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_FetchFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "samba-erin";
                search.fetch = false;

                response = service.CollectionBrokerSearch(search);

                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list,
                    "Results returned.");
                Assert.IsTrue(response.collectionbrokersearchresponse.queryresults.addedsource[0].nofetch == addedsourceNofetch.nofetch,
                    "NoFetch has wrong setting.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputDuplicatesFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputDuplicatesFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "samba-erin";
                search.outputduplicates = false;
                search.outputduplicatesSpecified = true;

                response = service.CollectionBrokerSearch(search);

                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsTrue(response.collectionbrokersearchresponse.queryresults.list.document.Length == 10,
                    "Not enough results.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputContents_Except()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputContents_Except Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.outputcontentsmode = CollectionBrokerSearchOutputcontentsmode.except;
                search.outputcontents = "title";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                foreach (content content in response.collectionbrokersearchresponse.queryresults.list.document[0].content)
                {
                    if (content.name == "title")
                    {
                        Assert.Fail("A title was returned.");
                    }
                }
                Assert.Pass("No titles were returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputContents_NoContent()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputContents_NoContent Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "samba-erin";
                search.outputcontentsmode = CollectionBrokerSearchOutputcontentsmode.list;
                search.outputcontents = "title";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                foreach (content content in response.collectionbrokersearchresponse.queryresults.list.document[0].content)
                {
                    if (content.name == "title")
                    {
                        Assert.Fail("A title was returned.");
                    }
                }
                Assert.Pass("No titles were returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputScoreFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputScoreFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "samba-erin";
                search.outputscore = false;
                search.outputscoreSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                        "No results returned.");
                Assert.AreNotEqual(0, response.collectionbrokersearchresponse.queryresults.list.document[0].score,
                        "A score was returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputCacheDataFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputCacheDataFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "samba-erin";
                search.outputcachedata = false;
                search.outputcachedataSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                        "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list.document[0].cache,
                        "Cache data was returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputCacheReferencesFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputCacheReferencesFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "samba-erin";
                search.outputcachereferences = false;
                search.outputcachereferencesSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                if (response.collectionbrokersearchresponse.queryresults.list.document[0].content[4].name == "snippet")
                {
                    Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list.document[0].content[4].Value,
                        "A snippet was not returned.");
                }
                else
                    Assert.Fail("Correct results not returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputSummaryFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputSummaryFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "samba-erin";
                search.outputsummary = false;
                search.outputsummarySpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                foreach (content content in response.collectionbrokersearchresponse.queryresults.list.document[0].content)
                {
                    if (content.name == "snippet")
                    {
                        Assert.Fail("A snippet was returned.");
                    }
                }
                Assert.Pass("No snippets were returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputKeyFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputKeyFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "acasta";
                search.collection = "oracle-1";
                search.outputkey = false;
                search.outputkeySpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list.document[0].key,
                    "No key returned for result.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_Num0()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Num0 Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";
                search.num = 0;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_Empty()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Empty Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                response = service.CollectionBrokerSearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleMissingVar(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_NoAuth()
        {
            // Variables
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_NoAuth Server: " + serverlist);
            service.Url = serverlist;

            try
            {

                search.query = "";
                search.collection = "oracle-1";
                response = service.CollectionBrokerSearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleNoAuth(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BinningModeOff()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Binning Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "binning-1";

                search.binningmode = CollectionBrokerSearchBinningmode.off;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.binning,
                    "Binning was returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BinningStateNull()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_BinningStateNull Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.collection = "binning-1";

                search.binningmode = CollectionBrokerSearchBinningmode.defaults;
                search.forcebinning = true;
                search.binningstate = null;

                response = service.CollectionBrokerSearch(search);

                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.binning.binningset,
                    "No bins returned.");
                Assert.AreNotEqual(0, response.collectionbrokersearchresponse.queryresults.binning.binningset[0].bin.Length,
                    "No bins.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BinningStateInvalid()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_BinningState Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.collection = "binning-1";

                search.binningmode = CollectionBrokerSearchBinningmode.defaults;
                search.forcebinning = true;
                search.binningstate = "me";

                response = service.CollectionBrokerSearch(search);

                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list, "Results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_ClusterFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_ClusterFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";

                search.cluster = false;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.tree,
                    "Clusters were created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_ClusterStemmersNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_ClusterStemmersNotExist Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";

                search.cluster = true;
                search.clusterstemmers = "delanguage english erin";

                response = service.CollectionBrokerSearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                Assert.AreEqual("The exception [collection-broker-search] was thrown.", se.Message,
                    "Incorrect exception thrown: " + se.Message.ToString());
                Assert.IsTrue(se.Detail.InnerXml.Contains("options-invalid-stemmer-error"),
                    "Incorrect reason for exception.");
            }
        }

        [Test]
        public void CollectionBrokerSearch_ClusterKbsNull()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Cluster Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";

                search.cluster = true;
                search.clusterkbs = null;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.tree,
                    "Clusters were created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        [Ignore("Replace when 22195 is fixed.")]
        public void CollectionBrokerSearch_ClusterSegmenterNotExist_22195()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_ClusterSegmenter Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";

                search.cluster = true;
                search.clustersegmenter = "erin";

                response = service.CollectionBrokerSearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                Assert.AreEqual("The exception [collection-broker-search] was thrown.", se.Message,
                    "Incorrect exception thrown: " + se.Message.ToString());
                Assert.IsTrue(se.Detail.InnerXml.Contains("options-invalid-stemmer-error"),
                    "Incorrect reason for exception.");
            }
        }

        [Test]
        public void CollectionBrokerSearch_ClusterKbsNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Cluster Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";

                search.cluster = true;
                search.clusterkbs = "erin";

                response = service.CollectionBrokerSearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                Assert.AreEqual("The exception [collection-broker-search] was thrown.", se.Message,
                    "Incorrect exception thrown: " + se.Message.ToString());
                Assert.IsTrue(se.Detail.InnerXml.Contains("indexer-bad-stoplist-error"),
                    "Incorrect reason for exception.");
            }
        }
    }
}
