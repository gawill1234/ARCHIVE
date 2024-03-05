
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAnyElement;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import org.w3c.dom.Element;


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
 *         &lt;element name="xml">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;any processContents='lax' minOccurs="0"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="vxml">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}document" maxOccurs="unbounded" minOccurs="0"/>
 *                   &lt;element ref="{urn:/velocity/objects}content" maxOccurs="unbounded" minOccurs="0"/>
 *                   &lt;element ref="{urn:/velocity/objects}advanced-content" maxOccurs="unbounded" minOccurs="0"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="base64" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="qp-utf8" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="text" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *       &lt;/sequence>
 *       &lt;attribute name="encoding">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="base64"/>
 *             &lt;enumeration value="xml"/>
 *             &lt;enumeration value="qp-utf8"/>
 *             &lt;enumeration value="text"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="db-row" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="rich-db-row" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="db-file" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="content-type" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="anchor" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="light-crawler-url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="light-crawler-enqueue-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="light-crawler-arena" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="error" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="fallback" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="fallback-error" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="acl" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="i" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="ct" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="rich-ct" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="input">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="input"/>
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
    "xml",
    "vxml",
    "base64",
    "qpUtf8",
    "text"
})
@XmlRootElement(name = "crawl-data")
public class CrawlData {

    @XmlElement(required = true)
    protected CrawlData.Xml xml;
    @XmlElement(required = true)
    protected CrawlData.Vxml vxml;
    @XmlElement(required = true)
    protected String base64;
    @XmlElement(name = "qp-utf8", required = true)
    protected String qpUtf8;
    @XmlElement(required = true)
    protected String text;
    @XmlAttribute
    protected String encoding;
    @XmlAttribute(name = "db-row")
    @XmlSchemaType(name = "unsignedInt")
    protected Long dbRow;
    @XmlAttribute(name = "rich-db-row")
    @XmlSchemaType(name = "unsignedInt")
    protected Long richDbRow;
    @XmlAttribute(name = "db-file")
    protected String dbFile;
    @XmlAttribute(name = "content-type")
    protected String contentType;
    @XmlAttribute
    protected String anchor;
    @XmlAttribute
    protected String url;
    @XmlAttribute(name = "light-crawler-url")
    protected String lightCrawlerUrl;
    @XmlAttribute(name = "light-crawler-enqueue-id")
    protected String lightCrawlerEnqueueId;
    @XmlAttribute(name = "light-crawler-arena")
    protected String lightCrawlerArena;
    @XmlAttribute
    protected String error;
    @XmlAttribute
    protected String fallback;
    @XmlAttribute(name = "fallback-error")
    protected String fallbackError;
    @XmlAttribute
    protected String acl;
    @XmlAttribute
    protected Integer i;
    @XmlAttribute
    protected String ct;
    @XmlAttribute(name = "rich-ct")
    protected String richCt;
    @XmlAttribute
    protected String input;

    /**
     * Gets the value of the xml property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlData.Xml }
     *     
     */
    public CrawlData.Xml getXml() {
        return xml;
    }

    /**
     * Sets the value of the xml property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlData.Xml }
     *     
     */
    public void setXml(CrawlData.Xml value) {
        this.xml = value;
    }

    /**
     * Gets the value of the vxml property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlData.Vxml }
     *     
     */
    public CrawlData.Vxml getVxml() {
        return vxml;
    }

    /**
     * Sets the value of the vxml property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlData.Vxml }
     *     
     */
    public void setVxml(CrawlData.Vxml value) {
        this.vxml = value;
    }

