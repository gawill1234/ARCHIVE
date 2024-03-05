package apiTests;


/**
 * @author pbhallamudi
 * @description tests the api function : annotation-express-update-doc-list
 * @tests include : 
 * 1.Passing valid values and expecting success
 * 2. Failing to pass required parameter content-old and expecting exception/failure
 * @depends
 * 1.JUnit 4, APIFunction.java, CannotverifyResultException.java, Collection.java
 */
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.soap.Detail;
import javax.xml.soap.SOAPFault;
import javax.xml.ws.soap.SOAPFaultException;

import org.junit.BeforeClass;
import org.junit.Test;

import velocity.VelocityPort;
import velocity.objects.Document;
import velocity.types.AnnotationExpressUpdateDocList;
import apiFunctions.APIFunction;
import apiFunctions.Collection;

public class Annotation_express_update_doc_list_Tests {
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

		Collection c = new Collection(BASE_URL, COLLECTION, USER_NAME, PASSWORD, true);
		c.deleteSearchCollection();
		c.startSearchCollection();
		c.waitForCrawlComplete();

	}

	@Test
	public void test_annotation_express_update_docList_valid() throws Exception {
		String annotationName = "tagsPushpa";
		String annotationPreviousValue = "newTag" + count++;
		String annotationUpdateValue = "update-" + annotationPreviousValue;

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);
		// first add annotation
		List<Document> result = f.annotation_express_add_DocList(annotationName, annotationPreviousValue);

		f.annotationExpressUpdateDocList(annotationName, annotationPreviousValue, annotationUpdateValue, result);
		for (Document d : result) {
			boolean verify = f.verifyAnnotation(d, annotationName, annotationUpdateValue);
			String failureMsg = "Expected Annotation: " + annotationName + ", value: " + annotationUpdateValue
					+ ", for doc: " + d.getVseKey() + "was not added";
			assertTrue(failureMsg, verify);
		}

	}

	@Test
	public void test_annotation_express_update_DocList_missing_ContentOld() throws Exception {
		String annotationName = "tagsPushpa";
		String annotationPreviousValue = "newTag" + count++;
		String annotationUpdateValue = "update-" + annotationPreviousValue;
		
		String missing_document_error = "Required variable content-old has not been passed when resolving the reference";

		APIFunction f = new APIFunction(BASE_URL, COLLECTION, QUERY, USER_NAME, PASSWORD);
		List<Document> result =  new ArrayList<Document>();
		result.add(new Document());
		AnnotationExpressUpdateDocList my_annotation = f.createAnnotationExpressUpdateDocListObj(annotationName, 
				annotationPreviousValue, annotationUpdateValue, result);
		

		my_annotation.setContentOld(null);
		VelocityPort p = f.getVelocityPort();

		try {
			p.annotationExpressUpdateDocList(my_annotation);
			fail("Test fails as no exception is thrown for missing content-old parameter ");
		} catch (SOAPFaultException sfe) {
			SOAPFault sf = sfe.getFault();
			Detail d = sf.getDetail();

			String failureMsg = "expected msg: " + missing_document_error + "\n actual message " + d.getTextContent();
			assertTrue(failureMsg, d.getTextContent().contains(missing_document_error));

		}

	}

}
