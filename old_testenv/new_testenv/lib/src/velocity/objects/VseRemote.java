
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
 *         &lt;element ref="{urn:/velocity/objects}vse-remote-option" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-remote-server-option" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-remote-mirror" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="admin-url" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="user" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="password" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
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
    "vseRemoteOption",
    "vseRemoteServerOption",
    "vseRemoteMirror"
})
@XmlRootElement(name = "vse-remote")
public class VseRemote {

    @XmlElement(name = "vse-index-option")
    protected List<VseIndexOption> vseIndexOption;
    @XmlElement(name = "vse-remote-option")
    protected List<VseRemoteOption> vseRemoteOption;
    @XmlElement(name = "vse-remote-server-option")
    protected List<VseRemoteServerOption> vseRemoteServerOption;
    @XmlElement(name = "vse-remote-mirror")
    protected List<VseRemoteMirror> vseRemoteMirror;
    @XmlAttribute(name = "admin-url")
    @XmlSchemaType(name = "anySimpleType")
    protected String adminUrl;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String user;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String password;

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
     * Gets the value of the vseRemoteOption property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseRemoteOption property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseRemoteOption().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseRemoteOption }
     * 
     * 
     */
    public List<VseRemoteOption> getVseRemoteOption() {
        if (vseRemoteOption == null) {
            vseRemoteOption = new ArrayList<VseRemoteOption>();
        }
        return this.vseRemoteOption;
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
     * Gets the value of the vseRemoteMirror property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseRemoteMirror property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseRemoteMirror().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseRemoteMirror }
     * 
     * 
     */
    public List<VseRemoteMirror> getVseRemoteMirror() {
        if (vseRemoteMirror == null) {
            vseRemoteMirror = new ArrayList<VseRemoteMirror>();
        }
        return this.vseRemoteMirror;
    }

    /**
     * Gets the value of the adminUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAdminUrl() {
        return adminUrl;
    }

    /**
     * Sets the value of the adminUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAdminUrl(String value) {
        this.adminUrl = value;
    }

    /**
     * Gets the value of the user property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUser() {
        return user;
    }

    /**
     * Sets the value of the user property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUser(String value) {
        this.user = value;
    }

    /**
     * Gets the value of the password property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPassword() {
        return password;
    }

    /**
     * Sets the value of the password property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPassword(String value) {
        this.password = value;
    }

}
