
package velocity.objects;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAnyAttribute;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import javax.xml.namespace.QName;


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
 *         &lt;element ref="{urn:/velocity/objects}sort-key" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index-stream" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}content" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}advanced-content" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}cache" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-collapsed" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}duplicate-documents" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attGroup ref="{urn:/velocity/objects}boost"/>
 *       &lt;attribute name="key" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="vse-key" type="{urn:/velocity/objects}vse-key" />
 *       &lt;attribute name="vse-doc-hash" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="vse-key-normalized">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="vse-key-normalized"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="vse-n-collapsed" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="vse-auto-url">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="first-document"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="authorization-url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="default-content-acl" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="full-document-acl" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="cache-acl" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="duplicates-priority" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="display-url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="rank" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="score" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="matched" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="binned" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="source" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="display-source" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="source-type" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="parse-ref" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="paid" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="original-id" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="base-score" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="vse-base-score" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="la-score" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="la-score-multiplier" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="vertex" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="query" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="duplicates" type="{http://www.w3.org/2001/XMLSchema}NMTOKENS" />
 *       &lt;attribute name="duplicate-of" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="duplicate-type">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="near"/>
 *             &lt;enumeration value="key"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="boost-name" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="boost-score" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="collapse-key" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="collapse-type">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="first"/>
 *             &lt;enumeration value="subsequent"/>
 *             &lt;enumeration value="hidden"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="stub">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="stub"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="cookie-jar" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="headers" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="parser" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="top-paid">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="top-paid"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="mwi-shingle" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="vse">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="vse"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="vse-key-check" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;anyAttribute processContents='skip' namespace=''/>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "sortKey",
    "vseIndexStream",
    "content",
    "advancedContent",
    "cache",
    "vseCollapsed",
    "duplicateDocuments"
})
@XmlRootElement(name = "document")
public class Document {

    @XmlElement(name = "sort-key")
    protected List<SortKey> sortKey;
    @XmlElement(name = "vse-index-stream")
    protected List<VseIndexStream> vseIndexStream;
    protected List<Content> content;
    @XmlElement(name = "advanced-content")
    protected List<AdvancedContent> advancedContent;
    protected List<Cache> cache;
    @XmlElement(name = "vse-collapsed")
    protected VseCollapsed vseCollapsed;
    @XmlElement(name = "duplicate-documents")
    protected List<DuplicateDocuments> duplicateDocuments;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String key;
    @XmlAttribute(name = "vse-key")
    protected String vseKey;
    @XmlAttribute(name = "vse-doc-hash")
    protected String vseDocHash;
    @XmlAttribute(name = "vse-key-normalized")
    protected String vseKeyNormalized;
    @XmlAttribute(name = "vse-n-collapsed")
    protected Integer vseNCollapsed;
    @XmlAttribute(name = "vse-auto-url")
    protected String vseAutoUrl;
    @XmlAttribute(name = "authorization-url")
    protected String authorizationUrl;
    @XmlAttribute(name = "default-content-acl")
    protected String defaultContentAcl;
    @XmlAttribute(name = "full-document-acl")
    protected String fullDocumentAcl;
    @XmlAttribute(name = "cache-acl")
    protected String cacheAcl;
    @XmlAttribute(name = "duplicates-priority")
    protected Double duplicatesPriority;
    @XmlAttribute
    protected String url;
    @XmlAttribute(name = "display-url")
    protected String displayUrl;
    @XmlAttribute
    protected String rank;
    @XmlAttribute
    protected Double score;
    @XmlAttribute
    protected Integer matched;
    @XmlAttribute
    protected String binned;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String source;
    @XmlAttribute(name = "display-source")
    protected String displaySource;
    @XmlAttribute(name = "source-type")
    protected String sourceType;
    @XmlAttribute(name = "parse-ref")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String parseRef;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String id;
    @XmlAttribute
    protected java.lang.Boolean paid;
    @XmlAttribute(name = "original-id")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String originalId;
    @XmlAttribute(name = "base-score")
    protected Double baseScore;
    @XmlAttribute(name = "vse-base-score")
    protected Double vseBaseScore;
    @XmlAttribute(name = "la-score")
    protected Double laScore;
    @XmlAttribute(name = "la-score-multiplier")
    protected Double laScoreMultiplier;
    @XmlAttribute
    protected Integer vertex;
    @XmlAttribute
    protected String query;
    @XmlAttribute
    @XmlSchemaType(name = "NMTOKENS")
    protected List<String> duplicates;
    @XmlAttribute(name = "duplicate-of")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String duplicateOf;
    @XmlAttribute(name = "duplicate-type")
    protected String duplicateType;
    @XmlAttribute(name = "boost-name")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String boostName;
    @XmlAttribute(name = "boost-score")
    protected Double boostScore;
    @XmlAttribute(name = "collapse-key")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String collapseKey;
    @XmlAttribute(name = "collapse-type")
    protected String collapseType;
    @XmlAttribute
    protected String stub;
    @XmlAttribute(name = "cookie-jar")
    protected String cookieJar;
    @XmlAttribute
    protected String headers;
    @XmlAttribute
    protected String parser;
    @XmlAttribute(name = "top-paid")
    protected String topPaid;
    @XmlAttribute(name = "mwi-shingle")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String mwiShingle;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String vse;
    @XmlAttribute(name = "vse-key-check")
    @XmlSchemaType(name = "anySimpleType")
    protected String vseKeyCheck;
    @XmlAttribute
    protected java.lang.Boolean async;
    @XmlAttribute(name = "elt-id")
    protected Integer eltId;
    @XmlAttribute(name = "max-elt-id")
    protected Integer maxEltId;
    @XmlAttribute(name = "execute-acl")
    protected String executeAcl;
    @XmlAttribute
    protected String process;
    @XmlAttribute(name = "boost-levels")
    protected String boostLevels;
    @XmlAttribute(name = "boost-display")
    protected String boostDisplay;
    @XmlAnyAttribute
    private Map<QName, String> otherAttributes = new HashMap<QName, String>();

