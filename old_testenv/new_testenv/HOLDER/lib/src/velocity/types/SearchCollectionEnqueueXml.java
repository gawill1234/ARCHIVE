
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import velocity.objects.CrawlUrls;
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
 *         &lt;element name="crawl-nodes">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}crawl-urls"/>
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
 *         &lt;element name="ensure-running" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
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
    "crawlNodes",
    "exceptionOnFailure",
    "crawlType",
    "ensureRunning"
})
@XmlRootElement(name = "SearchCollectionEnqueueXml")
public class SearchCollectionEnqueueXml {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String collection;
    @XmlElement(defaultValue = "live")
    protected String subcollection;
    @XmlElement(name = "crawl-nodes", required = true)
    protected SearchCollectionEnqueueXml.CrawlNodes crawlNodes;
    @XmlElement(name = "exception-on-failure", defaultValue = "false")
    protected Boolean exceptionOnFailure;
    @XmlElement(name = "crawl-type", defaultValue = "resume-and-idle")
    protected String crawlType;
    @XmlElement(name = "ensure-running", defaultValue = "true")
    protected Boolean ensureRunning;

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
     * Gets the value of the crawlNodes property.
     * 
     * @return
     *     possible object is
     *     {@link SearchCollectionEnqueueXml.CrawlNodes }
     *     
     */
    public SearchCollectionEnqueueXml.CrawlNodes getCrawlNodes() {
        return crawlNodes;
    }

    /**
     * Sets the value of the crawlNodes property.
     * 
     * @param value
     *     allowed object is
     *     {@link SearchCollectionEnqueueXml.CrawlNodes }
     *     
     */
    public void setCrawlNodes(SearchCollectionEnqueueXml.CrawlNodes value) {
        this.crawlNodes = value;
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
     * Gets the value of the ensureRunning property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isEnsureRunning() {
        return ensureRunning;
    }

    /**
     * Sets the value of the ensureRunning property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setEnsureRunning(Boolean value) {
        this.ensureRunning = value;
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
     *         &lt;element ref="{urn:/velocity/objects}crawl-urls"/>
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
        "crawlUrls"
    })
    public static class CrawlNodes {

        @XmlElement(name = "crawl-urls", namespace = "urn:/velocity/objects", required = true)
        protected CrawlUrls crawlUrls;

        /**
         * Gets the value of the crawlUrls property.
         * 
         * @return
         *     possible object is
         *     {@link CrawlUrls }
         *     
         */
        public CrawlUrls getCrawlUrls() {
            return crawlUrls;
        }

        /**
         * Sets the value of the crawlUrls property.
         * 
         * @param value
         *     allowed object is
         *     {@link CrawlUrls }
         *     
         */
        public void setCrawlUrls(CrawlUrls value) {
            this.crawlUrls = value;
        }

    }

}
