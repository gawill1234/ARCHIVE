/**
 * @author pbhallamudi
 * @description tests the api function : annotation-express-add-doc-list
 * @tests include : 
 * 1.Passing valid values and expecting success
 * 2.Missing document list * 
 * 
 * @depends
 * 1.JUnit 4, APIFunction.java, CannotverifyResultException.java
 */

package apiTests;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.net.MalformedURLException;
import java.util.List;

import javax.xml.soap.Detail;
import javax.xml.soap.SOAPFault;
import javax.xml.ws.soap.SOAPFaultException;

import org.junit.BeforeClass;
import org.junit.Test;

import velocity.VelocityPort;
import velocity.objects.Document;
import velocity.types.AnnotationExpressAddDocList;

import apiFunctions.APIFunction;
import apiFunctions.Collection;

public class AnnotationsAddDocList_API_Tests {
	// global variables
	public static String USER_NAME = "test-all";
	public static String PASSWORD = "P@$$word#1?";
	public static String BASE_URL = null;
	public static String COLLECTION = "example-metadata";
	public static String QUERY = "jockey";
	public static int count=1;
	
	@BeforeClass
	public static void setupTestVariables() throws MalformedURLException {

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
	public void test_addAnnotations_valid() throws Exception {
		String annotationName = "tags";
		String annotationValue = "newTag"+count++;

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);
		List<Document> result = f.annotation_express_add_DocList(annotationName, annotationValue);

		for (Document d : result) {
			boolean verify = f.verifyAnnotation(d, annotationName, annotationValue);
			String failureMsg = "Expected Annotation: " + annotationName + ", value: " + annotationValue
					+ ", for doc: " + d.getVseKey() + "was not added";
			assertTrue(failureMsg, verify);
		}

	}

	@Test
	public void test_addAnnotations_NoDocuments() throws Exception {
		String annotationName = "tags";
		String annotationValue = "newTag"+count++;
		String missing_document_error = "Required variable documents has not been passed when resolving the reference";
		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);
		AnnotationExpressAddDocList my_annotation = new AnnotationExpressAddDocList();
		f.createAnnotationExpressAddDocListObj(annotationName, annotationValue, my_annotation);
		VelocityPort p = f.getVelocityPort();
		my_annotation.setDocuments(null);
		

		try {
			p.annotationExpressAddDocList(my_annotation);
			fail("Test fails as no exception is thrown for missing document parameter ");
		} catch (SOAPFaultException sfe) {
			SOAPFault sf = sfe.getFault();
			Detail d = sf.getDetail();

			String failureMsg = "expected msg: " + missing_document_error + "\n actual message " + d.getTextContent();
			assertTrue(failureMsg, d.getTextContent().contains(missing_document_error));

		}

	}

}