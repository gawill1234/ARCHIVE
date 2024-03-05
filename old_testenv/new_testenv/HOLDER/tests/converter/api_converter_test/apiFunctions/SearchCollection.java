package apiFunctions;

import java.io.File;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.ws.soap.SOAPFaultException;


import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import velocity.VelocityPort;
import velocity.VelocityService;

import velocity.objects.CrawlerStatus;

import velocity.objects.Document;
import velocity.objects.VseIndexStatus;
import velocity.objects.VseStatus;

import velocity.soap.Authentication;

import velocity.types.QuerySearch;
import velocity.types.QuerySearchResponse;
import velocity.types.SearchCollectionCrawlerStart;
import velocity.types.SearchCollectionCreate;
import velocity.types.SearchCollectionDelete;
import velocity.types.SearchServiceStart;

import velocity.types.SearchCollectionSetXml;
import velocity.types.SearchCollectionStatus;
import velocity.types.SearchCollectionStatusResponse;

import velocity.types.SearchCollectionSetXml.Xml;

public class SearchCollection {

	// global constants
	public static final String DEFAULT_ACL_VALUE = "v.everyone";
	public static final String DEFAULT_USER = "test-all";
	public static final String DEFAULT_PASSWORD = "P@$$word#1?";
	public static final String DEFAULT_COLLECTION = "sc-doc-test";
	public static final String DEFAULT_QUERY = "jockey";
	public static final String DEFAULT_BASE_URL = "http://127.0.0.1:9080/vivisimo/cgi-bin/velocity.exe";;
	public static final String DEFAULT_SUB_COLLECTION = "live";
	public static final String SYNCHRONIZATION = "indexed";
	public static final String WSDL_CGI_PARAMS = "?v.app=api-soap&wsdl=1&specialize-for=&use-types=true";
	public static final int NO_OF_RESULTS_TO_QUERY = 10;

	// global variables
	private String userName = DEFAULT_USER;
	private String password = DEFAULT_PASSWORD;
	private String base_url = DEFAULT_BASE_URL;
	private String collection = DEFAULT_COLLECTION;

	private boolean verbose = true;

	/**
	 * Constructor
	 * 
	 * @param _baseUrl
	 * @param _collection
	 * @param _query
	 * @param _userN
	 * @param _pwd
	 * @throws MalformedURLException
	 */
	public SearchCollection(String _baseUrl, String _collection, String _userN, String _pwd, boolean _verbose)
			throws MalformedURLException {
		this.setBase_url(_baseUrl);
		this.setCollection(_collection);
		this.setUserName(_userN);
		this.setPassword(_pwd);
		this.verbose = _verbose;

	}

