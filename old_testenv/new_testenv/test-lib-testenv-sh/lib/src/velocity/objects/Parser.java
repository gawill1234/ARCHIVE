
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
 *       &lt;choice>
 *         &lt;element ref="{urn:/velocity/objects}scope"/>
 *         &lt;choice maxOccurs="unbounded" minOccurs="0">
 *           &lt;element ref="{urn:/velocity/objects}match"/>
 *           &lt;element ref="{urn:/velocity/objects}state"/>
 *           &lt;element ref="{urn:/velocity/objects}add-content"/>
 *         &lt;/choice>
 *       &lt;/choice>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}repository"/>
 *       &lt;attribute name="url" type="{http://www.w3.org/2001/XMLSchema}anyURI" />
 *       &lt;attribute name="name" type="{urn:/velocity/objects}nmtoken-or-anonymous" />
 *       &lt;attribute name="type" default="regex">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="regex"/>
 *             &lt;enumeration value="regex-text"/>
 *             &lt;enumeration value="case-insensitive-regex"/>
 *             &lt;enumeration value="case-insensitive-regex-text"/>
 *             &lt;enumeration value="perl-regex"/>
 *             &lt;enumeration value="perl-regex-text"/>
 *             &lt;enumeration value="case-insensitive-perl-regex"/>
 *             &lt;enumeration value="case-insensitive-perl-regex-text"/>
 *             &lt;enumeration value="xsl"/>
 *             &lt;enumeration value="html-xsl"/>
 *             &lt;enumeration value="java"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="java-classname" type="{http://www.w3.org/2001/XMLSchema}string" />
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
@XmlRootElement(name = "parser")
public class Parser {

    @XmlElementRefs({
        @XmlElementRef(name = "state", namespace = "urn:/velocity/objects", type = State.class),
        @XmlElementRef(name = "match", namespace = "urn:/velocity/objects", type = Match.class),
        @XmlElementRef(name = "scope", namespace = "urn:/velocity/objects", type = Scope.class),
        @XmlElementRef(name = "add-content", namespace = "urn:/velocity/objects", type = AddContent.class)
    })
    @XmlMixed
    protected List<Object> content;
    @XmlAttribute
    @XmlSchemaType(name = "anyURI")
    protected String url;
    @XmlAttribute
    protected String name;
    @XmlAttribute
    protected String type;
    @XmlAttribute(name = "java-classname")
    protected String javaClassname;
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
     * {@link Scope }
     * {@link AddContent }
     * {@link State }
     * {@link Match }
     * {@link String }
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
     * Gets the value of the url property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrl() {
        return url;
    }

    /**
     * Sets the value of the url property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrl(String value) {
        this.url = value;
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
            return "regex";
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
     * Gets the value of the javaClassname property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getJavaClassname() {
        return javaClassname;
    }

    /**
     * Sets the value of the javaClassname property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setJavaClassname(String value) {
        this.javaClassname = value;
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
