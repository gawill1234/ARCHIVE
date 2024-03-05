
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
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
 *         &lt;element ref="{urn:/velocity/objects}binning-set" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}binning-range" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}binning-tree" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}binning-calculation" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}bin" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="label" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="label-low" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="label-high" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="ndocs" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="cndocs" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="token" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="state" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="br-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="low" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="high" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="pruned-children">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="pruned-children"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="active">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="active"/>
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
    "binningSet",
    "binningRange",
    "binningTree",
    "binningCalculation",
    "bin"
})
@XmlRootElement(name = "bin")
public class Bin {

    @XmlElement(name = "binning-set")
    protected List<BinningSet> binningSet;
    @XmlElement(name = "binning-range")
    protected List<BinningRange> binningRange;
    @XmlElement(name = "binning-tree")
    protected List<BinningTree> binningTree;
    @XmlElement(name = "binning-calculation")
    protected List<BinningCalculation> binningCalculation;
    protected List<Bin> bin;
    @XmlAttribute
    protected String label;
    @XmlAttribute(name = "label-low")
    protected String labelLow;
    @XmlAttribute(name = "label-high")
    protected String labelHigh;
    @XmlAttribute
    protected Integer ndocs;
    @XmlAttribute
    protected Integer cndocs;
    @XmlAttribute
    protected String token;
    @XmlAttribute
    protected String state;
    @XmlAttribute(name = "br-id")
    protected String brId;
    @XmlAttribute
    protected Double low;
    @XmlAttribute
    protected Double high;
    @XmlAttribute(name = "pruned-children")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String prunedChildren;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String active;

    /**
     * Gets the value of the binningSet property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the binningSet property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getBinningSet().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link BinningSet }
     * 
     * 
     */
    public List<BinningSet> getBinningSet() {
        if (binningSet == null) {
            binningSet = new ArrayList<BinningSet>();
        }
        return this.binningSet;
    }

    /**
     * Gets the value of the binningRange property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the binningRange property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getBinningRange().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link BinningRange }
     * 
     * 
     */
    public List<BinningRange> getBinningRange() {
        if (binningRange == null) {
            binningRange = new ArrayList<BinningRange>();
        }
        return this.binningRange;
    }

    /**
     * Gets the value of the binningTree property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the binningTree property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getBinningTree().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link BinningTree }
     * 
     * 
     */
    public List<BinningTree> getBinningTree() {
        if (binningTree == null) {
            binningTree = new ArrayList<BinningTree>();
        }
        return this.binningTree;
    }

    /**
     * Gets the value of the binningCalculation property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the binningCalculation property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getBinningCalculation().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link BinningCalculation }
     * 
     * 
     */
    public List<BinningCalculation> getBinningCalculation() {
        if (binningCalculation == null) {
            binningCalculation = new ArrayList<BinningCalculation>();
        }
        return this.binningCalculation;
    }

    /**
     * Gets the value of the bin property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the bin property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getBin().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Bin }
     * 
     * 
     */
    public List<Bin> getBin() {
        if (bin == null) {
            bin = new ArrayList<Bin>();
        }
        return this.bin;
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
     * Gets the value of the labelLow property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLabelLow() {
        return labelLow;
    }

    /**
     * Sets the value of the labelLow property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLabelLow(String value) {
        this.labelLow = value;
    }

    /**
     * Gets the value of the labelHigh property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLabelHigh() {
        return labelHigh;
    }

    /**
     * Sets the value of the labelHigh property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLabelHigh(String value) {
        this.labelHigh = value;
    }

    /**
     * Gets the value of the ndocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNdocs() {
        return ndocs;
    }

    /**
     * Sets the value of the ndocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNdocs(Integer value) {
        this.ndocs = value;
    }

    /**
     * Gets the value of the cndocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCndocs() {
        return cndocs;
    }

    /**
     * Sets the value of the cndocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCndocs(Integer value) {
        this.cndocs = value;
    }

    /**
     * Gets the value of the token property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getToken() {
        return token;
    }

    /**
     * Sets the value of the token property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setToken(String value) {
        this.token = value;
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
     * Gets the value of the brId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBrId() {
        return brId;
    }

    /**
     * Sets the value of the brId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBrId(String value) {
        this.brId = value;
    }

    /**
     * Gets the value of the low property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getLow() {
        return low;
    }

    /**
     * Sets the value of the low property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setLow(Double value) {
        this.low = value;
    }

    /**
     * Gets the value of the high property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getHigh() {
        return high;
    }

    /**
     * Sets the value of the high property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setHigh(Double value) {
        this.high = value;
    }

    /**
     * Gets the value of the prunedChildren property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPrunedChildren() {
        return prunedChildren;
    }

    /**
     * Sets the value of the prunedChildren property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPrunedChildren(String value) {
        this.prunedChildren = value;
    }

    /**
     * Gets the value of the active property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getActive() {
        return active;
    }

    /**
     * Sets the value of the active property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setActive(String value) {
        this.active = value;
    }

}
