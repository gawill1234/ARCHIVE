
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}crawl-url-status-filter-operation"/>
 *       &lt;/sequence>
 *       &lt;attribute name="limit" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="offset" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlUrlStatusFilterOperation"
})
@XmlRootElement(name = "crawl-url-status")
public class CrawlUrlStatus {

    @XmlElement(name = "crawl-url-status-filter-operation", required = true)
    protected CrawlUrlStatusFilterOperation crawlUrlStatusFilterOperation;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long limit;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long offset;

    /**
     * Gets the value of the crawlUrlStatusFilterOperation property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlUrlStatusFilterOperation }
     *     
     */
    public CrawlUrlStatusFilterOperation getCrawlUrlStatusFilterOperation() {
        return crawlUrlStatusFilterOperation;
    }

    /**
     * Sets the value of the crawlUrlStatusFilterOperation property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlUrlStatusFilterOperation }
     *     
     */
    public void setCrawlUrlStatusFilterOperation(CrawlUrlStatusFilterOperation value) {
        this.crawlUrlStatusFilterOperation = value;
    }

    /**
     * Gets the value of the limit property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getLimit() {
        return limit;
    }

    /**
     * Sets the value of the limit property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setLimit(Long value) {
        this.limit = value;
    }

    /**
     * Gets the value of the offset property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOffset() {
        return offset;
    }

    /**
     * Sets the value of the offset property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOffset(Long value) {
        this.offset = value;
    }

}
