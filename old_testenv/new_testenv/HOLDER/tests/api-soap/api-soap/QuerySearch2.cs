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
    class QuerySearchTests2
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
        public void QuerySearch_BinningStateInvalid()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_BinningStateInvalid Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.sources = "binning-1";

                search.binningmode = QuerySearchBinningmode.defaults;
                search.forcebinning = true;
                search.binningstate = "me";

                response = service.QuerySearch(search);

                Assert.IsNull(response.queryresults.list, "Results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterKbsNotExist()
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
                search.clusterkbs = "erin";

                response = service.QuerySearch(search);
                Assert.Fail("An exception should have been thrown.");

            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.ToString());
                Assert.AreEqual("The exception [indexer-bad-stoplist-error] was thrown.", se.Message, 
                    "Incorrect exception thrown.");
            }
        }

        [Test]
        [Ignore("Known Bug: 22195")]
        public void QuerySearch_ClusterSegmenterNotExist()
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
                search.clustersegmenter = "erin";

                response = service.QuerySearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.ToString());
                Assert.AreEqual("The exception [options-invalid-stemmer-error] was thrown.", se.Message, 
                    "Incorrect exception thrown.");
            }
        }

        [Test]
        public void QuerySearch_ClusterStemmersNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ClusterStemmersNotExist Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = true;
                search.clusterstemmers = "delanguage english erin";

                response = service.QuerySearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.ToString());
                Assert.AreEqual("The exception [options-invalid-stemmer-error] was thrown.", se.Message,
                    "Incorrect exception thrown.");
            }
        }

        [Test]
        public void QuerySearch_DictionaryExpandWildcardDelanguageFalse()
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
                search.dictexpandwildcarddelanguage = false;
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
        public void QuerySearch_DictionaryMaxExpand0()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_DictionaryMaxExpand0 Server: " + serverlist);
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
                search.dictexpandmaxexpansions = 0;

                response = service.QuerySearch(search);
                // Check that query refinements were not returned.
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
        public void QuerySearch_FetchFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_FetchFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "samba-erin";
                search.fetch = false;

                response = service.QuerySearch(search);

                Assert.IsNull(response.queryresults.list, "Results returned.");
                Assert.AreEqual(addedsourceNofetch.nofetch, response.queryresults.addedsource[0].nofetch,
                    "NoFetch has wrong setting.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ForceBinningFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ForceBinningFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "destroyer";
                search.sources = "binning-1";
                search.start = 5;

                search.binningmode = QuerySearchBinningmode.normal;
                search.forcebinning = false;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNull(response.queryresults.binning, "Bins returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterKbsNull()
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
                search.clusterkbs = null;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.IsNotNull(response.queryresults.tree, "Clusters were created.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_DictionaryNull()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_DictionaryNull Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "uk";
                search.sources = "oracle-1";
                search.dictexpanddictionary = null;
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
        public void QuerySearch_NoAuth()
        {
            // Variables
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_NoAuth Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.query = "";
                search.sources = "oracle-1";
                response = service.QuerySearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleNoAuth(se);
            }
        }

        [Test]
        public void QuerySearch_NoQuery()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_NoQuery Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
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
        public void QuerySearch_Num0()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Num0 Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";
                search.num = 0;
                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        [Ignore("Known Bug: 22042")]
        public void QuerySearch_NumOverRequestNegative_22226()
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
                search.numoverrequest = -1.2;

                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list,
                    "Incorrect results returned: {0}", response.queryresults.list.document.Length);
                Assert.AreEqual(1.0, response.queryresults.list.num, "NumOverRequest not honored ");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputBoldContentsExcept()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputBoldContentsExcept Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.num = 3;
                search.outputboldcontents = "title";
                search.outputboldcontentsexcept = true;
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                foreach (content c in response.queryresults.list.document[0].content)
                {
                    if (c.name == "title")
                        Assert.IsTrue(c.Value.Contains("<b>") != true,
                            "Title contains bold text");
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputShinglesFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputShinglesFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.num = 3;
                search.outputshingles = false;
                search.outputshinglesSpecified = true;
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                foreach (document d in response.queryresults.list.document)
                {
                    Assert.IsTrue(d.mwishingle == null,
                        "Shingles returned for document: " + d.mwishingle);
                }
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_ClusterNearDuplicates0()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_ClusterNearDuplicates0 Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "oracle-1";

                search.cluster = true;
                search.clusternearduplicates = 0;

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
        public void QuerySearch_OutputCacheDataFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputCacheDataFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "samba-erin";
                search.outputcachedata = false;
                search.outputcachedataSpecified = true;
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list.document[0].cache, "Cache data was returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputCacheReferencesFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputCacheReferencesFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "samba-erin";
                search.outputcachereferences = false;
                search.outputcachereferencesSpecified = true;
                response = service.QuerySearch(search);
                if (response.queryresults.list.document[0].content[4].name == "snippet")
                {
                    Assert.IsNotNull(response.queryresults.list.document[0].content[4].Value,
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
        public void QuerySearch_OutputSummaryFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputSummaryFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "samba-erin";
                search.outputsummary = false;
                search.outputsummarySpecified = true;
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                foreach (content content in response.queryresults.list.document[0].content)
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
        public void QuerySearch_OutputKeyFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputKeyFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "acasta";
                search.sources = "oracle-1, samba-erin";
                search.outputkey = false;
                search.outputkeySpecified = true;
                response = service.QuerySearch(search);
                Assert.IsTrue(response.queryresults.list.document[0].key == null,
                    "No key returned for result.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputContents_Except()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputContents_Except Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.outputcontentsmode = QuerySearchOutputcontentsmode.except;
                search.outputcontents = "title";
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                foreach (content content in response.queryresults.list.document[0].content)
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
        public void QuerySearch_OutputContents_NoContent()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputContents_NoContent Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "samba-erin";
                search.outputcontentsmode = QuerySearchOutputcontentsmode.list;
                search.outputcontents = "title";
                
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                foreach (content content in response.queryresults.list.document[0].content)
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
        public void QuerySearch_OutputDuplicatesFalse()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputDuplicatesFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                search.sources = "samba-erin";
                search.outputduplicates = false;
                search.outputduplicatesSpecified = true;

                response = service.QuerySearch(search);

                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreEqual(10, response.queryresults.list.document.Length, "Not enough results.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_OutputScoreFalse_22007()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_OutputScoreFalse Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "samba-erin";
                search.outputscore = false;
                search.outputscoreSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(0, response.queryresults.list.document[0].score, "A score was returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryModificationMacroNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryModificationMacro Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                // Setup
                search.authentication = auth;
                search.sources = "oracle-1";
                search.query = "uk";
                search.num = 100;

                search.querymodificationmacros = "test";

                response = service.QuerySearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                Assert.AreEqual("The exception [xml-macro-reference-error] was thrown.", se.Message,
                    "Incorrect exception thrown.");
            }
        }

        [Test]
        public void QuerySearch_QueryObjectNull()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryObjectNull Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.queryobject = null;
                search.sources = "oracle-1";
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
        public void QuerySearch_QueryObjectNullOperator()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryObjectNullOperator Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.queryobject = new QuerySearchQueryobject();
                search.queryobject.@operator = null;
                search.sources = "oracle-1";

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
        public void QuerySearch_SyntaxOperatorsInvalid()
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
                search.query = "admiral OR hipper";
                search.sources = "oracle-1";

                search.syntaxoperators = "ERIN";

                response = service.QuerySearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.ToString());
                Assert.AreEqual("The exception [query-undefined-operator-error] was thrown.", se.Message,
                    "Incorrect exception thrown.");
            }
        }

        /// <summary>
        /// This works differently than I would expect because of the way .Net creates the SOAP
        /// packet.  I would not expect the OR to be recognized as a valid query syntax operator
        /// as I am explicitly setting the parameter to null.  When the SOAP packet is created,
        /// the syntaxoperators parameter is not included so the server side uses the default.
        /// </summary>
        [Test]
        public void QuerySearch_SyntaxOperatorsNull()
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
                search.query = "admiral OR hipper";
                search.sources = "oracle-1";

                search.syntaxoperators = null;

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
        public void QuerySearch_SyntaxOperatorsOrNotinList()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_syntaxOperatorsOrNotinList Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral OR hipper";
                search.sources = "oracle-1";

                search.syntaxoperators = "AND";

                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortByNoQuery()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortByNoQuery Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.sources = "oracle-1";
                search.sortby = "date";

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status);
                Assert.AreEqual(10, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortByNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortByNotExist Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.sortby = "erin";

                response = service.QuerySearch(search);
                Assert.AreEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status,
                    "Error status not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_RankDecay0()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_RankDecay0 Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.sortby = "date";
                search.rankdecay = 0;
                search.rankdecaySpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status);
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortNumPassagesNegative()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortNumPassagesNegative Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.sortby = "date";
                search.sortnumpassages = -1;
                search.sortnumpassagesSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status);
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_RankDecayNegative()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_RankDecayNegative Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";
                search.sortby = "date";
                search.rankdecay = -1;
                search.rankdecaySpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status);
                Assert.IsTrue(response.queryresults.list.document.Length == 3, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortScoreXPathEmpty()
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

                search.sortscorexpath = "";
                search.outputscore = true;
                search.outputscoreSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status);
                Assert.Less(2, response.queryresults.list.document[0].score, "Score not calculated correctly.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SortXPathsEmpty()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortXPathsEmpty Server: " + serverlist);
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
                xpaths.sort = sorts;
                search.sortxpaths = xpaths;

                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status);
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        //[Ignore ("Known Bug: 22189")]
        public void QuerySearch_SortScoreXPathInvalid_22189()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SortScoreXPathInvalid Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral";
                search.sources = "oracle-1";

                search.sortscorexpath = "erin";
                search.outputscore = true;
                search.outputscoreSpecified = true;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status);
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
                Assert.AreNotEqual(0, response.queryresults.list.document[0].score, "Score not calculated correctly.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SourcesNone()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_SourcesNone Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "";
                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_SyntaxRepositoryNodeNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_syntaxRepositoryNodeNotExist Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.query = "admiral OR hipper";
                search.sources = "oracle-1";

                search.syntaxrepositorynode = "erin";

                response = service.QuerySearch(search);
                Assert.Fail("An exception should have been thrown.");
            }
            catch (SoapException se)
            {
                logger.Info("Exception thrown: " + se.Message);
                logger.Info("Additional Info: " + se.Detail.ToString());
                Assert.AreEqual("The exception [xml-macro-reference-error] was thrown.", se.Message,
                    "Incorrect exception thrown.");
            }
        }

        [Test]
        public void QuerySearch_SourcesNotExist()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

                logger.Info("Test: QuerySearch_SourcesNotExist Server: " + serverlist);
                service.Url = serverlist;

                try
                {
                    search.authentication = auth;
                    search.query = "";
                    search.sources = "idontexistsourceblah";
                    response = service.QuerySearch(search);
                    Assert.IsNull(response.queryresults.list, "Results returned.");
                    Assert.AreEqual(addedsourceStatus.unknown, response.queryresults.addedsource[0].status,
                        "Incorrect status returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }


        [Test]
        public void QuerySearch_QueryConditionObjectNull()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryConditionObjectNull Server: " + serverlist);
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
                search.queryconditionobject = new QuerySearchQueryconditionobject();
                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status);
                Assert.AreEqual(1, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryConditionObjectOperatorNull()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryConditionObjectOperatorNull Server: " + serverlist);
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
                search.queryconditionobject = new QuerySearchQueryconditionobject();
                search.queryconditionobject.@operator = null;

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status);
                Assert.AreEqual(1, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }


        [Test]
        public void QuerySearch_QueryConditionObjectOperatorEmpty()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryConditionObjectOperatorEmpty Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.queryobject = new QuerySearchQueryobject();
                search.queryobject.@operator = new @operator();
                search.queryobject.@operator.logic = "and";
                term te = new term();
                te.field = "title";
                te.str = "admiral";
                search.queryobject.@operator.Items = new Object[1];
                search.queryobject.@operator.Items[0] = te;
                search.sources = "oracle-1";
                search.queryconditionobject = new QuerySearchQueryconditionobject();
                search.queryconditionobject.@operator = new @operator();

                response = service.QuerySearch(search);
                Assert.IsNotNull(response.queryresults.list, "No results returned.");
                Assert.AreNotEqual(addedsourceStatus.skippedunsupportedsyntax, response.queryresults.addedsource[0].status);
                Assert.AreEqual(3, response.queryresults.list.document.Length, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryConditionXPathInvalid()
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

                search.queryconditionxpath = "blah";

                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_QueryConditionXPathNotIndexed()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_QueryConditionXPathNotIndexed Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                search.sources = "oracle-1";
                search.query = "uk";
                search.num = 100;

                search.queryconditionxpath = "$ALIGNED='allied'";

                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        [Test]
        public void QuerySearch_Empty()
        {
            // Variables
            auth.username = username;
            auth.password = password;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            logger.Info("Test: QuerySearch_Empty Server: " + serverlist);
            service.Url = serverlist;

            try
            {
                search.authentication = auth;
                response = service.QuerySearch(search);
                Assert.IsNull(response.queryresults.list, "Incorrect results returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }
    }
}
