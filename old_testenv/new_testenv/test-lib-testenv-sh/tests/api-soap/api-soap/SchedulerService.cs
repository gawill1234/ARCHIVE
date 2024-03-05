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
    /// <summary>
    /// scheduler-service-start
    /// scheduler-service-stop
    /// scheduler-service-status-xml 
    ///
    /// </summary>
    [TestFixture]
    class SchedulerService
    {
        // Variables
        string username = ConfigurationManager.AppSettings["username"];
        string password = ConfigurationManager.AppSettings["password"];
        string serverlist = ConfigurationManager.AppSettings["serverlist"];
        string[] servers;

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

        /// <summary>
        /// This test verifies the method SchedulerServiceStop().  The test first checks
        /// the status of the service.  If the service is running, the test stops it.  If the
        /// service was stopped, the service is started, then stopped.
        /// </summary>
        [Test]
        public void TestSchedulerServiceStop()
        {
            // variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            SchedulerServiceStatusXml status = new SchedulerServiceStatusXml();
            XmlElement results;
            string StartedCompare = "<service-status started=\"";
            string StopCompare = "";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in this.servers)
            {
                service.Url = s;
                logger.Info("Test: TestSchedulerServiceStop Server: " + s);

                // check if Service is running.
                status.authentication = auth;
                results = service.SchedulerServiceStatusXml(status);
                if (results.InnerXml.ToString().Contains(StartedCompare) == true)
                {
                    try
                    {
                        // Stop service
                        StopSchedulerService(auth, s);
                        // check service status
                        results = service.SchedulerServiceStatusXml(status);
                        Assert.IsTrue(results.InnerXml.ToString().Contains(StopCompare), "Service was not stopped.");
                    }
                    catch (SoapException se)
                    {
                        TestUtilities.HandleSoapException(se);
                    }
                }
                // Start Service then stop it.
                else
                {
                    StartSchedulerService(auth, s);
                    try
                    {
                        // Stop service
                        StopSchedulerService(auth, s);
                        // check service status
                        results = service.SchedulerServiceStatusXml(status);
                        Assert.IsTrue(results.InnerXml.ToString().Contains(StopCompare), "Service was not stopped.");
                    }
                    catch (SoapException se)
                    {
                        TestUtilities.HandleSoapException(se);
                    }
                }
            }
        }

        /// <summary>
        /// Submits a request to SchedulerServiceStop with no authentication object.
        /// Expects an exception to be thrown.
        /// </summary>

        [Test]
        public void TestSchedulerServiceStop_NoAuth()
        {
            // variables
            VelocityService service = new VelocityService();
            SchedulerServiceStop stop = new SchedulerServiceStop();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSchedulerServiceStop_NoAuth Server: " + s);

                try
                {
                    service.SchedulerServiceStop(stop);
                }
                
                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Code.ToString() == "urn:/velocity/objects:rights-execute", "The appropriate SoapException was not thrown.");
                }
            }
        }

        /// <summary>
        /// This test verifies the method SchedulerServiceStart().  The 
        /// </summary>
        [Test]
        public void TestSchedulerServiceStart()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSchedulerServiceStart Server: " + s);

                // Start service
                StartSchedulerService(auth, s);

                Assert.Pass("Scheduler Service was started.");
            }
        }

        /// <summary>
        /// Tests that the SchedulerServiceStart() call doesn't fail when the 
        /// service is already started.
        /// </summary>
        [Test]
        public void TestSchedulerServiceStart_AlreadyStarted()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSchedulerServiceStart_AlreadyStarted Server: " + s);

                // Start service
                StartSchedulerService(auth, s);
                StartSchedulerService(auth, s);

                Assert.Pass("Scheduler Service was started when already running.");
            }

        }

        /// <summary>
        /// Submits a request to SchedulerServiceStart with no authentication object.
        /// Expects an exception to be thrown.
        /// </summary>
        [Test]
        public void TestSchedulerServiceStart_NoAuth()
        {
            // variables
            VelocityService service = new VelocityService();
            SchedulerServiceStart start = new SchedulerServiceStart();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSchedulerServiceStart_NoAuth Server: " + s);

                try
                {
                    service.SchedulerServiceStart(start);
                }

                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Code.ToString() == "urn:/velocity/objects:rights-execute", "The appropriate SoapException was not thrown.");
                }
            }
        }

        /// <summary>
        /// Tests that the scheduler service calls don't fail when the service isn't already
        /// running.
        /// </summary>
        [Test]
        public void TestSchedulerServiceStop_AlreadyStopped()
        {
            // Variables
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestSchedulerServiceStop_AlreadyStopped Server: " + s);

                // Start service
                StopSchedulerService(auth, s);
                StopSchedulerService(auth, s);

                Assert.Pass("Scheduler Service was stopped when not running.");
            }

        }

        /// <summary>
        /// Tests that the status is returned correctly when SchedulerServiceStatusXml is
        /// called with the service stopped.
        /// </summary>
        [Test]
        public void TestSchedulerServiceStatusXml_Stopped()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement results;
            SchedulerServiceStatusXml status = new SchedulerServiceStatusXml();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSchedulerServiceStatusXml_Stopped Server: " + s);

                status.authentication = auth;
                // Stop the service
                StopSchedulerService(auth, s);

                try
                {
                    results = service.SchedulerServiceStatusXml(status);
                    Assert.IsTrue(results.InnerXml.ToString() == "", "Stopped Status Returned Incorrectly.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        /// <summary>
        /// Tests that the status is returned correctly when SchedulerServiceStatusXml is
        /// called with the service started.
        /// </summary>
        [Test]
        public void TestSchedulerServiceStatusXml_Started()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement results;
            SchedulerServiceStatusXml status = new SchedulerServiceStatusXml();
            string ResultsCompare = "<service-status started=\"";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSchedulerServiceStatusXml_Started Server: " + s);

                status.authentication = auth;
                // Start the service
                StartSchedulerService(auth, s);

                try
                {
                    results = service.SchedulerServiceStatusXml(status);
                    Assert.IsTrue(results.InnerXml.ToString().Contains(ResultsCompare) == true, 
                        "Started Status Returned Incorrectly.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }

        }

        /// <summary>
        /// Submits a request to SchedulerServiceStatusXml with no authentication object.
        /// Expects an exception to be thrown.
        /// </summary>
        [Test]
        public void TestSchedulerServiceStatusXml_NoAuth()
        {
            // variables
            VelocityService service = new VelocityService();
            SchedulerServiceStatusXml status = new SchedulerServiceStatusXml();
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestSchedulerServiceStatusXml_NoAuth Server: " + s);

                try
                {
                    results = service.SchedulerServiceStatusXml(status);
                }

                catch (SoapException se)
                {
                    logger.Info("SoapException Details: " + se.Code);
                    logger.Info("SoapException Message: " + se.Message);
                    Assert.IsTrue(se.Code.ToString() == "urn:/velocity/objects:rights-execute", "The appropriate SoapException was not thrown.");
                }
            }
        }
        /// <summary>
        /// Helper method that stops the service and checks status after stopping.
        /// </summary>
        /// <param name="auth">authentication object required for all calls</param>
        /// <param name="url">service url to use</param>
        public void StopSchedulerService(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SchedulerServiceStop stop = new SchedulerServiceStop();
            SchedulerServiceStatusXml status = new SchedulerServiceStatusXml();
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

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

        /// <summary>
        /// Helper method that starts scheduler service.
        /// </summary>
        /// <param name="auth">authentication object required for all api methods</param>
        /// <param name="url">service url</param>
        public void StartSchedulerService(authentication auth, string url)
        {
            // Variables
            VelocityService service = new VelocityService();
            SchedulerServiceStart start = new SchedulerServiceStart();
            SchedulerServiceStatusXml status = new SchedulerServiceStatusXml();
            XmlElement results;
            string ResultsCompare = "<service-status started=\"";
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

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
    }
}
