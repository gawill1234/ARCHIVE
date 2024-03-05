
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="n" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="size" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="total-insert" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-entering" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-producers" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="max-idle" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="percent-idle" type="{http://www.w3.org/2001/XMLSchema}float" default="0.0" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "request-queue")
public class RequestQueue {

    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String name;
    @XmlAttribute
    protected Integer n;
    @XmlAttribute
    protected Integer size;
    @XmlAttribute(name = "total-insert")
    protected Integer totalInsert;
    @XmlAttribute(name = "n-entering")
    protected Integer nEntering;
    @XmlAttribute(name = "n-producers")
    protected Integer nProducers;
    @XmlAttribute(name = "max-idle")
    protected Integer maxIdle;
    @XmlAttribute(name = "percent-idle")
    protected Float percentIdle;

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
     * Gets the value of the n property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getN() {
        if (n == null) {
            return  0;
        } else {
            return n;
        }
    }

    /**
     * Sets the value of the n property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setN(Integer value) {
        this.n = value;
    }

    /**
     * Gets the value of the size property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getSize() {
        if (size == null) {
            return  0;
        } else {
            return size;
        }
    }

    /**
     * Sets the value of the size property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setSize(Integer value) {
        this.size = value;
    }

    /**
     * Gets the value of the totalInsert property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getTotalInsert() {
        if (totalInsert == null) {
            return  0;
        } else {
            return totalInsert;
        }
    }

    /**
     * Sets the value of the totalInsert property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTotalInsert(Integer value) {
        this.totalInsert = value;
    }

    /**
     * Gets the value of the nEntering property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNEntering() {
        if (nEntering == null) {
            return  0;
        } else {
            return nEntering;
        }
    }

    /**
     * Sets the value of the nEntering property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNEntering(Integer value) {
        this.nEntering = value;
    }

    /**
     * Gets the value of the nProducers property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNProducers() {
        if (nProducers == null) {
            return  0;
        } else {
            return nProducers;
        }
    }

    /**
     * Sets the value of the nProducers property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNProducers(Integer value) {
        this.nProducers = value;
    }

    /**
     * Gets the value of the maxIdle property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMaxIdle() {
        if (maxIdle == null) {
            return  0;
        } else {
            return maxIdle;
        }
    }

    /**
     * Sets the value of the maxIdle property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxIdle(Integer value) {
        this.maxIdle = value;
    }

    /**
     * Gets the value of the percentIdle property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public float getPercentIdle() {
        if (percentIdle == null) {
            return  0.0F;
        } else {
            return percentIdle;
        }
    }

    /**
     * Sets the value of the percentIdle property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setPercentIdle(Float value) {
        this.percentIdle = value;
    }

}
