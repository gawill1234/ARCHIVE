
package velocity.objects;

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
 *         &lt;element ref="{urn:/velocity/objects}scope"/>
 *       &lt;/sequence>
 *       &lt;attribute name="high" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="low" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="interval" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="label" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="br-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="number-label-xpath" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="number-label-connector" type="{http://www.w3.org/2001/XMLSchema}string" default=" - " />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "scope"
})
@XmlRootElement(name = "binning-range")
public class BinningRange {

    @XmlElement(required = true)
    protected Scope scope;
    @XmlAttribute
    protected Double high;
    @XmlAttribute
    protected Double low;
    @XmlAttribute
    protected Double interval;
    @XmlAttribute
    protected String label;
    @XmlAttribute(name = "br-id")
    protected String brId;
    @XmlAttribute(name = "number-label-xpath")
    protected String numberLabelXpath;
    @XmlAttribute(name = "number-label-connector")
    protected String numberLabelConnector;

    /**
     * Gets the value of the scope property.
     * 
     * @return
     *     possible object is
     *     {@link Scope }
     *     
     */
    public Scope getScope() {
        return scope;
    }

    /**
     * Sets the value of the scope property.
     * 
     * @param value
     *     allowed object is
     *     {@link Scope }
     *     
     */
    public void setScope(Scope value) {
        this.scope = value;
    }

    /**
     * Gets the value of the high property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getHigh() {
        return high;
    }

    /**
     * Sets the value of the high property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setHigh(Double value) {
        this.high = value;
    }

    /**
     * Gets the value of the low property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getLow() {
        return low;
    }

    /**
     * Sets the value of the low property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setLow(Double value) {
        this.low = value;
    }

    /**
     * Gets the value of the interval property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getInterval() {
        return interval;
    }

    /**
     * Sets the value of the interval property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setInterval(Double value) {
        this.interval = value;
    }

    /**
     * Gets the value of the label property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLabel() {
        return label;
    }

    /**
     * Sets the value of the label property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLabel(String value) {
        this.label = value;
    }

    /**
     * Gets the value of the brId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBrId() {
        return brId;
    }

    /**
     * Sets the value of the brId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBrId(String value) {
        this.brId = value;
    }

    /**
     * Gets the value of the numberLabelXpath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNumberLabelXpath() {
        return numberLabelXpath;
    }

    /**
     * Sets the value of the numberLabelXpath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNumberLabelXpath(String value) {
        this.numberLabelXpath = value;
    }

    /**
     * Gets the value of the numberLabelConnector property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNumberLabelConnector() {
        if (numberLabelConnector == null) {
            return " - ";
        } else {
            return numberLabelConnector;
        }
    }

    /**
     * Sets the value of the numberLabelConnector property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNumberLabelConnector(String value) {
        this.numberLabelConnector = value;
    }

}
