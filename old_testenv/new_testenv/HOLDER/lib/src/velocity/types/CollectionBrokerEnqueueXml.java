
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
    "crawlNodes",
    "exceptionOnFailure"
})
@XmlRootElement(name = "CollectionBrokerEnqueueXml")
public class CollectionBrokerEnqueueXml {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String collection;
    @XmlElement(name = "crawl-nodes", required = true)
    protected CollectionBrokerEnqueueXml.CrawlNodes crawlNodes;
    @XmlElement(name = "exception-on-failure", defaultValue = "false")
    protected Boolean exceptionOnFailure;

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
     * Gets the value of the crawlNodes property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerEnqueueXml.CrawlNodes }
     *     
     */
    public CollectionBrokerEnqueueXml.CrawlNodes getCrawlNodes() {
        return crawlNodes;
    }

    /**
     * Sets the value of the crawlNodes property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerEnqueueXml.CrawlNodes }
     *     
     */
    public void setCrawlNodes(CollectionBrokerEnqueueXml.CrawlNodes value) {
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
