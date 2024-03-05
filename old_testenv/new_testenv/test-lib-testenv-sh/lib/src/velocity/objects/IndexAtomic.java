
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}crawl-url" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-delete" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="originator" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="enqueue-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="notify-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="vse-key-of-delete" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="re-events" type="{http://www.w3.org/2001/XMLSchema}int" />
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
 *       &lt;attribute name="state">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="success"/>
 *             &lt;enumeration value="error"/>
 *             &lt;enumeration value="aborted"/>
 *             &lt;enumeration value="pending"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="aborted-why">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="duplicate-enqueue-id"/>
 *             &lt;enumeration value="batch-aborted-on-error"/>
 *             &lt;enumeration value="aborted-by-api"/>
 *             &lt;enumeration value="no-work"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="priority" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" default="0" />
 *       &lt;attribute name="input-priority" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="abort-batch-on-error">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="abort-batch-on-error"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="partial">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="partial"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="enqueued-offline">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="enqueued-offline"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="offline-id" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="force-abort">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="force-abort"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="remote-packet-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="remote-collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlUrl",
    "crawlDelete"
})
@XmlRootElement(name = "index-atomic")
public class IndexAtomic {

    @XmlElement(name = "crawl-url")
    protected List<CrawlUrl> crawlUrl;
    @XmlElement(name = "crawl-delete")
    protected List<CrawlDelete> crawlDelete;
    @XmlAttribute
    protected String originator;
    @XmlAttribute(name = "enqueue-id")
    protected String enqueueId;
    @XmlAttribute(name = "notify-id")
    protected Integer notifyId;
    @XmlAttribute(name = "vse-key-of-delete")
    protected String vseKeyOfDelete;
    @XmlAttribute(name = "re-events")
    protected Integer reEvents;
    @XmlAttribute
    protected String synchronization;
    @XmlAttribute
    protected String state;
    @XmlAttribute(name = "aborted-why")
    protected String abortedWhy;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long priority;
    @XmlAttribute(name = "input-priority")
    protected Integer inputPriority;
    @XmlAttribute(name = "abort-batch-on-error")
    protected String abortBatchOnError;
    @XmlAttribute
    protected String partial;
    @XmlAttribute(name = "enqueued-offline")
    protected String enqueuedOffline;
    @XmlAttribute(name = "offline-id")
    @XmlSchemaType(name = "unsignedInt")
    protected Long offlineId;
    @XmlAttribute(name = "force-abort")
    protected String forceAbort;
    @XmlAttribute(name = "remote-packet-id")
    protected Integer remotePacketId;
    @XmlAttribute(name = "remote-collection")
    protected String remoteCollection;

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
     * Gets the value of the notifyId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNotifyId() {
        return notifyId;
    }

    /**
     * Sets the value of the notifyId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNotifyId(Integer value) {
        this.notifyId = value;
    }

    /**
     * Gets the value of the vseKeyOfDelete property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseKeyOfDelete() {
        return vseKeyOfDelete;
    }

    /**
     * Sets the value of the vseKeyOfDelete property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseKeyOfDelete(String value) {
        this.vseKeyOfDelete = value;
    }

    /**
     * Gets the value of the reEvents property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getReEvents() {
        return reEvents;
    }

    /**
     * Sets the value of the reEvents property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setReEvents(Integer value) {
        this.reEvents = value;
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

    /**
     * Gets the value of the state property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getState() {
        return state;
    }

    /**
     * Sets the value of the state property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setState(String value) {
        this.state = value;
    }

    /**
     * Gets the value of the abortedWhy property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAbortedWhy() {
        return abortedWhy;
    }

    /**
     * Sets the value of the abortedWhy property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAbortedWhy(String value) {
        this.abortedWhy = value;
    }

    /**
     * Gets the value of the priority property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public long getPriority() {
        if (priority == null) {
            return  0L;
        } else {
            return priority;
        }
    }

    /**
     * Sets the value of the priority property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setPriority(Long value) {
        this.priority = value;
    }

    /**
     * Gets the value of the inputPriority property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getInputPriority() {
        return inputPriority;
    }

    /**
     * Sets the value of the inputPriority property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setInputPriority(Integer value) {
        this.inputPriority = value;
    }

    /**
     * Gets the value of the abortBatchOnError property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAbortBatchOnError() {
        return abortBatchOnError;
    }

    /**
     * Sets the value of the abortBatchOnError property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAbortBatchOnError(String value) {
        this.abortBatchOnError = value;
    }

    /**
     * Gets the value of the partial property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPartial() {
        return partial;
    }

    /**
     * Sets the value of the partial property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPartial(String value) {
        this.partial = value;
    }

    /**
     * Gets the value of the enqueuedOffline property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnqueuedOffline() {
        return enqueuedOffline;
    }

    /**
     * Sets the value of the enqueuedOffline property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnqueuedOffline(String value) {
        this.enqueuedOffline = value;
    }

    /**
     * Gets the value of the offlineId property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOfflineId() {
        return offlineId;
    }

    /**
     * Sets the value of the offlineId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOfflineId(Long value) {
        this.offlineId = value;
    }

    /**
     * Gets the value of the forceAbort property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForceAbort() {
        return forceAbort;
    }

    /**
     * Sets the value of the forceAbort property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForceAbort(String value) {
        this.forceAbort = value;
    }

    /**
     * Gets the value of the remotePacketId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemotePacketId() {
        return remotePacketId;
    }

    /**
     * Sets the value of the remotePacketId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemotePacketId(Integer value) {
        this.remotePacketId = value;
    }

    /**
     * Gets the value of the remoteCollection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteCollection() {
        return remoteCollection;
    }

    /**
     * Sets the value of the remoteCollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteCollection(String value) {
        this.remoteCollection = value;
    }

}
