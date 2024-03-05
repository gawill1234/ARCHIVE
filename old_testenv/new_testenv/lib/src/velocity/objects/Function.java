
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlElementRefs;
import javax.xml.bind.annotation.XmlMixed;
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
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}prototype"/>
 *         &lt;element ref="{urn:/velocity/objects}settings"/>
 *       &lt;/choice>
 *       &lt;attGroup ref="{urn:/velocity/objects}function-search-engine"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}function-interface"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}repository"/>
 *       &lt;attribute name="type">
 *         &lt;simpleType>
 *           &lt;union memberTypes=" {http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;simpleType>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *                 &lt;enumeration value="browser-script"/>
 *                 &lt;enumeration value="browser-script-component"/>
 *                 &lt;enumeration value="alert"/>
 *                 &lt;enumeration value="form"/>
 *                 &lt;enumeration value="parser"/>
 *                 &lt;enumeration value="login"/>
 *                 &lt;enumeration value="logout"/>
 *                 &lt;enumeration value="test"/>
 *                 &lt;enumeration value="script-component"/>
 *                 &lt;enumeration value="dict-input"/>
 *                 &lt;enumeration value="dict-output"/>
 *                 &lt;enumeration value="crawl-seed"/>
 *                 &lt;enumeration value="index-stream"/>
 *                 &lt;enumeration value="crawl-option"/>
 *                 &lt;enumeration value="crawl-condition"/>
 *                 &lt;enumeration value="crawl-condition-remote"/>
 *                 &lt;enumeration value="converter"/>
 *                 &lt;enumeration value="converters"/>
 *                 &lt;enumeration value="key-match-entry"/>
 *                 &lt;enumeration value="render-xsl"/>
 *                 &lt;enumeration value="render-master-xsl"/>
 *                 &lt;enumeration value="display"/>
 *                 &lt;enumeration value="display-module"/>
 *                 &lt;enumeration value="display-module-internal"/>
 *                 &lt;enumeration value="report-item"/>
 *                 &lt;enumeration value="report-item-component"/>
 *                 &lt;enumeration value="scheduler-command"/>
 *                 &lt;enumeration value="scheduler-condition"/>
 *                 &lt;enumeration value="binning-set"/>
 *                 &lt;enumeration value="binning-range"/>
 *                 &lt;enumeration value="binning-tree"/>
 *                 &lt;enumeration value="binning-calculation"/>
 *                 &lt;enumeration value="binning-component"/>
 *                 &lt;enumeration value="public-api"/>
 *                 &lt;enumeration value="internal-api"/>
 *               &lt;/restriction>
 *             &lt;/simpleType>
 *           &lt;/union>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="sub-type" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="hide-in-list" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="section" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="render-type">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="report-export"/>
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
@XmlRootElement(name = "function")
public class Function {

    @XmlElementRefs({
        @XmlElementRef(name = "settings", namespace = "urn:/velocity/objects", type = Settings.class),
        @XmlElementRef(name = "prototype", namespace = "urn:/velocity/objects", type = Prototype.class)
    })
    @XmlMixed
    protected List<Object> content;
    @XmlAttribute
    protected String type;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String name;
    @XmlAttribute(name = "sub-type")
    @XmlSchemaType(name = "anySimpleType")
    protected String subType;
    @XmlAttribute(name = "hide-in-list")
    @XmlSchemaType(name = "anySimpleType")
    protected String hideInList;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String section;
    @XmlAttribute(name = "render-type")
    protected String renderType;
    @XmlAttribute(name = "type-in")
    protected String typeIn;
    @XmlAttribute(name = "type-out")
    protected String typeOut;
    @XmlAttribute
    protected String fork;
    @XmlAttribute(name = "render-master-xsl")
    @XmlSchemaType(name = "anySimpleType")
    protected String renderMasterXsl;
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
     * Gets the value of the content property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the content property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getContent().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * {@link Prototype }
     * {@link Settings }
     * 
     * 
     */
    public List<Object> getContent() {
        if (content == null) {
            content = new ArrayList<Object>();
        }
        return this.content;
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
     * Gets the value of the subType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSubType() {
        return subType;
    }

    /**
     * Sets the value of the subType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSubType(String value) {
        this.subType = value;
    }

    /**
     * Gets the value of the hideInList property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHideInList() {
        return hideInList;
    }

    /**
     * Sets the value of the hideInList property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHideInList(String value) {
        this.hideInList = value;
    }

    /**
     * Gets the value of the section property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSection() {
        return section;
    }

    /**
     * Sets the value of the section property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSection(String value) {
        this.section = value;
    }

    /**
     * Gets the value of the renderType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRenderType() {
        return renderType;
    }

    /**
     * Sets the value of the renderType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRenderType(String value) {
        this.renderType = value;
    }

    /**
     * Gets the value of the typeIn property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTypeIn() {
        return typeIn;
    }

    /**
     * Sets the value of the typeIn property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTypeIn(String value) {
        this.typeIn = value;
    }

    /**
     * Gets the value of the typeOut property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTypeOut() {
        return typeOut;
    }

    /**
     * Sets the value of the typeOut property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTypeOut(String value) {
        this.typeOut = value;
    }

    /**
     * Gets the value of the fork property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFork() {
        return fork;
    }

    /**
     * Sets the value of the fork property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFork(String value) {
        this.fork = value;
    }

    /**
     * Gets the value of the renderMasterXsl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRenderMasterXsl() {
        return renderMasterXsl;
    }

    /**
     * Sets the value of the renderMasterXsl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRenderMasterXsl(String value) {
        this.renderMasterXsl = value;
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
