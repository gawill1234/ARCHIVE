package apiFunctions;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.Map;

import javax.xml.namespace.QName;
import javax.xml.ws.soap.SOAPFaultException;

import apiFunctions.CannotVerifyResultException;
import velocity.VelocityPort;
import velocity.VelocityService;
import velocity.objects.Content;
import velocity.objects.Document;
import velocity.objects.Query;

import velocity.soap.Authentication;
import velocity.types.AnnotationAdd;
import velocity.types.AnnotationExpressAddDocList;
import velocity.types.AnnotationExpressAddQuery;
import velocity.types.AnnotationExpressUpdateDocList;
import velocity.types.AnnotationUpdate;
import velocity.types.QuerySearch;
import velocity.types.QuerySearchResponse;


/**
 * @author pbhallamudi
 * 
 */
public class APIFunction {

	// global constants
	public static final String DEFAULT_ACL_VALUE = "v.everyone";
	public static final String DEFAULT_USER = "test-all";
	public static final String DEFAULT_PASSWORD = "P@$$word#1?";
	public static final String DEFAULT_COLLECTION = "example-metadata";
	public static final String DEFAULT_QUERY = "jockey";
	public static final String DEFAULT_BASE_URL = "http://127.0.0.1/vivisimo-758/cgi-bin/velocity.exe";;
	public static final String DEFAULT_SUB_COLLECTION = "live";
	public static final String SYNCHRONIZATION = "indexed";
	public static final String WSDL_CGI_PARAMS = "?v.app=api-soap&wsdl=1&specialize-for=&use-types=true";
	public static final int NO_OF_RESULTS_TO_QUERY = 10;

	// global variables
	private String userName = DEFAULT_USER;
	private String password = DEFAULT_PASSWORD;
	private String base_url = DEFAULT_BASE_URL;
	private String collection = DEFAULT_COLLECTION;
	private String query = DEFAULT_QUERY;
	private String acl = DEFAULT_ACL_VALUE;

	/**
	 * Constructor
	 * 
	 * @param _baseUrl
	 * @param _collection
	 * @param _query
	 * @param _userN
	 * @param _pwd
	 */
	public APIFunction(String _baseUrl, String _collection, String _query, String _userN, String _pwd) {
		this.setBase_url(_baseUrl);
		this.setCollection(_collection);
		this.setQuery(_query);
		this.setUserName(_userN);
		this.setPassword(_pwd);
	}

	/**
	 * Create authentication variable
	 * 
	 * @return variable of type Authentication
	 */
	public Authentication authenticate() {
		Authentication authentication = new Authentication();
		authentication.setUsername(userName);
		authentication.setPassword(password);
		return authentication;
	}

	/**
	 * create velocity port variable
	 * 
	 * @return Velocity Port variable
	 * @throws MalformedURLException
	 */
	public VelocityPort getVelocityPort() throws MalformedURLException {

		String url = base_url + WSDL_CGI_PARAMS;
		URL wsdlLocation = new URL(url);
		QName serviceName = new QName("urn:/velocity", "VelocityService");
		VelocityService s = new VelocityService(wsdlLocation, serviceName);
		return s.getVelocityPort();
	}

	/**
	 * add annotation
	 * 
	 * @param _annotationName
	 * @param _annotationValue
	 * @param _document_index
	 * @return document
	 * @throws Exception
	 */
	public Document addAnnotation(String _annotationName, String _annotationValue, int _document_index)
			throws Exception {

		AnnotationAdd my_annotation = createAnnotationAddVar(_annotationName, _annotationValue, _document_index);

		Document doc_details;
		try {
			doc_details = getDocumentVseKey(_document_index);
			my_annotation.setDocumentVseKey(doc_details.getVseKey());
			VelocityPort p = getVelocityPort();
			p.annotationAdd(my_annotation); // execute the api

		} catch (SOAPFaultException sfe) {
			throw sfe;
		}

		return doc_details;
	}

