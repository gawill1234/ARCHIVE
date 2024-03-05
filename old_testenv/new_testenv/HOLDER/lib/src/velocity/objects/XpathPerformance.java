
package velocity.objects;

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
 *       &lt;attribute name="xpath" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="slow-ms" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-slow" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-fast" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-direct" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-hashes" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "xpath-performance")
public class XpathPerformance {

    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String xpath;
    @XmlAttribute(name = "slow-ms")
    protected Integer slowMs;
    @XmlAttribute(name = "n-slow")
    protected Integer nSlow;
    @XmlAttribute(name = "n-fast")
    protected Integer nFast;
    @XmlAttribute(name = "n-direct")
    protected Integer nDirect;
    @XmlAttribute(name = "n-hashes")
    protected Integer nHashes;

    /**
     * Gets the value of the xpath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getXpath() {
        return xpath;
    }

    /**
     * Sets the value of the xpath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setXpath(String value) {
        this.xpath = value;
    }

    /**
     * Gets the value of the slowMs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getSlowMs() {
        return slowMs;
    }

    /**
     * Sets the value of the slowMs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setSlowMs(Integer value) {
        this.slowMs = value;
    }

    /**
     * Gets the value of the nSlow property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNSlow() {
        return nSlow;
    }

    /**
     * Sets the value of the nSlow property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNSlow(Integer value) {
        this.nSlow = value;
    }

    /**
     * Gets the value of the nFast property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNFast() {
        return nFast;
    }

    /**
     * Sets the value of the nFast property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNFast(Integer value) {
        this.nFast = value;
    }

    /**
     * Gets the value of the nDirect property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNDirect() {
        return nDirect;
    }

    /**
     * Sets the value of the nDirect property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNDirect(Integer value) {
        this.nDirect = value;
    }

    /**
     * Gets the value of the nHashes property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNHashes() {
        return nHashes;
    }

    /**
     * Sets the value of the nHashes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNHashes(Integer value) {
        this.nHashes = value;
    }

}
