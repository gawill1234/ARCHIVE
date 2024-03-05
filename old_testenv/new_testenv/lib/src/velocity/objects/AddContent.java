
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.XmlValue;
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
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}content"/>
 *       &lt;attribute name="no-merge">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="no-merge"/>
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
    "content"
})
@XmlRootElement(name = "add-content")
public class AddContent {

    @XmlValue
    protected String content;
    @XmlAttribute(name = "no-merge")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String noMerge;
    @XmlAttribute
    protected java.lang.Boolean async;
    @XmlAttribute(name = "elt-id")
    protected Integer eltId;
    @XmlAttribute(name = "max-elt-id")
    protected Integer maxEltId;
    @XmlAttribute(name = "execute-acl")
    protected String executeAcl;
    @XmlAttribute
    protected String process;
    @XmlAttribute
    protected String name;
    @XmlAttribute
    protected Integer count;
    @XmlAttribute
    protected String type;
    @XmlAttribute
    protected String action;
    @XmlAttribute
    protected Double weight;
    @XmlAttribute
    protected java.lang.Boolean indexed;
    @XmlAttribute
    protected String matches;
    @XmlAttribute(name = "max-size")
    protected String maxSize;
    @XmlAttribute(name = "add-to")
    protected String addTo;
    @XmlAttribute
    protected String acl;
    @XmlAttribute(name = "vse-had-acl")
    protected String vseHadAcl;
    @XmlAttribute(name = "vse-add-to-normalized")
    protected String vseAddToNormalized;
    @XmlAttribute(name = "vse-add-to-check")
    protected String vseAddToCheck;
    @XmlAttribute(name = "la-score-multiplier")
    protected Double laScoreMultiplier;
    @XmlAttribute
    protected Integer u;
    @XmlAttribute(name = "fast-index")
    protected FastIndexType fastIndex;
    @XmlAttribute(name = "indexed-fast-index")
    protected FastIndexType indexedFastIndex;
    @XmlAttribute(name = "fast-index-base")
    protected Integer fastIndexBase;
    @XmlAttribute(name = "fast-index-min-exponent")
    protected Integer fastIndexMinExponent;

