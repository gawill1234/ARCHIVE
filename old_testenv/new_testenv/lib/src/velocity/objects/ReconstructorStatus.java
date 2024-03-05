
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
 *       &lt;attribute name="n-to-do" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-done" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
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
@XmlRootElement(name = "reconstructor-status")
public class ReconstructorStatus {

    @XmlAttribute(name = "n-to-do")
    protected Integer nToDo;
    @XmlAttribute(name = "n-done")
    protected Integer nDone;
    @XmlAttribute(required = true)
    protected int start;
    @XmlAttribute
    protected Integer end;

    /**
     * Gets the value of the nToDo property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNToDo() {
        if (nToDo == null) {
            return  0;
        } else {
            return nToDo;
        }
    }

    /**
     * Sets the value of the nToDo property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNToDo(Integer value) {
        this.nToDo = value;
    }

    /**
     * Gets the value of the nDone property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNDone() {
        if (nDone == null) {
            return  0;
        } else {
            return nDone;
        }
    }

    /**
     * Sets the value of the nDone property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNDone(Integer value) {
        this.nDone = value;
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