    /**
     * Gets the value of the sortKey property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the sortKey property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSortKey().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SortKey }
     * 
     * 
     */
    public List<SortKey> getSortKey() {
        if (sortKey == null) {
            sortKey = new ArrayList<SortKey>();
        }
        return this.sortKey;
    }

    /**
     * Gets the value of the vseIndexStream property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseIndexStream property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseIndexStream().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseIndexStream }
     * 
     * 
     */
    public List<VseIndexStream> getVseIndexStream() {
        if (vseIndexStream == null) {
            vseIndexStream = new ArrayList<VseIndexStream>();
        }
        return this.vseIndexStream;
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

    /**
     * Gets the value of the cache property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the cache property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCache().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Cache }
     * 
     * 
     */
    public List<Cache> getCache() {
        if (cache == null) {
            cache = new ArrayList<Cache>();
        }
        return this.cache;
    }

    /**
     * Gets the value of the vseCollapsed property.
     * 
     * @return
     *     possible object is
     *     {@link VseCollapsed }
     *     
     */
    public VseCollapsed getVseCollapsed() {
        return vseCollapsed;
    }

    /**
     * Sets the value of the vseCollapsed property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseCollapsed }
     *     
     */
    public void setVseCollapsed(VseCollapsed value) {
        this.vseCollapsed = value;
    }

    /**
     * Gets the value of the duplicateDocuments property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the duplicateDocuments property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getDuplicateDocuments().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link DuplicateDocuments }
     * 
     * 
     */
    public List<DuplicateDocuments> getDuplicateDocuments() {
        if (duplicateDocuments == null) {
            duplicateDocuments = new ArrayList<DuplicateDocuments>();
        }
        return this.duplicateDocuments;
    }

    /**
     * Gets the value of the key property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getKey() {
        return key;
    }

    /**
     * Sets the value of the key property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setKey(String value) {
        this.key = value;
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
     * Gets the value of the vseDocHash property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseDocHash() {
        return vseDocHash;
    }

    /**
     * Sets the value of the vseDocHash property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseDocHash(String value) {
        this.vseDocHash = value;
    }

    /**
     * Gets the value of the vseKeyNormalized property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseKeyNormalized() {
        return vseKeyNormalized;
    }

    /**
     * Sets the value of the vseKeyNormalized property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseKeyNormalized(String value) {
        this.vseKeyNormalized = value;
    }

    /**
     * Gets the value of the vseNCollapsed property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getVseNCollapsed() {
        return vseNCollapsed;
    }

    /**
     * Sets the value of the vseNCollapsed property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setVseNCollapsed(Integer value) {
        this.vseNCollapsed = value;
    }

    /**
     * Gets the value of the vseAutoUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseAutoUrl() {
        return vseAutoUrl;
    }

    /**
     * Sets the value of the vseAutoUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseAutoUrl(String value) {
        this.vseAutoUrl = value;
    }

    /**
     * Gets the value of the authorizationUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthorizationUrl() {
        return authorizationUrl;
    }

    /**
     * Sets the value of the authorizationUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthorizationUrl(String value) {
        this.authorizationUrl = value;
    }

    /**
     * Gets the value of the defaultContentAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDefaultContentAcl() {
        return defaultContentAcl;
    }

    /**
     * Sets the value of the defaultContentAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDefaultContentAcl(String value) {
        this.defaultContentAcl = value;
    }

    /**
     * Gets the value of the fullDocumentAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFullDocumentAcl() {
        return fullDocumentAcl;
    }

    /**
     * Sets the value of the fullDocumentAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFullDocumentAcl(String value) {
        this.fullDocumentAcl = value;
    }

    /**
     * Gets the value of the cacheAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCacheAcl() {
        return cacheAcl;
    }

    /**
     * Sets the value of the cacheAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCacheAcl(String value) {
        this.cacheAcl = value;
    }

    /**
     * Gets the value of the duplicatesPriority property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getDuplicatesPriority() {
        return duplicatesPriority;
    }

    /**
     * Sets the value of the duplicatesPriority property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setDuplicatesPriority(Double value) {
        this.duplicatesPriority = value;
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
     * Gets the value of the displayUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisplayUrl() {
        return displayUrl;
    }

    /**
     * Sets the value of the displayUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisplayUrl(String value) {
        this.displayUrl = value;
    }

    /**
     * Gets the value of the rank property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRank() {
        return rank;
    }

    /**
     * Sets the value of the rank property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRank(String value) {
        this.rank = value;
    }

    /**
     * Gets the value of the score property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getScore() {
        return score;
    }

    /**
     * Sets the value of the score property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setScore(Double value) {
        this.score = value;
    }

    /**
     * Gets the value of the matched property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMatched() {
        if (matched == null) {
            return  0;
        } else {
            return matched;
        }
    }

    /**
     * Sets the value of the matched property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMatched(Integer value) {
        this.matched = value;
    }

    /**
     * Gets the value of the binned property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBinned() {
        return binned;
    }

    /**
     * Sets the value of the binned property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBinned(String value) {
        this.binned = value;
    }

    /**
     * Gets the value of the source property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSource() {
        return source;
    }

    /**
     * Sets the value of the source property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSource(String value) {
        this.source = value;
    }

    /**
     * Gets the value of the displaySource property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisplaySource() {
        return displaySource;
    }

    /**
     * Sets the value of the displaySource property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisplaySource(String value) {
        this.displaySource = value;
    }

    /**
     * Gets the value of the sourceType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSourceType() {
        return sourceType;
    }

    /**
     * Sets the value of the sourceType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSourceType(String value) {
        this.sourceType = value;
    }

    /**
     * Gets the value of the parseRef property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getParseRef() {
        return parseRef;
    }

    /**
     * Sets the value of the parseRef property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setParseRef(String value) {
        this.parseRef = value;
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
     * Gets the value of the paid property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isPaid() {
        return paid;
    }

    /**
     * Sets the value of the paid property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setPaid(java.lang.Boolean value) {
        this.paid = value;
    }

    /**
     * Gets the value of the originalId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOriginalId() {
        return originalId;
    }

    /**
     * Sets the value of the originalId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOriginalId(String value) {
        this.originalId = value;
    }

    /**
     * Gets the value of the baseScore property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getBaseScore() {
        return baseScore;
    }

    /**
     * Sets the value of the baseScore property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setBaseScore(Double value) {
        this.baseScore = value;
    }

    /**
     * Gets the value of the vseBaseScore property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getVseBaseScore() {
        return vseBaseScore;
    }

    /**
     * Sets the value of the vseBaseScore property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setVseBaseScore(Double value) {
        this.vseBaseScore = value;
    }

    /**
     * Gets the value of the laScore property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getLaScore() {
        return laScore;
    }

    /**
     * Sets the value of the laScore property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setLaScore(Double value) {
        this.laScore = value;
    }

    /**
     * Gets the value of the laScoreMultiplier property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getLaScoreMultiplier() {
        return laScoreMultiplier;
    }

    /**
     * Sets the value of the laScoreMultiplier property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setLaScoreMultiplier(Double value) {
        this.laScoreMultiplier = value;
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
     * Gets the value of the query property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getQuery() {
        return query;
    }

    /**
     * Sets the value of the query property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setQuery(String value) {
        this.query = value;
    }

    /**
     * Gets the value of the duplicates property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the duplicates property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getDuplicates().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * 
     * 
     */
    public List<String> getDuplicates() {
        if (duplicates == null) {
            duplicates = new ArrayList<String>();
        }
        return this.duplicates;
    }

    /**
     * Gets the value of the duplicateOf property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDuplicateOf() {
        return duplicateOf;
    }

    /**
     * Sets the value of the duplicateOf property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDuplicateOf(String value) {
        this.duplicateOf = value;
    }

    /**
     * Gets the value of the duplicateType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDuplicateType() {
        return duplicateType;
    }

    /**
     * Sets the value of the duplicateType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDuplicateType(String value) {
        this.duplicateType = value;
    }

    /**
     * Gets the value of the boostName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBoostName() {
        return boostName;
    }

    /**
     * Sets the value of the boostName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBoostName(String value) {
        this.boostName = value;
    }

    /**
     * Gets the value of the boostScore property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getBoostScore() {
        return boostScore;
    }

    /**
     * Sets the value of the boostScore property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setBoostScore(Double value) {
        this.boostScore = value;
    }

    /**
     * Gets the value of the collapseKey property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollapseKey() {
        return collapseKey;
    }

    /**
     * Sets the value of the collapseKey property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollapseKey(String value) {
        this.collapseKey = value;
    }

    /**
     * Gets the value of the collapseType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollapseType() {
        return collapseType;
    }

    /**
     * Sets the value of the collapseType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollapseType(String value) {
        this.collapseType = value;
    }

    /**
     * Gets the value of the stub property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStub() {
        return stub;
    }

    /**
     * Sets the value of the stub property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStub(String value) {
        this.stub = value;
    }

    /**
     * Gets the value of the cookieJar property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCookieJar() {
        return cookieJar;
    }

    /**
     * Sets the value of the cookieJar property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCookieJar(String value) {
        this.cookieJar = value;
    }

    /**
     * Gets the value of the headers property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHeaders() {
        return headers;
    }

    /**
     * Sets the value of the headers property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHeaders(String value) {
        this.headers = value;
    }

    /**
     * Gets the value of the parser property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getParser() {
        return parser;
    }

    /**
     * Sets the value of the parser property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setParser(String value) {
        this.parser = value;
    }

    /**
     * Gets the value of the topPaid property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTopPaid() {
        return topPaid;
    }

    /**
     * Sets the value of the topPaid property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTopPaid(String value) {
        this.topPaid = value;
    }

    /**
     * Gets the value of the mwiShingle property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMwiShingle() {
        return mwiShingle;
    }

    /**
     * Sets the value of the mwiShingle property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMwiShingle(String value) {
        this.mwiShingle = value;
    }

    /**
     * Gets the value of the vse property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVse() {
        return vse;
    }

    /**
     * Sets the value of the vse property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVse(String value) {
        this.vse = value;
    }

    /**
     * Gets the value of the vseKeyCheck property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVseKeyCheck() {
        return vseKeyCheck;
    }

    /**
     * Sets the value of the vseKeyCheck property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVseKeyCheck(String value) {
        this.vseKeyCheck = value;
    }

    /**
     * Gets the value of the async property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isAsync() {
        if (async == null) {
            return true;
        } else {
            return async;
        }
    }

    /**
     * Sets the value of the async property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setAsync(java.lang.Boolean value) {
        this.async = value;
    }

    /**
     * Gets the value of the eltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEltId() {
        return eltId;
    }

    /**
     * Sets the value of the eltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEltId(Integer value) {
        this.eltId = value;
    }

    /**
     * Gets the value of the maxEltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxEltId() {
        return maxEltId;
    }

    /**
     * Sets the value of the maxEltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxEltId(Integer value) {
        this.maxEltId = value;
    }

    /**
     * Gets the value of the executeAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExecuteAcl() {
        return executeAcl;
    }

    /**
     * Sets the value of the executeAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExecuteAcl(String value) {
        this.executeAcl = value;
    }

    /**
     * Gets the value of the process property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProcess() {
        return process;
    }

    /**
     * Sets the value of the process property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProcess(String value) {
        this.process = value;
    }

    /**
     * Gets the value of the boostLevels property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBoostLevels() {
        if (boostLevels == null) {
            return "-1";
        } else {
            return boostLevels;
        }
    }

    /**
     * Sets the value of the boostLevels property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBoostLevels(String value) {
        this.boostLevels = value;
    }

    /**
     * Gets the value of the boostDisplay property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBoostDisplay() {
        if (boostDisplay == null) {
            return "boost-and-list";
        } else {
            return boostDisplay;
        }
    }

    /**
     * Sets the value of the boostDisplay property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBoostDisplay(String value) {
        this.boostDisplay = value;
    }

    /**
     * Gets a map that contains attributes that aren't bound to any typed property on this class.
     * 
     * <p>
     * the map is keyed by the name of the attribute and 
     * the value is the string value of the attribute.
     * 
     * the map returned by this method is live, and you can add new attribute
     * by updating the map directly. Because of this design, there's no setter.
     * 
     * 
     * @return
     *     always non-null
     */
    public Map<QName, String> getOtherAttributes() {
        return otherAttributes;
    }

}
