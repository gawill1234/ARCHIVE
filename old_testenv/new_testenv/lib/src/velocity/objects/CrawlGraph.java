
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *       &lt;attribute name="filename" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remote-collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remote-packet-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="remote-counter" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "crawl-graph")
public class CrawlGraph {

    @XmlAttribute
    protected String filename;
    @XmlAttribute(name = "remote-collection")
    protected String remoteCollection;
    @XmlAttribute(name = "remote-packet-id")
    protected Integer remotePacketId;
    @XmlAttribute(name = "remote-counter")
    protected Integer remoteCounter;

    /**
     * Gets the value of the filename property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFilename() {
        return filename;
    }

    /**
     * Sets the value of the filename property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFilename(String value) {
        this.filename = value;
    }

    /**
     * Gets the value of the remoteCollection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteCollection() {
        return remoteCollection;
    }

    /**
     * Sets the value of the remoteCollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteCollection(String value) {
        this.remoteCollection = value;
    }

    /**
     * Gets the value of the remotePacketId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemotePacketId() {
        return remotePacketId;
    }

    /**
     * Sets the value of the remotePacketId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemotePacketId(Integer value) {
        this.remotePacketId = value;
    }

    /**
     * Gets the value of the remoteCounter property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteCounter() {
        return remoteCounter;
    }

    /**
     * Sets the value of the remoteCounter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteCounter(Integer value) {
        this.remoteCounter = value;
    }

}
