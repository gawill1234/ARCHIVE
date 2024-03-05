
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
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
 *       &lt;choice maxOccurs="unbounded">
 *         &lt;element ref="{urn:/velocity/objects}crawler-rpc-available"/>
 *         &lt;element ref="{urn:/velocity/objects}crawler-rpc-request"/>
 *         &lt;element ref="{urn:/velocity/objects}crawler-rpc-applied"/>
 *       &lt;/choice>
 *       &lt;attribute name="name">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="ping"/>
 *             &lt;enumeration value="available"/>
 *             &lt;enumeration value="applied"/>
 *             &lt;enumeration value="request"/>
 *             &lt;enumeration value="update"/>
 *             &lt;enumeration value="notification"/>
 *             &lt;enumeration value="identify"/>
 *             &lt;enumeration value="rebase"/>
 *             &lt;enumeration value="export-blob"/>
 *             &lt;enumeration value="goodbye"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="reply">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="success"/>
 *             &lt;enumeration value="partial"/>
 *             &lt;enumeration value="failure"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlerRpcAvailableOrCrawlerRpcRequestOrCrawlerRpcApplied"
})
@XmlRootElement(name = "crawler-rpc")
public class CrawlerRpc {

    @XmlElements({
        @XmlElement(name = "crawler-rpc-available", type = CrawlerRpcAvailable.class),
        @XmlElement(name = "crawler-rpc-request", type = CrawlerRpcRequest.class),
        @XmlElement(name = "crawler-rpc-applied", type = CrawlerRpcApplied.class)
    })
    protected List<Object> crawlerRpcAvailableOrCrawlerRpcRequestOrCrawlerRpcApplied;
    @XmlAttribute
    protected String name;
    @XmlAttribute
    protected Integer id;
    @XmlAttribute
    protected String reply;

    /**
     * Gets the value of the crawlerRpcAvailableOrCrawlerRpcRequestOrCrawlerRpcApplied property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlerRpcAvailableOrCrawlerRpcRequestOrCrawlerRpcApplied property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlerRpcAvailableOrCrawlerRpcRequestOrCrawlerRpcApplied().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlerRpcAvailable }
     * {@link CrawlerRpcRequest }
     * {@link CrawlerRpcApplied }
     * 
     * 
     */
    public List<Object> getCrawlerRpcAvailableOrCrawlerRpcRequestOrCrawlerRpcApplied() {
        if (crawlerRpcAvailableOrCrawlerRpcRequestOrCrawlerRpcApplied == null) {
            crawlerRpcAvailableOrCrawlerRpcRequestOrCrawlerRpcApplied = new ArrayList<Object>();
        }
        return this.crawlerRpcAvailableOrCrawlerRpcRequestOrCrawlerRpcApplied;
    }

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
     * Gets the value of the id property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getId() {
        return id;
    }

    /**
     * Sets the value of the id property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setId(Integer value) {
        this.id = value;
    }

    /**
     * Gets the value of the reply property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReply() {
        return reply;
    }

    /**
     * Sets the value of the reply property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReply(String value) {
        this.reply = value;
    }

}
