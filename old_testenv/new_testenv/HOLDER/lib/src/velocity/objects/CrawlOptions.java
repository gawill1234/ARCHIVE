
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
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
 *         &lt;element ref="{urn:/velocity/objects}crawl-option"/>
 *         &lt;element ref="{urn:/velocity/objects}curl-option"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-extender-option" maxOccurs="unbounded"/>
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
    "crawlOption",
    "curlOption",
    "crawlExtenderOption"
})
@XmlRootElement(name = "crawl-options")
public class CrawlOptions {

    @XmlElement(name = "crawl-option", required = true)
    protected CrawlOption crawlOption;
    @XmlElement(name = "curl-option", required = true)
    protected CurlOption curlOption;
    @XmlElement(name = "crawl-extender-option", required = true)
    protected List<GenericOption> crawlExtenderOption;

    /**
     * Gets the value of the crawlOption property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlOption }
     *     
     */
    public CrawlOption getCrawlOption() {
        return crawlOption;
    }

    /**
     * Sets the value of the crawlOption property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlOption }
     *     
     */
    public void setCrawlOption(CrawlOption value) {
        this.crawlOption = value;
    }

    /**
     * Gets the value of the curlOption property.
     * 
     * @return
     *     possible object is
     *     {@link CurlOption }
     *     
     */
    public CurlOption getCurlOption() {
        return curlOption;
    }

    /**
     * Sets the value of the curlOption property.
     * 
     * @param value
     *     allowed object is
     *     {@link CurlOption }
     *     
     */
    public void setCurlOption(CurlOption value) {
        this.curlOption = value;
    }

    /**
     * Gets the value of the crawlExtenderOption property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlExtenderOption property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlExtenderOption().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link GenericOption }
     * 
     * 
     */
    public List<GenericOption> getCrawlExtenderOption() {
        if (crawlExtenderOption == null) {
            crawlExtenderOption = new ArrayList<GenericOption>();
        }
        return this.crawlExtenderOption;
    }

}
