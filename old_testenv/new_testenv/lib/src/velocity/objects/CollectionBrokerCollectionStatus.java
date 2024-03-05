
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
 *         &lt;element name="crawler-status">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attribute name="online" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *                 &lt;attribute name="pid" type="{http://www.w3.org/2001/XMLSchema}int" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="indexer-status">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attribute name="online" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *                 &lt;attribute name="pid" type="{http://www.w3.org/2001/XMLSchema}int" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/sequence>
 *       &lt;attribute name="collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="ping" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="status">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="deleted"/>
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
    "crawlerStatus",
    "indexerStatus"
})
@XmlRootElement(name = "collection-broker-collection-status")
public class CollectionBrokerCollectionStatus {

    @XmlElement(name = "crawler-status", required = true)
    protected CollectionBrokerCollectionStatus.CrawlerStatus crawlerStatus;
    @XmlElement(name = "indexer-status", required = true)
    protected CollectionBrokerCollectionStatus.IndexerStatus indexerStatus;
    @XmlAttribute
    protected String collection;
    @XmlAttribute
    protected java.lang.Boolean ping;
    @XmlAttribute
    protected String status;

    /**
     * Gets the value of the crawlerStatus property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerCollectionStatus.CrawlerStatus }
     *     
     */
    public CollectionBrokerCollectionStatus.CrawlerStatus getCrawlerStatus() {
        return crawlerStatus;
    }

    /**
     * Sets the value of the crawlerStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerCollectionStatus.CrawlerStatus }
     *     
     */
    public void setCrawlerStatus(CollectionBrokerCollectionStatus.CrawlerStatus value) {
        this.crawlerStatus = value;
    }

    /**
     * Gets the value of the indexerStatus property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerCollectionStatus.IndexerStatus }
     *     
     */
    public CollectionBrokerCollectionStatus.IndexerStatus getIndexerStatus() {
        return indexerStatus;
    }

    /**
     * Sets the value of the indexerStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerCollectionStatus.IndexerStatus }
     *     
     */
    public void setIndexerStatus(CollectionBrokerCollectionStatus.IndexerStatus value) {
        this.indexerStatus = value;
    }

    /**
     * Gets the value of the collection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollection() {
        return collection;
    }

    /**
     * Sets the value of the collection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollection(String value) {
        this.collection = value;
    }

    /**
     * Gets the value of the ping property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isPing() {
        return ping;
    }

    /**
     * Sets the value of the ping property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setPing(java.lang.Boolean value) {
        this.ping = value;
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
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;attribute name="online" type="{http://www.w3.org/2001/XMLSchema}boolean" />
     *       &lt;attribute name="pid" type="{http://www.w3.org/2001/XMLSchema}int" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "")
    public static class CrawlerStatus {

        @XmlAttribute
        protected java.lang.Boolean online;
        @XmlAttribute
        protected Integer pid;

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
         * Gets the value of the pid property.
         * 
         * @return
         *     possible object is
         *     {@link Integer }
         *     
         */
        public Integer getPid() {
            return pid;
        }

        /**
         * Sets the value of the pid property.
         * 
         * @param value
         *     allowed object is
         *     {@link Integer }
         *     
         */
        public void setPid(Integer value) {
            this.pid = value;
        }

    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;attribute name="online" type="{http://www.w3.org/2001/XMLSchema}boolean" />
     *       &lt;attribute name="pid" type="{http://www.w3.org/2001/XMLSchema}int" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "")
    public static class IndexerStatus {

        @XmlAttribute
        protected java.lang.Boolean online;
        @XmlAttribute
        protected Integer pid;

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
         * Gets the value of the pid property.
         * 
         * @return
         *     possible object is
         *     {@link Integer }
         *     
         */
        public Integer getPid() {
            return pid;
        }

        /**
         * Sets the value of the pid property.
         * 
         * @param value
         *     allowed object is
         *     {@link Integer }
         *     
         */
        public void setPid(Integer value) {
            this.pid = value;
        }

    }

}
