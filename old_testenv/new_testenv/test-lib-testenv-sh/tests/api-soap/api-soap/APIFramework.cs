using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web.Services.Protocols;
using System.Xml;
using NUnit.Framework;

namespace APITests
{
    [TestFixture]
    class APIFramework
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");

        [Test]
        public void APIFramework_Boolean()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;

            ApiTestBoolean t = new ApiTestBoolean();
            t.authentication = auth;

            foreach (string s in GetServers())
            {
                service.Url = s;
                Console.WriteLine("Test: Boolean; Server: {0}", s);

                try
                {
                    bool res;

                    t.value = true;
                    res = service.ApiTestBoolean(t);
                    Assert.IsTrue(res, "Did not return true.");

                    t.value = false;
                    res = service.ApiTestBoolean(t);
                    Assert.IsFalse(res, "Did not return false.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void APIFramework_Int()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;

            ApiTestInt t = new ApiTestInt();
            t.authentication = auth;

            foreach (string s in GetServers())
            {
                service.Url = s;
                Console.WriteLine("Test: Int; Server: {0}", s);

                try
                {
                    int res;

                    t.value = 0;
                    res = service.ApiTestInt(t);
                    Assert.AreEqual(0, res, "Did not return 0.");

                    t.value = -1;
                    res = service.ApiTestInt(t);
                    Assert.AreEqual(-1, res, "Did not return -1.");

                    t.value = 1;
                    res = service.ApiTestInt(t);
                    Assert.AreEqual(1, res, "Did not return 1.");

                    t.value = Int32.MaxValue;
                    res = service.ApiTestInt(t);
                    Assert.AreEqual(Int32.MaxValue, res, "Did not return max int.");

                    t.value = Int32.MinValue;
                    res = service.ApiTestInt(t);
                    Assert.AreEqual(Int32.MinValue, res, "Did not return min int.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void APIFramework_Double()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;

            ApiTestDouble t = new ApiTestDouble();
            t.authentication = auth;

            foreach (string s in GetServers())
            {
                service.Url = s;
                Console.WriteLine("Test: Double; Server: {0}", s);

                try
                {
                    double res;

                    t.value = 0;
                    res = service.ApiTestDouble(t);
                    Assert.AreEqual(0, res, "Did not return true.");

                    t.value = -1;
                    res = service.ApiTestDouble(t);
                    Assert.AreEqual(-1, res, "Did not return -1.");

                    t.value = 1;
                    res = service.ApiTestDouble(t);
                    Assert.AreEqual(1, res, "Did not return 1.");

                    t.value = Double.MaxValue;
                    res = service.ApiTestDouble(t);
                    Assert.AreEqual(Double.MaxValue, res, "Did not return max double.");

                    t.value = Double.MinValue;
                    res = service.ApiTestDouble(t);
                    Assert.AreEqual(Double.MinValue, res, "Did not return min double.");

                    t.value = Double.NaN;
                    res = service.ApiTestDouble(t);
                    Assert.AreEqual(Double.NaN, res, "Did not return NaN.");

                    t.value = Double.PositiveInfinity;
                    res = service.ApiTestDouble(t);
                    Assert.AreEqual(Double.PositiveInfinity, res, "Did not return +infinity.");

                    t.value = Double.NegativeInfinity;
                    res = service.ApiTestDouble(t);
                    Assert.AreEqual(Double.NegativeInfinity, res, "Did not return -infinity.");

                    t.value = 1/9;
                    res = service.ApiTestDouble(t);
                    Assert.AreEqual(1/9, res, "Did not return 1/9.");

                    t.value = 1/3;
                    res = service.ApiTestDouble(t);
                    Assert.AreEqual(1/3, res, "Did not return 1/3.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void APIFramework_String()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;

            ApiTestString t = new ApiTestString();
            t.authentication = auth;

            foreach (string s in GetServers())
            {
                service.Url = s;
                Console.WriteLine("Test: String; Server: {0}", s);

                try
                {
                    string res;

                    t.value = "hello";
                    res = service.ApiTestString(t);
                    Assert.AreEqual("hello", res, "Did not return hello.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }

        [Test]
        public void APIFramework_Nodeset()
        {
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.password = password;
            auth.username = username;

            ApiTestNodeset t = new ApiTestNodeset();
            t.authentication = auth;

            foreach (string s in GetServers())
            {
                service.Url = s;
                Console.WriteLine("Test: Nodeset; Server: {0}", s);

                try
                {
                    XmlDocument doc = new XmlDocument();
                    XmlElement p;
                    XmlElement res;

                    p = doc.CreateElement("hello");

                    t.value = p;
                    res = service.ApiTestNodeset(t);
                    Assert.AreEqual(p, res, "Did not return hello node.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
            }
        }
        

        private string[] GetServers()
        {
            return serverlist.Split(',');
        }
    }
}
