
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
 *         &lt;element ref="{urn:/velocity/objects}crawl-delete" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}log" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="light-crawler">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="light-crawler"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="normalized">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="normalized"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="vse-key" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="only-input" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="index-atomically" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="was-atomic">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="was-atomic"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="vertex" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="vse-key-normalized">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="vse-key-normalized"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="indexer-generated">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="indexer-generated"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="enqueue-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="recursive">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="recursive"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="originator" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="state">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="pending"/>
 *             &lt;enumeration value="success"/>
 *             &lt;enumeration value="aborted"/>
 *             &lt;enumeration value="error"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="siphoned">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="terminated"/>
 *             &lt;enumeration value="nonexistent"/>
 *             &lt;enumeration value="rebasing"/>
 *             &lt;enumeration value="replaced"/>
 *             &lt;enumeration value="input-full"/>
 *             &lt;enumeration value="needed-gatekeeper"/>
 *             &lt;enumeration value="aborted"/>
 *             &lt;enumeration value="duplicate"/>
 *             &lt;enumeration value="unknown"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="notify-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="reply-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="synchronization" default="enqueued">
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
 *       &lt;attribute name="gatekeeper-action">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="reject"/>
 *             &lt;enumeration value="replace"/>
 *             &lt;enumeration value="add-to-queue"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="force-indexed-sync" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="enqueued-offline">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="enqueued-offline"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="orphaned-atomic">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="orphaned-atomic"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="priority" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="input-priority" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="indexer-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remote-collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remote-packet-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="remote-counter" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="remote-time" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="remote-delete-time" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlDelete",
    "log"
})
@XmlRootElement(name = "crawl-delete")
public class CrawlDelete {

    @XmlElement(name = "crawl-delete")
    protected List<CrawlDelete> crawlDelete;
    protected Log log;
    @XmlAttribute
    protected String url;
    @XmlAttribute(name = "light-crawler")
    protected String lightCrawler;
    @XmlAttribute
    protected String normalized;
    @XmlAttribute(name = "vse-key")
    protected String vseKey;
    @XmlAttribute(name = "only-input")
    @XmlSchemaType(name = "anySimpleType")
    protected String onlyInput;
    @XmlAttribute(name = "index-atomically")
    @XmlSchemaType(name = "anySimpleType")
    protected String indexAtomically;
    @XmlAttribute(name = "was-atomic")
    protected String wasAtomic;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long vertex;
    @XmlAttribute(name = "vse-key-normalized")
    protected String vseKeyNormalized;
    @XmlAttribute(name = "indexer-generated")
    protected String indexerGenerated;
    @XmlAttribute(name = "enqueue-id")
    protected String enqueueId;
    @XmlAttribute
    protected String recursive;
    @XmlAttribute
    protected String originator;
    @XmlAttribute
    protected String state;
    @XmlAttribute
    protected String siphoned;
    @XmlAttribute(name = "notify-id")
    protected Integer notifyId;
    @XmlAttribute(name = "reply-id")
    protected Integer replyId;
    @XmlAttribute
    protected String synchronization;
    @XmlAttribute(name = "gatekeeper-action")
    protected String gatekeeperAction;
    @XmlAttribute(name = "force-indexed-sync")
    @XmlSchemaType(name = "anySimpleType")
    protected String forceIndexedSync;
    @XmlAttribute(name = "enqueued-offline")
    protected String enqueuedOffline;
    @XmlAttribute(name = "orphaned-atomic")
    protected String orphanedAtomic;
    @XmlAttribute
    protected Integer priority;
    @XmlAttribute(name = "input-priority")
    protected Integer inputPriority;
    @XmlAttribute(name = "indexer-id")
    protected String indexerId;
    @XmlAttribute(name = "remote-collection")
    protected String remoteCollection;
    @XmlAttribute(name = "remote-packet-id")
    protected Integer remotePacketId;
    @XmlAttribute(name = "remote-counter")
    @XmlSchemaType(name = "unsignedInt")
    protected Long remoteCounter;
    @XmlAttribute(name = "remote-time")
    @XmlSchemaType(name = "unsignedInt")
    protected Long remoteTime;
    @XmlAttribute(name = "remote-delete-time")
    @XmlSchemaType(name = "unsignedInt")
    protected Long remoteDeleteTime;

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
     * Gets the value of the log property.
     * 
     * @return
     *     possible object is
     *     {@link Log }
     *     
     */
    public Log getLog() {
        return log;
    }

    /**
     * Sets the value of the log property.
     * 
     * @param value
     *     allowed object is
     *     {@link Log }
     *     
     */
    public void setLog(Log value) {
        this.log = value;
    }

