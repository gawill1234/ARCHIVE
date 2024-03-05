using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Web;
using System.Web.Services.Protocols;
using NUnit.Framework;
using log4net;
using log4net.Config;

namespace ActivityFeeds
{
    class TestUtilities
    {
        public static void CreateSearchCollection(string CollectionName, authentication auth, string url)
        {
            VelocityService service = new VelocityService();
            service.Url = url;
            // Configure search collection
            SearchCollectionCreate sc = new SearchCollectionCreate();
            sc.authentication = auth;
            sc.collection = CollectionName;
            SearchCollectionListXml list = new SearchCollectionListXml();
            list.authentication = auth;
            XmlElement results;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Creating search collection: " + CollectionName);
            try
            {
                if (!isInRepo("vse-collection", CollectionName, auth, url))
                {
                    service.SearchCollectionCreate(sc);
                }
                else
                {
                    DeleteSearchCollection(CollectionName, auth, url);
                    CreateSearchCollection(CollectionName, auth, url);
                }
            }
            catch (SoapException se)
            {
                HandleSoapException(se);
            }

            // Verify created collection exists
            try
            {
                logger.Info("Verifying collection was created.");
                results = service.SearchCollectionListXml(list);
                Assert.IsTrue(results.InnerXml.ToString().Contains(CollectionName) == true,
                    "Search Collection create failed " + CollectionName);

            }
            catch (SoapException se)
            {
                HandleSoapException(se);
            }
        }

        public static bool isInRepo(String node, String name, authentication auth, string url)
        {
            VelocityService service = new VelocityService();
            service.Url = url;
            try
            {
                RepositoryGet rget = new RepositoryGet();
                rget.element = node;
                rget.name = name;
                rget.authentication = auth;

                XmlElement e = service.RepositoryGet(rget);
                return true;
            }
            catch (SoapException se)
            {
                if (se.Message == "The exception [repository-unknown-node] was thrown.")
                {
                    return false;
                }
                else
                {
                    HandleSoapException(se);
                    return false;
                }

            }
        }
        public static void DeleteSearchCollection(string CollectionName, authentication auth, string url)
        {
            VelocityService service = new VelocityService();
            service.Url = url;
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            // Configure search collection
            SearchCollectionDelete sd = new SearchCollectionDelete();
            sd.authentication = auth;
            sd.collection = CollectionName;
            sd.killservices = true;
            sd.force = true;

            logger.Info("Deleting search collection: " + CollectionName);
            SearchCollectionListXml list = new SearchCollectionListXml();
            XmlElement results;
            SearchCollectionIndexerStop stopIndex = new SearchCollectionIndexerStop();

            try
            {
                if (isInRepo("vse-collection", CollectionName, auth, url))
                {
                    service.SearchCollectionDelete(sd);
                }
                list.authentication = auth;
                results = service.SearchCollectionListXml(list);
                logger.Info("SearchCollectionList: " + results.InnerXml.ToString());
                Assert.IsTrue(results.InnerXml.ToString().Contains(CollectionName) == false,
                    "Search Collection delete failed: " + CollectionName);
            }

            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
            }
        }
        public static void HandleSoapException(SoapException se)
        {
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("SoapException Details: " + se.Code);
            logger.Info("SoapException Message: " + se.Message);
            logger.Info("Additional Info: " + se.Detail.InnerXml.ToString());
            if (se.Message.Contains("is terminating and cannot process this request") == true ||
                se.Message.Contains("Cannot enqueue to a collection when its crawler is terminating") == true ||
                se.Message.Contains("was started to service a search request, but was immediately stopped to service other requests") == true)
            {
                return;
            }
            else
            {
                Assert.Fail("SoapException caught: " + se.Message);
            }
        }

        public static XmlElement ReadXmlFile(string path)
        {
            XmlElement element;
            XmlDocument doc = new XmlDocument();

            doc.Load(path);
            element = doc.DocumentElement;
            return element;

        }

        public static void UpdateCollection(XmlElement Node, authentication auth, string s)
        {
            // Variables
            VelocityService service = new VelocityService();
            RepositoryUpdate update = new RepositoryUpdate();
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            logger.Info("Updating repository.");
            service.Url = s;
            update.authentication = auth;
            update.node = Node;
            service.RepositoryUpdate(update);

        }

    }
}
