
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
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="stem" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="conflict" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "key-match")
public class KeyMatch {

    @XmlAttribute
    protected String name;
    @XmlAttribute
    protected String stem;
    @XmlAttribute
    protected String conflict;

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
     * Gets the value of the stem property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStem() {
        return stem;
    }

    /**
     * Sets the value of the stem property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStem(String value) {
        this.stem = value;
    }

    /**
     * Gets the value of the conflict property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getConflict() {
        return conflict;
    }

    /**
     * Sets the value of the conflict property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setConflict(String value) {
        this.conflict = value;
    }

}
