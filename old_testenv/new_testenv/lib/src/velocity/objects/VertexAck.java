
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
 *         &lt;element ref="{urn:/velocity/objects}log" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-pipeline"/>
 *       &lt;/sequence>
 *       &lt;attribute name="vertex" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-docs" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-contents" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-bytes" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="aborted">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="aborted"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="re-events" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="light-crawler">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="light-crawler"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="enqueue-id" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "log",
    "crawlPipeline"
})
@XmlRootElement(name = "vertex-ack")
public class VertexAck {

    protected Log log;
    @XmlElement(name = "crawl-pipeline", required = true)
    protected CrawlPipeline crawlPipeline;
    @XmlAttribute
    protected Integer vertex;
    @XmlAttribute(name = "n-docs")
    protected Integer nDocs;
    @XmlAttribute(name = "n-contents")
    protected Integer nContents;
    @XmlAttribute(name = "n-bytes")
    protected Long nBytes;
    @XmlAttribute
    protected String aborted;
    @XmlAttribute(name = "re-events")
    protected Integer reEvents;
    @XmlAttribute(name = "light-crawler")
    protected String lightCrawler;
    @XmlAttribute(name = "enqueue-id")
    @XmlSchemaType(name = "anySimpleType")
    protected String enqueueId;

    /**
     * Gets the value of the log property.
     * 
     * @return
     *     possible object is
     *     {@link Log }
     *     
     */
    public Log getLog() {
        return log;
    }

    /**
     * Sets the value of the log property.
     * 
     * @param value
     *     allowed object is
     *     {@link Log }
     *     
     */
    public void setLog(Log value) {
        this.log = value;
    }

    /**
     * Gets the value of the crawlPipeline property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlPipeline }
     *     
     */
    public CrawlPipeline getCrawlPipeline() {
        return crawlPipeline;
    }

    /**
     * Sets the value of the crawlPipeline property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlPipeline }
     *     
     */
    public void setCrawlPipeline(CrawlPipeline value) {
        this.crawlPipeline = value;
    }

    /**
     * Gets the value of the vertex property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getVertex() {
        return vertex;
    }

    /**
     * Sets the value of the vertex property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setVertex(Integer value) {
        this.vertex = value;
    }

    /**
     * Gets the value of the nDocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNDocs() {
        return nDocs;
    }

    /**
     * Sets the value of the nDocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNDocs(Integer value) {
        this.nDocs = value;
    }

    /**
     * Gets the value of the nContents property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNContents() {
        return nContents;
    }

    /**
     * Sets the value of the nContents property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNContents(Integer value) {
        this.nContents = value;
    }

    /**
     * Gets the value of the nBytes property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getNBytes() {
        return nBytes;
    }

    /**
     * Sets the value of the nBytes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setNBytes(Long value) {
        this.nBytes = value;
    }

    /**
     * Gets the value of the aborted property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAborted() {
        return aborted;
    }

    /**
     * Sets the value of the aborted property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAborted(String value) {
        this.aborted = value;
    }

    /**
     * Gets the value of the reEvents property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getReEvents() {
        return reEvents;
    }

    /**
     * Sets the value of the reEvents property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setReEvents(Integer value) {
        this.reEvents = value;
    }

    /**
     * Gets the value of the lightCrawler property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLightCrawler() {
        return lightCrawler;
    }

    /**
     * Sets the value of the lightCrawler property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLightCrawler(String value) {
        this.lightCrawler = value;
    }

    /**
     * Gets the value of the enqueueId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnqueueId() {
        return enqueueId;
    }

    /**
     * Sets the value of the enqueueId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnqueueId(String value) {
        this.enqueueId = value;
    }

}
