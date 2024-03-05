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
    class Repository
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;
        

        /// <summary>
        /// Need to add a node, then update it, then delete.
        /// </summary>
        [Test]
        public void TestRepositoryUpdate()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            XmlElement xmltoupdate;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("samba-erin.xml");
            xmltoupdate = TestUtilities.ReadXmlFile("samba-2.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryUpdate Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                update.authentication = auth;
                update.node = xmltoupdate;
                try
                {
                    result = service.RepositoryAdd(add);
                    result = service.RepositoryUpdate(update);
                    
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "samba-erin";
                    service.RepositoryDelete(delete);
                }
            }
        }

        [Test]
        public void TestRepositoryDelete_NoElement()
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryDelete delete = new RepositoryDelete();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryDelete_NoElement Server: " + s);

                try
                {
                    delete.name = "name";
                    service.RepositoryDelete(delete);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
            }
        }

        [Test]
        public void TestRepositoryDelete_Md5()
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string result;
            XmlElement xmltoadd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryDelete_Md5 Server: " + s);

                xmltoadd = TestUtilities.ReadXmlFile("oracle-1.xml");
                try
                {
                    add.node = xmltoadd;
                    add.authentication = auth;
                    result = service.RepositoryAdd(add);
                    delete.md5 = result;
                    delete.name = "oracle-1";
                    delete.element = "vse-collection";
                    delete.authentication = auth;
                    service.RepositoryDelete(delete);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }

        }


        [Test]
        public void TestRepositoryDelete_BadMd5()
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            string result;
            XmlElement xmltoadd;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryDelete_BadMd5 Server: " + s);

                xmltoadd = TestUtilities.ReadXmlFile("oracle-1.xml");
                try
                {
                    add.node = xmltoadd;
                    add.authentication = auth;
                    result = service.RepositoryAdd(add);
                    delete.name = "oracle-1";
                    delete.element = "vse-collection";
                    delete.md5 = "element";
                    delete.authentication = auth;
                    service.RepositoryDelete(delete);
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [repository-bad-md5] was thrown.", "Incorrect exception thrown.");
                }
                finally
                {
                    delete.element = "vse-collection";
                    delete.name = "oracle-1";
                    delete.md5 = null;
                    service.RepositoryDelete(delete);
                }
            }

        }

        [Test]
        public void TestRepositoryDelete_NoName()
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryDelete delete = new RepositoryDelete();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryDelete_NoName Server: " + s);

                try
                {
                    delete.element = "element";
                    service.RepositoryDelete(delete);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
            }
        }

        [Test]
        public void TestRepositoryDelete_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryDelete delete = new RepositoryDelete();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryDelete_NoAuth Server: " + s);

                delete.element = "NoAuth";
                delete.name = "NoAuth";

                try
                {
                    service.RepositoryDelete(delete);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }

            }
        }

        [Test]
        public void TestRepositoryUpdate_21187()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            XmlElement xmltoupdate;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("oracle-1.xml");
            xmltoupdate = TestUtilities.ReadXmlFile("21187-2.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryUpdate_21187 Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                update.authentication = auth;
                update.node = xmltoupdate;
                try
                {
                    result = service.RepositoryAdd(add);
                    Assert.IsTrue(result != null, "RepositoryAdd() call failed.");
                    result = service.RepositoryUpdate(update);
                    Assert.IsTrue(result != null, "RepositoryUpdate() call failed.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "oracle-1";
                    service.RepositoryDelete(delete);
                }
            }
        }


        [Test]
        public void TestRepositoryUpdate_Md5()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            RepositoryGetMd5 md5 = new RepositoryGetMd5();
            XmlElement xmltoadd;
            XmlElement xmltoupdate;
            XmlElement md5result;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("samba-erin.xml");
            xmltoupdate = TestUtilities.ReadXmlFile("samba-2.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryUpdate_Md5 Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                update.authentication = auth;
                update.node = xmltoupdate;
                md5.authentication = auth;
                md5.element = "vse-collection";
                md5.name = "samba-erin";

                try
                {

                    result = service.RepositoryAdd(add);
                    md5result = service.RepositoryGetMd5(md5);
                    update.md5 = md5result.SelectSingleNode("./md5").InnerText.ToString();
                    result = service.RepositoryUpdate(update);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "samba-erin";
                    service.RepositoryDelete(delete);
                }
            }
        }


        [Test]
        public void TestRepositoryUpdate_BadMd5()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            XmlElement xmltoupdate;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("samba-erin.xml");
            xmltoupdate = TestUtilities.ReadXmlFile("samba-2.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryUpdate_BadMd5 Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                update.authentication = auth;
                update.node = xmltoupdate;
                update.md5 = "md5";

                try
                {
                    result = service.RepositoryAdd(add);
                    result = service.RepositoryUpdate(update);

                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.AreEqual("The exception [repository-bad-md5] was thrown.", se.Message, "Incorrect exception thrown.");
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "samba-erin";
                    service.RepositoryDelete(delete);
                }
            }
        }


        [Test]
        public void TestRepositoryUpdate_AddNode()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("samba-2.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryUpdate_AddNode Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                try
                {
                    result = service.RepositoryAdd(add);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "samba-erin";
                    service.RepositoryDelete(delete);
                }
            }
        }


        [Test]
        public void TestRepositoryUpdate_AddDupItem()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            XmlElement xmltoupdate;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("samba-erin.xml");
            xmltoupdate = TestUtilities.ReadXmlFile("samba-3.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryUpdate_AddDupItem Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                update.authentication = auth;
                update.node = xmltoupdate;
                try
                {
                    result = service.RepositoryAdd(add);
                    result = service.RepositoryUpdate(update);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "samba-erin";
                    service.RepositoryDelete(delete);
                }
            }
        }


        [Test]
        public void TestRepositoryUpdate_NoChanges()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("samba-erin.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryUpdate_NoChanges Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                update.authentication = auth;
                update.node = xmltoadd;
                try
                {
                    result = service.RepositoryAdd(add);
                    result = service.RepositoryUpdate(update);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "samba-erin";
                    service.RepositoryDelete(delete);
                }
            }
        }


        [Test]
        public void TestRepositoryUpdate_NoNode()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("samba-erin.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryUpdate_NoNode Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                update.authentication = auth;
                try
                {
                    result = service.RepositoryAdd(add);
                    result = service.RepositoryUpdate(update);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "samba-erin";
                    service.RepositoryDelete(delete);
                }
            }
        }


        [Test]
        public void TestRepositoryUpdate_NoAuth()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            XmlElement xmltoupdate;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("samba-erin.xml");
            xmltoupdate = TestUtilities.ReadXmlFile("samba-2.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryUpdate_NoAuth Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                update.node = xmltoupdate;
                try
                {
                    result = service.RepositoryAdd(add);
                    result = service.RepositoryUpdate(update);
                    Assert.Fail("An exception should have been thrown.");

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "samba-erin";
                    service.RepositoryDelete(delete);
                }
            }

        }


        [Test]
        public void TestRepositoryUpdate_NotExist()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            RepositoryUpdate update = new RepositoryUpdate();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoupdate;
            string result;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoupdate = TestUtilities.ReadXmlFile("samba-erin.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryUpdate_NotExist Server: " + s);

                update.authentication = auth;
                update.node = xmltoupdate;
                try
                {
                    result = service.RepositoryUpdate(update);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("An exception was thrown.");
                    logger.Info("Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [repository-error] was thrown.",
                        "The incorrect exception was thrown. Expected: [repository-error] Actual: " + se.Message);
                }
            }

        }

        [Test]
        public void TestRepositoryAdd()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("oracle-1.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryAdd Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                try
                {
                    result = service.RepositoryAdd(add);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "oracle-1";
                    service.RepositoryDelete(delete);
                }
            }

        }

        [Test]
        public void TestRepositoryAdd_21187()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("21187.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryAdd_21187 Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                try
                {
                    result = service.RepositoryAdd(add);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "macro";
                    delete.name = "test";
                    service.RepositoryDelete(delete);
                }
            }

        }


        [Test]
        public void TestRepositoryAdd_NoName()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("oracle-3.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryAdd_NoName Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                try
                {
                    result = service.RepositoryAdd(add);
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.AreEqual("The exception [repository-node-needs-name] was thrown.", se.Message,
                        "Incorrect exception thrown.");

                }
            }

        }


        [Test]
        public void TestRepositoryAdd_AlreadyExists()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("oracle-1.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryAdd_AlreadyExists Server: " + s);

                add.authentication = auth;
                add.node = xmltoadd;
                try
                {
                    result = service.RepositoryAdd(add);
                    result = service.RepositoryAdd(add);
                }
                catch (SoapException se)
                {
                    logger.Info("Exception thrown: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [repository-node-already-exists] was thrown.", "Incorrect exception thrown.");
                }
                finally
                {
                    delete.authentication = auth;
                    delete.element = "vse-collection";
                    delete.name = "oracle-1";
                    service.RepositoryDelete(delete);
                }
            }

        }


        [Test]
        public void TestRepositoryAdd_NoNode()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryAdd add = new RepositoryAdd();
            string result;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryAdd_NoNode Server: " + s);

                add.authentication = auth;
                try
                {
                    result = service.RepositoryAdd(add);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
            }

        }


        [Test]
        public void TestRepositoryAdd_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryAdd add = new RepositoryAdd();
            RepositoryDelete delete = new RepositoryDelete();
            XmlElement xmltoadd;
            string result = null;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            xmltoadd = TestUtilities.ReadXmlFile("oracle-1.xml");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryAdd_NoAuth Server: " + s);

                add.node = xmltoadd;
                try
                {
                    result = service.RepositoryAdd(add);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
            }

        }

        [Test]
        public void TestRepositoryList()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryListXml list = new RepositoryListXml();
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            list.authentication = auth;

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryList Server: " + s);

                // Make call
                try
                {
                    results = service.RepositoryListXml(list);
                    Assert.IsTrue(results.InnerXml != null, "XML results not returned.");
                }

                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void TestRepositoryGetMd5()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement results;
            RepositoryGetMd5 md5 = new RepositoryGetMd5();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();
            Dictionary<string, string> dict = new Dictionary<string, string>();

            dict.Add("vse-collection", "enron-email-tutorial");
            dict.Add("function", "BBC-parser");
            dict.Add("application", "api-soap");
            dict.Add("source", "CNN");
            dict.Add("report", "source-summary");
            dict.Add("parser", "proxy");
            dict.Add("macro", "url-state");
            dict.Add("kb", "custom");
            dict.Add("dictionary", "base");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryGetMd5 Server: " + s);

                foreach (KeyValuePair<string, string> kvp in dict)
                {
                    md5.authentication = auth;
                    md5.element = kvp.Key;
                    md5.name = kvp.Value;

                    try
                    {
                        results = service.RepositoryGetMd5(md5);
                        Assert.IsTrue(results.InnerXml.Contains("<md5>") == true, "Md5 node not returned.");
                    }
                    catch (SoapException se)
                    {
                        TestUtilities.HandleSoapException(se);
                    }
                }
            }
        }

        [Test]
        public void TestRepositoryGetMd5_BadElement()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement results;
            RepositoryGetMd5 md5 = new RepositoryGetMd5();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryGetMd5_BadElement Server: " + s);

                md5.authentication = auth;
                md5.element = "BadElement";
                md5.name = "admin-search-service-actions";

                try
                {
                    results = service.RepositoryGetMd5(md5);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("An exception was thrown.");
                    logger.Info("Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [repository-unknown-node] was thrown.",
                        "The incorrect exception was thrown.");
                }
            }
        }

        [Test]
        public void TestRepositoryGetMd5_BadName()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement results;
            RepositoryGetMd5 md5 = new RepositoryGetMd5();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryGetMd5_BadName Server: " + s);

                md5.authentication = auth;
                md5.element = "application";
                md5.name = "BadName";

                try
                {
                    results = service.RepositoryGetMd5(md5);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("An exception was thrown.");
                    logger.Info("Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [repository-unknown-node] was thrown.",
                        "The incorrect exception was thrown.");
                }
            }
        }

        [Test]
        public void TestRepositoryGetMd5_NoName()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement results;
            RepositoryGetMd5 md5 = new RepositoryGetMd5();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryGetMd5_NoName Server: " + s);

                md5.authentication = auth;
                md5.element = "application";
                
                try
                {
                    results = service.RepositoryGetMd5(md5);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
            }
        }

        [Test]
        public void TestRepositoryGetMd5_NoElement()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement results;
            RepositoryGetMd5 md5 = new RepositoryGetMd5();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryGetMd5_NoElement Server: " + s);

                md5.authentication = auth;
                md5.name = "admin-search-service-actions";

                try
                {
                    results = service.RepositoryGetMd5(md5);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
            }
        }


        [Test]
        public void TestRepositoryGetMd5_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            XmlElement results;
            RepositoryGetMd5 md5 = new RepositoryGetMd5();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryGetMd5_NoAuth Server: " + s);

                md5.element = "application";
                md5.name = "admin-search-service-actions";

                try
                {
                    results = service.RepositoryGetMd5(md5);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
            }
        }

        [Test]
        public void TestReposityGet()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryGet get = new RepositoryGet();
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            Dictionary<string, string> dict = new Dictionary<string, string>();

            dict.Add("vse-collection", "enron-email-tutorial");
            dict.Add("function", "BBC-parser");
            dict.Add("application", "api-soap");
            dict.Add("source", "CNN");
            dict.Add("report", "source-summary");
            dict.Add("parser", "proxy");
            dict.Add("macro", "url-state");
            dict.Add("kb", "custom");
            dict.Add("dictionary", "base");

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReposityGet Server: " + s);

                get.authentication = auth;
                foreach (KeyValuePair<string, string> kvp in dict)
                {
                    get.element = kvp.Key;
                    get.name = kvp.Value;
                    try
                    {
                        results = service.RepositoryGet(get);
                        Assert.IsTrue(results.InnerXml.ToString().Length != 0 == true,
                            "Expected item not returned in repository: " + kvp.Key + " " + kvp.Value);
                    }
                    catch (SoapException se)
                    {
                        TestUtilities.HandleSoapException(se);
                    }
                }
            }
        }

        [Test]
        public void TestReposityGet_BadName()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryGet get = new RepositoryGet();
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReposityGet_BadName Server: " + s);

                get.authentication = auth;
                get.element = "application";
                get.name = "bogusname";
                try
                {
                    results = service.RepositoryGet(get);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("An exception was thrown.");
                    logger.Info("Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [repository-unknown-node] was thrown.",
                        "The incorrect exception was thrown.");
                }
            }
        }

        [Test]
        public void TestReposityGet_BadElement()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryGet get = new RepositoryGet();
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReposityGet_BadElement Server: " + s);

                get.authentication = auth;
                get.element = "BadElement";
                get.name = "admin-search-service-actions";
                try
                {
                    results = service.RepositoryGet(get);
                    Assert.Fail("An exception should have been thrown.");
                }
                catch (SoapException se)
                {
                    logger.Info("An exception was thrown.");
                    logger.Info("Message: " + se.Message);
                    Assert.IsTrue(se.Message == "The exception [repository-unknown-node] was thrown.", 
                        "The incorrect exception was thrown.");
                }
            }
        }

        [Test]
        public void TestReposityGet_NoName()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryGet get = new RepositoryGet();
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReposityGet_NoName Server: " + s);

                get.authentication = auth;
                get.element = "application";
                try
                {
                    results = service.RepositoryGet(get);
                    Assert.Fail("An exception was not thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
            }
        }


        [Test]
        public void TestReposityGet_NoElement()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;
            RepositoryGet get = new RepositoryGet();
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReposityGet_NoElement Server: " + s);

                get.authentication = auth;
                get.name = "admin-search-service-actions";
                try
                {
                    results = service.RepositoryGet(get);
                    Assert.Fail("No exception was thrown.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleMissingVar(se);
                }
            }
        }

        [Test]
        public void TestReposityGet_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryGet get = new RepositoryGet();
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestReposityGet_NoAuth Server: " + s);

                get.element = "application";
                get.name = "admin-search-service-actions";
                try
                {
                    results = service.RepositoryGet(get);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleNoAuth(se);
                }
            }
        }


        [Test]
        public void TestRepositoryList_NoAuth()
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryListXml list = new RepositoryListXml();
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestRepositoryList_NoAuth Server: " + s);

                // Make call
                try
                {
                    results = service.RepositoryListXml(list);
                    Assert.Fail("An exception was not thrown.");
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
