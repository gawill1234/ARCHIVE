
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import velocity.soap.Authentication;


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
 *         &lt;element ref="{urn:/velocity/soap}authentication" minOccurs="0"/>
 *         &lt;element name="collection" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN"/>
 *         &lt;element name="subcollection" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="live"/>
 *               &lt;enumeration value="staging"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *         &lt;element name="url" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="synchronization" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="enqueued"/>
 *               &lt;enumeration value="to-be-crawled"/>
 *               &lt;enumeration value="to-be-indexed"/>
 *               &lt;enumeration value="indexed"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *         &lt;element name="enqueue-type" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="none"/>
 *               &lt;enumeration value="forced"/>
 *               &lt;enumeration value="reenqueued"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *         &lt;element name="force-allow" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="crawl-type" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="resume"/>
 *               &lt;enumeration value="resume-and-idle"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
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
    "authentication",
    "collection",
    "subcollection",
    "url",
    "synchronization",
    "enqueueType",
    "forceAllow",
    "crawlType"
})
@XmlRootElement(name = "SearchCollectionEnqueueUrl")
public class SearchCollectionEnqueueUrl {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String collection;
    @XmlElement(defaultValue = "live")
    protected String subcollection;
    @XmlElement(required = true)
    protected String url;
    @XmlElement(defaultValue = "enqueued")
    protected String synchronization;
    @XmlElement(name = "enqueue-type", defaultValue = "none")
    protected String enqueueType;
    @XmlElement(name = "force-allow", defaultValue = "false")
    protected Boolean forceAllow;
    @XmlElement(name = "crawl-type", defaultValue = "resume-and-idle")
    protected String crawlType;

    /**
     * Gets the value of the authentication property.
     * 
     * @return
     *     possible object is
     *     {@link Authentication }
     *     
     */
    public Authentication getAuthentication() {
        return authentication;
    }

    /**
     * Sets the value of the authentication property.
     * 
     * @param value
     *     allowed object is
     *     {@link Authentication }
     *     
     */
    public void setAuthentication(Authentication value) {
        this.authentication = value;
    }

    /**
     * Gets the value of the collection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollection() {
        return collection;
    }

    /**
     * Sets the value of the collection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollection(String value) {
        this.collection = value;
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
     * Gets the value of the synchronization property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSynchronization() {
        return synchronization;
    }

    /**
     * Sets the value of the synchronization property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSynchronization(String value) {
        this.synchronization = value;
    }

    /**
     * Gets the value of the enqueueType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnqueueType() {
        return enqueueType;
    }

    /**
     * Sets the value of the enqueueType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnqueueType(String value) {
        this.enqueueType = value;
    }

    /**
     * Gets the value of the forceAllow property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isForceAllow() {
        return forceAllow;
    }

    /**
     * Sets the value of the forceAllow property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setForceAllow(Boolean value) {
        this.forceAllow = value;
    }

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

}
