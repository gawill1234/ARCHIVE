
package velocity.objects;

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
 *         &lt;element ref="{urn:/velocity/objects}dictionary-inputs"/>
 *         &lt;element ref="{urn:/velocity/objects}dictionary-outputs"/>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}repository"/>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="prune-size" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="manual-dictionary" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="auth-dict-source" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="input-stemmer" type="{http://www.w3.org/2001/XMLSchema}string" default="case" />
 *       &lt;attribute name="input-segmenter" type="{http://www.w3.org/2001/XMLSchema}string" default="none" />
 *       &lt;attribute name="min-length" type="{http://www.w3.org/2001/XMLSchema}int" default="4" />
 *       &lt;attribute name="min-letter-percentage" type="{http://www.w3.org/2001/XMLSchema}double" default="0.5" />
 *       &lt;attribute name="should-tokenize" type="{http://www.w3.org/2001/XMLSchema}boolean" default="true" />
 *       &lt;attribute name="rights-function" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" default="util-groups-for-user" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "dictionaryInputs",
    "dictionaryOutputs"
})
@XmlRootElement(name = "dictionary")
public class Dictionary {

    @XmlElement(name = "dictionary-inputs", required = true)
    protected DictionaryInputs dictionaryInputs;
    @XmlElement(name = "dictionary-outputs", required = true)
    protected DictionaryOutputs dictionaryOutputs;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String name;
    @XmlAttribute(name = "prune-size")
    protected Integer pruneSize;
    @XmlAttribute(name = "manual-dictionary")
    protected String manualDictionary;
    @XmlAttribute(name = "auth-dict-source")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String authDictSource;
    @XmlAttribute(name = "input-stemmer")
    protected String inputStemmer;
    @XmlAttribute(name = "input-segmenter")
    protected String inputSegmenter;
    @XmlAttribute(name = "min-length")
    protected Integer minLength;
    @XmlAttribute(name = "min-letter-percentage")
    protected Double minLetterPercentage;
    @XmlAttribute(name = "should-tokenize")
    protected java.lang.Boolean shouldTokenize;
    @XmlAttribute(name = "rights-function")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String rightsFunction;
    @XmlAttribute
    protected String internal;
    @XmlAttribute
    protected String overrides;
    @XmlAttribute(name = "overrides-status")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String overridesStatus;
    @XmlAttribute(name = "no-override")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String noOverride;
    @XmlAttribute
    protected Integer modified;
    @XmlAttribute(name = "modified-by")
    protected String modifiedBy;
    @XmlAttribute(name = "do-not-delete")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String doNotDelete;
    @XmlAttribute(name = "read-only")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String readOnly;
    @XmlAttribute
    protected List<String> products;

    /**
     * Gets the value of the dictionaryInputs property.
     * 
     * @return
     *     possible object is
     *     {@link DictionaryInputs }
     *     
     */
    public DictionaryInputs getDictionaryInputs() {
        return dictionaryInputs;
    }

    /**
     * Sets the value of the dictionaryInputs property.
     * 
     * @param value
     *     allowed object is
     *     {@link DictionaryInputs }
     *     
     */
    public void setDictionaryInputs(DictionaryInputs value) {
        this.dictionaryInputs = value;
    }

    /**
     * Gets the value of the dictionaryOutputs property.
     * 
     * @return
     *     possible object is
     *     {@link DictionaryOutputs }
     *     
     */
    public DictionaryOutputs getDictionaryOutputs() {
        return dictionaryOutputs;
    }