	public SearchCollection(boolean _verbose) throws MalformedURLException {

		this.verbose = _verbose;

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

	public void deleteSearchCollection() throws MalformedURLException {
		if (verbose)
			System.out.println("deleting collection [" + collection + "]...");
		VelocityPort p = getVelocityPort();
		SearchCollectionDelete scDel = new SearchCollectionDelete();
		scDel.setAuthentication(authenticate());
		scDel.setCollection(collection);
		scDel.setKillServices(true);
		p.searchCollectionDelete(scDel);
	}

	public void startSearchCollection() throws MalformedURLException {
		if (verbose)
			System.out.println("Start crawl in collection [" + collection + "]...");
		VelocityPort p = getVelocityPort();
		SearchCollectionCrawlerStart scc = new SearchCollectionCrawlerStart();
		scc.setAuthentication(authenticate());
		scc.setCollection(collection);
		scc.setSubcollection(DEFAULT_SUB_COLLECTION);
		p.searchCollectionCrawlerStart(scc);
	}

	public void waitForCrawlComplete() throws MalformedURLException {
		VelocityPort vp = getVelocityPort();

		SearchCollectionStatus scs = new SearchCollectionStatus();
		scs.setAuthentication(authenticate());
		scs.setCollection(collection);

		if (verbose)
			System.out.println("Request status of [" + collection + "]...");

		SearchCollectionStatusResponse scsr;
		VseStatus vses = null;
		VseIndexStatus vseis = null;
		Boolean sleeping = false;
		do {
			sleeping = false;
			// reuse objects already created for indexer status check
			vses = null;
			vseis = null;
			CrawlerStatus cs = null;
			while (vses == null || vseis == null || cs == null) {
				if (verbose)
					System.out.println("Request status of [" + collection + "]...");
				scsr = vp.searchCollectionStatus(scs);

				vses = scsr.getVseStatus();
				if (vses == null) {
					System.out.println("No collection status yet, crawl is still starting.");
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
					}
				} else {
					vseis = vses.getVseIndexStatus();
					cs = vses.getCrawlerStatus();
					//cs.
					if (cs == null) {
						System.out.println("No crawler status yet, crawler is still	starting.");
						try {
							Thread.sleep(1000);
						} catch (InterruptedException e) {
						}
					}
				}
			}
			if (!("stopped".equals(cs.getServiceStatus()) && "running".equals(vseis.getServiceStatus()))) {
				if (verbose) {
					System.out.println("Crawl is not done.");
					System.out.println("Sleeping for 5 seconds to show crawl progress...");
				}
				sleeping = true;
				try {
					Thread.sleep(5000);
				} catch (InterruptedException e) {
				}
			}
		} while (sleeping);

	}

	
	public String searchCollectionCrawlError() throws MalformedURLException {
		VelocityPort vp = getVelocityPort();

		SearchCollectionStatus scs = new SearchCollectionStatus();
		scs.setAuthentication(authenticate());
		scs.setCollection(collection);

		if (verbose)
			System.out.println("Request Crawl Errors of [" + collection + "]...");

		SearchCollectionStatusResponse scsr;
		VseStatus vses = null;
	
		vses = null;
		CrawlerStatus cs = null;
		
		scsr = vp.searchCollectionStatus(scs);
		vses = scsr.getVseStatus();
		if (vses == null) {
			System.out.println("No collection status yet, crawl is still starting.");
			try {
				Thread.sleep(1000);
				} catch (InterruptedException e) {}
		} else {					
			cs = vses.getCrawlerStatus();
			if (cs == null) {
				System.out.println("No crawler status yet, crawler is still	starting.");
				try {
					Thread.sleep(1000);
				    } catch (InterruptedException e) {}
			}else{
				return cs.getError();
					}
				}
			
			
          return null;
	}

	
	public int searchCollectionNoOfDocumentsIndexed() throws Exception {
		VelocityPort vp = getVelocityPort();

		SearchCollectionStatus scs = new SearchCollectionStatus();
		scs.setAuthentication(authenticate());
		scs.setCollection(collection);

		if (verbose)
			System.out.println("Request Indexed documents in [" + collection + "]...");

		SearchCollectionStatusResponse scsr;
		VseStatus vses = null;
	
		vses = null;
		VseIndexStatus vseis = null;
		scsr = vp.searchCollectionStatus(scs);
		vses = scsr.getVseStatus();
		if (vses == null) {
			System.out.println("No collection status yet, crawl is still starting.");
			try {
				Thread.sleep(1000);
				} catch (InterruptedException e) {}
		} else {					
			vseis = vses.getVseIndexStatus();
			if (vseis == null) {
				System.out.println("No Indexer status yet, Indexer is still	starting.");
				try {
					Thread.sleep(1000);
				    } catch (InterruptedException e) {}
			}else{
				String error=vseis.getError();
				if(error!=null &&error.length()>0){
					throw new Exception(error);
				}
				return vseis.getIndexedDocs();
					}
				}
			
			
          return -1;
	}

	
	
	
	/**
	 * Create Search collection
	 * 
	 * @throws MalformedURLException
	 */
	public void createSearchCollection() throws MalformedURLException {
		if (verbose)
			System.out.println("Creating collection [" + collection + "]...");
		VelocityPort p = getVelocityPort();
		SearchCollectionCreate scC = new SearchCollectionCreate();
		scC.setAuthentication(authenticate());
		scC.setCollection(collection);
		scC.setBasedOn("default");
		try {
			p.searchCollectionCreate(scC);
		} catch (SOAPFaultException e) {
			if (e.getFault().getFaultString().contains("search-collection-already-exists")) {
				this.deleteSearchCollection();
				p.searchCollectionCreate(scC);
			}

		}
	}

