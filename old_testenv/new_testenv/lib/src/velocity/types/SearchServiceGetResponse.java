
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.VseQs;


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
 *         &lt;element ref="{urn:/velocity/objects}vse-qs"/>
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
    "vseQs"
})
@XmlRootElement(name = "SearchServiceGetResponse")
public class SearchServiceGetResponse {

    @XmlElement(name = "vse-qs", namespace = "urn:/velocity/objects", required = true)
    protected VseQs vseQs;

    /**
     * Gets the value of the vseQs property.
     * 
     * @return
     *     possible object is
     *     {@link VseQs }
     *     
     */
    public VseQs getVseQs() {
        return vseQs;
    }

    /**
     * Sets the value of the vseQs property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseQs }
     *     
     */
    public void setVseQs(VseQs value) {
        this.vseQs = value;
    }

}
