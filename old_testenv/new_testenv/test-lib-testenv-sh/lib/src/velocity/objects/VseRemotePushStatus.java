
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
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
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}vse-remote-hello"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-remote-push-file"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-remote-push-swap"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-remote-push-slice"/>
 *       &lt;/choice>
 *       &lt;attribute name="start-at" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="end-at" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseRemoteHelloOrVseRemotePushFileOrVseRemotePushSwap"
})
@XmlRootElement(name = "vse-remote-push-status")
public class VseRemotePushStatus {

    @XmlElements({
        @XmlElement(name = "vse-remote-hello", type = VseRemoteHello.class),
        @XmlElement(name = "vse-remote-push-slice", type = VseRemotePushSlice.class),
        @XmlElement(name = "vse-remote-push-swap", type = VseRemotePushSwap.class),
        @XmlElement(name = "vse-remote-push-file", type = VseRemotePushFile.class)
    })
    protected List<Object> vseRemoteHelloOrVseRemotePushFileOrVseRemotePushSwap;
    @XmlAttribute(name = "start-at")
    protected Integer startAt;
    @XmlAttribute(name = "end-at")
    protected Integer endAt;

    /**
     * Gets the value of the vseRemoteHelloOrVseRemotePushFileOrVseRemotePushSwap property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseRemoteHelloOrVseRemotePushFileOrVseRemotePushSwap property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseRemoteHelloOrVseRemotePushFileOrVseRemotePushSwap().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseRemoteHello }
     * {@link VseRemotePushSlice }
     * {@link VseRemotePushSwap }
     * {@link VseRemotePushFile }
     * 
     * 
     */
    public List<Object> getVseRemoteHelloOrVseRemotePushFileOrVseRemotePushSwap() {
        if (vseRemoteHelloOrVseRemotePushFileOrVseRemotePushSwap == null) {
            vseRemoteHelloOrVseRemotePushFileOrVseRemotePushSwap = new ArrayList<Object>();
        }
        return this.vseRemoteHelloOrVseRemotePushFileOrVseRemotePushSwap;
    }

    /**
     * Gets the value of the startAt property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStartAt() {
        return startAt;
    }

    /**
     * Sets the value of the startAt property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStartAt(Integer value) {
        this.startAt = value;
    }

    /**
     * Gets the value of the endAt property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEndAt() {
        return endAt;
    }

    /**
     * Sets the value of the endAt property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEndAt(Integer value) {
        this.endAt = value;
    }

}
