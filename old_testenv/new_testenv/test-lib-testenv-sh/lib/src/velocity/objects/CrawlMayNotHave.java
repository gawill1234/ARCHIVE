
package velocity.objects;

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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}crawl-pattern"/>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}crawl-condition"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}crawl-filter"/>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlPattern"
})
@XmlRootElement(name = "crawl-may-not-have")
public class CrawlMayNotHave {

    @XmlElement(name = "crawl-pattern", required = true)
    protected Object crawlPattern;
    @XmlAttribute
    protected String how;
    @XmlAttribute
    protected String field;
    @XmlAttribute(name = "custom-field")
    protected String customField;
    @XmlAttribute
    protected String log;

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

    /**
     * Gets the value of the log property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLog() {
        return log;
    }

    /**
     * Sets the value of the log property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLog(String value) {
        this.log = value;
    }

}
