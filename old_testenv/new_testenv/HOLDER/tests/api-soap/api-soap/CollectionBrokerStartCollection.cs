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
    class CollectionBrokerStartCollectionsTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;


        [Test]
        public void CollectionBrokerStartCollection_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStartCollection start = new CollectionBrokerStartCollection();
            string collection = "CollectionBrokerStartCollection_NoAuth";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStartCollection_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    // Configure request
                    logger.Info("Submitting CollectionBrokerStartCollection request.");

                    start.collection = collection;
                    service.CollectionBrokerStartCollection(start);

                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerStartCollection_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStartCollection start = new CollectionBrokerStartCollection();
            string collection = "CollectionBrokerStartCollection";
            CollectionBrokerStatus status = new CollectionBrokerStatus();
            CollectionBrokerStatusResponse response = new CollectionBrokerStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStartCollection_Default Server: " + s);
                service.Url = s;

                try
                {
                    // Configure request
                    logger.Info("Test setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    
                    logger.Info("Submitting CollectionBrokerStartCollection request.");
                    start.collection = collection;
                    start.authentication = auth;
                    service.CollectionBrokerStartCollection(start);

                    // Check status, make sure collection specified is started.
                    status.authentication = auth;
                    response = service.CollectionBrokerStatus(status);

                    Assert.AreNotEqual(null, response.collectionbrokerstatusresponse, 
                        "No CollectionBrokerStatus response.");
                    foreach (collectionbrokerstatusresponseCollection c in response.collectionbrokerstatusresponse.collection)
                    {
                        if (c.name == collection)
                        {
                            Assert.AreEqual(true, c.starttimeSpecified,
                                "Collection has no start time.  Collection not started.");
                            return;
                        }
                    }
                    Assert.Fail("Expected collection not in Status response");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerStartCollection_AlreadyStarted()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStartCollection start = new CollectionBrokerStartCollection();
            string collection = "CollectionBrokerStartCollection_AlreadyStarted";
            CollectionBrokerStatus status = new CollectionBrokerStatus();
            CollectionBrokerStatusResponse response = new CollectionBrokerStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStartCollection_AlreadyStarted Server: " + s);
                service.Url = s;

                try
                {
                    // Configure request
                    logger.Info("Test setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);

                    logger.Info("Submitting CollectionBrokerStartCollection request.");
                    start.collection = collection;
                    start.authentication = auth;
                    service.CollectionBrokerStartCollection(start);
                    service.CollectionBrokerStartCollection(start);

                    // Check status, make sure collection specified is started.
                    status.authentication = auth;
                    response = service.CollectionBrokerStatus(status);

                    Assert.AreNotEqual(null, response.collectionbrokerstatusresponse,
                        "No CollectionBrokerStatus response.");
                    foreach (collectionbrokerstatusresponseCollection c in response.collectionbrokerstatusresponse.collection)
                    {
                        if (c.name == collection)
                        {
                            Assert.AreEqual(true, c.starttimeSpecified,
                                "Collection has no start time.  Collection not started.");
                            return;
                        }
                    }
                    Assert.Fail("Expected collection not in Status response");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }


        [Test]
        public void CollectionBrokerStartCollection_CollectionNotExist_22566()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStartCollection start = new CollectionBrokerStartCollection();
            string collection = "CollectionBrokerStartCollection_CollectionNotExist";
            CollectionBrokerStatus status = new CollectionBrokerStatus();
            CollectionBrokerStatusResponse response = new CollectionBrokerStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStartCollection_CollectionNotExist Server: " + s);
                service.Url = s;

                try
                {
                    // Configure request
                    logger.Info("Submitting CollectionBrokerStartCollection request.");
                    start.collection = collection;
                    start.authentication = auth;
                    service.CollectionBrokerStartCollection(start);

                    // Check status, make sure collection specified is started.
                    status.authentication = auth;
                    response = service.CollectionBrokerStatus(status);

                    Assert.Fail("An exception should have been thrown.");
                }

                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
                    Assert.AreEqual("The exception [collection-broker-start-collection] was thrown.", se.Message,
                        "Incorrect exception thrown.");
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerStartCollection_NoCollection()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStartCollection start = new CollectionBrokerStartCollection();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStartCollection_NoCollection Server: " + s);
                service.Url = s;

                try
                {
                    // Configure request
                    logger.Info("Submitting CollectionBrokerStartCollection request.");

                    start.authentication = auth;
                    service.CollectionBrokerStartCollection(start);

                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }
    }
}
