
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
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
 *         &lt;element ref="{urn:/velocity/objects}enum-values"/>
 *         &lt;element ref="{urn:/velocity/objects}value"/>
 *         &lt;element ref="{urn:/velocity/objects}label"/>
 *         &lt;element ref="{urn:/velocity/objects}description"/>
 *       &lt;/choice>
 *       &lt;attGroup ref="{urn:/velocity/objects}declare-interface"/>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="tab" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="group" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="type" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="instance-title" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="hidden">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="hidden"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="required">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="required"/>
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
    "enumValuesOrValueOrLabel"
})
@XmlRootElement(name = "declare-setting")
public class DeclareSetting {

    @XmlElements({
        @XmlElement(name = "description", type = Description.class),
        @XmlElement(name = "enum-values", type = EnumValues.class),
        @XmlElement(name = "value", type = Value.class),
        @XmlElement(name = "label", type = Label.class)
    })
    protected List<Object> enumValuesOrValueOrLabel;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String name;
    @XmlAttribute
    protected String tab;
    @XmlAttribute
    protected String group;
    @XmlAttribute
    protected String type;
    @XmlAttribute(name = "instance-title")
    protected String instanceTitle;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String hidden;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String required;
    @XmlAttribute(name = "ac-multi")
    @XmlSchemaType(name = "anySimpleType")
    protected String acMulti;
    @XmlAttribute(name = "ac-xpath")
    @XmlSchemaType(name = "anySimpleType")
    protected String acXpath;
    @XmlAttribute(name = "allow-xml")
    @XmlSchemaType(name = "anySimpleType")
    protected String allowXml;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String cols;
    @XmlAttribute(name = "date-end-of-day")
    @XmlSchemaType(name = "anySimpleType")
    protected String dateEndOfDay;
    @XmlAttribute(name = "date-start-of-day")
    @XmlSchemaType(name = "anySimpleType")
    protected String dateStartOfDay;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String deprecated;
    @XmlAttribute(name = "do-not-delete")
    @XmlSchemaType(name = "anySimpleType")
    protected String doNotDelete;
    @XmlAttribute(name = "enum-separator")
    @XmlSchemaType(name = "anySimpleType")
    protected String enumSeparator;
    @XmlAttribute(name = "enum-sources")
    @XmlSchemaType(name = "anySimpleType")
    protected String enumSources;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String hide;
    @XmlAttribute(name = "hide-default")
    @XmlSchemaType(name = "anySimpleType")
    protected String hideDefault;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String hierarchical;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String label;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String min;
    @XmlAttribute(name = "no-label")
    @XmlSchemaType(name = "anySimpleType")
    protected String noLabel;
    @XmlAttribute(name = "other-size")
    @XmlSchemaType(name = "anySimpleType")
    protected String otherSize;
    @XmlAttribute(name = "other-value")
    @XmlSchemaType(name = "anySimpleType")
    protected String otherValue;
    @XmlAttribute(name = "read-only")
    @XmlSchemaType(name = "anySimpleType")
    protected String readOnly;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String rows;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String section;
    @XmlAttribute(name = "show-time")
    @XmlSchemaType(name = "anySimpleType")
    protected String showTime;
    @XmlAttribute(name = "silently-required")
    @XmlSchemaType(name = "anySimpleType")
    protected String silentlyRequired;
    @XmlAttribute(name = "toggle-boring")
    @XmlSchemaType(name = "anySimpleType")
    protected String toggleBoring;
    @XmlAttribute(name = "toggle-default")
    @XmlSchemaType(name = "anySimpleType")
    protected String toggleDefault;
    @XmlAttribute(name = "two-rows")
    @XmlSchemaType(name = "anySimpleType")
    protected String twoRows;
    @XmlAttribute(name = "type-separator")
    @XmlSchemaType(name = "anySimpleType")
    protected String typeSeparator;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String units;
    @XmlAttribute(name = "user-set-permission")
    @XmlSchemaType(name = "anySimpleType")
    protected String userSetPermission;
    @XmlAttribute(name = "values-node")
    @XmlSchemaType(name = "anySimpleType")
    protected String valuesNode;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String wrap;

