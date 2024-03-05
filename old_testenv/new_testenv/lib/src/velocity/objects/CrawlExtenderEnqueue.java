
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
 *         &lt;element ref="{urn:/velocity/objects}crawl-url"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-state"/>
 *       &lt;/choice>
 *       &lt;attribute name="url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlUrlOrCrawlState"
})
@XmlRootElement(name = "crawl-extender-enqueue")
public class CrawlExtenderEnqueue {

    @XmlElements({
        @XmlElement(name = "crawl-state", type = CrawlState.class),
        @XmlElement(name = "crawl-url", type = CrawlUrl.class)
    })
    protected List<Object> crawlUrlOrCrawlState;
    @XmlAttribute
    protected String url;

    /**
     * Gets the value of the crawlUrlOrCrawlState property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlUrlOrCrawlState property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlUrlOrCrawlState().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlState }
     * {@link CrawlUrl }
     * 
     * 
     */
    public List<Object> getCrawlUrlOrCrawlState() {
        if (crawlUrlOrCrawlState == null) {
            crawlUrlOrCrawlState = new ArrayList<Object>();
        }
        return this.crawlUrlOrCrawlState;
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

}
