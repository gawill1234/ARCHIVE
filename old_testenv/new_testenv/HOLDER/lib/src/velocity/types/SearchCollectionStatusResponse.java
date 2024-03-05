
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.VseStatus;


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
 *         &lt;element ref="{urn:/velocity/objects}vse-status"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseStatus"
})
@XmlRootElement(name = "SearchCollectionStatusResponse")
public class SearchCollectionStatusResponse {

    @XmlElement(name = "vse-status", namespace = "urn:/velocity/objects", required = true)
    protected VseStatus vseStatus;

    /**
     * Gets the value of the vseStatus property.
     * 
     * @return
     *     possible object is
     *     {@link VseStatus }
     *     
     */
    public VseStatus getVseStatus() {
        return vseStatus;
    }

    /**
     * Sets the value of the vseStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseStatus }
     *     
     */
    public void setVseStatus(VseStatus value) {
        this.vseStatus = value;
    }

}
