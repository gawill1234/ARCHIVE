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
    class CollectionBrokerStatusTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void CollectionBrokerStatus_Running()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStatus status = new CollectionBrokerStatus();
            CollectionBrokerStatusResponse response = new CollectionBrokerStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStatus_Running Server: " + s);
                service.Url = s;

                // Start collection broker
                TestUtilities.StartCollectionBrokerandWait(auth, s);
                try
                {
                    // Configure request
                    logger.Info("Submitting CollectionBrokerStatus request.");
                    status.authentication = auth;

                    response = service.CollectionBrokerStatus(status);

                    Assert.AreNotEqual(null, response, "No response for status request.");
                    Assert.AreEqual(collectionbrokerstatusresponseStatus.running, response.collectionbrokerstatusresponse.status,
                        "Collection Broker Status incorrectly reported.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerStatus_Stopped()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStatus status = new CollectionBrokerStatus();
            CollectionBrokerStatusResponse response = new CollectionBrokerStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStatus_Stopped Server: " + s);
                service.Url = s;

                // Start collection broker
                TestUtilities.StopCollectionBrokerandWait(auth, s);
                try
                {
                    // Configure request
                    logger.Info("Submitting CollectionBrokerStatus request.");
                    status.authentication = auth;

                    response = service.CollectionBrokerStatus(status);

                    Assert.AreNotEqual(null, response, "No response for status request.");
                    Assert.AreEqual(collectionbrokerstatusresponseStatus.stopped, response.collectionbrokerstatusresponse.status,
                        "Collection Broker Status incorrectly reported.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }

            }
        }

        [Test]
        public void CollectionBrokerStatus_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStatus status = new CollectionBrokerStatus();
            CollectionBrokerStatusResponse response = new CollectionBrokerStatusResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStatus_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    // Configure request
                    logger.Info("Submitting CollectionBrokerStatus request.");

                    response = service.CollectionBrokerStatus(status);

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


        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }
    }
}
