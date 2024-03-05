
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
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
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;element name="option">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *                 &lt;attribute name="value" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                 &lt;attribute name="field-value" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                 &lt;attribute name="logic" type="{urn:/velocity/objects}logic" />
 *                 &lt;attribute name="field" type="{urn:/velocity/objects}field" />
 *                 &lt;attribute name="delimiters" type="{urn:/velocity/objects}delimiters" />
 *                 &lt;attribute name="term-logic" type="{urn:/velocity/objects}logic" />
 *                 &lt;attribute name="next-only">
 *                   &lt;simpleType>
 *                     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *                       &lt;enumeration value="next-only"/>
 *                     &lt;/restriction>
 *                   &lt;/simpleType>
 *                 &lt;/attribute>
 *                 &lt;attribute name="position" type="{http://www.w3.org/2001/XMLSchema}int" />
 *                 &lt;attribute name="method" type="{urn:/velocity/objects}method" />
 *                 &lt;attribute name="selected">
 *                   &lt;simpleType>
 *                     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *                       &lt;enumeration value="selected"/>
 *                     &lt;/restriction>
 *                   &lt;/simpleType>
 *                 &lt;/attribute>
 *                 &lt;attribute name="processing" type="{urn:/velocity/objects}processing" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/choice>
 *       &lt;attGroup ref="{urn:/velocity/objects}select-interface"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="multiple">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="multiple"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="check-value">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="check-value"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="field" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="logic" type="{http://www.w3.org/2001/XMLSchema}string" default="or" />
 *       &lt;attribute name="apply-to" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="next-only">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="next-only"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="position" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="priority" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="method" type="{urn:/velocity/objects}method" />
 *       &lt;attribute name="type">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="radio"/>
 *             &lt;enumeration value="checkbox"/>
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
    "option"
})
@XmlRootElement(name = "select")
public class Select {

    protected List<Select.Option> option;
    @XmlAttribute
    protected String name;
    @XmlAttribute
    protected String multiple;
    @XmlAttribute(name = "check-value")
    protected String checkValue;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String field;
    @XmlAttribute
    protected String logic;
    @XmlAttribute(name = "apply-to")
    protected String applyTo;
    @XmlAttribute(name = "next-only")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String nextOnly;
    @XmlAttribute
    protected Integer position;
    @XmlAttribute
    protected Integer priority;
    @XmlAttribute
    protected Method method;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String type;
    @XmlAttribute(name = "display-name")
    protected String displayName;
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

    /**
     * Gets the value of the option property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the option property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getOption().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Select.Option }
     * 
     * 
     */
    public List<Select.Option> getOption() {
        if (option == null) {
            option = new ArrayList<Select.Option>();
        }
        return this.option;
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
     * Gets the value of the multiple property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMultiple() {
        return multiple;
    }

    /**
     * Sets the value of the multiple property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMultiple(String value) {
        this.multiple = value;
    }

    /**
     * Gets the value of the checkValue property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCheckValue() {
        return checkValue;
    }

    /**
     * Sets the value of the checkValue property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCheckValue(String value) {
        this.checkValue = value;
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
     * Gets the value of the logic property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLogic() {
        if (logic == null) {
            return "or";
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
     * Gets the value of the applyTo property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getApplyTo() {
        return applyTo;
    }

    /**
     * Sets the value of the applyTo property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setApplyTo(String value) {
        this.applyTo = value;
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
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
     *       &lt;attribute name="value" type="{http://www.w3.org/2001/XMLSchema}string" />
     *       &lt;attribute name="field-value" type="{http://www.w3.org/2001/XMLSchema}string" />
     *       &lt;attribute name="logic" type="{urn:/velocity/objects}logic" />
     *       &lt;attribute name="field" type="{urn:/velocity/objects}field" />
     *       &lt;attribute name="delimiters" type="{urn:/velocity/objects}delimiters" />
     *       &lt;attribute name="term-logic" type="{urn:/velocity/objects}logic" />
     *       &lt;attribute name="next-only">
     *         &lt;simpleType>
     *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
     *             &lt;enumeration value="next-only"/>
     *           &lt;/restriction>
     *         &lt;/simpleType>
     *       &lt;/attribute>
     *       &lt;attribute name="position" type="{http://www.w3.org/2001/XMLSchema}int" />
     *       &lt;attribute name="method" type="{urn:/velocity/objects}method" />
     *       &lt;attribute name="selected">
     *         &lt;simpleType>
     *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
     *             &lt;enumeration value="selected"/>
     *           &lt;/restriction>
     *         &lt;/simpleType>
     *       &lt;/attribute>
     *       &lt;attribute name="processing" type="{urn:/velocity/objects}processing" />
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
    public static class Option {

        @XmlValue
        protected String content;
        @XmlAttribute
        protected String value;
        @XmlAttribute(name = "field-value")
        protected String fieldValue;
        @XmlAttribute
        protected String logic;
        @XmlAttribute
        protected String field;
        @XmlAttribute
        protected String delimiters;
        @XmlAttribute(name = "term-logic")
        protected String termLogic;
        @XmlAttribute(name = "next-only")
        @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
        protected String nextOnly;
        @XmlAttribute
        protected Integer position;
        @XmlAttribute
        protected Method method;
        @XmlAttribute
        protected String selected;
        @XmlAttribute
        protected Processing processing;
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
         * Gets the value of the logic property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getLogic() {
            return logic;
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
         * Gets the value of the delimiters property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getDelimiters() {
            return delimiters;
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
         * Gets the value of the selected property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getSelected() {
            return selected;
        }

        /**
         * Sets the value of the selected property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setSelected(String value) {
            this.selected = value;
        }

        /**
         * Gets the value of the processing property.
         * 
         * @return
         *     possible object is
         *     {@link Processing }
         *     
         */
        public Processing getProcessing() {
            return processing;
        }

        /**
         * Sets the value of the processing property.
         * 
         * @param value
         *     allowed object is
         *     {@link Processing }
         *     
         */
        public void setProcessing(Processing value) {
            this.processing = value;
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

    }

}
