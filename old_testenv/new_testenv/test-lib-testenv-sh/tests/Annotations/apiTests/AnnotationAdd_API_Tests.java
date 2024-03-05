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

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.net.MalformedURLException;

import javax.xml.soap.Detail;
import javax.xml.soap.SOAPFault;
import javax.xml.ws.soap.SOAPFaultException;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;

import velocity.VelocityPort;
import velocity.objects.Content;
import velocity.objects.Document;
import velocity.types.AnnotationAdd;
import apiFunctions.APIFunction;
import apiFunctions.Collection;

public class AnnotationAdd_API_Tests {
	// global variables
	public static String USER_NAME = "test-all";
	public static String PASSWORD = "P@$$word#1?";
	public static String BASE_URL = null;
	public static String COLLECTION = "example-metadata";
	public static String QUERY = "car";
	public static int count = 1;
	
	
	@BeforeClass
	public static void setupTest() throws MalformedURLException {

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
			port = "80"; // default is port 80
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
		
		Collection c= new Collection(BASE_URL, COLLECTION, USER_NAME, PASSWORD, true);
		c.deleteSearchCollection();
		c.startSearchCollection();
		c.waitForCrawlComplete();
	}

	
	/**
	 * Test Exceptions
	 * 
	 * @throws Exception
	 */
	@Test
	public void test_addAnnotations_SearchCollection_missing() throws Exception {
		String annotationName = "tags";
		String annotationValue = "newTag"+count++;

		int docIndex = 1;
		String missing_collection_error = "Required variable collection has not been passed when resolving the reference";

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

		AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName, annotationValue, docIndex);
		my_annotation.setCollection(null);

