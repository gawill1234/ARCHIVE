
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
 *       &lt;attGroup ref="{urn:/velocity/objects}duplicates"/>
 *       &lt;attribute name="this" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="that" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "crawl-replace")
public class CrawlReplace {

    @XmlAttribute(name = "this")
    @XmlSchemaType(name = "anySimpleType")
    protected String _this;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String that;
    @XmlAttribute
    protected String added;

    /**
     * Gets the value of the this property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getThis() {
        return _this;
    }

    /**
     * Sets the value of the this property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setThis(String value) {
        this._this = value;
    }

    /**
     * Gets the value of the that property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getThat() {
        return that;
    }

    /**
     * Sets the value of the that property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setThat(String value) {
        this.that = value;
    }

    /**
     * Gets the value of the added property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAdded() {
        return added;
    }

    /**
     * Sets the value of the added property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAdded(String value) {
        this.added = value;
    }

}
