
package velocity.objects;

import java.math.BigInteger;
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
 *         &lt;element name="maximum-collections" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="always-allow-one-collection" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="prefer-requests" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="search"/>
 *               &lt;enumeration value="enqueue"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *         &lt;element name="minimum-free-memory" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" minOccurs="0"/>
 *         &lt;element name="overcommit-factor" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="indexer-overhead" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" minOccurs="0"/>
 *         &lt;element name="crawler-overhead" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" minOccurs="0"/>
 *         &lt;element name="indexer-minimum" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" minOccurs="0"/>
 *         &lt;element name="crawler-minimum" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" minOccurs="0"/>
 *         &lt;element name="memory-granularity" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" minOccurs="0"/>
 *         &lt;element name="time-granularity" type="{http://www.w3.org/2001/XMLSchema}long" minOccurs="0"/>
 *         &lt;element name="check-online-time" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="current-status-time" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="start-offline-time" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="check-memory-usage-time" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="persistent-save-time" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="live-ping-probability" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="check-online-are-responsive-time" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="check-online-are-responsive-timeout-time" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="name" use="required" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" fixed="global" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "maximumCollections",
    "alwaysAllowOneCollection",
    "preferRequests",
    "minimumFreeMemory",
    "overcommitFactor",
    "indexerOverhead",
    "crawlerOverhead",
    "indexerMinimum",
    "crawlerMinimum",
    "memoryGranularity",
    "timeGranularity",
    "checkOnlineTime",
    "currentStatusTime",
    "startOfflineTime",
    "checkMemoryUsageTime",
    "persistentSaveTime",
    "livePingProbability",
    "checkOnlineAreResponsiveTime",
    "checkOnlineAreResponsiveTimeoutTime"
})
@XmlRootElement(name = "collection-broker-configuration")
public class CollectionBrokerConfiguration {

    @XmlElement(name = "maximum-collections", defaultValue = "-1")
    protected Integer maximumCollections;
    @XmlElement(name = "always-allow-one-collection", defaultValue = "true")
    protected java.lang.Boolean alwaysAllowOneCollection;
    @XmlElement(name = "prefer-requests", defaultValue = "search")
    protected String preferRequests;
    @XmlElement(name = "minimum-free-memory", defaultValue = "262144000")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger minimumFreeMemory;
    @XmlElement(name = "overcommit-factor", defaultValue = "0.75")
    protected Double overcommitFactor;
    @XmlElement(name = "indexer-overhead", defaultValue = "262144000")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger indexerOverhead;
    @XmlElement(name = "crawler-overhead", defaultValue = "262144000")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger crawlerOverhead;
    @XmlElement(name = "indexer-minimum", defaultValue = "367001600")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger indexerMinimum;
    @XmlElement(name = "crawler-minimum", defaultValue = "367001600")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger crawlerMinimum;
    @XmlElement(name = "memory-granularity", defaultValue = "10485760")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger memoryGranularity;
    @XmlElement(name = "time-granularity", defaultValue = "30")
    protected Long timeGranularity;
    @XmlElement(name = "check-online-time", defaultValue = "10")
    protected Double checkOnlineTime;
    @XmlElement(name = "current-status-time", defaultValue = "20")
    protected Double currentStatusTime;
    @XmlElement(name = "start-offline-time", defaultValue = "15")
    protected Double startOfflineTime;
    @XmlElement(name = "check-memory-usage-time", defaultValue = "3")
    protected Double checkMemoryUsageTime;
    @XmlElement(name = "persistent-save-time", defaultValue = "10")
    protected Double persistentSaveTime;
    @XmlElement(name = "live-ping-probability", defaultValue = "0.1")
    protected Double livePingProbability;
    @XmlElement(name = "check-online-are-responsive-time", defaultValue = "120")
    protected Double checkOnlineAreResponsiveTime;
    @XmlElement(name = "check-online-are-responsive-timeout-time", defaultValue = "120")
    protected Double checkOnlineAreResponsiveTimeoutTime;
    @XmlAttribute(required = true)
    @XmlSchemaType(name = "anySimpleType")
    protected String name;