	/**
	 * Created AnnotationAdd object with required parameters
	 * 
	 * @param _annotationName
	 * @param _annotationValue
	 * @param _document_index
	 * @return AnnotationAdd
	 * @throws Exception
	 */

	public AnnotationAdd createAnnotationAddVar(String _annotationName, String _annotationValue, int _document_index)
			throws Exception {
		AnnotationAdd my_annotation = new AnnotationAdd();

		my_annotation.setAuthentication(authenticate());
		my_annotation.setCollection(collection);
		my_annotation.setSubcollection(DEFAULT_SUB_COLLECTION);
		my_annotation.setSynchronization(SYNCHRONIZATION);
		my_annotation.setDocumentVseKeyNormalized(true);
		my_annotation.setUsername(userName);
		my_annotation.setAcl(acl);

		// create content
		AnnotationAdd.Content content = createContent(_annotationName, _annotationValue);
		my_annotation.setContent(content);

		// get vse_key
		Document doc_details = getDocumentVseKey(_document_index);
		my_annotation.setDocumentVseKey(doc_details.getVseKey()); // pass the vse-key parameter

		return my_annotation;
	}

	/**
	 * Creates content variable
	 * 
	 * @param _annotationName
	 * @param _annotationValue
	 * @return AnnotationAdd.Content
	 */
	public AnnotationAdd.Content createContent(String _annotationName, String _annotationValue) {
		Content c = new Content();
		AnnotationAdd.Content content = new AnnotationAdd.Content();
		content.getContent().add(c);
		if (_annotationName != null) {
			c.setName(_annotationName);
		}
		if (_annotationValue != null) {
			c.setValue(_annotationValue);
		}
		return content;
	}

	/**
	 * get the VSE_KEY for the document
	 * 
	 * @param _index
	 *            :document index for which you need VSE-KEY
	 * @return document
	 * @throws Exception
	 *             1. IllegalArgumentException : "No Documents at index" +Index
	 */
	public Document getDocumentVseKey(int _index) throws Exception {

		List<Document> doc = query_collection();
		if (doc.size() <= _index | _index < 0) {
			throw new IllegalArgumentException("Collection: " + this.collection + " query: " + this.query + " url: "
					+ this.base_url + " No Documents at index: " + _index);
		} else {
			return doc.get(_index);
		}

	}

	/**
	 * returns list of result documents *
	 * 
	 * @return List of Documents
	 * @throws Exception
	 *             1. IllegalArgumentException : when no results are found
	 */
	public List<Document> query_collection() throws Exception {
		QuerySearch querySearch = new QuerySearch();

		querySearch.setAuthentication(authenticate());
		querySearch.setQuery(query);
		querySearch.setSources(collection);
		querySearch.setNum(NO_OF_RESULTS_TO_QUERY);

		VelocityPort p = getVelocityPort();
		QuerySearchResponse qsr = p.querySearch(querySearch);

		if (qsr.getQueryResults().getList() != null) {
			return (qsr.getQueryResults().getList().getDocument());
		} else {
			throw new IllegalArgumentException("No query results" + "Collection: " + this.collection + "query: "
					+ this.query + ",url: " + this.base_url);
		}

	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String _userName) {
		if (_userName != null && _userName.length() > 0) {
			this.userName = _userName;
		}
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String _password) {
		if (_password != null && _password.length() > 0) {
			this.password = _password;
		}

	}

	public String getBase_url() {
		return base_url;
	}

	public void setBase_url(String _baseUrl) {

		if (_baseUrl != null && _baseUrl.length() > 0) {

			this.base_url = _baseUrl;
		}

	}

	public void setCollection(String _collection) {

		if (_collection != null && _collection.length() > 0) {
			this.collection = _collection;
		}

	}

	public String getCollection() {
		return collection;
	}

	public void setQuery(String _query) {
		if (_query != null) {
			this.query = _query;
		}

	}

