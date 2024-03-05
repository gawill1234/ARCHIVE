
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
 *       &lt;attribute name="slice" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="n-slices" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "vse-remote-push-slice")
public class VseRemotePushSlice {

    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String slice;
    @XmlAttribute(name = "n-slices")
    @XmlSchemaType(name = "anySimpleType")
    protected String nSlices;

    /**
     * Gets the value of the slice property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSlice() {
        return slice;
    }

    /**
     * Sets the value of the slice property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSlice(String value) {
        this.slice = value;
    }

    /**
     * Gets the value of the nSlices property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNSlices() {
        return nSlices;
    }

    /**
     * Sets the value of the nSlices property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNSlices(String value) {
        this.nSlices = value;
    }

}
