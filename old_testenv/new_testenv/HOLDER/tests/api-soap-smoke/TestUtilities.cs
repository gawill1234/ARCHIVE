using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web.Services.Protocols;
using System.Xml;
using NUnit.Framework;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Threading;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters;

namespace api_soap_smoke
{
    class TestUtilities
    {
        const long MAXTIME = 5000;
        const int NUMDOCS = 1;
        const string ENQ_URL = "http://vivisimo.com/";

        public static string GetQueryBrowseFile(QuerySearch browse, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            service.Url = url;
            QuerySearchResponse response = new QuerySearchResponse();

            try
            {
                browse.browse = true;
                response = service.QuerySearch(browse);
            }
            catch (SoapException se)
            {
                HandleSoapException(se);
            }

            Assert.IsNotNull(response.queryresults, "No query results.");
            Assert.IsNotNull(response.queryresults.file, "No file returned.");
            return response.queryresults.file;
        }

        public static bool IsQueryServiceStarted(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            service.Url = url;

            SearchServiceStatusXml status = new SearchServiceStatusXml();
            XmlElement statusresponse;

            status.authentication = auth;
            statusresponse = service.SearchServiceStatusXml(status);
            if (statusresponse.InnerXml.Contains("service-status started"))
                return true;
            else
                return false;
        }

        /// <summary>
        /// Start the collection broker.  Wait for the status to show started.
        /// </summary>
        /// <param name="auth">Authentication</param>
        /// <param name="url">Service URL</param>
        public static void StartCollectionBrokerandWait(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            CollectionBrokerStart startbroker = new CollectionBrokerStart();
            CollectionBrokerStatus status = new CollectionBrokerStatus();
            CollectionBrokerStatusResponse statusresponse = new CollectionBrokerStatusResponse();

            service.Url = url;
            status.authentication = auth;

            // Start collection broker
            startbroker.authentication = auth;
            service.CollectionBrokerStart(startbroker);

            System.Threading.Thread.Sleep(1000);

            while (true)
            {
                // Get status
                System.Threading.Thread.Sleep(1000);
                statusresponse = service.CollectionBrokerStatus(status);
                Console.WriteLine("Broker status: {0}", statusresponse.collectionbrokerstatusresponse.status.ToString());
                if (statusresponse.collectionbrokerstatusresponse.status == collectionbrokerstatusresponseStatus.running)
                {
                    return;
                }
                System.Threading.Thread.Sleep(1000);
            }
        }

        /// <summary>
        /// Start the collection broker.  Wait for the status to show started.
        /// </summary>
        /// <param name="auth">Authentication</param>
        /// <param name="url">Service URL</param>
        public static void StopCollectionBrokerandWait(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            CollectionBrokerStop stopbroker = new CollectionBrokerStop();
            CollectionBrokerStatus status = new CollectionBrokerStatus();
            CollectionBrokerStatusResponse statusresponse = new CollectionBrokerStatusResponse();

            service.Url = url;
            status.authentication = auth;

            // Start collection broker
            stopbroker.authentication = auth;
            service.CollectionBrokerStop(stopbroker);

            System.Threading.Thread.Sleep(1000);

            while (true)
            {
                // Get status
                System.Threading.Thread.Sleep(1000);
                statusresponse = service.CollectionBrokerStatus(status);
                Console.WriteLine("Broker status: {0}", statusresponse.collectionbrokerstatusresponse.status.ToString());
                if (statusresponse.collectionbrokerstatusresponse.status == collectionbrokerstatusresponseStatus.stopped)
                    return;

                System.Threading.Thread.Sleep(1000);
            }
        }


        public static void StartQueryService(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchServiceStart start = new SearchServiceStart();
            SearchServiceStatusXml status = new SearchServiceStatusXml();
            XmlElement statusresponse;

            service.Url = url;

            start.authentication = auth;
            service.SearchServiceStart(start);

            status.authentication = auth;
            statusresponse = service.SearchServiceStatusXml(status);
            Assert.IsTrue(statusresponse.InnerXml.Contains("service-status started") == true, "Service Not Started.");

            return;

        }
        public static void StopQueryService(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchServiceStop stop = new SearchServiceStop();
            SearchServiceStatusXml status = new SearchServiceStatusXml();
            XmlElement statusresponse;

            service.Url = url;

            stop.authentication = auth;
            service.SearchServiceStop(stop);

            status.authentication = auth;
            statusresponse = service.SearchServiceStatusXml(status);
            Assert.IsTrue(statusresponse.GetAttribute("not-running") == "not-running");

            return;

        }

