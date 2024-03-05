
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}scope"/>
 *         &lt;choice maxOccurs="unbounded" minOccurs="0">
 *           &lt;element ref="{urn:/velocity/objects}input"/>
 *           &lt;element ref="{urn:/velocity/objects}select"/>
 *           &lt;element ref="{urn:/velocity/objects}parse"/>
 *         &lt;/choice>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}form"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}repository"/>
 *       &lt;attribute name="name" type="{urn:/velocity/objects}nmtoken-or-anonymous" />
 *       &lt;attribute name="action" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="display-action" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="encoding" type="{urn:/velocity/objects}encoding" default="UTF-8" />
 *       &lt;attribute name="output-encoding" type="{urn:/velocity/objects}encoding" />
 *       &lt;attribute name="status">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="resolved"/>
 *             &lt;enumeration value="trans-failed"/>
 *             &lt;enumeration value="trans-succeeded"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="max" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="max-over-request" type="{http://www.w3.org/2001/XMLSchema}double" default="1" />
 *       &lt;attribute name="multimax" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="transform" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="normalized">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="normalized"/>
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
    "scope",
    "inputOrSelectOrParse"
})
@XmlRootElement(name = "form")
public class Form {

    @XmlElement(required = true)
    protected Scope scope;
    @XmlElements({
        @XmlElement(name = "parse", type = Parse.class),
        @XmlElement(name = "select", type = Select.class),
        @XmlElement(name = "input", type = Input.class)
    })
    protected List<Object> inputOrSelectOrParse;
    @XmlAttribute
    protected String name;
    @XmlAttribute
    protected String action;
    @XmlAttribute(name = "display-action")
    protected String displayAction;
    @XmlAttribute
    protected String encoding;
    @XmlAttribute(name = "output-encoding")
    protected String outputEncoding;
    @XmlAttribute
    protected String status;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long max;
    @XmlAttribute(name = "max-over-request")
    protected Double maxOverRequest;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long multimax;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String transform;
    @XmlAttribute
    protected String normalized;
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
    protected String internal;
    @XmlAttribute
    protected String overrides;
    @XmlAttribute(name = "overrides-status")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String overridesStatus;
    @XmlAttribute(name = "no-override")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String noOverride;
    @XmlAttribute
    protected Integer modified;
    @XmlAttribute(name = "modified-by")
    protected String modifiedBy;
    @XmlAttribute(name = "do-not-delete")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String doNotDelete;
    @XmlAttribute(name = "read-only")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String readOnly;
    @XmlAttribute
    protected List<String> products;

    /**
     * Gets the value of the scope property.
     * 
     * @return
     *     possible object is
     *     {@link Scope }
     *     
     */
    public Scope getScope() {
        return scope;
    }

    /**
     * Sets the value of the scope property.
     * 
     * @param value
     *     allowed object is
     *     {@link Scope }
     *     
     */
    public void setScope(Scope value) {
        this.scope = value;
    }

    /**
     * Gets the value of the inputOrSelectOrParse property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the inputOrSelectOrParse property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getInputOrSelectOrParse().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Parse }
     * {@link Select }
     * {@link Input }
     * 
     * 
     */
    public List<Object> getInputOrSelectOrParse() {
        if (inputOrSelectOrParse == null) {
            inputOrSelectOrParse = new ArrayList<Object>();
        }
        return this.inputOrSelectOrParse;
    }

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
    }

    /**
     * Gets the value of the action property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAction() {
        return action;
    }

    /**
     * Sets the value of the action property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAction(String value) {
        this.action = value;
    }

    /**
     * Gets the value of the displayAction property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisplayAction() {
        return displayAction;
    }

    /**
     * Sets the value of the displayAction property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisplayAction(String value) {
        this.displayAction = value;
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
        if (encoding == null) {
            return "UTF-8";
        } else {
            return encoding;
        }
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
     * Gets the value of the outputEncoding property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputEncoding() {
        return outputEncoding;
    }

    /**
     * Sets the value of the outputEncoding property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputEncoding(String value) {
        this.outputEncoding = value;
    }

    /**
     * Gets the value of the status property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStatus() {
        return status;
    }

    /**
     * Sets the value of the status property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStatus(String value) {
        this.status = value;
    }

    /**
     * Gets the value of the max property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getMax() {
        return max;
    }

    /**
     * Sets the value of the max property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setMax(Long value) {
        this.max = value;
    }

    /**
     * Gets the value of the maxOverRequest property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getMaxOverRequest() {
        if (maxOverRequest == null) {
            return  1.0D;
        } else {
            return maxOverRequest;
        }
    }

    /**
     * Sets the value of the maxOverRequest property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setMaxOverRequest(Double value) {
        this.maxOverRequest = value;
    }

    /**
     * Gets the value of the multimax property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getMultimax() {
        return multimax;
    }

    /**
     * Sets the value of the multimax property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setMultimax(Long value) {
        this.multimax = value;
    }

    /**
     * Gets the value of the transform property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTransform() {
        return transform;
    }

    /**
     * Sets the value of the transform property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTransform(String value) {
        this.transform = value;
    }

    /**
     * Gets the value of the normalized property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNormalized() {
        return normalized;
    }

    /**
     * Sets the value of the normalized property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNormalized(String value) {
        this.normalized = value;
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
     * Gets the value of the internal property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInternal() {
        return internal;
    }

    /**
     * Sets the value of the internal property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInternal(String value) {
        this.internal = value;
    }

    /**
     * Gets the value of the overrides property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOverrides() {
        return overrides;
    }

    /**
     * Sets the value of the overrides property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOverrides(String value) {
        this.overrides = value;
    }

    /**
     * Gets the value of the overridesStatus property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOverridesStatus() {
        return overridesStatus;
    }

    /**
     * Sets the value of the overridesStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOverridesStatus(String value) {
        this.overridesStatus = value;
    }

    /**
     * Gets the value of the noOverride property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNoOverride() {
        return noOverride;
    }

    /**
     * Sets the value of the noOverride property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNoOverride(String value) {
        this.noOverride = value;
    }

    /**
     * Gets the value of the modified property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getModified() {
        return modified;
    }

    /**
     * Sets the value of the modified property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setModified(Integer value) {
        this.modified = value;
    }

    /**
     * Gets the value of the modifiedBy property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getModifiedBy() {
        return modifiedBy;
    }

    /**
     * Sets the value of the modifiedBy property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setModifiedBy(String value) {
        this.modifiedBy = value;
    }

    /**
     * Gets the value of the doNotDelete property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDoNotDelete() {
        return doNotDelete;
    }

    /**
     * Sets the value of the doNotDelete property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDoNotDelete(String value) {
        this.doNotDelete = value;
    }

    /**
     * Gets the value of the readOnly property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReadOnly() {
        return readOnly;
    }

    /**
     * Sets the value of the readOnly property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReadOnly(String value) {
        this.readOnly = value;
    }

    /**
     * Gets the value of the products property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the products property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getProducts().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * 
     * 
     */
    public List<String> getProducts() {
        if (products == null) {
            products = new ArrayList<String>();
        }
        return this.products;
    }

}
