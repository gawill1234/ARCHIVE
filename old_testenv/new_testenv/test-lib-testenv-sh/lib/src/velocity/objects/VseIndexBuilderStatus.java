
package velocity.objects;

import java.math.BigInteger;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *       &lt;attribute name="elapsed" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="url" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="msg" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="n-segments" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-urls" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="ms" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "vse-index-builder-status")
public class VseIndexBuilderStatus {

    @XmlAttribute
    protected Double elapsed;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String url;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String msg;
    @XmlAttribute(name = "n-segments")
    protected Integer nSegments;
    @XmlAttribute(name = "n-urls")
    protected Integer nUrls;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger ms;

    /**
     * Gets the value of the elapsed property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getElapsed() {
        return elapsed;
    }

    /**
     * Sets the value of the elapsed property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setElapsed(Double value) {
        this.elapsed = value;
    }

    /**
     * Gets the value of the url property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrl() {
        return url;
    }

    /**
     * Sets the value of the url property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrl(String value) {
        this.url = value;
    }

    /**
     * Gets the value of the msg property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMsg() {
        return msg;
    }

    /**
     * Sets the value of the msg property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMsg(String value) {
        this.msg = value;
    }

    /**
     * Gets the value of the nSegments property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNSegments() {
        if (nSegments == null) {
            return  0;
        } else {
            return nSegments;
        }
    }

    /**
     * Sets the value of the nSegments property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNSegments(Integer value) {
        this.nSegments = value;
    }

    /**
     * Gets the value of the nUrls property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNUrls() {
        if (nUrls == null) {
            return  0;
        } else {
            return nUrls;
        }
    }

    /**
     * Sets the value of the nUrls property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNUrls(Integer value) {
        this.nUrls = value;
    }

    /**
     * Gets the value of the ms property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getMs() {
        if (ms == null) {
            return new BigInteger("0");
        } else {
            return ms;
        }
    }

    /**
     * Sets the value of the ms property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setMs(BigInteger value) {
        this.ms = value;
    }

}
