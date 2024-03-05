
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
 *       &lt;attribute name="timing-name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="n" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-errors" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="n-check" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="ms" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="ms-check" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="ms-errors" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="bytes-in" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="bytes-in-check" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="bytes-in-errors" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="bytes-out" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "converter-timing")
public class ConverterTiming {

    @XmlAttribute(name = "timing-name")
    protected String timingName;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger n;
    @XmlAttribute(name = "n-errors")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nErrors;
    @XmlAttribute(name = "n-check")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nCheck;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger ms;
    @XmlAttribute(name = "ms-check")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger msCheck;
    @XmlAttribute(name = "ms-errors")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger msErrors;
    @XmlAttribute(name = "bytes-in")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger bytesIn;
    @XmlAttribute(name = "bytes-in-check")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger bytesInCheck;
    @XmlAttribute(name = "bytes-in-errors")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger bytesInErrors;
    @XmlAttribute(name = "bytes-out")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger bytesOut;

    /**
     * Gets the value of the timingName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTimingName() {
        return timingName;
    }

    /**
     * Sets the value of the timingName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTimingName(String value) {
        this.timingName = value;
    }

    /**
     * Gets the value of the n property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getN() {
        if (n == null) {
            return new BigInteger("0");
        } else {
            return n;
        }
    }

    /**
     * Sets the value of the n property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setN(BigInteger value) {
        this.n = value;
    }

    /**
     * Gets the value of the nErrors property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNErrors() {
        if (nErrors == null) {
            return new BigInteger("0");
        } else {
            return nErrors;
        }
    }

    /**
     * Sets the value of the nErrors property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNErrors(BigInteger value) {
        this.nErrors = value;
    }

    /**
     * Gets the value of the nCheck property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNCheck() {
        if (nCheck == null) {
            return new BigInteger("0");
        } else {
            return nCheck;
        }
    }

    /**
     * Sets the value of the nCheck property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNCheck(BigInteger value) {
        this.nCheck = value;
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

    /**
     * Gets the value of the msCheck property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getMsCheck() {
        if (msCheck == null) {
            return new BigInteger("0");
        } else {
            return msCheck;
        }
    }

    /**
     * Sets the value of the msCheck property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setMsCheck(BigInteger value) {
        this.msCheck = value;
    }

    /**
     * Gets the value of the msErrors property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getMsErrors() {
        if (msErrors == null) {
            return new BigInteger("0");
        } else {
            return msErrors;
        }
    }

    /**
     * Sets the value of the msErrors property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setMsErrors(BigInteger value) {
        this.msErrors = value;
    }

    /**
     * Gets the value of the bytesIn property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getBytesIn() {
        if (bytesIn == null) {
            return new BigInteger("0");
        } else {
            return bytesIn;
        }
    }

    /**
     * Sets the value of the bytesIn property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setBytesIn(BigInteger value) {
        this.bytesIn = value;
    }

    /**
     * Gets the value of the bytesInCheck property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getBytesInCheck() {
        if (bytesInCheck == null) {
            return new BigInteger("0");
        } else {
            return bytesInCheck;
        }
    }

    /**
     * Sets the value of the bytesInCheck property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setBytesInCheck(BigInteger value) {
        this.bytesInCheck = value;
    }

    /**
     * Gets the value of the bytesInErrors property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getBytesInErrors() {
        if (bytesInErrors == null) {
            return new BigInteger("0");
        } else {
            return bytesInErrors;
        }
    }

    /**
     * Sets the value of the bytesInErrors property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setBytesInErrors(BigInteger value) {
        this.bytesInErrors = value;
    }

    /**
     * Gets the value of the bytesOut property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getBytesOut() {
        if (bytesOut == null) {
            return new BigInteger("0");
        } else {
            return bytesOut;
        }
    }

    /**
     * Sets the value of the bytesOut property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setBytesOut(BigInteger value) {
        this.bytesOut = value;
    }

}
