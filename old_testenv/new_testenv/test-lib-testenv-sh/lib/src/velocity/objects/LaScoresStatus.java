
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
 *       &lt;attribute name="pct" type="{http://www.w3.org/2001/XMLSchema}double" default="0" />
 *       &lt;attribute name="start" use="required" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="end" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "la-scores-status")
public class LaScoresStatus {

    @XmlAttribute
    protected Double pct;
    @XmlAttribute(required = true)
    protected int start;
    @XmlAttribute
    protected Integer end;

    /**
     * Gets the value of the pct property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getPct() {
        if (pct == null) {
            return  0.0D;
        } else {
            return pct;
        }
    }

    /**
     * Sets the value of the pct property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setPct(Double value) {
        this.pct = value;
    }

    /**
     * Gets the value of the start property.
     * 
     */
    public int getStart() {
        return start;
    }

    /**
     * Sets the value of the start property.
     * 
     */
    public void setStart(int value) {
        this.start = value;
    }

    /**
     * Gets the value of the end property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEnd() {
        return end;
    }

    /**
     * Sets the value of the end property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEnd(Integer value) {
        this.end = value;
    }

}
