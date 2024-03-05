
package velocity.types;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import velocity.objects.CrawlUrl;
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
 *         &lt;element name="crawl-urls">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence maxOccurs="unbounded">
 *                   &lt;element ref="{urn:/velocity/objects}crawl-url"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="exception-on-failure" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
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
    "crawlUrls",
    "exceptionOnFailure",
    "crawlType"
})
@XmlRootElement(name = "SearchCollectionEnqueue")
public class SearchCollectionEnqueue {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String collection;
    @XmlElement(defaultValue = "live")
    protected String subcollection;
    @XmlElement(name = "crawl-urls", required = true)
    protected SearchCollectionEnqueue.CrawlUrls crawlUrls;
    @XmlElement(name = "exception-on-failure", defaultValue = "false")
    protected Boolean exceptionOnFailure;
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
     * Gets the value of the crawlUrls property.
     * 
     * @return
     *     possible object is
     *     {@link SearchCollectionEnqueue.CrawlUrls }
     *     
     */
    public SearchCollectionEnqueue.CrawlUrls getCrawlUrls() {
        return crawlUrls;
    }

    /**
     * Sets the value of the crawlUrls property.
     * 
     * @param value
     *     allowed object is
     *     {@link SearchCollectionEnqueue.CrawlUrls }
     *     
     */
    public void setCrawlUrls(SearchCollectionEnqueue.CrawlUrls value) {
        this.crawlUrls = value;
    }

    /**
     * Gets the value of the exceptionOnFailure property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isExceptionOnFailure() {
        return exceptionOnFailure;
    }

    /**
     * Sets the value of the exceptionOnFailure property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setExceptionOnFailure(Boolean value) {
        this.exceptionOnFailure = value;
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


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;sequence maxOccurs="unbounded">
     *         &lt;element ref="{urn:/velocity/objects}crawl-url"/>
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
        "crawlUrl"
    })
    public static class CrawlUrls {

        @XmlElement(name = "crawl-url", namespace = "urn:/velocity/objects", required = true)
        protected List<CrawlUrl> crawlUrl;

        /**
         * Gets the value of the crawlUrl property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the crawlUrl property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getCrawlUrl().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link CrawlUrl }
         * 
         * 
         */
        public List<CrawlUrl> getCrawlUrl() {
            if (crawlUrl == null) {
                crawlUrl = new ArrayList<CrawlUrl>();
            }
            return this.crawlUrl;
        }

    }

}
