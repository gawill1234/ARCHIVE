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


/* AnnotationReturnValueTests
 *
 * This class was written to test the behavior of the Annotation functions
 * on the .NET bindings.  It was reported in Defect 39453 that several of
 * the Annotation* functions were returning XML nodes, despite being declared
 * as void functions in the documentation.  When these functions were run
 * using the C# SOAP bindings, an error was occuring when the response
 * packet from Velocity was deserialized and the unexpected XML was run
 * into.  These regression tests were written to ensure that the changes
 * introducted to fix #39453 leave the Annotation API functionality intact.
 *
 * The tests cover the default behavior for the following API functions:
 *      AnnotationExpressGlobalSetDocList
 *      AnnotationExpressUserSetDocList
 *      AnnotationGlobalSet
 *      AnnotationPermissions
 *      AnnotationUserSet
 *
 * The AnnotationReturnValuesTests class consists of one method/Test for
 * each API function.  Each test "passes" if the API function does its job
 * (i.e. adds an annotation, updates an existing annotation, returns
 * user permissions, etc.) without raising an exception or error (such as
 * the Deserialization error mentioned by customers in Defect 39453).
 */


namespace APITests
{
    [TestFixture]
    class AnnotationReturnValuesTests
    {

        // Variables
        string username = ConfigurationManager.AppSettings.Get("username");
        string password = ConfigurationManager.AppSettings.Get("password");
        string serverlist = ConfigurationManager.AppSettings.Get("serverlist");
        authentication auth = new authentication();
        string acl = "+nt authority\\authenticated users";
        string[] servers;

        // Set up root 'service' of SOAP API
        VelocityService service = new VelocityService();


