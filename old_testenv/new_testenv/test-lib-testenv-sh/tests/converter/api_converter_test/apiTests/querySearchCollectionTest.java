package apiTests;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import helperFunctions.XMLReader;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;
 
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

import velocity.objects.Document;


import apiFunctions.SearchCollection;
 

@RunWith(value = Parameterized.class)
public class querySearchCollectionTest {
	
	// global variables
	
	public static  SearchCollection sc;	
	
	// parameterized variables 
	String query;
	String expectedDoc;
	@BeforeClass
	public static void setupTest() throws Exception {
	String USER_NAME = "test-all";
	String PASSWORD = "P@$$word#1?";
    String BASE_URL = null;
	String COLLECTION = "sc-doc-test";
   
	
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

		
 
	 public querySearchCollectionTest(String _q, String data) {
	   query=_q;
	   expectedDoc=data;
	 }
 
	 @Parameters
	 public static Collection<Object[]> data() {
		 String filePath="input/testinput.xml";
			XMLReader r = new XMLReader();
			r.readXML(filePath);
			List<String[][]> in=r.testInput;
			 Object[][] data=  new Object[in.size()][2];
		for(int i=0;i<in.size();i++){
			data[i][0]=in.get(i)[0][0];
			data[i][1]=in.get(i)[0][1];
		}
			
	   
	   return Arrays.asList(data);
	 }
 
	 @Test
	 public void pushTest() throws Exception {
	   System.out.println("Parameterized query is : " + query);
	   System.out.println("Parameterized expectedDoc is : " + expectedDoc);
	  try{ 
	  List<Document> result=sc.query_collection(query);
	  assertTrue(verifyResult(expectedDoc, result));
	  }catch(IllegalArgumentException e){
		  fail("No query results");
	  }
	  
	
	  
	  
	 }



	private boolean verifyResult(String expectedDoc2, List<Document> result) {
		// TODO Auto-generated method stub
		for(Document d:result){
			System.out.println("d.getUrl(): " +d.getUrl());
			if(d.getUrl().toLowerCase().contains(expectedDoc.toLowerCase())){
				return true;
			}
			
		}
		return false;
	}
 
 
}
