
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *       &lt;attribute name="aggregation" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="aggregation-table" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="main-key" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="main-key-table" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="second-key" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="second-key-table" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="join-command" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="label" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="sort-rank" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="sort-id" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="sort-direction" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="fmt" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="sample-scale" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "double-group-by")
public class DoubleGroupBy {

    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String aggregation;
    @XmlAttribute(name = "aggregation-table")
    @XmlSchemaType(name = "anySimpleType")
    protected String aggregationTable;
    @XmlAttribute(name = "main-key")
    @XmlSchemaType(name = "anySimpleType")
    protected String mainKey;
    @XmlAttribute(name = "main-key-table")
    @XmlSchemaType(name = "anySimpleType")
    protected String mainKeyTable;
    @XmlAttribute(name = "second-key")
    @XmlSchemaType(name = "anySimpleType")
    protected String secondKey;
    @XmlAttribute(name = "second-key-table")
    @XmlSchemaType(name = "anySimpleType")
    protected String secondKeyTable;
    @XmlAttribute(name = "join-command")
    @XmlSchemaType(name = "anySimpleType")
    protected String joinCommand;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String label;
    @XmlAttribute(name = "sort-rank")
    @XmlSchemaType(name = "anySimpleType")
    protected String sortRank;
    @XmlAttribute(name = "sort-id")
    @XmlSchemaType(name = "anySimpleType")
    protected String sortId;
    @XmlAttribute(name = "sort-direction")
    @XmlSchemaType(name = "anySimpleType")
    protected String sortDirection;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String fmt;
    @XmlAttribute(name = "sample-scale")
    @XmlSchemaType(name = "anySimpleType")
    protected String sampleScale;

    /**
     * Gets the value of the aggregation property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAggregation() {
        return aggregation;
    }

    /**
     * Sets the value of the aggregation property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAggregation(String value) {
        this.aggregation = value;
    }

    /**
     * Gets the value of the aggregationTable property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAggregationTable() {
        return aggregationTable;
    }

    /**
     * Sets the value of the aggregationTable property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAggregationTable(String value) {
        this.aggregationTable = value;
    }

    /**
     * Gets the value of the mainKey property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMainKey() {
        return mainKey;
    }

    /**
     * Sets the value of the mainKey property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMainKey(String value) {
        this.mainKey = value;
    }

    /**
     * Gets the value of the mainKeyTable property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMainKeyTable() {
        return mainKeyTable;
    }

    /**
     * Sets the value of the mainKeyTable property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMainKeyTable(String value) {
        this.mainKeyTable = value;
    }

    /**
     * Gets the value of the secondKey property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSecondKey() {
        return secondKey;
    }

    /**
     * Sets the value of the secondKey property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSecondKey(String value) {
        this.secondKey = value;
    }

    /**
     * Gets the value of the secondKeyTable property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSecondKeyTable() {
        return secondKeyTable;
    }

    /**
     * Sets the value of the secondKeyTable property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSecondKeyTable(String value) {
        this.secondKeyTable = value;
    }

    /**
     * Gets the value of the joinCommand property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getJoinCommand() {
        return joinCommand;
    }

    /**
     * Sets the value of the joinCommand property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setJoinCommand(String value) {
        this.joinCommand = value;
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
     * Gets the value of the sortRank property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSortRank() {
        return sortRank;
    }

    /**
     * Sets the value of the sortRank property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSortRank(String value) {
        this.sortRank = value;
    }

    /**
     * Gets the value of the sortId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSortId() {
        return sortId;
    }

    /**
     * Sets the value of the sortId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSortId(String value) {
        this.sortId = value;
    }

    /**
     * Gets the value of the sortDirection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSortDirection() {
        return sortDirection;
    }

    /**
     * Sets the value of the sortDirection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSortDirection(String value) {
        this.sortDirection = value;
    }

    /**
     * Gets the value of the fmt property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFmt() {
        return fmt;
    }

    /**
     * Sets the value of the fmt property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFmt(String value) {
        this.fmt = value;
    }

    /**
     * Gets the value of the sampleScale property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSampleScale() {
        return sampleScale;
    }

    /**
     * Sets the value of the sampleScale property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSampleScale(String value) {
        this.sampleScale = value;
    }

}