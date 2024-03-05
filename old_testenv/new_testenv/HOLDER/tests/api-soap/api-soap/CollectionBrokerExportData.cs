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
    class CollectionBrokerExportDataTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void CollectionBrokerExportData_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_NoAuth";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    export.query = "";
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerExportData_NoQueryEmpty()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_NoQuery";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_NoQuery Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);
                    
                    // Validate results
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.StopCrawlAndIndex("oracle-1", auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        [Ignore ("Bug 23205")]
        public void CollectionBrokerExportData_CollectionNotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_CollectionNotExist";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                    Assert.AreEqual("The exception [collection-broker-export-data] was thrown.", se.Message,
                        "Incorrect exception thrown: {0}", se.Message.ToString());
                    Assert.IsTrue(se.Detail.InnerXml.Contains("COLLECTION_BROKER_COLLECTION_DOES_NOT_EXIST") == true,
                        "Incorrect reason for exception.");
                }
                finally
                {
                    logger.Info("Cleanup.");
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.StopCrawlAndIndex("oracle-1", auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerExportData_DestinationExists()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_DestinationExists";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_DestinationExists Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                    Assert.AreEqual("The exception [collection-broker-export-destination-exists] was thrown.", se.Message,
                        "Incorrect reason for exception.");
                }
                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerExportData_DefaultWithData()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_DefaultWithData";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_DefaultWithData Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.query = "admiral";
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(3, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");
                    
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerExportData_DictExpandDictionary()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_DictExpandDictionary";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_DictExpandDictionary Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.dictexpanddictionary = "default";

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(352, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        [Ignore ("Bug 23380")]
        public void CollectionBrokerExportData_DictExpandWildcard()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_DictExpandWildcard";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_DictExpandWildcard Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.query = "adm$ral";
                    export.dictexpanddictionary = "default";
                    export.dictexpandwildcardenabled = true;
                    export.dictexpandwildcardenabledSpecified = true;
                    export.dictexpandstemstemmers = "default";

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(3, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    //TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.StopCrawlAndIndex("oracle-1", auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerExportData_DictExpandWildcardSegmenter()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_DictExpandWildcardSegmenter";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_DictExpandWildcardSegmenter Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.query = "adm$ral";
                    export.dictexpanddictionary = "default";
                    export.dictexpandwildcardenabled = true;
                    export.dictexpandwildcardenabledSpecified = true;
                    export.dictexpandstemstemmers = "default";
                    export.dictexpandwildcardsegmenter = "default";
                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(0, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerExportData_DictExpandWildcardDelanguage()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_DictExpandWildcardDelanguage";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_DictExpandWildcardDelanguage Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.query = "adm$ral";
                    export.dictexpanddictionary = "default";
                    export.dictexpandwildcardenabled = true;
                    export.dictexpandwildcardenabledSpecified = true;
                    export.dictexpandstemstemmers = "default";
                    export.dictexpandwildcarddelanguage = true;
                    export.dictexpandwildcarddelanguageSpecified = true;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(0, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerExportData_DictExpandRegEx()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_DictExpandRegEx";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_DictExpandRegEx Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.query = "adm$ral";
                    export.dictexpanddictionary = "default";
                    export.dictexpandwildcardenabled = true;
                    export.dictexpandwildcardenabledSpecified = true;
                    export.dictexpandstemstemmers = "default";
                    export.dictexpandregexenabled = true;
                    export.dictexpandregexenabledSpecified = true;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(0, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_TermExpand()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_TermExpand";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_TermExpand Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;

                    export.query = "admiral*";
                    export.termexpandmaxexpansions = 10;
                    export.termexpandmaxexpansionsSpecified = true;
                    export.termexpanderrorwhenexceedslimit = false;
                    export.termexpanderrorwhenexceedslimitSpecified = true;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(3, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        [Ignore ("Bug 23372")]
        public void CollectionBrokerExportData_TermExpandError()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_TermExpandError";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_TermExpandError Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;

                    export.query = "admiral*";
                    export.termexpandmaxexpansions = 1;
                    export.termexpandmaxexpansionsSpecified = true;
                    export.termexpanderrorwhenexceedslimit = true;
                    export.termexpanderrorwhenexceedslimitSpecified = true;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(0, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_SyntaxRepositoryNode()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_SyntaxRepositoryNode";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_SyntaxRepositoryNode Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.syntaxrepositorynode = "custom";
                    export.query = "admiral OR hipper";

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(4, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_SyntaxOperators()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_SyntaxOperators";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_SyntaxOperators Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.syntaxoperators = "AND";
                    export.query = "admiral OR hipper";

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(0, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_QueryModification()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_QueryModification";
            string result;
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            XmlElement XmlMacro;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_QueryModification Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);
                    XmlMacro = TestUtilities.ReadXmlFile("21187.xml");
                    add.authentication = auth;
                    add.node = XmlMacro;
                    result = service.RepositoryAdd(add);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.querymodificationmacros = "test";

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(352, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Cleanup.");

                    delete.authentication = auth;
                    delete.name = "test";
                    delete.element = "macro";
                    service.RepositoryDelete(delete);

                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        [Ignore ("Bug 23271")]
        public void CollectionBrokerExportData_QueryConditionXPath()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_QueryConditionXPath";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_QueryConditionXPath Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.queryconditionxpath = "$SHIP_TYPE='Destroyer'";

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(45, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_QueryConditionObject()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_QueryConditionObject";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_QueryConditionObject Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;

                    CollectionBrokerExportDataQueryconditionobject cond = new CollectionBrokerExportDataQueryconditionobject();
                    cond.@operator = new @operator();
                    cond.@operator.logic = "and";
                    cond.@operator.Items = new Object[1];
                    term t2 = new term();
                    t2.field = "title";
                    t2.str = "acasta";
                    cond.@operator.Items[0] = t2;

                    export.queryconditionobject = cond; 


                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.query = "acasta";
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(1, qsResponse.queryresults.list.document.Length,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_DestinationMeta()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_DestinationMeta";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_DestinationMeta Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.destinationcollectionmeta = new CollectionBrokerExportDataDestinationcollectionmeta();
                    export.destinationcollectionmeta.vsemeta = new vsemeta();
                    export.destinationcollectionmeta.vsemeta.which = vsemetaWhich.live;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.query = "admiral";
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(3, qsResponse.queryresults.list.document.Length,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_QueryObject()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_QueryObject";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_QueryObject Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.queryobject = new CollectionBrokerExportDataQueryobject();
                    export.queryobject.@operator = new @operator();
                    export.queryobject.@operator.logic = "and";
                    term te = new term();
                    te.field = "title";
                    te.str = "achates";
                    export.queryobject.@operator.Items = new Object[1];
                    export.queryobject.@operator.Items[0] = te;


                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results."); 
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");
                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.query = "achates";
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(1, qsResponse.queryresults.list.document.Length,
                        "Incorrect Results returned.  Data not exported.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerExportData_QueryObjectAndQuery()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_QueryObjectAndQuery";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_QueryObjectAndQuery Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.query = "admiral";
                    export.queryobject = new CollectionBrokerExportDataQueryobject();
                    export.queryobject.@operator = new @operator();
                    export.queryobject.@operator.logic = "and";
                    term te = new term();
                    te.field = "title";
                    te.str = "achates";
                    export.queryobject.@operator.Items = new Object[1];
                    export.queryobject.@operator.Items[0] = te;


                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");
                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.query = "achates";
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(0, qsResponse.queryresults.addedsource[0].totalresults,
                        "Incorrect Results returned.  Data not exported correctly.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_QueryObjectNull()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_QueryObjectNull";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_QueryObjectNull Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.queryobject = null;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    logger.Info("Validating results.");
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");
                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.query = "";
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(10, qsResponse.queryresults.list.document.Length,
                        "Incorrect Results returned.  Data not exported.");
                    Assert.AreEqual(352, qsResponse.queryresults.addedsource[0].totalresults,
                        "Full collection not exported.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_MoveTrue()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_MoveTrue";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_MoveTrue Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.move = true;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.query = "admiral";
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(3, qsResponse.queryresults.list.document.Length,
                        "Incorrect Results returned.  Data not exported.");

                    TestUtilities.WaitIdle("oracle-1", auth, s);
                    search.query = "admiral";
                    search.sources = "oracle-1";
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(null, qsResponse.queryresults.list,
                        "Incorrect Results returned.  Data not moved.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerExportData_QueryMove()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_QueryMove";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_QueryMove Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWait("oracle-1", auth, s);
                    TestUtilities.WaitIdle("oracle-1", auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";
                    export.destinationcollection = collection;
                    export.move = true;
                    export.query = "admiral";

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);

                    // Validate results
                    Assert.AreNotEqual(null, response.collectionbrokerexportdataresponse.id, "No id returned.");

                    TestUtilities.WaitIdle(collection, auth, s);
                    QuerySearch search = new QuerySearch();
                    QuerySearchResponse qsResponse = new QuerySearchResponse();
                    search.query = "";
                    search.sources = collection;
                    search.authentication = auth;
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(3, qsResponse.queryresults.list.document.Length,
                        "Incorrect Results returned.  Data not exported.");

                    TestUtilities.WaitIdle("oracle-1", auth, s);
                    search.query = "admiral";
                    search.sources = "oracle-1";
                    qsResponse = service.QuerySearch(search);
                    Assert.AreEqual(null, qsResponse.queryresults.list,
                        "Incorrect Results returned.  Data not moved.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        [Test]
        public void CollectionBrokerExportData_NoSourceCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_NoSourceCollection";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_NoSourceCollection Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    export.authentication = auth;
                    export.destinationcollection = collection;

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerExportData_NoDestinationCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            string collection = "CollectionBrokerExportData_NoDestinationCollection";
            CollectionBrokerExportData export = new CollectionBrokerExportData();
            CollectionBrokerExportDataResponse response = new CollectionBrokerExportDataResponse();
            XmlElement XmlToAdd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerExportData_NoDestinationCollection Server: " + s);
                service.Url = s;

                try
                {
                    logger.Info("Test Setup.");
                    TestUtilities.CreateSearchCollection("oracle-1", auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);

                    export.authentication = auth;
                    export.sourcecollection = "oracle-1";

                    logger.Info("Submitting request.");
                    response = service.CollectionBrokerExportData(export);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }

                finally
                {
                    logger.Info("Cleanup.");
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                    TestUtilities.DeleteSearchCollection("oracle-1", auth, s);
                }
            }
        }


        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }
    }
}
