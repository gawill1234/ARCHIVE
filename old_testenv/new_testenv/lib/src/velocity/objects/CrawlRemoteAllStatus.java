
package velocity.objects;

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
 *         &lt;element ref="{urn:/velocity/objects}crawl-remote-server-status" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-remote-client-status" minOccurs="0"/>
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
    "crawlRemoteServerStatus",
    "crawlRemoteClientStatus"
})
@XmlRootElement(name = "crawl-remote-all-status")
public class CrawlRemoteAllStatus {

    @XmlElement(name = "crawl-remote-server-status")
    protected CrawlRemoteServerStatus crawlRemoteServerStatus;
    @XmlElement(name = "crawl-remote-client-status")
    protected CrawlRemoteClientStatus crawlRemoteClientStatus;

    /**
     * Gets the value of the crawlRemoteServerStatus property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlRemoteServerStatus }
     *     
     */
    public CrawlRemoteServerStatus getCrawlRemoteServerStatus() {
        return crawlRemoteServerStatus;
    }

    /**
     * Sets the value of the crawlRemoteServerStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlRemoteServerStatus }
     *     
     */
    public void setCrawlRemoteServerStatus(CrawlRemoteServerStatus value) {
        this.crawlRemoteServerStatus = value;
    }

    /**
     * Gets the value of the crawlRemoteClientStatus property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlRemoteClientStatus }
     *     
     */
    public CrawlRemoteClientStatus getCrawlRemoteClientStatus() {
        return crawlRemoteClientStatus;
    }

    /**
     * Sets the value of the crawlRemoteClientStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlRemoteClientStatus }
     *     
     */
    public void setCrawlRemoteClientStatus(CrawlRemoteClientStatus value) {
        this.crawlRemoteClientStatus = value;
    }

}