	public String getQuery() {
		return query;
	}

	/**
	 * returns true if the annotation with expected value is present in the document.
	 * 
	 * @param _expectedDocDetails
	 *            :List<String> (VSE-key, Title)
	 * @param _annotationName
	 * @param _annotationValue
	 * @return true/false
	 * @throws Exception
	 *             1. CannotVerifyException:"annotation cannot be verified"
	 */
	public boolean verifyAnnotation(final Document _expectedDocDetails, final String _annotationName,
			final String _annotationValue) throws Exception {

		// query results using default query to check annotations

		List<Document> doc = query_collection();
		if (doc == null) { // query again with the title of the doc to which annotation was added
			final String previous_query = this.getQuery(); // save previous query parameter
			// get the title of the result , to search by title
			for (Content c : _expectedDocDetails.getContent()) {
				if (c.getName().toString().equalsIgnoreCase("title")) {
					this.setQuery(c.getValue());
				}
			}

			this.setQuery(_expectedDocDetails.getContent().toString()); // set query to title of doc
			doc = query_collection(); // get results of new query
			this.setQuery(previous_query); // set the query term back to
			// original
		}
		if (doc != null) { // there are results
			for (Document temp : doc) {
				// match the vse-key of document to expected document vse-key
				if (temp.getVseKey().equalsIgnoreCase(_expectedDocDetails.getVseKey())) {
					// the vse-key matches, check for its contents
					for (Content c : temp.getContent()) {
						if (c.getName().equals(_annotationName) && c.getValue().equals(_annotationValue)) {
							return true; // expected annotation with its value present in the document
						}

					}
					return false; // document is found , but expected annotation or result not present.

				}

			}
		}
		// result cannot be verified, throw exception
		throw new CannotVerifyResultException("annotation cannot be verified" + "Doc: "
				+ _expectedDocDetails.getVseKey() + ",Annotation name:" + _annotationName + ",with Annotation value:"
				+ _annotationValue + "Collection: " + this.collection + "query: " + this.query + "url: "
				+ this.base_url);

	}

	public void setAcl(String acl) {
		this.acl = acl;
	}

	public String getAcl() {
		return acl;
	}

	/**
	 * Adds annotations to multiple documents using AnnotationExpressAddDocList
	 * 
	 * @param _annotationName
	 * @param _annotationValue
	 * @return
	 * @throws Exception
	 */
	public List<Document> annotation_express_add_DocList(String _annotationName, String _annotationValue)
			throws Exception {

		AnnotationExpressAddDocList my_annotation = new AnnotationExpressAddDocList();

		List<Document> d = createAnnotationExpressAddDocListObj(_annotationName, _annotationValue, my_annotation);

		try {

			VelocityPort p = getVelocityPort();

			p.annotationExpressAddDocList(my_annotation);
		} catch (SOAPFaultException sfe) {
			throw sfe;
		}

		return d;
	}

	/**
	 * Creates a object of AnnotationExpressAddDocList with required values.
	 * 
	 * @param _annotationName
	 * @param _annotationValue
	 * @param my_annotation
	 * @return
	 * @throws Exception
	 */
	public List<Document> createAnnotationExpressAddDocListObj(String _annotationName, String _annotationValue,
			AnnotationExpressAddDocList my_annotation) throws Exception {
		my_annotation.setAuthentication(authenticate());
		my_annotation.setCollection(collection);
		my_annotation.setSubcollection(DEFAULT_SUB_COLLECTION);
		my_annotation.setSynchronization(SYNCHRONIZATION);
		my_annotation.setUsername(userName);
		my_annotation.setAcl(acl);

		// create content

		Content c = new Content();
		AnnotationExpressAddDocList.Content content = new AnnotationExpressAddDocList.Content();
		content.getContent().add(c);
		if (_annotationName != null) {
			c.setName(_annotationName);
		}
		if (_annotationValue != null) {
			c.setValue(_annotationValue);
		}
		my_annotation.setContent(content);

		// get documents

		List<Document> d = this.query_collection();

		AnnotationExpressAddDocList.Documents expressDoc = new AnnotationExpressAddDocList.Documents();
		expressDoc.getDocument().addAll(d);
		my_annotation.setDocuments(expressDoc);
		return d;
	}

