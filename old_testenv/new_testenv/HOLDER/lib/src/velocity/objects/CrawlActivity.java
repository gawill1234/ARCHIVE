
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
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
 *       &lt;choice>
 *         &lt;element name="always">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;choice>
 *                   &lt;element ref="{urn:/velocity/objects}content" maxOccurs="unbounded"/>
 *                 &lt;/choice>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="created" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;choice>
 *                   &lt;element name="added" type="{urn:/velocity/objects}activity-feed-added" maxOccurs="unbounded" minOccurs="0"/>
 *                 &lt;/choice>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="deleted" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;choice>
 *                   &lt;element name="removed" type="{urn:/velocity/objects}activity-feed-removed" maxOccurs="unbounded" minOccurs="0"/>
 *                 &lt;/choice>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="changes" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;choice>
 *                   &lt;element name="added" type="{urn:/velocity/objects}activity-feed-added" maxOccurs="unbounded" minOccurs="0"/>
 *                   &lt;element name="removed" type="{urn:/velocity/objects}activity-feed-removed" maxOccurs="unbounded" minOccurs="0"/>
 *                   &lt;element name="updated" maxOccurs="unbounded" minOccurs="0">
 *                     &lt;complexType>
 *                       &lt;complexContent>
 *                         &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                           &lt;choice>
 *                             &lt;element name="previous">
 *                               &lt;complexType>
 *                                 &lt;complexContent>
 *                                   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                                     &lt;choice>
 *                                       &lt;element ref="{urn:/velocity/objects}content"/>
 *                                     &lt;/choice>
 *                                   &lt;/restriction>
 *                                 &lt;/complexContent>
 *                               &lt;/complexType>
 *                             &lt;/element>
 *                             &lt;element name="current">
 *                               &lt;complexType>
 *                                 &lt;complexContent>
 *                                   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                                     &lt;choice>
 *                                       &lt;element ref="{urn:/velocity/objects}content"/>
 *                                     &lt;/choice>
 *                                   &lt;/restriction>
 *                                 &lt;/complexContent>
 *                               &lt;/complexType>
 *                             &lt;/element>
 *                           &lt;/choice>
 *                         &lt;/restriction>
 *                       &lt;/complexContent>
 *                     &lt;/complexType>
 *                   &lt;/element>
 *                 &lt;/choice>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/choice>
 *       &lt;attribute name="date" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="document-key-hash" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="vse-key" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="acl" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="fallback" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="original-url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="unique-url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="has-changes">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="has-changes"/>
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
    "always",
    "created",
    "deleted",
    "changes"
})
@XmlRootElement(name = "crawl-activity")
public class CrawlActivity {

    protected CrawlActivity.Always always;
    protected CrawlActivity.Created created;
    protected CrawlActivity.Deleted deleted;
    protected CrawlActivity.Changes changes;
    @XmlAttribute
    protected String date;
    @XmlAttribute(name = "document-key-hash")
    protected String documentKeyHash;
    @XmlAttribute(name = "vse-key")
    protected String vseKey;
    @XmlAttribute
    protected String acl;
    @XmlAttribute
    protected String fallback;
    @XmlAttribute(name = "original-url")
    protected String originalUrl;
    @XmlAttribute(name = "unique-url")
    protected String uniqueUrl;
    @XmlAttribute(name = "has-changes")
    protected String hasChanges;

    /**
     * Gets the value of the always property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlActivity.Always }
     *     
     */
    public CrawlActivity.Always getAlways() {
        return always;
    }

    /**
     * Sets the value of the always property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlActivity.Always }
     *     
     */
    public void setAlways(CrawlActivity.Always value) {
        this.always = value;
    }

    /**
     * Gets the value of the created property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlActivity.Created }
     *     
     */
    public CrawlActivity.Created getCreated() {
        return created;
    }

    /**
     * Sets the value of the created property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlActivity.Created }
     *     
     */
    public void setCreated(CrawlActivity.Created value) {
        this.created = value;
    }

    /**
     * Gets the value of the deleted property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlActivity.Deleted }
     *     
     */
    public CrawlActivity.Deleted getDeleted() {
        return deleted;
    }

    /**
     * Sets the value of the deleted property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlActivity.Deleted }
     *     
     */
    public void setDeleted(CrawlActivity.Deleted value) {
        this.deleted = value;
    }

    /**
     * Gets the value of the changes property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlActivity.Changes }
     *     
     */
    public CrawlActivity.Changes getChanges() {
        return changes;
    }

    /**
     * Sets the value of the changes property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlActivity.Changes }
     *     
     */
    public void setChanges(CrawlActivity.Changes value) {
        this.changes = value;
    }

