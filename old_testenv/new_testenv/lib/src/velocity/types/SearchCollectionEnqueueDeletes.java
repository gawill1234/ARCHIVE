
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
import velocity.objects.CrawlDelete;
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
 *         &lt;element name="crawl-deletes">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence maxOccurs="unbounded">
 *                   &lt;element ref="{urn:/velocity/objects}crawl-delete"/>
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
    "crawlDeletes",
    "exceptionOnFailure",
    "crawlType"
})
@XmlRootElement(name = "SearchCollectionEnqueueDeletes")
public class SearchCollectionEnqueueDeletes {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String collection;
    @XmlElement(defaultValue = "live")
    protected String subcollection;
    @XmlElement(name = "crawl-deletes", required = true)
    protected SearchCollectionEnqueueDeletes.CrawlDeletes crawlDeletes;
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
     * Gets the value of the crawlDeletes property.
     * 
     * @return
     *     possible object is
     *     {@link SearchCollectionEnqueueDeletes.CrawlDeletes }
     *     
     */
    public SearchCollectionEnqueueDeletes.CrawlDeletes getCrawlDeletes() {
        return crawlDeletes;
    }

    /**
     * Sets the value of the crawlDeletes property.
     * 
     * @param value
     *     allowed object is
     *     {@link SearchCollectionEnqueueDeletes.CrawlDeletes }
     *     
     */
    public void setCrawlDeletes(SearchCollectionEnqueueDeletes.CrawlDeletes value) {
        this.crawlDeletes = value;
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
     *         &lt;element ref="{urn:/velocity/objects}crawl-delete"/>
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
        "crawlDelete"
    })
    public static class CrawlDeletes {

        @XmlElement(name = "crawl-delete", namespace = "urn:/velocity/objects", required = true)
        protected List<CrawlDelete> crawlDelete;

        /**
         * Gets the value of the crawlDelete property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the crawlDelete property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getCrawlDelete().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link CrawlDelete }
         * 
         * 
         */
        public List<CrawlDelete> getCrawlDelete() {
            if (crawlDelete == null) {
                crawlDelete = new ArrayList<CrawlDelete>();
            }
            return this.crawlDelete;
        }

    }

}
