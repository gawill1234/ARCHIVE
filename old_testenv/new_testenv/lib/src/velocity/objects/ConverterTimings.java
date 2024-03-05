
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}converter-timing" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="total-ms" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "converterTiming"
})
@XmlRootElement(name = "converter-timings")
public class ConverterTimings {

    @XmlElement(name = "converter-timing")
    protected List<ConverterTiming> converterTiming;
    @XmlAttribute(name = "total-ms")
    protected String totalMs;

    /**
     * Gets the value of the converterTiming property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the converterTiming property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getConverterTiming().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ConverterTiming }
     * 
     * 
     */
    public List<ConverterTiming> getConverterTiming() {
        if (converterTiming == null) {
            converterTiming = new ArrayList<ConverterTiming>();
        }
        return this.converterTiming;
    }

    /**
     * Gets the value of the totalMs property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTotalMs() {
        return totalMs;
    }

    /**
     * Sets the value of the totalMs property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTotalMs(String value) {
        this.totalMs = value;
    }

}
