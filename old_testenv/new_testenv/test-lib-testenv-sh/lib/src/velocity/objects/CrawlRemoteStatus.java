
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
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="current" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="serve-from" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="serve-to" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="crawl-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "crawl-remote-status")
public class CrawlRemoteStatus {

    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String name;
    @XmlAttribute
    protected Long current;
    @XmlAttribute(name = "serve-from")
    protected Long serveFrom;
    @XmlAttribute(name = "serve-to")
    protected Long serveTo;
    @XmlAttribute(name = "crawl-id")
    protected String crawlId;

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
     * Gets the value of the current property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getCurrent() {
        return current;
    }

    /**
     * Sets the value of the current property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setCurrent(Long value) {
        this.current = value;
    }

    /**
     * Gets the value of the serveFrom property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getServeFrom() {
        return serveFrom;
    }

    /**
     * Sets the value of the serveFrom property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setServeFrom(Long value) {
        this.serveFrom = value;
    }

    /**
     * Gets the value of the serveTo property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getServeTo() {
        return serveTo;
    }

    /**
     * Sets the value of the serveTo property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setServeTo(Long value) {
        this.serveTo = value;
    }

    /**
     * Gets the value of the crawlId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCrawlId() {
        return crawlId;
    }

    /**
     * Sets the value of the crawlId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCrawlId(String value) {
        this.crawlId = value;
    }

}
