
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}reconstructor-status" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}value-set-field" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="n-pending" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="priority" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="ms" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "reconstructorStatus",
    "valueSetField"
})
@XmlRootElement(name = "reconstructor-statuses")
public class ReconstructorStatuses {

    @XmlElement(name = "reconstructor-status")
    protected List<ReconstructorStatus> reconstructorStatus;
    @XmlElement(name = "value-set-field")
    protected List<ValueSetField> valueSetField;
    @XmlAttribute(name = "n-pending")
    protected Integer nPending;
    @XmlAttribute
    protected Integer priority;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger ms;

    /**
     * Gets the value of the reconstructorStatus property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the reconstructorStatus property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getReconstructorStatus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ReconstructorStatus }
     * 
     * 
     */
    public List<ReconstructorStatus> getReconstructorStatus() {
        if (reconstructorStatus == null) {
            reconstructorStatus = new ArrayList<ReconstructorStatus>();
        }
        return this.reconstructorStatus;
    }

    /**
     * Gets the value of the valueSetField property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the valueSetField property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getValueSetField().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ValueSetField }
     * 
     * 
     */
    public List<ValueSetField> getValueSetField() {
        if (valueSetField == null) {
            valueSetField = new ArrayList<ValueSetField>();
        }
        return this.valueSetField;
    }

    /**
     * Gets the value of the nPending property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNPending() {
        if (nPending == null) {
            return  0;
        } else {
            return nPending;
        }
    }

    /**
     * Sets the value of the nPending property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNPending(Integer value) {
        this.nPending = value;
    }

    /**
     * Gets the value of the priority property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getPriority() {
        if (priority == null) {
            return  0;
        } else {
            return priority;
        }
    }

    /**
     * Sets the value of the priority property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPriority(Integer value) {
        this.priority = value;
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
