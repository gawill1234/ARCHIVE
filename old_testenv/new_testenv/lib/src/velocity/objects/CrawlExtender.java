
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
 *         &lt;element ref="{urn:/velocity/objects}crawl-extender-option"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-state"/>
 *       &lt;/sequence>
 *       &lt;attribute name="protocol" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="exec" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="dns">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="dns"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="continuous-update-mode">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="continuous-update-mode"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="always-run">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="always-run"/>
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
    "crawlExtenderOptionAndCrawlState"
})
@XmlRootElement(name = "crawl-extender")
public class CrawlExtender {

    @XmlElements({
        @XmlElement(name = "crawl-extender-option", required = true, type = GenericOption.class),
        @XmlElement(name = "crawl-state", required = true, type = CrawlState.class)
    })
    protected List<Object> crawlExtenderOptionAndCrawlState;
    @XmlAttribute
    protected String protocol;
    @XmlAttribute
    protected String exec;
    @XmlAttribute
    protected String dns;
    @XmlAttribute(name = "continuous-update-mode")
    protected String continuousUpdateMode;
    @XmlAttribute(name = "always-run")
    protected String alwaysRun;

    /**
     * Gets the value of the crawlExtenderOptionAndCrawlState property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlExtenderOptionAndCrawlState property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlExtenderOptionAndCrawlState().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link GenericOption }
     * {@link CrawlState }
     * 
     * 
     */
    public List<Object> getCrawlExtenderOptionAndCrawlState() {
        if (crawlExtenderOptionAndCrawlState == null) {
            crawlExtenderOptionAndCrawlState = new ArrayList<Object>();
        }
        return this.crawlExtenderOptionAndCrawlState;
    }

    /**
     * Gets the value of the protocol property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProtocol() {
        return protocol;
    }

    /**
     * Sets the value of the protocol property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProtocol(String value) {
        this.protocol = value;
    }

    /**
     * Gets the value of the exec property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExec() {
        return exec;
    }

    /**
     * Sets the value of the exec property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExec(String value) {
        this.exec = value;
    }

    /**
     * Gets the value of the dns property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDns() {
        return dns;
    }

    /**
     * Sets the value of the dns property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDns(String value) {
        this.dns = value;
    }

    /**
     * Gets the value of the continuousUpdateMode property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getContinuousUpdateMode() {
        return continuousUpdateMode;
    }

    /**
     * Sets the value of the continuousUpdateMode property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setContinuousUpdateMode(String value) {
        this.continuousUpdateMode = value;
    }

    /**
     * Gets the value of the alwaysRun property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAlwaysRun() {
        return alwaysRun;
    }

    /**
     * Sets the value of the alwaysRun property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAlwaysRun(String value) {
        this.alwaysRun = value;
    }

}
