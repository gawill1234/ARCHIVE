
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
 *         &lt;element ref="{urn:/velocity/objects}vse-qs-serving"/>
 *       &lt;/sequence>
 *       &lt;attribute name="died">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="died"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="ping" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseQsServing"
})
@XmlRootElement(name = "vse-qs-status")
public class VseQsStatus {

    @XmlElement(name = "vse-qs-serving")
    protected List<VseQsServing> vseQsServing;
    @XmlAttribute
    protected String died;
    @XmlAttribute
    protected String ping;

    /**
     * Gets the value of the vseQsServing property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseQsServing property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseQsServing().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseQsServing }
     * 
     * 
     */
    public List<VseQsServing> getVseQsServing() {
        if (vseQsServing == null) {
            vseQsServing = new ArrayList<VseQsServing>();
        }
        return this.vseQsServing;
    }

    /**
     * Gets the value of the died property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDied() {
        return died;
    }

    /**
     * Sets the value of the died property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDied(String value) {
        this.died = value;
    }

    /**
     * Gets the value of the ping property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPing() {
        return ping;
    }

    /**
     * Sets the value of the ping property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPing(String value) {
        this.ping = value;
    }

}
