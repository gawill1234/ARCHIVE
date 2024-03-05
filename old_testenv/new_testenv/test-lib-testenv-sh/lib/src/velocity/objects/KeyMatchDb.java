
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
 *       &lt;attribute name="stem" type="{http://www.w3.org/2001/XMLSchema}string" default="case" />
 *       &lt;attribute name="kb" type="{http://www.w3.org/2001/XMLSchema}string" default="none" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "key-match-db")
public class KeyMatchDb {

    @XmlAttribute
    protected String stem;
    @XmlAttribute
    protected String kb;

    /**
     * Gets the value of the stem property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStem() {
        if (stem == null) {
            return "case";
        } else {
            return stem;
        }
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
     * Gets the value of the kb property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getKb() {
        if (kb == null) {
            return "none";
        } else {
            return kb;
        }
    }

    /**
     * Sets the value of the kb property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setKb(String value) {
        this.kb = value;
    }

}
