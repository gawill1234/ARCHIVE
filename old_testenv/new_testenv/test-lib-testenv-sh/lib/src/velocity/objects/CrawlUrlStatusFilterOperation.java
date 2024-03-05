
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
 *       &lt;sequence maxOccurs="unbounded">
 *         &lt;element ref="{urn:/velocity/objects}crawl-url-status-filter-operation"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-url-status-filter"/>
 *       &lt;/sequence>
 *       &lt;attribute name="name">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="and"/>
 *             &lt;enumeration value="or"/>
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
    "crawlUrlStatusFilterOperationAndCrawlUrlStatusFilter"
})
@XmlRootElement(name = "crawl-url-status-filter-operation")
public class CrawlUrlStatusFilterOperation {

    @XmlElements({
        @XmlElement(name = "crawl-url-status-filter-operation", required = true, type = CrawlUrlStatusFilterOperation.class),
        @XmlElement(name = "crawl-url-status-filter", required = true, type = CrawlUrlStatusFilter.class)
    })
    protected List<Object> crawlUrlStatusFilterOperationAndCrawlUrlStatusFilter;
    @XmlAttribute
    protected String name;

    /**
     * Gets the value of the crawlUrlStatusFilterOperationAndCrawlUrlStatusFilter property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlUrlStatusFilterOperationAndCrawlUrlStatusFilter property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlUrlStatusFilterOperationAndCrawlUrlStatusFilter().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlUrlStatusFilterOperation }
     * {@link CrawlUrlStatusFilter }
     * 
     * 
     */
    public List<Object> getCrawlUrlStatusFilterOperationAndCrawlUrlStatusFilter() {
        if (crawlUrlStatusFilterOperationAndCrawlUrlStatusFilter == null) {
            crawlUrlStatusFilterOperationAndCrawlUrlStatusFilter = new ArrayList<Object>();
        }
        return this.crawlUrlStatusFilterOperationAndCrawlUrlStatusFilter;
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

}
