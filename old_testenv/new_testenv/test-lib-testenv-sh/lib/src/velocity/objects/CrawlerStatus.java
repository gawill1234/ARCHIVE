
package velocity.objects;

import java.math.BigInteger;
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
 *         &lt;element ref="{urn:/velocity/objects}converter-timings" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-thread" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-remote-status" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-client-status" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawler-status" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-hops-output" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-hops-input" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}queues" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-remote-all-status" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="from-cache">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="from-cache"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="version" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="stopping-time" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="expected-stop-time" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="time" use="required" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="n-input" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-output" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-errors" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-error-rows" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-http-errors" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-http-location" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-filtered" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-robots" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-pending" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-pending-internal" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-awaiting-gate" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-awaiting-input" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-offline-queue" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-awaiting-index-input" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-awaiting-index-reply" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="conversion-time" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-sub" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-bytes" type="{http://www.w3.org/2001/XMLSchema}double" default="0" />
 *       &lt;attribute name="n-dl-bytes" type="{http://www.w3.org/2001/XMLSchema}double" default="0" />
 *       &lt;attribute name="n-redirect" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-duplicates" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-deleted" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-cache-complete" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="converted-size" type="{http://www.w3.org/2001/XMLSchema}double" default="0" />
 *       &lt;attribute name="elapsed" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="this-elapsed" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="upgrade-schema">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="upgrade-schema"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="sanitize-rebase">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="sanitze-rebase"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="request-rebase">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="request-rebase"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="copy-rebase">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="copy-rebase"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="receive-rebase">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="receive-rebase"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="resume">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="resume"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="complete">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="complete"/>
 *             &lt;enumeration value="aborted"/>
 *             &lt;enumeration value="unexpected"/>
 *             &lt;enumeration value="docs-limit"/>
 *             &lt;enumeration value="urls-limit"/>
 *             &lt;enumeration value="input-urls-limit"/>
 *             &lt;enumeration value="time-limit"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="idle">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="idle"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="final">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="final"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="performing-vacuum">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="performing-vacuum"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="error" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="config-md5" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="service-status">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="stopped"/>
 *             &lt;enumeration value="running"/>
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
    "converterTimings",
    "crawlThread",
    "crawlRemoteStatus",
    "crawlClientStatus",
    "crawlerStatus",
    "crawlHopsOutput",
    "crawlHopsInput",
    "queues",
    "crawlRemoteAllStatus"
})
@XmlRootElement(name = "crawler-status")
public class CrawlerStatus {