    /**
     * Gets the value of the enumValuesOrValueOrLabel property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the enumValuesOrValueOrLabel property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getEnumValuesOrValueOrLabel().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Description }
     * {@link EnumValues }
     * {@link Value }
     * {@link Label }
     * 
     * 
     */
    public List<Object> getEnumValuesOrValueOrLabel() {
        if (enumValuesOrValueOrLabel == null) {
            enumValuesOrValueOrLabel = new ArrayList<Object>();
        }
        return this.enumValuesOrValueOrLabel;
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
     * Gets the value of the tab property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTab() {
        return tab;
    }

    /**
     * Sets the value of the tab property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTab(String value) {
        this.tab = value;
    }

    /**
     * Gets the value of the group property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGroup() {
        return group;
    }

    /**
     * Sets the value of the group property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGroup(String value) {
        this.group = value;
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
     * Gets the value of the instanceTitle property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInstanceTitle() {
        return instanceTitle;
    }

    /**
     * Sets the value of the instanceTitle property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInstanceTitle(String value) {
        this.instanceTitle = value;
    }

    /**
     * Gets the value of the hidden property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHidden() {
        return hidden;
    }

    /**
     * Sets the value of the hidden property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHidden(String value) {
        this.hidden = value;
    }

    /**
     * Gets the value of the required property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRequired() {
        return required;
    }

    /**
     * Sets the value of the required property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRequired(String value) {
        this.required = value;
    }

    /**
     * Gets the value of the acMulti property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAcMulti() {
        return acMulti;
    }

    /**
     * Sets the value of the acMulti property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAcMulti(String value) {
        this.acMulti = value;
    }

    /**
     * Gets the value of the acXpath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAcXpath() {
        return acXpath;
    }

    /**
     * Sets the value of the acXpath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAcXpath(String value) {
        this.acXpath = value;
    }

    /**
     * Gets the value of the allowXml property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAllowXml() {
        return allowXml;
    }

    /**
     * Sets the value of the allowXml property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAllowXml(String value) {
        this.allowXml = value;
    }

    /**
     * Gets the value of the cols property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCols() {
        return cols;
    }

    /**
     * Sets the value of the cols property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCols(String value) {
        this.cols = value;
    }

    /**
     * Gets the value of the dateEndOfDay property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDateEndOfDay() {
        return dateEndOfDay;
    }

    /**
     * Sets the value of the dateEndOfDay property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDateEndOfDay(String value) {
        this.dateEndOfDay = value;
    }

    /**
     * Gets the value of the dateStartOfDay property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDateStartOfDay() {
        return dateStartOfDay;
    }

    /**
     * Sets the value of the dateStartOfDay property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDateStartOfDay(String value) {
        this.dateStartOfDay = value;
    }

    /**
     * Gets the value of the deprecated property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDeprecated() {
        return deprecated;
    }

    /**
     * Sets the value of the deprecated property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDeprecated(String value) {
        this.deprecated = value;
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
     * Gets the value of the enumSeparator property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnumSeparator() {
        return enumSeparator;
    }

    /**
     * Sets the value of the enumSeparator property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnumSeparator(String value) {
        this.enumSeparator = value;
    }

    /**
     * Gets the value of the enumSources property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnumSources() {
        return enumSources;
    }

    /**
     * Sets the value of the enumSources property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnumSources(String value) {
        this.enumSources = value;
    }

    /**
     * Gets the value of the hide property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHide() {
        return hide;
    }

    /**
     * Sets the value of the hide property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHide(String value) {
        this.hide = value;
    }

    /**
     * Gets the value of the hideDefault property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHideDefault() {
        return hideDefault;
    }

    /**
     * Sets the value of the hideDefault property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHideDefault(String value) {
        this.hideDefault = value;
    }

    /**
     * Gets the value of the hierarchical property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHierarchical() {
        return hierarchical;
    }

    /**
     * Sets the value of the hierarchical property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHierarchical(String value) {
        this.hierarchical = value;
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
     * Gets the value of the min property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMin() {
        return min;
    }

    /**
     * Sets the value of the min property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMin(String value) {
        this.min = value;
    }

    /**
     * Gets the value of the noLabel property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNoLabel() {
        return noLabel;
    }

    /**
     * Sets the value of the noLabel property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNoLabel(String value) {
        this.noLabel = value;
    }

    /**
     * Gets the value of the otherSize property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOtherSize() {
        return otherSize;
    }

    /**
     * Sets the value of the otherSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOtherSize(String value) {
        this.otherSize = value;
    }

    /**
     * Gets the value of the otherValue property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOtherValue() {
        return otherValue;
    }

    /**
     * Sets the value of the otherValue property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOtherValue(String value) {
        this.otherValue = value;
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
     * Gets the value of the rows property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRows() {
        return rows;
    }

    /**
     * Sets the value of the rows property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRows(String value) {
        this.rows = value;
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
     * Gets the value of the showTime property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getShowTime() {
        return showTime;
    }

    /**
     * Sets the value of the showTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setShowTime(String value) {
        this.showTime = value;
    }

    /**
     * Gets the value of the silentlyRequired property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSilentlyRequired() {
        return silentlyRequired;
    }

    /**
     * Sets the value of the silentlyRequired property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSilentlyRequired(String value) {
        this.silentlyRequired = value;
    }

    /**
     * Gets the value of the toggleBoring property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getToggleBoring() {
        return toggleBoring;
    }

    /**
     * Sets the value of the toggleBoring property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setToggleBoring(String value) {
        this.toggleBoring = value;
    }

    /**
     * Gets the value of the toggleDefault property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getToggleDefault() {
        return toggleDefault;
    }

    /**
     * Sets the value of the toggleDefault property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setToggleDefault(String value) {
        this.toggleDefault = value;
    }

    /**
     * Gets the value of the twoRows property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTwoRows() {
        return twoRows;
    }

    /**
     * Sets the value of the twoRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTwoRows(String value) {
        this.twoRows = value;
    }

    /**
     * Gets the value of the typeSeparator property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTypeSeparator() {
        return typeSeparator;
    }

    /**
     * Sets the value of the typeSeparator property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTypeSeparator(String value) {
        this.typeSeparator = value;
    }

    /**
     * Gets the value of the units property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUnits() {
        return units;
    }

    /**
     * Sets the value of the units property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUnits(String value) {
        this.units = value;
    }

    /**
     * Gets the value of the userSetPermission property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUserSetPermission() {
        return userSetPermission;
    }

    /**
     * Sets the value of the userSetPermission property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUserSetPermission(String value) {
        this.userSetPermission = value;
    }

    /**
     * Gets the value of the valuesNode property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getValuesNode() {
        return valuesNode;
    }

    /**
     * Sets the value of the valuesNode property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setValuesNode(String value) {
        this.valuesNode = value;
    }

    /**
     * Gets the value of the wrap property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getWrap() {
        return wrap;
    }

    /**
     * Sets the value of the wrap property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setWrap(String value) {
        this.wrap = value;
    }

}
