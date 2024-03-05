
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
 *       &lt;attribute name="port" use="required" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="ping" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="n-queries" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-cached-queries" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-pings" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="ms-queries" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-documents" type="{http://www.w3.org/2001/XMLSchema}double" default="0" />
 *       &lt;attribute name="n-no-documents" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-threads" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-idle-threads" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="q-p-s-1" type="{http://www.w3.org/2001/XMLSchema}double" default="0" />
 *       &lt;attribute name="q-p-s-5" type="{http://www.w3.org/2001/XMLSchema}double" default="0" />
 *       &lt;attribute name="q-p-s-15" type="{http://www.w3.org/2001/XMLSchema}double" default="0" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "vse-serving")
public class VseServing {

    @XmlAttribute(required = true)
    protected int port;
    @XmlAttribute
    protected String ping;
    @XmlAttribute(name = "n-queries")
    protected Integer nQueries;
    @XmlAttribute(name = "n-cached-queries")
    protected Integer nCachedQueries;
    @XmlAttribute(name = "n-pings")
    protected Integer nPings;
    @XmlAttribute(name = "ms-queries")
    protected Integer msQueries;
    @XmlAttribute(name = "n-documents")
    protected Double nDocuments;
    @XmlAttribute(name = "n-no-documents")
    protected Integer nNoDocuments;
    @XmlAttribute(name = "n-threads")
    protected Integer nThreads;
    @XmlAttribute(name = "n-idle-threads")
    protected Integer nIdleThreads;
    @XmlAttribute(name = "q-p-s-1")
    protected Double qps1;
    @XmlAttribute(name = "q-p-s-5")
    protected Double qps5;
    @XmlAttribute(name = "q-p-s-15")
    protected Double qps15;

    /**
     * Gets the value of the port property.
     * 
     */
    public int getPort() {
        return port;
    }

    /**
     * Sets the value of the port property.
     * 
     */
    public void setPort(int value) {
        this.port = value;
    }

    /**
     * Gets the value of the ping property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPing() {
        return ping;
    }

    /**
     * Sets the value of the ping property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPing(String value) {
        this.ping = value;
    }

    /**
     * Gets the value of the nQueries property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNQueries() {
        if (nQueries == null) {
            return  0;
        } else {
            return nQueries;
        }
    }

    /**
     * Sets the value of the nQueries property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNQueries(Integer value) {
        this.nQueries = value;
    }

    /**
     * Gets the value of the nCachedQueries property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNCachedQueries() {
        if (nCachedQueries == null) {
            return  0;
        } else {
            return nCachedQueries;
        }
    }

    /**
     * Sets the value of the nCachedQueries property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNCachedQueries(Integer value) {
        this.nCachedQueries = value;
    }

    /**
     * Gets the value of the nPings property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNPings() {
        if (nPings == null) {
            return  0;
        } else {
            return nPings;
        }
    }

    /**
     * Sets the value of the nPings property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNPings(Integer value) {
        this.nPings = value;
    }

    /**
     * Gets the value of the msQueries property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMsQueries() {
        if (msQueries == null) {
            return  0;
        } else {
            return msQueries;
        }
    }

    /**
     * Sets the value of the msQueries property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMsQueries(Integer value) {
        this.msQueries = value;
    }

    /**
     * Gets the value of the nDocuments property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getNDocuments() {
        if (nDocuments == null) {
            return  0.0D;
        } else {
            return nDocuments;
        }
    }

    /**
     * Sets the value of the nDocuments property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setNDocuments(Double value) {
        this.nDocuments = value;
    }

    /**
     * Gets the value of the nNoDocuments property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNNoDocuments() {
        if (nNoDocuments == null) {
            return  0;
        } else {
            return nNoDocuments;
        }
    }

    /**
     * Sets the value of the nNoDocuments property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNNoDocuments(Integer value) {
        this.nNoDocuments = value;
    }

    /**
     * Gets the value of the nThreads property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNThreads() {
        if (nThreads == null) {
            return  0;
        } else {
            return nThreads;
        }
    }

    /**
     * Sets the value of the nThreads property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNThreads(Integer value) {
        this.nThreads = value;
    }

    /**
     * Gets the value of the nIdleThreads property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNIdleThreads() {
        if (nIdleThreads == null) {
            return  0;
        } else {
            return nIdleThreads;
        }
    }

    /**
     * Sets the value of the nIdleThreads property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNIdleThreads(Integer value) {
        this.nIdleThreads = value;
    }

    /**
     * Gets the value of the qps1 property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getQPS1() {
        if (qps1 == null) {
            return  0.0D;
        } else {
            return qps1;
        }
    }

    /**
     * Sets the value of the qps1 property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setQPS1(Double value) {
        this.qps1 = value;
    }

    /**
     * Gets the value of the qps5 property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getQPS5() {
        if (qps5 == null) {
            return  0.0D;
        } else {
            return qps5;
        }
    }

    /**
     * Sets the value of the qps5 property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setQPS5(Double value) {
        this.qps5 = value;
    }

    /**
     * Gets the value of the qps15 property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public double getQPS15() {
        if (qps15 == null) {
            return  0.0D;
        } else {
            return qps15;
        }
    }

    /**
     * Sets the value of the qps15 property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setQPS15(Double value) {
        this.qps15 = value;
    }

}