    @XmlElement(name = "converter-timings")
    protected ConverterTimings converterTimings;
    @XmlElement(name = "crawl-thread")
    protected List<CrawlThread> crawlThread;
    @XmlElement(name = "crawl-remote-status")
    protected List<CrawlRemoteStatus> crawlRemoteStatus;
    @XmlElement(name = "crawl-client-status")
    protected List<CrawlClientStatus> crawlClientStatus;
    @XmlElement(name = "crawler-status")
    protected List<CrawlerStatus> crawlerStatus;
    @XmlElement(name = "crawl-hops-output")
    protected CrawlHopsOutput crawlHopsOutput;
    @XmlElement(name = "crawl-hops-input")
    protected CrawlHopsInput crawlHopsInput;
    protected Queues queues;
    @XmlElement(name = "crawl-remote-all-status")
    protected CrawlRemoteAllStatus crawlRemoteAllStatus;
    @XmlAttribute(name = "from-cache")
    protected String fromCache;
    @XmlAttribute
    protected String version;
    @XmlAttribute
    protected String id;
    @XmlAttribute(name = "stopping-time")
    protected Long stoppingTime;
    @XmlAttribute(name = "expected-stop-time")
    protected Long expectedStopTime;
    @XmlAttribute(required = true)
    protected long time;
    @XmlAttribute(name = "n-input")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nInput;
    @XmlAttribute(name = "n-output")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nOutput;
    @XmlAttribute(name = "n-errors")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nErrors;
    @XmlAttribute(name = "n-error-rows")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nErrorRows;
    @XmlAttribute(name = "n-http-errors")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nHttpErrors;
    @XmlAttribute(name = "n-http-location")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nHttpLocation;
    @XmlAttribute(name = "n-filtered")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nFiltered;
    @XmlAttribute(name = "n-robots")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nRobots;
    @XmlAttribute(name = "n-pending")
    protected Integer nPending;
    @XmlAttribute(name = "n-pending-internal")
    protected Integer nPendingInternal;
    @XmlAttribute(name = "n-awaiting-gate")
    protected Integer nAwaitingGate;
    @XmlAttribute(name = "n-awaiting-input")
    protected Integer nAwaitingInput;
    @XmlAttribute(name = "n-offline-queue")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nOfflineQueue;
    @XmlAttribute(name = "n-awaiting-index-input")
    protected Integer nAwaitingIndexInput;
    @XmlAttribute(name = "n-awaiting-index-reply")
    protected Integer nAwaitingIndexReply;
    @XmlAttribute(name = "conversion-time")
    protected Integer conversionTime;
    @XmlAttribute(name = "n-sub")
    protected Integer nSub;
    @XmlAttribute(name = "n-bytes")
    protected Double nBytes;
    @XmlAttribute(name = "n-dl-bytes")
    protected Double nDlBytes;
    @XmlAttribute(name = "n-redirect")
    protected Integer nRedirect;
    @XmlAttribute(name = "n-duplicates")
    protected Integer nDuplicates;
    @XmlAttribute(name = "n-deleted")
    protected Integer nDeleted;
    @XmlAttribute(name = "n-cache-complete")
    protected Integer nCacheComplete;
    @XmlAttribute(name = "converted-size")
    protected Double convertedSize;
    @XmlAttribute
    protected Integer elapsed;
    @XmlAttribute(name = "this-elapsed")
    protected Integer thisElapsed;
    @XmlAttribute(name = "upgrade-schema")
    protected String upgradeSchema;
    @XmlAttribute(name = "sanitize-rebase")
    protected String sanitizeRebase;
    @XmlAttribute(name = "request-rebase")
    protected String requestRebase;
    @XmlAttribute(name = "copy-rebase")
    protected String copyRebase;
    @XmlAttribute(name = "receive-rebase")
    protected String receiveRebase;
    @XmlAttribute
    protected String resume;
    @XmlAttribute
    protected String complete;
    @XmlAttribute
    protected String idle;
    @XmlAttribute(name = "final")
    protected String _final;
    @XmlAttribute(name = "performing-vacuum")
    protected String performingVacuum;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String error;
    @XmlAttribute(name = "config-md5")
    @XmlSchemaType(name = "anySimpleType")
    protected String configMd5;
    @XmlAttribute(name = "service-status")
    protected String serviceStatus;

    /**
     * Gets the value of the converterTimings property.
     * 
     * @return
     *     possible object is
     *     {@link ConverterTimings }
     *     
     */
    public ConverterTimings getConverterTimings() {
        return converterTimings;
    }

    /**
     * Sets the value of the converterTimings property.
     * 
     * @param value
     *     allowed object is
     *     {@link ConverterTimings }
     *     
     */
    public void setConverterTimings(ConverterTimings value) {
        this.converterTimings = value;
    }

    /**
     * Gets the value of the crawlThread property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlThread property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlThread().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlThread }
     * 
     * 
     */
    public List<CrawlThread> getCrawlThread() {
        if (crawlThread == null) {
            crawlThread = new ArrayList<CrawlThread>();
        }
        return this.crawlThread;
    }

    /**
     * Gets the value of the crawlRemoteStatus property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlRemoteStatus property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlRemoteStatus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlRemoteStatus }
     * 
     * 
     */
    public List<CrawlRemoteStatus> getCrawlRemoteStatus() {
        if (crawlRemoteStatus == null) {
            crawlRemoteStatus = new ArrayList<CrawlRemoteStatus>();
        }
        return this.crawlRemoteStatus;
    }

    /**
     * Gets the value of the crawlClientStatus property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlClientStatus property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlClientStatus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlClientStatus }
     * 
     * 
     */
    public List<CrawlClientStatus> getCrawlClientStatus() {
        if (crawlClientStatus == null) {
            crawlClientStatus = new ArrayList<CrawlClientStatus>();
        }
        return this.crawlClientStatus;
    }

    /**
     * Gets the value of the crawlerStatus property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlerStatus property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlerStatus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlerStatus }
     * 
     * 
     */
    public List<CrawlerStatus> getCrawlerStatus() {
        if (crawlerStatus == null) {
            crawlerStatus = new ArrayList<CrawlerStatus>();
        }
        return this.crawlerStatus;
    }

    /**
     * Gets the value of the crawlHopsOutput property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlHopsOutput }
     *     
     */
    public CrawlHopsOutput getCrawlHopsOutput() {
        return crawlHopsOutput;
    }

