/**
 * @author pbhallamudi
 * @description tests the api function : annotation-add
 * @tests include : 
 * 1.Passing valid values and expecting success
 * 2.Missing search collection name, vse key,user name, acl, missing content
 * 3.Invalid/non existing values
 * 
 * @depends
 * 1.JUnit 4, APIFunction.java, CannotverifyResultException.java,Collection.java
 */

package apiTests;



import static org.junit.Assert.assertEquals;
import helperFunctions.SMB;
import org.junit.BeforeClass;
import org.junit.Test;
import apiFunctions.SearchCollection;

public class SearchCollectionTests {
	// global variables
	public static String USER_NAME = "test-all";
	public static String PASSWORD = "P@$$word#1?";
	public static String BASE_URL = null;
	public static String COLLECTION = "sc-doc-test";
	public static String QUERY = "jockey";
	public static int count = 1;
	public static SearchCollection sc;
	public static int expectedNoofIndexedDocuments=4;
	
	@BeforeClass
	public static void setupTest() throws Exception {
		
		InitializeTestParameters();

		String user = System.getenv("VIVUSER"); // get username
		if (user != null && !user.isEmpty()) {
			USER_NAME = user;
		}
		String password = System.getenv("VIVPW"); // get password
		if (password != null && !password.isEmpty()) {
			PASSWORD = password;
		}

		// set up base url
		String os = System.getenv("VIVTARGETOS");
		if (os == null || os.equalsIgnoreCase("")) {
			os = "win"; // default is windows
		}
		String host = System.getenv("VIVHOST");
		if (host == null || host.equalsIgnoreCase("")) {
			host = "127.0.0.1"; // default is local host ip
		}
		String port = System.getenv("VIVHTTPPORT");
		if (port == null || port.equalsIgnoreCase("")) {
			port = "9080"; // default is port 80
		}
		String virtualDir = System.getenv("VIVVIRTUALDIR");
		if (virtualDir == null || virtualDir.equalsIgnoreCase("")) {
			virtualDir = "vivisimo"; // default is dir is vivisimo
		}
		BASE_URL = "http://" + host + ":" + port + "/" + virtualDir + "/cgi-bin/";
		if (os.contains("win")) {
			BASE_URL = BASE_URL + "velocity.exe";
		} else {
			BASE_URL = BASE_URL + "velocity";
		}
		System.out.println("base url:" + BASE_URL);
		System.out.println("User Name:" + USER_NAME);
		System.out.println("PASSWORD:" + PASSWORD);
		
		sc= new SearchCollection(BASE_URL, COLLECTION, USER_NAME, PASSWORD, true);
		sc.searchServiceStart();
		sc.createSearchCollection();
		sc.setXMLSearchCollection("input/sc-doc-test.xml");
		sc.startSearchCollection();
		sc.waitForCrawlComplete();
	}

	
	private static void InitializeTestParameters() throws Exception {
		// TODO Auto-generated method stub
		 SMB smb= new SMB();
		
			expectedNoofIndexedDocuments= smb.noofFiles();
			if(expectedNoofIndexedDocuments<1){
				throw new Exception ("Test setup exception, no documents to search for");
			}
		
		
	}


	/**
	 * Test Exceptions
	 * 
	 * @throws Exception
	 */
	
	
	@Test
	public void No_crawler_error() throws Exception {
		assertEquals("failed : "+sc.searchCollectionCrawlError(),sc.searchCollectionCrawlError(),null);
	}
	
	@Test
	public void No_of_documents_crawled() throws Exception {
		assertEquals("failed incorrect no of document crawled  ",expectedNoofIndexedDocuments,sc.searchCollectionNoOfDocumentsIndexed());
	}






}