        public static void prepCollection(String collection, String subcollection, bool stopCrawler, bool stopIndexer, bool kill, bool clean, bool delete, int maxTries, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            service.Url = url;
            int pause = 2000;
            int factor = 2;


            if (subcollection == null || subcollection.Length == 0)
            {
                subcollection = "live";
            }
            SearchCollectionStatus stat = new SearchCollectionStatus();

            stat.collection = collection;
            stat.authentication = auth;

            SearchCollectionStatusResponse statresp = null;

            int tries = maxTries;
            while ((statresp = service.SearchCollectionStatus(stat)) != null && tries-- > 0)
            {
                if (stopCrawler && statresp.vsestatus.crawlerstatus != null)
                {
                    if (statresp.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.stopped)
                    {
                        SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();
                        stop.collection = collection;
                        stop.authentication = auth;
                        if (kill && tries - 1 == 0)
                            stop.kill = true;
                        if (!subcollection.Equals("live"))
                            stop.subcollection = SearchCollectionCrawlerStopSubcollection.staging;
                        service.SearchCollectionCrawlerStop(stop);

                        Thread.Sleep(pause * factor);
                    }
                }

                if (stopIndexer && statresp.vsestatus.vseindexstatus != null)
                {
                    if (statresp.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.stopped)
                    {
                        SearchCollectionIndexerStop stop = new SearchCollectionIndexerStop();
                        stop.collection = collection;
                        stop.authentication = auth;
                        if (kill && tries - 1 == 0)
                            stop.kill = true;
                        if (!subcollection.Equals("live"))
                            stop.subcollection = SearchCollectionIndexerStopSubcollection.staging;
                        service.SearchCollectionIndexerStop(stop);
                        Thread.Sleep(pause * factor);
                    }
                }
            }
            if (clean && ((statresp == null) || (statresp.vsestatus.crawlerstatus != null && statresp.vsestatus.crawlerstatus.servicestatus == crawlerstatusServicestatus.stopped) || (statresp.vsestatus.vseindexstatus != null && statresp.vsestatus.vseindexstatus.servicestatus == vseindexstatusServicestatus.stopped)))
            {
                SearchCollectionClean cleanc = new SearchCollectionClean();
                cleanc.collection = collection;
                cleanc.authentication = auth;
                service.SearchCollectionClean(cleanc);

            }

            if (delete && ((statresp == null) || (statresp.vsestatus.crawlerstatus != null && statresp.vsestatus.crawlerstatus.servicestatus == crawlerstatusServicestatus.stopped) || (statresp.vsestatus.vseindexstatus != null && statresp.vsestatus.vseindexstatus.servicestatus == vseindexstatusServicestatus.stopped)))
            {
                SearchCollectionDelete del = new SearchCollectionDelete();
                del.collection = collection;
                del.authentication = auth;
                service.SearchCollectionDelete(del);
                return;

            }

        }


        public static bool isInRepo(String node, String name, authentication auth, string url)
        {
            VelocityService service = new VelocityService();
            service.Url = url;
            try
            {
                RepositoryGet rget = new RepositoryGet();
                rget.element = node;
                rget.name = name;
                rget.authentication = auth;

                XmlElement e = service.RepositoryGet(rget);
                return true;
            }
            catch (SoapException se)
            {
                if (se.Message == "The exception [repository-unknown-node] was thrown.")
                {
                    return false;
                }
                else
                {
                    HandleSoapException(se);
                    return false;
                }

            }
        }

        public static string AddCollection(XmlElement Node, authentication auth, string s)
        {
            // variables
            VelocityService service = new VelocityService();
            string Add = null;
            RepositoryAdd AddCollection = new RepositoryAdd();

            // Add the collection
            service.Url = s;
            AddCollection.authentication = auth;
            AddCollection.node = Node;

            Add = service.RepositoryAdd(AddCollection);

            return Add;
        }

