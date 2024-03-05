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
    class CollectionBrokerStopTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;


        [Test]
        public void CollectionBrokerStop_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStop stop = new CollectionBrokerStop();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStop_NoAuth Server: " + s);
                service.Url = s;

                try
                {
                    // Configure request
                    logger.Info("Submitting CollectionBrokerStatus request.");

                    service.CollectionBrokerStop(stop);

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
        public void CollectionBrokerStop_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStop stop = new CollectionBrokerStop();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStop_Default Server: " + s);
                service.Url = s;

                try
                {
                    // Configure request
                    logger.Info("Submitting CollectionBrokerStatus request.");

                    stop.authentication = auth;
                    service.CollectionBrokerStop(stop);

                    Assert.Pass("CollectionBrokerStop call successful.");
                    
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
        public void CollectionBrokerStop_AlreadyStopped()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStop stop = new CollectionBrokerStop();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStop_AlreadyStopped Server: " + s);
                service.Url = s;

                try
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                    // Configure request
                    logger.Info("Submitting CollectionBrokerStop request.");

                    stop.authentication = auth;
                    service.CollectionBrokerStop(stop);

                    Assert.Pass("CollectionBrokerStop call successful.");

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
        public void CollectionBrokerStop_AlreadyStarted()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            CollectionBrokerStop stop = new CollectionBrokerStop();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStop_AlreadyStarted Server: " + s);
                service.Url = s;

                try
                {
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
                    // Configure request
                    logger.Info("Submitting CollectionBrokerStop request.");

                    stop.authentication = auth;
                    service.CollectionBrokerStop(stop);

                    Assert.Pass("CollectionBrokerStop call successful.");

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


        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }
    }
}