    /**
     * Sets the value of the dictionaryOutputs property.
     * 
     * @param value
     *     allowed object is
     *     {@link DictionaryOutputs }
     *     
     */
    public void setDictionaryOutputs(DictionaryOutputs value) {
        this.dictionaryOutputs = value;
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
     * Gets the value of the pruneSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getPruneSize() {
        return pruneSize;
    }

    /**
     * Sets the value of the pruneSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPruneSize(Integer value) {
        this.pruneSize = value;
    }

    /**
     * Gets the value of the manualDictionary property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getManualDictionary() {
        return manualDictionary;
    }

    /**
     * Sets the value of the manualDictionary property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setManualDictionary(String value) {
        this.manualDictionary = value;
    }

    /**
     * Gets the value of the authDictSource property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthDictSource() {
        return authDictSource;
    }

    /**
     * Sets the value of the authDictSource property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthDictSource(String value) {
        this.authDictSource = value;
    }

    /**
     * Gets the value of the inputStemmer property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInputStemmer() {
        if (inputStemmer == null) {
            return "case";
        } else {
            return inputStemmer;
        }
    }

    /**
     * Sets the value of the inputStemmer property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInputStemmer(String value) {
        this.inputStemmer = value;
    }

    /**
     * Gets the value of the inputSegmenter property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInputSegmenter() {
        if (inputSegmenter == null) {
            return "none";
        } else {
            return inputSegmenter;
        }
    }

    /**
     * Sets the value of the inputSegmenter property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInputSegmenter(String value) {
        this.inputSegmenter = value;
    }

    /**
     * Gets the value of the minLength property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMinLength() {
        if (minLength == null) {
            return  4;
        } else {
            return minLength;
        }
    }

    /**
     * Sets the value of the minLength property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMinLength(Integer value) {
        this.minLength = value;
    }

    /**
     * Gets the value of the minLetterPercentage property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getMinLetterPercentage() {
        if (minLetterPercentage == null) {
            return  0.5D;
        } else {
            return minLetterPercentage;
        }
    }

    /**
     * Sets the value of the minLetterPercentage property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setMinLetterPercentage(Double value) {
        this.minLetterPercentage = value;
    }

    /**
     * Gets the value of the shouldTokenize property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isShouldTokenize() {
        if (shouldTokenize == null) {
            return true;
        } else {
            return shouldTokenize;
        }
    }

    /**
     * Sets the value of the shouldTokenize property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setShouldTokenize(java.lang.Boolean value) {
        this.shouldTokenize = value;
    }

    /**
     * Gets the value of the rightsFunction property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRightsFunction() {
        if (rightsFunction == null) {
            return "util-groups-for-user";
        } else {
            return rightsFunction;
        }
    }

    /**
     * Sets the value of the rightsFunction property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRightsFunction(String value) {
        this.rightsFunction = value;
    }

    /**
     * Gets the value of the internal property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInternal() {
        return internal;
    }

    /**
     * Sets the value of the internal property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInternal(String value) {
        this.internal = value;
    }

    /**
     * Gets the value of the overrides property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOverrides() {
        return overrides;
    }

    /**
     * Sets the value of the overrides property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOverrides(String value) {
        this.overrides = value;
    }

    /**
     * Gets the value of the overridesStatus property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOverridesStatus() {
        return overridesStatus;
    }

    /**
     * Sets the value of the overridesStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOverridesStatus(String value) {
        this.overridesStatus = value;
    }

    /**
     * Gets the value of the noOverride property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNoOverride() {
        return noOverride;
    }

    /**
     * Sets the value of the noOverride property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNoOverride(String value) {
        this.noOverride = value;
    }

    /**
     * Gets the value of the modified property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getModified() {
        return modified;
    }

    /**
     * Sets the value of the modified property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setModified(Integer value) {
        this.modified = value;
    }

    /**
     * Gets the value of the modifiedBy property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getModifiedBy() {
        return modifiedBy;
    }

    /**
     * Sets the value of the modifiedBy property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setModifiedBy(String value) {
        this.modifiedBy = value;
    }

    /**
     * Gets the value of the doNotDelete property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDoNotDelete() {
        return doNotDelete;
    }

    /**
     * Sets the value of the doNotDelete property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDoNotDelete(String value) {
        this.doNotDelete = value;
    }

    /**
     * Gets the value of the readOnly property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReadOnly() {
        return readOnly;
    }

    /**
     * Sets the value of the readOnly property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReadOnly(String value) {
        this.readOnly = value;
    }

    /**
     * Gets the value of the products property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the products property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getProducts().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * 
     * 
     */
    public List<String> getProducts() {
        if (products == null) {
            products = new ArrayList<String>();
        }
        return this.products;
    }

}
