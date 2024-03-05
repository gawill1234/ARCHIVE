
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
 *       &lt;group ref="{urn:/velocity/objects}crawl-condition-children"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}crawl-condition"/>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlPattern",
    "curlOptions",
    "crawlReplace",
    "crawlConditionWhenOrCrawlConditionExceptOrCrawlMustHave"
})
@XmlRootElement(name = "crawl-condition-when")
public class CrawlConditionWhen {

    @XmlElement(name = "crawl-pattern", required = true)
    protected Object crawlPattern;
    @XmlElement(name = "curl-options", required = true)
    protected CurlOptions curlOptions;
    @XmlElement(name = "crawl-replace")
    protected List<CrawlReplace> crawlReplace;
    @XmlElements({
        @XmlElement(name = "crawl-condition-when", type = CrawlConditionWhen.class),
        @XmlElement(name = "crawl-may-not-have", type = CrawlMayNotHave.class),
        @XmlElement(name = "crawl-must-have", type = CrawlMustHave.class),
        @XmlElement(name = "crawl-condition-except", type = CrawlConditionExcept.class)
    })
    protected List<Object> crawlConditionWhenOrCrawlConditionExceptOrCrawlMustHave;
    @XmlAttribute
    protected String how;
    @XmlAttribute
    protected String field;
    @XmlAttribute(name = "custom-field")
    protected String customField;

    /**
     * Gets the value of the crawlPattern property.
     * 
     * @return
     *     possible object is
     *     {@link Object }
     *     
     */
    public Object getCrawlPattern() {
        return crawlPattern;
    }

    /**
     * Sets the value of the crawlPattern property.
     * 
     * @param value
     *     allowed object is
     *     {@link Object }
     *     
     */
    public void setCrawlPattern(Object value) {
        this.crawlPattern = value;
    }

    /**
     * Gets the value of the curlOptions property.
     * 
     * @return
     *     possible object is
     *     {@link CurlOptions }
     *     
     */
    public CurlOptions getCurlOptions() {
        return curlOptions;
    }

    /**
     * Sets the value of the curlOptions property.
     * 
     * @param value
     *     allowed object is
     *     {@link CurlOptions }
     *     
     */
    public void setCurlOptions(CurlOptions value) {
        this.curlOptions = value;
    }

    /**
     * Gets the value of the crawlReplace property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlReplace property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlReplace().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlReplace }
     * 
     * 
     */
    public List<CrawlReplace> getCrawlReplace() {
        if (crawlReplace == null) {
            crawlReplace = new ArrayList<CrawlReplace>();
        }
        return this.crawlReplace;
    }

    /**
     * Gets the value of the crawlConditionWhenOrCrawlConditionExceptOrCrawlMustHave property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlConditionWhenOrCrawlConditionExceptOrCrawlMustHave property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlConditionWhenOrCrawlConditionExceptOrCrawlMustHave().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlConditionWhen }
     * {@link CrawlMayNotHave }
     * {@link CrawlMustHave }
     * {@link CrawlConditionExcept }
     * 
     * 
     */
    public List<Object> getCrawlConditionWhenOrCrawlConditionExceptOrCrawlMustHave() {
        if (crawlConditionWhenOrCrawlConditionExceptOrCrawlMustHave == null) {
            crawlConditionWhenOrCrawlConditionExceptOrCrawlMustHave = new ArrayList<Object>();
        }
        return this.crawlConditionWhenOrCrawlConditionExceptOrCrawlMustHave;
    }

    /**
     * Gets the value of the how property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHow() {
        if (how == null) {
            return "wc-set";
        } else {
            return how;
        }
    }

    /**
     * Sets the value of the how property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHow(String value) {
        this.how = value;
    }

    /**
     * Gets the value of the field property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getField() {
        if (field == null) {
            return "url";
        } else {
            return field;
        }
    }

    /**
     * Sets the value of the field property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setField(String value) {
        this.field = value;
    }

    /**
     * Gets the value of the customField property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCustomField() {
        return customField;
    }

    /**
     * Sets the value of the customField property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCustomField(String value) {
        this.customField = value;
    }

}
