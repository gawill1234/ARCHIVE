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
    public class QuerySimilarDocument
    {
        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        VelocityService service = new VelocityService();
        authentication auth = new authentication();

        [Test]
        public void TestQuerySimilarDocuments()
        {
            // Variables
            auth.password = password;
            auth.username = username;
            QuerySimilarDocuments qsdocs = new QuerySimilarDocuments();
            QuerySimilarDocumentsResponse qsresponse = new QuerySimilarDocumentsResponse();
            XmlElement XmlToAdd;
            QuerySearch search = new QuerySearch();
            QuerySearchResponse qresponse = new QuerySearchResponse();
            QuerySimilarDocumentsDocument doc = new QuerySimilarDocumentsDocument();
            XmlToAdd = TestUtilities.ReadXmlFile("oracle-1.xml");
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Test: TestQuerySimilarDocuments Server: " + serverlist);
            service.Url = serverlist;
            try
            {
                // Add a collection
                TestUtilities.CreateSearchCollection("oracle-1", auth, serverlist);
                TestUtilities.UpdateCollection(XmlToAdd, auth, serverlist);

                // Crawl Collection
                TestUtilities.StartCrawlandWaitStaging("oracle-1", auth, serverlist);
                TestUtilities.WaitIdle("oracle-1", auth, serverlist);

                // Get a document 
                search.sources = "oracle-1";
                search.authentication = auth;
                search.num = 100;
                qresponse = service.QuerySearch(search);
                Assert.IsTrue(qresponse.queryresults.list != null, "No results returned.");

                // Query Similar Documents
                qsdocs.document = doc;
                qsdocs.document.document = qresponse.queryresults.list.document[0];
                qsdocs.authentication = auth;
                qsresponse = service.QuerySimilarDocuments(qsdocs);
                Assert.IsTrue(qsresponse.@operator.Items.Length > 0, "No related terms returned.");

            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
            finally
            {
                TestUtilities.StopCrawlAndIndex("oracle-1", auth, serverlist);
                TestUtilities.DeleteSearchCollection("oracle-1", auth, serverlist);
            }
        }
    }
}
