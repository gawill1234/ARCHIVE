
package velocity.objects;

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
 *         &lt;element ref="{urn:/velocity/objects}crawl-url"/>
 *       &lt;/choice>
 *       &lt;attribute name="collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="counter" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="time" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="collection-dependency" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="collection-previous" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="counter-dependency" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="counter-previous" type="{http://www.w3.org/2001/XMLSchema}int" />
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
@XmlRootElement(name = "crawler-rpc-update")
public class CrawlerRpcUpdate {

    @XmlElement(name = "crawl-url")
    protected CrawlUrl crawlUrl;
    @XmlAttribute
    protected String collection;
    @XmlAttribute
    protected Integer counter;
    @XmlAttribute
    protected Long time;
    @XmlAttribute(name = "collection-dependency")
    protected String collectionDependency;
    @XmlAttribute(name = "collection-previous")
    protected String collectionPrevious;
    @XmlAttribute(name = "counter-dependency")
    protected Integer counterDependency;
    @XmlAttribute(name = "counter-previous")
    protected Integer counterPrevious;

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
     * Gets the value of the time property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getTime() {
        return time;
    }

    /**
     * Sets the value of the time property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setTime(Long value) {
        this.time = value;
    }

    /**
     * Gets the value of the collectionDependency property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollectionDependency() {
        return collectionDependency;
    }

    /**
     * Sets the value of the collectionDependency property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollectionDependency(String value) {
        this.collectionDependency = value;
    }

    /**
     * Gets the value of the collectionPrevious property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollectionPrevious() {
        return collectionPrevious;
    }

    /**
     * Sets the value of the collectionPrevious property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollectionPrevious(String value) {
        this.collectionPrevious = value;
    }

    /**
     * Gets the value of the counterDependency property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCounterDependency() {
        return counterDependency;
    }

    /**
     * Sets the value of the counterDependency property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCounterDependency(Integer value) {
        this.counterDependency = value;
    }

    /**
     * Gets the value of the counterPrevious property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCounterPrevious() {
        return counterPrevious;
    }

    /**
     * Sets the value of the counterPrevious property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCounterPrevious(Integer value) {
        this.counterPrevious = value;
    }

}
