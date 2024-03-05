
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
 *         &lt;element ref="{urn:/velocity/objects}form" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}parser" minOccurs="0"/>
 *         &lt;choice maxOccurs="unbounded" minOccurs="0">
 *           &lt;element ref="{urn:/velocity/objects}parse"/>
 *           &lt;element ref="{urn:/velocity/objects}operator"/>
 *         &lt;/choice>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}submit"/>
 *       &lt;attribute name="num" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="start-rank" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="start-page" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="last-rank" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="last-page" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="repass" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="weight" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="source" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="min" type="{http://www.w3.org/2001/XMLSchema}int" default="1" />
 *       &lt;attribute name="max" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="multimax" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="forms">
 *         &lt;simpleType>
 *           &lt;list itemType="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="depth" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="status">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="translated"/>
 *             &lt;enumeration value="translation-failed"/>
 *             &lt;enumeration value="no-query"/>
 *             &lt;enumeration value="processing"/>
 *             &lt;enumeration value="skipped"/>
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
    "form",
    "parser",
    "parseOrOperator"
})
@XmlRootElement(name = "submit")
public class Submit {

    protected Form form;
    protected Parser parser;
    @XmlElements({
        @XmlElement(name = "operator", type = Operator.class),
        @XmlElement(name = "parse", type = Parse.class)
    })
    protected List<Object> parseOrOperator;
    @XmlAttribute
    protected Integer num;
    @XmlAttribute(name = "start-rank")
    protected Integer startRank;
    @XmlAttribute(name = "start-page")
    protected Integer startPage;
    @XmlAttribute(name = "last-rank")
    protected Integer lastRank;
    @XmlAttribute(name = "last-page")
    protected Integer lastPage;
    @XmlAttribute
    protected Integer repass;
    @XmlAttribute
    protected Double weight;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String source;
    @XmlAttribute
    protected Integer min;
    @XmlAttribute
    protected Integer max;
    @XmlAttribute
    protected Integer multimax;
    @XmlAttribute
    protected List<String> forms;
    @XmlAttribute
    protected Integer depth;
    @XmlAttribute
    protected String status;
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
     * Gets the value of the form property.
     * 
     * @return
     *     possible object is
     *     {@link Form }
     *     
     */
    public Form getForm() {
        return form;
    }

    /**
     * Sets the value of the form property.
     * 
     * @param value
     *     allowed object is
     *     {@link Form }
     *     
     */
    public void setForm(Form value) {
        this.form = value;
    }

    /**
     * Gets the value of the parser property.
     * 
     * @return
     *     possible object is
     *     {@link Parser }
     *     
     */
    public Parser getParser() {
        return parser;
    }

    /**
     * Sets the value of the parser property.
     * 
     * @param value
     *     allowed object is
     *     {@link Parser }
     *     
     */
    public void setParser(Parser value) {
        this.parser = value;
    }

    /**
     * Gets the value of the parseOrOperator property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the parseOrOperator property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getParseOrOperator().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Operator }
     * {@link Parse }
     * 
     * 
     */
    public List<Object> getParseOrOperator() {
        if (parseOrOperator == null) {
            parseOrOperator = new ArrayList<Object>();
        }
        return this.parseOrOperator;
    }

    /**
     * Gets the value of the num property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNum() {
        return num;
    }

    /**
     * Sets the value of the num property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNum(Integer value) {
        this.num = value;
    }

    /**
     * Gets the value of the startRank property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStartRank() {
        return startRank;
    }

    /**
     * Sets the value of the startRank property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStartRank(Integer value) {
        this.startRank = value;
    }

    /**
     * Gets the value of the startPage property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStartPage() {
        return startPage;
    }

    /**
     * Sets the value of the startPage property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStartPage(Integer value) {
        this.startPage = value;
    }

    /**
     * Gets the value of the lastRank property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getLastRank() {
        return lastRank;
    }

    /**
     * Sets the value of the lastRank property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setLastRank(Integer value) {
        this.lastRank = value;
    }

    /**
     * Gets the value of the lastPage property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getLastPage() {
        return lastPage;
    }

    /**
     * Sets the value of the lastPage property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setLastPage(Integer value) {
        this.lastPage = value;
    }

    /**
     * Gets the value of the repass property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRepass() {
        return repass;
    }

    /**
     * Sets the value of the repass property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRepass(Integer value) {
        this.repass = value;
    }

    /**
     * Gets the value of the weight property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getWeight() {
        return weight;
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
     * Gets the value of the min property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMin() {
        if (min == null) {
            return  1;
        } else {
            return min;
        }
    }

    /**
     * Sets the value of the min property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMin(Integer value) {
        this.min = value;
    }

    /**
     * Gets the value of the max property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMax() {
        return max;
    }

    /**
     * Sets the value of the max property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMax(Integer value) {
        this.max = value;
    }

    /**
     * Gets the value of the multimax property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMultimax() {
        return multimax;
    }

    /**
     * Sets the value of the multimax property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMultimax(Integer value) {
        this.multimax = value;
    }

    /**
     * Gets the value of the forms property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the forms property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getForms().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * 
     * 
     */
    public List<String> getForms() {
        if (forms == null) {
            forms = new ArrayList<String>();
        }
        return this.forms;
    }

    /**
     * Gets the value of the depth property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDepth() {
        return depth;
    }

    /**
     * Sets the value of the depth property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDepth(Integer value) {
        this.depth = value;
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
