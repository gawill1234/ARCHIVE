
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.ReadOnlyState;


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
 *         &lt;element ref="{urn:/velocity/objects}read-only-state"/>
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
    "readOnlyState"
})
@XmlRootElement(name = "SearchCollectionReadOnlyResponse")
public class SearchCollectionReadOnlyResponse {

    @XmlElement(name = "read-only-state", namespace = "urn:/velocity/objects", required = true)
    protected ReadOnlyState readOnlyState;

    /**
     * Gets the value of the readOnlyState property.
     * 
     * @return
     *     possible object is
     *     {@link ReadOnlyState }
     *     
     */
    public ReadOnlyState getReadOnlyState() {
        return readOnlyState;
    }

    /**
     * Sets the value of the readOnlyState property.
     * 
     * @param value
     *     allowed object is
     *     {@link ReadOnlyState }
     *     
     */
    public void setReadOnlyState(ReadOnlyState value) {
        this.readOnlyState = value;
    }

}