    /**
     * Gets the value of the maximumCollections property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaximumCollections() {
        return maximumCollections;
    }

    /**
     * Sets the value of the maximumCollections property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaximumCollections(Integer value) {
        this.maximumCollections = value;
    }

    /**
     * Gets the value of the alwaysAllowOneCollection property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isAlwaysAllowOneCollection() {
        return alwaysAllowOneCollection;
    }

    /**
     * Sets the value of the alwaysAllowOneCollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setAlwaysAllowOneCollection(java.lang.Boolean value) {
        this.alwaysAllowOneCollection = value;
    }

    /**
     * Gets the value of the preferRequests property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPreferRequests() {
        return preferRequests;
    }

    /**
     * Sets the value of the preferRequests property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPreferRequests(String value) {
        this.preferRequests = value;
    }

    /**
     * Gets the value of the minimumFreeMemory property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getMinimumFreeMemory() {
        return minimumFreeMemory;
    }

    /**
     * Sets the value of the minimumFreeMemory property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setMinimumFreeMemory(BigInteger value) {
        this.minimumFreeMemory = value;
    }

    /**
     * Gets the value of the overcommitFactor property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getOvercommitFactor() {
        return overcommitFactor;
    }

    /**
     * Sets the value of the overcommitFactor property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setOvercommitFactor(Double value) {
        this.overcommitFactor = value;
    }

    /**
     * Gets the value of the indexerOverhead property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getIndexerOverhead() {
        return indexerOverhead;
    }

    /**
     * Sets the value of the indexerOverhead property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setIndexerOverhead(BigInteger value) {
        this.indexerOverhead = value;
    }

    /**
     * Gets the value of the crawlerOverhead property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getCrawlerOverhead() {
        return crawlerOverhead;
    }

    /**
     * Sets the value of the crawlerOverhead property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setCrawlerOverhead(BigInteger value) {
        this.crawlerOverhead = value;
    }

    /**
     * Gets the value of the indexerMinimum property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getIndexerMinimum() {
        return indexerMinimum;
    }

    /**
     * Sets the value of the indexerMinimum property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setIndexerMinimum(BigInteger value) {
        this.indexerMinimum = value;
    }

    /**
     * Gets the value of the crawlerMinimum property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getCrawlerMinimum() {
        return crawlerMinimum;
    }

    /**
     * Sets the value of the crawlerMinimum property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setCrawlerMinimum(BigInteger value) {
        this.crawlerMinimum = value;
    }

    /**
     * Gets the value of the memoryGranularity property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getMemoryGranularity() {
        return memoryGranularity;
    }

    /**
     * Sets the value of the memoryGranularity property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setMemoryGranularity(BigInteger value) {
        this.memoryGranularity = value;
    }

    /**
     * Gets the value of the timeGranularity property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getTimeGranularity() {
        return timeGranularity;
    }

    /**
     * Sets the value of the timeGranularity property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setTimeGranularity(Long value) {
        this.timeGranularity = value;
    }

    /**
     * Gets the value of the checkOnlineTime property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getCheckOnlineTime() {
        return checkOnlineTime;
    }

    /**
     * Sets the value of the checkOnlineTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setCheckOnlineTime(Double value) {
        this.checkOnlineTime = value;
    }

    /**
     * Gets the value of the currentStatusTime property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getCurrentStatusTime() {
        return currentStatusTime;
    }

    /**
     * Sets the value of the currentStatusTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setCurrentStatusTime(Double value) {
        this.currentStatusTime = value;
    }

    /**
     * Gets the value of the startOfflineTime property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getStartOfflineTime() {
        return startOfflineTime;
    }

    /**
     * Sets the value of the startOfflineTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setStartOfflineTime(Double value) {
        this.startOfflineTime = value;
    }

    /**
     * Gets the value of the checkMemoryUsageTime property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getCheckMemoryUsageTime() {
        return checkMemoryUsageTime;
    }

    /**
     * Sets the value of the checkMemoryUsageTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setCheckMemoryUsageTime(Double value) {
        this.checkMemoryUsageTime = value;
    }

    /**
     * Gets the value of the persistentSaveTime property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getPersistentSaveTime() {
        return persistentSaveTime;
    }

    /**
     * Sets the value of the persistentSaveTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setPersistentSaveTime(Double value) {
        this.persistentSaveTime = value;
    }

    /**
     * Gets the value of the livePingProbability property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getLivePingProbability() {
        return livePingProbability;
    }

    /**
     * Sets the value of the livePingProbability property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setLivePingProbability(Double value) {
        this.livePingProbability = value;
    }

    /**
     * Gets the value of the checkOnlineAreResponsiveTime property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getCheckOnlineAreResponsiveTime() {
        return checkOnlineAreResponsiveTime;
    }

    /**
     * Sets the value of the checkOnlineAreResponsiveTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setCheckOnlineAreResponsiveTime(Double value) {
        this.checkOnlineAreResponsiveTime = value;
    }

    /**
     * Gets the value of the checkOnlineAreResponsiveTimeoutTime property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getCheckOnlineAreResponsiveTimeoutTime() {
        return checkOnlineAreResponsiveTimeoutTime;
    }

    /**
     * Sets the value of the checkOnlineAreResponsiveTimeoutTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setCheckOnlineAreResponsiveTimeoutTime(Double value) {
        this.checkOnlineAreResponsiveTimeoutTime = value;
    }

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        if (name == null) {
            return "global";
        } else {
            return name;
        }
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
    }

}
