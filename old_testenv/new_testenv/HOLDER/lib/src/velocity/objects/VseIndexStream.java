
package velocity.objects;

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
 *         &lt;element ref="{urn:/velocity/objects}vse-tokenizer"/>
 *       &lt;/sequence>
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="content-name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="arena" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="stem" type="{http://www.w3.org/2001/XMLSchema}string" default="depluralize" />
 *       &lt;attribute name="kb" type="{http://www.w3.org/2001/XMLSchema}string" default="none" />
 *       &lt;attribute name="segmenter" type="{http://www.w3.org/2001/XMLSchema}string" default="none" />
 *       &lt;attribute name="segmenter-version" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="delanguage" type="{http://www.w3.org/2001/XMLSchema}boolean" default="true" />
 *       &lt;attribute name="weight" type="{http://www.w3.org/2001/XMLSchema}double" default="1" />
 *       &lt;attribute name="wildcard-stem" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="wildcard-delanguage" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="fast-index-field" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="fast-index-base" type="{http://www.w3.org/2001/XMLSchema}int" default="10" />
 *       &lt;attribute name="fast-index-min-exponent" type="{http://www.w3.org/2001/XMLSchema}int" default="10" />
 *       &lt;attribute name="fast-index-low" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="fast-index-high" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="index-tags">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="index-tags"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="disable-wildcarding">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="disable-wildcarding"/>
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
    "vseTokenizer"
})
@XmlRootElement(name = "vse-index-stream")
public class VseIndexStream {

    @XmlElement(name = "vse-tokenizer", required = true)
    protected VseTokenizer vseTokenizer;
    @XmlAttribute
    protected Integer id;
    @XmlAttribute(name = "content-name")
    protected String contentName;
    @XmlAttribute
    protected String arena;
    @XmlAttribute
    protected String stem;
    @XmlAttribute
    protected String kb;
    @XmlAttribute
    protected String segmenter;
    @XmlAttribute(name = "segmenter-version")
    @XmlSchemaType(name = "unsignedInt")
    protected Long segmenterVersion;
    @XmlAttribute
    protected java.lang.Boolean delanguage;
    @XmlAttribute
    protected Double weight;
    @XmlAttribute(name = "wildcard-stem")
    protected String wildcardStem;
    @XmlAttribute(name = "wildcard-delanguage")
    protected java.lang.Boolean wildcardDelanguage;
    @XmlAttribute(name = "fast-index-field")
    protected Integer fastIndexField;
    @XmlAttribute(name = "fast-index-base")
    protected Integer fastIndexBase;
    @XmlAttribute(name = "fast-index-min-exponent")
    protected Integer fastIndexMinExponent;
    @XmlAttribute(name = "fast-index-low")
    protected Integer fastIndexLow;
    @XmlAttribute(name = "fast-index-high")
    protected Integer fastIndexHigh;
    @XmlAttribute(name = "index-tags")
    protected String indexTags;
    @XmlAttribute(name = "disable-wildcarding")
    protected String disableWildcarding;

    /**
     * Gets the value of the vseTokenizer property.
     * 
     * @return
     *     possible object is
     *     {@link VseTokenizer }
     *     
     */
    public VseTokenizer getVseTokenizer() {
        return vseTokenizer;
    }

    /**
     * Sets the value of the vseTokenizer property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseTokenizer }
     *     
     */
    public void setVseTokenizer(VseTokenizer value) {
        this.vseTokenizer = value;
    }

    /**
     * Gets the value of the id property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getId() {
        return id;
    }

    /**
     * Sets the value of the id property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setId(Integer value) {
        this.id = value;
    }

    /**
     * Gets the value of the contentName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getContentName() {
        return contentName;
    }

    /**
     * Sets the value of the contentName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setContentName(String value) {
        this.contentName = value;
    }

    /**
     * Gets the value of the arena property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getArena() {
        return arena;
    }

    /**
     * Sets the value of the arena property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setArena(String value) {
        this.arena = value;
    }

    /**
     * Gets the value of the stem property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStem() {
        if (stem == null) {
            return "depluralize";
        } else {
            return stem;
        }
    }

    /**
     * Sets the value of the stem property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStem(String value) {
        this.stem = value;
    }

    /**
     * Gets the value of the kb property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getKb() {
        if (kb == null) {
            return "none";
        } else {
            return kb;
        }
    }

    /**
     * Sets the value of the kb property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setKb(String value) {
        this.kb = value;
    }

    /**
     * Gets the value of the segmenter property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSegmenter() {
        if (segmenter == null) {
            return "none";
        } else {
            return segmenter;
        }
    }

    /**
     * Sets the value of the segmenter property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSegmenter(String value) {
        this.segmenter = value;
    }

    /**
     * Gets the value of the segmenterVersion property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getSegmenterVersion() {
        return segmenterVersion;
    }

    /**
     * Sets the value of the segmenterVersion property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setSegmenterVersion(Long value) {
        this.segmenterVersion = value;
    }

    /**
     * Gets the value of the delanguage property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isDelanguage() {
        if (delanguage == null) {
            return true;
        } else {
            return delanguage;
        }
    }

    /**
     * Sets the value of the delanguage property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setDelanguage(java.lang.Boolean value) {
        this.delanguage = value;
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
     * Gets the value of the wildcardStem property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getWildcardStem() {
        return wildcardStem;
    }

    /**
     * Sets the value of the wildcardStem property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setWildcardStem(String value) {
        this.wildcardStem = value;
    }

    /**
     * Gets the value of the wildcardDelanguage property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isWildcardDelanguage() {
        return wildcardDelanguage;
    }

    /**
     * Sets the value of the wildcardDelanguage property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setWildcardDelanguage(java.lang.Boolean value) {
        this.wildcardDelanguage = value;
    }

    /**
     * Gets the value of the fastIndexField property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getFastIndexField() {
        return fastIndexField;
    }

    /**
     * Sets the value of the fastIndexField property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setFastIndexField(Integer value) {
        this.fastIndexField = value;
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
     * Gets the value of the fastIndexLow property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getFastIndexLow() {
        return fastIndexLow;
    }

    /**
     * Sets the value of the fastIndexLow property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setFastIndexLow(Integer value) {
        this.fastIndexLow = value;
    }

    /**
     * Gets the value of the fastIndexHigh property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getFastIndexHigh() {
        return fastIndexHigh;
    }

    /**
     * Sets the value of the fastIndexHigh property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setFastIndexHigh(Integer value) {
        this.fastIndexHigh = value;
    }

    /**
     * Gets the value of the indexTags property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIndexTags() {
        return indexTags;
    }

    /**
     * Sets the value of the indexTags property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIndexTags(String value) {
        this.indexTags = value;
    }

    /**
     * Gets the value of the disableWildcarding property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisableWildcarding() {
        return disableWildcarding;
    }

    /**
     * Sets the value of the disableWildcarding property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisableWildcarding(String value) {
        this.disableWildcarding = value;
    }

}
