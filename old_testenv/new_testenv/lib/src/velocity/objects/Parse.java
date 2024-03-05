
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlMixed;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}parse-param"/>
 *       &lt;/choice>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}parse"/>
 *       &lt;attribute name="query" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="new-cookies" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="base-url" type="{http://www.w3.org/2001/XMLSchema}anyURI" />
 *       &lt;attribute name="ref" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="depth" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="debug-id" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="parse-debug-type">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="xsl"/>
 *             &lt;enumeration value="regexp"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="parse-debug-id" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="http-status" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="body-length" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="retrieved" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="start-time" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="end-time" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="parsing-time" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="status">
 *         &lt;simpleType>
 *           &lt;list>
 *             &lt;simpleType>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *                 &lt;enumeration value="processed"/>
 *                 &lt;enumeration value="skipped"/>
 *                 &lt;enumeration value="partially-fetched"/>
 *                 &lt;enumeration value="parsing-failed"/>
 *                 &lt;enumeration value="parsed"/>
 *                 &lt;enumeration value="failed"/>
 *                 &lt;enumeration value="connection-failed"/>
 *                 &lt;enumeration value="dns-timeout"/>
 *                 &lt;enumeration value="timeout"/>
 *                 &lt;enumeration value="url-encoding-error"/>
 *                 &lt;enumeration value="content-encoding-error"/>
 *                 &lt;enumeration value="fetched"/>
 *                 &lt;enumeration value="redirected"/>
 *                 &lt;enumeration value="cached"/>
 *                 &lt;enumeration value="not-redirected"/>
 *                 &lt;enumeration value="http-error"/>
 *                 &lt;enumeration value="too-deep"/>
 *                 &lt;enumeration value="malformed-url"/>
 *                 &lt;enumeration value="base64-decoding-failed"/>
 *               &lt;/restriction>
 *             &lt;/simpleType>
 *           &lt;/list>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="encode">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="encode"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "content"
})
@XmlRootElement(name = "parse")
public class Parse {

