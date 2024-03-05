
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
 *         &lt;element ref="{urn:/velocity/objects}vse-meta-info"/>
 *       &lt;/sequence>
 *       &lt;attribute name="creator" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="create-time" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="modified" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="push-toggle">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="push-toggle"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="which">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="staging"/>
 *             &lt;enumeration value="live"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="fork">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="master"/>
 *             &lt;enumeration value="slave"/>
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
    "vseMetaInfo"
})
@XmlRootElement(name = "vse-meta")
public class VseMeta {

    @XmlElement(name = "vse-meta-info")
    protected List<VseMetaInfo> vseMetaInfo;
    @XmlAttribute
    protected String creator;
    @XmlAttribute(name = "create-time")
    protected Integer createTime;
    @XmlAttribute
    protected Integer modified;
    @XmlAttribute(name = "push-toggle")
    protected String pushToggle;
    @XmlAttribute
    protected String which;
    @XmlAttribute
    protected String fork;

    /**
     * Gets the value of the vseMetaInfo property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseMetaInfo property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseMetaInfo().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseMetaInfo }
     * 
     * 
     */
    public List<VseMetaInfo> getVseMetaInfo() {
        if (vseMetaInfo == null) {
            vseMetaInfo = new ArrayList<VseMetaInfo>();
        }
        return this.vseMetaInfo;
    }

    /**
     * Gets the value of the creator property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCreator() {
        return creator;
    }

    /**
     * Sets the value of the creator property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCreator(String value) {
        this.creator = value;
    }

    /**
     * Gets the value of the createTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCreateTime() {
        return createTime;
    }

    /**
     * Sets the value of the createTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCreateTime(Integer value) {
        this.createTime = value;
    }

    /**
     * Gets the value of the modified property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getModified() {
        return modified;
    }

    /**
     * Sets the value of the modified property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setModified(Integer value) {
        this.modified = value;
    }

    /**
     * Gets the value of the pushToggle property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPushToggle() {
        return pushToggle;
    }

    /**
     * Sets the value of the pushToggle property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPushToggle(String value) {
        this.pushToggle = value;
    }

    /**
     * Gets the value of the which property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getWhich() {
        return which;
    }

    /**
     * Sets the value of the which property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setWhich(String value) {
        this.which = value;
    }

    /**
     * Gets the value of the fork property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFork() {
        return fork;
    }

    /**
     * Sets the value of the fork property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFork(String value) {
        this.fork = value;
    }

}
