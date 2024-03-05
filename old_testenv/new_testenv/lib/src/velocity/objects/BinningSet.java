
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
 *         &lt;element ref="{urn:/velocity/objects}scope"/>
 *         &lt;sequence>
 *           &lt;element ref="{urn:/velocity/objects}binning-set" maxOccurs="unbounded" minOccurs="0"/>
 *           &lt;element ref="{urn:/velocity/objects}binning-range" maxOccurs="unbounded" minOccurs="0"/>
 *           &lt;element ref="{urn:/velocity/objects}binning-tree" maxOccurs="unbounded" minOccurs="0"/>
 *           &lt;element ref="{urn:/velocity/objects}binning-calculation" maxOccurs="unbounded" minOccurs="0"/>
 *           &lt;element ref="{urn:/velocity/objects}bin" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;/sequence>
 *       &lt;/sequence>
 *       &lt;attribute name="select" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="label" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="other-ndocs" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="bin-label-xpath" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="display-type" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="bs-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="max-bins" type="{http://www.w3.org/2001/XMLSchema}int" default="100" />
 *       &lt;attribute name="disable-bin-pruning">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="disable-bin-pruning"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="n-total-bins" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-output-bins" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="ndocs-not-output" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="ss" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="alpha">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="alpha"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="remove-state" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="restricted-by" default="all-selections">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="all-selections"/>
 *             &lt;enumeration value="other-selections"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="logic" default="and">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="and"/>
 *             &lt;enumeration value="or"/>
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
    "scope",
    "binningSet",
    "binningRange",
    "binningTree",
    "binningCalculation",
    "bin"
})
@XmlRootElement(name = "binning-set")
public class BinningSet {

    @XmlElement(required = true)
    protected Scope scope;
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
    protected String select;
    @XmlAttribute
    protected String label;
    @XmlAttribute(name = "other-ndocs")
    protected Integer otherNdocs;
    @XmlAttribute(name = "bin-label-xpath")
    protected String binLabelXpath;
    @XmlAttribute(name = "display-type")
    protected String displayType;
    @XmlAttribute(name = "bs-id")
    protected String bsId;
    @XmlAttribute(name = "max-bins")
    protected Integer maxBins;
    @XmlAttribute(name = "disable-bin-pruning")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String disableBinPruning;
    @XmlAttribute(name = "n-total-bins")
    protected Integer nTotalBins;
    @XmlAttribute(name = "n-output-bins")
    protected Integer nOutputBins;
    @XmlAttribute(name = "ndocs-not-output")
    protected Integer ndocsNotOutput;
    @XmlAttribute
    protected String ss;
    @XmlAttribute
    protected String alpha;
    @XmlAttribute(name = "remove-state")
    protected String removeState;
    @XmlAttribute(name = "restricted-by")
    protected String restrictedBy;
    @XmlAttribute
    protected String logic;

    /**
     * Gets the value of the scope property.
     * 
     * @return
     *     possible object is
     *     {@link Scope }
     *     
     */
    public Scope getScope() {
        return scope;
    }

    /**
     * Sets the value of the scope property.
     * 
     * @param value
     *     allowed object is
     *     {@link Scope }
     *     
     */
    public void setScope(Scope value) {
        this.scope = value;
    }

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
     * Gets the value of the select property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSelect() {
        return select;
    }

    /**
     * Sets the value of the select property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSelect(String value) {
        this.select = value;
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
     * Gets the value of the otherNdocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getOtherNdocs() {
        return otherNdocs;
    }

    /**
     * Sets the value of the otherNdocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setOtherNdocs(Integer value) {
        this.otherNdocs = value;
    }

    /**
     * Gets the value of the binLabelXpath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBinLabelXpath() {
        return binLabelXpath;
    }

    /**
     * Sets the value of the binLabelXpath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBinLabelXpath(String value) {
        this.binLabelXpath = value;
    }

    /**
     * Gets the value of the displayType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisplayType() {
        return displayType;
    }

    /**
     * Sets the value of the displayType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisplayType(String value) {
        this.displayType = value;
    }

    /**
     * Gets the value of the bsId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBsId() {
        return bsId;
    }

    /**
     * Sets the value of the bsId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBsId(String value) {
        this.bsId = value;
    }

    /**
     * Gets the value of the maxBins property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMaxBins() {
        if (maxBins == null) {
            return  100;
        } else {
            return maxBins;
        }
    }

    /**
     * Sets the value of the maxBins property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxBins(Integer value) {
        this.maxBins = value;
    }

    /**
     * Gets the value of the disableBinPruning property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisableBinPruning() {
        return disableBinPruning;
    }

    /**
     * Sets the value of the disableBinPruning property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisableBinPruning(String value) {
        this.disableBinPruning = value;
    }

    /**
     * Gets the value of the nTotalBins property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNTotalBins() {
        return nTotalBins;
    }

    /**
     * Sets the value of the nTotalBins property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNTotalBins(Integer value) {
        this.nTotalBins = value;
    }

    /**
     * Gets the value of the nOutputBins property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNOutputBins() {
        return nOutputBins;
    }

    /**
     * Sets the value of the nOutputBins property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNOutputBins(Integer value) {
        this.nOutputBins = value;
    }

    /**
     * Gets the value of the ndocsNotOutput property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNdocsNotOutput() {
        return ndocsNotOutput;
    }

    /**
     * Sets the value of the ndocsNotOutput property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNdocsNotOutput(Integer value) {
        this.ndocsNotOutput = value;
    }

    /**
     * Gets the value of the ss property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSs() {
        return ss;
    }

    /**
     * Sets the value of the ss property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSs(String value) {
        this.ss = value;
    }

    /**
     * Gets the value of the alpha property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAlpha() {
        return alpha;
    }

    /**
     * Sets the value of the alpha property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAlpha(String value) {
        this.alpha = value;
    }

    /**
     * Gets the value of the removeState property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoveState() {
        return removeState;
    }

    /**
     * Sets the value of the removeState property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoveState(String value) {
        this.removeState = value;
    }

    /**
     * Gets the value of the restrictedBy property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRestrictedBy() {
        if (restrictedBy == null) {
            return "all-selections";
        } else {
            return restrictedBy;
        }
    }

    /**
     * Sets the value of the restrictedBy property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRestrictedBy(String value) {
        this.restrictedBy = value;
    }

    /**
     * Gets the value of the logic property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLogic() {
        if (logic == null) {
            return "and";
        } else {
            return logic;
        }
    }

    /**
     * Sets the value of the logic property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLogic(String value) {
        this.logic = value;
    }

}