    @XmlElementRef(name = "parse-param", namespace = "urn:/velocity/objects", type = ParseParam.class)
    @XmlMixed
    protected List<Object> content;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String query;
    @XmlAttribute(name = "new-cookies")
    protected String newCookies;
    @XmlAttribute(name = "base-url")
    @XmlSchemaType(name = "anyURI")
    protected String baseUrl;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String ref;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long depth;
    @XmlAttribute(name = "debug-id")
    @XmlSchemaType(name = "unsignedInt")
    protected Long debugId;
    @XmlAttribute(name = "parse-debug-type")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String parseDebugType;
    @XmlAttribute(name = "parse-debug-id")
    @XmlSchemaType(name = "unsignedInt")
    protected Long parseDebugId;
    @XmlAttribute(name = "http-status")
    protected String httpStatus;
    @XmlAttribute(name = "body-length")
    protected String bodyLength;
    @XmlAttribute
    protected Integer retrieved;
    @XmlAttribute(name = "start-time")
    protected Integer startTime;
    @XmlAttribute(name = "end-time")
    protected Integer endTime;
    @XmlAttribute(name = "parsing-time")
    protected Integer parsingTime;
    @XmlAttribute
    protected List<String> status;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String encode;
    @XmlAttribute
    protected java.lang.Boolean async;
    @XmlAttribute(name = "elt-id")
    protected Integer eltId;
    @XmlAttribute(name = "max-elt-id")
    protected Integer maxEltId;
    @XmlAttribute(name = "execute-acl")
    protected String executeAcl;
    @XmlAttribute
    protected String process;
    @XmlAttribute
    @XmlSchemaType(name = "anyURI")
    protected String url;
    @XmlAttribute
    @XmlSchemaType(name = "anyURI")
    protected String uri;
    @XmlAttribute(name = "paging-url")
    @XmlSchemaType(name = "anyURI")
    protected String pagingUrl;
    @XmlAttribute(name = "paging-doc-cond-url")
    @XmlSchemaType(name = "anyURI")
    protected String pagingDocCondUrl;
    @XmlAttribute(name = "url-encoding")
    protected String urlEncoding;
    @XmlAttribute
    protected String filename;
    @XmlAttribute(name = "display-url")
    @XmlSchemaType(name = "anyURI")
    protected String displayUrl;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String source;
    @XmlAttribute
    protected String encoding;
    @XmlAttribute(name = "headers-sent")
    protected String headersSent;
    @XmlAttribute(name = "headers-received")
    protected String headersReceived;
    @XmlAttribute(name = "post-data")
    protected String postData;
    @XmlAttribute
    protected String message;
    @XmlAttribute(name = "disable-global-timeout")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String disableGlobalTimeout;
    @XmlAttribute(name = "base-64-encoded")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String base64Encoded;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long start;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long per;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long page;
    @XmlAttribute
    protected Double weight;
    @XmlAttribute
    protected String parser;
    @XmlAttribute(name = "root-id")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String rootId;
    @XmlAttribute
    protected String inherit;
    @XmlAttribute(name = "process-output")
    protected String processOutput;
    @XmlAttribute
    protected String headers;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String username;
    @XmlAttribute
    protected String password;
    @XmlAttribute
    protected Method method;
    @XmlAttribute(name = "xml-container")
    protected String xmlContainer;
    @XmlAttribute(name = "xml-namespace-url")
    protected String xmlNamespaceUrl;
    @XmlAttribute(name = "content-type")
    protected String contentType;
    @XmlAttribute
    protected String separator;
    @XmlAttribute(name = "ignore-http-status")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String ignoreHttpStatus;
    @XmlAttribute(name = "disable-compression")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String disableCompression;
    @XmlAttribute(name = "store-headers")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String storeHeaders;
    @XmlAttribute(name = "ssl-version")
    protected String sslVersion;
    @XmlAttribute(name = "ssl-cert")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String sslCert;
    @XmlAttribute(name = "ssl-cert-type")
    protected String sslCertType;
    @XmlAttribute(name = "ssl-key")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String sslKey;
    @XmlAttribute(name = "ssl-key-type")
    protected String sslKeyType;
    @XmlAttribute(name = "ssl-key-password")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String sslKeyPassword;
    @XmlAttribute(name = "ssl-verify-peer")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String sslVerifyPeer;
    @XmlAttribute(name = "cookie-jar")
    protected String cookieJar;
    @XmlAttribute
    protected String timeout;
    @XmlAttribute(name = "max-size")
    protected String maxSize;
    @XmlAttribute
    protected String proxy;
    @XmlAttribute(name = "proxy-user-password")
    protected String proxyUserPassword;
    @XmlAttribute(name = "cache-write")
    protected java.lang.Boolean cacheWrite;
    @XmlAttribute(name = "cache-read")
    protected java.lang.Boolean cacheRead;
    @XmlAttribute(name = "cache-max-age")
    protected Integer cacheMaxAge;

    /**
     * Gets the value of the content property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the content property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getContent().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ParseParam }
     * {@link String }
     * 
     * 
     */
    public List<Object> getContent() {
        if (content == null) {
            content = new ArrayList<Object>();
        }
        return this.content;
    }

