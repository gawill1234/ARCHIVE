
package velocity.objects;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import javax.xml.datatype.XMLGregorianCalendar;


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
 *         &lt;element name="collection" maxOccurs="unbounded" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attribute name="name" use="required" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *                 &lt;attribute name="is-online" use="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *                 &lt;attribute name="is-ignored" use="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *                 &lt;attribute name="ram-usage" use="required" type="{http://www.w3.org/2001/XMLSchema}long" />
 *                 &lt;attribute name="start-time" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
 *                 &lt;attribute name="idle-time" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
 *                 &lt;attribute name="active-queries" use="required" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *                 &lt;attribute name="active-enqueues" use="required" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *                 &lt;attribute name="has-offline-queue" use="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="export" maxOccurs="unbounded" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}log" minOccurs="0"/>
 *                 &lt;/sequence>
 *                 &lt;attribute name="id" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                 &lt;attribute name="source-collection" use="required" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *                 &lt;attribute name="destination-collection" use="required" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *                 &lt;attribute name="status" use="required">
 *                   &lt;simpleType>
 *                     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *                       &lt;enumeration value="copying"/>
 *                       &lt;enumeration value="deleting"/>
 *                       &lt;enumeration value="complete"/>
 *                       &lt;enumeration value="error"/>
 *                     &lt;/restriction>
 *                   &lt;/simpleType>
 *                 &lt;/attribute>
 *                 &lt;attribute name="start-time" use="required" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
 *                 &lt;attribute name="copy-complete-time" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
 *                 &lt;attribute name="complete-time" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
 *                 &lt;attribute name="total-files" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *                 &lt;attribute name="copied-files" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *                 &lt;attribute name="total-size" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *                 &lt;attribute name="copied-size" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *                 &lt;attribute name="documents-deleted" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element ref="{urn:/velocity/objects}collection-broker-configuration"/>
 *       &lt;/sequence>
 *       &lt;attribute name="status" use="required">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="stopped"/>
 *             &lt;enumeration value="running"/>
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
    "collection",
    "export",
    "collectionBrokerConfiguration"
})
@XmlRootElement(name = "collection-broker-status-response")
public class CollectionBrokerStatusResponse {

    protected List<CollectionBrokerStatusResponse.Collection> collection;
    protected List<CollectionBrokerStatusResponse.Export> export;
    @XmlElement(name = "collection-broker-configuration", required = true)
    protected CollectionBrokerConfiguration collectionBrokerConfiguration;
    @XmlAttribute(required = true)
    protected String status;

    /**
     * Gets the value of the collection property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the collection property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCollection().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CollectionBrokerStatusResponse.Collection }
     * 
     * 
     */
    public List<CollectionBrokerStatusResponse.Collection> getCollection() {
        if (collection == null) {
            collection = new ArrayList<CollectionBrokerStatusResponse.Collection>();
        }
        return this.collection;
    }

    /**
     * Gets the value of the export property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the export property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getExport().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CollectionBrokerStatusResponse.Export }
     * 
     * 
     */
    public List<CollectionBrokerStatusResponse.Export> getExport() {
        if (export == null) {
            export = new ArrayList<CollectionBrokerStatusResponse.Export>();
        }
        return this.export;
    }

    /**
     * Gets the value of the collectionBrokerConfiguration property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerConfiguration }
     *     
     */
    public CollectionBrokerConfiguration getCollectionBrokerConfiguration() {
        return collectionBrokerConfiguration;
    }

