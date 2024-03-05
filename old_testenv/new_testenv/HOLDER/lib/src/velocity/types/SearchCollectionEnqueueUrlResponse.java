
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.CrawlerServiceEnqueueResponse;


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
 *         &lt;element ref="{urn:/velocity/objects}crawler-service-enqueue-response"/>
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
    "crawlerServiceEnqueueResponse"
})
@XmlRootElement(name = "SearchCollectionEnqueueUrlResponse")
public class SearchCollectionEnqueueUrlResponse {

    @XmlElement(name = "crawler-service-enqueue-response", namespace = "urn:/velocity/objects", required = true)
    protected CrawlerServiceEnqueueResponse crawlerServiceEnqueueResponse;

    /**
     * Gets the value of the crawlerServiceEnqueueResponse property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlerServiceEnqueueResponse }
     *     
     */
    public CrawlerServiceEnqueueResponse getCrawlerServiceEnqueueResponse() {
        return crawlerServiceEnqueueResponse;
    }

    /**
     * Sets the value of the crawlerServiceEnqueueResponse property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlerServiceEnqueueResponse }
     *     
     */
    public void setCrawlerServiceEnqueueResponse(CrawlerServiceEnqueueResponse value) {
        this.crawlerServiceEnqueueResponse = value;
    }

}
