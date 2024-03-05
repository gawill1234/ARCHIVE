
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *       &lt;attGroup ref="{urn:/velocity/objects}collection-service"/>
 *       &lt;attribute name="crawl-type">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="new"/>
 *             &lt;enumeration value="resume"/>
 *             &lt;enumeration value="resume-and-idle"/>
 *             &lt;enumeration value="refresh-inplace"/>
 *             &lt;enumeration value="refresh-new"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="full-merge">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="full-merge"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="email" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="dir" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="cmd" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="rerun" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="timeout" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="dont-kill-staging">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="dont-kill-staging"/>
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
@XmlType(name = "")
@XmlRootElement(name = "collection-service-service-start")
public class CollectionServiceServiceStart {

    @XmlAttribute(name = "crawl-type")
    protected String crawlType;
    @XmlAttribute(name = "full-merge")
    protected String fullMerge;
    @XmlAttribute
    protected String email;
    @XmlAttribute
    protected String dir;
    @XmlAttribute
    protected String cmd;
    @XmlAttribute
    protected java.lang.Boolean rerun;
    @XmlAttribute
    protected Integer timeout;
    @XmlAttribute(name = "dont-kill-staging")
    protected String dontKillStaging;
    @XmlAttribute
    protected String service;
    @XmlAttribute
    protected String subcollection;
    @XmlAttribute
    protected String token;
    @XmlAttribute(name = "config-md5")
    protected String configMd5;
    @XmlAttribute(name = "curr-config-md5")
    protected String currConfigMd5;
    @XmlAttribute(name = "crawler-config-md5")
    protected String crawlerConfigMd5;
    @XmlAttribute(name = "indexer-config-md5")
    protected String indexerConfigMd5;
    @XmlAttribute
    protected String error;

    /**
     * Gets the value of the crawlType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCrawlType() {
        return crawlType;
    }

    /**
     * Sets the value of the crawlType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCrawlType(String value) {
        this.crawlType = value;
    }

    /**
     * Gets the value of the fullMerge property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFullMerge() {
        return fullMerge;
    }

    /**
     * Sets the value of the fullMerge property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFullMerge(String value) {
        this.fullMerge = value;
    }

    /**
     * Gets the value of the email property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEmail() {
        return email;
    }

    /**
     * Sets the value of the email property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEmail(String value) {
        this.email = value;
    }

    /**
     * Gets the value of the dir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDir() {
        return dir;
    }

    /**
     * Sets the value of the dir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDir(String value) {
        this.dir = value;
    }

    /**
     * Gets the value of the cmd property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCmd() {
        return cmd;
    }

    /**
     * Sets the value of the cmd property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCmd(String value) {
        this.cmd = value;
    }

    /**
     * Gets the value of the rerun property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isRerun() {
        return rerun;
    }

    /**
     * Sets the value of the rerun property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setRerun(java.lang.Boolean value) {
        this.rerun = value;
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
     * Gets the value of the dontKillStaging property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDontKillStaging() {
        return dontKillStaging;
    }

    /**
     * Sets the value of the dontKillStaging property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDontKillStaging(String value) {
        this.dontKillStaging = value;
    }

    /**
     * Gets the value of the service property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getService() {
        return service;
    }

    /**
     * Sets the value of the service property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setService(String value) {
        this.service = value;
    }

    /**
     * Gets the value of the subcollection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSubcollection() {
        return subcollection;
    }

    /**
     * Sets the value of the subcollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSubcollection(String value) {
        this.subcollection = value;
    }

    /**
     * Gets the value of the token property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getToken() {
        return token;
    }

    /**
     * Sets the value of the token property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setToken(String value) {
        this.token = value;
    }

    /**
     * Gets the value of the configMd5 property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getConfigMd5() {
        return configMd5;
    }

    /**
     * Sets the value of the configMd5 property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setConfigMd5(String value) {
        this.configMd5 = value;
    }

    /**
     * Gets the value of the currConfigMd5 property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCurrConfigMd5() {
        return currConfigMd5;
    }

    /**
     * Sets the value of the currConfigMd5 property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCurrConfigMd5(String value) {
        this.currConfigMd5 = value;
    }

    /**
     * Gets the value of the crawlerConfigMd5 property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCrawlerConfigMd5() {
        return crawlerConfigMd5;
    }

    /**
     * Sets the value of the crawlerConfigMd5 property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCrawlerConfigMd5(String value) {
        this.crawlerConfigMd5 = value;
    }

    /**
     * Gets the value of the indexerConfigMd5 property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIndexerConfigMd5() {
        return indexerConfigMd5;
    }

    /**
     * Sets the value of the indexerConfigMd5 property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIndexerConfigMd5(String value) {
        this.indexerConfigMd5 = value;
    }

    /**
     * Gets the value of the error property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getError() {
        return error;
    }

    /**
     * Sets the value of the error property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setError(String value) {
        this.error = value;
    }

}