    /**
     * Gets the value of the query property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getQuery() {
        return query;
    }

    /**
     * Sets the value of the query property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setQuery(String value) {
        this.query = value;
    }

    /**
     * Gets the value of the newCookies property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNewCookies() {
        return newCookies;
    }

    /**
     * Sets the value of the newCookies property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNewCookies(String value) {
        this.newCookies = value;
    }

    /**
     * Gets the value of the baseUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBaseUrl() {
        return baseUrl;
    }

    /**
     * Sets the value of the baseUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBaseUrl(String value) {
        this.baseUrl = value;
    }

    /**
     * Gets the value of the ref property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRef() {
        return ref;
    }

    /**
     * Sets the value of the ref property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRef(String value) {
        this.ref = value;
    }

    /**
     * Gets the value of the depth property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getDepth() {
        return depth;
    }

    /**
     * Sets the value of the depth property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setDepth(Long value) {
        this.depth = value;
    }

    /**
     * Gets the value of the debugId property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getDebugId() {
        return debugId;
    }

    /**
     * Sets the value of the debugId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setDebugId(Long value) {
        this.debugId = value;
    }

    /**
     * Gets the value of the parseDebugType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getParseDebugType() {
        return parseDebugType;
    }

    /**
     * Sets the value of the parseDebugType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setParseDebugType(String value) {
        this.parseDebugType = value;
    }

    /**
     * Gets the value of the parseDebugId property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getParseDebugId() {
        return parseDebugId;
    }

    /**
     * Sets the value of the parseDebugId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setParseDebugId(Long value) {
        this.parseDebugId = value;
    }

    /**
     * Gets the value of the httpStatus property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHttpStatus() {
        return httpStatus;
    }

    /**
     * Sets the value of the httpStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHttpStatus(String value) {
        this.httpStatus = value;
    }

    /**
     * Gets the value of the bodyLength property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBodyLength() {
        return bodyLength;
    }

    /**
     * Sets the value of the bodyLength property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBodyLength(String value) {
        this.bodyLength = value;
    }

    /**
     * Gets the value of the retrieved property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRetrieved() {
        return retrieved;
    }

    /**
     * Sets the value of the retrieved property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRetrieved(Integer value) {
        this.retrieved = value;
    }

    /**
     * Gets the value of the startTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStartTime() {
        return startTime;
    }

    /**
     * Sets the value of the startTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStartTime(Integer value) {
        this.startTime = value;
    }

    /**
     * Gets the value of the endTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEndTime() {
        return endTime;
    }

    /**
     * Sets the value of the endTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEndTime(Integer value) {
        this.endTime = value;
    }

    /**
     * Gets the value of the parsingTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getParsingTime() {
        return parsingTime;
    }

    /**
     * Sets the value of the parsingTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setParsingTime(Integer value) {
        this.parsingTime = value;
    }

    /**
     * Gets the value of the status property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the status property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getStatus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * 
     * 
     */
    public List<String> getStatus() {
        if (status == null) {
            status = new ArrayList<String>();
        }
        return this.status;
    }

