
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
 *       &lt;attribute name="n-segments" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-indices" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="to-read" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="read" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="written" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="start" use="required" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *       &lt;attribute name="end" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *       &lt;attribute name="total-ms" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "vse-index-merge-status")
public class VseIndexMergeStatus {

    @XmlAttribute(name = "n-segments")
    protected Integer nSegments;
    @XmlAttribute(name = "n-indices")
    protected Integer nIndices;
    @XmlAttribute(name = "to-read")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger toRead;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger read;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger written;
    @XmlAttribute(required = true)
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger start;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger end;
    @XmlAttribute(name = "total-ms")
    protected Integer totalMs;

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
     * Gets the value of the nIndices property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNIndices() {
        if (nIndices == null) {
            return  0;
        } else {
            return nIndices;
        }
    }

    /**
     * Sets the value of the nIndices property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNIndices(Integer value) {
        this.nIndices = value;
    }

    /**
     * Gets the value of the toRead property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getToRead() {
        if (toRead == null) {
            return new BigInteger("0");
        } else {
            return toRead;
        }
    }

    /**
     * Sets the value of the toRead property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setToRead(BigInteger value) {
        this.toRead = value;
    }

    /**
     * Gets the value of the read property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getRead() {
        if (read == null) {
            return new BigInteger("0");
        } else {
            return read;
        }
    }

    /**
     * Sets the value of the read property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setRead(BigInteger value) {
        this.read = value;
    }

    /**
     * Gets the value of the written property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getWritten() {
        if (written == null) {
            return new BigInteger("0");
        } else {
            return written;
        }
    }

    /**
     * Sets the value of the written property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setWritten(BigInteger value) {
        this.written = value;
    }

    /**
     * Gets the value of the start property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getStart() {
        return start;
    }

    /**
     * Sets the value of the start property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setStart(BigInteger value) {
        this.start = value;
    }

    /**
     * Gets the value of the end property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getEnd() {
        return end;
    }

    /**
     * Sets the value of the end property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setEnd(BigInteger value) {
        this.end = value;
    }

    /**
     * Gets the value of the totalMs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getTotalMs() {
        if (totalMs == null) {
            return  0;
        } else {
            return totalMs;
        }
    }

    /**
     * Sets the value of the totalMs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTotalMs(Integer value) {
        this.totalMs = value;
    }

}
