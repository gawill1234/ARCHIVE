
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
 *         &lt;element name="crawl-url-status">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}crawl-url-status"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="force-sync" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
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
    "crawlUrlStatus",
    "forceSync"
})
@XmlRootElement(name = "SearchCollectionUrlStatusQuery")
public class SearchCollectionUrlStatusQuery {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String collection;
    @XmlElement(defaultValue = "live")
    protected String subcollection;
    @XmlElement(name = "crawl-url-status", required = true)
    protected SearchCollectionUrlStatusQuery.CrawlUrlStatus crawlUrlStatus;
    @XmlElement(name = "force-sync", defaultValue = "true")
    protected Boolean forceSync;

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
     * Gets the value of the crawlUrlStatus property.
     * 
     * @return
     *     possible object is
     *     {@link SearchCollectionUrlStatusQuery.CrawlUrlStatus }
     *     
     */
    public SearchCollectionUrlStatusQuery.CrawlUrlStatus getCrawlUrlStatus() {
        return crawlUrlStatus;
    }

    /**
     * Sets the value of the crawlUrlStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link SearchCollectionUrlStatusQuery.CrawlUrlStatus }
     *     
     */
    public void setCrawlUrlStatus(SearchCollectionUrlStatusQuery.CrawlUrlStatus value) {
        this.crawlUrlStatus = value;
    }

    /**
     * Gets the value of the forceSync property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isForceSync() {
        return forceSync;
    }

    /**
     * Sets the value of the forceSync property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setForceSync(Boolean value) {
        this.forceSync = value;
    }


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
    public static class CrawlUrlStatus {

        @XmlElement(name = "crawl-url-status", namespace = "urn:/velocity/objects", required = true)
        protected velocity.objects.CrawlUrlStatus crawlUrlStatus;

        /**
         * Gets the value of the crawlUrlStatus property.
         * 
         * @return
         *     possible object is
         *     {@link velocity.objects.CrawlUrlStatus }
         *     
         */
        public velocity.objects.CrawlUrlStatus getCrawlUrlStatus() {
            return crawlUrlStatus;
        }

        /**
         * Sets the value of the crawlUrlStatus property.
         * 
         * @param value
         *     allowed object is
         *     {@link velocity.objects.CrawlUrlStatus }
         *     
         */
        public void setCrawlUrlStatus(velocity.objects.CrawlUrlStatus value) {
            this.crawlUrlStatus = value;
        }

    }

}
