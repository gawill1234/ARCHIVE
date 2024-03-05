
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
 *         &lt;element ref="{urn:/velocity/objects}vse-serving" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index-file" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index-cache-statuses" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index-merging-status" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}reconstructor-statuses" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}la-scores-statuses" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index-streams" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}term-expand-dicts-status" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-remote-push-status" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index-builder-status" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="version" type="{http://www.w3.org/2001/XMLSchema}string" default="1.0" />
 *       &lt;attribute name="service-version" type="{http://www.w3.org/2001/XMLSchema}string" default="1.0" />
 *       &lt;attribute name="idle">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="idle"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="starting">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="starting"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="idle-exit" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="idle-time" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="error" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="indexed-urls" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="indexed-datas" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="indexed-docs" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="indexed-contents" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="indexed-bytes" type="{http://www.w3.org/2001/XMLSchema}long" default="0" />
 *       &lt;attribute name="error-items" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="error-datas" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-docs" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="max-docs" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="start-time" use="required" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="end-time" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="running-time" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="stopping-time" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="stopped-at" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *       &lt;attribute name="slice" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-slices" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="identifier" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="config-md5" type="{http://www.w3.org/2001/XMLSchema}string" />
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
    "vseServing",
    "vseIndexFile",
    "vseIndexCacheStatuses",
    "vseIndexMergingStatus",
    "reconstructorStatuses",
    "laScoresStatuses",
    "vseIndexStreams",
    "termExpandDictsStatus",
    "vseRemotePushStatus",
    "vseIndexBuilderStatus"
})
@XmlRootElement(name = "vse-index-status")
public class VseIndexStatus {

    @XmlElement(name = "vse-serving")
    protected VseServing vseServing;
    @XmlElement(name = "vse-index-file")
    protected List<VseIndexFile> vseIndexFile;
    @XmlElement(name = "vse-index-cache-statuses")
    protected VseIndexCacheStatuses vseIndexCacheStatuses;
    @XmlElement(name = "vse-index-merging-status")
    protected VseIndexMergingStatus vseIndexMergingStatus;
    @XmlElement(name = "reconstructor-statuses")
    protected ReconstructorStatuses reconstructorStatuses;
    @XmlElement(name = "la-scores-statuses")
    protected LaScoresStatuses laScoresStatuses;
    @XmlElement(name = "vse-index-streams")
    protected VseIndexStreams vseIndexStreams;
    @XmlElement(name = "term-expand-dicts-status")
    protected TermExpandDictsStatus termExpandDictsStatus;
    @XmlElement(name = "vse-remote-push-status")
    protected VseRemotePushStatus vseRemotePushStatus;
    @XmlElement(name = "vse-index-builder-status")
    protected List<VseIndexBuilderStatus> vseIndexBuilderStatus;
    @XmlAttribute
    protected String version;
    @XmlAttribute(name = "service-version")
    protected String serviceVersion;
    @XmlAttribute
    protected String idle;
    @XmlAttribute
    protected String starting;
    @XmlAttribute(name = "idle-exit")
    protected Integer idleExit;
    @XmlAttribute(name = "idle-time")
    protected Integer idleTime;
    @XmlAttribute
    protected String error;
    @XmlAttribute(name = "indexed-urls")
    protected Integer indexedUrls;
    @XmlAttribute(name = "indexed-datas")
    protected Integer indexedDatas;
    @XmlAttribute(name = "indexed-docs")
    protected Integer indexedDocs;
    @XmlAttribute(name = "indexed-contents")
    protected Integer indexedContents;
    @XmlAttribute(name = "indexed-bytes")
    protected Long indexedBytes;
    @XmlAttribute(name = "error-items")
    protected Integer errorItems;
    @XmlAttribute(name = "error-datas")
    protected Integer errorDatas;
    @XmlAttribute(name = "n-docs")
    protected Integer nDocs;
    @XmlAttribute(name = "max-docs")
    protected Integer maxDocs;
    @XmlAttribute(name = "start-time", required = true)
    protected int startTime;
    @XmlAttribute(name = "end-time")
    protected Integer endTime;
    @XmlAttribute(name = "running-time")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger runningTime;
    @XmlAttribute(name = "stopping-time")
    protected Integer stoppingTime;
    @XmlAttribute(name = "stopped-at")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger stoppedAt;
    @XmlAttribute
    protected Integer slice;
    @XmlAttribute(name = "n-slices")
    protected Integer nSlices;
    @XmlAttribute
    protected String identifier;
    @XmlAttribute(name = "config-md5")
    protected String configMd5;
    @XmlAttribute(name = "service-status")
    protected String serviceStatus;

    /**
     * Gets the value of the vseServing property.
     * 
     * @return
     *     possible object is
     *     {@link VseServing }
     *     
     */
    public VseServing getVseServing() {
        return vseServing;
    }

    /**
     * Sets the value of the vseServing property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseServing }
     *     
     */
    public void setVseServing(VseServing value) {
        this.vseServing = value;
    }