    /**
     * Gets the value of the url property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrl() {
        return url;
    }

    /**
     * Sets the value of the url property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrl(String value) {
        this.url = value;
    }

    /**
     * Gets the value of the lightCrawler property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLightCrawler() {
        return lightCrawler;
    }

    /**
     * Sets the value of the lightCrawler property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLightCrawler(String value) {
        this.lightCrawler = value;
    }

    /**
     * Gets the value of the normalized property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNormalized() {
        return normalized;
    }

    /**
     * Sets the value of the normalized property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNormalized(String value) {
        this.normalized = value;
    }

    /**
     * Gets the value of the vseKey property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseKey() {
        return vseKey;
    }

    /**
     * Sets the value of the vseKey property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseKey(String value) {
        this.vseKey = value;
    }

    /**
     * Gets the value of the onlyInput property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOnlyInput() {
        return onlyInput;
    }

    /**
     * Sets the value of the onlyInput property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOnlyInput(String value) {
        this.onlyInput = value;
    }

    /**
     * Gets the value of the indexAtomically property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIndexAtomically() {
        return indexAtomically;
    }

    /**
     * Sets the value of the indexAtomically property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIndexAtomically(String value) {
        this.indexAtomically = value;
    }

    /**
     * Gets the value of the wasAtomic property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getWasAtomic() {
        return wasAtomic;
    }

    /**
     * Sets the value of the wasAtomic property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setWasAtomic(String value) {
        this.wasAtomic = value;
    }

    /**
     * Gets the value of the vertex property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getVertex() {
        return vertex;
    }

    /**
     * Sets the value of the vertex property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setVertex(Long value) {
        this.vertex = value;
    }

    /**
     * Gets the value of the vseKeyNormalized property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseKeyNormalized() {
        return vseKeyNormalized;
    }

    /**
     * Sets the value of the vseKeyNormalized property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseKeyNormalized(String value) {
        this.vseKeyNormalized = value;
    }

    /**
     * Gets the value of the indexerGenerated property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIndexerGenerated() {
        return indexerGenerated;
    }

    /**
     * Sets the value of the indexerGenerated property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIndexerGenerated(String value) {
        this.indexerGenerated = value;
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
     * Gets the value of the recursive property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRecursive() {
        return recursive;
    }

    /**
     * Sets the value of the recursive property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRecursive(String value) {
        this.recursive = value;
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
     * Gets the value of the siphoned property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSiphoned() {
        return siphoned;
    }

    /**
     * Sets the value of the siphoned property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSiphoned(String value) {
        this.siphoned = value;
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
     * Gets the value of the replyId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getReplyId() {
        return replyId;
    }

    /**
     * Sets the value of the replyId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setReplyId(Integer value) {
        this.replyId = value;
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
        if (synchronization == null) {
            return "enqueued";
        } else {
            return synchronization;
        }
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
     * Gets the value of the gatekeeperAction property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGatekeeperAction() {
        return gatekeeperAction;
    }

    /**
     * Sets the value of the gatekeeperAction property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGatekeeperAction(String value) {
        this.gatekeeperAction = value;
    }

    /**
     * Gets the value of the forceIndexedSync property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForceIndexedSync() {
        return forceIndexedSync;
    }

    /**
     * Sets the value of the forceIndexedSync property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForceIndexedSync(String value) {
        this.forceIndexedSync = value;
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
     * Gets the value of the orphanedAtomic property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOrphanedAtomic() {
        return orphanedAtomic;
    }

    /**
     * Sets the value of the orphanedAtomic property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOrphanedAtomic(String value) {
        this.orphanedAtomic = value;
    }

    /**
     * Gets the value of the priority property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getPriority() {
        if (priority == null) {
            return  0;
        } else {
            return priority;
        }
    }

    /**
     * Sets the value of the priority property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPriority(Integer value) {
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
     * Gets the value of the indexerId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIndexerId() {
        return indexerId;
    }

    /**
     * Sets the value of the indexerId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIndexerId(String value) {
        this.indexerId = value;
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
     * Gets the value of the remoteCounter property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getRemoteCounter() {
        return remoteCounter;
    }

    /**
     * Sets the value of the remoteCounter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setRemoteCounter(Long value) {
        this.remoteCounter = value;
    }

    /**
     * Gets the value of the remoteTime property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getRemoteTime() {
        return remoteTime;
    }

    /**
     * Sets the value of the remoteTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setRemoteTime(Long value) {
        this.remoteTime = value;
    }

    /**
     * Gets the value of the remoteDeleteTime property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getRemoteDeleteTime() {
        return remoteDeleteTime;
    }

    /**
     * Sets the value of the remoteDeleteTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setRemoteDeleteTime(Long value) {
        this.remoteDeleteTime = value;
    }

}
