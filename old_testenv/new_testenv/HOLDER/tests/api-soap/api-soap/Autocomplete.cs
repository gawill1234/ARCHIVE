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
    class Autocomplete
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        public crawlurl makeAutocompleteCrawlurl(string url, string phrase, string count, string[][] metadata, string rights)
        {
            crawlurl cu = new crawlurl();
            cu.url = url;
            cu.status = crawlurlStatus.complete;
            cu.synchronization = crawlurlSynchronization.indexed;
            cu.crawldata = new crawldata[1];
            cu.crawldata[0] = new crawldata();
            crawldata cd = cu.crawldata[0];
            cd.encodingSpecified = true;
            cd.encoding = crawldataEncoding.xml;
            cd.contenttype = "application/vxml";

            document doc = new document();
            if (metadata == null)
            {
                doc.content = new content[2];
            }
            else
            {
                doc.content = new content[metadata.Length + 2];
            }
            doc.content[0] = new content();
            content c = doc.content[0];
            c.name = "ac.phrase";
            c.Value = phrase;
            if (rights != null)
            {
                c.acl = rights;
            }
            doc.content[1] = new content();
            c = doc.content[1];
            c.name = "ac.count";
            c.Value = count;
            if (rights != null)
            {
                c.acl = rights;
            }
            if (metadata != null)
            {
                for (int i = 0; i < metadata.Length; i++)
                {
                    int j = i + 2;
                    doc.content[j] = new content();
                    c = doc.content[j];
                    c.name = metadata[i][0];
                    c.Value = metadata[i][1];
                    if (rights != null)
                    {
                        c.acl = rights;
                    }
                }
            }

            cd.vxml = new crawldataVxml();

            cd.vxml.document = new document[1];
            cd.vxml.document[0] = doc;

            return cu;
        }

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

        [Test]
        public void TestAutocompleteSuggestion()
        {

            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAutocomplete-autocomplete";
            string DictionaryName = "TestAutocomplete";
            XmlElement XmlToAdd;
            XmlToAdd = TestUtilities.ReadXmlFile("autocomplete.xml");
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAutocompleteSuggestion Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    string[][] meta = new string[2][];
                    meta[0] = new string[] { "bar", "meta" };
                    meta[1] = new string[] { "baz", "woof" };
                    crawlurl cu = makeAutocompleteCrawlurl("a", "foo", "2", meta, null);

                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.collection = CollectionName;
                    sce.authentication = auth;
                    sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    sce.crawlurls.crawlurl = new crawlurl[1];
                    sce.crawlurls.crawlurl[0] = cu;

                    service.SearchCollectionEnqueue(sce);

                    TestUtilities.WaitCrawlerIdle(CollectionName, auth, s);

                    AutocompleteSuggest acs = new AutocompleteSuggest();
                    acs.dictionary = DictionaryName;
                    acs.authentication = auth;
                    acs.str = "f";
                    AutocompleteSuggestResponse asr = service.AutocompleteSuggest(acs);
                    Assert.IsNotNull(asr.suggestions);
                    Assert.IsNotNull(asr.suggestions.query);
                    Assert.AreEqual("f", asr.suggestions.query);

                    Assert.AreEqual(1, asr.suggestions.suggestion.Length);
                    foreach (suggestionsSuggestion sugg in asr.suggestions.suggestion)
                    {
                        Assert.IsNotNull(sugg.phrase);
                        Assert.AreEqual("foo", sugg.phrase);
                        Assert.IsNotNull(sugg.count);
                        Assert.AreEqual(2, sugg.count);
                        Assert.IsNotNull(sugg.metadata);
                        Assert.AreEqual(2, sugg.metadata.Length);
                        Assert.IsNotNull(sugg.metadata[0]);
                        Assert.IsNotNull(sugg.metadata[0].name);
                        Assert.IsNotNull(sugg.metadata[0].Value);
                        Assert.AreEqual("bar", sugg.metadata[0].name);
                        Assert.AreEqual("meta", sugg.metadata[0].Value);
                        Assert.IsNotNull(sugg.metadata[1]);
                        Assert.IsNotNull(sugg.metadata[1].name);
                        Assert.IsNotNull(sugg.metadata[1].Value);
                        Assert.AreEqual("baz", sugg.metadata[1].name);
                        Assert.AreEqual("woof", sugg.metadata[1].Value);
                    }

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void TestAutocompleteNoSuggestion()
        {

            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAutocomplete-autocomplete";
            string DictionaryName = "TestAutocomplete";
            XmlElement XmlToAdd;
            XmlToAdd = TestUtilities.ReadXmlFile("autocomplete.xml");
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAutocompleteNoSuggestion Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    string[][] meta = new string[2][];
                    meta[0] = new string[] { "bar", "meta" };
                    meta[1] = new string[] { "baz", "woof" };
                    crawlurl cu = makeAutocompleteCrawlurl("a", "foo", "2", meta, null);

                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.collection = CollectionName;
                    sce.authentication = auth;
                    sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    sce.crawlurls.crawlurl = new crawlurl[1];
                    sce.crawlurls.crawlurl[0] = cu;

                    service.SearchCollectionEnqueue(sce);

                    TestUtilities.WaitCrawlerIdle(CollectionName, auth, s);

                    AutocompleteSuggest acs = new AutocompleteSuggest();
                    acs.dictionary = DictionaryName;
                    acs.authentication = auth;
                    acs.str = "b";
                    AutocompleteSuggestResponse asr = service.AutocompleteSuggest(acs);
                    Assert.IsNotNull(asr.suggestions);
                    Assert.IsNotNull(asr.suggestions.query);
                    Assert.AreEqual("b", asr.suggestions.query);

                    Assert.IsNull(asr.suggestions.suggestion);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void TestAutocompleteNoMetadata()
        {

            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAutocomplete-autocomplete";
            string DictionaryName = "TestAutocomplete";
            XmlElement XmlToAdd;
            XmlToAdd = TestUtilities.ReadXmlFile("autocomplete.xml");
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAutocompleteNoMetadata Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    crawlurl cu = makeAutocompleteCrawlurl("a", "foo", "2", null, null);

                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.collection = CollectionName;
                    sce.authentication = auth;
                    sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    sce.crawlurls.crawlurl = new crawlurl[1];
                    sce.crawlurls.crawlurl[0] = cu;

                    service.SearchCollectionEnqueue(sce);

                    TestUtilities.WaitCrawlerIdle(CollectionName, auth, s);

                    AutocompleteSuggest acs = new AutocompleteSuggest();
                    acs.dictionary = DictionaryName;
                    acs.authentication = auth;
                    acs.str = "f";
                    AutocompleteSuggestResponse asr = service.AutocompleteSuggest(acs);
                    Assert.IsNotNull(asr.suggestions);
                    Assert.IsNotNull(asr.suggestions.query);
                    Assert.AreEqual("f", asr.suggestions.query);

                    Assert.AreEqual(1, asr.suggestions.suggestion.Length);
                    foreach (suggestionsSuggestion sugg in asr.suggestions.suggestion)
                    {
                        Assert.IsNotNull(sugg.phrase);
                        Assert.AreEqual("foo", sugg.phrase);
                        Assert.IsNotNull(sugg.count);
                        Assert.AreEqual(2, sugg.count);
                        Assert.IsNull(sugg.metadata);
                    }

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.StopCrawlAndIndex(CollectionName, auth, s);
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void TestAutocompleteNumParam()
        {

            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAutocomplete-autocomplete";
            string DictionaryName = "TestAutocomplete";
            XmlElement XmlToAdd;
            XmlToAdd = TestUtilities.ReadXmlFile("autocomplete.xml");
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAutocompleteNumParam Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.collection = CollectionName;
                    sce.authentication = auth;
                    sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    sce.crawlurls.crawlurl = new crawlurl[15];

                    for (int i = 0; i < 15; i++)
                    {
                        crawlurl cu = makeAutocompleteCrawlurl(i.ToString(), "foo" + i, (i + 1).ToString(), null, null);

                        sce.crawlurls.crawlurl[i] = cu;
                    }

                    service.SearchCollectionEnqueue(sce);

                    TestUtilities.WaitCrawlerIdle(CollectionName, auth, s);

                    AutocompleteSuggest acs = new AutocompleteSuggest();
                    acs.dictionary = DictionaryName;
                    acs.authentication = auth;
                    acs.str = "f";
                    AutocompleteSuggestResponse asr = service.AutocompleteSuggest(acs);
                    Assert.IsNotNull(asr.suggestions);
                    Assert.IsNotNull(asr.suggestions.query);
                    Assert.AreEqual("f", asr.suggestions.query);

                    Assert.AreEqual(10, asr.suggestions.suggestion.Length);

                    for (int j = 0; j < asr.suggestions.suggestion.Length; j++)
                    {
                        suggestionsSuggestion sugg = asr.suggestions.suggestion[j];
                        Assert.IsNotNull(sugg.phrase);
                        Assert.AreEqual("foo" + (14 - j).ToString(), sugg.phrase);
                        Assert.IsNotNull(sugg.count);
                        Assert.AreEqual(14 - j + 1, sugg.count);
                        Assert.IsNull(sugg.metadata);
                    }

                    acs.num = 3;
                    asr = service.AutocompleteSuggest(acs);
                    Assert.IsNotNull(asr.suggestions);
                    Assert.IsNotNull(asr.suggestions.query);
                    Assert.AreEqual("f", asr.suggestions.query);

                    Assert.AreEqual(3, asr.suggestions.suggestion.Length);
                    for (int j = 0; j < asr.suggestions.suggestion.Length; j++)
                    {
                        suggestionsSuggestion sugg = asr.suggestions.suggestion[j];
                        Assert.IsNotNull(sugg.phrase);
                        Assert.AreEqual("foo" + (14 - j).ToString(), sugg.phrase);
                        Assert.IsNotNull(sugg.count);
                        Assert.AreEqual(14 - j + 1, sugg.count);
                        Assert.IsNull(sugg.metadata);
                    }

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void TestAutocompleteRightsParam()
        {

            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAutocomplete-autocomplete";
            string DictionaryName = "TestAutocomplete";
            XmlElement XmlToAdd;
            XmlToAdd = TestUtilities.ReadXmlFile("autocomplete.xml");
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAutocompleteRightsParam Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    crawlurl cu = makeAutocompleteCrawlurl("a", "foo", "2", null, "techies");

                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.collection = CollectionName;
                    sce.authentication = auth;
                    sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    sce.crawlurls.crawlurl = new crawlurl[1];
                    sce.crawlurls.crawlurl[0] = cu;

                    service.SearchCollectionEnqueue(sce);

                    TestUtilities.WaitCrawlerIdle(CollectionName, auth, s);

                    AutocompleteSuggest acs = new AutocompleteSuggest();
                    acs.dictionary = DictionaryName;
                    acs.authentication = auth;
                    acs.str = "f";
                    acs.rights = "customers";

                    AutocompleteSuggestResponse asr = service.AutocompleteSuggest(acs);
                    Assert.IsNotNull(asr.suggestions);
                    Assert.IsNotNull(asr.suggestions.query);
                    Assert.AreEqual("f", asr.suggestions.query);

                    Assert.IsNull(asr.suggestions.suggestion);

                    acs = new AutocompleteSuggest();
                    acs.dictionary = DictionaryName;
                    acs.authentication = auth;
                    acs.str = "f";
                    acs.rights = "techies";

                    asr = service.AutocompleteSuggest(acs);
                    Assert.IsNotNull(asr.suggestions);
                    Assert.IsNotNull(asr.suggestions.query);
                    Assert.AreEqual("f", asr.suggestions.query);

                    Assert.AreEqual(1, asr.suggestions.suggestion.Length);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void TestAutocompleteBagOfWords()
        {

            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAutocomplete-autocomplete";
            string DictionaryName = "TestAutocomplete";
            XmlElement XmlToAdd;
            XmlToAdd = TestUtilities.ReadXmlFile("autocomplete.xml");
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAutocompleteBagOfWords Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    crawlurl cu = makeAutocompleteCrawlurl("a", "foo bar", "2", null, null);

                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.collection = CollectionName;
                    sce.authentication = auth;
                    sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    sce.crawlurls.crawlurl = new crawlurl[1];
                    sce.crawlurls.crawlurl[0] = cu;

                    service.SearchCollectionEnqueue(sce);

                    TestUtilities.WaitCrawlerIdle(CollectionName, auth, s);

                    AutocompleteSuggest acs = new AutocompleteSuggest();
                    acs.dictionary = DictionaryName;
                    acs.authentication = auth;
                    acs.str = "bar f";
                    AutocompleteSuggestResponse asr = service.AutocompleteSuggest(acs);
                    Assert.IsNotNull(asr.suggestions);
                    Assert.IsNotNull(asr.suggestions.query);
                    Assert.AreEqual("bar f", asr.suggestions.query);

                    Assert.IsNull(asr.suggestions.suggestion);

                    acs.bagofwords = true;
                    asr = service.AutocompleteSuggest(acs);
                    Assert.IsNotNull(asr.suggestions);
                    Assert.IsNotNull(asr.suggestions.query);
                    Assert.AreEqual("bar f", asr.suggestions.query);

                    Assert.AreEqual(1, asr.suggestions.suggestion.Length);
                    foreach (suggestionsSuggestion sugg in asr.suggestions.suggestion)
                    {
                        Assert.IsNotNull(sugg.phrase);
                        Assert.AreEqual("foo bar", sugg.phrase);
                        Assert.IsNotNull(sugg.count);
                        Assert.AreEqual(2, sugg.count);
                        Assert.IsNull(sugg.metadata);
                    }

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }

        [Test]
        public void TestAutocompleteFilter()
        {

            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestAutocomplete-autocomplete";
            string DictionaryName = "TestAutocomplete";
            XmlElement XmlToAdd;
            XmlToAdd = TestUtilities.ReadXmlFile("autocomplete.xml");
            XmlElement FilterToAdd;
            FilterToAdd = TestUtilities.ReadXmlFile("autocomplete-filter.xml");
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            RepositoryAdd ra = new RepositoryAdd();
            ra.authentication = auth;
            ra.node = FilterToAdd;
            service.RepositoryAdd(ra);

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAutocompleteFilter Server: " + s);

                try
                {
                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    crawlurl cu1 = makeAutocompleteCrawlurl("a", "foo bar", "2", null, null);
                    crawlurl cu2 = makeAutocompleteCrawlurl("a", "foo baz", "2", null, null);

                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.collection = CollectionName;
                    sce.authentication = auth;
                    sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    sce.crawlurls.crawlurl = new crawlurl[2];
                    sce.crawlurls.crawlurl[0] = cu1;
                    sce.crawlurls.crawlurl[1] = cu2;

                    service.SearchCollectionEnqueue(sce);

                    TestUtilities.WaitCrawlerIdle(CollectionName, auth, s);

                    AutocompleteSuggest acs = new AutocompleteSuggest();
                    acs.dictionary = DictionaryName;
                    acs.authentication = auth;
                    acs.str = "f";
                    acs.filter = "bar-filter";
                    AutocompleteSuggestResponse asr = service.AutocompleteSuggest(acs);
                    Assert.IsNotNull(asr.suggestions);
                    Assert.IsNotNull(asr.suggestions.query);
                    Assert.AreEqual("f", asr.suggestions.query);

                    Assert.AreEqual(1, asr.suggestions.suggestion.Length);
                    foreach (suggestionsSuggestion sugg in asr.suggestions.suggestion)
                    {
                        Assert.IsNotNull(sugg.phrase);
                        Assert.AreEqual("foo baz", sugg.phrase);
                        Assert.IsNotNull(sugg.count);
                        Assert.AreEqual(2, sugg.count);
                        Assert.IsNull(sugg.metadata);
                    }

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    // Delete Search Collection
                    RepositoryDelete rd = new RepositoryDelete();
                    rd.authentication = auth;
                    rd.element = "filter";
                    rd.name = "bar-filter";
                    service.RepositoryDelete(rd);
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }


    }
}
