using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web.Services.Protocols;
using System.Xml;
using System.Threading;
using o = System.Console;
using NUnit.Framework;

namespace APITests
{
    [TestFixture]
    class CodeExamples
    {
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;
        const string BASED_ON = "default-push";
        const string ENQ_URL = "http://vivisimo.com/";
        const long MAXTIME = 5000;
        const int NUMDOCS = 1;


        [Test]
        public void queryObjectExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "queryObjectExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;
                try
                {
                    multiAttachment(collection, auth, s);
                    /*example start: cs-structured-query */
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.queryobject = new QuerySearchQueryobject();
                    qs.queryobject.@operator = new @operator();
                    qs.queryobject.@operator.logic = "or";
                    term te1 = new term();
                    te1.field = "query";
                    te1.str = "some main document";
                    te1.phrase = termPhrase.phrase;

                    @operator op2 = new @operator();
                    op2.logic = "and";
                    op2.Items = new object[2];
                    term te2 = new term();
                    te2.field = "query";
                    te2.str = "first";
                    term te3 = new term();
                    te3.field = "query";
                    te3.str = "test";
                    op2.Items[0] = te2;
                    op2.Items[1] = te3;

                    qs.queryobject.@operator.Items = new Object[2];
                    qs.queryobject.@operator.Items[0] = te1;
                    qs.queryobject.@operator.Items[1] = op2;
                    qs.sources = collection;
                    // note: since we are sending in a structured query object there is no need to reference a 
                    // syntax node.  There is no query parsing that takes place and you can manually set up feild
                    // searches by specifying the 'field' attribute of a specific term
                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    /*example end: cs-structured-query */
                    Assert.IsTrue(qsr.queryresults.list != null, "No results returned.");
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
        public void queryExample()
        {

            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "queryExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;
                try
                {
                    multiAttachment(collection, auth, s);

                    /* example start: cs-simple-query */
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "\"some main document\" OR (first and test)";

                    // if sending in the plain text query and using custom fields or operators you must define those
                    // in a syntax node and reference it for your query so the software can correctly parse the textual query
                    /* example start: cs-query-syntax-rep-node */
                    //qs.syntaxrepositorynode = "custom";
                    /* example end: cs-query-syntax-rep-node */

                    // specify the list of syntax operators your query will use.
                    // NOTE: this must be defined in syntaxrepositorynode (this defines what the operator *is*
                    //       but must *also* be in this list so that the query can be parsed correctly.
                    // by default 

                    //qs.syntaxoperators = "AND and () CONTAINING CONTENT %field%: + NEAR - NOT NOTCONTAINING NOTWITHIN OR0 quotes regex stem THRU BEFORE FOLLOWEDBY weight wildcard wildchar WITHIN WORDS site less-than less-than-or-equal greater-than greater-than-or-equal equal range";
                    // if you've defined any custom modification macros for Velocity to manipulate your query, such
                    // as stopword removal, thesaurus expansion, etc. specify the macro name here
                    //qs.querymodificationmacros = "some_macro_here";
                    // if querying multiple collections turn on aggregate mode to have the software query the separate 
                    // collections as if they were all coming from a single collection
                    qs.aggregate = true;
                    // if in aggregate mode you can control the number of times each source may be re-queried if the 
                    // query and result set dictate it (i.e. if sorting, or if more relevant results come from a single
                    // collection in the queried set
                    qs.aggregatemaxpasses = 3;
                    // if you've configured your sources to perform late binding security checks this is where you 
                    // specify the username and password
                    qs.authorizationpassword = password;
                    qs.authorizationusername = username;
                    // if you've configured your source to require security groups this is where you pass those in, in a 
                    // newline separated list
                    qs.authorizationrights = "acl1\nacl2\nacl3";
                    // by default fetch is true which means results will be requested for each collection.  However if
                    // querying a bundle and wishing to get a list of all sources fully expanded for, say, building out
                    // an advanced form set this to false and no results will be requested but you will be returned
                    // a reqular query response otherwise
                    qs.fetch = false;
                    // by default the maximum time a query may take is 60 seconds.  Override this value if you wish to
                    // increase or decrease this value
                    qs.fetchtimeout = 60000;

                    // number of results to retrieve
                    qs.num = 200;
                    // maximium number of results to rank
                    // NOTE: if you are going to be issuing subsequent queries to "page" into the collection
                    // you will want to set this value to *at least* qs.start + qs.num on each request
                    qs.nummax = 500;

                    qs.nummaxSpecified = true;
                    // if querying multiple sources this will be used as a multiplier when retrieving results from
                    // each source to better ensure at least the minimum required results are returned
                    // i.e. if you are asking for 200 total across 2 sources, typically 100 will be requested from 
                    // each source but it's possible for results to only come from one of the sources.  The multiplier
                    // tries to alleviate this.
                    // NOTE: see aggregate options if you want to treat two physical sources as a single logical source
                    qs.numoverrequest = 1.3;
                    // number of results to request per source
                    qs.numpersource = 25;
                    qs.numpersourceSpecified = true;
                    // the starting location to retrieve results from 
                    qs.start = 0;
                    // NOTE: maximum ranked results (either nummax or num*numoverrequest) must be > start + num

                    // if you want our software to return contextual hits that are bolded use the following
                    qs.outputboldcontents = "title snippet";
                    qs.outputboldcontentsexcept = false;
                    // to have all contents bolded set use the following:
                    qs.outputboldcontents = "";
                    qs.outputboldcontentsexcept = true;
                    // by default we surround matches with <b>..</b> tags but
                    // to control what we use to identify matches specify a custom class
                    qs.outputboldclassroot = "myClass";
                    // this will generate <span class="myClass">...</span> around matches

                    // by default this is true for sources so set to false if not interested in the 
                    // cache references
                    qs.outputcachereferencesSpecified = false;
                    // if you're collection was configured to use our cache database set 
                    // outputcachereferencesSpecified=true and then set the following to true
                    // to return the entire cache node.  This will greatly increase the size of the 
                    // returned xml and probably should be used for queries that are guaranteed to 
                    // return a single document, such as DOCUMENT_KEY queries
                    qs.outputcachedataSpecified = true;

                    // by default all contents configured in your collection will be output
                    // but you can control this on a per-query basis using the following options
                    qs.outputcontents = "contentA contentB";
                    // output *only* the specified contents
                    qs.outputcontentsmode = QuerySearchOutputcontentsmode.list;
                    // output all contents *except* those specified
                    qs.outputcontentsmode = QuerySearchOutputcontentsmode.except;
                    // use the collection's defaults
                    qs.outputcontentsmode = QuerySearchOutputcontentsmode.defaults;

                    // to control whether or not you want duplicates output by the search collection use the following
                    qs.outputduplicates = true;
                    qs.outputduplicatesSpecified = true;
                    // if querying multiple collections at the same time and you want to remove duplicate results
                    // that share the same key (based on vse-key) enable this option.
                    qs.outputkey = true;
                    qs.outputkeySpecified = true;
                    // if querying multiple sources and aggregating them together enable the following 
                    // so that the federation layer can combine the results properly based on the ranking score
                    qs.outputscore = true;
                    qs.outputscoreSpecified = true;
                    // if querying multiple sources and wanting to remove near duplicates across all of the collections
                    // enable the following.
                    qs.outputshingles = true;
                    qs.outputshinglesSpecified = true;
                    // need to get info here
                    qs.outputsortkeys = true;
                    qs.outputsortkeysSpecified = true;
                    // if you'd like to output whatever contents your collection has specified to be summarized
                    // enable the following
                    // NOTE: if you'd like to specify contents to be summarized on a per-call basis you will have
                    // to use output-axl as of now
                    qs.outputsummary = true;
                    qs.outputsummarySpecified = true;
                    // this should be a double!
                    // this option controls the decay of ranking passages.  Each ranking passage is assigned a score
                    // and then this value is used to determine on ranking passages affect the overall score.  The 
                    // default is 0.5.  Example) 1*<1st_passage_score> + 0.5*<2nd_passage_score> + 0.24*<34_passage_score>
                    // if you want all passages to be weighted equally set this to 1.0
                    qs.rankdecay = 0.5;
                    qs.rankdecaySpecified = true;

                    // to enable debug output
                    // NOTE: turning this on will negatively effect performance.  It will create debug files in
                    // whatever directory you have configured.  These files are interacted with through the admin
                    // tool in the 'Management' -> 'Debug Sessions' section of admin
                    qs.debug = false;

                    // enable this option if you want to produce performance information for your query.  This behaves
                    // similar to the debug option.  You should not enable both debugging and profiling at the same
                    // time since debugging will affect performance
                    qs.profile = false;

                    // there is also a parameter that allows you to pass in arbitrary xml.  This could be useful if
                    // you have configured your sources to look for some customer parameter that query-search does not
                    // provide.  In that case you would create your xml elements and assign the entire xml structure to
                    // the 'extraxml' attribute of the QuerySearch object.
                    //qs.extraxml = null; // assign your custom xml here

                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    /*example end: cs-simple-query */

                    Assert.IsTrue(qsr.queryresults.list == null, "No results returned.");

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
        public void querySimilarDocumentsExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "querySimilarDocumentsExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;
                try
                {
                    /* example start: cs-locate-similar-docs */
                    QuerySimilarDocuments qsd = new QuerySimilarDocuments();
                    qsd.authentication = auth;
                    QuerySimilarDocumentsDocument doc = new QuerySimilarDocumentsDocument();
                    qsd.document = doc;
                    doc.document = new document();
                    // populate the document as you would a vxml document 
                    // or better yet grab a document from a result set
                    doc.document = new document(); // ignore
                    doc.document.content = new content[1]; // ignore
                    doc.document.content[0] = new content(); // ignore
                    doc.document.content[0].name = "snippet"; // ignore
                    doc.document.content[0].Value = "<html><head><title>My HTML page title</title></head><body>My body</body></html>"; // ignore

                    QuerySimilarDocumentsResponse qsdr = service.QuerySimilarDocuments(qsd);
                    @operator op = qsdr.@operator;
                    // you can then take this operator and make it your new query object for a subsequent query request
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.queryobject = new QuerySearchQueryobject();
                    qs.queryobject.@operator = op;
                    /* example end: cs-locate-similar-docs */

                    Assert.IsTrue(op != null, "No operator returned.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }


        [Test]
        public void reportsSystemReportsExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "queryConditionXpathExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;

                try
                {
                    /* example start: cs-reports-sys-reports */
                    ReportsSystemReporting rsr = new ReportsSystemReporting();
                    rsr.authentication = auth;
                    rsr.maxitems = 1000;
                    rsr.start = DateTime.Now.AddDays(-30);
                    rsr.end = DateTime.Now;

                    ReportsSystemReportingResponse rsrresp = service.ReportsSystemReporting(rsr);

                    Assert.IsTrue(rsrresp.systemreport != null, "No report returned."); // ignore
                    if (rsrresp.systemreport != null)
                    {

                        systemreport sysrep = rsrresp.systemreport;
                        DateTime lastDate = new DateTime(0);

                        Assert.IsTrue(sysrep.systemreportitem != null); // ignore
                        if (sysrep.systemreportitem != null)
                        {

                            foreach (systemreportitem item in sysrep.systemreportitem)
                            {
                                // process
                                DateTime d = item.date;
                                lastDate = d;
                                String id = item.id;
                                String msg = item.message;
                                systemreportitemType type = item.type;

                            }
                            lastDate = sysrep.systemreportitem[sysrep.systemreportitem.Length - 1].date;

                            rsr.start = lastDate;
                            if (sysrep.systemreportitem.Length == rsr.maxitems)
                            {
                                /// query again to grab the next batch
                            }
                        }

                    }
                    /* example end: cs-reports-sys-reports */

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }


        [Test]
        public void queryConditionXpathExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "queryConditionXpathExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;
                try
                {
                    searchCollectionFastIndexEnqueue(collection, auth, s);

                    /* example start: cs-fi-query */
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.queryconditionxpath = "$field2=12345 and $field1='My field 1'";

                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qres = qsr.queryresults;
                    /* example end: cs-fi-query */

                    Assert.IsTrue(qres.list != null && qres.list.document.Length == 1, "No results returned.");
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
        public void multiAttachmentExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "multiAttachmentExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;
                try
                {
                    multiAttachment(collection, auth, s);

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
        public void multiValueFieldExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "multiValueFieldExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server {1}", collection, s);
                service.Url = s;

                try
                {
                    if (!TestUtilities.isInRepo("vse-collection", collection, auth, s))
                    {
                        TestUtilities.CreateSearchCollection(collection, auth, s);
                        Assert.IsTrue(TestUtilities.isInRepo("vse-collection", collection, auth, s), "Collection not created.");
                    }
                    else
                    {
                        TestUtilities.prepCollection(collection, null, true, true, true, true, false, 3, auth, s);
                    }

                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.authentication = auth;
                    sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    sce.collection = collection;
                    /* example start: cs-multi-value-field */
                    crawlurl[] cus = new crawlurl[1];
                    sce.crawlurls.crawlurl = cus;
                    cus[0] = new crawlurl();
                    cus[0].url = "myproto://doc?id=2";
                    cus[0].status = crawlurlStatus.complete;
                    cus[0].crawldata = new crawldata[1];
                    cus[0].crawldata[0] = new crawldata();
                    cus[0].crawldata[0].vxml = new crawldataVxml();
                    cus[0].crawldata[0].contenttype = "application/vxml";
                    document[] docs1 = new document[1];
                    cus[0].crawldata[0].vxml.document = docs1;
                    docs1[0] = new document();
                    docs1[0].vsekeynormalizedSpecified = true;
                    docs1[0].vsekey = "key-2";
                    docs1[0].content = new content[3];
                    docs1[0].content[0] = new content();
                    docs1[0].content[0].name = "emailTo";
                    docs1[0].content[0].Value = "sample1@vivisimo.com";
                    docs1[0].content[1] = new content();
                    docs1[0].content[1].name = "emailTo";
                    docs1[0].content[1].Value = "sample2@vivisimo.com";
                    docs1[0].content[2] = new content();
                    docs1[0].content[2].name = "emailTo";
                    docs1[0].content[2].Value = "sample3@vivisimo.com";

                    SearchCollectionEnqueueResponse enqresp = service.SearchCollectionEnqueue(sce);
                    /* example end: cs-multi-value-field */

                    Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                        "Enqueue failed.");

                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, 1, 3000, auth, s));

                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "DOCUMENT:key-2";
                    qs.outputcontents = "emailTo";
                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No results returned.");

                    int count = 0;
                    foreach (document d in qres.list.document)
                    {
                        foreach (content c in d.content)
                        {
                            if (c.name.Equals("emailTo")) count++;
                        }
                    }

                    Assert.IsTrue(count == 3, "Incorrect number of results returned.");
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
        public void sortXpathsExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "sortXpathsExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;

                try
                {
                    if (!TestUtilities.isInRepo("vse-collection", collection, auth, s))
                    {
                        TestUtilities.CreateSearchCollection(collection, auth, s);
                        Assert.IsTrue(TestUtilities.isInRepo("vse-collection", collection, auth, s));
                    }
                    else
                    {
                        TestUtilities.prepCollection(collection, null, true, true, true, true, false, 3, auth, s);
                    }

                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.authentication = auth;
                    sce.collection = collection;
                    SearchCollectionEnqueueCrawlurls crurls = new SearchCollectionEnqueueCrawlurls();
                    sce.crawlurls = crurls;
                    crawlurl[] cu = new crawlurl[3];
                    crurls.crawlurl = cu;

                    cu[0] = new crawlurl();
                    cu[0].status = crawlurlStatus.complete;
                    cu[0].url = "myproto://doc?id=1";
                    crawldata[] cdata0 = new crawldata[1];
                    cu[0].crawldata = cdata0;
                    cdata0[0] = new crawldata();
                    cdata0[0].contenttype = "application/vxml";

                    crawldataVxml vxml0 = new crawldataVxml();
                    cdata0[0].vxml = vxml0;
                    document[] doc0 = new document[1];
                    vxml0.document = doc0;
                    content[] content0 = new content[1];
                    doc0[0] = new document();
                    doc0[0].content = content0;
                    content0[0] = new content();
                    content0[0].name = "field1";
                    content0[0].Value = "1";
                    content0[0].fastindex = fastindextype.@int;
                    content0[0].fastindexSpecified = true;


                    cu[1] = new crawlurl();
                    cu[1].status = crawlurlStatus.complete;

                    cu[1].url = "myproto://doc?id=2";
                    crawldata[] cdata1 = new crawldata[1];
                    cu[1].crawldata = cdata1;
                    cdata1[0] = new crawldata();
                    cdata1[0].contenttype = "application/vxml";

                    crawldataVxml vxml1 = new crawldataVxml();
                    cdata1[0].vxml = vxml1;
                    document[] doc1 = new document[1];
                    vxml1.document = doc1;
                    content[] content1 = new content[1];
                    doc1[0] = new document();
                    doc1[0].content = content1;
                    content1[0] = new content();
                    content1[0].name = "field1";
                    content1[0].Value = "3";
                    content1[0].fastindex = fastindextype.@int;
                    content1[0].fastindexSpecified = true;

                    cu[2] = new crawlurl();
                    cu[2].status = crawlurlStatus.complete;

                    cu[2].url = "myproto://doc?id=3";
                    crawldata[] cdata2 = new crawldata[1];
                    cu[2].crawldata = cdata2;
                    cdata2[0] = new crawldata();
                    cdata2[0].contenttype = "application/vxml";

                    crawldataVxml vxml2 = new crawldataVxml();
                    cdata2[0].vxml = vxml2;
                    document[] doc2 = new document[1];
                    vxml2.document = doc2;
                    content[] content2 = new content[1];
                    doc2[0] = new document();
                    doc2[0].content = content2;
                    content2[0] = new content();
                    content2[0].name = "field1";
                    content2[0].Value = "2";
                    content2[0].fastindex = fastindextype.@int;
                    content2[0].fastindexSpecified = true;


                    SearchCollectionEnqueueResponse enqresp = service.SearchCollectionEnqueue(sce);

                    Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                        "Enqueue Failed.");

                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, 3, 3000, auth, s), "Collection not queryable.");


                    QuerySearch qs0 = new QuerySearch();
                    qs0.authentication = auth;
                    qs0.sources = collection;
                    QuerySearchResponse qsresp0 = service.QuerySearch(qs0);

                    Assert.IsTrue(qsresp0.queryresults.list != null && qsresp0.queryresults.list.document.Length == 3,
                        "Correct results not returned.");

                    /* example start: cs-sort-xpath */
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;

                    QuerySearchSortxpaths xpaths = new QuerySearchSortxpaths();
                    qs.sortxpaths = xpaths;
                    sort[] sorts = new sort[1];
                    sorts[0] = new sort();
                    sorts[0].order = sortOrder.ascending;
                    sorts[0].xpath = "$field1";
                    xpaths.sort = sorts;

                    XmlDocument d = new XmlDocument(); // ignore
                    XmlElement e = d.CreateElement("document"); // ignore
                    d.AppendChild(e); // ignore
                    XmlElement c = d.CreateElement("content"); // ignore
                    e.AppendChild(c); // ignore
                    c.SetAttribute("name", "custom-name"); // ignore
                    XmlElement v = d.CreateElement("value-of"); // ignore
                    c.AppendChild(v); // ignore
                    v.SetAttribute("select", "vse:fi-value('field1')"); // ignore
                    qs.outputaxl = e; // ignore

                    // set to 0 since not using $score in ranking
                    qs.sortnumpassages = 0;
                    qs.sortnumpassagesSpecified = true;
                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    /* example end: cs-sort-xpath */

                    queryresults qres = qsr.queryresults;
                    Assert.IsTrue(qres.list != null);

                    Assert.IsTrue(qres.list.document[0].content[0].Value.Equals("1"), "Incorrect document returned.");
                    Assert.IsTrue(qres.list.document[1].content[0].Value.Equals("2"), "Incorrect document returned.");
                    Assert.IsTrue(qres.list.document[2].content[0].Value.Equals("3"), "Incorrect document returned.");
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
        public void sortByExample()
        {
            /* example start: cs-sort-xpath-2 */
            QuerySearch qs = new QuerySearch();
            // this must be defined in the source
            // better to use sortXpaths
            qs.sortby = "mySort";

            // use this to limit the number of ranking passages to use when
            // calculating relevancy
            qs.sortnumpassages = 10;
            qs.sortnumpassagesSpecified = true;

            // set to 0 if not using $score in your ranking algorithm
            // i.e. if you're specifying sort-by or sort-xpaths
            qs.sortnumpassages = 0;
            qs.sortnumpassagesSpecified = true;
            qs.sortby = "mySort";
            // or
            qs.sortxpaths = new QuerySearchSortxpaths();


            // this is what is used to output a score on documents
            // this is overridden if sort-by or sort-xpaths is specified
            // you can use any xpath formula that uses $score or $la-score
            qs.sortscorexpath = "$score + $la-score";
            /* example end: cs-sort-xpath-2 */

        }
        

        [Test]
        public void collapseExample()
        {
            /* example start: cs-query-collapse */
            QuerySearch qs = new QuerySearch();
            // collapse the binning values as well so that collapsed documents only count as one occurrance in the 
            // bins
            qs.collapsebinning = true;
            qs.collapsebinningSpecified = true;
            // how many collaped documents to return under a top-level document
            // NOTE: this will increae the amount of xml returned
            qs.collapsenum = 10;
            qs.collapsenumSpecified = true;
            // the field to sort by within a collapsed key
            // so if the key was a document number, you might want to sort by date to ensure you always get the 
            // newest version back up top
            qs.collapsesortxpaths = new QuerySearchCollapsesortxpaths();
            qs.collapsesortxpaths.sort = new sort[1];
            qs.collapsesortxpaths.sort[0] = new sort();
            qs.collapsesortxpaths.sort[0].order = sortOrder.descending;
            qs.collapsesortxpaths.sort[0].xpath = "$some_field";
            // the key to collapse on
            qs.collapsexpath = "$key";
            /* example end: cs-query-collapse */
        }
        


        [Test]
        public void searchCollectionFastIndexUpdatePartExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "searchCollectionFastIndexUpdatePartExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;

                try
                {
                    searchCollectionFastIndexEnqueue(collection, auth, s);
                    searchCollectionFastIndexUpdatePart(collection, auth, s);
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
        public void searchCollectionFastIndexEnqueueExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "searchCollectionFastIndexEnqueueExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;
                try
                {
                    searchCollectionFastIndexEnqueue(collection, auth, s);

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
        // per Stan: check 'state' for error (should be 'success'), specifics, check 'siphoned' and 'log' // ignore
        public void enqueueErrorHandlingExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "enqueueErrorHandlingExample";

            GetServers();
            foreach (string s in servers)
            {
                try
                {

                    Console.WriteLine("Test: {0} Server: {1}", collection, s);
                    service.Url = s;
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.authentication = auth;
                    // ... populate sce object ...
                    sce.collection = collection;
                    sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    crawlurl[] cus = new crawlurl[2];
                    sce.crawlurls.crawlurl = cus;

                    cus = new crawlurl[1];
                    sce.crawlurls.crawlurl = cus;
                    cus[0] = new crawlurl();
                    cus[0].url = "myproto://doc?id=2#field1";
                    cus[0].status = crawlurlStatus.complete;
                    cus[0].crawldata = new crawldata[1];
                    cus[0].crawldata[0] = new crawldata();
                    cus[0].crawldata[0].vxml = new crawldataVxml();
                    cus[0].crawldata[0].contenttype = "application/vxml";
                    document[] docs3 = new document[1];
                    cus[0].crawldata[0].vxml.document = docs3;
                    docs3[0] = new document();
                    docs3[0].vsekeynormalizedSpecified = true;
                    docs3[0].vsekey = "key-2";
                    docs3[0].content = new content[1];
                    docs3[0].content[0] = new content();
                    docs3[0].content[0].name = "field1";
                    docs3[0].content[0].Value = "My updated field 1";

                    /* example start: cs-enqueue-err-handling */
                    SearchCollectionEnqueueResponse scer = service.SearchCollectionEnqueue(sce);
                    if (scer != null && scer.crawlerserviceenqueueresponse.nfailedSpecified && scer.crawlerserviceenqueueresponse.nfailed > 0)
                    {
                        foreach (Object o in scer.crawlerserviceenqueueresponse.Items)
                        {
                            if (o is crawlurl)
                            {
                                crawlurl cu = (crawlurl)o;
                                if (cu.siphonedSpecified)
                                    System.Console.WriteLine(cu.url + " failed: " + cu.siphoned);
                            }
                            if (o is crawldelete)
                            {
                                crawldelete cd = (crawldelete)o;
                                if (cd.siphonedSpecified)
                                    System.Console.WriteLine(cd.url + " failed: " + cd.siphoned);
                            }
                        }
                    }
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                /* example end: cs-enqueue-err-handling */
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }


        [Test]
        public void searchCollectionUpdateSingleFieldExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "searchCollectionUpdateSingleFieldExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;
                try
                {
                    searchCollectionContentLevelUpdates(collection, auth, s);

                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection; ;
                    qs.query = "DOCUMENT_KEY:\"key-2\"";

                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null && qres.list.document.Length == 1, "Incorrect number of results returned.");

                    qs.query = qs.query + " My updated field 1";
                    qsr = service.QuerySearch(qs);
                    qres = qsr.queryresults;

                    Assert.IsTrue(qres.list == null, "Results should not have been returned.");

                    /* enqueue data */
                    SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                    sce.authentication = auth;
                    sce.collection = collection;
                    sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                    crawlurl[] cus = new crawlurl[2];
                    sce.crawlurls.crawlurl = cus;

                    /* updating just part */
                    /* example start: cs-update-field */
                    cus = new crawlurl[1];
                    sce.crawlurls.crawlurl = cus;
                    cus[0] = new crawlurl();
                    cus[0].url = "myproto://doc?id=2#field1";
                    cus[0].status = crawlurlStatus.complete;
                    cus[0].enqueuetype = crawlurlEnqueuetype.reenqueued;
                    cus[0].crawldata = new crawldata[1];
                    cus[0].crawldata[0] = new crawldata();
                    cus[0].crawldata[0].vxml = new crawldataVxml();
                    cus[0].crawldata[0].contenttype = "application/vxml";
                    document[] docs3 = new document[1];
                    cus[0].crawldata[0].vxml.document = docs3;
                    docs3[0] = new document();
                    docs3[0].vsekeynormalizedSpecified = true;
                    docs3[0].vsekey = "key-2";
                    docs3[0].content = new content[1];
                    docs3[0].content[0] = new content();
                    docs3[0].content[0].name = "field1";
                    docs3[0].content[0].Value = "My updated field 1";
                    SearchCollectionEnqueueResponse enqresp = service.SearchCollectionEnqueue(sce);
                    /* example end: cs-update-field */

                    Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                        "Enqueue failed.");

                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, 1, 3000, auth, s));


                    qs.sources = collection;

                    qsr = service.QuerySearch(qs);
                    qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null && qres.list.document.Length == 1, "Incorrect documents returned.");

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
        public void searchCollectionContentLevelUpdatesExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "searchCollectionContentLevelUpdatesExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;
                try
                {
                    searchCollectionContentLevelUpdates(collection, auth, s);
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
        public void searchCollectionDeleteUrlExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "searchCollectionDeleteUrlExample";

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                service.Url = s;
                try
                {
                    searchCollectionEnqueueUrl(collection, auth, s);
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "DOCUMENT:\"" + ENQ_URL + "\"";

                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qres = qsr.queryresults;

                    Assert.IsTrue(qres.list != null, "No results returned.");
                    Assert.IsTrue(qres.list.document[0].url.Equals(ENQ_URL),
                        "Correct result not returned.  Expected: {0} Actual: {1}", ENQ_URL, qres.list.document[0].url);

                    /* deleting */
                    /* example start: cs-delete-url */
                    SearchCollectionEnqueueDeletes sced = new SearchCollectionEnqueueDeletes();
                    sced.authentication = auth;
                    sced.collection = collection;
                    sced.crawldeletes = new SearchCollectionEnqueueDeletesCrawldeletes();
                    crawldelete[] cds = new crawldelete[1];
                    sced.crawldeletes.crawldelete = cds;
                    cds[0] = new crawldelete();
                    cds[0].url = ENQ_URL;
                    // cds[0].synchronization = crawldeleteSynchronization.indexed; // ignore
                    SearchCollectionEnqueueDeletesResponse delresp = service.SearchCollectionEnqueueDeletes(sced);
                    /* example end: cs-delete-url */

                    Assert.IsTrue(delresp.crawlerserviceenqueueresponse.nfailed == 0 || !delresp.crawlerserviceenqueueresponse.nfailedSpecified,
                        "Delete response incorrect.  Expected: 0 Actual: {0}", delresp.crawlerserviceenqueueresponse.nfailed);

                    Thread.Sleep(3000 * 2);

                    qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.sources = collection;
                    qs.query = "DOCUMENT:\"" + ENQ_URL + "\"";

                    qsr = service.QuerySearch(qs);
                    qres = qsr.queryresults;
                    int sleeptime = 500;
                    while (qres.list != null)
                    {
                        if (sleeptime > 0) Thread.Sleep(sleeptime);
                        if (sleeptime < 90000) sleeptime += 500;
                        qsr = service.QuerySearch(qs);
                        qres = qsr.queryresults;
                    }

                    Assert.IsTrue(qres.list == null, "Results returned.  Delete failed.");

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
        public void searchCollectionEnqueueUrlExample()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "searchCollectionEnqueueUrlExample";

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                Console.WriteLine("Test: {0} Server: {1}", collection, s);
                /* enqueue url */
                try
                {
                    if (!TestUtilities.isInRepo("vse-collection", collection, auth, s))
                    {
                        SearchCollectionCreate scc = new SearchCollectionCreate();
                        scc.authentication = auth;
                        scc.collection = collection;
                        scc.basedon = BASED_ON;
                        service.SearchCollectionCreate(scc);

                        Assert.IsTrue(TestUtilities.isInRepo("vse-collection", collection, auth, s), 
                            "Collection {0} not in repository.", collection);
                    }
                    else
                    {
                        TestUtilities.prepCollection(collection, null, true, true, true, true, false, 3, auth, s);
                    }
                    /* example start: cs-enq-url */
                    SearchCollectionEnqueueUrl sceu = new SearchCollectionEnqueueUrl();
                    sceu.authentication = auth;
                    sceu.collection = collection;
                    sceu.url = ENQ_URL;
                    sceu.forceallow = true;
                    SearchCollectionEnqueueUrlResponse enqresp = service.SearchCollectionEnqueueUrl(sceu);
                    /* example end: cs-enq-url */

                    Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                        "Enqueue failed.");

                    Assert.IsTrue(TestUtilities.ensureQueryable(collection, 1, 3000, auth, s), "Index not queryable.");
                    QuerySearch qs = new QuerySearch();
                    qs.authentication = auth;
                    qs.query = "DOCUMENT:\"" + ENQ_URL + "\"";
                    qs.sources = collection;

                    QuerySearchResponse qsr = service.QuerySearch(qs);
                    queryresults qr = qsr.queryresults;

                    Assert.IsTrue(qr.list != null, "No documents returned.");
                    Assert.IsTrue(qr.list.document[0].url.Equals(ENQ_URL),
                        "Wrong document returned. Expected: {0} Actual: {1}", ENQ_URL, qr.list.document[0].url);

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



        public static void searchCollectionContentLevelUpdates(string collection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();

            try
            {
                if (!TestUtilities.isInRepo("vse-collection", collection, auth, url))
                {
                    SearchCollectionCreate scc = new SearchCollectionCreate();
                    scc.authentication = auth;
                    scc.collection = collection;
                    service.SearchCollectionCreate(scc);

                    Assert.IsTrue(TestUtilities.isInRepo("vse-collection", collection, auth, url));
                }
                else
                {
                    TestUtilities.prepCollection(collection, null, true, true, true, true, false, 3, auth, url);
                }
                /* enqueue data */
                SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                sce.authentication = auth;
                sce.collection = collection;
                sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                crawlurl[] cus = new crawlurl[2];
                sce.crawlurls.crawlurl = cus;


                /* content level updates */
                /* example start: cs-content-lev-updates */
                cus = new crawlurl[2];
                sce.crawlurls.crawlurl = cus;
                /* first content */
                cus[0] = new crawlurl();
                cus[0].url = "myproto://doc?id=2#field1";
                cus[0].status = crawlurlStatus.complete;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].vxml = new crawldataVxml();
                cus[0].crawldata[0].contenttype = "application/vxml";
                document[] docs1 = new document[1];
                cus[0].crawldata[0].vxml.document = docs1;
                docs1[0] = new document();
                docs1[0].vsekeynormalizedSpecified = true;
                docs1[0].vsekey = "key-2";
                docs1[0].content = new content[1];
                docs1[0].content[0] = new content();
                docs1[0].content[0].name = "field1";
                docs1[0].content[0].Value = "My field 1";
                /* second content */
                cus[1] = new crawlurl();
                cus[1].url = "myproto://doc?id=2#field2";
                cus[1].status = crawlurlStatus.complete;
                cus[1].crawldata = new crawldata[1];
                cus[1].crawldata[0] = new crawldata();
                cus[1].crawldata[0].vxml = new crawldataVxml();
                cus[1].crawldata[0].contenttype = "application/vxml";
                document[] docs2 = new document[1];
                cus[1].crawldata[0].vxml.document = docs2;
                docs2[0] = new document();
                docs2[0].vsekeynormalizedSpecified = true;
                docs2[0].vsekey = "key-2";
                docs2[0].content = new content[1];
                docs2[0].content[0] = new content();
                docs2[0].content[0].name = "field2";
                docs2[0].content[0].Value = "My field 2";
                SearchCollectionEnqueueResponse enqresp = service.SearchCollectionEnqueue(sce);
                /* example end: cs-content-lev-updates */

                Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                    "Enqueue failed.");

                Assert.IsTrue(TestUtilities.ensureQueryable(collection, 1, 3000, auth, url), "Collection not queryable.");


                QuerySearch qs = new QuerySearch();
                qs.authentication = auth;
                qs.sources = collection;
                qs.query = "DOCUMENT_KEY:\"key-2\" My field 1 My field 2";

                QuerySearchResponse qsr = service.QuerySearch(qs);
                queryresults qres = qsr.queryresults;

                Assert.IsTrue(qres.list != null && qres.list.document.Length == 1,
                    "Expected document not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        
        }

        public void searchCollectionFastIndexEnqueue(string collection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();

            try
            {
                if (!TestUtilities.isInRepo("vse-collection", collection, auth, url))
                {
                    SearchCollectionCreate scc = new SearchCollectionCreate();
                    scc.authentication = auth;
                    scc.collection = collection;
                    scc.basedon = BASED_ON;
                    service.SearchCollectionCreate(scc);

                    Assert.IsTrue(TestUtilities.isInRepo("vse-collection", collection, auth, url));
                }
                else
                {
                    TestUtilities.prepCollection(collection, null, true, true, true, true, false, 3, auth, url);
                }

                /* 7.1 content level updates w/ fastindex */
                /* content level updates */
                SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                sce.authentication = auth;
                sce.collection = collection;

                /* example start: cs-fi-enq */
                crawlurl[] cus = new crawlurl[2];
                sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                sce.crawlurls.crawlurl = cus;
                /* first content */
                cus[0] = new crawlurl();
                cus[0].url = "myproto://doc2?id=3#field1";
                cus[0].enqueuetype = crawlurlEnqueuetype.reenqueued;
                cus[0].status = crawlurlStatus.complete;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].vxml = new crawldataVxml();
                cus[0].crawldata[0].contenttype = "application/vxml";
                document[] docs1 = new document[1];
                cus[0].crawldata[0].vxml.document = docs1;
                docs1[0] = new document();
                docs1[0].vsekeynormalizedSpecified = true;
                docs1[0].vsekey = "key-3";
                docs1[0].content = new content[1];
                docs1[0].content[0] = new content();
                docs1[0].content[0].name = "field1";
                docs1[0].content[0].Value = "My field 1";
                docs1[0].content[0].fastindex = fastindextype.set;
                docs1[0].content[0].fastindexSpecified = true;

                /* second content */
                cus[1] = new crawlurl();
                cus[1].url = "myproto://doc2?id=3#field2";
                cus[1].enqueuetype = crawlurlEnqueuetype.reenqueued;
                cus[1].status = crawlurlStatus.complete;
                cus[1].crawldata = new crawldata[1];
                cus[1].crawldata[0] = new crawldata();
                cus[1].crawldata[0].vxml = new crawldataVxml();
                cus[1].crawldata[0].contenttype = "application/vxml";
                document[] docs2 = new document[1];
                cus[1].crawldata[0].vxml.document = docs2;
                docs2[0] = new document();
                docs2[0].vsekeynormalizedSpecified = true;
                docs2[0].vsekey = "key-3";
                docs2[0].content = new content[1];
                docs2[0].content[0] = new content();
                docs2[0].content[0].name = "field2";
                docs2[0].content[0].Value = "12345";
                docs2[0].content[0].fastindex = fastindextype.@int;
                docs2[0].content[0].fastindexSpecified = true;
                SearchCollectionEnqueueResponse enqresp = service.SearchCollectionEnqueue(sce);
                /* example end: cs-fi-enq */

                Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                    "Enqueue failed.");

                Assert.IsTrue(TestUtilities.ensureQueryable(collection, 1, 3000, auth, url));

                QuerySearch qs = new QuerySearch();
                qs.authentication = auth;
                qs.sources = collection;
                qs.queryconditionxpath = "$field2=12345 and $field1='My field 1'";

                QuerySearchResponse qsr = service.QuerySearch(qs);
                queryresults qres = qsr.queryresults;

                Assert.IsTrue(qres.list != null && qres.list.document.Length == 1,
                    "Correct document not returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
                throw (se);
            }
        }

        public void searchCollectionFastIndexUpdatePart(string collection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();

            service.Url = url;

            try
            {
                searchCollectionFastIndexEnqueue(collection, auth, url);
                QuerySearch qs = new QuerySearch();
                qs.authentication = auth;
                qs.sources = collection;
                qs.queryconditionxpath = "$field2=12345";
                // ignore "$field1=='My Field 1' and 

                QuerySearchResponse qsr = service.QuerySearch(qs);
                queryresults qres = qsr.queryresults;

                Assert.IsTrue(qres.list != null && qres.list.document.Length == 1, "No results returned.");

                SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                sce.authentication = auth;
                sce.collection = collection;
                sce.crawlurls = new SearchCollectionEnqueueCrawlurls();

                crawlurl[] cus = new crawlurl[2];
                sce.crawlurls.crawlurl = cus;

                /* updating just part - change type of fastindex */
                /* example start: cs-fi-update-part */
                cus = new crawlurl[1];
                sce.crawlurls.crawlurl = cus;
                cus[0] = new crawlurl();
                cus[0].enqueuetype = crawlurlEnqueuetype.reenqueued;
                cus[0].url = "myproto://doc2?id=3#field2";
                cus[0].status = crawlurlStatus.complete;
                cus[0].enqueuetype = crawlurlEnqueuetype.reenqueued;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].vxml = new crawldataVxml();
                cus[0].crawldata[0].contenttype = "application/vxml";
                document[] docs3 = new document[1];
                cus[0].crawldata[0].vxml.document = docs3;
                docs3[0] = new document();
                docs3[0].vsekeynormalizedSpecified = true;
                docs3[0].vsekey = "key-3";
                docs3[0].content = new content[1];
                docs3[0].content[0] = new content();
                docs3[0].content[0].name = "field2";
                docs3[0].content[0].Value = DateTime.Now.ToString("d");
                docs3[0].content[0].fastindex = fastindextype.date;
                docs3[0].content[0].fastindexSpecified = true;
                SearchCollectionEnqueueResponse enqresp = service.SearchCollectionEnqueue(sce);
                /* example end: cs-fi-update-part */

                Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                    "Enqueue failed.");
                Assert.IsTrue(TestUtilities.ensureQueryable(collection, 1, 3000, auth, url));


                qs.sources = collection;
                qs.queryconditionxpath = "$field2!=12345";
                // ignore "$field1=='My Field 1' and 

                qsr = service.QuerySearch(qs);
                qres = qsr.queryresults;

                Assert.IsTrue(qres.list != null && qres.list.document.Length == 1, "Incorrect result set returned.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }

        }

        public static void searchCollectionEnqueueUrl(string collection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            service.Url = url;
            /* enqueue url */
            try
            {
                if (!TestUtilities.isInRepo("vse-collection", collection, auth, url))
                {
                    SearchCollectionCreate scc = new SearchCollectionCreate();
                    scc.authentication = auth;
                    scc.collection = collection;
                    service.SearchCollectionCreate(scc);

                    Assert.IsTrue(TestUtilities.isInRepo("vse-collection", collection, auth, url));
                }
                else
                {
                    TestUtilities.prepCollection(collection, null, true, true, true, true, false, 3, auth, url);
                }
                /* example start: cs-enq-url */
                SearchCollectionEnqueueUrl sceu = new SearchCollectionEnqueueUrl();
                sceu.authentication = auth;
                sceu.collection = collection;
                sceu.url = ENQ_URL;
                sceu.forceallow = true;
                SearchCollectionEnqueueUrlResponse enqresp = service.SearchCollectionEnqueueUrl(sceu);
                /* example end: cs-enq-url */

                Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified);

                Assert.IsTrue(TestUtilities.ensureQueryable(collection, 1, 3000, auth, url));
                QuerySearch qs = new QuerySearch();
                qs.authentication = auth;
                qs.query = "DOCUMENT:\"" + ENQ_URL + "\"";
                qs.sources = collection;

                QuerySearchResponse qsr = service.QuerySearch(qs);
                queryresults qr = qsr.queryresults;

                Assert.IsTrue(qr.list != null, "No documents returned.");
                Assert.IsTrue(qr.list.document[0].url.Equals(ENQ_URL), "Incorrect document returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        public static void searchCollectionEnqueue(string collection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();

            /* enqueue data */
            try
            {
                if (!TestUtilities.isInRepo("vse-collection", collection, auth, url))
                {
                    SearchCollectionCreate scc = new SearchCollectionCreate();
                    scc.authentication = auth;
                    scc.collection = collection;
                    service.SearchCollectionCreate(scc);

                    Assert.IsTrue(TestUtilities.isInRepo("vse-collection", collection, auth, url));
                }
                else
                {
                    TestUtilities.prepCollection(collection, null, true, true, true, true, false, 3, auth, url);
                }

                /* example start: cs-enq-data-1 */
                SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                sce.authentication = auth;
                sce.collection = collection;
                sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                crawlurl[] cus = new crawlurl[2];
                sce.crawlurls.crawlurl = cus;
                /* example end: cs-enq-data-1 */

                /* example start: cs-enq-data-2 */
                // this first url will be fetched by the crawler since we're not specifying status="complete"
                cus[0] = new crawlurl();
                cus[0].url = ENQ_URL;
                /* example end: cs-enq-data-2 */

                /* example start: cs-enq-data-3 */
                // the next url contains textual data, vxml data, and raw base64 data - all of which is provided
                // completely at enqueue time and will no be fetched by the crawler due to the url's status being
                // complete
                /* textual content */
                String MY_CRAWL_URL = "myproto://doc?id=1";
                cus[1] = new crawlurl();
                cus[1].url = MY_CRAWL_URL;
                cus[1].status = crawlurlStatus.complete;
                cus[1].crawldata = new crawldata[3];
                cus[1].crawldata[0] = new crawldata();
                cus[1].crawldata[0].contenttype = "text/html";
                cus[1].crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";

                /* fielded content */
                cus[1].crawldata[1] = new crawldata();
                cus[1].crawldata[1].contenttype = "application/vxml";
                cus[1].crawldata[1].vxml = new crawldataVxml();
                document[] doc = new document[1];
                cus[1].crawldata[1].vxml.document = doc;
                doc[0] = new document();
                doc[0].content = new content[2];
                doc[0].content[0] = new content();
                doc[0].content[0].name = "field1";
                doc[0].content[0].Value = "My first field";
                doc[0].content[1] = new content();
                doc[0].content[1].name = "field2";
                doc[0].content[1].Value = "My second field";

                /* base64 */
                cus[1].crawldata[2] = new crawldata();
                byte[] binarydata = new byte[4] { 98, 97, 100, 0 };
                cus[1].crawldata[2].base64 = System.Convert.ToBase64String(binarydata);
                cus[1].crawldata[2].contenttype = "text/plain";
                SearchCollectionEnqueueResponse enqresp = service.SearchCollectionEnqueue(sce);
                /* example end: cs-enq-data-3 */

                Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified);
                Assert.IsTrue(TestUtilities.ensureQueryable(collection, 2, 3000, auth, url));

                QuerySearch qs = new QuerySearch();
                qs.authentication = auth;
                qs.sources = collection;
                qs.query = "DOCUMENT:\"" + ENQ_URL + "\"";

                QuerySearchResponse qsr = service.QuerySearch(qs);
                queryresults qres = qsr.queryresults;

                Assert.IsTrue(qres.list != null, "No results.");
                Assert.IsTrue(qres.list.document[0].url == ENQ_URL, "Wrong document returned.");

                qs.query = "DOCUMENT:\"" + MY_CRAWL_URL + "\"";
                qsr = service.QuerySearch(qs);
                qres = qsr.queryresults;

                Assert.IsTrue(qres.list != null, "No results returned.");
                Assert.IsTrue(qres.list.document[0].url == MY_CRAWL_URL, "Document not returned.");

                qs.query = "(My HTML page) AND (CONTENT field1) AND (bad))";
                qsr = service.QuerySearch(qs);
                qres = qsr.queryresults;

                Assert.IsTrue(qres.list != null, "No results returned.");
                Assert.IsTrue(qres.list.document.Length == 1, "Incorrect number of results returned.");


            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }

        }

        public void collectionBrokerEnqueueXml(string collection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();

            try
            {
                if (!TestUtilities.isInRepo("vse-collection", collection, auth, url))
                {
                    TestUtilities.CreateSearchCollection(collection, auth, url);

                    Assert.IsTrue(TestUtilities.isInRepo("vse-collection", collection, auth, url), 
                        "Collection: {0}: not in repository", collection);
                }
                else
                {
                    TestUtilities.prepCollection(collection, null, true, true, true, true, false, 3, auth, url);
                }


                /* example start: cs-cb-enqueue-xml */
                CollectionBrokerEnqueueXml enqueue = new CollectionBrokerEnqueueXml();
                enqueue.authentication = auth;

                enqueue.collection = collection;
                enqueue.crawlnodes = new CollectionBrokerEnqueueXmlCrawlnodes();
                enqueue.crawlnodes.crawlurls = new crawlurls();
                enqueue.crawlnodes.crawlurls.synchronization = crawlurlsSynchronization.indexednosync;
                crawlurl[] cus = new crawlurl[2];
                enqueue.crawlnodes.crawlurls.crawlurl = cus;
                cus[0] = new crawlurl();
                cus[0].url = ENQ_URL;

                String MY_CRAWL_URL = "myproto://doc?id=1";
                cus[1] = new crawlurl();
                cus[1].url = MY_CRAWL_URL;
                cus[1].crawldata = new crawldata[3];
                cus[1].crawldata[0] = new crawldata();
                cus[1].crawldata[0].contenttype = "text/html";
                cus[1].crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";

                cus[1].crawldata[1] = new crawldata();
                cus[1].crawldata[1].contenttype = "application/vxml";
                cus[1].crawldata[1].vxml = new crawldataVxml();
                document[] doc = new document[1];
                cus[1].crawldata[1].vxml.document = doc;
                doc[0] = new document();
                doc[0].content = new content[2];
                doc[0].content[0] = new content();
                doc[0].content[0].name = "field1";
                doc[0].content[0].Value = "My first field";
                doc[0].content[1] = new content();
                doc[0].content[1].name = "field2";
                doc[0].content[1].Value = "My second field";

                // everything is identical except
                CollectionBrokerEnqueueXmlResponse enqueueresp = service.CollectionBrokerEnqueueXml(enqueue);
                Assert.IsTrue(enqueueresp.collectionbrokerenqueueresponse != null, "No enqueue response returned.");
                collectionbrokerenqueueresponse enqresp = enqueueresp.collectionbrokerenqueueresponse;

                // contains logging information
                log l = enqresp.log;
                // was the collection already online?
                Boolean online = enqresp.online;
                // what was the overall status of the request?
                collectionbrokerenqueueresponseStatus status = enqresp.status;
                if (status == collectionbrokerenqueueresponseStatus.error)
                {
                    Assert.Fail("Collection broker Enqueue status was error.");
                }
                if (status == collectionbrokerenqueueresponseStatus.success)
                {
                }
                /* example end: cs-cb-enqueue-xml */

                Thread.Sleep(3000);

                Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                    "Enqueue failed.");
                Assert.IsTrue(TestUtilities.ensureQueryable(collection, 2, 10000, auth, url), 
                    "Index not queryable for collection: {0}", collection);

                QuerySearch qs = new QuerySearch();
                qs.authentication = auth;
                qs.sources = collection;
                qs.query = "DOCUMENT:\"" + ENQ_URL + "\"";

                QuerySearchResponse qsr = service.QuerySearch(qs);
                queryresults qres = qsr.queryresults;

                Assert.IsTrue(qres.list != null, "No results returned.");
                Assert.IsTrue(qres.list.document[0].url == ENQ_URL, 
                    "Expected result {0} not returned.  Result returned: {1}", ENQ_URL, qres.list.document[0].url);

                qs.query = "DOCUMENT:\"" + MY_CRAWL_URL + "\"";
                qsr = service.QuerySearch(qs);
                qres = qsr.queryresults;

                Assert.IsTrue(qres.list != null, "No results returned.");
                Assert.IsTrue(qres.list.document[0].url == MY_CRAWL_URL,
                    "Expected result {0} not returned.  Result returned: {1}", MY_CRAWL_URL, qres.list.document[0].url);
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }

        }

        public void multiAttachment(string collection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            service.Url = url;
            try
            {
                if (!TestUtilities.isInRepo("vse-collection", collection, auth, url))
                {
                    TestUtilities.CreateSearchCollection(collection, auth, url);
                    Assert.IsTrue(TestUtilities.isInRepo("vse-collection", collection, auth, url));
                }
                else
                {
                    TestUtilities.prepCollection(collection, null, true, true, true, true, false, 3, auth, url);
                }

                /* example start: cs-multi-attach */
                SearchCollectionEnqueue sce = new SearchCollectionEnqueue();
                sce.authentication = auth;
                sce.crawlurls = new SearchCollectionEnqueueCrawlurls();
                sce.collection = collection;
                crawlurl[] cus = new crawlurl[1];
                sce.crawlurls.crawlurl = cus;

                /* main document */
                cus[0] = new crawlurl();
                cus[0].url = "myproto://doc?id=2";
                cus[0].status = crawlurlStatus.complete;
                cus[0].enqueuetype = crawlurlEnqueuetype.reenqueued;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].text = "some main document text";
                cus[0].forcedvsekey = "key-2";
                cus[0].forcedvsekeynormalizedSpecified = true;

                SearchCollectionEnqueueResponse enqresp = service.SearchCollectionEnqueue(sce);
                Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                    "Enqueue failed."); // ignore

                /* first attachment */
                cus = new crawlurl[1];
                sce.crawlurls.crawlurl = cus;
                cus[0] = new crawlurl();
                cus[0].url = "myproto://doc?id=2#attachment1";
                cus[0].status = crawlurlStatus.complete;
                cus[0].enqueuetype = crawlurlEnqueuetype.reenqueued;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].text = "first attach";
                cus[0].forcedvsekey = "key-2";
                cus[0].forcedvsekeynormalizedSpecified = true;

