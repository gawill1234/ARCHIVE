
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.CollectionBrokerConfiguration;


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
 *         &lt;element ref="{urn:/velocity/objects}collection-broker-configuration"/>
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
    "collectionBrokerConfiguration"
})
@XmlRootElement(name = "CollectionBrokerGetResponse")
public class CollectionBrokerGetResponse {

    @XmlElement(name = "collection-broker-configuration", namespace = "urn:/velocity/objects", required = true)
    protected CollectionBrokerConfiguration collectionBrokerConfiguration;

    /**
     * Gets the value of the collectionBrokerConfiguration property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerConfiguration }
     *     
     */
    public CollectionBrokerConfiguration getCollectionBrokerConfiguration() {
        return collectionBrokerConfiguration;
    }

    /**
     * Sets the value of the collectionBrokerConfiguration property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerConfiguration }
     *     
     */
    public void setCollectionBrokerConfiguration(CollectionBrokerConfiguration value) {
        this.collectionBrokerConfiguration = value;
    }

}