    /**
     * Gets the value of the content property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getContent() {
        return content;
    }

    /**
     * Sets the value of the content property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setContent(String value) {
        this.content = value;
    }

    /**
     * Gets the value of the noMerge property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNoMerge() {
        return noMerge;
    }

    /**
     * Sets the value of the noMerge property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNoMerge(String value) {
        this.noMerge = value;
    }

    /**
     * Gets the value of the async property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isAsync() {
        if (async == null) {
            return true;
        } else {
            return async;
        }
    }

    /**
     * Sets the value of the async property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setAsync(java.lang.Boolean value) {
        this.async = value;
    }

    /**
     * Gets the value of the eltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEltId() {
        return eltId;
    }

    /**
     * Sets the value of the eltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEltId(Integer value) {
        this.eltId = value;
    }

    /**
     * Gets the value of the maxEltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxEltId() {
        return maxEltId;
    }

    /**
     * Sets the value of the maxEltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxEltId(Integer value) {
        this.maxEltId = value;
    }

    /**
     * Gets the value of the executeAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExecuteAcl() {
        return executeAcl;
    }

    /**
     * Sets the value of the executeAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExecuteAcl(String value) {
        this.executeAcl = value;
    }

    /**
     * Gets the value of the process property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProcess() {
        return process;
    }

    /**
     * Sets the value of the process property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProcess(String value) {
        this.process = value;
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
     * Gets the value of the count property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCount() {
        return count;
    }

    /**
     * Sets the value of the count property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCount(Integer value) {
        this.count = value;
    }

    /**
     * Gets the value of the type property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getType() {
        if (type == null) {
            return "html";
        } else {
            return type;
        }
    }

    /**
     * Sets the value of the type property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setType(String value) {
        this.type = value;
    }

    /**
     * Gets the value of the action property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAction() {
        if (action == null) {
            return "cluster";
        } else {
            return action;
        }
    }

    /**
     * Sets the value of the action property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAction(String value) {
        this.action = value;
    }

    /**
     * Gets the value of the weight property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getWeight() {
        if (weight == null) {
            return  1.0D;
        } else {
            return weight;
        }
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
     * Gets the value of the indexed property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isIndexed() {
        if (indexed == null) {
            return true;
        } else {
            return indexed;
        }
    }

    /**
     * Sets the value of the indexed property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setIndexed(java.lang.Boolean value) {
        this.indexed = value;
    }

    /**
     * Gets the value of the matches property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMatches() {
        return matches;
    }

    /**
     * Sets the value of the matches property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMatches(String value) {
        this.matches = value;
    }

    /**
     * Gets the value of the maxSize property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMaxSize() {
        return maxSize;
    }

    /**
     * Sets the value of the maxSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMaxSize(String value) {
        this.maxSize = value;
    }

    /**
     * Gets the value of the addTo property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAddTo() {
        return addTo;
    }

    /**
     * Sets the value of the addTo property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAddTo(String value) {
        this.addTo = value;
    }

    /**
     * Gets the value of the acl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAcl() {
        return acl;
    }

    /**
     * Sets the value of the acl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAcl(String value) {
        this.acl = value;
    }

    /**
     * Gets the value of the vseHadAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseHadAcl() {
        return vseHadAcl;
    }

    /**
     * Sets the value of the vseHadAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseHadAcl(String value) {
        this.vseHadAcl = value;
    }

    /**
     * Gets the value of the vseAddToNormalized property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseAddToNormalized() {
        return vseAddToNormalized;
    }

    /**
     * Sets the value of the vseAddToNormalized property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseAddToNormalized(String value) {
        this.vseAddToNormalized = value;
    }

    /**
     * Gets the value of the vseAddToCheck property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseAddToCheck() {
        return vseAddToCheck;
    }

    /**
     * Sets the value of the vseAddToCheck property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseAddToCheck(String value) {
        this.vseAddToCheck = value;
    }

    /**
     * Gets the value of the laScoreMultiplier property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getLaScoreMultiplier() {
        return laScoreMultiplier;
    }

    /**
     * Sets the value of the laScoreMultiplier property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setLaScoreMultiplier(Double value) {
        this.laScoreMultiplier = value;
    }

    /**
     * Gets the value of the u property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getU() {
        return u;
    }

    /**
     * Sets the value of the u property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setU(Integer value) {
        this.u = value;
    }

    /**
     * Gets the value of the fastIndex property.
     * 
     * @return
     *     possible object is
     *     {@link FastIndexType }
     *     
     */
    public FastIndexType getFastIndex() {
        return fastIndex;
    }

    /**
     * Sets the value of the fastIndex property.
     * 
     * @param value
     *     allowed object is
     *     {@link FastIndexType }
     *     
     */
    public void setFastIndex(FastIndexType value) {
        this.fastIndex = value;
    }

    /**
     * Gets the value of the indexedFastIndex property.
     * 
     * @return
     *     possible object is
     *     {@link FastIndexType }
     *     
     */
    public FastIndexType getIndexedFastIndex() {
        return indexedFastIndex;
    }

    /**
     * Sets the value of the indexedFastIndex property.
     * 
     * @param value
     *     allowed object is
     *     {@link FastIndexType }
     *     
     */
    public void setIndexedFastIndex(FastIndexType value) {
        this.indexedFastIndex = value;
    }

    /**
     * Gets the value of the fastIndexBase property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getFastIndexBase() {
        if (fastIndexBase == null) {
            return  10;
        } else {
            return fastIndexBase;
        }
    }

    /**
     * Sets the value of the fastIndexBase property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setFastIndexBase(Integer value) {
        this.fastIndexBase = value;
    }

    /**
     * Gets the value of the fastIndexMinExponent property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getFastIndexMinExponent() {
        if (fastIndexMinExponent == null) {
            return  10;
        } else {
            return fastIndexMinExponent;
        }
    }

    /**
     * Sets the value of the fastIndexMinExponent property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setFastIndexMinExponent(Integer value) {
        this.fastIndexMinExponent = value;
    }

}