        public static XmlElement ReadXmlFile(string path)
        {
            XmlElement element;
            XmlDocument doc = new XmlDocument();

            doc.Load(path);
            element = doc.DocumentElement;
            return element;

        }
        public static void HandleSoapException(SoapException se)
        {
            Console.WriteLine("SoapException Details: " + se.Code);
            Console.WriteLine("SoapException Message: " + se.Message);
            Console.WriteLine("Additional Info: {0}", se.Detail.InnerXml.ToString());
            Assert.Fail("SoapException caught: " + se.Message);
            throw se;
        }

        public static void HandleNoAuth(SoapException se)
        {
            Console.WriteLine("SoapException Details: " + se.Code);
            Console.WriteLine("SoapException Message: " + se.Message);
            Assert.IsTrue(se.Code.ToString() == "urn:/velocity/objects:rights-execute",
                "The appropriate SoapException was not thrown.");
        }

        public static void HandleMissingVar(SoapException se)
        {
            Console.WriteLine("Exception thrown: {0}", se.Message);
            Console.WriteLine("AdditionalInfo: {0}", se.Detail.InnerXml);
            Assert.AreEqual("The exception [xml-resolve-missing-var-error] was thrown.", se.Message,
                "Incorrect exception thrown.");
        }

        public static void StopCrawlAndIndexStaging(string CollectionName, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();
            SearchCollectionIndexerStop stopIndex = new SearchCollectionIndexerStop();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();

            service.Url = url;

            stop.authentication = auth;
            stop.collection = CollectionName;
            stop.subcollection = SearchCollectionCrawlerStopSubcollection.staging;
            stopIndex.authentication = auth;
            stopIndex.collection = CollectionName;
            stopIndex.subcollection = SearchCollectionIndexerStopSubcollection.staging;
            status.authentication = auth;
            status.collection = CollectionName;
            status.subcollection = SearchCollectionStatusSubcollection.staging;

            try
            {
                if (isInRepo("vse-collection", CollectionName, auth, url))
                {
                    // Stop Crawler and Indexer
                    service.SearchCollectionCrawlerStop(stop);
                    System.Threading.Thread.Sleep(2000);
                    service.SearchCollectionIndexerStop(stopIndex);
                    System.Threading.Thread.Sleep(2000);
                    while (true)
                    {
                        Thread.Sleep(1000);
                        statusresponse = service.SearchCollectionStatus(status);
                        if (statusresponse == null)
                            return;
                        if (statusresponse.vsestatus.crawlerstatus == null && statusresponse.vsestatus.vseindexstatus == null)
                            return;
                        if (statusresponse.vsestatus.crawlerstatus == null)
                        {
                            if (statusresponse.vsestatus.vseindexstatus.idletime > 0 ||
                                statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                                return;
                        }
                        else
                        {
                            if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                                statusresponse.vsestatus.vseindexstatus.idletime > 0)
                                return;
                            if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                                statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                                return;
                        }
                        service.SearchCollectionCrawlerStop(stop);
                        service.SearchCollectionIndexerStop(stopIndex);
                    }

                }
            }
            catch (SoapException se)
            {
                HandleSoapException(se);
            }
        }

        public static void StopCrawlAndIndex(string CollectionName, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();
            SearchCollectionIndexerStop stopIndex = new SearchCollectionIndexerStop();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();

            service.Url = url;

            stop.authentication = auth;
            stop.collection = CollectionName;
            stopIndex.authentication = auth;
            stopIndex.collection = CollectionName;
            status.authentication = auth;
            status.collection = CollectionName;

            try
            {
                // Make sure collection exists
                if (isInRepo("vse-collection", CollectionName, auth, url))
                {// Stop Crawler and Indexer
                    service.SearchCollectionCrawlerStop(stop);
                    System.Threading.Thread.Sleep(1000);
                    service.SearchCollectionIndexerStop(stopIndex);
                    System.Threading.Thread.Sleep(1000);

                    while (true)
                    {
                        Thread.Sleep(1000);
                        statusresponse = service.SearchCollectionStatus(status);
                        if (statusresponse == null)
                            return;
                        if (statusresponse.vsestatus.crawlerstatus == null && statusresponse.vsestatus.vseindexstatus == null)
                            return;
                        if (statusresponse.vsestatus.crawlerstatus == null)
                        {
                            if (statusresponse.vsestatus.vseindexstatus.idletime > 0 ||
                                statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                                return;
                        }
                        else
                        {
                            if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                                statusresponse.vsestatus.vseindexstatus.idletime > 0)
                                return;
                            if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                                statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                                return;
                        }
                        service.SearchCollectionCrawlerStop(stop);
                        service.SearchCollectionIndexerStop(stopIndex);
                    }
                }
                // wait to return for services to be stopped

            }
            catch (SoapException se)
            {
                HandleSoapException(se);
            }
        }

