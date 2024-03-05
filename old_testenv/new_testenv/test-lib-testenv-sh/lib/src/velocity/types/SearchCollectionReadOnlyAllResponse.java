
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.ReadOnlyStateAll;


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
 *         &lt;element ref="{urn:/velocity/objects}read-only-state-all"/>
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
    "readOnlyStateAll"
})
@XmlRootElement(name = "SearchCollectionReadOnlyAllResponse")
public class SearchCollectionReadOnlyAllResponse {

    @XmlElement(name = "read-only-state-all", namespace = "urn:/velocity/objects", required = true)
    protected ReadOnlyStateAll readOnlyStateAll;

    /**
     * Gets the value of the readOnlyStateAll property.
     * 
     * @return
     *     possible object is
     *     {@link ReadOnlyStateAll }
     *     
     */
    public ReadOnlyStateAll getReadOnlyStateAll() {
        return readOnlyStateAll;
    }

    /**
     * Sets the value of the readOnlyStateAll property.
     * 
     * @param value
     *     allowed object is
     *     {@link ReadOnlyStateAll }
     *     
     */
    public void setReadOnlyStateAll(ReadOnlyStateAll value) {
        this.readOnlyStateAll = value;
    }

}
