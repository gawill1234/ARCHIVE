
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
 *         &lt;element ref="{urn:/velocity/objects}term"/>
 *         &lt;element ref="{urn:/velocity/objects}label"/>
 *         &lt;element ref="{urn:/velocity/objects}description"/>
 *       &lt;/choice>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="start-string" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="end-string" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="middle-string" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="char" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="precedence" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="distribute">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="distribute"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="logic" type="{urn:/velocity/objects}logic" />
 *       &lt;attribute name="field" type="{urn:/velocity/objects}field" />
 *       &lt;attribute name="disallow-operators" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="expand-str" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="expand-logic">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="stem"/>
 *             &lt;enumeration value="wildcard"/>
 *             &lt;enumeration value="regex"/>
 *             &lt;enumeration value="spelling"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="expand-type">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="error"/>
 *             &lt;enumeration value="too-short"/>
 *             &lt;enumeration value="nomatch"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="expand-count" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "operatorOrTermOrLabel"
})
@XmlRootElement(name = "operator")
public class Operator {

    @XmlElements({
        @XmlElement(name = "term", type = Term.class),
        @XmlElement(name = "description", type = Description.class),
        @XmlElement(name = "label", type = Label.class),
        @XmlElement(name = "operator", type = Operator.class)
    })
    protected List<Object> operatorOrTermOrLabel;
    @XmlAttribute
    protected String name;
    @XmlAttribute(name = "start-string")
    protected String startString;
    @XmlAttribute(name = "end-string")
    protected String endString;
    @XmlAttribute(name = "middle-string")
    protected String middleString;
    @XmlAttribute(name = "char")
    protected String _char;
    @XmlAttribute
    protected Integer precedence;
    @XmlAttribute
    protected String distribute;
    @XmlAttribute
    protected String logic;
    @XmlAttribute
    protected String field;
    @XmlAttribute(name = "disallow-operators")
    protected String disallowOperators;
    @XmlAttribute(name = "expand-str")
    protected String expandStr;
    @XmlAttribute(name = "expand-logic")
    protected String expandLogic;
    @XmlAttribute(name = "expand-type")
    protected String expandType;
    @XmlAttribute(name = "expand-count")
    @XmlSchemaType(name = "unsignedInt")
    protected Long expandCount;
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
     * Gets the value of the operatorOrTermOrLabel property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the operatorOrTermOrLabel property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getOperatorOrTermOrLabel().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Term }
     * {@link Description }
     * {@link Label }
     * {@link Operator }
     * 
     * 
     */
    public List<Object> getOperatorOrTermOrLabel() {
        if (operatorOrTermOrLabel == null) {
            operatorOrTermOrLabel = new ArrayList<Object>();
        }
        return this.operatorOrTermOrLabel;
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
     * Gets the value of the startString property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStartString() {
        return startString;
    }

    /**
     * Sets the value of the startString property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStartString(String value) {
        this.startString = value;
    }

    /**
     * Gets the value of the endString property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEndString() {
        return endString;
    }

    /**
     * Sets the value of the endString property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEndString(String value) {
        this.endString = value;
    }

    /**
     * Gets the value of the middleString property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMiddleString() {
        return middleString;
    }

    /**
     * Sets the value of the middleString property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMiddleString(String value) {
        this.middleString = value;
    }

    /**
     * Gets the value of the char property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getChar() {
        return _char;
    }

    /**
     * Sets the value of the char property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setChar(String value) {
        this._char = value;
    }

    /**
     * Gets the value of the precedence property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getPrecedence() {
        return precedence;
    }

    /**
     * Sets the value of the precedence property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPrecedence(Integer value) {
        this.precedence = value;
    }

    /**
     * Gets the value of the distribute property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDistribute() {
        return distribute;
    }

    /**
     * Sets the value of the distribute property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDistribute(String value) {
        this.distribute = value;
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
     * Gets the value of the disallowOperators property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisallowOperators() {
        return disallowOperators;
    }

    /**
     * Sets the value of the disallowOperators property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisallowOperators(String value) {
        this.disallowOperators = value;
    }

    /**
     * Gets the value of the expandStr property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExpandStr() {
        return expandStr;
    }

    /**
     * Sets the value of the expandStr property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExpandStr(String value) {
        this.expandStr = value;
    }

    /**
     * Gets the value of the expandLogic property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExpandLogic() {
        return expandLogic;
    }

    /**
     * Sets the value of the expandLogic property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExpandLogic(String value) {
        this.expandLogic = value;
    }

    /**
     * Gets the value of the expandType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExpandType() {
        return expandType;
    }

    /**
     * Sets the value of the expandType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExpandType(String value) {
        this.expandType = value;
    }

    /**
     * Gets the value of the expandCount property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getExpandCount() {
        return expandCount;
    }

    /**
     * Sets the value of the expandCount property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setExpandCount(Long value) {
        this.expandCount = value;
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
