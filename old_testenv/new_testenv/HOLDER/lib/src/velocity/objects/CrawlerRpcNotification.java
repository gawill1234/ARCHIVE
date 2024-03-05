
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
 *       &lt;attribute name="collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="counter" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="timestamp" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="delete" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="not-contiguous" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "crawler-rpc-notification")
public class CrawlerRpcNotification {

    @XmlAttribute
    protected String collection;
    @XmlAttribute
    protected Integer counter;
    @XmlAttribute
    protected Integer timestamp;
    @XmlAttribute
    protected String url;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String delete;
    @XmlAttribute(name = "not-contiguous")
    @XmlSchemaType(name = "anySimpleType")
    protected String notContiguous;

    /**
     * Gets the value of the collection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollection() {
        return collection;
    }

    /**
     * Sets the value of the collection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollection(String value) {
        this.collection = value;
    }

    /**
     * Gets the value of the counter property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCounter() {
        return counter;
    }

    /**
     * Sets the value of the counter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCounter(Integer value) {
        this.counter = value;
    }

    /**
     * Gets the value of the timestamp property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTimestamp() {
        return timestamp;
    }

    /**
     * Sets the value of the timestamp property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTimestamp(Integer value) {
        this.timestamp = value;
    }

    /**
     * Gets the value of the url property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrl() {
        return url;
    }

    /**
     * Sets the value of the url property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrl(String value) {
        this.url = value;
    }

    /**
     * Gets the value of the delete property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDelete() {
        return delete;
    }

    /**
     * Sets the value of the delete property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDelete(String value) {
        this.delete = value;
    }

    /**
     * Gets the value of the notContiguous property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNotContiguous() {
        return notContiguous;
    }

    /**
     * Sets the value of the notContiguous property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNotContiguous(String value) {
        this.notContiguous = value;
    }

}