    /**
     * Gets the value of the encode property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEncode() {
        return encode;
    }

    /**
     * Sets the value of the encode property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEncode(String value) {
        this.encode = value;
    }

    /**
     * Gets the value of the async property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isAsync() {
        if (async == null) {
            return true;
        } else {
            return async;
        }
    }

    /**
     * Sets the value of the async property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setAsync(java.lang.Boolean value) {
        this.async = value;
    }

    /**
     * Gets the value of the eltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEltId() {
        return eltId;
    }

    /**
     * Sets the value of the eltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEltId(Integer value) {
        this.eltId = value;
    }

    /**
     * Gets the value of the maxEltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxEltId() {
        return maxEltId;
    }

    /**
     * Sets the value of the maxEltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxEltId(Integer value) {
        this.maxEltId = value;
    }

    /**
     * Gets the value of the executeAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExecuteAcl() {
        return executeAcl;
    }

    /**
     * Sets the value of the executeAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExecuteAcl(String value) {
        this.executeAcl = value;
    }

    /**
     * Gets the value of the process property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProcess() {
        return process;
    }

    /**
     * Sets the value of the process property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProcess(String value) {
        this.process = value;
    }

    /**
     * Gets the value of the url property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrl() {
        return url;
    }

    /**
     * Sets the value of the url property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrl(String value) {
        this.url = value;
    }

    /**
     * Gets the value of the uri property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUri() {
        return uri;
    }

    /**
     * Sets the value of the uri property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUri(String value) {
        this.uri = value;
    }

    /**
     * Gets the value of the pagingUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPagingUrl() {
        return pagingUrl;
    }

    /**
     * Sets the value of the pagingUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPagingUrl(String value) {
        this.pagingUrl = value;
    }

    /**
     * Gets the value of the pagingDocCondUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPagingDocCondUrl() {
        return pagingDocCondUrl;
    }

    /**
     * Sets the value of the pagingDocCondUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPagingDocCondUrl(String value) {
        this.pagingDocCondUrl = value;
    }

    /**
     * Gets the value of the urlEncoding property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrlEncoding() {
        if (urlEncoding == null) {
            return "UTF-8";
        } else {
            return urlEncoding;
        }
    }

    /**
     * Sets the value of the urlEncoding property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrlEncoding(String value) {
        this.urlEncoding = value;
    }

    /**
     * Gets the value of the filename property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFilename() {
        return filename;
    }

    /**
     * Sets the value of the filename property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFilename(String value) {
        this.filename = value;
    }

    /**
     * Gets the value of the displayUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisplayUrl() {
        return displayUrl;
    }

    /**
     * Sets the value of the displayUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisplayUrl(String value) {
        this.displayUrl = value;
    }

    /**
     * Gets the value of the source property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSource() {
        return source;
    }

    /**
     * Sets the value of the source property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSource(String value) {
        this.source = value;
    }

    /**
     * Gets the value of the encoding property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEncoding() {
        return encoding;
    }

    /**
     * Sets the value of the encoding property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEncoding(String value) {
        this.encoding = value;
    }

    /**
     * Gets the value of the headersSent property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHeadersSent() {
        return headersSent;
    }

    /**
     * Sets the value of the headersSent property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHeadersSent(String value) {
        this.headersSent = value;
    }

    /**
     * Gets the value of the headersReceived property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHeadersReceived() {
        return headersReceived;
    }

    /**
     * Sets the value of the headersReceived property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHeadersReceived(String value) {
        this.headersReceived = value;
    }

    /**
     * Gets the value of the postData property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPostData() {
        return postData;
    }

    /**
     * Sets the value of the postData property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPostData(String value) {
        this.postData = value;
    }

    /**
     * Gets the value of the message property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMessage() {
        return message;
    }

    /**
     * Sets the value of the message property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMessage(String value) {
        this.message = value;
    }

    /**
     * Gets the value of the disableGlobalTimeout property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisableGlobalTimeout() {
        return disableGlobalTimeout;
    }

    /**
     * Sets the value of the disableGlobalTimeout property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisableGlobalTimeout(String value) {
        this.disableGlobalTimeout = value;
    }

    /**
     * Gets the value of the base64Encoded property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBase64Encoded() {
        return base64Encoded;
    }

    /**
     * Sets the value of the base64Encoded property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBase64Encoded(String value) {
        this.base64Encoded = value;
    }

    /**
     * Gets the value of the start property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public long getStart() {
        if (start == null) {
            return  0L;
        } else {
            return start;
        }
    }

    /**
     * Sets the value of the start property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setStart(Long value) {
        this.start = value;
    }

    /**
     * Gets the value of the per property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getPer() {
        return per;
    }

    /**
     * Sets the value of the per property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setPer(Long value) {
        this.per = value;
    }

    /**
     * Gets the value of the page property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getPage() {
        return page;
    }

    /**
     * Sets the value of the page property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setPage(Long value) {
        this.page = value;
    }

    /**
     * Gets the value of the weight property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getWeight() {
        if (weight == null) {
            return  1.0D;
        } else {
            return weight;
        }
    }

    /**
     * Sets the value of the weight property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setWeight(Double value) {
        this.weight = value;
    }

    /**
     * Gets the value of the parser property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getParser() {
        return parser;
    }

    /**
     * Sets the value of the parser property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setParser(String value) {
        this.parser = value;
    }

    /**
     * Gets the value of the rootId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRootId() {
        return rootId;
    }

    /**
     * Sets the value of the rootId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRootId(String value) {
        this.rootId = value;
    }

    /**
     * Gets the value of the inherit property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInherit() {
        if (inherit == null) {
            return "per parser method url-encoding display-url source encoding username password content-type proxy proxy-user-password max-size weight id disable-global-timeout ssl-cert ssl-cert-type ssl-key ssl-key-type ssl-key-password ssl-verify-peer store-headers";
        } else {
            return inherit;
        }
    }

    /**
     * Sets the value of the inherit property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInherit(String value) {
        this.inherit = value;
    }

    /**
     * Gets the value of the processOutput property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProcessOutput() {
        return processOutput;
    }

    /**
     * Sets the value of the processOutput property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProcessOutput(String value) {
        this.processOutput = value;
    }

    /**
     * Gets the value of the headers property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHeaders() {
        return headers;
    }

    /**
     * Sets the value of the headers property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHeaders(String value) {
        this.headers = value;
    }

    /**
     * Gets the value of the username property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUsername() {
        return username;
    }

    /**
     * Sets the value of the username property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUsername(String value) {
        this.username = value;
    }

    /**
     * Gets the value of the password property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPassword() {
        return password;
    }

    /**
     * Sets the value of the password property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPassword(String value) {
        this.password = value;
    }

    /**
     * Gets the value of the method property.
     * 
     * @return
     *     possible object is
     *     {@link Method }
     *     
     */
    public Method getMethod() {
        if (method == null) {
            return Method.GET;
        } else {
            return method;
        }
    }

