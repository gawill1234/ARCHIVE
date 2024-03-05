
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
 *       &lt;attribute name="ping" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="staging">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="staging"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="active" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-queries" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="ms-queries" type="{http://www.w3.org/2001/XMLSchema}long" default="0" />
 *       &lt;attribute name="n-bytes" type="{http://www.w3.org/2001/XMLSchema}long" default="0" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "vse-qs-serving")
public class VseQsServing {

    @XmlAttribute
    protected String name;
    @XmlAttribute
    protected String ping;
    @XmlAttribute
    protected String staging;
    @XmlAttribute
    protected Integer active;
    @XmlAttribute(name = "n-queries")
    protected Integer nQueries;
    @XmlAttribute(name = "ms-queries")
    protected Long msQueries;
    @XmlAttribute(name = "n-bytes")
    protected Long nBytes;

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

    /**
     * Gets the value of the staging property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStaging() {
        return staging;
    }

    /**
     * Sets the value of the staging property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStaging(String value) {
        this.staging = value;
    }

    /**
     * Gets the value of the active property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getActive() {
        if (active == null) {
            return  0;
        } else {
            return active;
        }
    }

    /**
     * Sets the value of the active property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setActive(Integer value) {
        this.active = value;
    }

    /**
     * Gets the value of the nQueries property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNQueries() {
        if (nQueries == null) {
            return  0;
        } else {
            return nQueries;
        }
    }

    /**
     * Sets the value of the nQueries property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNQueries(Integer value) {
        this.nQueries = value;
    }

    /**
     * Gets the value of the msQueries property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public long getMsQueries() {
        if (msQueries == null) {
            return  0L;
        } else {
            return msQueries;
        }
    }

    /**
     * Sets the value of the msQueries property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setMsQueries(Long value) {
        this.msQueries = value;
    }

    /**
     * Gets the value of the nBytes property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public long getNBytes() {
        if (nBytes == null) {
            return  0L;
        } else {
            return nBytes;
        }
    }

    /**
     * Sets the value of the nBytes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setNBytes(Long value) {
        this.nBytes = value;
    }

}