	/**
	 * @param _annotationName
	 * @param _annotationValue
	 *            *
	 * @param _no_doc
	 * @param _query
	 * @param my_annotation
	 * @throws Exception
	 */
	public void createAnnotationExpressAddQueryobj(String _annotationName, String _annotationValue, String _no_doc,
			String _query, AnnotationExpressAddQuery my_annotation) throws Exception {

		my_annotation.setAuthentication(authenticate());
		my_annotation.setCollection(getCollection());
		my_annotation.setSubcollection(DEFAULT_SUB_COLLECTION);
		my_annotation.setUsername(getUserName());
		my_annotation.setAcl(getAcl());

		// create content

		Content c = new Content();
		AnnotationExpressAddQuery.Content content = new AnnotationExpressAddQuery.Content();
		content.getContent().add(c);
		if (_annotationName != null) {
			c.setName(_annotationName);
		}
		if (_annotationValue != null) {
			c.setValue(_annotationValue);
		}
		my_annotation.setContent(content);

		Query q = new Query();
		AnnotationExpressAddQuery.Query query = new AnnotationExpressAddQuery.Query();

		if (_query != null) {
			q.setForm(_query);
		}

		query.setQuery(q);
		my_annotation.setQuery(query);
		my_annotation.setNumDocsAtATime(_no_doc);

		// get documents

	}

	/**
	 * @param _annotationName
	 * @param _annotationValue
	 * @param _no_document
	 * @param _query
	 * @return
	 * @throws Exception
	 */
	public void annotation_express_add_query(String _annotationName, String _annotationValue, String _no_document,
			String _query) throws Exception {
		AnnotationExpressAddQuery my_annotation = new AnnotationExpressAddQuery();

		createAnnotationExpressAddQueryobj(_annotationName, _annotationValue, _no_document, _query, my_annotation);

		try {

			VelocityPort p = getVelocityPort();
			p.annotationExpressAddQuery(my_annotation); // execute the api
		} catch (SOAPFaultException sfe) {
			throw sfe;
		}

	}

	public void annotationUpdate(String _annotationName, String _annotationPreviousValue,
			String _annotationUpdateValue, Document _expectedDoc) throws Exception {

		AnnotationUpdate my_annotation = createAnnotationUpdateObj(_annotationName, _annotationPreviousValue,
				_annotationUpdateValue, _expectedDoc);

		try {

			VelocityPort p = getVelocityPort();
			p.annotationUpdate(my_annotation); // execute the api

		} catch (SOAPFaultException sfe) {
			throw sfe;
		}

	}

	public AnnotationUpdate createAnnotationUpdateObj(String _annotationName, String _annotationPreviousValue,
			String _annotationUpdateValue, Document _expectedDoc) throws Exception {

		System.out.println(_expectedDoc.getVseKey());

		String contentID = getContentID(_annotationName, _annotationPreviousValue, _expectedDoc);
		AnnotationUpdate my_annotation = new AnnotationUpdate();

		my_annotation.setAuthentication(authenticate());
		my_annotation.setCollection(collection);
		my_annotation.setSubcollection(DEFAULT_SUB_COLLECTION);
		my_annotation.setSynchronization(SYNCHRONIZATION);
		my_annotation.setDocumentVseKeyNormalized(true);
		my_annotation.setUsername(userName);
		my_annotation.setAcl(acl);
		my_annotation.setContentId(contentID);
		// create content
		Content c = new Content();
		AnnotationUpdate.Content content = new AnnotationUpdate.Content();

		if (_annotationName != null) {
			c.setName(_annotationName);
		}
		if (_annotationUpdateValue != null) {
			c.setValue(_annotationUpdateValue);
		}
		content.setContent(c);
		my_annotation.setContent(content);

		// get vse_key

		my_annotation.setDocumentVseKey(_expectedDoc.getVseKey()); // pass the vse-key parameter

		return my_annotation;
	}

