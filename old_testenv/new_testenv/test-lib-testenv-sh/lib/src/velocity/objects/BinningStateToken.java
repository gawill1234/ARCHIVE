
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
 *       &lt;attribute name="bst-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="bs-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="token" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remove-state" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "binning-state-token")
public class BinningStateToken {

    @XmlAttribute(name = "bst-id")
    protected String bstId;
    @XmlAttribute(name = "bs-id")
    protected String bsId;
    @XmlAttribute
    protected String token;
    @XmlAttribute(name = "remove-state")
    protected String removeState;

    /**
     * Gets the value of the bstId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBstId() {
        return bstId;
    }

    /**
     * Sets the value of the bstId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBstId(String value) {
        this.bstId = value;
    }

    /**
     * Gets the value of the bsId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBsId() {
        return bsId;
    }

    /**
     * Sets the value of the bsId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBsId(String value) {
        this.bsId = value;
    }

    /**
     * Gets the value of the token property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getToken() {
        return token;
    }

    /**
     * Sets the value of the token property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setToken(String value) {
        this.token = value;
    }

    /**
     * Gets the value of the removeState property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoveState() {
        return removeState;
    }

    /**
     * Sets the value of the removeState property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoveState(String value) {
        this.removeState = value;
    }

}