    /**
     * Sets the value of the crawlHopsOutput property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlHopsOutput }
     *     
     */
    public void setCrawlHopsOutput(CrawlHopsOutput value) {
        this.crawlHopsOutput = value;
    }

    /**
     * Gets the value of the crawlHopsInput property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlHopsInput }
     *     
     */
    public CrawlHopsInput getCrawlHopsInput() {
        return crawlHopsInput;
    }

    /**
     * Sets the value of the crawlHopsInput property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlHopsInput }
     *     
     */
    public void setCrawlHopsInput(CrawlHopsInput value) {
        this.crawlHopsInput = value;
    }

    /**
     * Gets the value of the queues property.
     * 
     * @return
     *     possible object is
     *     {@link Queues }
     *     
     */
    public Queues getQueues() {
        return queues;
    }

    /**
     * Sets the value of the queues property.
     * 
     * @param value
     *     allowed object is
     *     {@link Queues }
     *     
     */
    public void setQueues(Queues value) {
        this.queues = value;
    }

    /**
     * Gets the value of the crawlRemoteAllStatus property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlRemoteAllStatus }
     *     
     */
    public CrawlRemoteAllStatus getCrawlRemoteAllStatus() {
        return crawlRemoteAllStatus;
    }

    /**
     * Sets the value of the crawlRemoteAllStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlRemoteAllStatus }
     *     
     */
    public void setCrawlRemoteAllStatus(CrawlRemoteAllStatus value) {
        this.crawlRemoteAllStatus = value;
    }

    /**
     * Gets the value of the fromCache property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFromCache() {
        return fromCache;
    }

    /**
     * Sets the value of the fromCache property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFromCache(String value) {
        this.fromCache = value;
    }

    /**
     * Gets the value of the version property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVersion() {
        return version;
    }

    /**
     * Sets the value of the version property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVersion(String value) {
        this.version = value;
    }

    /**
     * Gets the value of the id property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getId() {
        return id;
    }

    /**
     * Sets the value of the id property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setId(String value) {
        this.id = value;
    }

    /**
     * Gets the value of the stoppingTime property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getStoppingTime() {
        return stoppingTime;
    }

    /**
     * Sets the value of the stoppingTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setStoppingTime(Long value) {
        this.stoppingTime = value;
    }

    /**
     * Gets the value of the expectedStopTime property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getExpectedStopTime() {
        return expectedStopTime;
    }

    /**
     * Sets the value of the expectedStopTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setExpectedStopTime(Long value) {
        this.expectedStopTime = value;
    }

    /**
     * Gets the value of the time property.
     * 
     */
    public long getTime() {
        return time;
    }

    /**
     * Sets the value of the time property.
     * 
     */
    public void setTime(long value) {
        this.time = value;
    }