	public String getContentID(String _annotationName, String _annotationPreviousValue, Document _expectedDoc)
			throws Exception {

		List<Document> docs = query_collection();
		for (Document temp : docs) {
			// match the vse-key of document to expected document vse-key
			if (temp.getVseKey().equalsIgnoreCase(_expectedDoc.getVseKey())) {
				// the vse-key matches, check for its contents
				for (Content c : temp.getContent()) {

					if (c.getName().equals(_annotationName) && c.getValue().equals(_annotationPreviousValue)) {
						Map<QName, String> m = c.getOtherAttributes(); // additional parameters
						for (QName q : m.keySet()) {
							if (q.toString().equals("content-id")) {
								return m.get(q);
							}
						}

					}

				}

			}

		}
		throw new IllegalArgumentException("Caption-id missing for [ " + _expectedDoc.getVseKey() + " ] annotation[ "
				+ _annotationName + "]");
	}

	/**
	 * @param _annotationName
	 * @param _annotationPreviousValue
	 * @param _annotationUpdateValue
	 * @param _result
	 * @throws Exception
	 */
	

	public void annotationExpressUpdateDocList(String _annotationName, String _annotationPreviousValue,
			String _annotationUpdateValue, List<Document> _result) throws Exception {
		
		AnnotationExpressUpdateDocList my_annotation = createAnnotationExpressUpdateDocListObj(_annotationName,
				_annotationPreviousValue, _annotationUpdateValue, _result);

		try {

			VelocityPort p = getVelocityPort();
			p.annotationExpressUpdateDocList(my_annotation); // execute the api

		} catch (SOAPFaultException sfe) {
			throw sfe;
		}

	}

	public AnnotationExpressUpdateDocList createAnnotationExpressUpdateDocListObj(String _annotationName,
			String _annotationPreviousValue, String _annotationUpdateValue, List<Document> _result) throws Exception {
		AnnotationExpressUpdateDocList my_annotation = new AnnotationExpressUpdateDocList();
		my_annotation.setAuthentication(authenticate());
		my_annotation.setCollection(collection);
		my_annotation.setSubcollection(DEFAULT_SUB_COLLECTION);
		my_annotation.setSynchronization(SYNCHRONIZATION);
		my_annotation.setUsername(userName);
		my_annotation.setAcl(acl);
		my_annotation.setContentOld(setOldContent(_annotationName, _annotationPreviousValue));

		Content c = new Content();
		AnnotationExpressUpdateDocList.Content content = new AnnotationExpressUpdateDocList.Content();

		if (_annotationName != null) {
			c.setName(_annotationName);
		}
		if (_annotationUpdateValue != null) {
			c.setValue(_annotationUpdateValue);
		}
		content.setContent(c);
		my_annotation.setContent(content);

		// get documents

		AnnotationExpressUpdateDocList.Documents expressDoc = new AnnotationExpressUpdateDocList.Documents();
		expressDoc.getDocument().addAll(_result);
		my_annotation.setDocuments(expressDoc);
		return (my_annotation);

	}

	private AnnotationExpressUpdateDocList.ContentOld setOldContent(String _annotationName,
			String _annotationPreviousValue) throws Exception {

		Content c = new Content();
		AnnotationExpressUpdateDocList.ContentOld content = new AnnotationExpressUpdateDocList.ContentOld();

		if (_annotationName != null) {
			c.setName(_annotationName);
		}
		if (_annotationPreviousValue != null) {
			c.setValue(_annotationPreviousValue);
		}
		content.setContent(c);
		return content;
	}

}
