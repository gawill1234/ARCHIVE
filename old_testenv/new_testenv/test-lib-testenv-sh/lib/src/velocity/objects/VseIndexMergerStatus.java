
package velocity.objects;

import java.math.BigInteger;
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
 *       &lt;sequence maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}vse-index-merge-status"/>
 *       &lt;/sequence>
 *       &lt;attribute name="total-ms" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *       &lt;attribute name="min-size" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="max-size" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseIndexMergeStatus"
})
@XmlRootElement(name = "vse-index-merger-status")
public class VseIndexMergerStatus {

    @XmlElement(name = "vse-index-merge-status")
    protected List<VseIndexMergeStatus> vseIndexMergeStatus;
    @XmlAttribute(name = "total-ms")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger totalMs;
    @XmlAttribute(name = "min-size")
    protected Integer minSize;
    @XmlAttribute(name = "max-size")
    protected Integer maxSize;

    /**
     * Gets the value of the vseIndexMergeStatus property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseIndexMergeStatus property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseIndexMergeStatus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseIndexMergeStatus }
     * 
     * 
     */
    public List<VseIndexMergeStatus> getVseIndexMergeStatus() {
        if (vseIndexMergeStatus == null) {
            vseIndexMergeStatus = new ArrayList<VseIndexMergeStatus>();
        }
        return this.vseIndexMergeStatus;
    }

    /**
     * Gets the value of the totalMs property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getTotalMs() {
        if (totalMs == null) {
            return new BigInteger("0");
        } else {
            return totalMs;
        }
    }

    /**
     * Sets the value of the totalMs property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setTotalMs(BigInteger value) {
        this.totalMs = value;
    }

    /**
     * Gets the value of the minSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMinSize() {
        return minSize;
    }

    /**
     * Sets the value of the minSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMinSize(Integer value) {
        this.minSize = value;
    }

    /**
     * Gets the value of the maxSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxSize() {
        return maxSize;
    }

    /**
     * Sets the value of the maxSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxSize(Integer value) {
        this.maxSize = value;
    }

}
