
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
 *         &lt;element ref="{urn:/velocity/objects}prototype" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}add-sources" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}submit" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}tests" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}help" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}description" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}parser" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}source-interface"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}source"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}repository"/>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="logo" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="status">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="ignore"/>
 *             &lt;enumeration value="disabled"/>
 *             &lt;enumeration value="broken"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="template">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="template"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="display-name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="source-type" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "prototype",
    "addSources",
    "submit",
    "tests",
    "help",
    "description",
    "parser"
})
@XmlRootElement(name = "source")
public class Source {

    protected Prototype prototype;
    @XmlElement(name = "add-sources")
    protected AddSources addSources;
    protected Submit submit;
    protected Tests tests;
    protected Object help;
    protected Description description;
    protected List<Parser> parser;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String name;
    @XmlAttribute
    protected String logo;
    @XmlAttribute
    protected String status;
    @XmlAttribute
    protected String template;
    @XmlAttribute(name = "display-name")
    protected String displayName;
    @XmlAttribute(name = "source-type")
    protected String sourceType;
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
    protected String type;
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
     * Gets the value of the prototype property.
     * 
     * @return
     *     possible object is
     *     {@link Prototype }
     *     
     */
    public Prototype getPrototype() {
        return prototype;
    }

    /**
     * Sets the value of the prototype property.
     * 
     * @param value
     *     allowed object is
     *     {@link Prototype }
     *     
     */
    public void setPrototype(Prototype value) {
        this.prototype = value;
    }

    /**
     * Gets the value of the addSources property.
     * 
     * @return
     *     possible object is
     *     {@link AddSources }
     *     
     */
    public AddSources getAddSources() {
        return addSources;
    }

    /**
     * Sets the value of the addSources property.
     * 
     * @param value
     *     allowed object is
     *     {@link AddSources }
     *     
     */
    public void setAddSources(AddSources value) {
        this.addSources = value;
    }

    /**
     * Gets the value of the submit property.
     * 
     * @return
     *     possible object is
     *     {@link Submit }
     *     
     */
    public Submit getSubmit() {
        return submit;
    }

    /**
     * Sets the value of the submit property.
     * 
     * @param value
     *     allowed object is
     *     {@link Submit }
     *     
     */
    public void setSubmit(Submit value) {
        this.submit = value;
    }

    /**
     * Gets the value of the tests property.
     * 
     * @return
     *     possible object is
     *     {@link Tests }
     *     
     */
    public Tests getTests() {
        return tests;
    }

    /**
     * Sets the value of the tests property.
     * 
     * @param value
     *     allowed object is
     *     {@link Tests }
     *     
     */
    public void setTests(Tests value) {
        this.tests = value;
    }

    /**
     * Gets the value of the help property.
     * 
     * @return
     *     possible object is
     *     {@link Object }
     *     
     */
    public Object getHelp() {
        return help;
    }

    /**
     * Sets the value of the help property.
     * 
     * @param value
     *     allowed object is
     *     {@link Object }
     *     
     */
    public void setHelp(Object value) {
        this.help = value;
    }

    /**
     * Gets the value of the description property.
     * 
     * @return
     *     possible object is
     *     {@link Description }
     *     
     */
    public Description getDescription() {
        return description;
    }

    /**
     * Sets the value of the description property.
     * 
     * @param value
     *     allowed object is
     *     {@link Description }
     *     
     */
    public void setDescription(Description value) {
        this.description = value;
    }

    /**
     * Gets the value of the parser property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the parser property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getParser().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Parser }
     * 
     * 
     */
    public List<Parser> getParser() {
        if (parser == null) {
            parser = new ArrayList<Parser>();
        }
        return this.parser;
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
     * Gets the value of the template property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTemplate() {
        return template;
    }

    /**
     * Sets the value of the template property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTemplate(String value) {
        this.template = value;
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
     * Gets the value of the type property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getType() {
        return type;
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
