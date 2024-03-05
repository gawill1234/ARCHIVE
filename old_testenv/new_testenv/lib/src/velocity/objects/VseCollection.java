
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
 *         &lt;element ref="{urn:/velocity/objects}vse-config" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-status" maxOccurs="2" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-run" maxOccurs="2" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-meta" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}repository"/>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="filebase" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="section" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="feature-version" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseConfig",
    "vseStatus",
    "vseRun",
    "vseMeta"
})
@XmlRootElement(name = "vse-collection")
public class VseCollection {

    @XmlElement(name = "vse-config")
    protected VseConfig vseConfig;
    @XmlElement(name = "vse-status")
    protected List<VseStatus> vseStatus;
    @XmlElement(name = "vse-run")
    protected List<VseRun> vseRun;
    @XmlElement(name = "vse-meta")
    protected VseMeta vseMeta;
    @XmlAttribute
    protected String name;
    @XmlAttribute(required = true)
    protected String filebase;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String section;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String id;
    @XmlAttribute(name = "feature-version")
    protected String featureVersion;
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
     * Gets the value of the vseConfig property.
     * 
     * @return
     *     possible object is
     *     {@link VseConfig }
     *     
     */
    public VseConfig getVseConfig() {
        return vseConfig;
    }

    /**
     * Sets the value of the vseConfig property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseConfig }
     *     
     */
    public void setVseConfig(VseConfig value) {
        this.vseConfig = value;
    }

    /**
     * Gets the value of the vseStatus property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseStatus property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseStatus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseStatus }
     * 
     * 
     */
    public List<VseStatus> getVseStatus() {
        if (vseStatus == null) {
            vseStatus = new ArrayList<VseStatus>();
        }
        return this.vseStatus;
    }

    /**
     * Gets the value of the vseRun property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseRun property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseRun().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseRun }
     * 
     * 
     */
    public List<VseRun> getVseRun() {
        if (vseRun == null) {
            vseRun = new ArrayList<VseRun>();
        }
        return this.vseRun;
    }

    /**
     * Gets the value of the vseMeta property.
     * 
     * @return
     *     possible object is
     *     {@link VseMeta }
     *     
     */
    public VseMeta getVseMeta() {
        return vseMeta;
    }

    /**
     * Sets the value of the vseMeta property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseMeta }
     *     
     */
    public void setVseMeta(VseMeta value) {
        this.vseMeta = value;
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
     * Gets the value of the filebase property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFilebase() {
        return filebase;
    }

    /**
     * Sets the value of the filebase property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFilebase(String value) {
        this.filebase = value;
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
     * Gets the value of the featureVersion property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFeatureVersion() {
        return featureVersion;
    }

    /**
     * Sets the value of the featureVersion property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFeatureVersion(String value) {
        this.featureVersion = value;
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
