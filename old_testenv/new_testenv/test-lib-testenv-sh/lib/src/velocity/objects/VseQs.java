
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}vse-qs-option"/>
 *       &lt;/sequence>
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseQsOption"
})
@XmlRootElement(name = "vse-qs")
public class VseQs {

    @XmlElement(name = "vse-qs-option", required = true)
    protected VseQsOption vseQsOption;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String id;

    /**
     * Gets the value of the vseQsOption property.
     * 
     * @return
     *     possible object is
     *     {@link VseQsOption }
     *     
     */
    public VseQsOption getVseQsOption() {
        return vseQsOption;
    }

    /**
     * Sets the value of the vseQsOption property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseQsOption }
     *     
     */
    public void setVseQsOption(VseQsOption value) {
        this.vseQsOption = value;
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

}
