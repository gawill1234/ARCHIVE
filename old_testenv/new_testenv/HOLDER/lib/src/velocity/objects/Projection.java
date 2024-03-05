
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *       &lt;attribute name="value-expression" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="key-expression" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="from" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="sort-rank" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="sort-id" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="sort-direction" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="fmt" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "projection")
public class Projection {

    @XmlAttribute(name = "value-expression")
    @XmlSchemaType(name = "anySimpleType")
    protected String valueExpression;
    @XmlAttribute(name = "key-expression")
    @XmlSchemaType(name = "anySimpleType")
    protected String keyExpression;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String from;
    @XmlAttribute(name = "sort-rank")
    @XmlSchemaType(name = "anySimpleType")
    protected String sortRank;
    @XmlAttribute(name = "sort-id")
    @XmlSchemaType(name = "anySimpleType")
    protected String sortId;
    @XmlAttribute(name = "sort-direction")
    @XmlSchemaType(name = "anySimpleType")
    protected String sortDirection;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String fmt;

    /**
     * Gets the value of the valueExpression property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getValueExpression() {
        return valueExpression;
    }

    /**
     * Sets the value of the valueExpression property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setValueExpression(String value) {
        this.valueExpression = value;
    }

    /**
     * Gets the value of the keyExpression property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getKeyExpression() {
        return keyExpression;
    }

    /**
     * Sets the value of the keyExpression property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setKeyExpression(String value) {
        this.keyExpression = value;
    }

    /**
     * Gets the value of the from property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFrom() {
        return from;
    }

    /**
     * Sets the value of the from property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFrom(String value) {
        this.from = value;
    }

    /**
     * Gets the value of the sortRank property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSortRank() {
        return sortRank;
    }

    /**
     * Sets the value of the sortRank property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSortRank(String value) {
        this.sortRank = value;
    }

    /**
     * Gets the value of the sortId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSortId() {
        return sortId;
    }

    /**
     * Sets the value of the sortId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSortId(String value) {
        this.sortId = value;
    }

    /**
     * Gets the value of the sortDirection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSortDirection() {
        return sortDirection;
    }

    /**
     * Sets the value of the sortDirection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSortDirection(String value) {
        this.sortDirection = value;
    }

    /**
     * Gets the value of the fmt property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFmt() {
        return fmt;
    }

    /**
     * Sets the value of the fmt property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFmt(String value) {
        this.fmt = value;
    }

}
