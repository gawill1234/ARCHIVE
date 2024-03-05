
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
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
 *         &lt;element ref="{urn:/velocity/objects}index-atomic"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-url"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-delete"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-urls"/>
 *       &lt;/choice>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "indexAtomic",
    "crawlUrl",
    "crawlDelete",
    "crawlUrls"
})
@XmlRootElement(name = "crawler-service-enqueue")
public class CrawlerServiceEnqueue {

    @XmlElement(name = "index-atomic")
    protected IndexAtomic indexAtomic;
    @XmlElement(name = "crawl-url")
    protected CrawlUrl crawlUrl;
    @XmlElement(name = "crawl-delete")
    protected CrawlDelete crawlDelete;
    @XmlElement(name = "crawl-urls")
    protected CrawlUrls crawlUrls;

    /**
     * Gets the value of the indexAtomic property.
     * 
     * @return
     *     possible object is
     *     {@link IndexAtomic }
     *     
     */
    public IndexAtomic getIndexAtomic() {
        return indexAtomic;
    }

    /**
     * Sets the value of the indexAtomic property.
     * 
     * @param value
     *     allowed object is
     *     {@link IndexAtomic }
     *     
     */
    public void setIndexAtomic(IndexAtomic value) {
        this.indexAtomic = value;
    }

    /**
     * Gets the value of the crawlUrl property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlUrl }
     *     
     */
    public CrawlUrl getCrawlUrl() {
        return crawlUrl;
    }

    /**
     * Sets the value of the crawlUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlUrl }
     *     
     */
    public void setCrawlUrl(CrawlUrl value) {
        this.crawlUrl = value;
    }

    /**
     * Gets the value of the crawlDelete property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlDelete }
     *     
     */
    public CrawlDelete getCrawlDelete() {
        return crawlDelete;
    }

    /**
     * Sets the value of the crawlDelete property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlDelete }
     *     
     */
    public void setCrawlDelete(CrawlDelete value) {
        this.crawlDelete = value;
    }

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
