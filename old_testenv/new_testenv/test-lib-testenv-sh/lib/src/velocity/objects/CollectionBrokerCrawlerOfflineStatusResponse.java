
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *         &lt;element ref="{urn:/velocity/objects}crawler-offline-status"/>
 *         &lt;element ref="{urn:/velocity/objects}log" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="status">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="success"/>
 *             &lt;enumeration value="error"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlerOfflineStatus",
    "log"
})
@XmlRootElement(name = "collection-broker-crawler-offline-status-response")
public class CollectionBrokerCrawlerOfflineStatusResponse {

    @XmlElement(name = "crawler-offline-status", required = true)
    protected CrawlerOfflineStatus crawlerOfflineStatus;
    protected Log log;
    @XmlAttribute
    protected String status;

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

    /**
     * Gets the value of the log property.
     * 
     * @return
     *     possible object is
     *     {@link Log }
     *     
     */
    public Log getLog() {
        return log;
    }

    /**
     * Sets the value of the log property.
     * 
     * @param value
     *     allowed object is
     *     {@link Log }
     *     
     */
    public void setLog(Log value) {
        this.log = value;
    }

    /**
     * Gets the value of the status property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStatus() {
        return status;
    }

    /**
     * Sets the value of the status property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStatus(String value) {
        this.status = value;
    }

}
