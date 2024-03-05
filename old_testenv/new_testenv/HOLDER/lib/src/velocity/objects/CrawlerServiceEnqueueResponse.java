
package velocity.objects;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
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
 *         &lt;element ref="{urn:/velocity/objects}index-atomic"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-url"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-delete"/>
 *       &lt;/choice>
 *       &lt;attribute name="error">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="database"/>
 *             &lt;enumeration value="invalid-node"/>
 *             &lt;enumeration value="invalid-attr"/>
 *             &lt;enumeration value="malformed-crawl-url"/>
 *             &lt;enumeration value="malformed-crawl-delete"/>
 *             &lt;enumeration value="malformed-index-atomic"/>
 *             &lt;enumeration value="malformed-crawl-state"/>
 *             &lt;enumeration value="terminating"/>
 *             &lt;enumeration value="read-only"/>
 *             &lt;enumeration value="audit-log-disabled"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="n-success" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-failed" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-offline" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="offline-queue-size" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *       &lt;attribute name="pipeline-size" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *       &lt;attribute name="throttle-id" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "indexAtomicOrCrawlUrlOrCrawlDelete"
})
@XmlRootElement(name = "crawler-service-enqueue-response")
public class CrawlerServiceEnqueueResponse {

    @XmlElements({
        @XmlElement(name = "crawl-url", type = CrawlUrl.class),
        @XmlElement(name = "crawl-delete", type = CrawlDelete.class),
        @XmlElement(name = "index-atomic", type = IndexAtomic.class)
    })
    protected List<Object> indexAtomicOrCrawlUrlOrCrawlDelete;
    @XmlAttribute
    protected String error;
    @XmlAttribute(name = "n-success")
    protected Integer nSuccess;
    @XmlAttribute(name = "n-failed")
    protected Integer nFailed;
    @XmlAttribute(name = "n-offline")
    protected Integer nOffline;
    @XmlAttribute(name = "offline-queue-size")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger offlineQueueSize;
    @XmlAttribute(name = "pipeline-size")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger pipelineSize;
    @XmlAttribute(name = "throttle-id")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger throttleId;

    /**
     * Gets the value of the indexAtomicOrCrawlUrlOrCrawlDelete property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the indexAtomicOrCrawlUrlOrCrawlDelete property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getIndexAtomicOrCrawlUrlOrCrawlDelete().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlUrl }
     * {@link CrawlDelete }
     * {@link IndexAtomic }
     * 
     * 
     */
    public List<Object> getIndexAtomicOrCrawlUrlOrCrawlDelete() {
        if (indexAtomicOrCrawlUrlOrCrawlDelete == null) {
            indexAtomicOrCrawlUrlOrCrawlDelete = new ArrayList<Object>();
        }
        return this.indexAtomicOrCrawlUrlOrCrawlDelete;
    }

    /**
     * Gets the value of the error property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getError() {
        return error;
    }

    /**
     * Sets the value of the error property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setError(String value) {
        this.error = value;
    }

    /**
     * Gets the value of the nSuccess property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNSuccess() {
        return nSuccess;
    }

    /**
     * Sets the value of the nSuccess property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNSuccess(Integer value) {
        this.nSuccess = value;
    }

    /**
     * Gets the value of the nFailed property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNFailed() {
        return nFailed;
    }

    /**
     * Sets the value of the nFailed property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNFailed(Integer value) {
        this.nFailed = value;
    }

    /**
     * Gets the value of the nOffline property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNOffline() {
        return nOffline;
    }

    /**
     * Sets the value of the nOffline property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNOffline(Integer value) {
        this.nOffline = value;
    }

    /**
     * Gets the value of the offlineQueueSize property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getOfflineQueueSize() {
        return offlineQueueSize;
    }

    /**
     * Sets the value of the offlineQueueSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setOfflineQueueSize(BigInteger value) {
        this.offlineQueueSize = value;
    }

    /**
     * Gets the value of the pipelineSize property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getPipelineSize() {
        return pipelineSize;
    }

    /**
     * Sets the value of the pipelineSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setPipelineSize(BigInteger value) {
        this.pipelineSize = value;
    }

    /**
     * Gets the value of the throttleId property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getThrottleId() {
        return throttleId;
    }

    /**
     * Sets the value of the throttleId property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setThrottleId(BigInteger value) {
        this.throttleId = value;
    }

}