    /**
     * Sets the value of the method property.
     * 
     * @param value
     *     allowed object is
     *     {@link Method }
     *     
     */
    public void setMethod(Method value) {
        this.method = value;
    }

    /**
     * Gets the value of the xmlContainer property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getXmlContainer() {
        return xmlContainer;
    }

    /**
     * Sets the value of the xmlContainer property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setXmlContainer(String value) {
        this.xmlContainer = value;
    }

    /**
     * Gets the value of the xmlNamespaceUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getXmlNamespaceUrl() {
        return xmlNamespaceUrl;
    }

    /**
     * Sets the value of the xmlNamespaceUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setXmlNamespaceUrl(String value) {
        this.xmlNamespaceUrl = value;
    }

    /**
     * Gets the value of the contentType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getContentType() {
        return contentType;
    }

    /**
     * Sets the value of the contentType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setContentType(String value) {
        this.contentType = value;
    }

    /**
     * Gets the value of the separator property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSeparator() {
        if (separator == null) {
            return "&";
        } else {
            return separator;
        }
    }

    /**
     * Sets the value of the separator property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSeparator(String value) {
        this.separator = value;
    }

    /**
     * Gets the value of the ignoreHttpStatus property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIgnoreHttpStatus() {
        return ignoreHttpStatus;
    }

    /**
     * Sets the value of the ignoreHttpStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIgnoreHttpStatus(String value) {
        this.ignoreHttpStatus = value;
    }

    /**
     * Gets the value of the disableCompression property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisableCompression() {
        return disableCompression;
    }

    /**
     * Sets the value of the disableCompression property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisableCompression(String value) {
        this.disableCompression = value;
    }

    /**
     * Gets the value of the storeHeaders property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStoreHeaders() {
        return storeHeaders;
    }

    /**
     * Sets the value of the storeHeaders property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStoreHeaders(String value) {
        this.storeHeaders = value;
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
        if (sslVersion == null) {
            return "Any";
        } else {
            return sslVersion;
        }
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
        if (sslCertType == null) {
            return "pem";
        } else {
            return sslCertType;
        }
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
     * Gets the value of the sslKeyType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSslKeyType() {
        if (sslKeyType == null) {
            return "pem";
        } else {
            return sslKeyType;
        }
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
     * Gets the value of the cookieJar property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCookieJar() {
        return cookieJar;
    }

    /**
     * Sets the value of the cookieJar property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCookieJar(String value) {
        this.cookieJar = value;
    }

    /**
     * Gets the value of the timeout property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTimeout() {
        return timeout;
    }

    /**
     * Sets the value of the timeout property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTimeout(String value) {
        this.timeout = value;
    }

    /**
     * Gets the value of the maxSize property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMaxSize() {
        if (maxSize == null) {
            return "-1";
        } else {
            return maxSize;
        }
    }

    /**
     * Sets the value of the maxSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMaxSize(String value) {
        this.maxSize = value;
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
     * Gets the value of the cacheWrite property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isCacheWrite() {
        if (cacheWrite == null) {
            return false;
        } else {
            return cacheWrite;
        }
    }

    /**
     * Sets the value of the cacheWrite property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setCacheWrite(java.lang.Boolean value) {
        this.cacheWrite = value;
    }

    /**
     * Gets the value of the cacheRead property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isCacheRead() {
        if (cacheRead == null) {
            return false;
        } else {
            return cacheRead;
        }
    }

    /**
     * Sets the value of the cacheRead property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setCacheRead(java.lang.Boolean value) {
        this.cacheRead = value;
    }

    /**
     * Gets the value of the cacheMaxAge property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getCacheMaxAge() {
        if (cacheMaxAge == null) {
            return -1;
        } else {
            return cacheMaxAge;
        }
    }

    /**
     * Sets the value of the cacheMaxAge property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCacheMaxAge(Integer value) {
        this.cacheMaxAge = value;
    }

}