        public static void StopCrawl(string CollectionName, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionCrawlerStop stop = new SearchCollectionCrawlerStop();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();

            service.Url = url;

            stop.authentication = auth;
            stop.collection = CollectionName;
            status.authentication = auth;
            status.collection = CollectionName;

            try
            {
                // Make sure collection exists
                if (isInRepo("vse-collection", CollectionName, auth, url))
                {// Stop Crawler and Indexer
                    service.SearchCollectionCrawlerStop(stop);
                    System.Threading.Thread.Sleep(1000);

                    while (true)
                    {
                        Thread.Sleep(1000);
                        statusresponse = service.SearchCollectionStatus(status);
                        if (statusresponse == null)
                            return;
                        if (statusresponse.vsestatus.crawlerstatus == null)
                            return;
                        if (statusresponse.vsestatus.crawlerstatus == null)
                        {
                            return;
                        }
                        else
                        {
                            if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running)
                                return;
                            if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running)
                                return;
                        }
                        service.SearchCollectionCrawlerStop(stop);
                    }
                }
                // wait to return for services to be stopped

            }
            catch (SoapException se)
            {
                HandleSoapException(se);
            }
        }

        /// <summary>
        /// Create a SearchCollection based on the default.
        /// </summary>
        /// <param name="SearchCollection">Name of the collection</param>
        /// <param name="auth">Authentication</param>
        /// <param name="url">Service URL</param>
        public static void CreateSearchCollection(string CollectionName, authentication auth, string url)
        {
            VelocityService service = new VelocityService();
            service.Url = url;

            // Configure search collection
            SearchCollectionCreate sc = new SearchCollectionCreate();
            sc.authentication = auth;
            sc.collection = CollectionName;
            SearchCollectionListXml list = new SearchCollectionListXml();
            list.authentication = auth;
            XmlElement results;

            try
            {
                if (!isInRepo("vse-collection", CollectionName, auth, url))
                {
                    service.SearchCollectionCreate(sc);
                }
                else
                {
                    DeleteSearchCollection(CollectionName, auth, url);
                    CreateSearchCollection(CollectionName, auth, url);
                }
            }
            catch (SoapException se)
            {
                HandleSoapException(se);
            }

            // Verify created collection exists
            try
            {
                results = service.SearchCollectionListXml(list);
                Assert.IsTrue(results.InnerXml.ToString().Contains(CollectionName) == true,
                    "Search Collection create failed " + CollectionName);

            }
            catch (SoapException se)
            {
                HandleSoapException(se);
            }
        }


        public static void DeleteSearchCollection(string CollectionName, authentication auth, string url)
        {
            VelocityService service = new VelocityService();
            service.Url = url;

            // Configure search collection
            SearchCollectionDelete sd = new SearchCollectionDelete();
            sd.authentication = auth;
            sd.collection = CollectionName;
            sd.killservices = true;

            SearchCollectionListXml list = new SearchCollectionListXml();
            XmlElement results;
            SearchCollectionIndexerStop stopIndex = new SearchCollectionIndexerStop();

            //Make sure services are stopped
            StopCollectionBrokerandWait(auth, url);
            
            try
            {
                if (isInRepo("vse-collection", CollectionName, auth, url))
                {
                    service.SearchCollectionDelete(sd);
                }
                list.authentication = auth;
                results = service.SearchCollectionListXml(list);
                Assert.IsTrue(results.InnerXml.ToString().Contains(CollectionName) == false,
                    "Search Collection delete failed: " + CollectionName);

            }

            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        /// <summary>
        /// Start a crawl on an existing search collection.  Wait for the status
        /// to show idle.
        /// </summary>
        /// <param name="SearchCollection">Name of the collection</param>
        /// <param name="auth">Authentication</param>
        /// <param name="url">Service URL</param>
        public static void StartCrawlandWait(string SearchCollection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionCrawlerStart startcrawler = new SearchCollectionCrawlerStart();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();

            // Make sure Query Service is started
            StartQueryService(auth, url);

            service.Url = url;
            status.authentication = auth;
            status.collection = SearchCollection;

            // Start Crawler
            startcrawler.authentication = auth;
            startcrawler.collection = SearchCollection;

            service.SearchCollectionCrawlerStart(startcrawler);

            System.Threading.Thread.Sleep(4000);

            while (true)
            {
                // Get status
                System.Threading.Thread.Sleep(1000);
                statusresponse = service.SearchCollectionStatus(status);
                Console.WriteLine("Crawl status: {0}", statusresponse.vsestatus.crawlerstatus.servicestatus.ToString());
                Console.WriteLine("Index status: {0}", statusresponse.vsestatus.vseindexstatus.servicestatus.ToString());
                if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                    statusresponse.vsestatus.vseindexstatus.idletime > 0)
                    return;
                if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                    statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                    return;

                System.Threading.Thread.Sleep(1000);
            }
        }

        /// <summary>
        /// Start a crawl on an existing search collection.  Wait for the status
        /// to show idle.
        /// </summary>
        /// <param name="SearchCollection">Name of the collection</param>
        /// <param name="auth">Authentication</param>
        /// <param name="url">Service URL</param>
        public static void StartCrawlandWaitStaging(string SearchCollection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionCrawlerStart startcrawler = new SearchCollectionCrawlerStart();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();

            // Make sure Query Service is started
            StartQueryService(auth, url);

            service.Url = url;
            status.authentication = auth;
            status.collection = SearchCollection;
            status.subcollection = SearchCollectionStatusSubcollection.staging;

            // Start Crawler
            startcrawler.authentication = auth;
            startcrawler.collection = SearchCollection;
            startcrawler.subcollection = SearchCollectionCrawlerStartSubcollection.staging;

            service.SearchCollectionCrawlerStart(startcrawler);

            System.Threading.Thread.Sleep(4000);

            while (true)
            {
                // Get status
                System.Threading.Thread.Sleep(1000);
                statusresponse = service.SearchCollectionStatus(status);
                if (statusresponse == null)
                    return;
                if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                    statusresponse.vsestatus.vseindexstatus.idletime > 0)
                    return;
                if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                    statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                    return;
                Console.WriteLine("Crawl status: {0}", statusresponse.vsestatus.crawlerstatus.servicestatus.ToString());
                Console.WriteLine("Index status: {0}", statusresponse.vsestatus.vseindexstatus.servicestatus.ToString());

                System.Threading.Thread.Sleep(1000);
            }
        }

        public static void WaitIdleStaging(string collection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();

            service.Url = url;
            status.authentication = auth;
            status.collection = collection;
            status.subcollection = SearchCollectionStatusSubcollection.staging;

            System.Threading.Thread.Sleep(4000);

            while (true)
            {
                // Get status
                System.Threading.Thread.Sleep(1000);
                statusresponse = service.SearchCollectionStatus(status);
                if (statusresponse == null)
                    return;
                if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                    statusresponse.vsestatus.vseindexstatus.idletime > 0)
                    return;
                if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                    statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                    return;
                Console.WriteLine("Crawl status: {0}", statusresponse.vsestatus.crawlerstatus.servicestatus.ToString());
                Console.WriteLine("Index status: {0}", statusresponse.vsestatus.vseindexstatus.servicestatus.ToString());

                System.Threading.Thread.Sleep(1000);
            }
        }


        public static void WaitIdle(string collection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();

            service.Url = url;
            status.authentication = auth;
            status.collection = collection;
            status.subcollection = SearchCollectionStatusSubcollection.live;

            System.Threading.Thread.Sleep(4000);

            while (true)
            {
                // Get status
                System.Threading.Thread.Sleep(1000);
                statusresponse = service.SearchCollectionStatus(status);
                if (statusresponse == null)
                    return;
                if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                    statusresponse.vsestatus.vseindexstatus.idletime > 0)
                    return;
                if (statusresponse.vsestatus.crawlerstatus.servicestatus != crawlerstatusServicestatus.running &&
                    statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                    return;
                Console.WriteLine("Crawl status: {0}", statusresponse.vsestatus.crawlerstatus.servicestatus.ToString());
                Console.WriteLine("Index status: {0}", statusresponse.vsestatus.vseindexstatus.servicestatus.ToString());

                System.Threading.Thread.Sleep(1000);
            }
        }


        /// <summary>
        /// Start the indexer on an existing search collection.  Wait for the status
        /// to show idle.
        /// </summary>
        /// <param name="SearchCollection">Name of the collection</param>
        /// <param name="auth">Authentication</param>
        /// <param name="url">Service URL</param>
        public static void StartIndexerandWait(string SearchCollection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionIndexerStart startindexer = new SearchCollectionIndexerStart();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();

            // Make sure Query Service is started
            StartQueryService(auth, url);

            service.Url = url;
            status.authentication = auth;
            status.collection = SearchCollection;

            // Start Indexer
            startindexer.authentication = auth;
            startindexer.collection = SearchCollection;
            service.SearchCollectionIndexerStart(startindexer);

            System.Threading.Thread.Sleep(4000);

            while (true)
            {
                // Get status
                System.Threading.Thread.Sleep(1000);
                statusresponse = service.SearchCollectionStatus(status);
                Console.WriteLine("Index status: {0}", statusresponse.vsestatus.vseindexstatus.servicestatus.ToString());
                if (statusresponse.vsestatus.vseindexstatus.idletime > 0)
                    return;
                if (statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                    return;

                System.Threading.Thread.Sleep(1000);
            }
        }


        /// <summary>
        /// Start the indexer on an existing search collection.  Wait for the status
        /// to show idle.
        /// </summary>
        /// <param name="SearchCollection">Name of the collection</param>
        /// <param name="auth">Authentication</param>
        /// <param name="url">Service URL</param>
        public static void StartIndexerandWaitStaging(string SearchCollection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionIndexerStart startindexer = new SearchCollectionIndexerStart();
            SearchCollectionStatus status = new SearchCollectionStatus();
            SearchCollectionStatusResponse statusresponse = new SearchCollectionStatusResponse();

            // Make sure Query Service is started
            StartQueryService(auth, url);

            service.Url = url;
            status.authentication = auth;
            status.collection = SearchCollection;
            status.subcollection = SearchCollectionStatusSubcollection.staging;

            // Start Indexer
            startindexer.authentication = auth;
            startindexer.collection = SearchCollection;
            startindexer.subcollection = SearchCollectionIndexerStartSubcollection.staging;
            service.SearchCollectionIndexerStart(startindexer);

            System.Threading.Thread.Sleep(4000);

            while (true)
            {
                // Get status
                System.Threading.Thread.Sleep(1000);
                statusresponse = service.SearchCollectionStatus(status);
                Console.WriteLine("Index status: {0}", statusresponse.vsestatus.vseindexstatus.servicestatus.ToString());
                if (statusresponse.vsestatus.vseindexstatus.idletime > 0)
                    return;
                if (statusresponse.vsestatus.vseindexstatus.servicestatus != vseindexstatusServicestatus.running)
                    return;

                System.Threading.Thread.Sleep(1000);
            }
        }


        /// <summary>
        /// Make a search collection read-only.  Wait for the status to be set to enabled.
        /// </summary>
        /// <param name="SearchCollection">Name of the collection</param>
        /// <param name="auth">Authentication</param>
        /// <param name="url">Service URL</param>
        public static void EnableReadOnlyandWait(string SearchCollection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            SearchCollectionReadOnlyResponse response = new SearchCollectionReadOnlyResponse();

            service.Url = url;

            // Enable read-only mode.
            scro.authentication = auth;
            scro.collection = SearchCollection;
            scro.mode = SearchCollectionReadOnlyMode.enable;
            response = service.SearchCollectionReadOnly(scro);
            Console.WriteLine("Read-0nly status: {0}", response.readonlystate.mode);

            System.Threading.Thread.Sleep(4000);

            while (true)
            {
                // Get status
                System.Threading.Thread.Sleep(1000);
                scro.mode = SearchCollectionReadOnlyMode.status;
                response = service.SearchCollectionReadOnly(scro);
                Console.WriteLine("Read-0nly status: {0}", response.readonlystate.mode);
                if (response.readonlystate.mode == readonlystateMode.enabled)
                    return;

                System.Threading.Thread.Sleep(1000);
            }
        }

        /// <summary>
        /// Make a search collection readable.  Wait for the status to be set to disabled.
        /// </summary>
        /// <param name="SearchCollection">Name of the collection</param>
        /// <param name="auth">Authentication</param>
        /// <param name="url">Service URL</param>
        public static void DisableReadOnlyandWait(string SearchCollection, authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SearchCollectionReadOnly scro = new SearchCollectionReadOnly();
            SearchCollectionReadOnlyResponse response = new SearchCollectionReadOnlyResponse();

            service.Url = url;

            // Enable read-only mode.
            scro.authentication = auth;
            scro.collection = SearchCollection;
            scro.mode = SearchCollectionReadOnlyMode.disable;
            response = service.SearchCollectionReadOnly(scro);
            Console.WriteLine("Read-0nly status: {0}", response.readonlystate.mode);

            while (true)
            {
                // Get status
                scro.mode = SearchCollectionReadOnlyMode.status;
                response = service.SearchCollectionReadOnly(scro);
                Console.WriteLine("Read-0nly status: {0}", response.readonlystate.mode);
                if (response.readonlystate.mode == readonlystateMode.disabled)
                    return;

                System.Threading.Thread.Sleep(1000);
            }
        }

        public static void UpdateCollection(XmlElement Node, authentication auth, string s)
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryUpdate update = new RepositoryUpdate();

            service.Url = s;
            update.authentication = auth;
            update.node = Node;
            service.RepositoryUpdate(update);

        }
        public static bool ensureQueryable(String collection, authentication auth, string url)
        {
            return ensureQueryable(collection, NUMDOCS, 0, MAXTIME, null, auth, url);
        }
        public static bool ensureQueryable(String collection, int numDocs, authentication auth, string url)
        {
            return ensureQueryable(collection, numDocs, 0, MAXTIME, null, auth, url);
        }
        public static bool ensureQueryable(String collection, int numDocs, int sleeptime, authentication auth, string url)
        {
            return ensureQueryable(collection, numDocs, sleeptime, MAXTIME, null, auth, url);
        }
        public static bool ensureQueryable(String collection, int numDocs, int sleeptime, long maxtime, authentication auth, string url)
        {
            return ensureQueryable(collection, numDocs, sleeptime, maxtime, null, auth, url);
        }

        public static bool ensureQueryable(String collection, int numDocs, int sleeptime, long maxtime, String subcollection, authentication auth, string url)
        {
            // variables
            VelocityService service = new VelocityService();
            service.Url = url;

            try
            {

                SearchServiceStatusXml sssxml = new SearchServiceStatusXml();
                sssxml.authentication = auth;
                XmlElement ssstat = service.SearchServiceStatusXml(sssxml);
                XmlNodeList notRunning = ssstat.SelectNodes("@not-running");
                if (notRunning != null && notRunning.Count != 0)
                {
                    SearchServiceStart(auth, url);
                }

                if (numDocs <= 0)
                    numDocs = NUMDOCS;
                if (maxtime <= 0)
                    maxtime = MAXTIME;

                SearchCollectionStatus stat = new SearchCollectionStatus();
                stat.collection = collection;
                stat.authentication = auth;
                if (subcollection == null || subcollection.Length == 0)
                {
                    subcollection = "live";
                }

                if (!"live".Equals(subcollection))
                    stat.subcollection = SearchCollectionStatusSubcollection.live;

                SearchCollectionStatusResponse statresp = null;


                statresp = service.SearchCollectionStatus(stat);

                int ndocs = 0;

                DateTime starttime = DateTime.Now;
                while (ndocs < numDocs && (DateTime.Now - starttime).TotalMilliseconds <= (maxtime * 10))
                {

                    statresp = service.SearchCollectionStatus(stat);
                    if (statresp.vsestatus != null && statresp.vsestatus.vseindexstatus != null && statresp.vsestatus.vseindexstatus.vseindexfile != null)
                    {
                        ndocs = statresp.vsestatus.vseindexstatus.ndocs;
                    }
                }

                if (sleeptime > 0)
                {
                    Thread.Sleep(sleeptime * 2);
                }
                return ndocs >= numDocs;
            }
            catch (SoapException se)
            {
                HandleSoapException(se);
            }

            return false;
        }

        public static void SearchServiceStart(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            service.Url = url;

            try
            {
                SearchServiceStatusXml sssxml = new SearchServiceStatusXml();
                sssxml.authentication = auth;
                XmlElement stat = service.SearchServiceStatusXml(sssxml);
                XmlNodeList notRunning = stat.SelectNodes("@not-running");

                if (notRunning == null || notRunning.Count == 0)
                {
                    return;
                }

                sssxml = new SearchServiceStatusXml();
                sssxml.authentication = auth;
                stat = service.SearchServiceStatusXml(sssxml);
                notRunning = stat.SelectNodes("@not-running");

                Assert.IsTrue(notRunning != null && notRunning.Count != 0);

                SearchServiceSet servset = new SearchServiceSet();
                SearchServiceSetConfiguration servconfig = new SearchServiceSetConfiguration();
                servset.configuration = servconfig;
                servconfig.vseqs = new vseqs();
                servconfig.vseqs.vseqsoption = new vseqsoption();
                servconfig.vseqs.vseqsoption.port = 7744;
                servset.authentication = auth;
                service.SearchServiceSet(servset);

                /* example start: cs-ss-start */
                try
                {
                    SearchServiceStart sss = new SearchServiceStart();
                    sss.authentication = auth;
                    // this will throw an exception if the port is in use
                    service.SearchServiceStart(sss);
                }
                catch (SoapException se)
                {
                    HandleSoapException(se);
                }

                sssxml = new SearchServiceStatusXml();
                sssxml.authentication = auth;
                stat = service.SearchServiceStatusXml(sssxml);
                notRunning = stat.SelectNodes("@not-running");

                Assert.IsTrue(notRunning == null || notRunning.Count == 0);
                /* example end: cs-ss-start */
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        public static void ResetCollectionBrokerSettings(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();

            CollectionBrokerSet set = new CollectionBrokerSet();
            CollectionBrokerSetConfiguration config = new CollectionBrokerSetConfiguration();

            service.Url = url;

            try
            {
                Console.WriteLine("Submitting CollectionBrokerSet request.");

                config.collectionbrokerconfiguration = new collectionbrokerconfiguration();

                set.authentication = auth;
                set.configuration = config;

                service.CollectionBrokerSet(set);

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }

        }

        /// <summary>
        /// Helper method that starts scheduler service.
        /// </summary>
        /// <param name="auth">authentication object required for all api methods</param>
        /// <param name="url">service url</param>
        public static void StartSchedulerService(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SchedulerServiceStart start = new SchedulerServiceStart();
            SchedulerServiceStatusXml status = new SchedulerServiceStatusXml();
            XmlElement results;
            string ResultsCompare = "<service-status started=\"";

            service.Url = url;
            start.authentication = auth;
            status.authentication = auth;
            try
            {
                service.SchedulerServiceStart(start);
                results = service.SchedulerServiceStatusXml(status);
                Assert.IsTrue(results.InnerXml.ToString().Contains(ResultsCompare) == true,
                    "Scheduler Service could not be started.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

        /// <summary>
        /// Helper method that stops the service and checks status after stopping.
        /// </summary>
        /// <param name="auth">authentication object required for all calls</param>
        /// <param name="url">service url to use</param>
        public static void StopSchedulerService(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SchedulerServiceStop stop = new SchedulerServiceStop();
            SchedulerServiceStatusXml status = new SchedulerServiceStatusXml();
            XmlElement results;

            service.Url = url;
            stop.authentication = auth;
            status.authentication = auth;
            try
            {
                service.SchedulerServiceStop(stop);
                // check service status
                results = service.SchedulerServiceStatusXml(status);
                Assert.IsTrue(results.InnerXml.ToString() == "", "Service could not be stopped.");
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }

    }

}