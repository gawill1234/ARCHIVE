
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="acl-user-prefix" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="authorization-required" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="authorization-url" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="case-normalize" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="connect-timeout" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="converter-fallback-type" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="converter-max-cpu" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="converter-max-elapsed" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="converter-max-memory" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="cookie" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="crawler-fallback-type" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="default-acl" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="default-allow" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="default-content-type" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="default-encoding" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="delay" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="disable-dns-resolution" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="disable-graph" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="disable-log" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="enable-acl" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="enable-fetch-compression" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="encoding-replacements" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="enqueue-input-threshold" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="enqueue-persistence" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="error-expires" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="expires" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="filter-exact-duplicates" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="force-recrawl" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="forced-content-type" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ftplistonly" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="full-logging" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="graph" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="header" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="http-auth" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="http-proxy-auth" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="http-version" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ignore-reported-encoding" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="ignore-robots" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="immediate-persistence" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="interface" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="internal-max-redirs" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="lazy-persistence" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="log" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="max-bytes" type="{http://www.w3.org/2001/XMLSchema}long" minOccurs="0"/>
 *         &lt;element name="max-data-size" type="{http://www.w3.org/2001/XMLSchema}long" minOccurs="0"/>
 *         &lt;element name="max-export-size" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="max-hops" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="max-redirs" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="max-slashes" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="max-url-len" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="method" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="minimal-logging" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="n-concurrent-requests" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="post" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="priority" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="proxy" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="proxy-port" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="proxy-user-password" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="purge-all-xml" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="purge-complete-xml" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="purge-input-xml" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="referer" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="refined-logging" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="robots" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ssl-ca-cert" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ssl-cert" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ssl-cert-type" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ssl-key" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ssl-key-password" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ssl-key-type" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ssl-verify-peer" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ssl-version" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="test-conversion" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="test-conversion-debug-id" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="test-conversion-id" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="timeout" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="uncrawled-expires" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="url-logging" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="user-agent" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="user-password" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "aclUserPrefix",
    "authorizationRequired",
    "authorizationUrl",
    "caseNormalize",
    "connectTimeout",
    "converterFallbackType",
    "converterMaxCpu",
    "converterMaxElapsed",
    "converterMaxMemory",
    "cookie",
    "crawlerFallbackType",
    "defaultAcl",
    "defaultAllow",
    "defaultContentType",
    "defaultEncoding",
    "delay",
    "disableDnsResolution",
    "disableGraph",
    "disableLog",
    "enableAcl",
    "enableFetchCompression",
    "encodingReplacements",
    "enqueueInputThreshold",
    "enqueuePersistence",
    "errorExpires",
    "expires",
    "filterExactDuplicates",
    "forceRecrawl",
    "forcedContentType",
    "ftplistonly",
    "fullLogging",
    "graph",
    "header",
    "httpAuth",
    "httpProxyAuth",
    "httpVersion",
    "ignoreReportedEncoding",
    "ignoreRobots",
    "immediatePersistence",
    "_interface",
    "internalMaxRedirs",
    "lazyPersistence",
    "log",
    "maxBytes",
    "maxDataSize",
    "maxExportSize",
    "maxHops",
    "maxRedirs",
    "maxSlashes",
    "maxUrlLen",
    "method",
    "minimalLogging",
    "nConcurrentRequests",
    "post",
    "priority",
    "proxy",
    "proxyPort",
    "proxyUserPassword",
    "purgeAllXml",
    "purgeCompleteXml",
    "purgeInputXml",
    "referer",
    "refinedLogging",
    "robots",
    "sslCaCert",
    "sslCert",
    "sslCertType",
    "sslKey",
    "sslKeyPassword",
    "sslKeyType",
    "sslVerifyPeer",
    "sslVersion",
    "testConversion",
    "testConversionDebugId",
    "testConversionId",
    "timeout",
    "uncrawledExpires",
    "urlLogging",
    "userAgent",
    "userPassword"
})
@XmlRootElement(name = "curl-option")
public class CurlOption {

