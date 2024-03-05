
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.CollectionBrokerEnqueueResponse;


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
 *         &lt;element ref="{urn:/velocity/objects}collection-broker-enqueue-response"/>
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
    "collectionBrokerEnqueueResponse"
})
@XmlRootElement(name = "CollectionBrokerEnqueueXmlResponse")
public class CollectionBrokerEnqueueXmlResponse {

    @XmlElement(name = "collection-broker-enqueue-response", namespace = "urn:/velocity/objects", required = true)
    protected CollectionBrokerEnqueueResponse collectionBrokerEnqueueResponse;

    /**
     * Gets the value of the collectionBrokerEnqueueResponse property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerEnqueueResponse }
     *     
     */
    public CollectionBrokerEnqueueResponse getCollectionBrokerEnqueueResponse() {
        return collectionBrokerEnqueueResponse;
    }

    /**
     * Sets the value of the collectionBrokerEnqueueResponse property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerEnqueueResponse }
     *     
     */
    public void setCollectionBrokerEnqueueResponse(CollectionBrokerEnqueueResponse value) {
        this.collectionBrokerEnqueueResponse = value;
    }

}
