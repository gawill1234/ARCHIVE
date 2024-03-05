
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
 *         &lt;element ref="{urn:/velocity/objects}crawl-url"/>
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
    "crawlUrl"
})
@XmlRootElement(name = "crawl-extender-complete")
public class CrawlExtenderComplete {

    @XmlElement(name = "crawl-url", required = true)
    protected CrawlUrl crawlUrl;

    /**
     * Gets the value of the crawlUrl property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlUrl }
     *     
     */
    public CrawlUrl getCrawlUrl() {
        return crawlUrl;
    }

    /**
     * Sets the value of the crawlUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlUrl }
     *     
     */
    public void setCrawlUrl(CrawlUrl value) {
        this.crawlUrl = value;
    }

}
