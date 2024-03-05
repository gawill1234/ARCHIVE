
package velocity.objects;

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
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}condition"/>
 *         &lt;element ref="{urn:/velocity/objects}projection"/>
 *         &lt;element ref="{urn:/velocity/objects}group-by"/>
 *         &lt;element ref="{urn:/velocity/objects}double-group-by"/>
 *       &lt;/choice>
 *       &lt;attribute name="count" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="browse-ref" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="simple" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="label" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="user-label" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="sort-ranks" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="per" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="start" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="temporary" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="browse-match" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="results" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="results-key" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="prefer" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="time-unit" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="sample" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="global" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="status">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="running"/>
 *             &lt;enumeration value="finished"/>
 *             &lt;enumeration value="aborted"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="key-label" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "conditionOrProjectionOrGroupBy"
})
@XmlRootElement(name = "report-item")
public class ReportItem {

    @XmlElements({
        @XmlElement(name = "projection", type = Projection.class),
        @XmlElement(name = "condition", type = Condition.class),
        @XmlElement(name = "double-group-by", type = DoubleGroupBy.class),
        @XmlElement(name = "group-by", type = GroupBy.class)
    })
    protected List<Object> conditionOrProjectionOrGroupBy;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String count;
    @XmlAttribute(name = "browse-ref")
    @XmlSchemaType(name = "anySimpleType")
    protected String browseRef;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String simple;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String label;
    @XmlAttribute(name = "user-label")
    @XmlSchemaType(name = "anySimpleType")
    protected String userLabel;
    @XmlAttribute(name = "sort-ranks")
    @XmlSchemaType(name = "anySimpleType")
    protected String sortRanks;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String per;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String start;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String temporary;
    @XmlAttribute(name = "browse-match")
    @XmlSchemaType(name = "anySimpleType")
    protected String browseMatch;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String results;
    @XmlAttribute(name = "results-key")
    @XmlSchemaType(name = "anySimpleType")
    protected String resultsKey;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String prefer;
    @XmlAttribute(name = "time-unit")
    @XmlSchemaType(name = "anySimpleType")
    protected String timeUnit;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String sample;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String id;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String global;
    @XmlAttribute
    protected String status;
    @XmlAttribute(name = "key-label")
    @XmlSchemaType(name = "anySimpleType")
    protected String keyLabel;

    /**
     * Gets the value of the conditionOrProjectionOrGroupBy property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the conditionOrProjectionOrGroupBy property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getConditionOrProjectionOrGroupBy().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Projection }
     * {@link Condition }
     * {@link DoubleGroupBy }
     * {@link GroupBy }
     * 
     * 
     */
    public List<Object> getConditionOrProjectionOrGroupBy() {
        if (conditionOrProjectionOrGroupBy == null) {
            conditionOrProjectionOrGroupBy = new ArrayList<Object>();
        }
        return this.conditionOrProjectionOrGroupBy;
    }

    /**
     * Gets the value of the count property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCount() {
        return count;
    }

    /**
     * Sets the value of the count property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCount(String value) {
        this.count = value;
    }

    /**
     * Gets the value of the browseRef property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBrowseRef() {
        return browseRef;
    }

    /**
     * Sets the value of the browseRef property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBrowseRef(String value) {
        this.browseRef = value;
    }

    /**
     * Gets the value of the simple property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSimple() {
        return simple;
    }

    /**
     * Sets the value of the simple property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSimple(String value) {
        this.simple = value;
    }

    /**
     * Gets the value of the label property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLabel() {
        return label;
    }

    /**
     * Sets the value of the label property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLabel(String value) {
        this.label = value;
    }

    /**
     * Gets the value of the userLabel property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUserLabel() {
        return userLabel;
    }

    /**
     * Sets the value of the userLabel property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUserLabel(String value) {
        this.userLabel = value;
    }

    /**
     * Gets the value of the sortRanks property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSortRanks() {
        return sortRanks;
    }

    /**
     * Sets the value of the sortRanks property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSortRanks(String value) {
        this.sortRanks = value;
    }

    /**
     * Gets the value of the per property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPer() {
        return per;
    }

    /**
     * Sets the value of the per property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPer(String value) {
        this.per = value;
    }

    /**
     * Gets the value of the start property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStart() {
        return start;
    }

    /**
     * Sets the value of the start property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStart(String value) {
        this.start = value;
    }

    /**
     * Gets the value of the temporary property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTemporary() {
        return temporary;
    }

    /**
     * Sets the value of the temporary property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTemporary(String value) {
        this.temporary = value;
    }

    /**
     * Gets the value of the browseMatch property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBrowseMatch() {
        return browseMatch;
    }

    /**
     * Sets the value of the browseMatch property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBrowseMatch(String value) {
        this.browseMatch = value;
    }

    /**
     * Gets the value of the results property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getResults() {
        return results;
    }

    /**
     * Sets the value of the results property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setResults(String value) {
        this.results = value;
    }

    /**
     * Gets the value of the resultsKey property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getResultsKey() {
        return resultsKey;
    }

    /**
     * Sets the value of the resultsKey property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setResultsKey(String value) {
        this.resultsKey = value;
    }

    /**
     * Gets the value of the prefer property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPrefer() {
        return prefer;
    }

    /**
     * Sets the value of the prefer property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPrefer(String value) {
        this.prefer = value;
    }

    /**
     * Gets the value of the timeUnit property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTimeUnit() {
        return timeUnit;
    }

    /**
     * Sets the value of the timeUnit property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTimeUnit(String value) {
        this.timeUnit = value;
    }

    /**
     * Gets the value of the sample property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSample() {
        return sample;
    }

    /**
     * Sets the value of the sample property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSample(String value) {
        this.sample = value;
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
     * Gets the value of the global property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGlobal() {
        return global;
    }

    /**
     * Sets the value of the global property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGlobal(String value) {
        this.global = value;
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
     * Gets the value of the keyLabel property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getKeyLabel() {
        return keyLabel;
    }

    /**
     * Sets the value of the keyLabel property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setKeyLabel(String value) {
        this.keyLabel = value;
    }

}