    /**
     * Gets the value of the date property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDate() {
        return date;
    }

    /**
     * Sets the value of the date property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDate(String value) {
        this.date = value;
    }

    /**
     * Gets the value of the documentKeyHash property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDocumentKeyHash() {
        return documentKeyHash;
    }

    /**
     * Sets the value of the documentKeyHash property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDocumentKeyHash(String value) {
        this.documentKeyHash = value;
    }

    /**
     * Gets the value of the vseKey property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseKey() {
        return vseKey;
    }

    /**
     * Sets the value of the vseKey property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseKey(String value) {
        this.vseKey = value;
    }

    /**
     * Gets the value of the acl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAcl() {
        return acl;
    }

    /**
     * Sets the value of the acl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAcl(String value) {
        this.acl = value;
    }

    /**
     * Gets the value of the fallback property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFallback() {
        return fallback;
    }

    /**
     * Sets the value of the fallback property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFallback(String value) {
        this.fallback = value;
    }

    /**
     * Gets the value of the originalUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOriginalUrl() {
        return originalUrl;
    }

    /**
     * Sets the value of the originalUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOriginalUrl(String value) {
        this.originalUrl = value;
    }

    /**
     * Gets the value of the uniqueUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUniqueUrl() {
        return uniqueUrl;
    }

    /**
     * Sets the value of the uniqueUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUniqueUrl(String value) {
        this.uniqueUrl = value;
    }

    /**
     * Gets the value of the hasChanges property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHasChanges() {
        return hasChanges;
    }

    /**
     * Sets the value of the hasChanges property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHasChanges(String value) {
        this.hasChanges = value;
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
     *       &lt;choice>
     *         &lt;element ref="{urn:/velocity/objects}content" maxOccurs="unbounded"/>
     *       &lt;/choice>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "content"
    })
    public static class Always {

        protected List<Content> content;

        /**
         * Gets the value of the content property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the content property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getContent().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link Content }
         * 
         * 
         */
        public List<Content> getContent() {
            if (content == null) {
                content = new ArrayList<Content>();
            }
            return this.content;
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
     *       &lt;choice>
     *         &lt;element name="added" type="{urn:/velocity/objects}activity-feed-added" maxOccurs="unbounded" minOccurs="0"/>
     *         &lt;element name="removed" type="{urn:/velocity/objects}activity-feed-removed" maxOccurs="unbounded" minOccurs="0"/>
     *         &lt;element name="updated" maxOccurs="unbounded" minOccurs="0">
     *           &lt;complexType>
     *             &lt;complexContent>
     *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *                 &lt;choice>
     *                   &lt;element name="previous">
     *                     &lt;complexType>
     *                       &lt;complexContent>
     *                         &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *                           &lt;choice>
     *                             &lt;element ref="{urn:/velocity/objects}content"/>
     *                           &lt;/choice>
     *                         &lt;/restriction>
     *                       &lt;/complexContent>
     *                     &lt;/complexType>
     *                   &lt;/element>
     *                   &lt;element name="current">
     *                     &lt;complexType>
     *                       &lt;complexContent>
     *                         &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *                           &lt;choice>
     *                             &lt;element ref="{urn:/velocity/objects}content"/>
     *                           &lt;/choice>
     *                         &lt;/restriction>
     *                       &lt;/complexContent>
     *                     &lt;/complexType>
     *                   &lt;/element>
     *                 &lt;/choice>
     *               &lt;/restriction>
     *             &lt;/complexContent>
     *           &lt;/complexType>
     *         &lt;/element>
     *       &lt;/choice>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "added",
        "removed",
        "updated"
    })
    public static class Changes {

        protected List<ActivityFeedAdded> added;
        protected List<ActivityFeedRemoved> removed;
        protected List<CrawlActivity.Changes.Updated> updated;

        /**
         * Gets the value of the added property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the added property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getAdded().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link ActivityFeedAdded }
         * 
         * 
         */
        public List<ActivityFeedAdded> getAdded() {
            if (added == null) {
                added = new ArrayList<ActivityFeedAdded>();
            }
            return this.added;
        }

        /**
         * Gets the value of the removed property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the removed property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getRemoved().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link ActivityFeedRemoved }
         * 
         * 
         */
        public List<ActivityFeedRemoved> getRemoved() {
            if (removed == null) {
                removed = new ArrayList<ActivityFeedRemoved>();
            }
            return this.removed;
        }

        /**
         * Gets the value of the updated property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the updated property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getUpdated().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link CrawlActivity.Changes.Updated }
         * 
         * 
         */
        public List<CrawlActivity.Changes.Updated> getUpdated() {
            if (updated == null) {
                updated = new ArrayList<CrawlActivity.Changes.Updated>();
            }
            return this.updated;
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
         *       &lt;choice>
         *         &lt;element name="previous">
         *           &lt;complexType>
         *             &lt;complexContent>
         *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
         *                 &lt;choice>
         *                   &lt;element ref="{urn:/velocity/objects}content"/>
         *                 &lt;/choice>
         *               &lt;/restriction>
         *             &lt;/complexContent>
         *           &lt;/complexType>
         *         &lt;/element>
         *         &lt;element name="current">
         *           &lt;complexType>
         *             &lt;complexContent>
         *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
         *                 &lt;choice>
         *                   &lt;element ref="{urn:/velocity/objects}content"/>
         *                 &lt;/choice>
         *               &lt;/restriction>
         *             &lt;/complexContent>
         *           &lt;/complexType>
         *         &lt;/element>
         *       &lt;/choice>
         *     &lt;/restriction>
         *   &lt;/complexContent>
         * &lt;/complexType>
         * </pre>
         * 
         * 
         */
        @XmlAccessorType(XmlAccessType.FIELD)
        @XmlType(name = "", propOrder = {
            "previous",
            "current"
        })
        public static class Updated {

            protected CrawlActivity.Changes.Updated.Previous previous;
            protected CrawlActivity.Changes.Updated.Current current;

            /**
             * Gets the value of the previous property.
             * 
             * @return
             *     possible object is
             *     {@link CrawlActivity.Changes.Updated.Previous }
             *     
             */
            public CrawlActivity.Changes.Updated.Previous getPrevious() {
                return previous;
            }

            /**
             * Sets the value of the previous property.
             * 
             * @param value
             *     allowed object is
             *     {@link CrawlActivity.Changes.Updated.Previous }
             *     
             */
            public void setPrevious(CrawlActivity.Changes.Updated.Previous value) {
                this.previous = value;
            }

            /**
             * Gets the value of the current property.
             * 
             * @return
             *     possible object is
             *     {@link CrawlActivity.Changes.Updated.Current }
             *     
             */
            public CrawlActivity.Changes.Updated.Current getCurrent() {
                return current;
            }

            /**
             * Sets the value of the current property.
             * 
             * @param value
             *     allowed object is
             *     {@link CrawlActivity.Changes.Updated.Current }
             *     
             */
            public void setCurrent(CrawlActivity.Changes.Updated.Current value) {
                this.current = value;
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
             *       &lt;choice>
             *         &lt;element ref="{urn:/velocity/objects}content"/>
             *       &lt;/choice>
             *     &lt;/restriction>
             *   &lt;/complexContent>
             * &lt;/complexType>
             * </pre>
             * 
             * 
             */
            @XmlAccessorType(XmlAccessType.FIELD)
            @XmlType(name = "", propOrder = {
                "content"
            })
            public static class Current {

                protected Content content;

                /**
                 * Gets the value of the content property.
                 * 
                 * @return
                 *     possible object is
                 *     {@link Content }
                 *     
                 */
                public Content getContent() {
                    return content;
                }

                /**
                 * Sets the value of the content property.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link Content }
                 *     
                 */
                public void setContent(Content value) {
                    this.content = value;
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
             *       &lt;choice>
             *         &lt;element ref="{urn:/velocity/objects}content"/>
             *       &lt;/choice>
             *     &lt;/restriction>
             *   &lt;/complexContent>
             * &lt;/complexType>
             * </pre>
             * 
             * 
             */
            @XmlAccessorType(XmlAccessType.FIELD)
            @XmlType(name = "", propOrder = {
                "content"
            })
            public static class Previous {

                protected Content content;

                /**
                 * Gets the value of the content property.
                 * 
                 * @return
                 *     possible object is
                 *     {@link Content }
                 *     
                 */
                public Content getContent() {
                    return content;
                }

                /**
                 * Sets the value of the content property.
                 * 
                 * @param value
                 *     allowed object is
                 *     {@link Content }
                 *     
                 */
                public void setContent(Content value) {
                    this.content = value;
                }

            }

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
     *       &lt;choice>
     *         &lt;element name="added" type="{urn:/velocity/objects}activity-feed-added" maxOccurs="unbounded" minOccurs="0"/>
     *       &lt;/choice>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "added"
    })
    public static class Created {

        protected List<ActivityFeedAdded> added;

        /**
         * Gets the value of the added property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the added property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getAdded().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link ActivityFeedAdded }
         * 
         * 
         */
        public List<ActivityFeedAdded> getAdded() {
            if (added == null) {
                added = new ArrayList<ActivityFeedAdded>();
            }
            return this.added;
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
     *       &lt;choice>
     *         &lt;element name="removed" type="{urn:/velocity/objects}activity-feed-removed" maxOccurs="unbounded" minOccurs="0"/>
     *       &lt;/choice>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "removed"
    })
    public static class Deleted {

        protected List<ActivityFeedRemoved> removed;

        /**
         * Gets the value of the removed property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the removed property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getRemoved().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link ActivityFeedRemoved }
         * 
         * 
         */
        public List<ActivityFeedRemoved> getRemoved() {
            if (removed == null) {
                removed = new ArrayList<ActivityFeedRemoved>();
            }
            return this.removed;
        }

    }

}
