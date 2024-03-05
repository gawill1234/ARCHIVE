
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
 *       &lt;choice maxOccurs="unbounded">
 *         &lt;element ref="{urn:/velocity/objects}crawler-rpc-range"/>
 *       &lt;/choice>
 *       &lt;attribute name="collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="counter" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="crawl-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="last-remote-update" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="remote-current-time" type="{http://www.w3.org/2001/XMLSchema}long" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlerRpcRange"
})
@XmlRootElement(name = "crawler-rpc-available")
public class CrawlerRpcAvailable {

    @XmlElement(name = "crawler-rpc-range")
    protected List<CrawlerRpcRange> crawlerRpcRange;
    @XmlAttribute
    protected String collection;
    @XmlAttribute
    protected Integer counter;
    @XmlAttribute(name = "crawl-id")
    protected String crawlId;
    @XmlAttribute(name = "last-remote-update")
    protected Long lastRemoteUpdate;
    @XmlAttribute(name = "remote-current-time")
    protected Long remoteCurrentTime;

    /**
     * Gets the value of the crawlerRpcRange property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlerRpcRange property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlerRpcRange().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlerRpcRange }
     * 
     * 
     */
    public List<CrawlerRpcRange> getCrawlerRpcRange() {
        if (crawlerRpcRange == null) {
            crawlerRpcRange = new ArrayList<CrawlerRpcRange>();
        }
        return this.crawlerRpcRange;
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
     * Gets the value of the counter property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCounter() {
        return counter;
    }

    /**
     * Sets the value of the counter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCounter(Integer value) {
        this.counter = value;
    }

    /**
     * Gets the value of the crawlId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCrawlId() {
        return crawlId;
    }

    /**
     * Sets the value of the crawlId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCrawlId(String value) {
        this.crawlId = value;
    }

    /**
     * Gets the value of the lastRemoteUpdate property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getLastRemoteUpdate() {
        return lastRemoteUpdate;
    }

    /**
     * Sets the value of the lastRemoteUpdate property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setLastRemoteUpdate(Long value) {
        this.lastRemoteUpdate = value;
    }

    /**
     * Gets the value of the remoteCurrentTime property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getRemoteCurrentTime() {
        return remoteCurrentTime;
    }

    /**
     * Sets the value of the remoteCurrentTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setRemoteCurrentTime(Long value) {
        this.remoteCurrentTime = value;
    }

}
