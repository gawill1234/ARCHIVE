
package velocity.objects;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAnyAttribute;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.XmlValue;
import javax.xml.namespace.QName;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;simpleContent>
 *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}content"/>
 *       &lt;attribute name="matched" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="vse-streams" default="0">
 *         &lt;simpleType>
 *           &lt;list itemType="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;anyAttribute processContents='lax'/>
 *     &lt;/extension>
 *   &lt;/simpleContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "value"
})
@XmlRootElement(name = "content")
public class Content {

    @XmlValue
    protected String value;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long matched;
    @XmlAttribute(name = "vse-streams")
    protected List<Long> vseStreams;
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
    @XmlAnyAttribute
    private Map<QName, String> otherAttributes = new HashMap<QName, String>();

    /**
     * Gets the value of the value property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getValue() {
        return value;
    }

    /**
     * Sets the value of the value property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setValue(String value) {
        this.value = value;
    }

    /**
     * Gets the value of the matched property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getMatched() {
        return matched;
    }

    /**
     * Sets the value of the matched property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setMatched(Long value) {
        this.matched = value;
    }

    /**
     * Gets the value of the vseStreams property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseStreams property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseStreams().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Long }
     * 
     * 
     */
    public List<Long> getVseStreams() {
        if (vseStreams == null) {
            vseStreams = new ArrayList<Long>();
        }
        return this.vseStreams;
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

    /**
     * Gets a map that contains attributes that aren't bound to any typed property on this class.
     * 
     * <p>
     * the map is keyed by the name of the attribute and 
     * the value is the string value of the attribute.
     * 
     * the map returned by this method is live, and you can add new attribute
     * by updating the map directly. Because of this design, there's no setter.
     * 
     * 
     * @return
     *     always non-null
     */
    public Map<QName, String> getOtherAttributes() {
        return otherAttributes;
    }

}
