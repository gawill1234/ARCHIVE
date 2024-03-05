
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
 *         &lt;element ref="{urn:/velocity/objects}collection-broker-search-response"/>
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
    "collectionBrokerSearchResponse"
})
@XmlRootElement(name = "CollectionBrokerSearchResponse")
public class CollectionBrokerSearchResponse {

    @XmlElement(name = "collection-broker-search-response", namespace = "urn:/velocity/objects", required = true)
    protected velocity.objects.CollectionBrokerSearchResponse collectionBrokerSearchResponse;

    /**
     * Gets the value of the collectionBrokerSearchResponse property.
     * 
     * @return
     *     possible object is
     *     {@link velocity.objects.CollectionBrokerSearchResponse }
     *     
     */
    public velocity.objects.CollectionBrokerSearchResponse getCollectionBrokerSearchResponse() {
        return collectionBrokerSearchResponse;
    }

    /**
     * Sets the value of the collectionBrokerSearchResponse property.
     * 
     * @param value
     *     allowed object is
     *     {@link velocity.objects.CollectionBrokerSearchResponse }
     *     
     */
    public void setCollectionBrokerSearchResponse(velocity.objects.CollectionBrokerSearchResponse value) {
        this.collectionBrokerSearchResponse = value;
    }

}
