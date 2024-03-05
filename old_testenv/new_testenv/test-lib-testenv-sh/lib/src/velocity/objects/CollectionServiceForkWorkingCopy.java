
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
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "collection-service-fork-working-copy")
public class CollectionServiceForkWorkingCopy {

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
