
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
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
 *         &lt;element ref="{urn:/velocity/objects}collection-broker-status-response"/>
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
    "collectionBrokerStatusResponse"
})
@XmlRootElement(name = "CollectionBrokerStatusResponse")
public class CollectionBrokerStatusResponse {

    @XmlElement(name = "collection-broker-status-response", namespace = "urn:/velocity/objects", required = true)
    protected velocity.objects.CollectionBrokerStatusResponse collectionBrokerStatusResponse;

    /**
     * Gets the value of the collectionBrokerStatusResponse property.
     * 
     * @return
     *     possible object is
     *     {@link velocity.objects.CollectionBrokerStatusResponse }
     *     
     */
    public velocity.objects.CollectionBrokerStatusResponse getCollectionBrokerStatusResponse() {
        return collectionBrokerStatusResponse;
    }

    /**
     * Sets the value of the collectionBrokerStatusResponse property.
     * 
     * @param value
     *     allowed object is
     *     {@link velocity.objects.CollectionBrokerStatusResponse }
     *     
     */
    public void setCollectionBrokerStatusResponse(velocity.objects.CollectionBrokerStatusResponse value) {
        this.collectionBrokerStatusResponse = value;
    }

}
