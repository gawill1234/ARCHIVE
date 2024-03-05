package apiTests;
/**
 * @author pbhallamudi
 * @description tests the api function : annotation-update
 * @tests include : 
 * 1.Passing valid values and expecting success
 * 2. Failing to pass required parameter content-id and expecting exception/failure
 * @depends
 * 1.JUnit 4, APIFunction.java, CannotverifyResultException.java, Collection.java
 */


import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.net.MalformedURLException;


import javax.xml.soap.Detail;
import javax.xml.soap.SOAPFault;
import javax.xml.ws.soap.SOAPFaultException;

import org.junit.BeforeClass;
import org.junit.Test;

import velocity.VelocityPort;
import velocity.objects.Document;
import velocity.types.AnnotationUpdate;
import apiFunctions.APIFunction;
import apiFunctions.Collection;

public class Annotation_update_Tests {
	// global variables
	public static String USER_NAME = "test-all";
	public static String PASSWORD = "P@$$word#1?";
	public static String BASE_URL = null;
	public static String COLLECTION = "example-metadata";
	public static String QUERY = "jockey";
	public static int count=1;
	
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

	@Test
	public void test_annotation_update_valid() throws Exception {
		String annotationName = "tagsPushpa";
		String annotationPreviousValue = "newTag"+count++;
		String annotationUpdateValue = "update-"+annotationPreviousValue;
		int doc_index=1;

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);
		// first add annotation
		Document result = f.addAnnotation(annotationName, annotationPreviousValue, doc_index);
		
		boolean verify = f.verifyAnnotation(result, annotationName, annotationPreviousValue);
		if(verify){
		f.annotationUpdate(annotationName,annotationPreviousValue, annotationUpdateValue, result);
		String failureMsg = "Expected Annotation: " + annotationName + " value: " + annotationUpdateValue + " for doc: "
				+ result.getVseKey() + "was not added";
		verify = f.verifyAnnotation(result, annotationName, annotationUpdateValue);
		assertTrue(failureMsg, verify);
		}
		else{
			fail("Could not add annotations before testing for update ");
		}

	}
	
	
	@Test
	public void test_annotation_update_missing_contentID() throws Exception {
		String annotationName = "tagsPushpa";
		String annotationPreviousValue = "newTag" + count++;
		String annotationUpdateValue = "update-" + annotationPreviousValue;
		int doc_index = 1;
		String missing_document_error = "Required variable content-id has not been passed when resolving the reference";

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);
		Document result = f.addAnnotation(annotationName, annotationPreviousValue, doc_index);
			AnnotationUpdate my_annotation = f.createAnnotationUpdateObj(annotationName, annotationPreviousValue,
					annotationUpdateValue, result);

			my_annotation.setContentId(null);
			VelocityPort p = f.getVelocityPort();

			try {
				p.annotationUpdate(my_annotation);
				fail("Test fails as no exception is thrown for missing content-id parameter ");
			} catch (SOAPFaultException sfe) {
				SOAPFault sf = sfe.getFault();
				Detail d = sf.getDetail();

				String failureMsg = "expected msg: " + missing_document_error + "\n actual message "
						+ d.getTextContent();
				assertTrue(failureMsg, d.getTextContent().contains(missing_document_error));

			}
		

	}
	
	

}
