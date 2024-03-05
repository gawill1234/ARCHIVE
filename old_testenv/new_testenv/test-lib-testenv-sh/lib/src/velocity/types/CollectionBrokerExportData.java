
package velocity.types;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAnyElement;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import org.w3c.dom.Element;
import velocity.objects.FieldMap;
import velocity.objects.Operator;
import velocity.objects.VseMeta;
import velocity.soap.Authentication;


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
 *         &lt;element ref="{urn:/velocity/soap}authentication" minOccurs="0"/>
 *         &lt;element name="source-collection" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN"/>
 *         &lt;element name="destination-collection" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN"/>
 *         &lt;element name="destination-collection-meta" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}vse-meta"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="move" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="query" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="query-object" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}operator"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="query-condition-object" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}operator"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="query-condition-xpath" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="query-modification-macros" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="syntax-operators" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="syntax-repository-node" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="syntax-field-mappings" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence maxOccurs="unbounded">
 *                   &lt;element ref="{urn:/velocity/objects}field-map"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="term-expand-max-expansions" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="term-expand-error-when-exceeds-limit" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="dict-expand-dictionary" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="dict-expand-max-expansions" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="dict-expand-stem-enabled" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="dict-expand-stem-stemmers" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="dict-expand-wildcard-enabled" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="dict-expand-wildcard-min-length" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="dict-expand-wildcard-segmenter" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="dict-expand-wildcard-delanguage" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="dict-expand-regex-enabled" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="arena" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="authorization-rights" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="authorization-username" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="authorization-password" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="efficient-paging" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="efficient-paging-n-top-docs-to-cluster" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="extra-xml" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;any processContents='lax'/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
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
    "authentication",
    "sourceCollection",
    "destinationCollection",
    "destinationCollectionMeta",
    "move",
    "query",
    "queryObject",
    "queryConditionObject",
    "queryConditionXpath",
    "queryModificationMacros",
    "syntaxOperators",
    "syntaxRepositoryNode",
    "syntaxFieldMappings",
    "termExpandMaxExpansions",
    "termExpandErrorWhenExceedsLimit",
    "dictExpandDictionary",
    "dictExpandMaxExpansions",
    "dictExpandStemEnabled",
    "dictExpandStemStemmers",
    "dictExpandWildcardEnabled",
    "dictExpandWildcardMinLength",
    "dictExpandWildcardSegmenter",
    "dictExpandWildcardDelanguage",
    "dictExpandRegexEnabled",
    "arena",
    "authorizationRights",
    "authorizationUsername",
    "authorizationPassword",
    "efficientPaging",
    "efficientPagingNTopDocsToCluster",
    "extraXml"
})
@XmlRootElement(name = "CollectionBrokerExportData")
public class CollectionBrokerExportData {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(name = "source-collection", required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String sourceCollection;
    @XmlElement(name = "destination-collection", required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String destinationCollection;
    @XmlElement(name = "destination-collection-meta")
    protected CollectionBrokerExportData.DestinationCollectionMeta destinationCollectionMeta;
    @XmlElement(defaultValue = "false")
    protected Boolean move;
    protected String query;
    @XmlElement(name = "query-object")
    protected CollectionBrokerExportData.QueryObject queryObject;
    @XmlElement(name = "query-condition-object")
    protected CollectionBrokerExportData.QueryConditionObject queryConditionObject;
    @XmlElement(name = "query-condition-xpath")
    protected String queryConditionXpath;
    @XmlElement(name = "query-modification-macros")
    protected String queryModificationMacros;
    @XmlElement(name = "syntax-operators", defaultValue = "AND and () CONTAINING CONTENT %field%: + NEAR - NOT NOTCONTAINING NOTWITHIN OR0 quotes regex stem THRU BEFORE FOLLOWEDBY weight wildcard wildchar WITHIN WORDS site less-than less-than-or-equal greater-than greater-than-or-equal equal range")
    protected String syntaxOperators;
    @XmlElement(name = "syntax-repository-node", defaultValue = "custom")
    protected String syntaxRepositoryNode;
    @XmlElement(name = "syntax-field-mappings")
    protected CollectionBrokerExportData.SyntaxFieldMappings syntaxFieldMappings;
    @XmlElement(name = "term-expand-max-expansions")
    protected Integer termExpandMaxExpansions;
    @XmlElement(name = "term-expand-error-when-exceeds-limit")
    protected Boolean termExpandErrorWhenExceedsLimit;
    @XmlElement(name = "dict-expand-dictionary")
    protected String dictExpandDictionary;
    @XmlElement(name = "dict-expand-max-expansions")
    protected Integer dictExpandMaxExpansions;
    @XmlElement(name = "dict-expand-stem-enabled")
    protected Boolean dictExpandStemEnabled;
    @XmlElement(name = "dict-expand-stem-stemmers")
    protected String dictExpandStemStemmers;
    @XmlElement(name = "dict-expand-wildcard-enabled")
    protected Boolean dictExpandWildcardEnabled;
    @XmlElement(name = "dict-expand-wildcard-min-length")
    protected Integer dictExpandWildcardMinLength;
    @XmlElement(name = "dict-expand-wildcard-segmenter")
    protected String dictExpandWildcardSegmenter;
    @XmlElement(name = "dict-expand-wildcard-delanguage")
    protected Boolean dictExpandWildcardDelanguage;
    @XmlElement(name = "dict-expand-regex-enabled")
    protected Boolean dictExpandRegexEnabled;
    protected String arena;
    @XmlElement(name = "authorization-rights")
    protected String authorizationRights;
    @XmlElement(name = "authorization-username")
    protected String authorizationUsername;
    @XmlElement(name = "authorization-password")
    protected String authorizationPassword;
    @XmlElement(name = "efficient-paging", defaultValue = "false")
    protected Boolean efficientPaging;
    @XmlElement(name = "efficient-paging-n-top-docs-to-cluster", defaultValue = "200")
    protected Integer efficientPagingNTopDocsToCluster;
    @XmlElement(name = "extra-xml")
    protected CollectionBrokerExportData.ExtraXml extraXml;

    /**
     * Gets the value of the authentication property.
     * 
     * @return
     *     possible object is
     *     {@link Authentication }
     *     
     */
    public Authentication getAuthentication() {
        return authentication;
    }

    /**
     * Sets the value of the authentication property.
     * 
     * @param value
     *     allowed object is
     *     {@link Authentication }
     *     
     */
    public void setAuthentication(Authentication value) {
        this.authentication = value;
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
     * Gets the value of the destinationCollectionMeta property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerExportData.DestinationCollectionMeta }
     *     
     */
    public CollectionBrokerExportData.DestinationCollectionMeta getDestinationCollectionMeta() {
        return destinationCollectionMeta;
    }

    /**
     * Sets the value of the destinationCollectionMeta property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerExportData.DestinationCollectionMeta }
     *     
     */
    public void setDestinationCollectionMeta(CollectionBrokerExportData.DestinationCollectionMeta value) {
        this.destinationCollectionMeta = value;
    }

    /**
     * Gets the value of the move property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isMove() {
        return move;
    }

    /**
     * Sets the value of the move property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setMove(Boolean value) {
        this.move = value;
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
     * Gets the value of the queryObject property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerExportData.QueryObject }
     *     
     */
    public CollectionBrokerExportData.QueryObject getQueryObject() {
        return queryObject;
    }

    /**
     * Sets the value of the queryObject property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerExportData.QueryObject }
     *     
     */
    public void setQueryObject(CollectionBrokerExportData.QueryObject value) {
        this.queryObject = value;
    }

    /**
     * Gets the value of the queryConditionObject property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerExportData.QueryConditionObject }
     *     
     */
    public CollectionBrokerExportData.QueryConditionObject getQueryConditionObject() {
        return queryConditionObject;
    }

    /**
     * Sets the value of the queryConditionObject property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerExportData.QueryConditionObject }
     *     
     */
    public void setQueryConditionObject(CollectionBrokerExportData.QueryConditionObject value) {
        this.queryConditionObject = value;
    }

    /**
     * Gets the value of the queryConditionXpath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getQueryConditionXpath() {
        return queryConditionXpath;
    }

    /**
     * Sets the value of the queryConditionXpath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setQueryConditionXpath(String value) {
        this.queryConditionXpath = value;
    }

    /**
     * Gets the value of the queryModificationMacros property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getQueryModificationMacros() {
        return queryModificationMacros;
    }

    /**
     * Sets the value of the queryModificationMacros property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setQueryModificationMacros(String value) {
        this.queryModificationMacros = value;
    }

    /**
     * Gets the value of the syntaxOperators property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSyntaxOperators() {
        return syntaxOperators;
    }

    /**
     * Sets the value of the syntaxOperators property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSyntaxOperators(String value) {
        this.syntaxOperators = value;
    }

    /**
     * Gets the value of the syntaxRepositoryNode property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSyntaxRepositoryNode() {
        return syntaxRepositoryNode;
    }

    /**
     * Sets the value of the syntaxRepositoryNode property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSyntaxRepositoryNode(String value) {
        this.syntaxRepositoryNode = value;
    }

    /**
     * Gets the value of the syntaxFieldMappings property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerExportData.SyntaxFieldMappings }
     *     
     */
    public CollectionBrokerExportData.SyntaxFieldMappings getSyntaxFieldMappings() {
        return syntaxFieldMappings;
    }

    /**
     * Sets the value of the syntaxFieldMappings property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerExportData.SyntaxFieldMappings }
     *     
     */
    public void setSyntaxFieldMappings(CollectionBrokerExportData.SyntaxFieldMappings value) {
        this.syntaxFieldMappings = value;
    }

    /**
     * Gets the value of the termExpandMaxExpansions property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTermExpandMaxExpansions() {
        return termExpandMaxExpansions;
    }

    /**
     * Sets the value of the termExpandMaxExpansions property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTermExpandMaxExpansions(Integer value) {
        this.termExpandMaxExpansions = value;
    }

    /**
     * Gets the value of the termExpandErrorWhenExceedsLimit property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isTermExpandErrorWhenExceedsLimit() {
        return termExpandErrorWhenExceedsLimit;
    }

    /**
     * Sets the value of the termExpandErrorWhenExceedsLimit property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setTermExpandErrorWhenExceedsLimit(Boolean value) {
        this.termExpandErrorWhenExceedsLimit = value;
    }

    /**
     * Gets the value of the dictExpandDictionary property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDictExpandDictionary() {
        return dictExpandDictionary;
    }

    /**
     * Sets the value of the dictExpandDictionary property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDictExpandDictionary(String value) {
        this.dictExpandDictionary = value;
    }

    /**
     * Gets the value of the dictExpandMaxExpansions property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDictExpandMaxExpansions() {
        return dictExpandMaxExpansions;
    }

    /**
     * Sets the value of the dictExpandMaxExpansions property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDictExpandMaxExpansions(Integer value) {
        this.dictExpandMaxExpansions = value;
    }

    /**
     * Gets the value of the dictExpandStemEnabled property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDictExpandStemEnabled() {
        return dictExpandStemEnabled;
    }

    /**
     * Sets the value of the dictExpandStemEnabled property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDictExpandStemEnabled(Boolean value) {
        this.dictExpandStemEnabled = value;
    }

    /**
     * Gets the value of the dictExpandStemStemmers property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDictExpandStemStemmers() {
        return dictExpandStemStemmers;
    }

    /**
     * Sets the value of the dictExpandStemStemmers property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDictExpandStemStemmers(String value) {
        this.dictExpandStemStemmers = value;
    }

    /**
     * Gets the value of the dictExpandWildcardEnabled property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDictExpandWildcardEnabled() {
        return dictExpandWildcardEnabled;
    }

    /**
     * Sets the value of the dictExpandWildcardEnabled property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDictExpandWildcardEnabled(Boolean value) {
        this.dictExpandWildcardEnabled = value;
    }

    /**
     * Gets the value of the dictExpandWildcardMinLength property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDictExpandWildcardMinLength() {
        return dictExpandWildcardMinLength;
    }

    /**
     * Sets the value of the dictExpandWildcardMinLength property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDictExpandWildcardMinLength(Integer value) {
        this.dictExpandWildcardMinLength = value;
    }

    /**
     * Gets the value of the dictExpandWildcardSegmenter property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDictExpandWildcardSegmenter() {
        return dictExpandWildcardSegmenter;
    }

    /**
     * Sets the value of the dictExpandWildcardSegmenter property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDictExpandWildcardSegmenter(String value) {
        this.dictExpandWildcardSegmenter = value;
    }

    /**
     * Gets the value of the dictExpandWildcardDelanguage property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDictExpandWildcardDelanguage() {
        return dictExpandWildcardDelanguage;
    }

    /**
     * Sets the value of the dictExpandWildcardDelanguage property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDictExpandWildcardDelanguage(Boolean value) {
        this.dictExpandWildcardDelanguage = value;
    }

    /**
     * Gets the value of the dictExpandRegexEnabled property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDictExpandRegexEnabled() {
        return dictExpandRegexEnabled;
    }

    /**
     * Sets the value of the dictExpandRegexEnabled property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDictExpandRegexEnabled(Boolean value) {
        this.dictExpandRegexEnabled = value;
    }

    /**
     * Gets the value of the arena property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getArena() {
        return arena;
    }

    /**
     * Sets the value of the arena property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setArena(String value) {
        this.arena = value;
    }

    /**
     * Gets the value of the authorizationRights property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthorizationRights() {
        return authorizationRights;
    }

    /**
     * Sets the value of the authorizationRights property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthorizationRights(String value) {
        this.authorizationRights = value;
    }

    /**
     * Gets the value of the authorizationUsername property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthorizationUsername() {
        return authorizationUsername;
    }

    /**
     * Sets the value of the authorizationUsername property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthorizationUsername(String value) {
        this.authorizationUsername = value;
    }

    /**
     * Gets the value of the authorizationPassword property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthorizationPassword() {
        return authorizationPassword;
    }

    /**
     * Sets the value of the authorizationPassword property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthorizationPassword(String value) {
        this.authorizationPassword = value;
    }

    /**
     * Gets the value of the efficientPaging property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isEfficientPaging() {
        return efficientPaging;
    }

    /**
     * Sets the value of the efficientPaging property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setEfficientPaging(Boolean value) {
        this.efficientPaging = value;
    }

    /**
     * Gets the value of the efficientPagingNTopDocsToCluster property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEfficientPagingNTopDocsToCluster() {
        return efficientPagingNTopDocsToCluster;
    }

    /**
     * Sets the value of the efficientPagingNTopDocsToCluster property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEfficientPagingNTopDocsToCluster(Integer value) {
        this.efficientPagingNTopDocsToCluster = value;
    }

    /**
     * Gets the value of the extraXml property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerExportData.ExtraXml }
     *     
     */
    public CollectionBrokerExportData.ExtraXml getExtraXml() {
        return extraXml;
    }

    /**
     * Sets the value of the extraXml property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerExportData.ExtraXml }
     *     
     */
    public void setExtraXml(CollectionBrokerExportData.ExtraXml value) {
        this.extraXml = value;
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
     *         &lt;element ref="{urn:/velocity/objects}vse-meta"/>
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
        "vseMeta"
    })
    public static class DestinationCollectionMeta {

        @XmlElement(name = "vse-meta", namespace = "urn:/velocity/objects", required = true)
        protected VseMeta vseMeta;

        /**
         * Gets the value of the vseMeta property.
         * 
         * @return
         *     possible object is
         *     {@link VseMeta }
         *     
         */
        public VseMeta getVseMeta() {
            return vseMeta;
        }

        /**
         * Sets the value of the vseMeta property.
         * 
         * @param value
         *     allowed object is
         *     {@link VseMeta }
         *     
         */
        public void setVseMeta(VseMeta value) {
            this.vseMeta = value;
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
     *         &lt;any processContents='lax'/>
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
    public static class ExtraXml {

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
     *         &lt;element ref="{urn:/velocity/objects}operator"/>
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
        "operator"
    })
    public static class QueryConditionObject {

        @XmlElement(namespace = "urn:/velocity/objects", required = true)
        protected Operator operator;

        /**
         * Gets the value of the operator property.
         * 
         * @return
         *     possible object is
         *     {@link Operator }
         *     
         */
        public Operator getOperator() {
            return operator;
        }

        /**
         * Sets the value of the operator property.
         * 
         * @param value
         *     allowed object is
         *     {@link Operator }
         *     
         */
        public void setOperator(Operator value) {
            this.operator = value;
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
     *         &lt;element ref="{urn:/velocity/objects}operator"/>
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
        "operator"
    })
    public static class QueryObject {

        @XmlElement(namespace = "urn:/velocity/objects", required = true)
        protected Operator operator;

        /**
         * Gets the value of the operator property.
         * 
         * @return
         *     possible object is
         *     {@link Operator }
         *     
         */
        public Operator getOperator() {
            return operator;
        }

        /**
         * Sets the value of the operator property.
         * 
         * @param value
         *     allowed object is
         *     {@link Operator }
         *     
         */
        public void setOperator(Operator value) {
            this.operator = value;
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
     *       &lt;sequence maxOccurs="unbounded">
     *         &lt;element ref="{urn:/velocity/objects}field-map"/>
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
        "fieldMap"
    })
    public static class SyntaxFieldMappings {

        @XmlElement(name = "field-map", namespace = "urn:/velocity/objects", required = true)
        protected List<FieldMap> fieldMap;

        /**
         * Gets the value of the fieldMap property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the fieldMap property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getFieldMap().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link FieldMap }
         * 
         * 
         */
        public List<FieldMap> getFieldMap() {
            if (fieldMap == null) {
                fieldMap = new ArrayList<FieldMap>();
            }
            return this.fieldMap;
        }

    }

}
