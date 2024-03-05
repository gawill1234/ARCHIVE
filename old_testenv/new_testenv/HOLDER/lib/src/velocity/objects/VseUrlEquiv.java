
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
 *       &lt;attribute name="old-prefix" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="new-prefix" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "vse-url-equiv")
public class VseUrlEquiv {

    @XmlAttribute(name = "old-prefix")
    @XmlSchemaType(name = "anySimpleType")
    protected String oldPrefix;
    @XmlAttribute(name = "new-prefix")
    @XmlSchemaType(name = "anySimpleType")
    protected String newPrefix;

    /**
     * Gets the value of the oldPrefix property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOldPrefix() {
        return oldPrefix;
    }

    /**
     * Sets the value of the oldPrefix property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOldPrefix(String value) {
        this.oldPrefix = value;
    }

    /**
     * Gets the value of the newPrefix property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNewPrefix() {
        return newPrefix;
    }

    /**
     * Sets the value of the newPrefix property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNewPrefix(String value) {
        this.newPrefix = value;
    }

}