    /**
     * Sets the value of the collectionBrokerConfiguration property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerConfiguration }
     *     
     */
    public void setCollectionBrokerConfiguration(CollectionBrokerConfiguration value) {
        this.collectionBrokerConfiguration = value;
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
     *       &lt;attribute name="name" use="required" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
     *       &lt;attribute name="is-online" use="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
     *       &lt;attribute name="is-ignored" use="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
     *       &lt;attribute name="ram-usage" use="required" type="{http://www.w3.org/2001/XMLSchema}long" />
     *       &lt;attribute name="start-time" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
     *       &lt;attribute name="idle-time" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
     *       &lt;attribute name="active-queries" use="required" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
     *       &lt;attribute name="active-enqueues" use="required" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
     *       &lt;attribute name="has-offline-queue" use="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "")
    public static class Collection {

        @XmlAttribute(required = true)
        @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
        @XmlSchemaType(name = "NMTOKEN")
        protected String name;
        @XmlAttribute(name = "is-online", required = true)
        protected boolean isOnline;
        @XmlAttribute(name = "is-ignored", required = true)
        protected boolean isIgnored;
        @XmlAttribute(name = "ram-usage", required = true)
        protected long ramUsage;
        @XmlAttribute(name = "start-time")
        @XmlSchemaType(name = "dateTime")
        protected XMLGregorianCalendar startTime;
        @XmlAttribute(name = "idle-time")
        @XmlSchemaType(name = "dateTime")
        protected XMLGregorianCalendar idleTime;
        @XmlAttribute(name = "active-queries", required = true)
        @XmlSchemaType(name = "unsignedInt")
        protected long activeQueries;
        @XmlAttribute(name = "active-enqueues", required = true)
        @XmlSchemaType(name = "unsignedInt")
        protected long activeEnqueues;
        @XmlAttribute(name = "has-offline-queue", required = true)
        protected boolean hasOfflineQueue;

        /**
         * Gets the value of the name property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getName() {
            return name;
        }

        /**
         * Sets the value of the name property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setName(String value) {
            this.name = value;
        }

        /**
         * Gets the value of the isOnline property.
         * 
         */
        public boolean isIsOnline() {
            return isOnline;
        }

        /**
         * Sets the value of the isOnline property.
         * 
         */
        public void setIsOnline(boolean value) {
            this.isOnline = value;
        }

        /**
         * Gets the value of the isIgnored property.
         * 
         */
        public boolean isIsIgnored() {
            return isIgnored;
        }

        /**
         * Sets the value of the isIgnored property.
         * 
         */
        public void setIsIgnored(boolean value) {
            this.isIgnored = value;
        }

        /**
         * Gets the value of the ramUsage property.
         * 
         */
        public long getRamUsage() {
            return ramUsage;
        }

        /**
         * Sets the value of the ramUsage property.
         * 
         */
        public void setRamUsage(long value) {
            this.ramUsage = value;
        }

        /**
         * Gets the value of the startTime property.
         * 
         * @return
         *     possible object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public XMLGregorianCalendar getStartTime() {
            return startTime;
        }

        /**
         * Sets the value of the startTime property.
         * 
         * @param value
         *     allowed object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public void setStartTime(XMLGregorianCalendar value) {
            this.startTime = value;
        }

        /**
         * Gets the value of the idleTime property.
         * 
         * @return
         *     possible object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public XMLGregorianCalendar getIdleTime() {
            return idleTime;
        }

        /**
         * Sets the value of the idleTime property.
         * 
         * @param value
         *     allowed object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public void setIdleTime(XMLGregorianCalendar value) {
            this.idleTime = value;
        }

        /**
         * Gets the value of the activeQueries property.
         * 
         */
        public long getActiveQueries() {
            return activeQueries;
        }

        /**
         * Sets the value of the activeQueries property.
         * 
         */
        public void setActiveQueries(long value) {
            this.activeQueries = value;
        }

        /**
         * Gets the value of the activeEnqueues property.
         * 
         */
        public long getActiveEnqueues() {
            return activeEnqueues;
        }

        /**
         * Sets the value of the activeEnqueues property.
         * 
         */
        public void setActiveEnqueues(long value) {
            this.activeEnqueues = value;
        }

        /**
         * Gets the value of the hasOfflineQueue property.
         * 
         */
        public boolean isHasOfflineQueue() {
            return hasOfflineQueue;
        }

        /**
         * Sets the value of the hasOfflineQueue property.
         * 
         */
        public void setHasOfflineQueue(boolean value) {
            this.hasOfflineQueue = value;
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
     *       &lt;sequence>
     *         &lt;element ref="{urn:/velocity/objects}log" minOccurs="0"/>
     *       &lt;/sequence>
     *       &lt;attribute name="id" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *       &lt;attribute name="source-collection" use="required" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
     *       &lt;attribute name="destination-collection" use="required" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
     *       &lt;attribute name="status" use="required">
     *         &lt;simpleType>
     *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
     *             &lt;enumeration value="copying"/>
     *             &lt;enumeration value="deleting"/>
     *             &lt;enumeration value="complete"/>
     *             &lt;enumeration value="error"/>
     *           &lt;/restriction>
     *         &lt;/simpleType>
     *       &lt;/attribute>
     *       &lt;attribute name="start-time" use="required" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
     *       &lt;attribute name="copy-complete-time" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
     *       &lt;attribute name="complete-time" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
     *       &lt;attribute name="total-files" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
     *       &lt;attribute name="copied-files" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
     *       &lt;attribute name="total-size" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
     *       &lt;attribute name="copied-size" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
     *       &lt;attribute name="documents-deleted" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "log"
    })
    public static class Export {

        protected Log log;
        @XmlAttribute(required = true)
        protected String id;
        @XmlAttribute(name = "source-collection", required = true)
        @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
        @XmlSchemaType(name = "NMTOKEN")
        protected String sourceCollection;
        @XmlAttribute(name = "destination-collection", required = true)
        @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
        @XmlSchemaType(name = "NMTOKEN")
        protected String destinationCollection;
        @XmlAttribute(required = true)
        protected String status;
        @XmlAttribute(name = "start-time", required = true)
        @XmlSchemaType(name = "dateTime")
        protected XMLGregorianCalendar startTime;
        @XmlAttribute(name = "copy-complete-time")
        @XmlSchemaType(name = "dateTime")
        protected XMLGregorianCalendar copyCompleteTime;
        @XmlAttribute(name = "complete-time")
        @XmlSchemaType(name = "dateTime")
        protected XMLGregorianCalendar completeTime;
        @XmlAttribute(name = "total-files")
        @XmlSchemaType(name = "unsignedInt")
        protected Long totalFiles;
        @XmlAttribute(name = "copied-files")
        @XmlSchemaType(name = "unsignedInt")
        protected Long copiedFiles;
        @XmlAttribute(name = "total-size")
        @XmlSchemaType(name = "unsignedLong")
        protected BigInteger totalSize;
        @XmlAttribute(name = "copied-size")
        @XmlSchemaType(name = "unsignedLong")
        protected BigInteger copiedSize;
        @XmlAttribute(name = "documents-deleted")
        @XmlSchemaType(name = "unsignedLong")
        protected BigInteger documentsDeleted;

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
         * Gets the value of the id property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getId() {
            return id;
        }

        /**
         * Sets the value of the id property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setId(String value) {
            this.id = value;
        }

        /**
         * Gets the value of the sourceCollection property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getSourceCollection() {
            return sourceCollection;
        }

        /**
         * Sets the value of the sourceCollection property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setSourceCollection(String value) {
            this.sourceCollection = value;
        }

        /**
         * Gets the value of the destinationCollection property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getDestinationCollection() {
            return destinationCollection;
        }

        /**
         * Sets the value of the destinationCollection property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setDestinationCollection(String value) {
            this.destinationCollection = value;
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
         * Gets the value of the startTime property.
         * 
         * @return
         *     possible object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public XMLGregorianCalendar getStartTime() {
            return startTime;
        }

        /**
         * Sets the value of the startTime property.
         * 
         * @param value
         *     allowed object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public void setStartTime(XMLGregorianCalendar value) {
            this.startTime = value;
        }

        /**
         * Gets the value of the copyCompleteTime property.
         * 
         * @return
         *     possible object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public XMLGregorianCalendar getCopyCompleteTime() {
            return copyCompleteTime;
        }

        /**
         * Sets the value of the copyCompleteTime property.
         * 
         * @param value
         *     allowed object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public void setCopyCompleteTime(XMLGregorianCalendar value) {
            this.copyCompleteTime = value;
        }

        /**
         * Gets the value of the completeTime property.
         * 
         * @return
         *     possible object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public XMLGregorianCalendar getCompleteTime() {
            return completeTime;
        }

        /**
         * Sets the value of the completeTime property.
         * 
         * @param value
         *     allowed object is
         *     {@link XMLGregorianCalendar }
         *     
         */
        public void setCompleteTime(XMLGregorianCalendar value) {
            this.completeTime = value;
        }

        /**
         * Gets the value of the totalFiles property.
         * 
         * @return
         *     possible object is
         *     {@link Long }
         *     
         */
        public Long getTotalFiles() {
            return totalFiles;
        }

        /**
         * Sets the value of the totalFiles property.
         * 
         * @param value
         *     allowed object is
         *     {@link Long }
         *     
         */
        public void setTotalFiles(Long value) {
            this.totalFiles = value;
        }

        /**
         * Gets the value of the copiedFiles property.
         * 
         * @return
         *     possible object is
         *     {@link Long }
         *     
         */
        public Long getCopiedFiles() {
            return copiedFiles;
        }

        /**
         * Sets the value of the copiedFiles property.
         * 
         * @param value
         *     allowed object is
         *     {@link Long }
         *     
         */
        public void setCopiedFiles(Long value) {
            this.copiedFiles = value;
        }

        /**
         * Gets the value of the totalSize property.
         * 
         * @return
         *     possible object is
         *     {@link BigInteger }
         *     
         */
        public BigInteger getTotalSize() {
            return totalSize;
        }

        /**
         * Sets the value of the totalSize property.
         * 
         * @param value
         *     allowed object is
         *     {@link BigInteger }
         *     
         */
        public void setTotalSize(BigInteger value) {
            this.totalSize = value;
        }

        /**
         * Gets the value of the copiedSize property.
         * 
         * @return
         *     possible object is
         *     {@link BigInteger }
         *     
         */
        public BigInteger getCopiedSize() {
            return copiedSize;
        }

        /**
         * Sets the value of the copiedSize property.
         * 
         * @param value
         *     allowed object is
         *     {@link BigInteger }
         *     
         */
        public void setCopiedSize(BigInteger value) {
            this.copiedSize = value;
        }

        /**
         * Gets the value of the documentsDeleted property.
         * 
         * @return
         *     possible object is
         *     {@link BigInteger }
         *     
         */
        public BigInteger getDocumentsDeleted() {
            return documentsDeleted;
        }

        /**
         * Sets the value of the documentsDeleted property.
         * 
         * @param value
         *     allowed object is
         *     {@link BigInteger }
         *     
         */
        public void setDocumentsDeleted(BigInteger value) {
            this.documentsDeleted = value;
        }

    }

}
