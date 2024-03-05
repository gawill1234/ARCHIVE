using System;
using System.Collections;
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
    class QuerySearchWithProjectTests
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        string[] servers;

        [Test]
        public void TestPrototype()
        {
            // Variables
            VelocityService service = new VelocityService();
            authentication auth = new authentication();
            auth.username = username;
            auth.password = password;
            QuerySearchWithProject search = new QuerySearchWithProject();
            QuerySearchWithProjectResponse response = new QuerySearchWithProjectResponse();
            string collection = "oracle-1";
            XmlElement XmlToAdd;

            GetServers();
            foreach (string s in servers)
            {
                Console.WriteLine("Test: TestPrototype Server: {0}", s);
                service.Url = s;

                try
                {
                    // Setup
                    Console.WriteLine("Test Setup.");
                    TestUtilities.CreateSearchCollection(collection, auth, s);
                    XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
                    TestUtilities.UpdateCollection(XmlToAdd, auth, s);
                    TestUtilities.StartCrawlandWaitStaging(collection, auth, s);
                    TestUtilities.WaitIdle(collection, auth, s);

                    // Configure request
                    search.authentication = auth;
                    search.project = "test-query-search";
                    search.query = "admiral";
                    search.sources = "oracle-1";
                    response = service.QuerySearchWithProject(search);

                    Assert.IsTrue(response.queryresults.addedsource[0].totalresults != 0);

                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                }
                finally
                {
                    Console.WriteLine("Test Cleanup.");
                    TestUtilities.StopCrawlAndIndex(collection, auth, s);
                    TestUtilities.DeleteSearchCollection(collection, auth, s);
                }
            }
        }

        public void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

    }
}
