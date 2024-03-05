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
    class IndexAtomic
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

        [Test]
        public void TestIndexAtomicStateSuccess()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicStateSuccess Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";
                    inda.synchronization = indexatomicSynchronization.indexednosync;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.state == indexatomicState.success, "Did not return Success state");
                        }
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
        public void TestIndexAtomicStateError()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicStateError Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";
                    inda.synchronization = indexatomicSynchronization.indexednosync;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "badprotocol://";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.state == indexatomicState.error, "Did not return Error state");
                        }
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
        public void TestIndexAtomicStateAbort()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicStateAbort Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";
                    inda.synchronization = indexatomicSynchronization.indexednosync;
                    inda.abortbatchonerrorSpecified = true;
                    inda.abortbatchonerror = indexatomicAbortbatchonerror.abortbatchonerror;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "badprotocol://";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.state == indexatomicState.aborted, "Did not return Abort state");
                        }
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
        public void TestIndexAtomicStatePending()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicStatePending Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myprotocol://";
                    //cu.synchronization = crawlurlSynchronization.none;
                    cu.status = crawlurlStatus.complete;

                    SearchCollectionEnqueueXmlResponse scexr = service.SearchCollectionEnqueueXml(scex);
                    foreach (object o in scexr.crawlerserviceenqueueresponse.Items)
                    {
                        indexatomic a = (indexatomic)o;
                        Assert.IsTrue(a.state == indexatomicState.pending, "Did not return Pending state");
                    }

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.state != indexatomicState.pending, "Did not resolve Pending state");
                        }
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
        public void TestIndexAtomicSynchronizationNone()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicSynchronizationNone Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";
                    inda.synchronizationSpecified = true;
                    inda.synchronization = indexatomicSynchronization.none;

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myprotocol://";
                    cu.synchronization = crawlurlSynchronization.none;
                    cu.status = crawlurlStatus.complete;

                    SearchCollectionEnqueueXmlResponse scexr = service.SearchCollectionEnqueueXml(scex);
                    Assert.IsNull(scexr.crawlerserviceenqueueresponse.Items, "Synchronization None shouldn't return items");

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.synchronizationSpecified == true && a.synchronization == indexatomicSynchronization.none, "Did not return synchronization None");
                        }
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
        public void TestIndexAtomicSynchronizationEnqueued()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicSynchronizationEnqueued Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";
                    inda.synchronizationSpecified = true;
                    inda.synchronization = indexatomicSynchronization.enqueued;

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myprotocol://";
                    cu.synchronization = crawlurlSynchronization.enqueued;
                    cu.status = crawlurlStatus.complete;

                    SearchCollectionEnqueueXmlResponse scexr = service.SearchCollectionEnqueueXml(scex);
                    foreach (object o in scexr.crawlerserviceenqueueresponse.Items)
                    {
                        indexatomic a = (indexatomic)o;
                        Assert.IsTrue(a.stateSpecified == true && a.state == indexatomicState.pending, "Did not return Pending state");
                    }

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.synchronizationSpecified == true && a.synchronization == indexatomicSynchronization.enqueued, "Did not return synchronization Enqueued");
                        }
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
        public void TestIndexAtomicSynchronizationToBeIndexed()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicSynchronizationToBeIndexed Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";
                    inda.synchronizationSpecified = true;
                    inda.synchronization = indexatomicSynchronization.tobeindexed;

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myprotocol://";
                    cu.synchronization = crawlurlSynchronization.tobeindexed;
                    cu.status = crawlurlStatus.complete;

                    SearchCollectionEnqueueXmlResponse scexr = service.SearchCollectionEnqueueXml(scex);
                    foreach (object o in scexr.crawlerserviceenqueueresponse.Items)
                    {
                        indexatomic a = (indexatomic)o;
                        Assert.IsTrue(a.stateSpecified == true && a.state == indexatomicState.pending, "Did not return Pending state");
                    }

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.synchronizationSpecified == true && a.synchronization == indexatomicSynchronization.tobeindexed, "Did not return synchronization To-Be-Indexed");
                        }
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
        public void TestIndexAtomicSynchronizationIndexed()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicSynchronizationIndexed Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";
                    inda.synchronizationSpecified = true;
                    inda.synchronization = indexatomicSynchronization.indexed;

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myprotocol://";
                    cu.synchronization = crawlurlSynchronization.indexed;
                    cu.status = crawlurlStatus.complete;

                    SearchCollectionEnqueueXmlResponse scexr = service.SearchCollectionEnqueueXml(scex);
                    foreach (object o in scexr.crawlerserviceenqueueresponse.Items)
                    {
                        indexatomic a = (indexatomic)o;
                        Assert.IsTrue(a.stateSpecified == true && a.state == indexatomicState.success, "Did not return Success state");
                    }

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.synchronizationSpecified == true && a.synchronization == indexatomicSynchronization.indexed, "Did not return synchronization Indexed");
                        }
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
        public void TestIndexAtomicSynchronizationIndexedNoSync()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicSynchronizationIndexedNoSync Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";
                    inda.synchronizationSpecified = true;
                    inda.synchronization = indexatomicSynchronization.indexednosync;

                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myprotocol://";
                    cu.synchronization = crawlurlSynchronization.indexednosync;
                    cu.status = crawlurlStatus.complete;

                    SearchCollectionEnqueueXmlResponse scexr = service.SearchCollectionEnqueueXml(scex);
                    foreach (object o in scexr.crawlerserviceenqueueresponse.Items)
                    {
                        indexatomic a = (indexatomic)o;
                        Assert.IsTrue(a.stateSpecified == true && a.state == indexatomicState.success, "Did not return Success state");
                    }

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.synchronizationSpecified == true && a.synchronization == indexatomicSynchronization.indexednosync, "Did not return synchronization Indexed-No-Sync");
                        }
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
        public void TestIndexAtomicAbortBatchAbortedOnError()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicAbortBatchAbortedOnError Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";
                    inda.synchronization = indexatomicSynchronization.indexednosync;
                    inda.abortbatchonerrorSpecified = true;
                    inda.abortbatchonerror = indexatomicAbortbatchonerror.abortbatchonerror;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "badprotocol://";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.abortedwhySpecified == true && a.abortedwhy == indexatomicAbortedwhy.batchabortedonerror, "Did not return 'Batch Aborted On Error'");
                        }
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
        public void TestIndexAtomicAbortBatchOnErrorNoError()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicAbortBatchOnErrorNoError Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "0";
                    inda.originator = "APISoap";
                    inda.synchronization = indexatomicSynchronization.indexednosync;
                    inda.abortbatchonerrorSpecified = true;
                    inda.abortbatchonerror = indexatomicAbortbatchonerror.abortbatchonerror;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[2];
                    inda.crawlurl[0] = new crawlurl();
                    inda.crawlurl[0].url = "myprotocol://doc?myid=1";
                    inda.crawlurl[0].status = crawlurlStatus.complete;
                    inda.crawlurl[0].synchronization = crawlurlSynchronization.indexednosync;
                    inda.crawlurl[1] = new crawlurl();
                    inda.crawlurl[1].url = "myprotocol://doc?myid=2";
                    inda.crawlurl[1].status = crawlurlStatus.complete;
                    inda.crawlurl[1].synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsFalse(a.abortedwhySpecified, "Should not abort");
                        }
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
        public void TestIndexAtomicOriginator()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicOriginator Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.originator = "APISoap";
                    inda.synchronization = indexatomicSynchronization.indexednosync;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.originator == "APISoap", "Did not return Originator");
                        }
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
        public void TestIndexAtomicPartial()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicPartial Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "Partial1";
                    inda.partial = indexatomicPartial.partial;
                    inda.partialSpecified = true;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";

                    service.SearchCollectionEnqueueXml(scex);


                    indexatomic inda2 = new indexatomic();
                    inda2.enqueueid = "Partial1";

                    SearchCollectionEnqueueXml scex2 = new SearchCollectionEnqueueXml();
                    scex2.collection = CollectionName;
                    scex2.authentication = auth;
                    scex2.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex2.crawlnodes.crawlurls = new crawlurls();
                    scex2.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex2.crawlnodes.crawlurls.indexatomic[0] = inda2;

                    inda2.crawlurl = new crawlurl[1];
                    crawlurl cu2 = new crawlurl();
                    inda2.crawlurl[0] = cu2;
                    cu2.url = "myproto://doc?id=2";
                    cu2.status = crawlurlStatus.complete;
                    cu2.crawldata = new crawldata[3];
                    cu2.crawldata[0] = new crawldata();
                    cu2.crawldata[0].contenttype = "text/html";
                    cu2.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";

                    service.SearchCollectionEnqueueXml(scex2);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.partialSpecified, "Partial not specified");
                            Assert.AreEqual(a.partial, indexatomicPartial.partial, "Partial not specified");
                        }
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
        public void TestIndexAtomicEnqueueID()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicEnqueueID Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "APISOAP.id.1";
                    inda.synchronization = indexatomicSynchronization.indexednosync;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.enqueueid == "APISOAP.id.1", "Did not return Enqueueid");
                        }
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
        public void TestIndexAtomicCrawlurl()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicCrawlurl Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "APISOAP.id.1";
                    inda.synchronization = indexatomicSynchronization.indexednosync;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "myproto://doc?id=1";
                    cu.status = crawlurlStatus.complete;
                    cu.crawldata = new crawldata[3];
                    cu.crawldata[0] = new crawldata();
                    cu.crawldata[0].contenttype = "text/html";
                    cu.crawldata[0].text = "<html><head><title>My HTML page title</title></head><body>My body</body></html>";
                    cu.synchronization = crawlurlSynchronization.indexednosync;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.AreEqual(auditresponse.auditlogretrieveresponse.auditlogentry.Length, 1, "Should only return one audit log entry");

                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        Assert.AreEqual(entry.Items.Length, 1, "Should only return one result");
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsNotNull(a.crawlurl, "Indexatomic should have a crawlurl child");
                        }
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
        public void TestIndexAtomicCrawldelete()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicCrawldelete Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "APISOAP.id.1";
                    inda.synchronization = indexatomicSynchronization.indexednosync;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;
                    
                    inda.enqueueid = "crawl-delete";
                    inda.crawldelete = new crawldelete[1];
                    crawldelete cd = new crawldelete();
                    inda.crawldelete[0] = cd;
                    cd.url = "myproto://doc?id=1";
                    cd.synchronization = crawldeleteSynchronization.indexed;

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);

                    Assert.NotNull(auditresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse);
                    Assert.NotNull(auditresponse.auditlogretrieveresponse.auditlogentry);

                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        if (entry.enqueueid == "crawl-delete")
                        {
                            Assert.AreEqual(entry.Items.Length, 1, "Should only return one result");
                            foreach (object o in entry.Items)
                            {
                                indexatomic a = (indexatomic)o;
                                Assert.IsNotNull(a.crawldelete, "Indexatomic should have a crawldelete child");
                            }
                        }
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
        public void TestIndexAtomicInvalidVseKeyDelete()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicInvalidVseKeyDelete Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "APISOAP.id.1";
                    inda.synchronization = indexatomicSynchronization.indexednosync;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    inda.crawldelete = new crawldelete[1];
                    crawldelete cd = new crawldelete();
                    inda.crawldelete[0] = cd;
                    cd.vsekey = "myproto://doc?id=1";
                    cd.synchronization = crawldeleteSynchronization.indexed;


                    SearchCollectionEnqueueXmlResponse resp = service.SearchCollectionEnqueueXml(scex);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.AreEqual("The exception [search-collection-enqueue-malformed-crawl-delete] was thrown.", se.Message,
                        "Incorrect exception thrown.");
                }
                finally
                {
                    TestUtilities.DeleteSearchCollection(CollectionName, auth, s);
                }
            }
        }


        [Test]
        public void TestIndexAtomicAbortDuplicateEnqueueID()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicAbortDuplicateEnqueueID Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "APISOAP.id.1";

                    indexatomic inda2 = new indexatomic();
                    inda2.enqueueid = "APISOAP.id.1";


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[2];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;
                    scex.crawlnodes.crawlurls.indexatomic[1] = inda2;

                    inda.crawlurl = new crawlurl[1];
                    crawlurl cu = new crawlurl();
                    inda.crawlurl[0] = cu;
                    cu.url = "http://vivisimo.com";

                    inda2.crawlurl = new crawlurl[1];
                    crawlurl cu2 = new crawlurl();
                    inda2.crawlurl[0] = cu2;
                    cu2.url = "http://vivisimo.com";

                    service.SearchCollectionEnqueueXml(scex);

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue (a.abortedwhy == indexatomicAbortedwhy.duplicateenqueueid, "Did not return Duplicate Enqueueid");
                        }
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
        [Ignore("Bug: 22029")]
        public void TestIndexAtomicAbortNoWork()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string CollectionName = "TestIndexAtomic";
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            XmlToAdd = TestUtilities.ReadXmlFile("indexatomic.xml");


            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestIndexAtomicAbortNoWork Server: " + s);

                try
                {

                    // Create Search Collection
                    TestUtilities.CreateSearchCollection(CollectionName, auth, s);
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    indexatomic inda = new indexatomic();
                    inda.enqueueid = "APISOAP.id.1";
                    inda.abortbatchonerrorSpecified = true;
                    inda.abortbatchonerror = indexatomicAbortbatchonerror.abortbatchonerror;
                    inda.synchronization = indexatomicSynchronization.indexednosync;


                    SearchCollectionEnqueueXml scex = new SearchCollectionEnqueueXml();
                    scex.collection = CollectionName;
                    scex.authentication = auth;
                    scex.crawlnodes = new SearchCollectionEnqueueXmlCrawlnodes();
                    scex.crawlnodes.crawlurls = new crawlurls();
                    scex.crawlnodes.crawlurls.indexatomic = new indexatomic[1];
                    scex.crawlnodes.crawlurls.indexatomic[0] = inda;

                    SearchCollectionEnqueueXmlResponse scexr = service.SearchCollectionEnqueueXml(scex);
                    Assert.IsTrue(scexr.crawlerserviceenqueueresponse.Items != null, "Items null.");
                    foreach (object o in scexr.crawlerserviceenqueueresponse.Items)
                    {
                        indexatomic a = (indexatomic)o;
                        Assert.IsTrue(a.abortedwhySpecified == true && a.abortedwhy == indexatomicAbortedwhy.nowork, 
                            "Did not return 'No Work' abort-why in crawler response");
                    }

                    TestUtilities.WaitIdle(CollectionName, auth, s);

                    SearchCollectionAuditLogRetrieve auditlog = new SearchCollectionAuditLogRetrieve();
                    auditlog.authentication = auth;
                    auditlog.collection = CollectionName;
                    auditlog.limit = 1000;
                    auditlog.offset = 0;
                    auditlog.subcollection = SearchCollectionAuditLogRetrieveSubcollection.live;
                    SearchCollectionAuditLogRetrieveResponse auditresponse = new SearchCollectionAuditLogRetrieveResponse();
                    auditresponse = service.SearchCollectionAuditLogRetrieve(auditlog);
                    foreach (auditlogentry entry in auditresponse.auditlogretrieveresponse.auditlogentry)
                    {
                        foreach (object o in entry.Items)
                        {
                            indexatomic a = (indexatomic)o;
                            Assert.IsTrue(a.abortedwhy == indexatomicAbortedwhy.nowork, "Did not return 'No Work' abort-why in audit log");
                        }
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
        

    }
}
