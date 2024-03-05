
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.CrawlerOfflineStatus;


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
 *         &lt;element ref="{urn:/velocity/objects}crawler-offline-status"/>
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
    "crawlerOfflineStatus"
})
@XmlRootElement(name = "CollectionBrokerCrawlerOfflineStatusResponse")
public class CollectionBrokerCrawlerOfflineStatusResponse {

    @XmlElement(name = "crawler-offline-status", namespace = "urn:/velocity/objects", required = true)
    protected CrawlerOfflineStatus crawlerOfflineStatus;

    /**
     * Gets the value of the crawlerOfflineStatus property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlerOfflineStatus }
     *     
     */
    public CrawlerOfflineStatus getCrawlerOfflineStatus() {
        return crawlerOfflineStatus;
    }

    /**
     * Sets the value of the crawlerOfflineStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlerOfflineStatus }
     *     
     */
    public void setCrawlerOfflineStatus(CrawlerOfflineStatus value) {
        this.crawlerOfflineStatus = value;
    }

}
