
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
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
 *       &lt;choice>
 *         &lt;element ref="{urn:/velocity/objects}crawl-activity" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-url" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-delete" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}index-atomic" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}light-crawler-entry" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/choice>
 *       &lt;attribute name="enqueue-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="originator" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="status" use="required">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="successful"/>
 *             &lt;enumeration value="unsuccessful"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="replicated">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="replicated"/>
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
@XmlType(name = "", propOrder = {
    "crawlActivity",
    "crawlUrl",
    "crawlDelete",
    "indexAtomic",
    "lightCrawlerEntry"
})
@XmlRootElement(name = "audit-log-entry")
public class AuditLogEntry {

    @XmlElement(name = "crawl-activity")
    protected List<CrawlActivity> crawlActivity;
    @XmlElement(name = "crawl-url")
    protected List<CrawlUrl> crawlUrl;
    @XmlElement(name = "crawl-delete")
    protected List<CrawlDelete> crawlDelete;
    @XmlElement(name = "index-atomic")
    protected List<IndexAtomic> indexAtomic;
    @XmlElement(name = "light-crawler-entry")
    protected List<LightCrawlerEntry> lightCrawlerEntry;
    @XmlAttribute(name = "enqueue-id")
    protected String enqueueId;
    @XmlAttribute
    protected String originator;
    @XmlAttribute(required = true)
    protected String status;
    @XmlAttribute
    protected String replicated;

    /**
     * Gets the value of the crawlActivity property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlActivity property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlActivity().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlActivity }
     * 
     * 
     */
    public List<CrawlActivity> getCrawlActivity() {
        if (crawlActivity == null) {
            crawlActivity = new ArrayList<CrawlActivity>();
        }
        return this.crawlActivity;
    }

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

    /**
     * Gets the value of the indexAtomic property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the indexAtomic property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getIndexAtomic().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link IndexAtomic }
     * 
     * 
     */
    public List<IndexAtomic> getIndexAtomic() {
        if (indexAtomic == null) {
            indexAtomic = new ArrayList<IndexAtomic>();
        }
        return this.indexAtomic;
    }

    /**
     * Gets the value of the lightCrawlerEntry property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the lightCrawlerEntry property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getLightCrawlerEntry().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link LightCrawlerEntry }
     * 
     * 
     */
    public List<LightCrawlerEntry> getLightCrawlerEntry() {
        if (lightCrawlerEntry == null) {
            lightCrawlerEntry = new ArrayList<LightCrawlerEntry>();
        }
        return this.lightCrawlerEntry;
    }

    /**
     * Gets the value of the enqueueId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnqueueId() {
        return enqueueId;
    }

    /**
     * Sets the value of the enqueueId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnqueueId(String value) {
        this.enqueueId = value;
    }

    /**
     * Gets the value of the originator property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOriginator() {
        return originator;
    }

    /**
     * Sets the value of the originator property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOriginator(String value) {
        this.originator = value;
    }

    /**
     * Gets the value of the status property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStatus() {
        return status;
    }

    /**
     * Sets the value of the status property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStatus(String value) {
        this.status = value;
    }

    /**
     * Gets the value of the replicated property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReplicated() {
        return replicated;
    }

    /**
     * Sets the value of the replicated property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReplicated(String value) {
        this.replicated = value;
    }

}
