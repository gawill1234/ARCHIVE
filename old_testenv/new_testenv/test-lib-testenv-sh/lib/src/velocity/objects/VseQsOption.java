
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
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
 *         &lt;element name="allow-ips" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="max-idle-threads" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="max-threads" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="min-idle-threads" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="port" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "allowIps",
    "maxIdleThreads",
    "maxThreads",
    "minIdleThreads",
    "port"
})
@XmlRootElement(name = "vse-qs-option")
public class VseQsOption {

    @XmlElement(name = "allow-ips", defaultValue = "127.0.0.1")
    protected String allowIps;
    @XmlElement(name = "max-idle-threads", defaultValue = "5")
    protected Integer maxIdleThreads;
    @XmlElement(name = "max-threads", defaultValue = "0")
    protected Integer maxThreads;
    @XmlElement(name = "min-idle-threads", defaultValue = "0")
    protected Integer minIdleThreads;
    @XmlElement(defaultValue = "7205")
    protected Integer port;

    /**
     * Gets the value of the allowIps property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAllowIps() {
        return allowIps;
    }

    /**
     * Sets the value of the allowIps property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAllowIps(String value) {
        this.allowIps = value;
    }

    /**
     * Gets the value of the maxIdleThreads property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxIdleThreads() {
        return maxIdleThreads;
    }

    /**
     * Sets the value of the maxIdleThreads property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxIdleThreads(Integer value) {
        this.maxIdleThreads = value;
    }

    /**
     * Gets the value of the maxThreads property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxThreads() {
        return maxThreads;
    }

    /**
     * Sets the value of the maxThreads property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxThreads(Integer value) {
        this.maxThreads = value;
    }

    /**
     * Gets the value of the minIdleThreads property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMinIdleThreads() {
        return minIdleThreads;
    }

    /**
     * Sets the value of the minIdleThreads property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMinIdleThreads(Integer value) {
        this.minIdleThreads = value;
    }

    /**
     * Gets the value of the port property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getPort() {
        return port;
    }

    /**
     * Sets the value of the port property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPort(Integer value) {
        this.port = value;
    }

}
