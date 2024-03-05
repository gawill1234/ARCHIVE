
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *         &lt;element ref="{urn:/velocity/objects}operator"/>
 *       &lt;/choice>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}input-interface"/>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="value" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="xpath-value" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="field" type="{urn:/velocity/objects}field" />
 *       &lt;attribute name="field-value" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="syntax" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="offset" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="next-only">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="next-only"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="min" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="max" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="max-instances" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="logic" type="{http://www.w3.org/2001/XMLSchema}string" default="and" />
 *       &lt;attribute name="term-logic" type="{urn:/velocity/objects}logic" />
 *       &lt;attribute name="delimiters" type="{http://www.w3.org/2001/XMLSchema}string" default=" 
 * 	　" />
 *       &lt;attribute name="word-chars" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="disable-auto-quotes">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="disable-auto-quotes"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="position" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="priority" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="method" type="{urn:/velocity/objects}method" />
 *       &lt;attribute name="submit-xml">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="submit-xml"/>
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
 *       &lt;attribute name="type">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="hidden"/>
 *             &lt;enumeration value="textarea"/>
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
    "operator"
})
@XmlRootElement(name = "input")
public class Input {

    protected List<Operator> operator;
    @XmlAttribute
    protected String name;
    @XmlAttribute
    protected String value;
    @XmlAttribute(name = "xpath-value")
    protected String xpathValue;
    @XmlAttribute
    protected String field;
    @XmlAttribute(name = "field-value")
    protected String fieldValue;
    @XmlAttribute
    protected String syntax;
    @XmlAttribute
    protected Integer offset;
    @XmlAttribute(name = "next-only")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String nextOnly;
    @XmlAttribute
    protected Integer min;
    @XmlAttribute
    protected Integer max;
    @XmlAttribute(name = "max-instances")
    protected Integer maxInstances;
    @XmlAttribute
    protected String logic;
    @XmlAttribute(name = "term-logic")
    protected String termLogic;
    @XmlAttribute
    protected String delimiters;
    @XmlAttribute(name = "word-chars")
    protected String wordChars;
    @XmlAttribute(name = "disable-auto-quotes")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String disableAutoQuotes;
    @XmlAttribute
    protected Integer position;
    @XmlAttribute
    protected Integer priority;
    @XmlAttribute
    protected Method method;
    @XmlAttribute(name = "submit-xml")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String submitXml;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String required;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String type;
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
    @XmlSchemaType(name = "anySimpleType")
    protected String size;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String cols;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String rows;
    @XmlAttribute(name = "remove-from-new-query")
    @XmlSchemaType(name = "anySimpleType")
    protected String removeFromNewQuery;
    @XmlAttribute(name = "display-name")
    @XmlSchemaType(name = "anySimpleType")
    protected String displayName;

    /**
     * Gets the value of the operator property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the operator property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getOperator().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Operator }
     * 
     * 
     */
    public List<Operator> getOperator() {
        if (operator == null) {
            operator = new ArrayList<Operator>();
        }
        return this.operator;
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
     * Gets the value of the xpathValue property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getXpathValue() {
        return xpathValue;
    }

    /**
     * Sets the value of the xpathValue property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setXpathValue(String value) {
        this.xpathValue = value;
    }

    /**
     * Gets the value of the field property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getField() {
        return field;
    }

    /**
     * Sets the value of the field property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setField(String value) {
        this.field = value;
    }

    /**
     * Gets the value of the fieldValue property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFieldValue() {
        return fieldValue;
    }

    /**
     * Sets the value of the fieldValue property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFieldValue(String value) {
        this.fieldValue = value;
    }

    /**
     * Gets the value of the syntax property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSyntax() {
        return syntax;
    }

    /**
     * Sets the value of the syntax property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSyntax(String value) {
        this.syntax = value;
    }

    /**
     * Gets the value of the offset property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getOffset() {
        return offset;
    }

    /**
     * Sets the value of the offset property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setOffset(Integer value) {
        this.offset = value;
    }

    /**
     * Gets the value of the nextOnly property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNextOnly() {
        return nextOnly;
    }

    /**
     * Sets the value of the nextOnly property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNextOnly(String value) {
        this.nextOnly = value;
    }

    /**
     * Gets the value of the min property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMin() {
        return min;
    }

    /**
     * Sets the value of the min property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMin(Integer value) {
        this.min = value;
    }

    /**
     * Gets the value of the max property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMax() {
        return max;
    }

    /**
     * Sets the value of the max property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMax(Integer value) {
        this.max = value;
    }

    /**
     * Gets the value of the maxInstances property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxInstances() {
        return maxInstances;
    }

    /**
     * Sets the value of the maxInstances property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxInstances(Integer value) {
        this.maxInstances = value;
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

    /**
     * Gets the value of the termLogic property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTermLogic() {
        return termLogic;
    }

    /**
     * Sets the value of the termLogic property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTermLogic(String value) {
        this.termLogic = value;
    }

    /**
     * Gets the value of the delimiters property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDelimiters() {
        if (delimiters == null) {
            return " \n\r\t\u3000";
        } else {
            return delimiters;
        }
    }

    /**
     * Sets the value of the delimiters property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDelimiters(String value) {
        this.delimiters = value;
    }

    /**
     * Gets the value of the wordChars property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getWordChars() {
        return wordChars;
    }

    /**
     * Sets the value of the wordChars property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setWordChars(String value) {
        this.wordChars = value;
    }

    /**
     * Gets the value of the disableAutoQuotes property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisableAutoQuotes() {
        return disableAutoQuotes;
    }

    /**
     * Sets the value of the disableAutoQuotes property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisableAutoQuotes(String value) {
        this.disableAutoQuotes = value;
    }

    /**
     * Gets the value of the position property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getPosition() {
        return position;
    }

    /**
     * Sets the value of the position property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPosition(Integer value) {
        this.position = value;
    }

    /**
     * Gets the value of the priority property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getPriority() {
        if (priority == null) {
            return  0;
        } else {
            return priority;
        }
    }

    /**
     * Sets the value of the priority property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPriority(Integer value) {
        this.priority = value;
    }

    /**
     * Gets the value of the method property.
     * 
     * @return
     *     possible object is
     *     {@link Method }
     *     
     */
    public Method getMethod() {
        return method;
    }

    /**
     * Sets the value of the method property.
     * 
     * @param value
     *     allowed object is
     *     {@link Method }
     *     
     */
    public void setMethod(Method value) {
        this.method = value;
    }

    /**
     * Gets the value of the submitXml property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSubmitXml() {
        return submitXml;
    }

    /**
     * Sets the value of the submitXml property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSubmitXml(String value) {
        this.submitXml = value;
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
     * Gets the value of the size property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSize() {
        return size;
    }

    /**
     * Sets the value of the size property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSize(String value) {
        this.size = value;
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
     * Gets the value of the removeFromNewQuery property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoveFromNewQuery() {
        return removeFromNewQuery;
    }

    /**
     * Sets the value of the removeFromNewQuery property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoveFromNewQuery(String value) {
        this.removeFromNewQuery = value;
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

}
