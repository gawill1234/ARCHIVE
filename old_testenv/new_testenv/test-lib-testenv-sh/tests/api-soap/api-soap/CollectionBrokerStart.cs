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
    class CollectionBrokerStartTests
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
        public void CollectionBrokerStartTests_Default()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerStart start = new CollectionBrokerStart();
            SearchServiceGet ssg = new SearchServiceGet();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStartTests_Default Server: " + s);
                service.Url = s;

                try
                {
                    // start collection broker
                    start.authentication = auth;
                    service.CollectionBrokerStart(start);
                }
                catch (SoapException se)
                {
                    // Cleanup
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }

        [Test]
        public void CollectionBrokerStartTests_StartandCheckStatus()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerStart start = new CollectionBrokerStart();
            SearchServiceGet ssg = new SearchServiceGet();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStartTests_StartandCheckStatus Server: " + s);
                service.Url = s;
                try
                {
                    // Start the collection broker
                    TestUtilities.StartCollectionBrokerandWait(auth, s);
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
        public void CollectionBrokerStartTests_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            CollectionBrokerStart start = new CollectionBrokerStart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();  

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: CollectionBrokerStartTests_NoAuth Server: " + s);
                service.Url = s;
                try
                {
                    // start collection broker
                    service.CollectionBrokerStart(start);
                }
                catch (SoapException se)
                {
                    // Cleanup
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    TestUtilities.StopCollectionBrokerandWait(auth, s);
                }
            }
        }
    }
}
