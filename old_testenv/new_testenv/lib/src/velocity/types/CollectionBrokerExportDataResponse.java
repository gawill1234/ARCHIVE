
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
 *         &lt;element ref="{urn:/velocity/objects}collection-broker-export-data-response"/>
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
    "collectionBrokerExportDataResponse"
})
@XmlRootElement(name = "CollectionBrokerExportDataResponse")
public class CollectionBrokerExportDataResponse {

    @XmlElement(name = "collection-broker-export-data-response", namespace = "urn:/velocity/objects", required = true)
    protected velocity.objects.CollectionBrokerExportDataResponse collectionBrokerExportDataResponse;

    /**
     * Gets the value of the collectionBrokerExportDataResponse property.
     * 
     * @return
     *     possible object is
     *     {@link velocity.objects.CollectionBrokerExportDataResponse }
     *     
     */
    public velocity.objects.CollectionBrokerExportDataResponse getCollectionBrokerExportDataResponse() {
        return collectionBrokerExportDataResponse;
    }

    /**
     * Sets the value of the collectionBrokerExportDataResponse property.
     * 
     * @param value
     *     allowed object is
     *     {@link velocity.objects.CollectionBrokerExportDataResponse }
     *     
     */
    public void setCollectionBrokerExportDataResponse(velocity.objects.CollectionBrokerExportDataResponse value) {
        this.collectionBrokerExportDataResponse = value;
    }

}
