
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
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
 *       &lt;all minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}crawler-status"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index-status"/>
 *       &lt;/all>
 *       &lt;attribute name="which">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="live"/>
 *             &lt;enumeration value="staging"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="version">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="6.0"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="identifier" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="clean-failed">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="clean-failed"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="config-md5" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="crawler-config-md5" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="indexer-config-md5" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="token" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {

})
@XmlRootElement(name = "vse-status")
public class VseStatus {

    @XmlElement(name = "crawler-status")
    protected CrawlerStatus crawlerStatus;
    @XmlElement(name = "vse-index-status")
    protected VseIndexStatus vseIndexStatus;
    @XmlAttribute
    protected String which;
    @XmlAttribute
    protected String version;
    @XmlAttribute
    protected String identifier;
    @XmlAttribute(name = "clean-failed")
    protected String cleanFailed;
    @XmlAttribute(name = "config-md5")
    @XmlSchemaType(name = "anySimpleType")
    protected String configMd5;
    @XmlAttribute(name = "crawler-config-md5")
    @XmlSchemaType(name = "anySimpleType")
    protected String crawlerConfigMd5;
    @XmlAttribute(name = "indexer-config-md5")
    @XmlSchemaType(name = "anySimpleType")
    protected String indexerConfigMd5;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String token;

    /**
     * Gets the value of the crawlerStatus property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlerStatus }
     *     
     */
    public CrawlerStatus getCrawlerStatus() {
        return crawlerStatus;
    }

    /**
     * Sets the value of the crawlerStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlerStatus }
     *     
     */
    public void setCrawlerStatus(CrawlerStatus value) {
        this.crawlerStatus = value;
    }

    /**
     * Gets the value of the vseIndexStatus property.
     * 
     * @return
     *     possible object is
     *     {@link VseIndexStatus }
     *     
     */
    public VseIndexStatus getVseIndexStatus() {
        return vseIndexStatus;
    }

    /**
     * Sets the value of the vseIndexStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseIndexStatus }
     *     
     */
    public void setVseIndexStatus(VseIndexStatus value) {
        this.vseIndexStatus = value;
    }

    /**
     * Gets the value of the which property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getWhich() {
        return which;
    }

    /**
     * Sets the value of the which property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setWhich(String value) {
        this.which = value;
    }

    /**
     * Gets the value of the version property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVersion() {
        return version;
    }

    /**
     * Sets the value of the version property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVersion(String value) {
        this.version = value;
    }

    /**
     * Gets the value of the identifier property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIdentifier() {
        return identifier;
    }

    /**
     * Sets the value of the identifier property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIdentifier(String value) {
        this.identifier = value;
    }

    /**
     * Gets the value of the cleanFailed property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCleanFailed() {
        return cleanFailed;
    }

    /**
     * Sets the value of the cleanFailed property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCleanFailed(String value) {
        this.cleanFailed = value;
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

}
