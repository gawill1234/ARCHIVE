
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}crawl-options" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-urls" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}scope" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;group ref="{urn:/velocity/objects}crawl-conditions" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-extender" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="log-file" type="{http://www.w3.org/2001/XMLSchema}string" default="crawler.log" />
 *       &lt;attribute name="run-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="subcollection">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="live"/>
 *             &lt;enumeration value="staging"/>
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
    "crawlOptions",
    "crawlUrls",
    "scope",
    "crawlConditions",
    "crawlExtender"
})
@XmlRootElement(name = "crawler")
public class Crawler {

    @XmlElement(name = "crawl-options")
    protected CrawlOptions crawlOptions;
    @XmlElement(name = "crawl-urls")
    protected List<CrawlUrls> crawlUrls;
    protected List<Scope> scope;
    @XmlElements({
        @XmlElement(name = "crawl-condition-when", type = CrawlConditionWhen.class),
        @XmlElement(name = "crawl-must-have", type = CrawlMustHave.class),
        @XmlElement(name = "crawl-may-not-have", type = CrawlMayNotHave.class),
        @XmlElement(name = "crawl-condition-except", type = CrawlConditionExcept.class)
    })
    protected List<Object> crawlConditions;
    @XmlElement(name = "crawl-extender")
    protected List<CrawlExtender> crawlExtender;
    @XmlAttribute(name = "log-file")
    protected String logFile;
    @XmlAttribute(name = "run-id")
    protected String runId;
    @XmlAttribute
    protected String subcollection;

    /**
     * Gets the value of the crawlOptions property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlOptions }
     *     
     */
    public CrawlOptions getCrawlOptions() {
        return crawlOptions;
    }

    /**
     * Sets the value of the crawlOptions property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlOptions }
     *     
     */
    public void setCrawlOptions(CrawlOptions value) {
        this.crawlOptions = value;
    }

    /**
     * Gets the value of the crawlUrls property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlUrls property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlUrls().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlUrls }
     * 
     * 
     */
    public List<CrawlUrls> getCrawlUrls() {
        if (crawlUrls == null) {
            crawlUrls = new ArrayList<CrawlUrls>();
        }
        return this.crawlUrls;
    }

    /**
     * Gets the value of the scope property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the scope property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getScope().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Scope }
     * 
     * 
     */
    public List<Scope> getScope() {
        if (scope == null) {
            scope = new ArrayList<Scope>();
        }
        return this.scope;
    }

    /**
     * Gets the value of the crawlConditions property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlConditions property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlConditions().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlConditionWhen }
     * {@link CrawlMustHave }
     * {@link CrawlMayNotHave }
     * {@link CrawlConditionExcept }
     * 
     * 
     */
    public List<Object> getCrawlConditions() {
        if (crawlConditions == null) {
            crawlConditions = new ArrayList<Object>();
        }
        return this.crawlConditions;
    }

    /**
     * Gets the value of the crawlExtender property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlExtender property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlExtender().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlExtender }
     * 
     * 
     */
    public List<CrawlExtender> getCrawlExtender() {
        if (crawlExtender == null) {
            crawlExtender = new ArrayList<CrawlExtender>();
        }
        return this.crawlExtender;
    }

    /**
     * Gets the value of the logFile property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLogFile() {
        if (logFile == null) {
            return "crawler.log";
        } else {
            return logFile;
        }
    }

    /**
     * Sets the value of the logFile property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLogFile(String value) {
        this.logFile = value;
    }

    /**
     * Gets the value of the runId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRunId() {
        return runId;
    }

    /**
     * Sets the value of the runId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRunId(String value) {
        this.runId = value;
    }

    /**
     * Gets the value of the subcollection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSubcollection() {
        return subcollection;
    }

    /**
     * Sets the value of the subcollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSubcollection(String value) {
        this.subcollection = value;
    }

}