    @XmlElement(name = "acl-user-prefix")
    protected String aclUserPrefix;
    @XmlElement(name = "authorization-required", defaultValue = "false")
    protected java.lang.Boolean authorizationRequired;
    @XmlElement(name = "authorization-url")
    protected String authorizationUrl;
    @XmlElement(name = "case-normalize")
    protected String caseNormalize;
    @XmlElement(name = "connect-timeout", defaultValue = "30")
    protected Integer connectTimeout;
    @XmlElement(name = "converter-fallback-type", defaultValue = "vivisimo/fallback")
    protected String converterFallbackType;
    @XmlElement(name = "converter-max-cpu", defaultValue = "1800")
    protected Integer converterMaxCpu;
    @XmlElement(name = "converter-max-elapsed", defaultValue = "1800")
    protected Integer converterMaxElapsed;
    @XmlElement(name = "converter-max-memory", defaultValue = "512")
    protected Integer converterMaxMemory;
    protected String cookie;
    @XmlElement(name = "crawler-fallback-type", defaultValue = "vivisimo/crawler-error")
    protected String crawlerFallbackType;
    @XmlElement(name = "default-acl")
    protected String defaultAcl;
    @XmlElement(name = "default-allow", defaultValue = "disallow")
    protected String defaultAllow;
    @XmlElement(name = "default-content-type")
    protected String defaultContentType;
    @XmlElement(name = "default-encoding")
    protected String defaultEncoding;
    @XmlElement(defaultValue = "100")
    protected Integer delay;
    @XmlElement(name = "disable-dns-resolution", defaultValue = "false")
    protected java.lang.Boolean disableDnsResolution;
    @XmlElement(name = "disable-graph", defaultValue = "false")
    protected java.lang.Boolean disableGraph;
    @XmlElement(name = "disable-log", defaultValue = "false")
    protected java.lang.Boolean disableLog;
    @XmlElement(name = "enable-acl", defaultValue = "true")
    protected java.lang.Boolean enableAcl;
    @XmlElement(name = "enable-fetch-compression", defaultValue = "true")
    protected java.lang.Boolean enableFetchCompression;
    @XmlElement(name = "encoding-replacements")
    protected String encodingReplacements;
    @XmlElement(name = "enqueue-input-threshold", defaultValue = "100000")
    protected Integer enqueueInputThreshold;
    @XmlElement(name = "enqueue-persistence", defaultValue = "immediate-persistence")
    protected String enqueuePersistence;
    @XmlElement(name = "error-expires", defaultValue = "604800")
    protected Integer errorExpires;
    @XmlElement(defaultValue = "0")
    protected Integer expires;
    @XmlElement(name = "filter-exact-duplicates", defaultValue = "false")
    protected java.lang.Boolean filterExactDuplicates;
    @XmlElement(name = "force-recrawl")
    protected String forceRecrawl;
    @XmlElement(name = "forced-content-type")
    protected String forcedContentType;
    @XmlElement(defaultValue = "false")
    protected java.lang.Boolean ftplistonly;
    @XmlElement(name = "full-logging")
    protected String fullLogging;
    @XmlElement(defaultValue = "true")
    protected java.lang.Boolean graph;
    protected String header;
    @XmlElement(name = "http-auth")
    protected String httpAuth;
    @XmlElement(name = "http-proxy-auth")
    protected String httpProxyAuth;
    @XmlElement(name = "http-version")
    protected String httpVersion;
    @XmlElement(name = "ignore-reported-encoding", defaultValue = "false")
    protected java.lang.Boolean ignoreReportedEncoding;
    @XmlElement(name = "ignore-robots", defaultValue = "false")
    protected java.lang.Boolean ignoreRobots;
    @XmlElement(name = "immediate-persistence")
    protected String immediatePersistence;
    @XmlElement(name = "interface")
    protected String _interface;
    @XmlElement(name = "internal-max-redirs", defaultValue = "0")
    protected Integer internalMaxRedirs;
    @XmlElement(name = "lazy-persistence")
    protected String lazyPersistence;
    @XmlElement(defaultValue = "true")
    protected java.lang.Boolean log;
    @XmlElement(name = "max-bytes", defaultValue = "1000000000")
    protected Long maxBytes;
    @XmlElement(name = "max-data-size", defaultValue = "20000000")
    protected Long maxDataSize;
    @XmlElement(name = "max-export-size", defaultValue = "0")
    protected Double maxExportSize;
    @XmlElement(name = "max-hops", defaultValue = "15")
    protected Integer maxHops;
    @XmlElement(name = "max-redirs", defaultValue = "10")
    protected Integer maxRedirs;
    @XmlElement(name = "max-slashes", defaultValue = "-1")
    protected Integer maxSlashes;
    @XmlElement(name = "max-url-len", defaultValue = "-1")
    protected Integer maxUrlLen;
    @XmlElement(defaultValue = "GET")
    protected String method;
    @XmlElement(name = "minimal-logging")
    protected String minimalLogging;
    @XmlElement(name = "n-concurrent-requests", defaultValue = "1")
    protected Integer nConcurrentRequests;
    protected String post;
    @XmlElement(defaultValue = "0")
    protected Integer priority;
    protected String proxy;
    @XmlElement(name = "proxy-port")
    protected String proxyPort;
    @XmlElement(name = "proxy-user-password")
    protected String proxyUserPassword;
    @XmlElement(name = "purge-all-xml", defaultValue = "false")
    protected java.lang.Boolean purgeAllXml;
    @XmlElement(name = "purge-complete-xml", defaultValue = "false")
    protected java.lang.Boolean purgeCompleteXml;
    @XmlElement(name = "purge-input-xml", defaultValue = "false")
    protected java.lang.Boolean purgeInputXml;
    protected String referer;
    @XmlElement(name = "refined-logging")
    protected String refinedLogging;
    protected String robots;
    @XmlElement(name = "ssl-ca-cert")
    protected String sslCaCert;
    @XmlElement(name = "ssl-cert")
    protected String sslCert;
    @XmlElement(name = "ssl-cert-type")
    protected String sslCertType;
    @XmlElement(name = "ssl-key")
    protected String sslKey;
    @XmlElement(name = "ssl-key-password")
    protected String sslKeyPassword;
    @XmlElement(name = "ssl-key-type")
    protected String sslKeyType;
    @XmlElement(name = "ssl-verify-peer")
    protected String sslVerifyPeer;
    @XmlElement(name = "ssl-version", defaultValue = "Any")
    protected String sslVersion;
    @XmlElement(name = "test-conversion", defaultValue = "0")
    protected Integer testConversion;
    @XmlElement(name = "test-conversion-debug-id")
    protected String testConversionDebugId;
    @XmlElement(name = "test-conversion-id", defaultValue = "-1")
    protected Integer testConversionId;
    @XmlElement(defaultValue = "600")
    protected Integer timeout;
    @XmlElement(name = "uncrawled-expires", defaultValue = "0")
    protected Integer uncrawledExpires;
    @XmlElement(name = "url-logging", defaultValue = "refined-logging")
    protected String urlLogging;
    @XmlElement(name = "user-agent", defaultValue = "VSE/1.0")
    protected String userAgent;
    @XmlElement(name = "user-password")
    protected String userPassword;