    /**
     * Gets the value of the vseIndexFile property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseIndexFile property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseIndexFile().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseIndexFile }
     * 
     * 
     */
    public List<VseIndexFile> getVseIndexFile() {
        if (vseIndexFile == null) {
            vseIndexFile = new ArrayList<VseIndexFile>();
        }
        return this.vseIndexFile;
    }

    /**
     * Gets the value of the vseIndexCacheStatuses property.
     * 
     * @return
     *     possible object is
     *     {@link VseIndexCacheStatuses }
     *     
     */
    public VseIndexCacheStatuses getVseIndexCacheStatuses() {
        return vseIndexCacheStatuses;
    }

    /**
     * Sets the value of the vseIndexCacheStatuses property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseIndexCacheStatuses }
     *     
     */
    public void setVseIndexCacheStatuses(VseIndexCacheStatuses value) {
        this.vseIndexCacheStatuses = value;
    }

    /**
     * Gets the value of the vseIndexMergingStatus property.
     * 
     * @return
     *     possible object is
     *     {@link VseIndexMergingStatus }
     *     
     */
    public VseIndexMergingStatus getVseIndexMergingStatus() {
        return vseIndexMergingStatus;
    }

    /**
     * Sets the value of the vseIndexMergingStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseIndexMergingStatus }
     *     
     */
    public void setVseIndexMergingStatus(VseIndexMergingStatus value) {
        this.vseIndexMergingStatus = value;
    }

    /**
     * Gets the value of the reconstructorStatuses property.
     * 
     * @return
     *     possible object is
     *     {@link ReconstructorStatuses }
     *     
     */
    public ReconstructorStatuses getReconstructorStatuses() {
        return reconstructorStatuses;
    }

    /**
     * Sets the value of the reconstructorStatuses property.
     * 
     * @param value
     *     allowed object is
     *     {@link ReconstructorStatuses }
     *     
     */
    public void setReconstructorStatuses(ReconstructorStatuses value) {
        this.reconstructorStatuses = value;
    }

    /**
     * Gets the value of the laScoresStatuses property.
     * 
     * @return
     *     possible object is
     *     {@link LaScoresStatuses }
     *     
     */
    public LaScoresStatuses getLaScoresStatuses() {
        return laScoresStatuses;
    }

    /**
     * Sets the value of the laScoresStatuses property.
     * 
     * @param value
     *     allowed object is
     *     {@link LaScoresStatuses }
     *     
     */
    public void setLaScoresStatuses(LaScoresStatuses value) {
        this.laScoresStatuses = value;
    }

    /**
     * Gets the value of the vseIndexStreams property.
     * 
     * @return
     *     possible object is
     *     {@link VseIndexStreams }
     *     
     */
    public VseIndexStreams getVseIndexStreams() {
        return vseIndexStreams;
    }

    /**
     * Sets the value of the vseIndexStreams property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseIndexStreams }
     *     
     */
    public void setVseIndexStreams(VseIndexStreams value) {
        this.vseIndexStreams = value;
    }

    /**
     * Gets the value of the termExpandDictsStatus property.
     * 
     * @return
     *     possible object is
     *     {@link TermExpandDictsStatus }
     *     
     */
    public TermExpandDictsStatus getTermExpandDictsStatus() {
        return termExpandDictsStatus;
    }

    /**
     * Sets the value of the termExpandDictsStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link TermExpandDictsStatus }
     *     
     */
    public void setTermExpandDictsStatus(TermExpandDictsStatus value) {
        this.termExpandDictsStatus = value;
    }

    /**
     * Gets the value of the vseRemotePushStatus property.
     * 
     * @return
     *     possible object is
     *     {@link VseRemotePushStatus }
     *     
     */
    public VseRemotePushStatus getVseRemotePushStatus() {
        return vseRemotePushStatus;
    }

    /**
     * Sets the value of the vseRemotePushStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseRemotePushStatus }
     *     
     */
    public void setVseRemotePushStatus(VseRemotePushStatus value) {
        this.vseRemotePushStatus = value;
    }

