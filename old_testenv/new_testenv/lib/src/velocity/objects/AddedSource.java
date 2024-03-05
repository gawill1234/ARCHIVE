
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
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


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
 *         &lt;element ref="{urn:/velocity/objects}parse" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}log" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}added-source" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}boost" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}source"/>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="logo" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="variables" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="status">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="queried"/>
 *             &lt;enumeration value="skipped-too-many"/>
 *             &lt;enumeration value="skipped-unsupported-syntax"/>
 *             &lt;enumeration value="ignore"/>
 *             &lt;enumeration value="disabled"/>
 *             &lt;enumeration value="broken"/>
 *             &lt;enumeration value="unknown"/>
 *             &lt;enumeration value="skipped-missing-variables"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="vse-vse">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="vse-vse"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="requested" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="display-name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="source-type" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="admin-url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="total-results" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="total-pre-collapsing" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="total-results-with-duplicates" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="search-ms" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *       &lt;attribute name="retrieval-ms" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *       &lt;attribute name="retrieved" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="discarded" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "parse",
    "log",
    "addedSource",
    "boost"
})
@XmlRootElement(name = "added-source")
public class AddedSource {

    protected List<Parse> parse;
    protected Log log;
    @XmlElement(name = "added-source")
    protected List<AddedSource> addedSource;
    protected List<Boost> boost;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String name;
    @XmlAttribute
    protected String logo;
    @XmlAttribute
    protected String variables;
    @XmlAttribute
    protected String status;
    @XmlAttribute(name = "vse-vse")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String vseVse;
    @XmlAttribute
    protected Integer requested;
    @XmlAttribute(name = "display-name")
    protected String displayName;
    @XmlAttribute(name = "source-type")
    protected String sourceType;
    @XmlAttribute(name = "admin-url")
    protected String adminUrl;
    @XmlAttribute(name = "total-results")
    protected Long totalResults;
    @XmlAttribute(name = "total-pre-collapsing")
    protected Long totalPreCollapsing;
    @XmlAttribute(name = "total-results-with-duplicates")
    protected Long totalResultsWithDuplicates;
    @XmlAttribute(name = "search-ms")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger searchMs;
    @XmlAttribute(name = "retrieval-ms")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger retrievalMs;
    @XmlAttribute
    protected Integer retrieved;
    @XmlAttribute
    protected Integer discarded;
    @XmlAttribute
    protected Integer num;
    @XmlAttribute(name = "num-per-source")
    protected Integer numPerSource;
    @XmlAttribute(name = "over-request")
    protected Double overRequest;
    @XmlAttribute
    protected Double weight;
    @XmlAttribute(name = "no-fetch")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String noFetch;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String sort;
    @XmlAttribute(name = "max-passes")
    protected Integer maxPasses;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String aggregate;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String transparent;
    @XmlAttribute
    protected String maintainers;
    @XmlAttribute(name = "test-strictly")
    protected String testStrictly;

    /**
     * Gets the value of the parse property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the parse property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getParse().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Parse }
     * 
     * 
     */
    public List<Parse> getParse() {
        if (parse == null) {
            parse = new ArrayList<Parse>();
        }
        return this.parse;
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
     * Gets the value of the addedSource property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the addedSource property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getAddedSource().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link AddedSource }
     * 
     * 
     */
    public List<AddedSource> getAddedSource() {
        if (addedSource == null) {
            addedSource = new ArrayList<AddedSource>();
        }
        return this.addedSource;
    }

