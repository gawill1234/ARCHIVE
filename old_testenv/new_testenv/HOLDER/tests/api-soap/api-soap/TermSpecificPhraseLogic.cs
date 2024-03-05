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
    class TermSpecificPhraseLogic
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void TermSpecificPhraseLogic_None()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            string collection = "TermSpecificPhraseLogic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TermSpecificPhraseLogic_None Server: " + s);
                service.Url = s;

                try
                {
                    // Create Collection and crawl data.
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("termlogic.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait(collection, auth, s);

                    // Configure Search.
                    search.authentication = auth;
                    search.queryobject = new QuerySearchQueryobject();
                    search.queryobject.@operator = new @operator();
                    search.queryobject.@operator.logic = "and";
                    term te = new term();
                    te.field = "title";
                    te.str = "achates";
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;
                    search.sources = "TermSpecificPhraseLogic";

                    response = service.QuerySearch(search);
                    Assert.AreEqual(1, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void TermSpecificPhraseLogic_And()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            string collection = "TermSpecificPhraseLogic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TermSpecificPhraseLogic_And Server: " + s);
                service.Url = s;

                try
                {
                    // Create Collection and crawl data.
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("termlogic.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait(collection, auth, s);

                    // Configure Search.
                    search.authentication = auth;
                    search.queryobject = new QuerySearchQueryobject();
                    search.queryobject.@operator = new @operator();
                    search.queryobject.@operator.logic = "and";
                    term te = new term();
                    te.field = "title";
                    te.str = "admiral";
                    te.logic = termLogic.and;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;
                    search.sources = "TermSpecificPhraseLogic";

                    response = service.QuerySearch(search);
                    Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: admiral");

                    te.field = "title";
                    te.str = "admiral graf";
                    te.logic = termLogic.and;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(1, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: admiral graf");

                    te.field = "title";
                    te.str = "admiral achates";
                    te.logic = termLogic.and;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(0, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: admiral achates");

                    te.field = "title";
                    te.str = "Alg??";
                    te.logic = termLogic.and;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(1, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: Algérie");


                    te.field = "title";
                    te.str = "";
                    te.logic = termLogic.and;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(352, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: (none)");


                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void TermSpecificPhraseLogic_Or()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            string collection = "TermSpecificPhraseLogic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TermSpecificPhraseLogic_Or Server: " + s);
                service.Url = s;

                try
                {
                    // Create Collection and crawl data.
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("termlogic.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait(collection, auth, s);

                    // Configure Search.
                    search.authentication = auth;
                    search.queryobject = new QuerySearchQueryobject();
                    search.queryobject.@operator = new @operator();
                    search.queryobject.@operator.logic = "and";
                    term te = new term();
                    te.field = "title";
                    te.str = "admiral";
                    te.logic = termLogic.or;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;
                    search.sources = "TermSpecificPhraseLogic";

                    response = service.QuerySearch(search);
                    Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: admiral");

                    te.field = "title";
                    te.str = "admiral graf";
                    te.logic = termLogic.or;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(3, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: admiral graf");

                    te.field = "title";
                    te.str = "admiral achates";
                    te.logic = termLogic.or;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(4, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: admiral achates");

                    te.field = "title";
                    te.str = "Alg??";
                    te.logic = termLogic.or;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(1, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: Algérie");

                    te.field = "title";
                    te.str = "";
                    te.logic = termLogic.or;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(352, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: (none)");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void TermSpecificPhraseLogic_Near()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            string collection = "TermSpecificPhraseLogic-2";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TermSpecificPhraseLogic_Near Server: " + s);
                service.Url = s;

                try
                {
                    // Create Collection and crawl data.
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("termlogic-2.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait(collection, auth, s);

                    // Configure Search.
                    search.authentication = auth;
                    search.queryobject = new QuerySearchQueryobject();
                    search.queryobject.@operator = new @operator();
                    search.queryobject.@operator.logic = "and";
                    term te = new term();
                    te.field = "title";
                    te.str = "thomas draft";
                    te.logic = termLogic.near;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;
                    search.sources = collection;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(1, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: thomas draft");

                    te.field = "snippet";
                    te.str = "common task";
                    te.logic = termLogic.near;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(4, response.queryresults.addedsource[0].totalresultswithduplicates,
                        "Incorrect number of results returned.  Query str: common task");

                    te.field = "title";
                    te.str = "admiral erin";
                    te.logic = termLogic.near;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(0, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: admiral erin");


                    te.field = "title";
                    te.str = "";
                    te.logic = termLogic.near;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(47, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: (none)");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        [Test]
        public void TermSpecificPhraseLogic_Phrase()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse response = new QuerySearchResponse();
            string collection = "TermSpecificPhraseLogic-2";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TermSpecificPhraseLogic_Phrase Server: " + s);
                service.Url = s;

                try
                {
                    // Create Collection and crawl data.
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("termlogic-2.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait(collection, auth, s);

                    // Configure Search.
                    search.authentication = auth;
                    search.queryobject = new QuerySearchQueryobject();
                    search.queryobject.@operator = new @operator();
                    search.queryobject.@operator.logic = "and";
                    term te = new term();
                    te.field = "title";
                    te.str = "thomas jefferson";
                    te.logic = termLogic.phrase;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;
                    search.sources = collection;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(1, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: thomas jefferson");

                    te.field = "title";
                    te.str = "admiral erin";
                    te.logic = termLogic.phrase;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(0, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: admiral erin");

                    te.field = "title";
                    te.str = "Alg??";
                    te.logic = termLogic.phrase;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(0, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: Algérie");

                    te.field = "title";
                    te.str = "";
                    te.logic = termLogic.phrase;
                    te.logicSpecified = true;
                    search.queryobject.@operator.Items = new Object[1];
                    search.queryobject.@operator.Items[0] = te;

                    response = service.QuerySearch(search);
                    Assert.AreEqual(47, response.queryresults.addedsource[0].totalresults,
                        "Incorrect number of results returned.  Query str: (none)");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
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
