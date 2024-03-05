
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
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
 *         &lt;element ref="{urn:/velocity/objects}crawl-remote-connection-status" maxOccurs="unbounded" minOccurs="0"/>
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
    "crawlRemoteConnectionStatus"
})
@XmlRootElement(name = "crawl-remote-server-status")
public class CrawlRemoteServerStatus {

    @XmlElement(name = "crawl-remote-connection-status")
    protected List<CrawlRemoteConnectionStatus> crawlRemoteConnectionStatus;

    /**
     * Gets the value of the crawlRemoteConnectionStatus property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlRemoteConnectionStatus property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlRemoteConnectionStatus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlRemoteConnectionStatus }
     * 
     * 
     */
    public List<CrawlRemoteConnectionStatus> getCrawlRemoteConnectionStatus() {
        if (crawlRemoteConnectionStatus == null) {
            crawlRemoteConnectionStatus = new ArrayList<CrawlRemoteConnectionStatus>();
        }
        return this.crawlRemoteConnectionStatus;
    }

}