    /**
     * Gets the value of the boost property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the boost property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getBoost().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Boost }
     * 
     * 
     */
    public List<Boost> getBoost() {
        if (boost == null) {
            boost = new ArrayList<Boost>();
        }
        return this.boost;
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
        return name;
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

    /**
     * Gets the value of the logo property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLogo() {
        return logo;
    }

    /**
     * Sets the value of the logo property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLogo(String value) {
        this.logo = value;
    }

    /**
     * Gets the value of the variables property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVariables() {
        return variables;
    }

    /**
     * Sets the value of the variables property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVariables(String value) {
        this.variables = value;
    }

    /**
     * Gets the value of the status property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStatus() {
        return status;
    }

    /**
     * Sets the value of the status property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStatus(String value) {
        this.status = value;
    }

    /**
     * Gets the value of the vseVse property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseVse() {
        return vseVse;
    }

    /**
     * Sets the value of the vseVse property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseVse(String value) {
        this.vseVse = value;
    }

    /**
     * Gets the value of the requested property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRequested() {
        return requested;
    }

    /**
     * Sets the value of the requested property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRequested(Integer value) {
        this.requested = value;
    }

    /**
     * Gets the value of the displayName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisplayName() {
        return displayName;
    }

    /**
     * Sets the value of the displayName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisplayName(String value) {
        this.displayName = value;
    }

    /**
     * Gets the value of the sourceType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSourceType() {
        return sourceType;
    }

    /**
     * Sets the value of the sourceType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSourceType(String value) {
        this.sourceType = value;
    }

    /**
     * Gets the value of the adminUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAdminUrl() {
        return adminUrl;
    }

    /**
     * Sets the value of the adminUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAdminUrl(String value) {
        this.adminUrl = value;
    }

    /**
     * Gets the value of the totalResults property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getTotalResults() {
        return totalResults;
    }

    /**
     * Sets the value of the totalResults property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setTotalResults(Long value) {
        this.totalResults = value;
    }

    /**
     * Gets the value of the totalPreCollapsing property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getTotalPreCollapsing() {
        return totalPreCollapsing;
    }

    /**
     * Sets the value of the totalPreCollapsing property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setTotalPreCollapsing(Long value) {
        this.totalPreCollapsing = value;
    }

    /**
     * Gets the value of the totalResultsWithDuplicates property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getTotalResultsWithDuplicates() {
        return totalResultsWithDuplicates;
    }

    /**
     * Sets the value of the totalResultsWithDuplicates property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setTotalResultsWithDuplicates(Long value) {
        this.totalResultsWithDuplicates = value;
    }

    /**
     * Gets the value of the searchMs property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getSearchMs() {
        return searchMs;
    }

    /**
     * Sets the value of the searchMs property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setSearchMs(BigInteger value) {
        this.searchMs = value;
    }

    /**
     * Gets the value of the retrievalMs property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getRetrievalMs() {
        return retrievalMs;
    }

    /**
     * Sets the value of the retrievalMs property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setRetrievalMs(BigInteger value) {
        this.retrievalMs = value;
    }

    /**
     * Gets the value of the retrieved property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRetrieved() {
        return retrieved;
    }

    /**
     * Sets the value of the retrieved property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRetrieved(Integer value) {
        this.retrieved = value;
    }

    /**
     * Gets the value of the discarded property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDiscarded() {
        return discarded;
    }

    /**
     * Sets the value of the discarded property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDiscarded(Integer value) {
        this.discarded = value;
    }

    /**
     * Gets the value of the num property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNum() {
        return num;
    }

    /**
     * Sets the value of the num property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNum(Integer value) {
        this.num = value;
    }

    /**
     * Gets the value of the numPerSource property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNumPerSource() {
        if (numPerSource == null) {
            return  50;
        } else {
            return numPerSource;
        }
    }

    /**
     * Sets the value of the numPerSource property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNumPerSource(Integer value) {
        this.numPerSource = value;
    }

    /**
     * Gets the value of the overRequest property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getOverRequest() {
        if (overRequest == null) {
            return  1.0D;
        } else {
            return overRequest;
        }
    }

    /**
     * Sets the value of the overRequest property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setOverRequest(Double value) {
        this.overRequest = value;
    }

    /**
     * Gets the value of the weight property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getWeight() {
        return weight;
    }

    /**
     * Sets the value of the weight property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setWeight(Double value) {
        this.weight = value;
    }

    /**
     * Gets the value of the noFetch property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNoFetch() {
        return noFetch;
    }

    /**
     * Sets the value of the noFetch property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNoFetch(String value) {
        this.noFetch = value;
    }

    /**
     * Gets the value of the sort property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSort() {
        return sort;
    }

    /**
     * Sets the value of the sort property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSort(String value) {
        this.sort = value;
    }

    /**
     * Gets the value of the maxPasses property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMaxPasses() {
        if (maxPasses == null) {
            return  1;
        } else {
            return maxPasses;
        }
    }

    /**
     * Sets the value of the maxPasses property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxPasses(Integer value) {
        this.maxPasses = value;
    }

    /**
     * Gets the value of the aggregate property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAggregate() {
        return aggregate;
    }

    /**
     * Sets the value of the aggregate property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAggregate(String value) {
        this.aggregate = value;
    }

    /**
     * Gets the value of the transparent property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTransparent() {
        return transparent;
    }

    /**
     * Sets the value of the transparent property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTransparent(String value) {
        this.transparent = value;
    }

    /**
     * Gets the value of the maintainers property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMaintainers() {
        return maintainers;
    }

    /**
     * Sets the value of the maintainers property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMaintainers(String value) {
        this.maintainers = value;
    }

    /**
     * Gets the value of the testStrictly property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTestStrictly() {
        return testStrictly;
    }

    /**
     * Sets the value of the testStrictly property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTestStrictly(String value) {
        this.testStrictly = value;
    }

}
