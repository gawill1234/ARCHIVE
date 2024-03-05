
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
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
 *       &lt;choice maxOccurs="unbounded">
 *         &lt;element ref="{urn:/velocity/objects}crawler-rpc-range"/>
 *       &lt;/choice>
 *       &lt;attribute name="collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlerRpcRange"
})
@XmlRootElement(name = "crawler-rpc-applied")
public class CrawlerRpcApplied {

    @XmlElement(name = "crawler-rpc-range")
    protected List<CrawlerRpcRange> crawlerRpcRange;
    @XmlAttribute
    protected String collection;

    /**
     * Gets the value of the crawlerRpcRange property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlerRpcRange property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlerRpcRange().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlerRpcRange }
     * 
     * 
     */
    public List<CrawlerRpcRange> getCrawlerRpcRange() {
        if (crawlerRpcRange == null) {
            crawlerRpcRange = new ArrayList<CrawlerRpcRange>();
        }
        return this.crawlerRpcRange;
    }

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

}
