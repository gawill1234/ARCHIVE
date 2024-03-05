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
    class CollectionBrokerSearchTests
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
        public void CollectionBrokerSearch_DefaultsOneCollection()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_DefaultsOneCollection Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";
                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list, "No results returned.");
                Assert.AreEqual(10, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SyntaxOperatorsAnd()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SyntaxOperatorsAnd Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral OR hipper";
                search.collection = "oracle-1";

                search.syntaxoperators = "AND";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SyntaxRepositoryNode()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SyntaxRepositoryNode Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral OR hipper";
                search.collection = "oracle-1";

                search.syntaxrepositorynode = "custom";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list, "No results returned.");
                Assert.AreEqual(4, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SyntaxOperatorsOrNotinList()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SyntaxOperatorsOrNotinList Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral OR hipper";
                search.collection = "oracle-1";

                search.syntaxoperators = "AND";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SortBy()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SortBy Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.sortby = "date";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list, "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect AddedSourceStatus.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        [Ignore("Replace when 22192 is fixed.")]
        public void CollectionBrokerSearch_OutputSortKeys()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputSortKeys Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.sortby = "date";
                search.sortscorexpath = "$score";
                search.outputsortkeys = true;
                search.outputsortkeysSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect added source Status");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list, "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length, "Incorrect results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list.document[0].sortkey,
                    "Sort keys not included with document.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_RankDecay()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_RankDecay Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.sortby = "date";
                search.rankdecay = 1;
                search.rankdecaySpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect Added Source Status.");
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
        public void CollectionBrokerSearch_RankDecay0()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_RankDecay0 Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.sortby = "date";
                search.rankdecay = 0;
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
        public void CollectionBrokerSearch_RankDecaySmall()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_RankDecaySmall Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.sortby = "date";
                search.rankdecay = 0.1;
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
        public void CollectionBrokerSearch_RankDecayLarge()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_RankDecayLarge Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.sortby = "date";
                search.rankdecay = 100000;
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
        public void CollectionBrokerSearch_SortNumPassages()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SortNumPassages Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.sortby = "date";
                search.sortnumpassages = 1;
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
        public void CollectionBrokerSearch_SortXPaths()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SortXPaths Server: " + serverlist);
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
                sorts[0].order = sortOrder.ascending;
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
        public void CollectionBrokerSearch_SortScoreXPathCustom()
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

                search.sortscorexpath = "$score + 1";
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
        public void CollectionBrokerSearch_SortScoreXPathNumber()
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

                search.sortscorexpath = "2";
                search.outputscore = true;
                search.outputscoreSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect added source status.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
                Assert.AreEqual(2, response.collectionbrokersearchresponse.queryresults.list.document[0].score,
                    "Score not calculated correctly.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BrowseTrue()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_BrowseTrue Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.collection = "oracle-1";

                search.browse = true;
                search.nummax = 167;
                search.nummaxSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.file,
                    "No temp file saved.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BrowseClusterNum()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_BrowseClusterNum Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.collection = "oracle-1";

                search.browse = true;
                search.nummax = 167;
                search.nummaxSpecified = true;

                search.cluster = true;
                search.browseclustersnum = 1;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.file, "No temp file saved.");

                QueryBrowse browse = new QueryBrowse();
                browse.authentication = auth;
                browse.file = response.collectionbrokersearchresponse.queryresults.file;
                QueryBrowseResponse qbResponse = new QueryBrowseResponse();
                qbResponse = service.QueryBrowse(browse);
                Assert.IsNotNull(qbResponse.queryresults.list, "No results returned.");
                Assert.IsNotNull(qbResponse.queryresults.tree, "No clusters returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BrowseStart()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_BrowseStart Server: " + serverlist);
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
                search.browsestart = 10;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.file, "No temp file saved.");

                // Check file to make sure it started past 10.
                QueryBrowse browse = new QueryBrowse();
                browse.authentication = auth;
                browse.file = response.collectionbrokersearchresponse.queryresults.file;
                QueryBrowseResponse qbResponse = new QueryBrowseResponse();
                qbResponse = service.QueryBrowse(browse);
                Assert.IsNotNull(qbResponse.queryresults.list, "No results returned.");
                Assert.False(qbResponse.queryresults.list.document[0].content[0].Value.StartsWith("ac"),
                    "Incorrect Results: {0}", qbResponse.queryresults.list.document[0].content[0].Value);

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryObject_22417()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryObject Server: " + serverlist);
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

                response = service.CollectionBrokerSearch(search);
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.collectionbrokersearchresponse.queryresults.addedsource[0].status,
                    "Incorrect added source status.");
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
        public void CollectionBrokerSearch_QueryConditionObjectOperatorAnd_22471()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch cbsearch = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryConditionObjectOperatorAnd Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                cbsearch.authentication = auth;
                cbsearch.collection = "oracle-1";
                cbsearch.num = 500;
                cbsearch.query = "";

                CollectionBrokerSearchQueryconditionobject cond = new CollectionBrokerSearchQueryconditionobject();
                cond.@operator = new @operator();
                cond.@operator.logic = "and";
                cond.@operator.Items = new Object[1];
                term t2 = new term();
                t2.field = "title";
                t2.str = "acasta";
                cond.@operator.Items[0] = t2;

                cbsearch.queryconditionobject = cond;

                response = service.CollectionBrokerSearch(cbsearch);
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
        public void CollectionBrokerSearch_QueryConditionXPath()
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

                search.queryconditionxpath = "$SHIP_TYPE='Destroyer'";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(45, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryModificationMacro()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            XmlElement XmlMacro;
            string result;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryModificationMacro Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Setup
                XmlMacro = TestUtilities.ReadXmlFile("21187.xml");
                add.authentication = auth;
                add.node = XmlMacro;
                result = service.RepositoryAdd(add);

                search.authentication = auth;
                search.collection = "oracle-1";
                search.query = "uk";
                search.num = 100;

                search.querymodificationmacros = "test";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(100, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                delete.authentication = auth;
                delete.name = "test";
                delete.element = "macro";
                service.RepositoryDelete(delete);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryConditionObjectOperatorOr()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryConditionObjectOperatorAnd Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.collection = "oracle-1";
                search.num = 10;
                search.query = "";

                CollectionBrokerSearchQueryconditionobject cond = new CollectionBrokerSearchQueryconditionobject();
                cond.@operator = new @operator();
                cond.@operator.logic = "or";
                cond.@operator.Items = new Object[1];
                term t2 = new term();
                t2.field = "title";
                t2.str = "admiral";
                cond.@operator.Items[0] = t2;

                search.queryconditionobject = cond;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_Start()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Start Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";
                search.start = 5;
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
        public void CollectionBrokerSearch_Spelling()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Spelling Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admirl";
                search.spellingenabled = true;
                search.collection = "oracle-1";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse, "No results returned.");
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list,
                    "Incorrect results returned.");
                Assert.AreEqual("admiral", response.collectionbrokersearchresponse.queryresults.spellingcorrection.@string,
                    "Incorrect spelling correction returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_SpellingConfiguration()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_SpellingConfiguration Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admirl";
                search.spellingenabled = true;
                search.collection = "oracle-1";

                search.spellingconfiguration = new CollectionBrokerSearchSpellingconfiguration();
                search.spellingconfiguration.spellingcorrectorconfiguration = new spellingcorrectorconfiguration();
                search.spellingconfiguration.spellingcorrectorconfiguration.spellingcorrectorfield = new spellingcorrectorfield[1];
                search.spellingconfiguration.spellingcorrectorconfiguration.spellingcorrectorfield[0] = new spellingcorrectorfield();
                search.spellingconfiguration.spellingcorrectorconfiguration.spellingcorrectorfield[0].dictionary = "default";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list, "Results returned.");
                Assert.AreEqual("admiral", response.collectionbrokersearchresponse.queryresults.spellingcorrection.@string,
                    "Incorrect spelling correction returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_DictExpandStemStemmersEnabled()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_DictExpandStemStemmersEnabled Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admirals";
                search.collection = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandstemstemmers = "default";
                search.dictexpandstemenabled = true;
                search.dictexpandstemenabledSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_Dictionary()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Dictionary Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.collection = "oracle-1";
                search.dictexpanddictionary = "default";

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
        public void CollectionBrokerSearch_DictionaryMaxExpand()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_DictionaryMaxExpand Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.collection = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandmaxexpansionsSpecified = true;
                search.dictexpandmaxexpansions = 2;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.query,
                        "No query returned.");
                // Check that query refinements were returned.
                foreach (object o in response.collectionbrokersearchresponse.queryresults.query[0].Items)
                {
                    if (o is @operator)
                    {
                        @operator op = (@operator)o;

                        foreach (object o2 in op.Items)
                        {
                            if (o2 is @operator)
                            {
                                @operator op2 = (@operator)o2;

                                foreach (object o3 in op2.Items)
                                {
                                    Assert.Greater(3, op2.Items.Length, "No expansions were returned.");
                                }
                            }
                        }
                    }
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_DictionaryExpandWildcard()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_DictionaryExpandWildcard Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.collection = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.query,
                        "No query returned.");
                // Check that query refinements were returned.
                foreach (object o in response.collectionbrokersearchresponse.queryresults.query[0].Items)
                {
                    if (o is @operator)
                    {
                        @operator op = (@operator)o;

                        foreach (object o2 in op.Items)
                        {
                            if (o2 is @operator)
                            {
                                @operator op2 = (@operator)o2;

                                foreach (object o3 in op2.Items)
                                {
                                    Assert.Less(1, op2.Items.Length, "No expansions were returned.");
                                }
                            }
                        }
                    }
                }
            }

            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_DictionaryExpandWildcardSegmenter()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_DictionaryExpandWildcard Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.collection = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandwildcardsegmenter = "default";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.query,
                        "No query returned.");
                // Check that query refinements were returned.
                foreach (object o in response.collectionbrokersearchresponse.queryresults.query[0].Items)
                {
                    if (o is @operator)
                    {
                        @operator op = (@operator)o;

                        foreach (object o2 in op.Items)
                        {
                            if (o2 is @operator)
                            {
                                @operator op2 = (@operator)o2;

                                foreach (object o3 in op2.Items)
                                {
                                    Assert.Less(1, op2.Items.Length, "No expansions were returned.");
                                }
                            }
                        }
                    }
                }
            }

            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_DictionaryExpandWildcardDelanguageFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_DictionaryExpandWildcard Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.collection = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandwildcarddelanguage = false;
                search.dictexpandwildcarddelanguageSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.query,
                        "No query returned.");

                // Check that query refinements were returned.
                foreach (object o in response.collectionbrokersearchresponse.queryresults.query[0].Items)
                {
                    if (o is @operator)
                    {
                        @operator op = (@operator)o;

                        foreach (object o2 in op.Items)
                        {
                            if (o2 is @operator)
                            {
                                @operator op2 = (@operator)o2;

                                foreach (object o3 in op2.Items)
                                {
                                    Assert.Less(1, op2.Items.Length, "No expansions were returned.");
                                }
                            }
                        }
                    }
                }
            }

            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_DictionaryExpandWildcardMinLength()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_DictionaryExpandWildcardMinLength Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.collection = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandwildcardminlength = 1;
                search.dictexpandwildcardminlengthSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.query,
                        "No query returned.");

                // Check that query refinements were returned.
                foreach (object o in response.collectionbrokersearchresponse.queryresults.query[0].Items)
                {
                    if (o is @operator)
                    {
                        @operator op = (@operator)o;

                        foreach (object o2 in op.Items)
                        {
                            if (o2 is @operator)
                            {
                                @operator op2 = (@operator)o2;

                                foreach (object o3 in op2.Items)
                                {
                                    Assert.Less(1, op2.Items.Length, "No expansions were returned.");
                                }
                            }
                        }
                    }
                }
            }

            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_DictionaryExpandWildcardMinLengthHigh()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_DictionaryExpandWildcardMinLengthHigh Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.collection = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandwildcardminlength = 6;
                search.dictexpandwildcardminlengthSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.query,
                        "No query returned.");

                // Check that query refinements were returned.
                foreach (object o in response.collectionbrokersearchresponse.queryresults.query[0].Items)
                {
                    if (o is @operator)
                    {
                        @operator op = (@operator)o;

                        foreach (object o2 in op.Items)
                        {
                            if (o2 is @operator)
                            {
                                @operator op2 = (@operator)o2;

                                foreach (object o3 in op2.Items)
                                {
                                    Assert.AreEqual(1, op2.Items.Length, "Incorrect expansions were returned.");
                                }
                            }
                        }
                    }
                }
            }

            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_DictionaryMaxExpand0()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_DictionaryMaxExpandFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.collection = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandmaxexpansionsSpecified = true;
                search.dictexpandmaxexpansions = 0;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.query,
                        "No query returned.");

                // Check that query refinements were not returned.
                foreach (object o in response.collectionbrokersearchresponse.queryresults.query[0].Items)
                {
                    if (o is @operator)
                    {
                        @operator op = (@operator)o;

                        foreach (object o2 in op.Items)
                        {
                            if (o2 is @operator)
                            {
                                @operator op2 = (@operator)o2;

                                foreach (object o3 in op2.Items)
                                {
                                    Assert.AreEqual(1, op2.Items.Length, "No expansions were returned.");
                                }
                            }
                        }
                    }
                }
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
        public void CollectionBrokerSearch_OutputShingles()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputShingles Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.num = 3;
                search.outputshingles = true;
                search.outputshinglesSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                foreach (document d in response.collectionbrokersearchresponse.queryresults.list.document)
                {
                    Assert.IsNotNull(d.mwishingle, "Shingles not returned for document: " + d.mwishingle);
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputBoldContents()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputBoldContents Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.num = 3;
                search.outputboldcontents = "title";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                foreach (content c in response.collectionbrokersearchresponse.queryresults.list.document[0].content)
                {
                    if (c.name == "title" && c.Value.Contains("admiral") == true)
                        Assert.IsTrue(c.Value.Contains("<b>"), "Title doesn't contain bold text: " + c.Value);
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputBoldClassRoot()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputBoldClassRoot Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.num = 3;
                search.outputboldcontents = "title";
                search.outputboldclassroot = "erin";
                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list, "No results returned.");
                foreach (content c in response.collectionbrokersearchresponse.queryresults.list.document[0].content)
                {
                    if (c.name == "title" && c.Value.Contains("admiral") == true)
                        Assert.IsTrue(c.Value.Contains("<span class=\"erin0\""),
                            "Title doesn't contain bold tag: " + c.Value);
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_Query()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Query Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "abdiel";
                search.collection = "oracle-1";

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
        public void CollectionBrokerSearch_QueryMultiWord()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryMultiWord Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral hipper";
                search.collection = "oracle-1";

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
        public void CollectionBrokerSearch_QueryOr()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryOr Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "acasta OR achates";
                search.collection = "oracle-1";
                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(2, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryNot()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryNot Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "acasta NOT uk";
                search.collection = "oracle-1";
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
        public void CollectionBrokerSearch_QueryAnd()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryAnd Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "acasta AND achates";
                search.collection = "oracle-1";
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
        public void CollectionBrokerSearch_OutputKey()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputKey Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "acasta";
                search.collection = "oracle-1";
                search.outputkey = true;
                search.outputkeySpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list.document[0].key,
                    "No key returned for result.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputAxl()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputAxl Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                XmlDocument d = new XmlDocument();
                XmlElement e = d.CreateElement("document");
                d.AppendChild(e);
                XmlElement c = d.CreateElement("content");
                e.AppendChild(c);
                c.SetAttribute("name", "custom-name");
                XmlElement v = d.CreateElement("value-of");
                c.AppendChild(v);
                v.SetAttribute("select", "vse:fi-value('field1')");

                search.authentication = auth;
                search.query = "acasta";
                search.collection = "oracle-1";
                search.outputaxl = e;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual("custom-name", response.collectionbrokersearchresponse.queryresults.list.document[0].content[0].name,
                    "Expected result not returned");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputSummary()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputSummary Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "samba-erin";
                search.outputsummary = true;
                search.outputsummarySpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");
                foreach (content content in response.collectionbrokersearchresponse.queryresults.list.document[0].content)
                {
                    if (content.name == "snippet")
                    {
                        Assert.Pass("A snippet was returned.");
                    }
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputContents()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputContents Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                search.outputcontentsmode = CollectionBrokerSearchOutputcontentsmode.list;
                search.outputcontents = "title";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");

                foreach (content content in response.collectionbrokersearchresponse.queryresults.list.document[0].content)
                {
                    if (content.name == "snippet")
                    {
                        Assert.Pass("A snippet was returned.");
                    }
                }

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputDuplicates()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputDuplicates Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "samba-erin";
                search.outputduplicates = true;
                search.outputduplicatesSpecified = true;

                response = service.CollectionBrokerSearch(search);

                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(10, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Not enough results.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_FetchTimeout()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_FetchTimeout Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "samba-erin";
                search.fetch = true;
                search.fetchtimeout = 0;

                response = service.CollectionBrokerSearch(search);

                Assert.IsNull(response.collectionbrokersearchresponse.queryresults.list,
                    "Results returned.");
                Assert.AreEqual(addedsourceNofetch.nofetch, response.collectionbrokersearchresponse.queryresults.addedsource[0].nofetch,
                    "NoFetch has wrong setting.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputCacheReferences()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputCacheReferences Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "samba-erin";
                search.outputcachereferences = true;
                search.outputcachereferencesSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list.document[0].cache,
                        "A cache was not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputCacheData()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputCacheData Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "samba-erin";
                search.outputcachedata = true;
                search.outputcachereferences = true;
                search.outputcachereferencesSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list.document[0].cache,
                        "A cache link was not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_OutputScore()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_OutputScore Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "samba-erin";
                search.outputscore = true;
                search.outputscoreSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreNotEqual(0, response.collectionbrokersearchresponse.queryresults.list.document[0].score,
                    "A score was not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryWildcard()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryWildcard Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "ac?sta AND ach?tes";
                search.collection = "oracle-1";
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
        public void CollectionBrokerSearch_QueryParen()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryParen Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk NOT destroyer (NOT mine AND NOT layer)";
                search.collection = "oracle-1";
                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");
                Assert.AreEqual(10, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryNear()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryNear Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk NEAR destroyer";
                search.collection = "oracle-1";
                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");
                Assert.AreEqual(10, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryMultiResults()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryMultiResults Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.collection = "oracle-1";
                response = service.CollectionBrokerSearch(search);

                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QuerySpecialChar()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QuerySpecialChar Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "Béarn";
                search.collection = "oracle-1";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");
                Assert.AreEqual(1, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_QueryNoResults()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_QueryNoResults Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "hgirose";
                search.collection = "oracle-1";
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
        public void CollectionBrokerSearch_Num()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Num Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";
                search.num = 5;
                response = service.CollectionBrokerSearch(search);

                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");
                Assert.AreEqual(5, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        /// <summary>
        /// There is also indirect coverage for this in some of the browse cases.
        /// </summary>
        [Test]
        public void CollectionBrokerSearch_NumMax()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Num Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";
                search.num = 5;
                search.start = 5;
                search.nummax = 10;
                search.nummaxSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");
                Assert.AreEqual(5, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
                Assert.AreEqual(5, response.collectionbrokersearchresponse.queryresults.addedsource[0].num,
                    "Incorrect total results returned");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_NumPerSource()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_Num Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";
                search.num = 5;
                search.numpersource = 2;
                search.numpersourceSpecified = true;
                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");
                Assert.AreEqual(2, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_NoQuery()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_NoQuery Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.collection = "oracle-1";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No Results returned.");
                Assert.AreEqual(10, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BinningModeDouble()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_BinningModeDouble Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.collection = "binning-1";

                search.binningmode = CollectionBrokerSearchBinningmode.@double;
                search.forcebinning = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.binningfull,
                    "No bins returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BinningConfiguration()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_BinningModeNormal Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.collection = "binning-1";

                search.binningmode = CollectionBrokerSearchBinningmode.normal;
                search.forcebinning = true;
                search.binningconfiguration = new CollectionBrokerSearchBinningconfiguration();
                search.binningconfiguration.binningset = new binningset[1];
                search.binningconfiguration.binningset[0] = new binningset();
                search.binningconfiguration.binningset[0].label = "mine";
                search.binningconfiguration.binningset[0].bsid = "ship";
                search.binningconfiguration.binningset[0].select = "$SHIP_TYPE";

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.binning.binningset,
                    "No bins returned.");
                Assert.AreEqual("mine", response.collectionbrokersearchresponse.queryresults.binning.binningset[0].label,
                    "Incorrect label.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_ForceBinningTrue()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_ForceBinningTrue Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.collection = "binning-1";
                search.start = 5;

                search.binningmode = CollectionBrokerSearchBinningmode.normal;
                search.forcebinning = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.binning.binningset,
                    "No bins returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BinningModeDefaults()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_BinningModeDefaults Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.collection = "binning-1";

                search.binningmode = CollectionBrokerSearchBinningmode.defaults;
                search.forcebinning = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.binning.binningset,
                    "No bins returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_BinningState()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            string BinningState = null;
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

                response = service.CollectionBrokerSearch(search);

                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.binning.binningset,
                    "No bins returned.");
                Assert.AreNotEqual(0, response.collectionbrokersearchresponse.queryresults.binning.binningset[0].bin.Length,
                    "No bins.");

                BinningState = response.collectionbrokersearchresponse.queryresults.binning.binningset[0].bin[0].state;

                search.binningstate = BinningState;
                response = service.CollectionBrokerSearch(search);

                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.binning.binningset,
                    "No bins returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.binning.binningstate,
                    "Binning state not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_Cluster()
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
        public void CollectionBrokerSearch_ClusterStemmers()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_ClusterStemmers Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";

                search.cluster = true;
                search.clusterstemmers = "delanguage english";

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
        public void CollectionBrokerSearch_ClusterKbs()
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
                search.clusterkbs = "core";

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
        public void CollectionBrokerSearch_ClusterSegmenter()
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
                search.clustersegmenter = "chinese";

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
        public void CollectionBrokerSearch_ClusterSegmenterTwo()
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
                search.clustersegmenter = "chinese korean";

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
        public void CollectionBrokerSearch_ClusterNearDuplicates()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_ClusterNearDuplicates Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";

                search.cluster = true;
                search.clusternearduplicates = 80;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.tree, "Clusters were created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_ClusterNearDuplicates0()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_ClusterNearDuplicates0 Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";

                search.cluster = true;
                search.clusternearduplicates = 0;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.tree, "Clusters were not created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_ClusterNearDuplicatesOff()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_ClusterNearDuplicatesOff Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";

                search.cluster = true;
                search.clusternearduplicates = -1;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list, 
                    "No results returned.");
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.tree, 
                    "Clusters were not created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_ClusterNearDuplicatesDecimal()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_ClusterNearDuplicatesDecimal Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.collection = "oracle-1";

                search.cluster = true;
                search.clusternearduplicates = 5.5;

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
        public void CollectionBrokerSearch_TermExpandMaxExpansions()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_TermExpandMaxExpansions Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral*";
                search.collection = "oracle-1";

                search.termexpandmaxexpansions = 10;
                search.termexpandmaxexpansionsSpecified = true;
                search.termexpanderrorwhenexceedslimit = false;
                search.termexpanderrorwhenexceedslimitSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");

                // Check that query refinements were returned.
                foreach (object o in response.collectionbrokersearchresponse.queryresults.query[0].Items)
                {
                    if (o is @operator)
                    {
                        @operator op = (@operator)o;

                        foreach (object o2 in op.Items)
                        {
                            if (o2 is @operator)
                            {
                                @operator op2 = (@operator)o2;
                                Assert.AreEqual(10, op2.expandcount, "Too many expansions returned");
                            }
                        }
                    }
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_TermExpandErrorWhenExceeds()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_TermExpandMaxExpansions Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral*";
                search.collection = "oracle-1";

                search.termexpandmaxexpansions = 2;
                search.termexpandmaxexpansionsSpecified = true;
                search.termexpanderrorwhenexceedslimit = true;
                search.termexpanderrorwhenexceedslimitSpecified = true;

                response = service.CollectionBrokerSearch(search);
                Assert.IsNotNull(response.collectionbrokersearchresponse.queryresults.list,
                    "No results returned.");
                Assert.AreEqual(3, response.collectionbrokersearchresponse.queryresults.list.document.Length,
                    "Incorrect results returned.");

                // Check that query refinements were returned.
                foreach (object o in response.collectionbrokersearchresponse.queryresults.query[0].Items)
                {
                    if (o is @operator)
                    {
                        @operator op = (@operator)o;

                        foreach (object o2 in op.Items)
                        {
                            if (o2 is @operator)
                            {
                                @operator op2 = (@operator)o2;
                                Assert.AreEqual(operatorExpandtype.error, op2.expandtype, "Error not set correctly.");
                            }
                        }
                    }
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void CollectionBrokerSearch_TermExpandErrorWhenExceedsFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            CollectionBrokerSearch search = new CollectionBrokerSearch();
            CollectionBrokerSearchResponse response = new CollectionBrokerSearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: CollectionBrokerSearch_TermExpandMaxExpansions Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral$";
                search.collection = "oracle-1";

                search.termexpandmaxexpansions = 2;
                search.termexpandmaxexpansionsSpecified = true;
                search.termexpanderrorwhenexceedslimit = false;
                search.termexpanderrorwhenexceedslimitSpecified = true;

                search.dictexpanddictionary = "default";
                search.dictexpandmaxexpansionsSpecified = false;
                search.dictexpandstemenabled = true;
                search.dictexpandstemenabledSpecified = true;

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
    }
}
