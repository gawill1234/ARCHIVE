
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *       &lt;attribute name="push-failed">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="no-modify-staging"/>
 *             &lt;enumeration value="no-modify-live"/>
 *             &lt;enumeration value="source-tests"/>
 *             &lt;enumeration value="no-staging"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="forked">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="forked"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="external-lock" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="live-crawl-date" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="next-live-crawl-date" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "collection-service-status")
public class CollectionServiceStatus {

    @XmlAttribute(name = "push-failed")
    protected String pushFailed;
    @XmlAttribute
    protected String forked;
    @XmlAttribute(name = "external-lock")
    protected Integer externalLock;
    @XmlAttribute(name = "live-crawl-date")
    protected Integer liveCrawlDate;
    @XmlAttribute(name = "next-live-crawl-date")
    protected Integer nextLiveCrawlDate;

    /**
     * Gets the value of the pushFailed property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPushFailed() {
        return pushFailed;
    }

    /**
     * Sets the value of the pushFailed property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPushFailed(String value) {
        this.pushFailed = value;
    }

    /**
     * Gets the value of the forked property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForked() {
        return forked;
    }

    /**
     * Sets the value of the forked property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForked(String value) {
        this.forked = value;
    }

    /**
     * Gets the value of the externalLock property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getExternalLock() {
        return externalLock;
    }

    /**
     * Sets the value of the externalLock property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setExternalLock(Integer value) {
        this.externalLock = value;
    }

    /**
     * Gets the value of the liveCrawlDate property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getLiveCrawlDate() {
        return liveCrawlDate;
    }

    /**
     * Sets the value of the liveCrawlDate property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setLiveCrawlDate(Integer value) {
        this.liveCrawlDate = value;
    }

    /**
     * Gets the value of the nextLiveCrawlDate property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNextLiveCrawlDate() {
        return nextLiveCrawlDate;
    }

    /**
     * Sets the value of the nextLiveCrawlDate property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNextLiveCrawlDate(Integer value) {
        this.nextLiveCrawlDate = value;
    }

}