    /**
     * Gets the value of the base64 property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBase64() {
        return base64;
    }

    /**
     * Sets the value of the base64 property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBase64(String value) {
        this.base64 = value;
    }

    /**
     * Gets the value of the qpUtf8 property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getQpUtf8() {
        return qpUtf8;
    }

    /**
     * Sets the value of the qpUtf8 property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setQpUtf8(String value) {
        this.qpUtf8 = value;
    }

    /**
     * Gets the value of the text property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getText() {
        return text;
    }

    /**
     * Sets the value of the text property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setText(String value) {
        this.text = value;
    }

    /**
     * Gets the value of the encoding property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEncoding() {
        return encoding;
    }

    /**
     * Sets the value of the encoding property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEncoding(String value) {
        this.encoding = value;
    }

    /**
     * Gets the value of the dbRow property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getDbRow() {
        return dbRow;
    }

    /**
     * Sets the value of the dbRow property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setDbRow(Long value) {
        this.dbRow = value;
    }

    /**
     * Gets the value of the richDbRow property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getRichDbRow() {
        return richDbRow;
    }

    /**
     * Sets the value of the richDbRow property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setRichDbRow(Long value) {
        this.richDbRow = value;
    }

    /**
     * Gets the value of the dbFile property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDbFile() {
        return dbFile;
    }

    /**
     * Sets the value of the dbFile property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDbFile(String value) {
        this.dbFile = value;
    }

    /**
     * Gets the value of the contentType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getContentType() {
        return contentType;
    }

    /**
     * Sets the value of the contentType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setContentType(String value) {
        this.contentType = value;
    }

    /**
     * Gets the value of the anchor property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAnchor() {
        return anchor;
    }

    /**
     * Sets the value of the anchor property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAnchor(String value) {
        this.anchor = value;
    }

    /**
     * Gets the value of the url property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrl() {
        return url;
    }

    /**
     * Sets the value of the url property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrl(String value) {
        this.url = value;
    }

    /**
     * Gets the value of the lightCrawlerUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLightCrawlerUrl() {
        return lightCrawlerUrl;
    }

    /**
     * Sets the value of the lightCrawlerUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLightCrawlerUrl(String value) {
        this.lightCrawlerUrl = value;
    }

    /**
     * Gets the value of the lightCrawlerEnqueueId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLightCrawlerEnqueueId() {
        return lightCrawlerEnqueueId;
    }

    /**
     * Sets the value of the lightCrawlerEnqueueId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLightCrawlerEnqueueId(String value) {
        this.lightCrawlerEnqueueId = value;
    }

    /**
     * Gets the value of the lightCrawlerArena property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLightCrawlerArena() {
        return lightCrawlerArena;
    }

    /**
     * Sets the value of the lightCrawlerArena property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLightCrawlerArena(String value) {
        this.lightCrawlerArena = value;
    }

    /**
     * Gets the value of the error property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getError() {
        return error;
    }

    /**
     * Sets the value of the error property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setError(String value) {
        this.error = value;
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
     * Gets the value of the fallbackError property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFallbackError() {
        return fallbackError;
    }

    /**
     * Sets the value of the fallbackError property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFallbackError(String value) {
        this.fallbackError = value;
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
     * Gets the value of the i property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getI() {
        if (i == null) {
            return  0;
        } else {
            return i;
        }
    }

    /**
     * Sets the value of the i property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setI(Integer value) {
        this.i = value;
    }

    /**
     * Gets the value of the ct property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCt() {
        return ct;
    }

    /**
     * Sets the value of the ct property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCt(String value) {
        this.ct = value;
    }

    /**
     * Gets the value of the richCt property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRichCt() {
        return richCt;
    }

    /**
     * Sets the value of the richCt property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRichCt(String value) {
        this.richCt = value;
    }

    /**
     * Gets the value of the input property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInput() {
        return input;
    }

    /**
     * Sets the value of the input property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInput(String value) {
        this.input = value;
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
     *         &lt;element ref="{urn:/velocity/objects}document" maxOccurs="unbounded" minOccurs="0"/>
     *         &lt;element ref="{urn:/velocity/objects}content" maxOccurs="unbounded" minOccurs="0"/>
     *         &lt;element ref="{urn:/velocity/objects}advanced-content" maxOccurs="unbounded" minOccurs="0"/>
     *       &lt;/sequence>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "document",
        "content",
        "advancedContent"
    })
    public static class Vxml {

        protected List<Document> document;
        protected List<Content> content;
        @XmlElement(name = "advanced-content")
        protected List<AdvancedContent> advancedContent;

        /**
         * Gets the value of the document property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the document property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getDocument().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link Document }
         * 
         * 
         */
        public List<Document> getDocument() {
            if (document == null) {
                document = new ArrayList<Document>();
            }
            return this.document;
        }

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

        /**
         * Gets the value of the advancedContent property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the advancedContent property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getAdvancedContent().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link AdvancedContent }
         * 
         * 
         */
        public List<AdvancedContent> getAdvancedContent() {
            if (advancedContent == null) {
                advancedContent = new ArrayList<AdvancedContent>();
            }
            return this.advancedContent;
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
     *         &lt;any processContents='lax' minOccurs="0"/>
     *       &lt;/sequence>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "any"
    })
    public static class Xml {

        @XmlAnyElement(lax = true)
        protected Object any;

        /**
         * Gets the value of the any property.
         * 
         * @return
         *     possible object is
         *     {@link Object }
         *     {@link Element }
         *     
         */
        public Object getAny() {
            return any;
        }

        /**
         * Sets the value of the any property.
         * 
         * @param value
         *     allowed object is
         *     {@link Object }
         *     {@link Element }
         *     
         */
        public void setAny(Object value) {
            this.any = value;
        }

    }

}