                enqresp = service.SearchCollectionEnqueue(sce);
                Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                    "Enqueue failed."); // ignore

                /* second attachment */
                cus = new crawlurl[1];
                sce.crawlurls.crawlurl = cus;
                cus[0] = new crawlurl();
                cus[0].url = "myproto://doc?id=2#attachment2";
                cus[0].status = crawlurlStatus.complete;
                cus[0].enqueuetype = crawlurlEnqueuetype.reenqueued;
                cus[0].crawldata = new crawldata[1];
                cus[0].crawldata[0] = new crawldata();
                cus[0].crawldata[0].text = "2nd attach";
                cus[0].forcedvsekey = "key-2";
                cus[0].forcedvsekeynormalizedSpecified = true;
                enqresp = service.SearchCollectionEnqueue(sce);
                /* example end: cs-multi-attach */

                Assert.IsTrue(enqresp.crawlerserviceenqueueresponse.nfailed == 0 || !enqresp.crawlerserviceenqueueresponse.nfailedSpecified,
                    "Enqueue failed.");

                Assert.IsTrue(TestUtilities.ensureQueryable(collection, 1, 5000, auth, url));

                QuerySearch qs = new QuerySearch();
                qs.authentication = auth;
                qs.sources = collection;
                qs.query = "\"some main document text\" \"2nd attach\" \"first attach\"";

                QuerySearchResponse qsr = service.QuerySearch(qs);
                queryresults qres = qsr.queryresults;

                Assert.IsTrue(qres.list != null && qres.list.document.Length == 1, "Document not returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
                throw (se);
            }
        }


        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

    }
}