        [Test]
        public void TestAnnotationReturnValues_AnnotationExpressGlobalSetDocList()
        {
            InitMemberVariables();
            //Test Specific Variables
            string collectionName = "AnnotationExpressGlobalSetDocList_Test_SC";
            string collectionBaseName = "example-metadata";
            string annoName = "AnnotationExpressGlobalSetDocList_Test_Annotation";
            string annoVal = "AnnotationDExpressGlobalSetDocList_Test_Value";

            //Set up log structures
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAnnotationReturnValues_AnnotationExpressGlobalSetDocList Server: " + s);
                try
                {
                    TestUtilities.CreateSearchCollectionWithBase(collectionName, collectionBaseName, auth, s);

                    // Start the Crawler and Indexer
                    StartCrawlAndIndex(collectionName, auth);

                    //Get Vse Keys from initialized Search Collection
                    string doc1VseKey = GetDocVseKey(collectionName, 0);
                    string doc2VseKey = GetDocVseKey(collectionName, 1);

                    //Prepare the AnnotationExpressDocList API call
                    AnnotationExpressGlobalSetDocList annoGlobalList = CreateAnnotationExpressGlobalSetDocList(collectionName, annoName, annoVal, doc1VseKey, doc2VseKey);

                    //Run the API call
                    service.AnnotationExpressGlobalSetDocList(annoGlobalList);

                    //Check that the annotations have been added
                    bool exists = DoesAnnotationExist(collectionName, annoName, annoVal, doc1VseKey);
                    Assert.IsTrue(exists, "Annotation wasn't added to document: " + doc1VseKey);
                    exists = DoesAnnotationExist(collectionName, annoName, annoVal, doc2VseKey);
                    Assert.IsTrue(exists, "Annotation wasn't added to document: " + doc2VseKey);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                    Assert.Fail("AnnotationExpressGlobalSetDocList raised SOAP exception");
                }
                catch (Exception e)
                {
                    string temp = e.ToString() + ": " + e.Message;
                    logger.Info(temp);
                    Assert.Fail("AnnotationExpressGlobalSetDocList raised exception");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collectionName, auth, s);
                    TestUtilities.DeleteSearchCollection(collectionName, auth, s);
                }
            }

        }


        [Test]
        public void TestAnnotationReturnValues_AnnotationExpressUserSetDocList()
        {
            InitMemberVariables();
            //Test Specific Variables
            string collectionName = "AnnotationExpressUserSetDocList_Test_SC";
            string collectionBaseName = "example-metadata";
            string annoName = "AnnotationExpressUserSetDocList_Test_Annotation";
            string annoVal = "AnnotationExpressUserSetDocList_Test_Value";

            // Set up log structures
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAnnotationReturnValues_AnnotationExpressUserSetDocList Server: " + s);
                try
                {
                    TestUtilities.CreateSearchCollectionWithBase(collectionName, collectionBaseName, auth, s);

                    // Start the Crawler and Indexer
                    StartCrawlAndIndex(collectionName, auth);

                    //Get Vse Keys from initialized search collection
                    string doc1VseKey = GetDocVseKey(collectionName, 0);
                    string doc2VseKey = GetDocVseKey(collectionName, 1);

                    //Prepare an API Call object
                    AnnotationExpressUserSetDocList annoUserSet = CreateAnnotationExpressUserSetDocList(collectionName, annoName, annoVal, doc1VseKey, doc2VseKey);
                    service.AnnotationExpressUserSetDocList(annoUserSet);

                    //Check that the annotations were added on the docs
                    bool exists = DoesAnnotationExist(collectionName, annoName, annoVal, doc1VseKey);
                    Assert.IsTrue(exists, "Annotation was not added to document: " + doc1VseKey);
                    exists = DoesAnnotationExist(collectionName, annoName, annoVal, doc2VseKey);
                    Assert.IsTrue(exists, "Annotation was not added to document: " + doc2VseKey);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                    Assert.Fail("AnnotationExpressUserSetDocList raised SOAP exception");
                }
                catch (Exception e)
                {
                    string temp = e.ToString() + ": " + e.Message;
                    logger.Info(temp);
                    Assert.Fail("AnnotationExpressUserSetDocList raised exception");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collectionName, auth, s);
                    TestUtilities.DeleteSearchCollection(collectionName, auth, s);
                }
            }

        }

        [Test]
        public void TestAnnotationReturnValues_AnnotationGlobalSet()
        {
            InitMemberVariables();
            // Test Specific Variables
            string collectionName = "AnnotationGlobalSet_Test_SC";
            string collectionBaseName = "example-metadata";
            string annoName = "AnnotationGlobalSet_Test_Annotation";
            string annoVal = "AnnotationGlobalSet_Test_Value";

            // Set up log structures
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAnnotationReturnValues_AnnotationGlobalSet Server: " + s);
                try
                {
                    TestUtilities.CreateSearchCollectionWithBase(collectionName, collectionBaseName, auth, s);

                    // Start the Crawler and Indexer
                    StartCrawlAndIndex(collectionName, auth);

                    //Get Vse Key from initialized crawler
                    string docVseKey = GetDocVseKey(collectionName, 0);

                    //Prepare API Call to set global anno
                    AnnotationGlobalSet annoGlobal = CreateAnnotationGlobalSet(collectionName, annoName, annoVal, docVseKey);

                    //Run the API Call
                    service.AnnotationGlobalSet(annoGlobal);

                    //Check that the Annotations have been set.
                    bool exists = DoesAnnotationExist(collectionName, annoName, annoVal, docVseKey);
                    Assert.IsTrue(exists, "Annotation was not added to document: " + docVseKey);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                    Assert.Fail("AnnotationGlobalSet raised SOAP exception");
                }
                catch (Exception e)
                {
                    string temp = e.ToString() + ": " + e.Message;
                    logger.Info(temp);
                    Assert.Fail("AnnotationGlobalSet raised exception");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collectionName, auth, s);
                    TestUtilities.DeleteSearchCollection(collectionName, auth, s);
                }
            }

        }

        [Test]
        public void TestAnnotationReturnValues_AnnotationPermissions()
        {
            InitMemberVariables();
            // Test Specific Variables
            string collectionName = "AnnotationDelete_Test_SC";
            string collectionBaseName = "example-metadata";

            // Set up log structures
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAnnotationReturnValues_AnnotationPermissions Server: " + s);
                try
                {
                    TestUtilities.CreateSearchCollectionWithBase(collectionName, collectionBaseName, auth, s);

                    // Start the Crawler and Indexer
                    StartCrawlAndIndex(collectionName, auth);

                    //Prepare the API Call
                    //For this API call, a Create* method wasn't necessary, because it requires few params
                    AnnotationPermissions annoPerm = new AnnotationPermissions();
                    annoPerm.authentication = auth;
                    annoPerm.username = username;

                    //Run API call requesting permissions
                    string permStr = service.AnnotationPermissions(annoPerm);
                    logger.Info("Permissions Returned: "+permStr);

                    Assert.IsTrue(permStr.Contains(annoPerm.username),"Permissions string seems invalid: doesn't contain username.");
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                    Assert.Fail("AnnotationPermissions raised SOAP exception");
                }
                catch (Exception e)
                {
                    string temp = e.ToString() + ": " + e.Message;
                    logger.Info(temp);
                    Assert.Fail("AnnotationPermissions raised exception");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collectionName, auth, s);
                    TestUtilities.DeleteSearchCollection(collectionName, auth, s);
                }
            }

        }

        [Test]
        public void TestAnnotationReturnValues_AnnotationUserSet()
        {
            InitMemberVariables();
            // Test Specific Variables
            string collectionName = "AnnotationUserSet_Test_SC";
            string collectionBaseName = "example-metadata";
            string annoName = "AnnotationUserSet_Test_Annotation";
            string annoVal = "AnnotationUserSet_Test_Value";

            //Set up log structures
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();

            GetServers();
            foreach (string s in servers)
            {
                service.Url = s;
                logger.Info("Test: TestAnnotationReturnValues_AnnotationUserSet Server: " + s);
                try
                {
                    TestUtilities.CreateSearchCollectionWithBase(collectionName, collectionBaseName, auth, s);

                    // Start the Crawler and Indexer
                    StartCrawlAndIndex(collectionName, auth);

                    //Get vse key info from initialized crawler
                    string docVseKey = GetDocVseKey(collectionName, 0);

                    //Prepare the AnnotationUserSet API Call
                    AnnotationUserSet annoUser = CreateAnnotationUserSet(collectionName, annoName, annoVal, docVseKey);

                    //Run the API Call
                    service.AnnotationUserSet(annoUser);

                    //Check that the annotation was added to the document
                    bool exists = DoesAnnotationExist(collectionName, annoName, annoVal, docVseKey);
                    Assert.IsTrue(exists, "Annotation was not added to document: " + docVseKey);
                }
                catch (SoapException se)
                {
                    TestUtilities.HandleSoapException(se);
                    Assert.Fail("AnnotationUserSet raised SOAP exception");
                }
                catch (Exception e)
                {
                    string temp = e.ToString() + ": " + e.Message;
                    logger.Info(temp);
                    Assert.Fail("AnnotationUserSet raised exception");
                }
                finally
                {
                    TestUtilities.StopCrawlAndIndex(collectionName, auth, s);
                    TestUtilities.DeleteSearchCollection(collectionName, auth, s);
                }
            }

        }


        ///////////////////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////////////////
        //Helper Methods/Functions

        private void InitMemberVariables()
        {
            GetServers();//Init the 'servers' member var
            InitAuthentication();//Init the 'auth' member var
        }

        // Get servers to run tests on
        private void GetServers()
        {
            this.servers = serverlist.Split(',');
        }

        // Give a username and password to the authentication object
        public void InitAuthentication()
        {
            this.auth.username=this.username;
            this.auth.password=this.password;

        }

        private AnnotationExpressGlobalSetDocList CreateAnnotationExpressGlobalSetDocList(string collectionName, string annoName, string annoVal, string doc1VseKey, string doc2VseKey)
        {
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();
            logger.Info("Entered CreateAnnotationExpressGlobalSetDocList");

            //Provide params for AnnotationExpressGlobalSetDocList call
            AnnotationExpressGlobalSetDocList annoSet = new AnnotationExpressGlobalSetDocList();
            annoSet.authentication = auth;
            annoSet.collection = collectionName;
            annoSet.subcollection = AnnotationExpressGlobalSetDocListSubcollection.live;
            annoSet.content = new AnnotationExpressGlobalSetDocListContent();
            annoSet.content.content = new content[1];
            annoSet.content.content[0] = new content();
            annoSet.content.content[0].name = annoName;
            annoSet.content.content[0].Value = annoVal;
            annoSet.documents = new AnnotationExpressGlobalSetDocListDocuments();
            annoSet.documents.document = new document[2];
            annoSet.documents.document[0] = new document();
            annoSet.documents.document[0].vsekey = doc1VseKey;
            annoSet.documents.document[1] = new document();
            annoSet.documents.document[1].vsekey = doc2VseKey;
            annoSet.username = username;
            annoSet.acl = acl;

            logger.Info("Leaving CreateAnnotationExpressGlobalSetDocList");
            return annoSet;
        }

        private AnnotationExpressUserSetDocList CreateAnnotationExpressUserSetDocList(string collectionName, string annoName, string annoVal, string doc1VseKey, string doc2VseKey)
        {
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();
            logger.Info("Entered CreateAnnotationExpressUserSetDocList");

            //Add parameters for AnnotationExpressUserSetDocList API Call
            AnnotationExpressUserSetDocList annoSet = new AnnotationExpressUserSetDocList();
            annoSet.authentication = auth;
            annoSet.collection = collectionName;
            annoSet.subcollection = AnnotationExpressUserSetDocListSubcollection.live;
            annoSet.content = new AnnotationExpressUserSetDocListContent();
            annoSet.content.content = new content[1];
            annoSet.content.content[0] = new content();
            annoSet.content.content[0].name = annoName;
            annoSet.content.content[0].Value = annoVal;
            annoSet.documents = new AnnotationExpressUserSetDocListDocuments();
            annoSet.documents.document = new document[2];
            annoSet.documents.document[0] = new document();
            annoSet.documents.document[0].vsekey = doc1VseKey;
            annoSet.documents.document[1] = new document();
            annoSet.documents.document[1].vsekey = doc2VseKey;
            annoSet.username = username;
            annoSet.acl = acl;

            logger.Info("Leaving CreateAnnotationExpressUserSetDocList");
            return annoSet;
        }

        private AnnotationGlobalSet CreateAnnotationGlobalSet(string collectionName, string annoName, string annoVal, string docVseKey)
        {
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();
            logger.Info("Entered CreateAnnotationGlobalSet");

            //Add parameters for AnnotationGlobalSet function call
            AnnotationGlobalSet annoSet = new AnnotationGlobalSet();
            annoSet.authentication = auth;
            annoSet.collection = collectionName;
            annoSet.subcollection = AnnotationGlobalSetSubcollection.live;
            annoSet.content = new AnnotationGlobalSetContent();
            annoSet.content.content = new content[1];
            annoSet.content.content[0] = new content();
            annoSet.content.content[0].name = annoName;
            annoSet.content.content[0].Value = annoVal;
            annoSet.documentvsekey = docVseKey;
            annoSet.username = username;
            annoSet.acl = acl;

            logger.Info("Leaving CreateAnnotationGlobalSet");
            return annoSet;
        }

        private AnnotationUserSet CreateAnnotationUserSet(string collectionName, string annoName, string annoVal, string docVseKey)
        {
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();
            logger.Info("Entered CreateAnnotationUserSet");

            //Add parameters for AnnotationUserSet API Call
            AnnotationUserSet annoSet = new AnnotationUserSet();
            annoSet.authentication = auth;
            annoSet.collection = collectionName;
            annoSet.subcollection = AnnotationUserSetSubcollection.live;
            annoSet.content = new AnnotationUserSetContent();
            annoSet.content.content = new content[1];
            annoSet.content.content[0] = new content();
            annoSet.content.content[0].name = annoName;
            annoSet.content.content[0].Value = annoVal;
            annoSet.documentvsekey = docVseKey;
            annoSet.username = username;
            annoSet.acl = acl;

            logger.Info("Leaving CreateAnnotationUserSet");
            return annoSet;
        }

        private string GetDocVseKey(string collectionName,int docNum)
        {
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();
            logger.Info("Entering GetDocVseKey");

            //Prepare query
            QuerySearch search = new QuerySearch();
            search.authentication = auth;
            search.sources = collectionName;
            search.num = 100;
            QuerySearchResponse response = new QuerySearchResponse();

            // Run Query on SearchCollection
            try
            {
                response = service.QuerySearch(search);
                // Wait until response is fully constructed
                WaitUntilListExists(response);
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
                logger.Info("Soap Exception occurred: " + se.ToString() + ": " + se.Message);
                Assert.Fail("Cannot obtain Vse-Key of any documents in collection.");
            }


            //Return DocVseKey if we find enough docs in the collection
            int totalDocs = response.queryresults.list.document.Length;
            logger.Info("Search returned " + totalDocs + " doc(s)");
            if (totalDocs > docNum)
            {
                logger.Info("Found doc-vse-key..leaving GetDocVseKey");
                return response.queryresults.list.document[docNum].vsekey;
            }
            else
            {
                logger.Info("No documents found in collection..leaving GetDocVseKey");
                Assert.Fail("Cannot obtain Vse-Key: not enough documents in search collection.");
                return "";
            }
        }

        private bool DoesAnnotationExist(string collectionName, string annoName, string annoVal, string docVseKey)
        {

            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();
            logger.Info("Entering DoesAnnotationExist");
            QuerySearch search = new QuerySearch();
            search.authentication = auth;
            search.sources = collectionName;
            search.num = 100;
            QuerySearchResponse response = new QuerySearchResponse();
            // Run Query on SearchCollection
            try
            {
                response = service.QuerySearch(search);
                // Wait until response is fully constructed
                WaitUntilListExists(response);
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
                logger.Info("Soap Exception occurred: " + se.ToString() + ": " + se.Message);
                Assert.Fail("Search for Annotation failed..cannot determine if annotation exists");
            }


            // Iterate through the content tags for each document, until Annotation is (hopefully) found */
            logger.Info("Search returned " + response.queryresults.list.document.Length + " doc(s)");
            int docCount = 0;
            foreach (document d in response.queryresults.list.document)
            {
                logger.Info("Examining document number: " + docCount);
                logger.Info("Document Key is: "+d.vsekey);
                docCount++;

                // "This is not the VseKey you're looking for"...ignore document
                if(d.vsekey.Equals(docVseKey,StringComparison.OrdinalIgnoreCase)==false)
                    continue;

                // Ignore the document if it doesnt have any content nodes
                if (d.content == null || d.content.Length == 0)
                    continue;

                logger.Info("The document has " + d.content.Length + " contents");
                int contentCount = 0;
                foreach (content c in d.content)
                {
                    logger.Info("Examining content number: " + contentCount);
                    contentCount++;

                    logger.Info("contents name is " + c.name);

                    // If we find the annotation we tried to add above
                    if (c.name.Equals(annoName, StringComparison.OrdinalIgnoreCase) &&
                            c.Value.Contains(annoVal))
                    {
                        logger.Info("contents value is " + c.Value);
                        return true;
                    }
                }
            }

            logger.Info("Leaving DoesAnnotationExist");
            return false;
        }

        private void StartCrawlAndIndex(string collectionName, authentication auth)
        {
            // Initialize logging structures
            log4net.ILog logger = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
            log4net.Config.XmlConfigurator.Configure();
            logger.Info("Entered StartCrawlAndIndex");

            // Initialize Start objeicts for the Crawler and Indexer
            SearchCollectionCrawlerStart cStart = new SearchCollectionCrawlerStart();
            cStart.collection = collectionName;
            cStart.authentication = auth;
            SearchCollectionIndexerStart iStart = new SearchCollectionIndexerStart();
            iStart.collection = collectionName;
            iStart.authentication = auth;

            try
            {
                // Start the Crawler and Indexer
                TestUtilities.StartCrawlandWait(collectionName, auth, service.Url);
                service.SearchCollectionIndexerStart(iStart);
            }
            catch (SoapException se)
            {
                TestUtilities.HandleSoapException(se);
                logger.Info("Caught SoapException: " + se.ToString() + ": " + se.Message);
                Assert.Fail("Could not start the Crawler/Indexer");
            }
            logger.Info("Leaving StartCrawlAndIndex");
        }

        // When retrieving search results using the QuerySearchResponse
        // I was getting NullPointerExceptions when accessing fields in the
        // QuerySearchResponse object.  I suspect that the object was being
        // filled with the XML results of the query asyncronously (on a different thread)
        // and I was accessing fields before they were initialized.  This method
        // lets me wait until the field I was using (List) is fully initialized
        public void WaitUntilListExists(QuerySearchResponse response)
        {
            while (true)
            {
                if (response.queryresults.list != null)
                    return;
                System.Threading.Thread.Sleep(1000);
            }
        }
    }
}
