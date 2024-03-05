
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *         &lt;element ref="{urn:/velocity/objects}crawl-url-status"/>
 *       &lt;/sequence>
 *       &lt;attribute name="subcollection">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="live"/>
 *             &lt;enumeration value="staging"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="force-sync" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlUrlStatus"
})
@XmlRootElement(name = "collection-service-query-url-status")
public class CollectionServiceQueryUrlStatus {

    @XmlElement(name = "crawl-url-status", required = true)
    protected CrawlUrlStatus crawlUrlStatus;
    @XmlAttribute
    protected String subcollection;
    @XmlAttribute(name = "force-sync")
    protected java.lang.Boolean forceSync;

    /**
     * Gets the value of the crawlUrlStatus property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlUrlStatus }
     *     
     */
    public CrawlUrlStatus getCrawlUrlStatus() {
        return crawlUrlStatus;
    }

    /**
     * Sets the value of the crawlUrlStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlUrlStatus }
     *     
     */
    public void setCrawlUrlStatus(CrawlUrlStatus value) {
        this.crawlUrlStatus = value;
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
     * Gets the value of the forceSync property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isForceSync() {
        return forceSync;
    }

    /**
     * Sets the value of the forceSync property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setForceSync(java.lang.Boolean value) {
        this.forceSync = value;
    }

}
