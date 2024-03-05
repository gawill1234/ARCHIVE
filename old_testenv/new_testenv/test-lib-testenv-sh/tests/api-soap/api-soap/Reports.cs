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
    class Reports
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        /// <summary>
        /// Based on the comments in the defect, this is an invalid test at the moment. Going
        /// to add the ignore flag in.
        /// </summary>
        [Test]
        [Ignore("Bug 21302")]
        public void TestReportingCleanNow_21302()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            ReportingCleanNow clean = new ReportingCleanNow();
            ReportsSystemReporting report = new ReportsSystemReporting();
            ReportsSystemReportingResponse response = new ReportsSystemReportingResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReportingCleanNow Server " + s);
                clean.authentication = auth;
                
                // Clean the reports then get a report and ensure length is 0
                try
                {
                    service.ReportingCleanNow(clean);
                    report.authentication = auth;
                    report.start = DateTime.Today;
                    report.end = DateTime.Now;
                    response = service.ReportsSystemReporting(report);
                    Assert.IsTrue(response.systemreport.systemreportitem.Length == 0, "Reports were returned after a clean.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void TestReportsSystemReporting()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            ReportsSystemReporting report = new ReportsSystemReporting();
            ReportsSystemReportingResponse response = new ReportsSystemReportingResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReportsSystemReporting Server: " + s);
                report.authentication = auth;
                report.start = DateTime.Today;
                report.end = DateTime.Now;

                try
                {
                    response = service.ReportsSystemReporting(report);
                    Assert.AreNotEqual(null, response.systemreport.systemreportingdatabase, 
                        "No system reporting database node returned.");
                    Assert.AreNotEqual(0, response.systemreport.systemreportitem.Length, 
                        "No report results returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }

        }

        [Test]
        public void TestReportsSystemReporting_MaxItems()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            ReportsSystemReporting report = new ReportsSystemReporting();
            ReportsSystemReportingResponse response = new ReportsSystemReportingResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                logger.Info("Test: TestReportsSystemReporting_MaxItems Server: " + s);
                service.Url = s;
                report.authentication = auth;
                report.start = DateTime.Today;
                report.end = DateTime.Now;
                report.maxitems = 10;

                try
                {
                    response = service.ReportsSystemReporting(report);
                    Assert.IsTrue(response.systemreport.systemreportitem.Length <= 10, "Too many report results returned.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }


        [Test]
        public void TestReportsSystemReporting_InvalidEnd()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            ReportsSystemReporting report = new ReportsSystemReporting();
            ReportsSystemReportingResponse response = new ReportsSystemReportingResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReportsSystemReporting_InvalidEnd Server: " + s);
                report.authentication = auth;
                report.start = DateTime.Today;

                try
                {
                    response = service.ReportsSystemReporting(report);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [reports-system-reporting] was thrown.");
                }
            }

        }



        [Test]
        public void TestReportsSystemReporting_InvalidStart()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            ReportsSystemReporting report = new ReportsSystemReporting();
            ReportsSystemReportingResponse response = new ReportsSystemReportingResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReportsSystemReporting_InvalidStart Server: " + s);

                report.authentication = auth;
                report.end = DateTime.Now;

                try
                {
                    response = service.ReportsSystemReporting(report);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [reports-system-reporting] was thrown.");
                }
            }

        }

        [Test]
        public void TestReportsSystemReporting_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            ReportsSystemReporting report = new ReportsSystemReporting();
            ReportsSystemReportingResponse response = new ReportsSystemReportingResponse();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReportsSystemReporting_NoAuth Server: " + s);

                report.start = DateTime.Today;
                report.end = DateTime.Now;

                try
                {
                    response = service.ReportsSystemReporting(report);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
            }

        }

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }
    }
}