	/**
	 * Set Search collection to valid xml
	 * 
	 * @throws Exception
	 */
	public void setXMLSearchCollection(String _xmlFile) throws Exception {
		if (verbose)
			System.out.println("Setting xml for collection [" + collection + "]...");
		VelocityPort p = getVelocityPort();
		// Read the XML, get each element and set that element using setAny()
		// read xml
		List<Element> elements = readXML(_xmlFile);
		// set xml
		Xml xml = new Xml();
		if (elements.size() > 0) {
			xml.setAny(elements.get(0));
		} else {
			throw new Exception("Cannot read nodes from xml");
		}

		SearchCollectionSetXml scXML = new SearchCollectionSetXml();
		scXML.setAuthentication(authenticate());
		scXML.setCollection(collection);
		scXML.setDoAdd(false);
		scXML.setXml(xml);
		p.searchCollectionSetXml(scXML);
	}

	private List<Element> readXML(String _file) {
		// TODO Auto-generated method stub
		List<Element> elements = new ArrayList<Element>();

		try {
			File file = new File(_file);
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			DocumentBuilder db = dbf.newDocumentBuilder();
			org.w3c.dom.Document doc = db.parse(file);
			doc.getDocumentElement().normalize();
			// System.out.println("Root element " + doc.getDocumentElement().getNodeName());
			NodeList nodeLst = doc.getElementsByTagName("vse-collection");
			Node vseCol = nodeLst.item(0);

			if (vseCol.getNodeType() == Node.ELEMENT_NODE) {
				elements.add((Element) vseCol);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return elements;
	}

	/**
	 * Setters and getters
	 * 
	 * @return
	 */

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
	
	public void searchServiceStart() throws MalformedURLException{
		SearchServiceStart service= new SearchServiceStart();
		service.setAuthentication(this.authenticate());
		VelocityPort p = getVelocityPort();
		p.searchServiceStart(service);
	}
	/**
	 * returns list of result documents *
	 * 
	 * @return List of Documents
	 * @throws Exception
	 *             1. IllegalArgumentException : when no results are found
	 */
	public List<Document> query_collection(String _query) throws Exception {
		QuerySearch querySearch = new QuerySearch();

		querySearch.setAuthentication(authenticate());
		querySearch.setQuery(_query);
		querySearch.setSources(collection);
		querySearch.setNum(NO_OF_RESULTS_TO_QUERY);
		VelocityPort p = getVelocityPort();
		QuerySearchResponse qsr = p.querySearch(querySearch);

		if (qsr.getQueryResults().getList() != null) {
			return (qsr.getQueryResults().getList().getDocument());
		} else {
			throw new IllegalArgumentException("No query results" + "Collection: " + this.collection + "query: "
					+ _query + ",url: " + this.base_url);
		}

	}


	public static void main(String[] args) throws Exception {
		SearchCollection sc = new SearchCollection(true);
		sc.authenticate();
		// sc.deleteSearchCollection();
		sc.createSearchCollection();
		sc.setXMLSearchCollection("C:\\Development\\projects\\TestsFolder\\git\\tests\\bugs\\27285\\sc-doc-test.xml");
		sc.startSearchCollection();
		sc.waitForCrawlComplete();// sc.setXML("C:\\Development\\projects\\TestsFolder\\git\\tests\\bugs\\27285\\sc-doc-test.xml");

	}
}
