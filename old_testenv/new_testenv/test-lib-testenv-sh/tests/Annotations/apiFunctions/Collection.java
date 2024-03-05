package apiFunctions;

import java.net.MalformedURLException;
import java.net.URL;
import javax.xml.namespace.QName;
import velocity.VelocityPort;
import velocity.VelocityService;
import velocity.objects.CrawlerStatus;
import velocity.objects.VseIndexStatus;
import velocity.objects.VseStatus;
import velocity.soap.Authentication;
import velocity.types.SearchCollectionCrawlerStart;
import velocity.types.SearchCollectionDelete;
import velocity.types.SearchCollectionStatus;
import velocity.types.SearchCollectionStatusResponse;

public class Collection {

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
	public Collection(String _baseUrl, String _collection,String _userN, String _pwd,boolean _verbose)
			throws MalformedURLException {
		this.setBase_url(_baseUrl);
		this.setCollection(_collection);
		this.setUserName(_userN);
		this.setPassword(_pwd);
		this.verbose=_verbose;

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

	
}
