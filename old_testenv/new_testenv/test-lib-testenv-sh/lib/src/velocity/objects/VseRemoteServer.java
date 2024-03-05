
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
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
 *         &lt;element ref="{urn:/velocity/objects}vse-index-option" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-remote-server-option" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="push-server" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remote-identifier" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="remote-slice" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="remote-n-slices" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="slice" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-slices" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseIndexOption",
    "vseRemoteServerOption"
})
@XmlRootElement(name = "vse-remote-server")
public class VseRemoteServer {

    @XmlElement(name = "vse-index-option")
    protected List<VseIndexOption> vseIndexOption;
    @XmlElement(name = "vse-remote-server-option")
    protected List<VseRemoteServerOption> vseRemoteServerOption;
    @XmlAttribute
    protected String id;
    @XmlAttribute(name = "push-server")
    protected String pushServer;
    @XmlAttribute(name = "remote-identifier")
    @XmlSchemaType(name = "anySimpleType")
    protected String remoteIdentifier;
    @XmlAttribute(name = "remote-slice")
    protected Integer remoteSlice;
    @XmlAttribute(name = "remote-n-slices")
    protected Integer remoteNSlices;
    @XmlAttribute
    protected Integer slice;
    @XmlAttribute(name = "n-slices")
    protected Integer nSlices;

    /**
     * Gets the value of the vseIndexOption property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseIndexOption property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseIndexOption().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseIndexOption }
     * 
     * 
     */
    public List<VseIndexOption> getVseIndexOption() {
        if (vseIndexOption == null) {
            vseIndexOption = new ArrayList<VseIndexOption>();
        }
        return this.vseIndexOption;
    }

    /**
     * Gets the value of the vseRemoteServerOption property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseRemoteServerOption property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseRemoteServerOption().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseRemoteServerOption }
     * 
     * 
     */
    public List<VseRemoteServerOption> getVseRemoteServerOption() {
        if (vseRemoteServerOption == null) {
            vseRemoteServerOption = new ArrayList<VseRemoteServerOption>();
        }
        return this.vseRemoteServerOption;
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

    /**
     * Gets the value of the pushServer property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPushServer() {
        return pushServer;
    }

    /**
     * Sets the value of the pushServer property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPushServer(String value) {
        this.pushServer = value;
    }

    /**
     * Gets the value of the remoteIdentifier property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteIdentifier() {
        return remoteIdentifier;
    }

    /**
     * Sets the value of the remoteIdentifier property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteIdentifier(String value) {
        this.remoteIdentifier = value;
    }

    /**
     * Gets the value of the remoteSlice property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteSlice() {
        return remoteSlice;
    }

    /**
     * Sets the value of the remoteSlice property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteSlice(Integer value) {
        this.remoteSlice = value;
    }

    /**
     * Gets the value of the remoteNSlices property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteNSlices() {
        return remoteNSlices;
    }

    /**
     * Sets the value of the remoteNSlices property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteNSlices(Integer value) {
        this.remoteNSlices = value;
    }

    /**
     * Gets the value of the slice property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getSlice() {
        return slice;
    }

    /**
     * Sets the value of the slice property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setSlice(Integer value) {
        this.slice = value;
    }

    /**
     * Gets the value of the nSlices property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNSlices() {
        return nSlices;
    }

    /**
     * Sets the value of the nSlices property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNSlices(Integer value) {
        this.nSlices = value;
    }

}
