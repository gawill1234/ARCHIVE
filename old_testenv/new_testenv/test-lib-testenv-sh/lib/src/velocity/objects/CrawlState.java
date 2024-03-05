
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.XmlValue;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;simpleContent>
 *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remote-collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remote-counter" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="remote-packet-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="synchronization" default="none">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="none"/>
 *             &lt;enumeration value="enqueued"/>
 *             &lt;enumeration value="indexed"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *     &lt;/extension>
 *   &lt;/simpleContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "value"
})
@XmlRootElement(name = "crawl-state")
public class CrawlState {

    @XmlValue
    protected String value;
    @XmlAttribute
    protected String name;
    @XmlAttribute(name = "remote-collection")
    protected String remoteCollection;
    @XmlAttribute(name = "remote-counter")
    @XmlSchemaType(name = "unsignedInt")
    protected Long remoteCounter;
    @XmlAttribute(name = "remote-packet-id")
    protected Integer remotePacketId;
    @XmlAttribute
    protected String synchronization;

    /**
     * Gets the value of the value property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getValue() {
        return value;
    }

    /**
     * Sets the value of the value property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setValue(String value) {
        this.value = value;
    }

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
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
     * Gets the value of the remoteCounter property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getRemoteCounter() {
        return remoteCounter;
    }

    /**
     * Sets the value of the remoteCounter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setRemoteCounter(Long value) {
        this.remoteCounter = value;
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
     * Gets the value of the synchronization property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSynchronization() {
        if (synchronization == null) {
            return "none";
        } else {
            return synchronization;
        }
    }

    /**
     * Sets the value of the synchronization property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSynchronization(String value) {
        this.synchronization = value;
    }

}