		VelocityPort p = f.getVelocityPort();
		try {
			p.annotationAdd(my_annotation);
			fail("Test fails as no exception is thrown for incorrect non existing collection name: "
					+ my_annotation.getCollection());
		} catch (SOAPFaultException sfe) {
			SOAPFault sf = sfe.getFault();
			Detail d = sf.getDetail();

			String failureMsg = "expected msg: " + missing_collection_error + "\n actual message " + d.getTextContent();
			assertTrue(failureMsg, d.getTextContent().contains(missing_collection_error));

		}

	}

	@Test
	public void test_addAnnotations_VSEKey_missing() throws Exception {
		String annotationName = "tags";
		String annotationValue = "newTag"+count++;

		int docIndex = 1;
		String missing_VSE_KEY_error = "Required variable document-vse-key has not been passed when resolving the reference";

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);
		AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName, annotationValue, docIndex);

		// get vse_key
		my_annotation.setDocumentVseKey(null);

		VelocityPort p = f.getVelocityPort();

		try {
			p.annotationAdd(my_annotation);
			fail("Test fails as no exception is thrown for incorrect non existing collection name : "
					+ my_annotation.getCollection());
		} catch (SOAPFaultException sfe) {
			SOAPFault sf = sfe.getFault();
			Detail d = sf.getDetail();

			String failureMsg = "expected msg: " + missing_VSE_KEY_error + "\n actual message " + d.getTextContent();
			assertTrue(failureMsg, d.getTextContent().contains(missing_VSE_KEY_error));

		}

	}

	@Test
	public void test_addAnnotations_contentMissing() throws Exception {
		String annotationName = "tags";
		String annotationValue = "newTag"+count++;
		int docIndex = 1;
		String missing_content_error = "Required variable content has not been passed when resolving the reference";

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

		AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName, annotationValue, docIndex);
		my_annotation.setContent(null);

		VelocityPort p = f.getVelocityPort();
		try {
			p.annotationAdd(my_annotation);
			fail("Test fails as no exception is thrown for incorrect non existing collection name: "
					+ my_annotation.getCollection());
		} catch (SOAPFaultException sfe) {
			SOAPFault sf = sfe.getFault();
			Detail d = sf.getDetail();

			String failureMsg = "expected msg: " + missing_content_error + "\n actual message " + d.getTextContent();
			assertTrue(failureMsg, d.getTextContent().contains(missing_content_error));

		}

	}

	@Test
	public void test_addAnnotations_usernameMissing() throws Exception {
		String annotationName = "tags";
		String annotationValue = "newTag"+count++;
		int docIndex = 1;
		String missing_username_error = "Required variable username has not been passed when resolving the reference";

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

		AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName, annotationValue, docIndex);
		my_annotation.setUsername(null);

		VelocityPort p = f.getVelocityPort();
		try {
			p.annotationAdd(my_annotation);
			fail("Test fails as no exception is thrown for incorrect non existing collection name: "
					+ my_annotation.getCollection());
		} catch (SOAPFaultException sfe) {
			SOAPFault sf = sfe.getFault();
			Detail d = sf.getDetail();

			String failureMsg = "expected msg: " + missing_username_error + "\n actual message " + d.getTextContent();
			assertTrue(failureMsg, d.getTextContent().contains(missing_username_error));

		}

	}

	@Test
	public void test_addAnnotations_ACLMissing() throws Exception {
		String annotationName = "tags";
		String annotationValue = "newTag"+count++;
		int docIndex = 1;
		String missing_ACL_error = "Required variable acl has not been passed when resolving the reference";

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

		AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName, annotationValue, docIndex);
		my_annotation.setAcl(null);

		VelocityPort p = f.getVelocityPort();
		try {
			p.annotationAdd(my_annotation);
			fail("Test fails as no exception is thrown for incorrect non existing collection name: "
					+ my_annotation.getCollection());
		} catch (SOAPFaultException sfe) {
			SOAPFault sf = sfe.getFault();
			Detail d = sf.getDetail();

			String failureMsg = "expected msg: " + missing_ACL_error + "\n actual message " + d.getTextContent();
			assertTrue(failureMsg, d.getTextContent().contains(missing_ACL_error));

		}

	}




	/**
	 * Test with valid values
	 * 
	 * @throws Exception
	 * 
	 */

	@Test
	public void test_addAnnotations_valid() throws Exception {
		String annotationName = "tags";
		String annotationValue = "newTag"+count++;

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);
		Document result = f.addAnnotation(annotationName, annotationValue, 3);
		boolean verify = f.verifyAnnotation(result, annotationName, annotationValue);
		String failureMsg = "Expected Annotation" + annotationName + " value" + annotationValue + " for doc: "
				+ result.getVseKey() + "was not added";
		assertTrue(failureMsg, verify);

	}
  

	@Test
	public void test_addAnnotations_AnnotationMultipleContent() throws Exception {
		String annotationName1 = "tags1";
		String annotationValue1 = "newTag"+count++;
		String annotationName2 = "tags2";
		String annotationValue2 = "newTag"+count++;
		int docIndex = 1;

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

		AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName1, annotationValue1, docIndex);
		// add multiple contents
		AnnotationAdd.Content content = new AnnotationAdd.Content();

		Content c1 = new Content();
		content.getContent().add(c1);
		c1.setName(annotationName1);
		c1.setValue(annotationValue1);
		c1.setAcl("v.testall");
		c1.setExecuteAcl("true");

		Content c2 = new Content();
		content.getContent().add(c2);
		c2.setName(annotationName2);
		c2.setValue(annotationValue2);

		my_annotation.setContent(content);

		// create velocity port and add annotation
		VelocityPort p = f.getVelocityPort();
		p.annotationAdd(my_annotation);

		// get the VSE key of the document to verify results
		Document result = new Document();
		result.setVseKey(my_annotation.getDocumentVseKey());

		boolean verify = f.verifyAnnotation(result, annotationName1, annotationValue1);
		String failureMsg = "Expected Annotation" + annotationName1 + " value" + annotationValue1 + " for doc: "
				+ result.getVseKey() + "was not added";
		assertTrue(failureMsg, verify);

		boolean verify2 = f.verifyAnnotation(result, annotationName2, annotationValue2);
		String failureMsg2 = "Expected Annotation" + annotationName2 + " value" + annotationValue2 + " for doc: "
				+ result.getVseKey() + "was not added";
		assertTrue(failureMsg2, verify2);
	}

	@Test
	public void test_addAnnotations_valid_ratings() throws Exception {
		String annotationName = "rate";
		String annotationValue = "+count++";

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);
		Document result = f.addAnnotation(annotationName, annotationValue, 0);
		boolean verify = f.verifyAnnotation(result, annotationName, annotationValue);
		String failureMsg = "Expected Annotation: " + annotationName + " value: " + annotationValue + " for doc: "
				+ result.getVseKey() + "was not added";
		assertTrue(failureMsg, verify);

	}

	

	@Test
	public void test_addAnnotations_NoDocuments() throws Exception {
		String annotationName1 = "tags1";
		String annotationValue1 = "newTag"+count++;

		int docIndex = 200; // there are not these many documents

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

		try {
			f.addAnnotation(annotationName1, annotationValue1, docIndex);
			fail("Test fails as no exception is thrown when no document exists at index: " + docIndex);
		} catch (IllegalArgumentException e) {

			String expectedException = "Collection: " + f.getCollection() + " query: " + f.getQuery() + " url: "
					+ f.getBase_url() + " No Documents at index: " + docIndex;
			String failureMsg = "expected msg: " + expectedException + "\n actual message " + e.getMessage();
			assertTrue(failureMsg, e.getMessage().contains(expectedException));

		}

	}
	
	
	// negative tests
	
	
	 @Ignore
		// need more information on how to test execute rights
		@Test
		public void test_addAnnotations_ExecuteRights() throws Exception {
			String annotationName1 = "tags1";
			String annotationValue1 = "newTag" + count++;

			int docIndex = 2;

			APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

			try {
				f.addAnnotation(annotationName1, annotationValue1, docIndex);
				fail("Test fails as no exception is thrown for incorrect rights ");
			} catch (SOAPFaultException sfe) {
				String expectedException = "The exception [rights-execute] was thrown";
				String failureMsg = "expected msg: " + expectedException + "\n actual message " + sfe.getMessage();
				assertTrue(failureMsg, sfe.getMessage().contains(expectedException));

			}

		}
	 
		/**
		 * Test for invalid values For non existing values request is processed but no exception is thrown. If the search
		 * collection doesn't exists nothing gets updated.
		 */
	    @Ignore // need to understand better how invalid values are suppose to be handled
		@Test
		public void test_addAnnotations_contentIncorrect() throws Exception {
			String annotationName = "tags";
			String annotationValue = "newTag"+count++;
			int docIndex = 1;
			String incorrect_content_error = ""; // update the message

			APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

			AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName, annotationValue, docIndex);

			AnnotationAdd.Content content = my_annotation.getContent();
			// incorrect contents
			content.getContent().clear();
			Content c1 = new Content();
			content.getContent().add(c1);
			c1.setName("<name=test>");
			c1.setValue("</>");
			c1.setExecuteAcl("true");
			c1.setAcl(USER_NAME);
			my_annotation.setContent(content);

			VelocityPort p = f.getVelocityPort();

			try {
				p.annotationAdd(my_annotation);
				fail("Test fails as no exception is thrown for incorrect content: "
						+ my_annotation.getContent().getContent().get(0));
			} catch (SOAPFaultException sfe) {
				SOAPFault sf = sfe.getFault();
				Detail d = sf.getDetail();

				String failureMsg = "expected msg: " + incorrect_content_error + "\n actual message " + d.getTextContent();
				assertTrue(failureMsg, d.getTextContent().contains(incorrect_content_error));

			}

		}

		@Ignore
		// need more information on behavior of this test
		@Test
		public void test_addAnnotations_usernameIncorrect() throws Exception {
			String annotationName = "tags";
			String annotationValue = "newTag"+count++;
			int docIndex = 1;
			String invalid_username_error = "Required variable username has not been passed when resolving the reference";

			APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

			AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName, annotationValue, docIndex);
			my_annotation.setUsername("xxxxxx"); // non existing user name

			VelocityPort p = f.getVelocityPort();
			try {
				p.annotationAdd(my_annotation);
				fail("Test fails as no exception is thrown for incorrect/non existing username: "
						+ my_annotation.getUsername());
			} catch (SOAPFaultException sfe) {
				SOAPFault sf = sfe.getFault();
				Detail d = sf.getDetail();

				String failureMsg = "expected msg: " + invalid_username_error + "\n actual message " + d.getTextContent();
				assertTrue(failureMsg, d.getTextContent().contains(invalid_username_error));

			}

		}

		@Ignore
		// need more information on behavior of this test
		@Test
		public void test_addAnnotations_ACLInCorrect() throws Exception {
			String annotationName = "tags";
			String annotationValue = "newTag"+count++;
			int docIndex = 1;
			String invalid_ACL_error = "Required variable acl has not been passed when resolving the reference";

			APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

			AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName, annotationValue, docIndex);
			my_annotation.setAcl("v.xxx");

			VelocityPort p = f.getVelocityPort();
			try {
				p.annotationAdd(my_annotation);
				fail("Test fails as no exception is thrown for incorrect/non existing ACL value: " + my_annotation.getAcl());
			} catch (SOAPFaultException sfe) {
				SOAPFault sf = sfe.getFault();
				Detail d = sf.getDetail();

				String failureMsg = "expected msg: " + invalid_ACL_error + "\n actual message " + d.getTextContent();
				assertTrue(failureMsg, d.getTextContent().contains(invalid_ACL_error));

			}

		}
		/**
		 * Test for invalid values For non existing values request is processed but no exception is thrown. If the search
		 * collection doesn't exists nothing gets updated.
		 */
	    @Ignore // need to understand better how invalid values are suppose to be handled
		@Test
		public void test_addAnnotations_SearchCollectionNonExisting() // no exception is thrown
				throws Exception {
			String annotationName = "tags";
			String annotationValue = "newTag"+count++;
			int docIndex = 1;

			APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);

			AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName, annotationValue, docIndex);
			my_annotation.setCollection("xxxxx");

			VelocityPort p = f.getVelocityPort();
			try {
				p.annotationAdd(my_annotation);

			} catch (SOAPFaultException sfe) {
				fail("Test fails exception is thrown for incorrect/non existing collection name: "
						+ my_annotation.getCollection());

			}

		}

		/**
		 * Test for invalid values For non existing values request is processed but no exception is thrown. If the search
		 * collection doesn't exists nothing gets updated.
		 */
	    @Ignore // need to understand better how invalid values are suppose to be handled
		@Test
		public void test_addAnnotations_VSEKeyInvalid() throws Exception {
			String annotationName = "tags";
			String annotationValue = "newTag"+count++;

			int docIndex = 1;

			APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);
			AnnotationAdd my_annotation = f.createAnnotationAddVar(annotationName, annotationValue, docIndex);

			// get vse_key
			my_annotation.setDocumentVseKey("xxxxx");

			VelocityPort p = f.getVelocityPort();

			try {
				p.annotationAdd(my_annotation);

			} catch (SOAPFaultException sfe) {
				fail("Test fails as exception is thrown for incorrect/ non existing vse-key name : "
						+ my_annotation.getDocumentVseKey());

			}

		}

}