    /**
     * Gets the value of the nInput property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNInput() {
        if (nInput == null) {
            return new BigInteger("0");
        } else {
            return nInput;
        }
    }

    /**
     * Sets the value of the nInput property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNInput(BigInteger value) {
        this.nInput = value;
    }

    /**
     * Gets the value of the nOutput property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNOutput() {
        if (nOutput == null) {
            return new BigInteger("0");
        } else {
            return nOutput;
        }
    }

    /**
     * Sets the value of the nOutput property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNOutput(BigInteger value) {
        this.nOutput = value;
    }

    /**
     * Gets the value of the nErrors property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNErrors() {
        if (nErrors == null) {
            return new BigInteger("0");
        } else {
            return nErrors;
        }
    }

    /**
     * Sets the value of the nErrors property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNErrors(BigInteger value) {
        this.nErrors = value;
    }

    /**
     * Gets the value of the nErrorRows property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNErrorRows() {
        if (nErrorRows == null) {
            return new BigInteger("0");
        } else {
            return nErrorRows;
        }
    }

    /**
     * Sets the value of the nErrorRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNErrorRows(BigInteger value) {
        this.nErrorRows = value;
    }

    /**
     * Gets the value of the nHttpErrors property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNHttpErrors() {
        if (nHttpErrors == null) {
            return new BigInteger("0");
        } else {
            return nHttpErrors;
        }
    }

    /**
     * Sets the value of the nHttpErrors property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNHttpErrors(BigInteger value) {
        this.nHttpErrors = value;
    }

    /**
     * Gets the value of the nHttpLocation property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNHttpLocation() {
        if (nHttpLocation == null) {
            return new BigInteger("0");
        } else {
            return nHttpLocation;
        }
    }

    /**
     * Sets the value of the nHttpLocation property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNHttpLocation(BigInteger value) {
        this.nHttpLocation = value;
    }

    /**
     * Gets the value of the nFiltered property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNFiltered() {
        if (nFiltered == null) {
            return new BigInteger("0");
        } else {
            return nFiltered;
        }
    }

    /**
     * Sets the value of the nFiltered property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNFiltered(BigInteger value) {
        this.nFiltered = value;
    }

    /**
     * Gets the value of the nRobots property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNRobots() {
        if (nRobots == null) {
            return new BigInteger("0");
        } else {
            return nRobots;
        }
    }

    /**
     * Sets the value of the nRobots property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNRobots(BigInteger value) {
        this.nRobots = value;
    }

    /**
     * Gets the value of the nPending property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNPending() {
        if (nPending == null) {
            return  0;
        } else {
            return nPending;
        }
    }

    /**
     * Sets the value of the nPending property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNPending(Integer value) {
        this.nPending = value;
    }

    /**
     * Gets the value of the nPendingInternal property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNPendingInternal() {
        if (nPendingInternal == null) {
            return  0;
        } else {
            return nPendingInternal;
        }
    }

    /**
     * Sets the value of the nPendingInternal property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNPendingInternal(Integer value) {
        this.nPendingInternal = value;
    }

    /**
     * Gets the value of the nAwaitingGate property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNAwaitingGate() {
        if (nAwaitingGate == null) {
            return  0;
        } else {
            return nAwaitingGate;
        }
    }

    /**
     * Sets the value of the nAwaitingGate property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNAwaitingGate(Integer value) {
        this.nAwaitingGate = value;
    }

    /**
     * Gets the value of the nAwaitingInput property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNAwaitingInput() {
        if (nAwaitingInput == null) {
            return  0;
        } else {
            return nAwaitingInput;
        }
    }

    /**
     * Sets the value of the nAwaitingInput property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNAwaitingInput(Integer value) {
        this.nAwaitingInput = value;
    }

    /**
     * Gets the value of the nOfflineQueue property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNOfflineQueue() {
        if (nOfflineQueue == null) {
            return new BigInteger("0");
        } else {
            return nOfflineQueue;
        }
    }

    /**
     * Sets the value of the nOfflineQueue property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNOfflineQueue(BigInteger value) {
        this.nOfflineQueue = value;
    }

    /**
     * Gets the value of the nAwaitingIndexInput property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNAwaitingIndexInput() {
        if (nAwaitingIndexInput == null) {
            return  0;
        } else {
            return nAwaitingIndexInput;
        }
    }

    /**
     * Sets the value of the nAwaitingIndexInput property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNAwaitingIndexInput(Integer value) {
        this.nAwaitingIndexInput = value;
    }

    /**
     * Gets the value of the nAwaitingIndexReply property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNAwaitingIndexReply() {
        if (nAwaitingIndexReply == null) {
            return  0;
        } else {
            return nAwaitingIndexReply;
        }
    }

    /**
     * Sets the value of the nAwaitingIndexReply property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNAwaitingIndexReply(Integer value) {
        this.nAwaitingIndexReply = value;
    }

    /**
     * Gets the value of the conversionTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getConversionTime() {
        if (conversionTime == null) {
            return  0;
        } else {
            return conversionTime;
        }
    }

    /**
     * Sets the value of the conversionTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setConversionTime(Integer value) {
        this.conversionTime = value;
    }

    /**
     * Gets the value of the nSub property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNSub() {
        if (nSub == null) {
            return  0;
        } else {
            return nSub;
        }
    }

    /**
     * Sets the value of the nSub property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNSub(Integer value) {
        this.nSub = value;
    }

    /**
     * Gets the value of the nBytes property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getNBytes() {
        if (nBytes == null) {
            return  0.0D;
        } else {
            return nBytes;
        }
    }

    /**
     * Sets the value of the nBytes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setNBytes(Double value) {
        this.nBytes = value;
    }

    /**
     * Gets the value of the nDlBytes property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getNDlBytes() {
        if (nDlBytes == null) {
            return  0.0D;
        } else {
            return nDlBytes;
        }
    }

    /**
     * Sets the value of the nDlBytes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setNDlBytes(Double value) {
        this.nDlBytes = value;
    }

    /**
     * Gets the value of the nRedirect property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNRedirect() {
        if (nRedirect == null) {
            return  0;
        } else {
            return nRedirect;
        }
    }

    /**
     * Sets the value of the nRedirect property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNRedirect(Integer value) {
        this.nRedirect = value;
    }

    /**
     * Gets the value of the nDuplicates property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNDuplicates() {
        if (nDuplicates == null) {
            return  0;
        } else {
            return nDuplicates;
        }
    }

    /**
     * Sets the value of the nDuplicates property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNDuplicates(Integer value) {
        this.nDuplicates = value;
    }

    /**
     * Gets the value of the nDeleted property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNDeleted() {
        if (nDeleted == null) {
            return  0;
        } else {
            return nDeleted;
        }
    }

    /**
     * Sets the value of the nDeleted property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNDeleted(Integer value) {
        this.nDeleted = value;
    }

    /**
     * Gets the value of the nCacheComplete property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNCacheComplete() {
        if (nCacheComplete == null) {
            return  0;
        } else {
            return nCacheComplete;
        }
    }

    /**
     * Sets the value of the nCacheComplete property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNCacheComplete(Integer value) {
        this.nCacheComplete = value;
    }

    /**
     * Gets the value of the convertedSize property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getConvertedSize() {
        if (convertedSize == null) {
            return  0.0D;
        } else {
            return convertedSize;
        }
    }

    /**
     * Sets the value of the convertedSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setConvertedSize(Double value) {
        this.convertedSize = value;
    }

    /**
     * Gets the value of the elapsed property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getElapsed() {
        if (elapsed == null) {
            return  0;
        } else {
            return elapsed;
        }
    }

    /**
     * Sets the value of the elapsed property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setElapsed(Integer value) {
        this.elapsed = value;
    }

    /**
     * Gets the value of the thisElapsed property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getThisElapsed() {
        if (thisElapsed == null) {
            return  0;
        } else {
            return thisElapsed;
        }
    }

    /**
     * Sets the value of the thisElapsed property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setThisElapsed(Integer value) {
        this.thisElapsed = value;
    }

    /**
     * Gets the value of the upgradeSchema property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUpgradeSchema() {
        return upgradeSchema;
    }

    /**
     * Sets the value of the upgradeSchema property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUpgradeSchema(String value) {
        this.upgradeSchema = value;
    }

    /**
     * Gets the value of the sanitizeRebase property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSanitizeRebase() {
        return sanitizeRebase;
    }

    /**
     * Sets the value of the sanitizeRebase property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSanitizeRebase(String value) {
        this.sanitizeRebase = value;
    }

    /**
     * Gets the value of the requestRebase property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRequestRebase() {
        return requestRebase;
    }

    /**
     * Sets the value of the requestRebase property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRequestRebase(String value) {
        this.requestRebase = value;
    }

    /**
     * Gets the value of the copyRebase property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCopyRebase() {
        return copyRebase;
    }

    /**
     * Sets the value of the copyRebase property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCopyRebase(String value) {
        this.copyRebase = value;
    }

    /**
     * Gets the value of the receiveRebase property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReceiveRebase() {
        return receiveRebase;
    }

    /**
     * Sets the value of the receiveRebase property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReceiveRebase(String value) {
        this.receiveRebase = value;
    }

    /**
     * Gets the value of the resume property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getResume() {
        return resume;
    }

    /**
     * Sets the value of the resume property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setResume(String value) {
        this.resume = value;
    }

    /**
     * Gets the value of the complete property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getComplete() {
        return complete;
    }

    /**
     * Sets the value of the complete property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setComplete(String value) {
        this.complete = value;
    }

    /**
     * Gets the value of the idle property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIdle() {
        return idle;
    }

    /**
     * Sets the value of the idle property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIdle(String value) {
        this.idle = value;
    }

    /**
     * Gets the value of the final property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFinal() {
        return _final;
    }

    /**
     * Sets the value of the final property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFinal(String value) {
        this._final = value;
    }

    /**
     * Gets the value of the performingVacuum property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPerformingVacuum() {
        return performingVacuum;
    }

    /**
     * Sets the value of the performingVacuum property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPerformingVacuum(String value) {
        this.performingVacuum = value;
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
     * Gets the value of the configMd5 property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getConfigMd5() {
        return configMd5;
    }

    /**
     * Sets the value of the configMd5 property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setConfigMd5(String value) {
        this.configMd5 = value;
    }

    /**
     * Gets the value of the serviceStatus property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getServiceStatus() {
        return serviceStatus;
    }

    /**
     * Sets the value of the serviceStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setServiceStatus(String value) {
        this.serviceStatus = value;
    }

}
