
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.CrawlUrlStatusResponse;


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
 *         &lt;element ref="{urn:/velocity/objects}crawl-url-status-response"/>
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
    "crawlUrlStatusResponse"
})
@XmlRootElement(name = "SearchCollectionUrlStatusQueryResponse")
public class SearchCollectionUrlStatusQueryResponse {

    @XmlElement(name = "crawl-url-status-response", namespace = "urn:/velocity/objects", required = true)
    protected CrawlUrlStatusResponse crawlUrlStatusResponse;

    /**
     * Gets the value of the crawlUrlStatusResponse property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlUrlStatusResponse }
     *     
     */
    public CrawlUrlStatusResponse getCrawlUrlStatusResponse() {
        return crawlUrlStatusResponse;
    }

    /**
     * Sets the value of the crawlUrlStatusResponse property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlUrlStatusResponse }
     *     
     */
    public void setCrawlUrlStatusResponse(CrawlUrlStatusResponse value) {
        this.crawlUrlStatusResponse = value;
    }

}
