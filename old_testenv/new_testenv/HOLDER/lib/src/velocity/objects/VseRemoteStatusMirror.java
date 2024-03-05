
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
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
 *       &lt;sequence maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}vse-remote-status-server"/>
 *       &lt;/sequence>
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseRemoteStatusServer"
})
@XmlRootElement(name = "vse-remote-status-mirror")
public class VseRemoteStatusMirror {

    @XmlElement(name = "vse-remote-status-server")
    protected List<VseRemoteStatusServer> vseRemoteStatusServer;
    @XmlAttribute
    protected String id;

    /**
     * Gets the value of the vseRemoteStatusServer property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseRemoteStatusServer property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseRemoteStatusServer().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseRemoteStatusServer }
     * 
     * 
     */
    public List<VseRemoteStatusServer> getVseRemoteStatusServer() {
        if (vseRemoteStatusServer == null) {
            vseRemoteStatusServer = new ArrayList<VseRemoteStatusServer>();
        }
        return this.vseRemoteStatusServer;
    }

    /**
     * Gets the value of the id property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getId() {
        return id;
    }

    /**
     * Sets the value of the id property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setId(String value) {
        this.id = value;
    }

}