    /**
     * Gets the value of the aclUserPrefix property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAclUserPrefix() {
        return aclUserPrefix;
    }

    /**
     * Sets the value of the aclUserPrefix property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAclUserPrefix(String value) {
        this.aclUserPrefix = value;
    }

    /**
     * Gets the value of the authorizationRequired property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isAuthorizationRequired() {
        return authorizationRequired;
    }

    /**
     * Sets the value of the authorizationRequired property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setAuthorizationRequired(java.lang.Boolean value) {
        this.authorizationRequired = value;
    }

    /**
     * Gets the value of the authorizationUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthorizationUrl() {
        return authorizationUrl;
    }

    /**
     * Sets the value of the authorizationUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthorizationUrl(String value) {
        this.authorizationUrl = value;
    }

    /**
     * Gets the value of the caseNormalize property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCaseNormalize() {
        return caseNormalize;
    }

    /**
     * Sets the value of the caseNormalize property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCaseNormalize(String value) {
        this.caseNormalize = value;
    }

    /**
     * Gets the value of the connectTimeout property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getConnectTimeout() {
        return connectTimeout;
    }

    /**
     * Sets the value of the connectTimeout property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setConnectTimeout(Integer value) {
        this.connectTimeout = value;
    }

    /**
     * Gets the value of the converterFallbackType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getConverterFallbackType() {
        return converterFallbackType;
    }

    /**
     * Sets the value of the converterFallbackType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setConverterFallbackType(String value) {
        this.converterFallbackType = value;
    }

    /**
     * Gets the value of the converterMaxCpu property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getConverterMaxCpu() {
        return converterMaxCpu;
    }

    /**
     * Sets the value of the converterMaxCpu property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setConverterMaxCpu(Integer value) {
        this.converterMaxCpu = value;
    }

    /**
     * Gets the value of the converterMaxElapsed property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getConverterMaxElapsed() {
        return converterMaxElapsed;
    }

    /**
     * Sets the value of the converterMaxElapsed property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setConverterMaxElapsed(Integer value) {
        this.converterMaxElapsed = value;
    }

    /**
     * Gets the value of the converterMaxMemory property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getConverterMaxMemory() {
        return converterMaxMemory;
    }

    /**
     * Sets the value of the converterMaxMemory property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setConverterMaxMemory(Integer value) {
        this.converterMaxMemory = value;
    }

    /**
     * Gets the value of the cookie property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCookie() {
        return cookie;
    }

    /**
     * Sets the value of the cookie property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCookie(String value) {
        this.cookie = value;
    }

    /**
     * Gets the value of the crawlerFallbackType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCrawlerFallbackType() {
        return crawlerFallbackType;
    }

    /**
     * Sets the value of the crawlerFallbackType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCrawlerFallbackType(String value) {
        this.crawlerFallbackType = value;
    }

    /**
     * Gets the value of the defaultAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDefaultAcl() {
        return defaultAcl;
    }

    /**
     * Sets the value of the defaultAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDefaultAcl(String value) {
        this.defaultAcl = value;
    }

    /**
     * Gets the value of the defaultAllow property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDefaultAllow() {
        return defaultAllow;
    }

    /**
     * Sets the value of the defaultAllow property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDefaultAllow(String value) {
        this.defaultAllow = value;
    }

    /**
     * Gets the value of the defaultContentType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDefaultContentType() {
        return defaultContentType;
    }

    /**
     * Sets the value of the defaultContentType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDefaultContentType(String value) {
        this.defaultContentType = value;
    }

    /**
     * Gets the value of the defaultEncoding property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDefaultEncoding() {
        return defaultEncoding;
    }

    /**
     * Sets the value of the defaultEncoding property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDefaultEncoding(String value) {
        this.defaultEncoding = value;
    }

    /**
     * Gets the value of the delay property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDelay() {
        return delay;
    }

    /**
     * Sets the value of the delay property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDelay(Integer value) {
        this.delay = value;
    }

    /**
     * Gets the value of the disableDnsResolution property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isDisableDnsResolution() {
        return disableDnsResolution;
    }

    /**
     * Sets the value of the disableDnsResolution property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setDisableDnsResolution(java.lang.Boolean value) {
        this.disableDnsResolution = value;
    }

    /**
     * Gets the value of the disableGraph property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isDisableGraph() {
        return disableGraph;
    }

    /**
     * Sets the value of the disableGraph property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setDisableGraph(java.lang.Boolean value) {
        this.disableGraph = value;
    }

    /**
     * Gets the value of the disableLog property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isDisableLog() {
        return disableLog;
    }

    /**
     * Sets the value of the disableLog property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setDisableLog(java.lang.Boolean value) {
        this.disableLog = value;
    }

    /**
     * Gets the value of the enableAcl property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isEnableAcl() {
        return enableAcl;
    }

    /**
     * Sets the value of the enableAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setEnableAcl(java.lang.Boolean value) {
        this.enableAcl = value;
    }

    /**
     * Gets the value of the enableFetchCompression property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isEnableFetchCompression() {
        return enableFetchCompression;
    }

    /**
     * Sets the value of the enableFetchCompression property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setEnableFetchCompression(java.lang.Boolean value) {
        this.enableFetchCompression = value;
    }

    /**
     * Gets the value of the encodingReplacements property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEncodingReplacements() {
        return encodingReplacements;
    }

    /**
     * Sets the value of the encodingReplacements property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEncodingReplacements(String value) {
        this.encodingReplacements = value;
    }

    /**
     * Gets the value of the enqueueInputThreshold property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEnqueueInputThreshold() {
        return enqueueInputThreshold;
    }

    /**
     * Sets the value of the enqueueInputThreshold property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEnqueueInputThreshold(Integer value) {
        this.enqueueInputThreshold = value;
    }

    /**
     * Gets the value of the enqueuePersistence property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnqueuePersistence() {
        return enqueuePersistence;
    }

    /**
     * Sets the value of the enqueuePersistence property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnqueuePersistence(String value) {
        this.enqueuePersistence = value;
    }

    /**
     * Gets the value of the errorExpires property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getErrorExpires() {
        return errorExpires;
    }

    /**
     * Sets the value of the errorExpires property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setErrorExpires(Integer value) {
        this.errorExpires = value;
    }

    /**
     * Gets the value of the expires property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getExpires() {
        return expires;
    }

    /**
     * Sets the value of the expires property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setExpires(Integer value) {
        this.expires = value;
    }

    /**
     * Gets the value of the filterExactDuplicates property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isFilterExactDuplicates() {
        return filterExactDuplicates;
    }

    /**
     * Sets the value of the filterExactDuplicates property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setFilterExactDuplicates(java.lang.Boolean value) {
        this.filterExactDuplicates = value;
    }

    /**
     * Gets the value of the forceRecrawl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForceRecrawl() {
        return forceRecrawl;
    }

    /**
     * Sets the value of the forceRecrawl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForceRecrawl(String value) {
        this.forceRecrawl = value;
    }

    /**
     * Gets the value of the forcedContentType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForcedContentType() {
        return forcedContentType;
    }

    /**
     * Sets the value of the forcedContentType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForcedContentType(String value) {
        this.forcedContentType = value;
    }

    /**
     * Gets the value of the ftplistonly property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isFtplistonly() {
        return ftplistonly;
    }

    /**
     * Sets the value of the ftplistonly property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setFtplistonly(java.lang.Boolean value) {
        this.ftplistonly = value;
    }

    /**
     * Gets the value of the fullLogging property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFullLogging() {
        return fullLogging;
    }

    /**
     * Sets the value of the fullLogging property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFullLogging(String value) {
        this.fullLogging = value;
    }

    /**
     * Gets the value of the graph property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isGraph() {
        return graph;
    }

    /**
     * Sets the value of the graph property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setGraph(java.lang.Boolean value) {
        this.graph = value;
    }

    /**
     * Gets the value of the header property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHeader() {
        return header;
    }

    /**
     * Sets the value of the header property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHeader(String value) {
        this.header = value;
    }

    /**
     * Gets the value of the httpAuth property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHttpAuth() {
        return httpAuth;
    }

    /**
     * Sets the value of the httpAuth property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHttpAuth(String value) {
        this.httpAuth = value;
    }

    /**
     * Gets the value of the httpProxyAuth property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHttpProxyAuth() {
        return httpProxyAuth;
    }

    /**
     * Sets the value of the httpProxyAuth property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHttpProxyAuth(String value) {
        this.httpProxyAuth = value;
    }

    /**
     * Gets the value of the httpVersion property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHttpVersion() {
        return httpVersion;
    }

    /**
     * Sets the value of the httpVersion property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHttpVersion(String value) {
        this.httpVersion = value;
    }

    /**
     * Gets the value of the ignoreReportedEncoding property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isIgnoreReportedEncoding() {
        return ignoreReportedEncoding;
    }

    /**
     * Sets the value of the ignoreReportedEncoding property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setIgnoreReportedEncoding(java.lang.Boolean value) {
        this.ignoreReportedEncoding = value;
    }

    /**
     * Gets the value of the ignoreRobots property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isIgnoreRobots() {
        return ignoreRobots;
    }

    /**
     * Sets the value of the ignoreRobots property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setIgnoreRobots(java.lang.Boolean value) {
        this.ignoreRobots = value;
    }

    /**
     * Gets the value of the immediatePersistence property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getImmediatePersistence() {
        return immediatePersistence;
    }

    /**
     * Sets the value of the immediatePersistence property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setImmediatePersistence(String value) {
        this.immediatePersistence = value;
    }

    /**
     * Gets the value of the interface property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInterface() {
        return _interface;
    }

    /**
     * Sets the value of the interface property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInterface(String value) {
        this._interface = value;
    }

    /**
     * Gets the value of the internalMaxRedirs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getInternalMaxRedirs() {
        return internalMaxRedirs;
    }

    /**
     * Sets the value of the internalMaxRedirs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setInternalMaxRedirs(Integer value) {
        this.internalMaxRedirs = value;
    }

    /**
     * Gets the value of the lazyPersistence property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLazyPersistence() {
        return lazyPersistence;
    }

    /**
     * Sets the value of the lazyPersistence property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLazyPersistence(String value) {
        this.lazyPersistence = value;
    }

    /**
     * Gets the value of the log property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isLog() {
        return log;
    }

    /**
     * Sets the value of the log property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setLog(java.lang.Boolean value) {
        this.log = value;
    }

    /**
     * Gets the value of the maxBytes property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getMaxBytes() {
        return maxBytes;
    }

    /**
     * Sets the value of the maxBytes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setMaxBytes(Long value) {
        this.maxBytes = value;
    }

    /**
     * Gets the value of the maxDataSize property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getMaxDataSize() {
        return maxDataSize;
    }

    /**
     * Sets the value of the maxDataSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setMaxDataSize(Long value) {
        this.maxDataSize = value;
    }

    /**
     * Gets the value of the maxExportSize property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getMaxExportSize() {
        return maxExportSize;
    }

    /**
     * Sets the value of the maxExportSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setMaxExportSize(Double value) {
        this.maxExportSize = value;
    }

    /**
     * Gets the value of the maxHops property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxHops() {
        return maxHops;
    }

    /**
     * Sets the value of the maxHops property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxHops(Integer value) {
        this.maxHops = value;
    }

    /**
     * Gets the value of the maxRedirs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxRedirs() {
        return maxRedirs;
    }

    /**
     * Sets the value of the maxRedirs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxRedirs(Integer value) {
        this.maxRedirs = value;
    }

    /**
     * Gets the value of the maxSlashes property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxSlashes() {
        return maxSlashes;
    }

    /**
     * Sets the value of the maxSlashes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxSlashes(Integer value) {
        this.maxSlashes = value;
    }

    /**
     * Gets the value of the maxUrlLen property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxUrlLen() {
        return maxUrlLen;
    }

    /**
     * Sets the value of the maxUrlLen property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxUrlLen(Integer value) {
        this.maxUrlLen = value;
    }

    /**
     * Gets the value of the method property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMethod() {
        return method;
    }

    /**
     * Sets the value of the method property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMethod(String value) {
        this.method = value;
    }

    /**
     * Gets the value of the minimalLogging property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMinimalLogging() {
        return minimalLogging;
    }

    /**
     * Sets the value of the minimalLogging property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMinimalLogging(String value) {
        this.minimalLogging = value;
    }

    /**
     * Gets the value of the nConcurrentRequests property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNConcurrentRequests() {
        return nConcurrentRequests;
    }

    /**
     * Sets the value of the nConcurrentRequests property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNConcurrentRequests(Integer value) {
        this.nConcurrentRequests = value;
    }

    /**
     * Gets the value of the post property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPost() {
        return post;
    }

    /**
     * Sets the value of the post property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPost(String value) {
        this.post = value;
    }

    /**
     * Gets the value of the priority property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getPriority() {
        return priority;
    }

    /**
     * Sets the value of the priority property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPriority(Integer value) {
        this.priority = value;
    }

    /**
     * Gets the value of the proxy property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProxy() {
        return proxy;
    }

    /**
     * Sets the value of the proxy property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProxy(String value) {
        this.proxy = value;
    }

    /**
     * Gets the value of the proxyPort property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProxyPort() {
        return proxyPort;
    }

    /**
     * Sets the value of the proxyPort property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProxyPort(String value) {
        this.proxyPort = value;
    }

    /**
     * Gets the value of the proxyUserPassword property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProxyUserPassword() {
        return proxyUserPassword;
    }

    /**
     * Sets the value of the proxyUserPassword property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProxyUserPassword(String value) {
        this.proxyUserPassword = value;
    }

    /**
     * Gets the value of the purgeAllXml property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isPurgeAllXml() {
        return purgeAllXml;
    }

    /**
     * Sets the value of the purgeAllXml property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setPurgeAllXml(java.lang.Boolean value) {
        this.purgeAllXml = value;
    }

    /**
     * Gets the value of the purgeCompleteXml property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isPurgeCompleteXml() {
        return purgeCompleteXml;
    }

    /**
     * Sets the value of the purgeCompleteXml property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setPurgeCompleteXml(java.lang.Boolean value) {
        this.purgeCompleteXml = value;
    }

    /**
     * Gets the value of the purgeInputXml property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isPurgeInputXml() {
        return purgeInputXml;
    }

    /**
     * Sets the value of the purgeInputXml property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setPurgeInputXml(java.lang.Boolean value) {
        this.purgeInputXml = value;
    }

    /**
     * Gets the value of the referer property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReferer() {
        return referer;
    }

    /**
     * Sets the value of the referer property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReferer(String value) {
        this.referer = value;
    }

    /**
     * Gets the value of the refinedLogging property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRefinedLogging() {
        return refinedLogging;
    }

    /**
     * Sets the value of the refinedLogging property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRefinedLogging(String value) {
        this.refinedLogging = value;
    }

    /**
     * Gets the value of the robots property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRobots() {
        return robots;
    }

    /**
     * Sets the value of the robots property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRobots(String value) {
        this.robots = value;
    }

    /**
     * Gets the value of the sslCaCert property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSslCaCert() {
        return sslCaCert;
    }

    /**
     * Sets the value of the sslCaCert property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSslCaCert(String value) {
        this.sslCaCert = value;
    }

    /**
     * Gets the value of the sslCert property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSslCert() {
        return sslCert;
    }

    /**
     * Sets the value of the sslCert property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSslCert(String value) {
        this.sslCert = value;
    }

    /**
     * Gets the value of the sslCertType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSslCertType() {
        return sslCertType;
    }

    /**
     * Sets the value of the sslCertType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSslCertType(String value) {
        this.sslCertType = value;
    }

    /**
     * Gets the value of the sslKey property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSslKey() {
        return sslKey;
    }

    /**
     * Sets the value of the sslKey property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSslKey(String value) {
        this.sslKey = value;
    }

    /**
     * Gets the value of the sslKeyPassword property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSslKeyPassword() {
        return sslKeyPassword;
    }

    /**
     * Sets the value of the sslKeyPassword property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSslKeyPassword(String value) {
        this.sslKeyPassword = value;
    }

    /**
     * Gets the value of the sslKeyType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSslKeyType() {
        return sslKeyType;
    }

    /**
     * Sets the value of the sslKeyType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSslKeyType(String value) {
        this.sslKeyType = value;
    }

    /**
     * Gets the value of the sslVerifyPeer property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSslVerifyPeer() {
        return sslVerifyPeer;
    }

    /**
     * Sets the value of the sslVerifyPeer property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSslVerifyPeer(String value) {
        this.sslVerifyPeer = value;
    }

    /**
     * Gets the value of the sslVersion property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSslVersion() {
        return sslVersion;
    }

    /**
     * Sets the value of the sslVersion property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSslVersion(String value) {
        this.sslVersion = value;
    }

    /**
     * Gets the value of the testConversion property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTestConversion() {
        return testConversion;
    }

    /**
     * Sets the value of the testConversion property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTestConversion(Integer value) {
        this.testConversion = value;
    }

    /**
     * Gets the value of the testConversionDebugId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTestConversionDebugId() {
        return testConversionDebugId;
    }

    /**
     * Sets the value of the testConversionDebugId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTestConversionDebugId(String value) {
        this.testConversionDebugId = value;
    }

    /**
     * Gets the value of the testConversionId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTestConversionId() {
        return testConversionId;
    }

    /**
     * Sets the value of the testConversionId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTestConversionId(Integer value) {
        this.testConversionId = value;
    }

    /**
     * Gets the value of the timeout property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTimeout() {
        return timeout;
    }

    /**
     * Sets the value of the timeout property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTimeout(Integer value) {
        this.timeout = value;
    }

    /**
     * Gets the value of the uncrawledExpires property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getUncrawledExpires() {
        return uncrawledExpires;
    }

    /**
     * Sets the value of the uncrawledExpires property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setUncrawledExpires(Integer value) {
        this.uncrawledExpires = value;
    }

    /**
     * Gets the value of the urlLogging property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrlLogging() {
        return urlLogging;
    }

    /**
     * Sets the value of the urlLogging property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrlLogging(String value) {
        this.urlLogging = value;
    }

    /**
     * Gets the value of the userAgent property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUserAgent() {
        return userAgent;
    }

    /**
     * Sets the value of the userAgent property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUserAgent(String value) {
        this.userAgent = value;
    }

    /**
     * Gets the value of the userPassword property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUserPassword() {
        return userPassword;
    }

    /**
     * Sets the value of the userPassword property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUserPassword(String value) {
        this.userPassword = value;
    }

}