    /**
     * Gets the value of the vseIndexBuilderStatus property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseIndexBuilderStatus property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseIndexBuilderStatus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseIndexBuilderStatus }
     * 
     * 
     */
    public List<VseIndexBuilderStatus> getVseIndexBuilderStatus() {
        if (vseIndexBuilderStatus == null) {
            vseIndexBuilderStatus = new ArrayList<VseIndexBuilderStatus>();
        }
        return this.vseIndexBuilderStatus;
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
        if (version == null) {
            return "1.0";
        } else {
            return version;
        }
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
     * Gets the value of the serviceVersion property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getServiceVersion() {
        if (serviceVersion == null) {
            return "1.0";
        } else {
            return serviceVersion;
        }
    }

    /**
     * Sets the value of the serviceVersion property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setServiceVersion(String value) {
        this.serviceVersion = value;
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
     * Gets the value of the starting property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStarting() {
        return starting;
    }

    /**
     * Sets the value of the starting property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStarting(String value) {
        this.starting = value;
    }

    /**
     * Gets the value of the idleExit property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getIdleExit() {
        return idleExit;
    }

    /**
     * Sets the value of the idleExit property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setIdleExit(Integer value) {
        this.idleExit = value;
    }

    /**
     * Gets the value of the idleTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getIdleTime() {
        if (idleTime == null) {
            return  0;
        } else {
            return idleTime;
        }
    }

    /**
     * Sets the value of the idleTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setIdleTime(Integer value) {
        this.idleTime = value;
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
     * Gets the value of the indexedUrls property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getIndexedUrls() {
        if (indexedUrls == null) {
            return  0;
        } else {
            return indexedUrls;
        }
    }

    /**
     * Sets the value of the indexedUrls property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setIndexedUrls(Integer value) {
        this.indexedUrls = value;
    }

    /**
     * Gets the value of the indexedDatas property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getIndexedDatas() {
        if (indexedDatas == null) {
            return  0;
        } else {
            return indexedDatas;
        }
    }

    /**
     * Sets the value of the indexedDatas property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setIndexedDatas(Integer value) {
        this.indexedDatas = value;
    }

    /**
     * Gets the value of the indexedDocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getIndexedDocs() {
        if (indexedDocs == null) {
            return  0;
        } else {
            return indexedDocs;
        }
    }

    /**
     * Sets the value of the indexedDocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setIndexedDocs(Integer value) {
        this.indexedDocs = value;
    }

    /**
     * Gets the value of the indexedContents property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getIndexedContents() {
        if (indexedContents == null) {
            return  0;
        } else {
            return indexedContents;
        }
    }

    /**
     * Sets the value of the indexedContents property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setIndexedContents(Integer value) {
        this.indexedContents = value;
    }

    /**
     * Gets the value of the indexedBytes property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public long getIndexedBytes() {
        if (indexedBytes == null) {
            return  0L;
        } else {
            return indexedBytes;
        }
    }

    /**
     * Sets the value of the indexedBytes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setIndexedBytes(Long value) {
        this.indexedBytes = value;
    }

    /**
     * Gets the value of the errorItems property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getErrorItems() {
        if (errorItems == null) {
            return  0;
        } else {
            return errorItems;
        }
    }

    /**
     * Sets the value of the errorItems property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setErrorItems(Integer value) {
        this.errorItems = value;
    }

    /**
     * Gets the value of the errorDatas property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getErrorDatas() {
        if (errorDatas == null) {
            return  0;
        } else {
            return errorDatas;
        }
    }

    /**
     * Sets the value of the errorDatas property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setErrorDatas(Integer value) {
        this.errorDatas = value;
    }

    /**
     * Gets the value of the nDocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNDocs() {
        if (nDocs == null) {
            return  0;
        } else {
            return nDocs;
        }
    }

    /**
     * Sets the value of the nDocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNDocs(Integer value) {
        this.nDocs = value;
    }

    /**
     * Gets the value of the maxDocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMaxDocs() {
        if (maxDocs == null) {
            return  0;
        } else {
            return maxDocs;
        }
    }

    /**
     * Sets the value of the maxDocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxDocs(Integer value) {
        this.maxDocs = value;
    }

    /**
     * Gets the value of the startTime property.
     * 
     */
    public int getStartTime() {
        return startTime;
    }

    /**
     * Sets the value of the startTime property.
     * 
     */
    public void setStartTime(int value) {
        this.startTime = value;
    }

    /**
     * Gets the value of the endTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEndTime() {
        return endTime;
    }

    /**
     * Sets the value of the endTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEndTime(Integer value) {
        this.endTime = value;
    }

    /**
     * Gets the value of the runningTime property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getRunningTime() {
        if (runningTime == null) {
            return new BigInteger("0");
        } else {
            return runningTime;
        }
    }

    /**
     * Sets the value of the runningTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setRunningTime(BigInteger value) {
        this.runningTime = value;
    }

    /**
     * Gets the value of the stoppingTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStoppingTime() {
        return stoppingTime;
    }

    /**
     * Sets the value of the stoppingTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStoppingTime(Integer value) {
        this.stoppingTime = value;
    }

    /**
     * Gets the value of the stoppedAt property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getStoppedAt() {
        return stoppedAt;
    }

    /**
     * Sets the value of the stoppedAt property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setStoppedAt(BigInteger value) {
        this.stoppedAt = value;
    }

    /**
     * Gets the value of the slice property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getSlice() {
        return slice;
    }

    /**
     * Sets the value of the slice property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setSlice(Integer value) {
        this.slice = value;
    }

    /**
     * Gets the value of the nSlices property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNSlices() {
        return nSlices;
    }

    /**
     * Sets the value of the nSlices property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNSlices(Integer value) {
        this.nSlices = value;
    }

    /**
     * Gets the value of the identifier property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIdentifier() {
        return identifier;
    }

    /**
     * Sets the value of the identifier property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIdentifier(String value) {
        this.identifier = value;
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
