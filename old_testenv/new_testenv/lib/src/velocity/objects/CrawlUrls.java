
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
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
 *       &lt;sequence maxOccurs="unbounded">
 *         &lt;element ref="{urn:/velocity/objects}crawl-url"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-delete"/>
 *         &lt;element ref="{urn:/velocity/objects}index-atomic"/>
 *       &lt;/sequence>
 *       &lt;attribute name="synchronization">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="none"/>
 *             &lt;enumeration value="enqueued"/>
 *             &lt;enumeration value="to-be-indexed"/>
 *             &lt;enumeration value="indexed"/>
 *             &lt;enumeration value="indexed-no-sync"/>
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
    "crawlUrlAndCrawlDeleteAndIndexAtomic"
})
@XmlRootElement(name = "crawl-urls")
public class CrawlUrls {

    @XmlElements({
        @XmlElement(name = "index-atomic", required = true, type = IndexAtomic.class),
        @XmlElement(name = "crawl-delete", required = true, type = CrawlDelete.class),
        @XmlElement(name = "crawl-url", required = true, type = CrawlUrl.class)
    })
    protected List<Object> crawlUrlAndCrawlDeleteAndIndexAtomic;
    @XmlAttribute
    protected String synchronization;

    /**
     * Gets the value of the crawlUrlAndCrawlDeleteAndIndexAtomic property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlUrlAndCrawlDeleteAndIndexAtomic property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlUrlAndCrawlDeleteAndIndexAtomic().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link IndexAtomic }
     * {@link CrawlDelete }
     * {@link CrawlUrl }
     * 
     * 
     */
    public List<Object> getCrawlUrlAndCrawlDeleteAndIndexAtomic() {
        if (crawlUrlAndCrawlDeleteAndIndexAtomic == null) {
            crawlUrlAndCrawlDeleteAndIndexAtomic = new ArrayList<Object>();
        }
        return this.crawlUrlAndCrawlDeleteAndIndexAtomic;
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

}
