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
    class QuerySearchTests
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
            auth.username = username;
            auth.password = password;
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

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
        public void QuerySearch_Bug24148()
        {
            // Variables
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: QuerySearch_Bug24148 Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";
                search.authorizationrights = "";
                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "No results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_DefaultsOneCollection()
        {
            // Variables
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_DefaultsOneCollection Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(10, response.queryresults.list.document.Length, 
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SyntaxOperatorsAnd()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_syntaxOperatorsAnd Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral AND hipper";
                search.sources = "oracle-1";

                search.syntaxoperators = "AND";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(1, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SyntaxRepositoryNode()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_syntaxRepositoryNode Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral OR hipper";
                search.sources = "oracle-1";

                search.syntaxrepositorynode = "custom";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(4, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortBy()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortBy Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.sortby = "date";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Incorrect syntax.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        [Ignore ("Known Bug: 22192")]
        public void QuerySearch_OutputSortKeys()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputSortKeys Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1 samba-erin";
                search.sortby = "date";
                search.sortscorexpath = "$score";
                search.outputsortkeys = true;
                search.outputsortkeysSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Incorrect syntax.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
                Assert.IsNotNull(response.queryresults.list.document[0].sortkey, "Sort keys not included with document.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_RankDecay()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_RankDecay Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.sortby = "date";
                search.rankdecay = 1;
                search.rankdecaySpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Incorrect syntax.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_RankDecaySmall()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_RankDecaySmall Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.sortby = "date";
                search.rankdecay = 0.1;
                search.rankdecaySpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Incorrect syntax.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_RankDecayLarge()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_RankDecayLarge Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.sortby = "date";
                search.rankdecay = 100000;
                search.rankdecaySpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Incorrect syntax.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortNumPassages()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortNumPassages Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.sortby = "date";
                search.sortnumpassages = 1;
                search.sortnumpassagesSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Incorrect syntax.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortXPaths()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortXPaths Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                
                // Configure sort
                QuerySearchSortxpaths xpaths = new QuerySearchSortxpaths(); 
                sort[] sorts = new sort[1]; 
                sorts[0] = new sort(); 
                sorts[0].order = sortOrder.ascending; 
                sorts[0].xpath = "$last-modified"; 
                xpaths.sort = sorts;
                search.sortxpaths = xpaths; 

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Incorrect syntax.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortScoreXPathCustom_23006()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortScoreXPath Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";

                search.sortscorexpath = "$score + 1";
                search.outputscore = true;
                search.outputscoreSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Incorrect syntax.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
                Assert.IsTrue(response.queryresults.list.document[0].score > 2.9, "Score not calculated correctly.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortScoreXPathNumber()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortScoreXPath Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";

                search.sortscorexpath = "2";
                search.outputscore = true;
                search.outputscoreSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Incorrect syntax.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
                Assert.AreEqual(2, response.queryresults.list.document[0].score, "Score not calculated correctly.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortXPathsDes()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortXPathsDes Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";

                // Configure sort
                QuerySearchSortxpaths xpaths = new QuerySearchSortxpaths();
                sort[] sorts = new sort[1];
                sorts[0] = new sort();
                sorts[0].order = sortOrder.descending;
                sorts[0].xpath = "$last-modified";
                xpaths.sort = sorts;
                search.sortxpaths = xpaths;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Incorrect syntax.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_BrowseTrue()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_BrowseTrue Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.sources = "oracle-1";

                search.browse = true;
                search.nummax = 167;
                search.nummaxSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.file, "No temp file saved.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_BrowseClusterNum()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_BrowseClusterNum Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.sources = "oracle-1";

                search.browse = true;
                search.nummax = 167;
                search.nummaxSpecified = true;

                search.cluster = true;
                search.browseclustersnum = 1;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.file, "No temp file saved.");

                QueryBrowse browse = new QueryBrowse();
                browse.authentication = auth;
                browse.file = response.queryresults.file;
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
        public void QuerySearch_BrowseStart()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_BrowseStart Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.sources = "oracle-1";

                search.start = 10;
                search.nummax = 20;
                search.nummaxSpecified = true;

                search.browse = true;
                search.browsestart = 10;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.file, "No temp file saved.");

                // Check file to make sure it started past 10.
                QueryBrowse browse = new QueryBrowse();
                browse.authentication = auth;
                browse.file = response.queryresults.file;
                QueryBrowseResponse qbResponse = new QueryBrowseResponse();
                qbResponse = service.QueryBrowse(browse);
                Assert.IsNotNull(qbResponse.queryresults.list, "No results returned.");
                Assert.IsTrue(qbResponse.queryresults.list.document[0].content[0].Value.StartsWith("ac") == false,
                    "Incorrect Results: {0}", qbResponse.queryresults.list.document[0].content[0].Value);

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_BrowseStartNeg()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_BrowseStartNeg Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.sources = "oracle-1";

                search.start = 10;
                search.nummax = 20;
                search.nummaxSpecified = true;

                search.browse = true;
                search.browsestart = -10;
                search.nummax = 167;
                search.nummaxSpecified = true;


                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.file, "No temp file saved.");

                // Check file to make sure it started past 10.
                QueryBrowse browse = new QueryBrowse();
                browse.authentication = auth;
                browse.file = response.queryresults.file;
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
        public void QuerySearch_QueryObject()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryObject Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.queryobject = new QuerySearchQueryobject();
                search.queryobject.@operator = new @operator();
                search.queryobject.@operator.logic = "and";
                term te = new term();
                te.field = "title";
                te.str = "achates";
                search.queryobject.@operator.Items = new Object[1];
                search.queryobject.@operator.Items[0] = te;
                search.sources = "oracle-1";
                
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(1, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryConditionObjectOperatorAnd()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryConditionObjectOperatorAnd Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.sources = "oracle-1";
                search.num = 500;
                search.query = "";
                
                QuerySearchQueryconditionobject cond = new QuerySearchQueryconditionobject();
                cond.@operator = new @operator();
                cond.@operator.logic = "and";
                cond.@operator.Items = new Object[1];
                term t2 = new term();
                t2.field = "title";
                t2.str = "acasta";
                cond.@operator.Items[0] = t2;

                search.queryconditionobject = cond; 

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(1, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryConditionXPath()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryConditionXPath Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.sources = "oracle-1";
                search.query = "uk";
                search.num = 100;

                search.queryconditionxpath = "$SHIP_TYPE='Destroyer'";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(45, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryModificationMacro()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            XmlElement XmlMacro;
            string result;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryModificationMacro Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Setup
                XmlMacro = TestUtilities.ReadXmlFile("21187.xml");
                add.authentication = auth;
                add.node = XmlMacro;
                result = service.RepositoryAdd(add);

                search.authentication = auth;
                search.sources = "oracle-1";
                search.query = "uk";
                search.num = 100;

                search.querymodificationmacros = "test";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(100, response.queryresults.list.document.Length, "Incorrect results returned.");
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
        public void QuerySearch_QueryConditionObjectOperatorOr()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryConditionObjectOperatorOr Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.sources = "oracle-1";
                search.num = 10;
                search.query = "";

                QuerySearchQueryconditionobject cond = new QuerySearchQueryconditionobject();
                cond.@operator = new @operator();
                cond.@operator.logic = "or";
                cond.@operator.Items = new Object[1];
                term t2 = new term();
                t2.field = "title";
                t2.str = "admiral";
                cond.@operator.Items[0] = t2;

                search.queryconditionobject = cond;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_Start()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Start Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";
                search.start = 5;
                response = service.QuerySearch(search);
                Assert.IsTrue(response.queryresults.list.document.Length == 10, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_StartMax()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_StartMax Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";
                search.start = 500;
                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_Spelling()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Spelling Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admirl";
                search.spellingenabled = true;
                search.sources = "oracle-1";

                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned.");
                Assert.AreEqual("admiral", response.queryresults.spellingcorrection.@string,
                    "Incorrect spelling correction returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SpellingConfiguration()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SpellingConfiguration Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admirl";
                search.spellingenabled = true;
                search.sources = "oracle-1";

                search.spellingconfiguration = new QuerySearchSpellingconfiguration();
                search.spellingconfiguration.spellingcorrectorconfiguration = new spellingcorrectorconfiguration();
                search.spellingconfiguration.spellingcorrectorconfiguration.spellingcorrectorfield = new spellingcorrectorfield[1];
                search.spellingconfiguration.spellingcorrectorconfiguration.spellingcorrectorfield[0] = new spellingcorrectorfield();
                search.spellingconfiguration.spellingcorrectorconfiguration.spellingcorrectorfield[0].dictionary = "default";

                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned.");
                Assert.AreEqual("admiral", response.queryresults.spellingcorrection.@string,
                    "Incorrect spelling correction returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_DictExpandStemStemmersEnabled()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_DictExpandStemStemmersEnabled Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admirals";
                search.sources = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandstemstemmers = "default";
                search.dictexpandstemenabled = true;
                search.dictexpandstemenabledSpecified = true;
                response = service.QuerySearch(search);
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
                
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_Dictionary()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Dictionary Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.sources = "oracle-1";
                search.dictexpanddictionary = "default";
                response = service.QuerySearch(search);
                Assert.AreEqual(10, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_DictionaryMaxExpand()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_DictionaryMaxExpand Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.sources = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandmaxexpansionsSpecified = true;
                search.dictexpandmaxexpansions = 2;
                response = service.QuerySearch(search);

                // Check that query refinements were returned.
                foreach (object o in response.queryresults.query[0].Items)
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
                                    Assert.IsTrue(op2.Items.Length > 1, "No expansions were returned.");
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
        public void QuerySearch_DictionaryExpandWildcard()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_DictionaryExpandWildcard Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.sources = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                response = service.QuerySearch(search);

                // Check that query refinements were returned.
                foreach (object o in response.queryresults.query[0].Items)
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
                                    Assert.IsTrue(op2.Items.Length > 1, "No expansions were returned.");
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
        public void QuerySearch_DictionaryExpandWildcardSegmenter()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_DictionaryExpandWildcard Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.sources = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandwildcardsegmenter = "default";
                response = service.QuerySearch(search);

                // Check that query refinements were returned.
                foreach (object o in response.queryresults.query[0].Items)
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
                                    Assert.IsTrue(op2.Items.Length > 1, "No expansions were returned.");
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
        public void QuerySearch_DictionaryExpandWildcardDelanguageTrue()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_DictionaryExpandWildcard Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.sources = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandwildcarddelanguage = true;
                search.dictexpandwildcarddelanguageSpecified = true;
                response = service.QuerySearch(search);

                // Check that query refinements were returned.
                foreach (object o in response.queryresults.query[0].Items)
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
                                    Assert.IsTrue(op2.Items.Length > 1, "No expansions were returned.");
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
        public void QuerySearch_DictionaryExpandWildcardMinLength()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_DictionaryExpandWildcardMinLength Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.sources = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandwildcardminlength = 1;
                search.dictexpandwildcardminlengthSpecified = true;
                response = service.QuerySearch(search);

                // Check that query refinements were returned.
                foreach (object o in response.queryresults.query[0].Items)
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
                                    Assert.IsTrue(op2.Items.Length > 1, "No expansions were returned.");
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
        public void QuerySearch_DictionaryExpandWildcardMinLengthHigh()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_DictionaryExpandWildcardMinLengthHigh Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "adm$ral";
                search.sources = "oracle-1";
                search.dictexpanddictionary = "default";
                search.dictexpandwildcardenabled = true;
                search.dictexpandwildcardenabledSpecified = true;
                search.dictexpandstemstemmers = "default";
                search.dictexpandwildcardminlength = 6;
                search.dictexpandwildcardminlengthSpecified = true;
                response = service.QuerySearch(search);

                // Check that query refinements were returned.
                foreach (object o in response.queryresults.query[0].Items)
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
                                    Assert.IsTrue(op2.Items.Length == 1, "No expansions were returned.");
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
        public void QuerySearch_SpellingNoCorrection()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SpellingNoCorrection Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.spellingenabled = true;
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.spellingcorrection, "Unexpected spelling correction returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SourcesTwo()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SourcesTwo Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1, samba-erin";
                search.num = 20;
                search.numpersource = 10;
                response = service.QuerySearch(search);
                Assert.AreEqual(20, response.queryresults.list.document.Length,
                    "Incorrect results returned");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputShingles()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputShingles Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.num = 3;
                search.outputshingles = true;
                search.outputshinglesSpecified = true;
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                foreach (document d in response.queryresults.list.document)
                {
                    Assert.IsNotNull(d.mwishingle, "Shingles not returned for document: " + d.content[0].Value);
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputBoldContents()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputBoldContents Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.num = 3;
                search.outputboldcontents = "title";
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                foreach (content c in response.queryresults.list.document[0].content)
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
        public void QuerySearch_OutputBoldClassRoot()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputBoldClassRoot Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.num = 3;
                search.outputboldcontents = "title";
                search.outputboldclassroot = "erin";
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                foreach (content c in response.queryresults.list.document[0].content)
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
        public void QuerySearch_OutputBoldClusterClassRoot()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputBoldClassRoot Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.num = 3;
                search.outputboldcontents = "title";
                search.outputboldclassroot = "erin";
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                foreach (content c in response.queryresults.list.document[0].content)
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
        public void QuerySearch_Query()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Query Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "Alg%c3%a9rie";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.AreEqual(1, response.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryMultiWord()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryMultiWord Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral hipper";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.AreEqual(1, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryOr()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryOr Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "acasta OR achates";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.AreEqual(2, response.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryNot()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryNot Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "acasta NOT uk";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned. Expected: 0");
                Assert.AreEqual(0, response.queryresults.addedsource[0].totalresults, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryAnd()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryAnd Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "acasta AND achates";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned. Expected: 0");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputKey()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputKey Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "acasta";
                search.sources = "oracle-1, samba-erin";
                search.outputkey = true;
                search.outputkeySpecified = true;
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.list.document[0].key, "No key returned for result.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputAxl()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputAxl Server: " + serverlist);
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
                search.sources = "oracle-1";
                search.outputaxl = e;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsTrue(response.queryresults.list.document[0].content[0].name.Equals("custom-name"),
                    "Expected result not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputSummary()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputSummary Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "samba-erin";
                search.outputsummary = true;
                search.outputsummarySpecified = true;
                response = service.QuerySearch(search);
                foreach (content content in response.queryresults.list.document[0].content)
                {
                    if (content.name == "snippet")
                    {
                        Assert.Pass("A snippet was returned.");
                    }
                }
                Assert.Fail("No snippets were returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputContents()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputContents Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.outputcontentsmode = QuerySearchOutputcontentsmode.list;
                search.outputcontents = "title";
                response = service.QuerySearch(search);
                foreach (content content in response.queryresults.list.document[0].content)
                {
                    if (content.name == "snippet")
                    {
                        Assert.Pass("A snippet was returned.");
                    }
                }
                Assert.Fail("No snippets were returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputDuplicates()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputDuplicates Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "samba-erin";
                search.outputduplicates = true;
                search.outputduplicatesSpecified = true;

                response = service.QuerySearch(search);

                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(10, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        [Ignore("Results returning faster than timeout.")]
        public void QuerySearch_FetchTimeout()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_FetchTimeout Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "samba-erin";
                search.fetch = true;
                search.fetchtimeout = 1;

                response = service.QuerySearch(search);

                Assert.IsNull(response.queryresults.list, "Results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputCacheReferences()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputCacheReferences Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "samba-erin";
                search.outputcachereferences = true;
                search.outputcachereferencesSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.list.document[0].cache, "A snippet was not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputCacheData()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputCacheData Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "samba-erin";
                search.outputcachedata = true;
                search.outputcachereferences = true;
                search.outputcachereferencesSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.list.document[0].cache, "A snippet was not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputScore()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputScore Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "samba-erin";
                search.outputscore = true;
                search.outputscoreSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(0, response.queryresults.list.document[0].score,
                        "A score was not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryWildcard()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryWildcard Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "ac?sta AND ach?tes";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryParen()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryParen Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk NOT destroyer (NOT mine AND NOT layer)";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.AreEqual(10, response.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryNear()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryNear Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk NEAR destroyer";
                search.sources = "oracle-1";
                
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(10, response.queryresults.list.document.Length,
                    "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryMultiResults()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryMultiResults Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QuerySpecialChar()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QuerySpecialChar Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "Béarn";
                search.sources = "oracle-1";
                
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned."); 
                Assert.AreEqual(1, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryNoResults()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryNoResults Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "hgirose";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_Num()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Num Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";
                search.num = 5;
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(5, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_NumMax()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Num Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";
                search.num = 5;
                search.start = 5;
                search.nummax = 10;
                search.nummaxSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(5, response.queryresults.list.document.Length, "Incorrect results returned.");
                Assert.AreEqual(5, response.queryresults.addedsource[0].num,
                    "Incorrect total results returned:");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_NumOverRequest()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_NumOverRequest Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1 samba-erin";
                search.num = 10;
                search.numoverrequest = 1.2;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(10, response.queryresults.list.document.Length,
                    "Incorrect results returned.");
                Assert.AreEqual(12, response.queryresults.list.num,
                    "NumOverRequest not honored.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_NumPerSource()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Num Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";
                search.num = 5;
                search.numpersource = 2;
                search.numpersourceSpecified = true;
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(2, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_BinningModeOff()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Binning Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "binning-1";

                search.binningmode = QuerySearchBinningmode.off;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNull(response.queryresults.binning, "Binning was returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_BinningConfiguration()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_BinningModeNormal Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.sources = "binning-1";

                search.binningmode = QuerySearchBinningmode.normal;
                search.forcebinning = true;
                search.binningconfiguration = new QuerySearchBinningconfiguration();
                search.binningconfiguration.binningset = new binningset[1];
                search.binningconfiguration.binningset[0] = new binningset();
                search.binningconfiguration.binningset[0].label = "mine";
                search.binningconfiguration.binningset[0].bsid = "ship";
                search.binningconfiguration.binningset[0].select = "$SHIP_TYPE";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.binning, "Binning was not returned.");
                Assert.AreEqual("mine", response.queryresults.binning.binningset[0].label, "Incorrect label.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ForceBinningTrue()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ForceBinningTrue Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.sources = "binning-1";
                search.start = 5;

                search.binningmode = QuerySearchBinningmode.normal;
                search.forcebinning = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.binning, "Binning was not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_BinningModeDefaults()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_BinningModeDefaults Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.sources = "binning-1";

                search.binningmode = QuerySearchBinningmode.defaults;
                search.forcebinning = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.binning, "Binning was not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_BinningState()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            string BinningState = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_BinningState Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.sources = "binning-1";

                search.binningmode = QuerySearchBinningmode.defaults;
                search.forcebinning = true;

                response = service.QuerySearch(search);

                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.binning, "Binning was not returned.");
                Assert.IsNotNull(response.queryresults.binning.binningset[0].bin.Length, "No bins.");

                BinningState = response.queryresults.binning.binningset[0].bin[0].state;

                search.binningstate = BinningState;
                response = service.QuerySearch(search);

                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.binning, "Binning was not returned.");
                Assert.IsNotNull(response.queryresults.binning.binningstate, "Binning state not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_BinningStateNull()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_BinningStateNull Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.sources = "binning-1";

                search.binningmode = QuerySearchBinningmode.defaults;
                search.forcebinning = true;
                search.binningstate = null;

                response = service.QuerySearch(search);

                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.binning, "Binning was not returned.");
                Assert.AreNotEqual(0, response.queryresults.binning.binningset[0].bin.Length, "No bins.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ClusterFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = false;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNull(response.queryresults.tree, "Clusters were created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_Cluster()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Cluster Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.tree, "Clusters were not created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterStemmers()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ClusterStemmers Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = true;
                search.clusterstemmers = "delanguage english";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.tree, "Clusters were not created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterKbs()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ClusterKbs Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = true;
                search.clusterkbs = "core";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.tree, "Clusters were not created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterSegmenter()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ClusterSegmenter Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = true;
                search.clustersegmenter = "chinese";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.tree, "Clusters were not created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterSegmenterTwo()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ClusterSegmenter Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = true;
                search.clustersegmenter = "chinese korean";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.tree, "Clusters were not created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterNearDuplicates()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ClusterNearDuplicates Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = true;
                search.clusternearduplicates = 80;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.tree, "Clusters were not created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterNearDuplicatesOff()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ClusterNearDuplicatesOff Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = true;
                search.clusternearduplicates = -1;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.tree, "Clusters were not created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterNearDuplicatesDecimal()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ClusterNearDuplicatesDecimal Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = true;
                search.clusternearduplicates = 5.5;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.tree, "Clusters were not created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_TermExpandMaxExpansions()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_TermExpandMaxExpansions Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral*";
                search.sources = "oracle-1";

                search.termexpandmaxexpansions = 10;
                search.termexpandmaxexpansionsSpecified = true;
                search.termexpanderrorwhenexceedslimit = false;
                search.termexpanderrorwhenexceedslimitSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");

                // Check that query refinements were returned.
                foreach (object o in response.queryresults.query[0].Items)
                {
                    if (o is @operator)
                    {
                        @operator op = (@operator)o;

                        foreach (object o2 in op.Items)
                        {
                            if (o2 is @operator)
                            {
                                @operator op2 = (@operator)o2;
                                Assert.AreEqual(10, op2.expandcount, "Too many expansions returned.");
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
        public void QuerySearch_TermExpandErrorWhenExceeds()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_TermExpandMaxExpansions Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral*";
                search.sources = "oracle-1";

                search.termexpandmaxexpansions = 2;
                search.termexpandmaxexpansionsSpecified = true;
                search.termexpanderrorwhenexceedslimit = true;
                search.termexpanderrorwhenexceedslimitSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");

                // Check that query refinements were returned.
                foreach (object o in response.queryresults.query[0].Items)
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
        public void QuerySearch_TermExpandErrorWhenExceedsFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_TermExpandMaxExpansions Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral$";
                search.sources = "oracle-1";

                search.termexpandmaxexpansions = 2;
                search.termexpandmaxexpansionsSpecified = true;
                search.termexpanderrorwhenexceedslimit = false;
                search.termexpanderrorwhenexceedslimitSpecified = true;

                search.dictexpanddictionary = "default";
                search.dictexpandmaxexpansionsSpecified = false;
                search.dictexpandstemenabled = true;
                search.dictexpandstemenabledSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }
    }
}
