
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
 *         &lt;element ref="{urn:/velocity/objects}query-results"/>
 *         &lt;element ref="{urn:/velocity/objects}log" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="status">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="success"/>
 *             &lt;enumeration value="error"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="online" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="started" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "queryResults",
    "log"
})
@XmlRootElement(name = "collection-broker-search-response")
public class CollectionBrokerSearchResponse {

    @XmlElement(name = "query-results", required = true)
    protected QueryResults queryResults;
    protected Log log;
    @XmlAttribute
    protected String status;
    @XmlAttribute
    protected java.lang.Boolean online;
    @XmlAttribute
    protected java.lang.Boolean started;

    /**
     * Gets the value of the queryResults property.
     * 
     * @return
     *     possible object is
     *     {@link QueryResults }
     *     
     */
    public QueryResults getQueryResults() {
        return queryResults;
    }

    /**
     * Sets the value of the queryResults property.
     * 
     * @param value
     *     allowed object is
     *     {@link QueryResults }
     *     
     */
    public void setQueryResults(QueryResults value) {
        this.queryResults = value;
    }

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
     * Gets the value of the status property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStatus() {
        return status;
    }

    /**
     * Sets the value of the status property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStatus(String value) {
        this.status = value;
    }

    /**
     * Gets the value of the online property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isOnline() {
        return online;
    }

    /**
     * Sets the value of the online property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setOnline(java.lang.Boolean value) {
        this.online = value;
    }

    /**
     * Gets the value of the started property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isStarted() {
        return started;
    }

    /**
     * Sets the value of the started property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setStarted(java.lang.Boolean value) {
        this.started = value;
    }

}
